From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 8/9] xen-netback: Timeout packets in RX path
Date: Wed, 8 Jan 2014 00:10:17 +0000
Message-ID: <1389139818-24458-9-git-send-email-zoltan.kiss@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:10440 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754608AbaAHAPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 19:15:55 -0500
In-Reply-To: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A malicious or buggy guest can leave its queue filled indefinitely, in which
case qdisc start to queue packets for that VIF. If those packets came from an
another guest, it can block its slots and prevent shutdown. To avoid that, we
make sure the queue is drained in every 10 seconds.

v3:
- remove stale debug log
- tie unmap timeout in xenvif_free to this timeout

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    5 +++++
 drivers/net/xen-netback/interface.c |   22 ++++++++++++++++++++--
 drivers/net/xen-netback/netback.c   |    9 +++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index dda3fd5..063fcda 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -130,6 +130,8 @@ struct xenvif {
 	 */
 	bool rx_event;
 
+	struct timer_list wake_queue;
+
 	/* This array is allocated seperately as it is large */
 	struct gnttab_copy *grant_copy_op;
 
@@ -224,4 +226,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
 
 extern bool separate_tx_rx_irq;
 
+extern unsigned int rx_drain_timeout_msecs;
+extern unsigned int rx_drain_timeout_jiffies;
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 95fcd63..ce032f9 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -114,6 +114,16 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static void xenvif_wake_queue(unsigned long data)
+{
+	struct xenvif *vif = (struct xenvif *)data;
+
+	if (netif_queue_stopped(vif->dev)) {
+		netdev_err(vif->dev, "draining TX queue\n");
+		netif_wake_queue(vif->dev);
+	}
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -143,8 +153,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * then turn off the queue to give the ring a chance to
 	 * drain.
 	 */
-	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
+	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed)) {
+		vif->wake_queue.function = xenvif_wake_queue;
+		vif->wake_queue.data = (unsigned long)vif;
 		xenvif_stop_queue(vif);
+		mod_timer(&vif->wake_queue,
+			jiffies + rx_drain_timeout_jiffies);
+	}
 
 	skb_queue_tail(&vif->rx_queue, skb);
 	xenvif_kick_thread(vif);
@@ -353,6 +368,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	/* Initialize 'expires' now: it's used to track the credit window. */
 	vif->credit_timeout.expires = jiffies;
 
+	init_timer(&vif->wake_queue);
+
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -528,6 +545,7 @@ void xenvif_disconnect(struct xenvif *vif)
 		xenvif_carrier_off(vif);
 
 	if (vif->task) {
+		del_timer_sync(&vif->wake_queue);
 		kthread_stop(vif->task);
 		vif->task = NULL;
 	}
@@ -558,7 +576,7 @@ void xenvif_free(struct xenvif *vif)
 		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
 			unmap_timeout++;
 			schedule_timeout(msecs_to_jiffies(1000));
-			if (unmap_timeout > 9 &&
+			if (unmap_timeout > (rx_drain_timeout_msecs/1000) &&
 				net_ratelimit())
 				netdev_err(vif->dev,
 					"Page still granted! Index: %x\n", i);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f815395..6bc5413 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -62,6 +62,13 @@ module_param(separate_tx_rx_irq, bool, 0644);
 static unsigned int fatal_skb_slots = FATAL_SKB_SLOTS_DEFAULT;
 module_param(fatal_skb_slots, uint, 0444);
 
+/* When guest ring is filled up, qdisc queues the packets for us, but we have
+ * to timeout them, otherwise other guests' packets can get stucked there
+ */
+unsigned int rx_drain_timeout_msecs = 10000;
+module_param(rx_drain_timeout_msecs, uint, 0444);
+unsigned int rx_drain_timeout_jiffies;
+
 /*
  * To avoid confusion, we define XEN_NETBK_LEGACY_SLOTS_MAX indicating
  * the maximum slots a valid packet can use. Now this value is defined
@@ -2032,6 +2039,8 @@ static int __init netback_init(void)
 	if (rc)
 		goto failed_init;
 
+	rx_drain_timeout_jiffies = msecs_to_jiffies(rx_drain_timeout_msecs);
+
 	return 0;
 
 failed_init:
