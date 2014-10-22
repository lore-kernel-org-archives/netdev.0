From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/3] xen-netback: make feature-rx-notify mandatory
Date: Wed, 22 Oct 2014 14:08:53 +0100
Message-ID: <1413983335-8307-2-git-send-email-david.vrabel@citrix.com>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19173 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186AbaJVNJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 09:09:25 -0400
In-Reply-To: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frontends that do not provide feature-rx-notify may stall because
netback depends on the notification from frontend to wake the guest Rx
thread (even if can_queue is false).

This could be fixed but feature-rx-notify was introduced in 2006 and I
am not aware of any frontends that do not implement this.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/common.h    |    5 -----
 drivers/net/xen-netback/interface.c |   12 +-----------
 drivers/net/xen-netback/xenbus.c    |   13 ++++---------
 3 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index d4eb8d2..93ca77c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -228,9 +228,6 @@ struct xenvif {
 	u8 ip_csum:1;
 	u8 ipv6_csum:1;
 
-	/* Internal feature information. */
-	u8 can_queue:1;	    /* can queue packets for receiver? */
-
 	/* Is this interface disabled? True when backend discovers
 	 * frontend is rogue.
 	 */
@@ -272,8 +269,6 @@ void xenvif_xenbus_fini(void);
 
 int xenvif_schedulable(struct xenvif *vif);
 
-int xenvif_must_stop_queue(struct xenvif_queue *queue);
-
 int xenvif_queue_stopped(struct xenvif_queue *queue);
 void xenvif_wake_queue(struct xenvif_queue *queue);
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index f379689..c6759b1 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -60,16 +60,6 @@ void xenvif_skb_zerocopy_complete(struct xenvif_queue *queue)
 	atomic_dec(&queue->inflight_packets);
 }
 
-static inline void xenvif_stop_queue(struct xenvif_queue *queue)
-{
-	struct net_device *dev = queue->vif->dev;
-
-	if (!queue->vif->can_queue)
-		return;
-
-	netif_tx_stop_queue(netdev_get_tx_queue(dev, queue->id));
-}
-
 int xenvif_schedulable(struct xenvif *vif)
 {
 	return netif_running(vif->dev) &&
@@ -209,7 +199,7 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!xenvif_rx_ring_slots_available(queue, min_slots_needed)) {
 		queue->rx_stalled.function = xenvif_rx_stalled;
 		queue->rx_stalled.data = (unsigned long)queue;
-		xenvif_stop_queue(queue);
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, queue->id));
 		mod_timer(&queue->rx_stalled,
 			  jiffies + rx_drain_timeout_jiffies);
 	}
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 8079c31..9060857 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -873,15 +873,10 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 	if (!rx_copy)
 		return -EOPNOTSUPP;
 
-	if (vif->dev->tx_queue_len != 0) {
-		if (xenbus_scanf(XBT_NIL, dev->otherend,
-				 "feature-rx-notify", "%d", &val) < 0)
-			val = 0;
-		if (val)
-			vif->can_queue = 1;
-		else
-			/* Must be non-zero for pfifo_fast to work. */
-			vif->dev->tx_queue_len = 1;
+	if (xenbus_scanf(XBT_NIL, dev->otherend,
+			 "feature-rx-notify", "%d", &val) < 0 || val == 0) {
+		xenbus_dev_fatal(dev, -EINVAL, "feature-rx-notify is mandatory");
+		return -EINVAL;
 	}
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
-- 
1.7.10.4
