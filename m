From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 net-next 2/2] sunvnet: Use one Tx queue per vnet_port
Date: Thu, 30 Oct 2014 12:46:09 -0400
Message-ID: <20141030164609.GG650@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45720 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760685AbaJ3QqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:46:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use multple Tx netdev queues for sunvnet by supporting a one-to-one
mapping between vnet_port and Tx queue. Provide a ndo_select_queue
indirection (vnet_select_queue()) which selects the queue based
on the peer that would be selected in vnet_start_xmit()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 94 +++++++++++++++++++++++++-------------
 drivers/net/ethernet/sun/sunvnet.h |  2 +
 2 files changed, 65 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 7ada479..e7bb63b 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -40,6 +40,8 @@ MODULE_DESCRIPTION("Sun LDOM virtual network driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
+#define	VNET_MAX_TXQS		16
+
 /* Heuristic for the number of times to exponentially backoff and
  * retry sending an LDC trigger when EAGAIN is encountered
  */
@@ -551,6 +553,8 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	struct vnet *vp;
 	u32 end;
 	struct vio_net_desc *desc;
+	struct netdev_queue *txq;
+
 	if (unlikely(pkt->tag.stype_env != VIO_DRING_DATA))
 		return 0;
 
@@ -580,7 +584,8 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	}
 	netif_tx_unlock(dev);
 
-	if (unlikely(netif_queue_stopped(dev) &&
+	txq = netdev_get_tx_queue(dev, port->q_index);
+	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     vnet_tx_dring_avail(dr) >= VNET_TX_WAKEUP_THRESH(dr)))
 		return 1;
 
@@ -608,31 +613,23 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-static void maybe_tx_wakeup(struct vnet *vp)
+/* Got back a STOPPED LDC message on port. If the queue is stopped,
+ * wake it up so that we'll send out another START message at the
+ * next TX.
+ */
+static void maybe_tx_wakeup(struct vnet_port *port)
 {
-	struct net_device *dev = vp->dev;
+	struct netdev_queue *txq;
 
-	netif_tx_lock(dev);
-	if (likely(netif_queue_stopped(dev))) {
-		struct vnet_port *port;
-		int wake = 1;
-
-		rcu_read_lock();
-		list_for_each_entry_rcu(port, &vp->port_list, list) {
-			struct vio_dring_state *dr;
-
-			dr = &port->vio.drings[VIO_DRIVER_TX_RING];
-			if (vnet_tx_dring_avail(dr) <
-			    VNET_TX_WAKEUP_THRESH(dr)) {
-				wake = 0;
-				break;
-			}
-		}
-		rcu_read_unlock();
-		if (wake)
-			netif_wake_queue(dev);
+	txq = netdev_get_tx_queue(port->vp->dev, port->q_index);
+	__netif_tx_lock(txq, smp_processor_id());
+	if (likely(netif_tx_queue_stopped(txq))) {
+		struct vio_dring_state *dr;
+
+		dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+			netif_tx_wake_queue(txq);
 	}
-	netif_tx_unlock(dev);
+	__netif_tx_unlock(txq);
 }
 
 static inline bool port_is_up(struct vnet_port *vnet)
@@ -748,7 +745,7 @@ napi_resume:
 			break;
 	}
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
-		maybe_tx_wakeup(port->vp);
+		maybe_tx_wakeup(port);
 	return npkts;
 }
 
@@ -953,6 +950,16 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
 	return skb;
 }
 
+static u16
+vnet_select_queue(struct net_device *dev, struct sk_buff *skb,
+		  void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct vnet *vp = netdev_priv(dev);
+	struct vnet_port *port = __tx_port_find(vp, skb);
+
+	return port->q_index;
+}
+
 static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vnet *vp = netdev_priv(dev);
@@ -965,6 +972,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	void *start = NULL;
 	int nlen = 0;
 	unsigned pending = 0;
+	struct netdev_queue *txq;
 
 	skb = vnet_skb_shape(skb, &start, &nlen);
 	if (unlikely(!skb))
@@ -1008,9 +1016,11 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
+	i = skb_get_queue_mapping(skb);
+	txq = netdev_get_tx_queue(dev, i);
 	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+		if (!netif_tx_queue_stopped(txq)) {
+			netif_tx_stop_queue(txq);
 
 			/* This is a hard error, log it. */
 			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
@@ -1104,9 +1114,9 @@ ldc_start_done:
 
 	dr->prod = (dr->prod + 1) & (VNET_TX_RING_SIZE - 1);
 	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		if (vnet_tx_dring_avail(dr) > VNET_TX_WAKEUP_THRESH(dr))
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(txq);
 	}
 
 	(void)mod_timer(&port->clean_timer, jiffies + VNET_CLEAN_TIMEOUT);
@@ -1139,14 +1149,14 @@ static void vnet_tx_timeout(struct net_device *dev)
 static int vnet_open(struct net_device *dev)
 {
 	netif_carrier_on(dev);
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
 }
 
 static int vnet_close(struct net_device *dev)
 {
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
 
 	return 0;
@@ -1420,6 +1430,7 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_tx_timeout		= vnet_tx_timeout,
 	.ndo_change_mtu		= vnet_change_mtu,
 	.ndo_start_xmit		= vnet_start_xmit,
+	.ndo_select_queue	= vnet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= vnet_poll_controller,
 #endif
@@ -1431,7 +1442,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	struct vnet *vp;
 	int err, i;
 
-	dev = alloc_etherdev(sizeof(*vp));
+	dev = alloc_etherdev_mqs(sizeof(*vp), VNET_MAX_TXQS, 1);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 	dev->needed_headroom = VNET_PACKET_SKIP + 8;
@@ -1556,6 +1567,25 @@ static void print_version(void)
 
 const char *remote_macaddr_prop = "remote-mac-address";
 
+static void
+vnet_port_add_txq(struct vnet_port *port)
+{
+	struct vnet *vp = port->vp;
+	int n;
+
+	n = vp->nports++;
+	n = n & (VNET_MAX_TXQS - 1);
+	port->q_index = n;
+	netif_tx_wake_queue(netdev_get_tx_queue(vp->dev, port->q_index));
+}
+
+static void
+vnet_port_rm_txq(struct vnet_port *port)
+{
+	port->vp->nports--;
+	netif_tx_stop_queue(netdev_get_tx_queue(port->vp->dev, port->q_index));
+}
+
 static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 {
 	struct mdesc_handle *hp;
@@ -1624,6 +1654,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 		list_add_tail_rcu(&port->list, &vp->port_list);
 	hlist_add_head_rcu(&port->hash,
 			   &vp->port_hash[vnet_hashfn(port->raddr)]);
+	vnet_port_add_txq(port);
 	spin_unlock_irqrestore(&vp->lock, flags);
 
 	dev_set_drvdata(&vdev->dev, port);
@@ -1668,6 +1699,7 @@ static int vnet_port_remove(struct vio_dev *vdev)
 
 		synchronize_rcu();
 		del_timer_sync(&port->clean_timer);
+		vnet_port_rm_txq(port);
 		netif_napi_del(&port->napi);
 		vnet_port_free_tx_bufs(port);
 		vio_ldc_free(&port->vio);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index c8a862e..cd5d343 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -61,6 +61,7 @@ struct vnet_port {
 	u32			napi_stop_idx;
 	bool			napi_resume;
 	int			rx_event;
+	u16			q_index;
 };
 
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
@@ -102,6 +103,7 @@ struct vnet {
 	struct list_head	list;
 	u64			local_mac;
 
+	int			nports;
 };
 
 #endif /* _SUNVNET_H */
-- 
1.8.4.2
