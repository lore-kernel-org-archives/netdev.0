From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v4 8/9] xen-netback: Timeout packets in RX path
Date: Tue, 14 Jan 2014 20:39:54 +0000
Message-ID: <1389731995-9887-9-git-send-email-zoltan.kiss@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A malicious or buggy guest can leave its queue filled indefinitely, in which
case qdisc start to queue packets for that VIF. If those packets came from an
another guest, it can block its slots and prevent shutdown. To avoid that, we
make sure the queue is drained in every 10 seconds.
The QDisc queue in worst case takes 3 round to flush usually.

v3:
- remove stale debug log
- tie unmap timeout in xenvif_free to this timeout

v4:
- due to RX flow control changes now start_xmit doesn't drop the packets but
  place them on the internal queue. So the timer set rx_queue_purge and kick in
  the thread to drop the packets there
- we shoot down the timer if a previously filled internal queue drains
- adjust the teardown timeout as in worst case it can take more time now

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    6 ++++++
 drivers/net/xen-netback/interface.c |   24 ++++++++++++++++++++++--
 drivers/net/xen-netback/netback.c   |   23 ++++++++++++++++++++---
 3 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 109c29f..d1cd8ce 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -129,6 +129,9 @@ struct xenvif {
 	struct xen_netif_rx_back_ring rx;
 	struct sk_buff_head rx_queue;
 	RING_IDX rx_last_skb_slots;
+	bool rx_queue_purge;
+
+	struct timer_list wake_queue;
 
 	/* This array is allocated seperately as it is large */
 	struct gnttab_copy *grant_copy_op;
@@ -225,4 +228,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
 
 extern bool separate_tx_rx_irq;
 
+extern unsigned int rx_drain_timeout_msecs;
+extern unsigned int rx_drain_timeout_jiffies;
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index c531f6c..2616d51 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -114,6 +114,18 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static void xenvif_wake_queue(unsigned long data)
+{
+	struct xenvif *vif = (struct xenvif *)data;
+
+	if (netif_queue_stopped(vif->dev)) {
+		netdev_err(vif->dev, "draining TX queue\n");
+		vif->rx_queue_purge = true;
+		xenvif_kick_thread(vif);
+		netif_wake_queue(vif->dev);
+	}
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -143,8 +155,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -352,6 +369,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	init_timer(&vif->credit_timeout);
 	vif->credit_window_start = get_jiffies_64();
 
+	init_timer(&vif->wake_queue);
+
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -529,6 +548,7 @@ void xenvif_disconnect(struct xenvif *vif)
 		xenvif_carrier_off(vif);
 
 	if (vif->task) {
+		del_timer_sync(&vif->wake_queue);
 		kthread_stop(vif->task);
 		vif->task = NULL;
 	}
@@ -559,7 +579,7 @@ void xenvif_free(struct xenvif *vif)
 		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
 			unmap_timeout++;
 			schedule_timeout(msecs_to_jiffies(1000));
-			if (unmap_timeout > 9 &&
+			if (unmap_timeout > ((rx_drain_timeout_msecs/1000) * DIV_ROUND_UP(XENVIF_QUEUE_LENGTH, (XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS))) &&
 			    net_ratelimit())
 				netdev_err(vif->dev,
 					   "Page still granted! Index: %x\n",
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index d2ccb55..1378abd 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -63,6 +63,13 @@ module_param(separate_tx_rx_irq, bool, 0644);
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
@@ -1919,8 +1926,9 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 
 static inline int rx_work_todo(struct xenvif *vif)
 {
-	return !skb_queue_empty(&vif->rx_queue) &&
-	       xenvif_rx_ring_slots_available(vif, vif->rx_last_skb_slots);
+	return (!skb_queue_empty(&vif->rx_queue) &&
+	       xenvif_rx_ring_slots_available(vif, vif->rx_last_skb_slots)) ||
+	       vif->rx_queue_purge;
 }
 
 static inline int tx_work_todo(struct xenvif *vif)
@@ -2011,12 +2019,19 @@ int xenvif_kthread(void *data)
 		if (kthread_should_stop())
 			break;
 
+		if (vif->rx_queue_purge) {
+			skb_queue_purge(&vif->rx_queue);
+			vif->rx_queue_purge = false;
+		}
+
 		if (!skb_queue_empty(&vif->rx_queue))
 			xenvif_rx_action(vif);
 
 		if (skb_queue_empty(&vif->rx_queue) &&
-		    netif_queue_stopped(vif->dev))
+		    netif_queue_stopped(vif->dev)) {
+			del_timer_sync(&vif->wake_queue);
 			xenvif_start_queue(vif);
+		}
 
 		cond_resched();
 	}
@@ -2067,6 +2082,8 @@ static int __init netback_init(void)
 	if (rc)
 		goto failed_init;
 
+	rx_drain_timeout_jiffies = msecs_to_jiffies(rx_drain_timeout_msecs);
+
 	return 0;
 
 failed_init:
