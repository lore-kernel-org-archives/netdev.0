From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] mv643xx_eth: Fix a possible deadlock upon ifdown
Date: Fri,  4 Jan 2013 15:07:02 +0100
Message-ID: <1357308422-19639-1-git-send-email-lkundrak@v3.sk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Lubomir Rintel <lubo.rintel@gooddata.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lubo.rintel@gooddata.com>

=================================
[ INFO: inconsistent lock state ]
3.7.0-6.luboskovo.fc19.armv5tel.kirkwood #1 Tainted: G        W
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
NetworkManager/337 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (_xmit_ETHER#2){+.?...}, at: [<bf07adfc>] txq_reclaim+0x54/0x264 [mv643xx_eth]
{IN-SOFTIRQ-W} state was registered at:
  [<c0068480>] __lock_acquire+0x5b4/0x17d0
  [<c0069d7c>] lock_acquire+0x160/0x1e0
  [<c04f41a0>] _raw_spin_lock+0x50/0x88
  [<c0407178>] sch_direct_xmit+0x4c/0x2d4
  [<c03ec978>] dev_queue_xmit+0x4b8/0x8d8
  [<c0492dc8>] ip6_finish_output2+0x350/0x42c
  [<c04b7fd8>] mld_sendpack+0x2d0/0x514
  [<c04b8834>] mld_ifc_timer_expire+0x228/0x278
  [<c002afe8>] call_timer_fn+0x140/0x33c
  [<c002bbf0>] run_timer_softirq+0x278/0x32c
  [<c0024288>] __do_softirq+0x16c/0x398
  [<c002488c>] irq_exit+0x5c/0xc0
  [<c0009c64>] handle_IRQ+0x6c/0x8c
  [<c04f5218>] __irq_svc+0x38/0x80
  [<c0065684>] lock_is_held+0x4/0x54
  [<c004d5a0>] __might_sleep+0x44/0x228
  [<c04f25a4>] down_read+0x28/0x88
  [<c0263c94>] __copy_to_user_memcpy+0xa8/0x140
  [<c01374d0>] seq_read+0x3ac/0x474
  [<c011623c>] vfs_read+0xac/0x184
  [<c0116354>] sys_read+0x40/0x6c
  [<c0008cc0>] ret_fast_syscall+0x0/0x38
irq event stamp: 115119
hardirqs last  enabled at (115119): [<c04f4cf0>] _raw_spin_unlock_irqrestore+0x44/0x64
hardirqs last disabled at (115118): [<c04f430c>] _raw_spin_lock_irqsave+0x28/0xa0
softirqs last  enabled at (114880): [<c00243d4>] __do_softirq+0x2b8/0x398
softirqs last disabled at (114873): [<c002488c>] irq_exit+0x5c/0xc0

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(_xmit_ETHER#2);
  <Interrupt>
    lock(_xmit_ETHER#2);

 *** DEADLOCK ***

1 lock held by NetworkManager/337:
 #0:  (rtnl_mutex){+.+.+.}, at: [<c03fad04>] rtnetlink_rcv+0x14/0x2c

stack backtrace:
[<c000f5a8>] (unwind_backtrace+0x0/0x124) from [<c04ebea8>] (print_usage_bug.part.29+0x20c/0x26c)
[<c04ebea8>] (print_usage_bug.part.29+0x20c/0x26c) from [<c0067cc4>] (mark_lock+0x404/0x60c)
[<c0067cc4>] (mark_lock+0x404/0x60c) from [<c0068504>] (__lock_acquire+0x638/0x17d0)
[<c0068504>] (__lock_acquire+0x638/0x17d0) from [<c0069d7c>] (lock_acquire+0x160/0x1e0)
[<c0069d7c>] (lock_acquire+0x160/0x1e0) from [<c04f41a0>] (_raw_spin_lock+0x50/0x88)
[<c04f41a0>] (_raw_spin_lock+0x50/0x88) from [<bf07adfc>] (txq_reclaim+0x54/0x264 [mv643xx_eth])
[<bf07adfc>] (txq_reclaim+0x54/0x264 [mv643xx_eth]) from [<bf07b03c>] (txq_deinit+0x30/0xec [mv643xx_eth])
[<bf07b03c>] (txq_deinit+0x30/0xec [mv643xx_eth]) from [<bf07b21c>] (mv643xx_eth_stop+0x124/0x140 [mv643xx_eth])
[<bf07b21c>] (mv643xx_eth_stop+0x124/0x140 [mv643xx_eth]) from [<c03e8bbc>] (__dev_close_many+0xb0/0xec)
[<c03e8bbc>] (__dev_close_many+0xb0/0xec) from [<c03e8c28>] (__dev_close+0x30/0x44)
[<c03e8c28>] (__dev_close+0x30/0x44) from [<c03ed154>] (__dev_change_flags+0x94/0x120)
[<c03ed154>] (__dev_change_flags+0x94/0x120) from [<c03ed260>] (dev_change_flags+0x18/0x4c)
[<c03ed260>] (dev_change_flags+0x18/0x4c) from [<c03fb174>] (do_setlink+0x2cc/0x7ac)
[<c03fb174>] (do_setlink+0x2cc/0x7ac) from [<c03fc5ec>] (rtnl_newlink+0x26c/0x4a8)
[<c03fc5ec>] (rtnl_newlink+0x26c/0x4a8) from [<c03fc104>] (rtnetlink_rcv_msg+0x280/0x29c)
[<c03fc104>] (rtnetlink_rcv_msg+0x280/0x29c) from [<c041245c>] (netlink_rcv_skb+0x58/0xb4)
[<c041245c>] (netlink_rcv_skb+0x58/0xb4) from [<c03fad10>] (rtnetlink_rcv+0x20/0x2c)
[<c03fad10>] (rtnetlink_rcv+0x20/0x2c) from [<c0411dec>] (netlink_unicast+0x158/0x208)
[<c0411dec>] (netlink_unicast+0x158/0x208) from [<c0412254>] (netlink_sendmsg+0x310/0x3c0)
[<c0412254>] (netlink_sendmsg+0x310/0x3c0) from [<c03d209c>] (sock_sendmsg+0xa8/0xd0)
[<c03d209c>] (sock_sendmsg+0xa8/0xd0) from [<c03d2314>] (__sys_sendmsg+0x1d8/0x280)
[<c03d2314>] (__sys_sendmsg+0x1d8/0x280) from [<c03d4054>] (sys_sendmsg+0x44/0x68)
[<c03d4054>] (sys_sendmsg+0x44/0x68) from [<c0008cc0>] (ret_fast_syscall+0x0/0x38)
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 84c1326..67a3e78 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -943,7 +943,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 	int reclaimed;
 
-	__netif_tx_lock(nq, smp_processor_id());
+	__netif_tx_lock_bh(nq);
 
 	reclaimed = 0;
 	while (reclaimed < budget && txq->tx_desc_count > 0) {
@@ -989,7 +989,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		dev_kfree_skb(skb);
 	}
 
-	__netif_tx_unlock(nq);
+	__netif_tx_unlock_bh(nq);
 
 	if (reclaimed < budget)
 		mp->work_tx &= ~(1 << txq->index);
-- 
1.7.1
