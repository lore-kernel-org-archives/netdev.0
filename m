From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] sunvnet: Process Rx data packets in a BH handler
Date: Wed, 1 Oct 2014 14:56:15 -0400
Message-ID: <20141001185615.GH17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45106 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaJAS4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:56:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move VIO DATA processing out of interrupt context,
and into a bottom-half handler (vnet_event_bh())

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

---
 drivers/net/ethernet/sun/sunvnet.c | 126 ++++++++++++++++++++++++-------------
 drivers/net/ethernet/sun/sunvnet.h |  10 ++-
 2 files changed, 91 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1262697..e2aacf5 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -274,6 +274,7 @@ static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
 	return skb;
 }
 
+/* reads in exactly one sk_buff */
 static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 		       struct ldc_trans_cookie *cookies, int ncookies)
 {
@@ -311,9 +312,8 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
-
-	netif_rx(skb);
-
+	/* BH context cannot call netif_receive_skb */
+	netif_rx_ni(skb);
 	return 0;
 
 out_free_skb:
@@ -534,7 +534,10 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	struct net_device *dev;
 	struct vnet *vp;
 	u32 end;
+	unsigned long flags;
 	struct vio_net_desc *desc;
+	bool need_trigger = false;
+
 	if (unlikely(pkt->tag.stype_env != VIO_DRING_DATA))
 		return 0;
 
@@ -545,21 +548,17 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	/* sync for race conditions with vnet_start_xmit() and tell xmit it
 	 * is time to send a trigger.
 	 */
+	spin_lock_irqsave(&port->vio.lock, flags);
 	dr->cons = next_idx(end, dr);
 	desc = vio_dring_entry(dr, dr->cons);
-	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
-		/* vnet_start_xmit() just populated this dring but missed
-		 * sending the "start" LDC message to the consumer.
-		 * Send a "start" trigger on its behalf.
-		 */
-		if (__vnet_tx_trigger(port, dr->cons) > 0)
-			port->start_cons = false;
-		else
-			port->start_cons = true;
-	} else {
-		port->start_cons = true;
-	}
+	if (desc->hdr.state == VIO_DESC_READY && !port->start_cons)
+		need_trigger = true;
+	else
+		port->start_cons = true; /* vnet_start_xmit will send trigger */
+	spin_unlock_irqrestore(&port->vio.lock, flags);
 
+	if (need_trigger && __vnet_tx_trigger(port, dr->cons) <= 0)
+		port->start_cons = true;
 
 	vp = port->vp;
 	dev = vp->dev;
@@ -617,33 +616,13 @@ static void maybe_tx_wakeup(unsigned long param)
 	netif_tx_unlock(dev);
 }
 
-static void vnet_event(void *arg, int event)
+static void vnet_event_bh(struct work_struct *work)
 {
-	struct vnet_port *port = arg;
+	struct vnet_port *port = container_of(work, struct vnet_port, rx_work);
 	struct vio_driver_state *vio = &port->vio;
-	unsigned long flags;
 	int tx_wakeup, err;
 
-	spin_lock_irqsave(&vio->lock, flags);
-
-	if (unlikely(event == LDC_EVENT_RESET ||
-		     event == LDC_EVENT_UP)) {
-		vio_link_state_change(vio, event);
-		spin_unlock_irqrestore(&vio->lock, flags);
-
-		if (event == LDC_EVENT_RESET) {
-			port->rmtu = 0;
-			vio_port_up(vio);
-		}
-		return;
-	}
-
-	if (unlikely(event != LDC_EVENT_DATA_READY)) {
-		pr_warn("Unexpected LDC event %d\n", event);
-		spin_unlock_irqrestore(&vio->lock, flags);
-		return;
-	}
-
+	mutex_lock(&port->vnet_rx_mutex);
 	tx_wakeup = err = 0;
 	while (1) {
 		union {
@@ -691,14 +670,41 @@ static void vnet_event(void *arg, int event)
 		if (err == -ECONNRESET)
 			break;
 	}
-	spin_unlock(&vio->lock);
-	/* Kick off a tasklet to wake the queue.  We cannot call
-	 * maybe_tx_wakeup directly here because we could deadlock on
-	 * netif_tx_lock() with dev_watchdog()
-	 */
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
 		tasklet_schedule(&port->vp->vnet_tx_wakeup);
+	mutex_unlock(&port->vnet_rx_mutex);
+	vio_set_intr(vio->vdev->rx_ino, HV_INTR_ENABLED);
+}
+
+static void vnet_event(void *arg, int event)
+{
+	struct vnet_port *port = arg;
+	struct vio_driver_state *vio = &port->vio;
+	unsigned long flags;
 
+	spin_lock_irqsave(&vio->lock, flags);
+
+	if (unlikely(event == LDC_EVENT_RESET ||
+		     event == LDC_EVENT_UP)) {
+		vio_link_state_change(vio, event);
+		spin_unlock_irqrestore(&vio->lock, flags);
+
+		if (event == LDC_EVENT_RESET)
+			vio_port_up(vio);
+		return;
+	}
+
+	if (unlikely(event != LDC_EVENT_DATA_READY)) {
+		pr_warn("Unexpected LDC event %d\n", event);
+		spin_unlock_irqrestore(&vio->lock, flags);
+		return;
+	}
+
+	if ((port->flags & VNET_PORT_DEAD) == 0) {
+		vio_set_intr(vio->vdev->rx_ino, HV_INTR_DISABLED);
+		queue_work(port->rx_workq, &port->rx_work);
+	}
+	spin_unlock(&vio->lock);
 	local_irq_restore(flags);
 }
 
@@ -750,6 +756,11 @@ static inline bool port_is_up(struct vnet_port *vnet)
 {
 	struct vio_driver_state *vio = &vnet->vio;
 
+	/* Should never hit a DEAD port here: we are holding the vnet lock,
+	 * and the list cleanup and VNET_PORT_DEAD marking gets done
+	 * under the vnet lock as well.
+	 */
+	BUG_ON(vnet->flags & VNET_PORT_DEAD);
 	return !!(vio->hs_state & VIO_HS_COMPLETE);
 }
 
@@ -1487,6 +1498,23 @@ static void print_version(void)
 	printk_once(KERN_INFO "%s", version);
 }
 
+static int vnet_workq_enable(struct vnet_port *port)
+{
+	port->rx_workq = alloc_workqueue(dev_name(&port->vio.vdev->dev),
+					 WQ_HIGHPRI|WQ_UNBOUND, 1);
+	if (!port->rx_workq)
+		return -ENOMEM;
+	mutex_init(&port->vnet_rx_mutex);
+	INIT_WORK(&port->rx_work, vnet_event_bh);
+	return 0;
+}
+
+static void vnet_workq_disable(struct vnet_port *port)
+{
+	flush_workqueue(port->rx_workq);
+	destroy_workqueue(port->rx_workq);
+}
+
 const char *remote_macaddr_prop = "remote-mac-address";
 
 static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
@@ -1536,6 +1564,10 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	if (err)
 		goto err_out_free_port;
 
+	err = vnet_workq_enable(port);
+	if (err)
+		goto err_out_free_port;
+
 	err = vnet_port_alloc_tx_bufs(port);
 	if (err)
 		goto err_out_free_ldc;
@@ -1572,6 +1604,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 err_out_free_ldc:
 	vio_ldc_free(&port->vio);
+	destroy_workqueue(port->rx_workq);
 
 err_out_free_port:
 	kfree(port);
@@ -1589,14 +1622,21 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		struct vnet *vp = port->vp;
 		unsigned long flags;
 
+		vio_set_intr(port->vio.vdev->rx_ino, HV_INTR_DISABLED);
 		del_timer_sync(&port->vio.timer);
 		del_timer_sync(&port->clean_timer);
 
+		/* VNET_PORT_DEAD disallows any more vnet_event_bh
+		 * scheduling and prevents new refs to the port
+		 */
 		spin_lock_irqsave(&vp->lock, flags);
+		port->flags |= VNET_PORT_DEAD;
 		list_del(&port->list);
 		hlist_del(&port->hash);
 		spin_unlock_irqrestore(&vp->lock, flags);
 
+		vnet_workq_disable(port);
+
 		vnet_port_free_tx_bufs(port);
 		vio_ldc_free(&port->vio);
 
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index c911045..1182ec6 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -2,7 +2,7 @@
 #define _SUNVNET_H
 
 #include <linux/interrupt.h>
-
+#include <linux/workqueue.h>
 #define DESC_NCOOKIES(entry_size)	\
 	((entry_size) - sizeof(struct vio_net_desc))
 
@@ -41,7 +41,8 @@ struct vnet_port {
 	struct hlist_node	hash;
 	u8			raddr[ETH_ALEN];
 	u8			switch_port;
-	u8			__pad;
+	u8			flags;
+#define	VNET_PORT_DEAD	0x01
 
 	struct vnet		*vp;
 
@@ -56,6 +57,11 @@ struct vnet_port {
 	struct timer_list	clean_timer;
 
 	u64			rmtu;
+
+	struct mutex            vnet_rx_mutex; /* serializes rx_workq */
+	struct work_struct      rx_work;
+	struct workqueue_struct *rx_workq;
+
 };
 
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
-- 
1.8.4.2
