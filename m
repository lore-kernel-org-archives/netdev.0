From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH RFC] netpoll: convert mutex into a semaphore
Date: Tue, 30 Apr 2013 11:35:05 -0400
Message-ID: <1367336105-6275-1-git-send-email-nhorman@tuxdriver.com>
References: <20130429181322.GA27119@hmsreliant.think-freely.org>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41262 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462Ab3D3PfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 11:35:22 -0400
In-Reply-To: <20130429181322.GA27119@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart Van Assche recently reported a warning to me:

<IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
[<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
[<ffffffff814761dd>] mutex_trylock+0x16d/0x180
[<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
[<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
[<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
[<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
[<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
[<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
[<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
[<ffffffff8103fb76>] console_unlock+0x2d6/0x450
[<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
[<ffffffff8146f9f6>] printk+0x4d/0x4f
[<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]

This resulted from my commit ca99ca14c which introduced a mutex_trylock
operation in a path that could execute in interrupt context.  When mutex
debugging is enabled, the above warns the user when we are in fact
exectuting in interrupt context
interrupt context.

After some discussion, It seems that a semaphore is the proper mechanism to use
here.  While mutexes are defined to be unusable in interrupt context, no such
condition exists for semaphores (save for the fact that the non blocking api
calls, like up and down_trylock must be used when in irq context).

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Bart Van Assche <bvanassche@acm.org>
CC: Bart Van Assche <bvanassche@acm.org>
CC: David Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
---
 include/linux/netpoll.h |  2 +-
 net/core/netpoll.c      | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 9d7d8c6..fa2cb76 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -40,7 +40,7 @@ struct netpoll_info {
 
 	unsigned long rx_flags;
 	spinlock_t rx_lock;
-	struct mutex dev_lock;
+	struct semaphore dev_lock;
 	struct list_head rx_np; /* netpolls that registered an rx_hook */
 
 	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 209d842..a5802a8 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -206,17 +206,17 @@ static void netpoll_poll_dev(struct net_device *dev)
 	 * the dev_open/close paths use this to block netpoll activity
 	 * while changing device state
 	 */
-	if (!mutex_trylock(&ni->dev_lock))
+	if (!down_trylock(&ni->dev_lock))
 		return;
 
 	if (!netif_running(dev)) {
-		mutex_unlock(&ni->dev_lock);
+		up(&ni->dev_lock);
 		return;
 	}
 
 	ops = dev->netdev_ops;
 	if (!ops->ndo_poll_controller) {
-		mutex_unlock(&ni->dev_lock);
+		up(&ni->dev_lock);
 		return;
 	}
 
@@ -225,7 +225,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
-	mutex_unlock(&ni->dev_lock);
+	up(&ni->dev_lock);
 
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
@@ -255,7 +255,7 @@ int netpoll_rx_disable(struct net_device *dev)
 	idx = srcu_read_lock(&netpoll_srcu);
 	ni = srcu_dereference(dev->npinfo, &netpoll_srcu);
 	if (ni)
-		mutex_lock(&ni->dev_lock);
+		down(&ni->dev_lock);
 	srcu_read_unlock(&netpoll_srcu, idx);
 	return 0;
 }
@@ -267,7 +267,7 @@ void netpoll_rx_enable(struct net_device *dev)
 	rcu_read_lock();
 	ni = rcu_dereference(dev->npinfo);
 	if (ni)
-		mutex_unlock(&ni->dev_lock);
+		up(&ni->dev_lock);
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(netpoll_rx_enable);
@@ -1047,7 +1047,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 		INIT_LIST_HEAD(&npinfo->rx_np);
 
 		spin_lock_init(&npinfo->rx_lock);
-		mutex_init(&npinfo->dev_lock);
+		sema_init(&npinfo->dev_lock, 1);
 		skb_queue_head_init(&npinfo->neigh_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
-- 
1.8.1.4
