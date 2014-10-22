From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv5 net-next 1/4] sunvnet: NAPIfy sunvnet
Date: Wed, 22 Oct 2014 18:12:25 -0400
Message-ID: <20141022221225.GC17252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, bob.picco@oracle.com,
	sowmini.varadhan@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com, david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51859 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933024AbaJVWM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 18:12:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move Rx packet procssing to the NAPI poll callback.
Disable VIO interrupt and unconditioanlly go into NAPI
context from vnet_event.

Note that we want to minimize the number of LDC
STOP/START messages sent. Specifically, do not send a STOP
message if vnet_walk_rx does not read all the available descriptors
because of the NAPI budget limitation. Instead, note the end index
as part of port state, and resume from this index when the
next poll callback is triggered.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
Acked-by: Dwight Engen <dwight.engen@oracle.com>
---
changes since v2: use NAPI.
changes since v3: David Stevens comments.
Changes since v4: vnet_event() must accumulate LDC_EVENT_* bits into rx_event
                  and all these bits should be processed in vnet_event_api()
		  in the same order as send_events()

 drivers/net/ethernet/sun/sunvnet.c | 175 ++++++++++++++++++++++++++++---------
 drivers/net/ethernet/sun/sunvnet.h |   6 +-
 2 files changed, 137 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 3652afd..8827fef 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -33,6 +33,8 @@
 #define DRV_MODULE_VERSION	"1.0"
 #define DRV_MODULE_RELDATE	"June 25, 2007"
 
+#define	NAPI_POLL_WEIGHT	64
+
 static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
@@ -311,9 +313,7 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
-
-	netif_rx(skb);
-
+	napi_gro_receive(&port->napi, skb);
 	return 0;
 
 out_free_skb:
@@ -430,6 +430,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	struct vio_driver_state *vio = &port->vio;
 	int err;
 
+	BUG_ON(desc == NULL);
 	if (IS_ERR(desc))
 		return PTR_ERR(desc);
 
@@ -456,10 +457,11 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 }
 
 static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
-			u32 start, u32 end)
+			u32 start, u32 end, int *npkts, int budget)
 {
 	struct vio_driver_state *vio = &port->vio;
 	int ack_start = -1, ack_end = -1;
+	bool send_ack = true;
 
 	end = (end == (u32) -1) ? prev_idx(start, dr) : next_idx(end, dr);
 
@@ -471,6 +473,7 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 			return err;
 		if (err != 0)
 			break;
+		(*npkts)++;
 		if (ack_start == -1)
 			ack_start = start;
 		ack_end = start;
@@ -482,13 +485,26 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 				return err;
 			ack_start = -1;
 		}
+		if ((*npkts) >= budget) {
+			send_ack = false;
+			break;
+		}
 	}
 	if (unlikely(ack_start == -1))
 		ack_start = ack_end = prev_idx(start, dr);
-	return vnet_send_ack(port, dr, ack_start, ack_end, VIO_DRING_STOPPED);
+	if (send_ack) {
+		port->napi_resume = false;
+		return vnet_send_ack(port, dr, ack_start, ack_end,
+				     VIO_DRING_STOPPED);
+	} else  {
+		port->napi_resume = true;
+		port->napi_stop_idx = ack_end;
+		return 1;
+	}
 }
 
-static int vnet_rx(struct vnet_port *port, void *msgbuf)
+static int vnet_rx(struct vnet_port *port, void *msgbuf, int *npkts,
+		   int budget)
 {
 	struct vio_dring_data *pkt = msgbuf;
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_RX_RING];
@@ -505,11 +521,13 @@ static int vnet_rx(struct vnet_port *port, void *msgbuf)
 		return 0;
 	}
 
-	dr->rcv_nxt++;
+	if (!port->napi_resume)
+		dr->rcv_nxt++;
 
 	/* XXX Validate pkt->start_idx and pkt->end_idx XXX */
 
-	return vnet_walk_rx(port, dr, pkt->start_idx, pkt->end_idx);
+	return vnet_walk_rx(port, dr, pkt->start_idx, pkt->end_idx,
+			    npkts, budget);
 }
 
 static int idx_is_pending(struct vio_dring_state *dr, u32 end)
@@ -542,9 +560,12 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	if (unlikely(!idx_is_pending(dr, end)))
 		return 0;
 
+	vp = port->vp;
+	dev = vp->dev;
 	/* sync for race conditions with vnet_start_xmit() and tell xmit it
 	 * is time to send a trigger.
 	 */
+	netif_tx_lock(dev);
 	dr->cons = next_idx(end, dr);
 	desc = vio_dring_entry(dr, dr->cons);
 	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
@@ -559,10 +580,8 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	} else {
 		port->start_cons = true;
 	}
+	netif_tx_unlock(dev);
 
-
-	vp = port->vp;
-	dev = vp->dev;
 	if (unlikely(netif_queue_stopped(dev) &&
 		     vnet_tx_dring_avail(dr) >= VNET_TX_WAKEUP_THRESH(dr)))
 		return 1;
@@ -591,9 +610,8 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-static void maybe_tx_wakeup(unsigned long param)
+static void maybe_tx_wakeup(struct vnet *vp)
 {
-	struct vnet *vp = (struct vnet *)param;
 	struct net_device *dev = vp->dev;
 
 	netif_tx_lock(dev);
@@ -617,32 +635,43 @@ static void maybe_tx_wakeup(unsigned long param)
 	netif_tx_unlock(dev);
 }
 
-static void vnet_event(void *arg, int event)
+static inline bool port_is_up(struct vnet_port *vnet)
+{
+	struct vio_driver_state *vio = &vnet->vio;
+
+	return !!(vio->hs_state & VIO_HS_COMPLETE);
+}
+
+static int vnet_event_napi(struct vnet_port *port, int budget)
 {
-	struct vnet_port *port = arg;
 	struct vio_driver_state *vio = &port->vio;
-	unsigned long flags;
 	int tx_wakeup, err;
+	int npkts = 0;
+	int event = (port->rx_event & LDC_EVENT_RESET);
 
-	spin_lock_irqsave(&vio->lock, flags);
-
+ldc_ctrl:
 	if (unlikely(event == LDC_EVENT_RESET ||
 		     event == LDC_EVENT_UP)) {
 		vio_link_state_change(vio, event);
-		spin_unlock_irqrestore(&vio->lock, flags);
 
 		if (event == LDC_EVENT_RESET) {
 			port->rmtu = 0;
 			vio_port_up(vio);
 		}
-		return;
+		port->rx_event = 0;
+		return 0;
 	}
+	/* We may have multiple LDC events in rx_event. Unroll send_events() */
+	event = (port->rx_event & LDC_EVENT_UP);
+	port->rx_event &= ~(LDC_EVENT_RESET|LDC_EVENT_UP);
+	if (event == LDC_EVENT_UP)
+		goto ldc_ctrl;
+	event = port->rx_event;
+	if (!(event & LDC_EVENT_DATA_READY))
+		return 0;
 
-	if (unlikely(event != LDC_EVENT_DATA_READY)) {
-		pr_warn("Unexpected LDC event %d\n", event);
-		spin_unlock_irqrestore(&vio->lock, flags);
-		return;
-	}
+	/* we dont expect any other bits than RESET, UP, DATA_READY */
+	BUG_ON(event != LDC_EVENT_DATA_READY);
 
 	tx_wakeup = err = 0;
 	while (1) {
@@ -651,6 +680,21 @@ static void vnet_event(void *arg, int event)
 			u64 raw[8];
 		} msgbuf;
 
+		if (port->napi_resume) {
+			struct vio_dring_data *pkt =
+				(struct vio_dring_data *)&msgbuf;
+			struct vio_dring_state *dr =
+				&port->vio.drings[VIO_DRIVER_RX_RING];
+
+			pkt->tag.type = VIO_TYPE_DATA;
+			pkt->tag.stype = VIO_SUBTYPE_INFO;
+			pkt->tag.stype_env = VIO_DRING_DATA;
+			pkt->seq = dr->rcv_nxt;
+			pkt->start_idx = next_idx(port->napi_stop_idx, dr);
+			pkt->end_idx = -1;
+			goto napi_resume;
+		}
+ldc_read:
 		err = ldc_read(vio->lp, &msgbuf, sizeof(msgbuf));
 		if (unlikely(err < 0)) {
 			if (err == -ECONNRESET)
@@ -667,10 +711,22 @@ static void vnet_event(void *arg, int event)
 		err = vio_validate_sid(vio, &msgbuf.tag);
 		if (err < 0)
 			break;
-
+napi_resume:
 		if (likely(msgbuf.tag.type == VIO_TYPE_DATA)) {
 			if (msgbuf.tag.stype == VIO_SUBTYPE_INFO) {
-				err = vnet_rx(port, &msgbuf);
+				if (!port_is_up(port)) {
+					/* failures like handshake_failure()
+					 * may have cleaned up dring, but
+					 * NAPI polling may bring us here.
+					 */
+					err = -ECONNRESET;
+					break;
+				}
+				err = vnet_rx(port, &msgbuf, &npkts, budget);
+				if (npkts >= budget)
+					break;
+				if (npkts == 0 && err != -ECONNRESET)
+					goto ldc_read;
 			} else if (msgbuf.tag.stype == VIO_SUBTYPE_ACK) {
 				err = vnet_ack(port, &msgbuf);
 				if (err > 0)
@@ -691,15 +747,33 @@ static void vnet_event(void *arg, int event)
 		if (err == -ECONNRESET)
 			break;
 	}
-	spin_unlock(&vio->lock);
-	/* Kick off a tasklet to wake the queue.  We cannot call
-	 * maybe_tx_wakeup directly here because we could deadlock on
-	 * netif_tx_lock() with dev_watchdog()
-	 */
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
-		tasklet_schedule(&port->vp->vnet_tx_wakeup);
+		maybe_tx_wakeup(port->vp);
+	return npkts;
+}
+
+static int vnet_poll(struct napi_struct *napi, int budget)
+{
+	struct vnet_port *port = container_of(napi, struct vnet_port, napi);
+	struct vio_driver_state *vio = &port->vio;
+	int processed = vnet_event_napi(port, budget);
+
+	if (processed < budget) {
+		napi_complete(napi);
+		vio_set_intr(vio->vdev->rx_ino, HV_INTR_ENABLED);
+	}
+	return processed;
+}
+
+static void vnet_event(void *arg, int event)
+{
+	struct vnet_port *port = arg;
+	struct vio_driver_state *vio = &port->vio;
+
+	port->rx_event |= event;
+	vio_set_intr(vio->vdev->rx_ino, HV_INTR_DISABLED);
+	napi_schedule(&port->napi);
 
-	local_irq_restore(flags);
 }
 
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
@@ -746,13 +820,6 @@ static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 	return err;
 }
 
-static inline bool port_is_up(struct vnet_port *vnet)
-{
-	struct vio_driver_state *vio = &vnet->vio;
-
-	return !!(vio->hs_state & VIO_HS_COMPLETE);
-}
-
 struct vnet_port *__tx_port_find(struct vnet *vp, struct sk_buff *skb)
 {
 	unsigned int hash = vnet_hashfn(skb->data);
@@ -1342,6 +1409,21 @@ err_out:
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void vnet_poll_controller(struct net_device *dev)
+{
+	struct vnet *vp = netdev_priv(dev);
+	struct vnet_port *port;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vp->lock, flags);
+	if (!list_empty(&vp->port_list)) {
+		port = list_entry(vp->port_list.next, struct vnet_port, list);
+		napi_schedule(&port->napi);
+	}
+	spin_unlock_irqrestore(&vp->lock, flags);
+}
+#endif
 static LIST_HEAD(vnet_list);
 static DEFINE_MUTEX(vnet_list_mutex);
 
@@ -1354,6 +1436,9 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_tx_timeout		= vnet_tx_timeout,
 	.ndo_change_mtu		= vnet_change_mtu,
 	.ndo_start_xmit		= vnet_start_xmit,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= vnet_poll_controller,
+#endif
 };
 
 static struct vnet *vnet_new(const u64 *local_mac)
@@ -1374,7 +1459,6 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	vp = netdev_priv(dev);
 
 	spin_lock_init(&vp->lock);
-	tasklet_init(&vp->vnet_tx_wakeup, maybe_tx_wakeup, (unsigned long)vp);
 	vp->dev = dev;
 
 	INIT_LIST_HEAD(&vp->port_list);
@@ -1434,7 +1518,6 @@ static void vnet_cleanup(void)
 		vp = list_first_entry(&vnet_list, struct vnet, list);
 		list_del(&vp->list);
 		dev = vp->dev;
-		tasklet_kill(&vp->vnet_tx_wakeup);
 		/* vio_unregister_driver() should have cleaned up port_list */
 		BUG_ON(!list_empty(&vp->port_list));
 		unregister_netdev(dev);
@@ -1536,6 +1619,8 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	if (err)
 		goto err_out_free_port;
 
+	netif_napi_add(port->vp->dev, &port->napi, vnet_poll, NAPI_POLL_WEIGHT);
+
 	err = vnet_port_alloc_tx_bufs(port);
 	if (err)
 		goto err_out_free_ldc;
@@ -1564,6 +1649,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	setup_timer(&port->clean_timer, vnet_clean_timer_expire,
 		    (unsigned long)port);
 
+	napi_enable(&port->napi);
 	vio_port_up(&port->vio);
 
 	mdesc_release(hp);
@@ -1571,6 +1657,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	return 0;
 
 err_out_free_ldc:
+	netif_napi_del(&port->napi);
 	vio_ldc_free(&port->vio);
 
 err_out_free_port:
@@ -1592,11 +1679,13 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		del_timer_sync(&port->vio.timer);
 		del_timer_sync(&port->clean_timer);
 
+		napi_disable(&port->napi);
 		spin_lock_irqsave(&vp->lock, flags);
 		list_del(&port->list);
 		hlist_del(&port->hash);
 		spin_unlock_irqrestore(&vp->lock, flags);
 
+		netif_napi_del(&port->napi);
 		vnet_port_free_tx_bufs(port);
 		vio_ldc_free(&port->vio);
 
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index c911045..c8a862e 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -56,6 +56,11 @@ struct vnet_port {
 	struct timer_list	clean_timer;
 
 	u64			rmtu;
+
+	struct napi_struct	napi;
+	u32			napi_stop_idx;
+	bool			napi_resume;
+	int			rx_event;
 };
 
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
@@ -97,7 +102,6 @@ struct vnet {
 	struct list_head	list;
 	u64			local_mac;
 
-	struct tasklet_struct	vnet_tx_wakeup;
 };
 
 #endif /* _SUNVNET_H */
-- 
1.8.4.2
