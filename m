From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] fix mv643xx_eth.c lockdep violation
Date: Thu, 16 May 2013 17:31:42 +0100
Message-ID: <20130516163142.GT18614@n2100.arm.linux.org.uk>
References: <20130516161313.GS18614@n2100.arm.linux.org.uk> <1368721294.3301.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:51798 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab3EPQbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 12:31:52 -0400
Content-Disposition: inline
In-Reply-To: <1368721294.3301.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 09:21:34AM -0700, Eric Dumazet wrote:
> On Thu, 2013-05-16 at 17:13 +0100, Russell King - ARM Linux wrote:
> 
> > It seems that txq_reclaim() takes the netif tx lock:
> > 
> >         __netif_tx_lock(nq, smp_processor_id());
> > 
> > in a context outside of softirq context, and thus is susceptible to
> > deadlock should an interrupt occur.
> > 
> > Disable IRQs around the call to txq_deinit() to avoid this issue.
> 
> Hmm, I would use __netif_tx_lock_bh()/__netif_tx_unlock_bh() in
> txq_reclaim() instead...

Yes, thanks, that seems to work as well.  Here's a replacement patch.

8<===
From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] NET: mv643xx_eth: avoid lockdep dump on interface down

When the interface is shutdown, the mv643xx_eth driver hits the following
lockdep dump:

=================================
[ INFO: inconsistent lock state ]
3.8.0+ #303 Not tainted
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
NetworkManager/3449 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (_xmit_ETHER#2){+.?...}, at: [<c02828e4>] txq_reclaim+0x60/0x230
{IN-SOFTIRQ-W} state was registered at:
  [<c007e93c>] mark_irqflags+0xf8/0x1c4
  [<c007ee60>] __lock_acquire+0x458/0x9a4
  [<c007f8b0>] lock_acquire+0x60/0x74
  [<c03ea914>] _raw_spin_lock+0x40/0x50
  [<c0334040>] sch_direct_xmit+0xa4/0x2e4
  [<c0320880>] dev_queue_xmit+0x174/0x508
  [<c03953b0>] ip6_finish_output2+0xd0/0x3c4
  [<c03b15bc>] mld_sendpack+0x190/0x368
  [<c03b3204>] mld_ifc_timer_expire+0xc/0x58
  [<c005133c>] call_timer_fn+0x6c/0xe0
  [<c0051588>] run_timer_softirq+0x1d8/0x210
  [<c004c004>] __do_softirq+0xe0/0x1b4
  [<c004c448>] irq_exit+0x64/0x6c
  [<c000f1e0>] handle_IRQ+0x34/0x84
  [<c000e0d0>] __irq_usr+0x30/0x80
irq event stamp: 160603
hardirqs last  enabled at (160603): [<c00c736c>] kfree+0xa8/0xe8
hardirqs last disabled at (160602): [<c00c72e0>] kfree+0x1c/0xe8
softirqs last  enabled at (160304): [<c028260c>] mib_counters_update+0x5ec/0x60c
softirqs last disabled at (160302): [<c03eab8c>] _raw_spin_lock_bh+0x14/0x54

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(_xmit_ETHER#2);
  <Interrupt>
    lock(_xmit_ETHER#2);

 *** DEADLOCK ***

1 lock held by NetworkManager/3449:
 #0:  (rtnl_mutex){+.+.+.}, at: [<c032e664>] rtnetlink_rcv+0xc/0x24

stack backtrace:
[<c0013e34>] (unwind_backtrace+0x0/0xf8) from [<c007e12c>] (print_usage_bug+0x150/0x1d4)
[<c007e12c>] (print_usage_bug+0x150/0x1d4) from [<c007e3f8>] (mark_lock_irq+0x248/0x290)
[<c007e3f8>] (mark_lock_irq+0x248/0x290) from [<c007e598>] (mark_lock+0x158/0x404)
[<c007e598>] (mark_lock+0x158/0x404) from [<c007e97c>] (mark_irqflags+0x138/0x1c4)
[<c007e97c>] (mark_irqflags+0x138/0x1c4) from [<c007ee60>] (__lock_acquire+0x458/0x9a4)
[<c007ee60>] (__lock_acquire+0x458/0x9a4) from [<c007f8b0>] (lock_acquire+0x60/0x74)
[<c007f8b0>] (lock_acquire+0x60/0x74) from [<c03ea914>] (_raw_spin_lock+0x40/0x50)
[<c03ea914>] (_raw_spin_lock+0x40/0x50) from [<c02828e4>] (txq_reclaim+0x60/0x230)
[<c02828e4>] (txq_reclaim+0x60/0x230) from [<c0282ad8>] (txq_deinit+0x24/0xcc)
[<c0282ad8>] (txq_deinit+0x24/0xcc) from [<c0282d28>] (mv643xx_eth_stop+0x1a8/0x1bc)
[<c0282d28>] (mv643xx_eth_stop+0x1a8/0x1bc) from [<c031e314>] (__dev_close_many+0x88/0xcc)
[<c031e314>] (__dev_close_many+0x88/0xcc) from [<c031e380>] (__dev_close+0x28/0x3c)
[<c031e380>] (__dev_close+0x28/0x3c) from [<c0320fa0>] (__dev_change_flags+0x7c/0x134)
[<c0320fa0>] (__dev_change_flags+0x7c/0x134) from [<c03210e0>] (dev_change_flags+0x10/0x48)
[<c03210e0>] (dev_change_flags+0x10/0x48) from [<c032da1c>] (do_setlink+0x1a0/0x730)
[<c032da1c>] (do_setlink+0x1a0/0x730) from [<c032f524>] (rtnl_newlink+0x304/0x4b0)
[<c032f524>] (rtnl_newlink+0x304/0x4b0) from [<c032ef8c>] (rtnetlink_rcv_msg+0x25c/0x2a0)
[<c032ef8c>] (rtnetlink_rcv_msg+0x25c/0x2a0) from [<c03383a0>] (netlink_rcv_skb+0xbc/0xd8)
[<c03383a0>] (netlink_rcv_skb+0xbc/0xd8) from [<c032e674>] (rtnetlink_rcv+0x1c/0x24)
[<c032e674>] (rtnetlink_rcv+0x1c/0x24) from [<c03361d8>] (netlink_unicast_kernel+0x88/0xd4)
[<c03361d8>] (netlink_unicast_kernel+0x88/0xd4) from [<c0337dd0>] (netlink_unicast+0x138/0x180)
[<c0337dd0>] (netlink_unicast+0x138/0x180) from [<c0338020>] (netlink_sendmsg+0x208/0x32c)
[<c0338020>] (netlink_sendmsg+0x208/0x32c) from [<c030ab48>] (sock_sendmsg+0x84/0xa4)
[<c030ab48>] (sock_sendmsg+0x84/0xa4) from [<c030aef4>] (__sys_sendmsg+0x2ac/0x2c4)
[<c030aef4>] (__sys_sendmsg+0x2ac/0x2c4) from [<c030c8ec>] (sys_sendmsg+0x3c/0x68)
[<c030c8ec>] (sys_sendmsg+0x3c/0x68) from [<c000e2e0>] (ret_fast_syscall+0x0/0x3c)

It seems that txq_reclaim() takes the netif tx lock:

        __netif_tx_lock(nq, smp_processor_id());

in a context outside of softirq context, and thus is susceptible to
deadlock should an interrupt occur.

Use __netif_tx_lock_bh()/__netif_tx_unlock_bh() instead.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
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
1.7.4.4
