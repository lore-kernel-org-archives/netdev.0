From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH] net: core: dev.c: use spin_lock_irqsave() rather than
Date: Mon, 20 Sep 2010 17:08:55 +0200
Message-ID: <ee14e5e38e7a5df520d902ef8a236bbe9ed206fa.1284991149.git.m.nazarewicz@samsung.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit fixes a warning that was issued when g_ether gadget
was connected to Windows host.  In g_ether, the dev_txq_stats_fold()
can be called from context other then soft-irq so _bh version of
spin_lock is not adequate.

Changing from spin_lock_bh() to spin_lock_irqsave() is always safe (as
irqsave is superset of all other spin lock operations) is always safe
so this commit should not break anything.

As Eric Dumazet said, dev_txq_stats_fold() is a slow patch so there
is no need to optimise that much.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

Hello David,

could you pull this patch.  I think it's best to get it in 2.6.36.


Without this patch, I got the following warning when RNDIS
configuration is chosen:

> ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:143 local_bh_enable_ip+0x44/0xc0()
> Modules linked in:
> [<c002d73c>] (unwind_backtrace+0x0/0xf0) from [<c0043b60>] (warn_slowpath_common+0x4c/0x64)
> [<c0043b60>] (warn_slowpath_common+0x4c/0x64) from [<c0043b90>] (warn_slowpath_null+0x18/0x1c)
> [<c0043b90>] (warn_slowpath_null+0x18/0x1c) from [<c0049024>] (local_bh_enable_ip+0x44/0xc0)
> [<c0049024>] (local_bh_enable_ip+0x44/0xc0) from [<c025ef18>] (dev_txq_stats_fold+0xac/0x108)
> [<c025ef18>] (dev_txq_stats_fold+0xac/0x108) from [<c025f018>] (dev_get_stats+0xa4/0xac)
> [<c025f018>] (dev_get_stats+0xa4/0xac) from [<c01f72bc>] (gen_ndis_query_resp+0x4c/0x43c)
> [<c01f72bc>] (gen_ndis_query_resp+0x4c/0x43c) from [<c01f784c>] (rndis_msg_parser+0x1a0/0x32c)
> [<c01f784c>] (rndis_msg_parser+0x1a0/0x32c) from [<c01f79f8>] (rndis_command_complete+0x20/0x4c)
> [<c01f79f8>] (rndis_command_complete+0x20/0x4c) from [<c01f3278>] (done+0x5c/0x70)
> [<c01f3278>] (done+0x5c/0x70) from [<c01f3c60>] (complete_tx+0xf0/0x1a8)
> [<c01f3c60>] (complete_tx+0xf0/0x1a8) from [<c01f3d8c>] (process_ep_in_intr+0x74/0x14c)
> [<c01f3d8c>] (process_ep_in_intr+0x74/0x14c) from [<c01f470c>] (s3c_udc_irq+0x2c8/0x3f4)
> [<c01f470c>] (s3c_udc_irq+0x2c8/0x3f4) from [<c006dfd0>] (handle_IRQ_event+0x24/0xe4)
> [<c006dfd0>] (handle_IRQ_event+0x24/0xe4) from [<c006fe40>] (handle_level_irq+0xb0/0x12c)
> [<c006fe40>] (handle_level_irq+0xb0/0x12c) from [<c0027074>] (asm_do_IRQ+0x74/0x98)
> [<c0027074>] (asm_do_IRQ+0x74/0x98) from [<c0027ca4>] (__irq_usr+0x44/0xc0)
> Exception stack(0xe735ffb0 to 0xe735fff8)
> ffa0:                                     000cc328 00000000 00000000 bec76520
> ffc0: 000ee008 000bd210 00000000 00000000 000ee068 000ee008 bec76524 bec76520
> ffe0: 000ec108 bec76508 000471f4 000458e8 80000010 ffffffff
> ---[ end trace 92e33c96fb76fb3d ]---

After some investigation I found out that commit
bd27290a593f80cb99e95287cb29c72c0d57608b is the culprit:

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fdc3f29..b626289 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -501,9 +501,9 @@ struct netdev_queue {
>  	 * please use this field instead of dev->trans_start
>  	 */
>  	unsigned long		trans_start;
> -	unsigned long		tx_bytes;
> -	unsigned long		tx_packets;
> -	unsigned long		tx_dropped;
> +	u64			tx_bytes;
> +	u64			tx_packets;
> +	u64			tx_dropped;
>  } ____cacheline_aligned_in_smp;
>  
>  #ifdef CONFIG_RPS
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1c002c7..9de75cd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5282,15 +5282,17 @@ void netdev_run_todo(void)
>  void dev_txq_stats_fold(const struct net_device *dev,
>  			struct rtnl_link_stats64 *stats)
>  {
> -	unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
> +	u64 tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
>  	unsigned int i;
>  	struct netdev_queue *txq;
>  
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		txq = netdev_get_tx_queue(dev, i);
> +		spin_lock_bh(&txq->_xmit_lock);
>  		tx_bytes   += txq->tx_bytes;
>  		tx_packets += txq->tx_packets;
>  		tx_dropped += txq->tx_dropped;
> +		spin_unlock_bh(&txq->_xmit_lock);
>  	}
>  	if (tx_bytes || tx_packets || tx_dropped) {
>  		stats->tx_bytes   = tx_bytes;

Changing spin_lock_bh() to spin_lock_irqsave().

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ae6543..278bd08 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5289,12 +5289,13 @@ void dev_txq_stats_fold(const struct net_device *dev,
 	struct netdev_queue *txq;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
+		unsigned long flags;
 		txq = netdev_get_tx_queue(dev, i);
-		spin_lock_bh(&txq->_xmit_lock);
+		spin_lock_irqsave(&txq->_xmit_lock, flags);
 		tx_bytes   += txq->tx_bytes;
 		tx_packets += txq->tx_packets;
 		tx_dropped += txq->tx_dropped;
-		spin_unlock_bh(&txq->_xmit_lock);
+		spin_unlock_irqrestore(&txq->_xmit_lock, flags);
 	}
 	if (tx_bytes || tx_packets || tx_dropped) {
 		stats->tx_bytes   = tx_bytes;
-- 
1.7.1
