From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 11/13] netback: split event channels support
Date: Thu, 2 Feb 2012 16:49:21 +0000
Message-ID: <1328201363-13915-12-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16259 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157Ab2BBQtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 11:49:41 -0500
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally, netback and netfront only use one event channel to do tx /
rx notification. This may cause unnecessary wake-up of NAPI / kthread.

When guest tx is completed, netback will only notify tx_irq.

If feature-split-event-channels ==0, rx_irq = tx_irq, so
RX protocol will just work as expected.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |    7 ++-
 drivers/net/xen-netback/interface.c |   82 +++++++++++++++++++++++++++--------
 drivers/net/xen-netback/netback.c   |    4 +-
 drivers/net/xen-netback/xenbus.c    |   51 +++++++++++++++++----
 4 files changed, 111 insertions(+), 33 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 1bb16ec..a0497fc 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -85,8 +85,9 @@ struct xenvif {
 
 	u8               fe_dev_addr[6];
 
-	/* Physical parameters of the comms window. */
-	unsigned int     irq;
+	/* When feature-split-event-channels = 0, tx_irq = rx_irq */
+	unsigned int tx_irq;
+	unsigned int rx_irq;
 
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
@@ -145,7 +146,7 @@ struct xenvif *xenvif_alloc(struct device *parent,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_order,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_order,
-		   unsigned int evtchn);
+		   unsigned int tx_evtchn, unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e1aa003..c6dbd50 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -51,19 +51,35 @@ static int xenvif_rx_schedulable(struct xenvif *vif)
 	return xenvif_schedulable(vif) && !xenvif_rx_ring_full(vif);
 }
 
-static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (xenvif_rx_schedulable(vif))
-		netif_wake_queue(vif->dev);
-
 	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
 		napi_schedule(&vif->napi);
 
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif = dev_id;
+
+	if (xenvif_schedulable(vif) && !xenvif_rx_ring_full(vif))
+		netif_wake_queue(vif->dev);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+{
+	xenvif_tx_interrupt(irq, dev_id);
+
+	xenvif_rx_interrupt(irq, dev_id);
+
+	return IRQ_HANDLED;
+}
+
 static int xenvif_poll(struct napi_struct *napi, int budget)
 {
 	struct xenvif *vif = container_of(napi, struct xenvif, napi);
@@ -132,14 +148,16 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 static void xenvif_up(struct xenvif *vif)
 {
 	napi_enable(&vif->napi);
-	enable_irq(vif->irq);
+	enable_irq(vif->tx_irq);
+	enable_irq(vif->rx_irq);
 	xenvif_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
 	napi_disable(&vif->napi);
-	disable_irq(vif->irq);
+	disable_irq(vif->tx_irq);
+	disable_irq(vif->rx_irq);
 }
 
 static int xenvif_open(struct net_device *dev)
@@ -322,7 +340,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_ref_count,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_ref_count,
-		   unsigned int evtchn)
+		   unsigned int tx_evtchn, unsigned int rx_evtchn)
 {
 	int err = -ENOMEM;
 	void *addr;
@@ -331,7 +349,7 @@ int xenvif_connect(struct xenvif *vif,
 	int tmp[NETBK_MAX_RING_PAGES], i;
 
 	/* Already connected through? */
-	if (vif->irq)
+	if (vif->tx_irq)
 		return 0;
 
 	__module_get(THIS_MODULE);
@@ -358,13 +376,34 @@ int xenvif_connect(struct xenvif *vif,
 	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
 	vif->nr_rx_handles = rx_ring_ref_count;
 
-	err = bind_interdomain_evtchn_to_irqhandler(
-		vif->domid, evtchn, xenvif_interrupt, 0,
-		vif->dev->name, vif);
-	if (err < 0)
-		goto err_rx_unmap;
-	vif->irq = err;
-	disable_irq(vif->irq);
+	if (tx_evtchn == rx_evtchn) { /* feature-split-event-channels == 0 */
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, tx_evtchn, xenvif_interrupt, 0,
+			vif->dev->name, vif);
+		if (err < 0)
+			goto err_rx_unmap;
+		vif->tx_irq = vif->rx_irq = err;
+		disable_irq(vif->tx_irq);
+		disable_irq(vif->rx_irq);
+	} else {
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
+			vif->dev->name, vif);
+		if (err < 0)
+			goto err_rx_unmap;
+		vif->tx_irq = err;
+		disable_irq(vif->tx_irq);
+
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
+			vif->dev->name, vif);
+		if (err < 0) {
+			unbind_from_irqhandler(vif->tx_irq, vif);
+			goto err_rx_unmap;
+		}
+		vif->rx_irq = err;
+		disable_irq(vif->rx_irq);
+	}
 
 	init_waitqueue_head(&vif->wq);
 	vif->task = kthread_create(xenvif_kthread,
@@ -389,7 +428,12 @@ int xenvif_connect(struct xenvif *vif,
 
 	return 0;
 err_unbind:
-	unbind_from_irqhandler(vif->irq, vif);
+	if (vif->tx_irq == vif->rx_irq)
+		unbind_from_irqhandler(vif->tx_irq, vif);
+	else {
+		unbind_from_irqhandler(vif->tx_irq, vif);
+		unbind_from_irqhandler(vif->rx_irq, vif);
+	}
 err_rx_unmap:
 	xenvif_unmap_frontend_ring(vif, (void *)vif->tx.sring);
 err_tx_unmap:
@@ -419,10 +463,12 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	del_timer_sync(&vif->credit_timeout);
 
-	if (vif->irq) {
-		unbind_from_irqhandler(vif->irq, vif);
+	if (vif->tx_irq) {
+		unbind_from_irqhandler(vif->tx_irq, vif);
 		need_module_put = 1;
 	}
+	if (vif->tx_irq != vif->rx_irq)
+		unbind_from_irqhandler(vif->rx_irq, vif);
 
 	unregister_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 60c8951..957cf9d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -622,7 +622,7 @@ void xenvif_rx_action(struct xenvif *vif)
 	}
 
 	if (need_to_notify)
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->rx_irq);
 
 	if (!skb_queue_empty(&vif->rx_queue))
 		xenvif_kick_thread(vif);
@@ -1392,7 +1392,7 @@ static void make_tx_response(struct xenvif *vif,
 	vif->tx.rsp_prod_pvt = ++i;
 	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
 	if (notify)
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->tx_irq);
 }
 
 static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 79499fc..3772e0c 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -131,6 +131,14 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-split-event-channels",
+				    "%u", 1);
+		if (err) {
+			message = "writing feature-split-event-channels";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -408,7 +416,7 @@ static int connect_rings(struct backend_info *be)
 {
 	struct xenvif *vif = be->vif;
 	struct xenbus_device *dev = be->dev;
-	unsigned int evtchn, rx_copy;
+	unsigned int tx_evtchn, rx_evtchn, rx_copy;
 	int err;
 	int val;
 	unsigned long tx_ring_ref[NETBK_MAX_RING_PAGES];
@@ -417,12 +425,30 @@ static int connect_rings(struct backend_info *be)
 	unsigned int  rx_ring_order;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "event-channel", "%u", &evtchn, NULL);
+			    "event-channel", "%u", &tx_evtchn, NULL);
 	if (err) {
-		xenbus_dev_fatal(dev, err,
-				 "reading %s/event-channel",
-				 dev->otherend);
-		return err;
+		err = xenbus_gather(XBT_NIL, dev->otherend,
+				    "event-channel-tx", "%u", &tx_evtchn,
+				    NULL);
+		if (err) {
+			xenbus_dev_fatal(dev, err,
+					 "reading %s/event-channel-tx",
+					 dev->otherend);
+			return err;
+		}
+		err = xenbus_gather(XBT_NIL, dev->otherend,
+				    "event-channel-rx", "%u", &rx_evtchn,
+				    NULL);
+		if (err) {
+			xenbus_dev_fatal(dev, err,
+					 "reading %s/event-channel-rx",
+					 dev->otherend);
+			return err;
+		}
+		dev_info(&dev->dev, "split event channels\n");
+	} else {
+		rx_evtchn = tx_evtchn;
+		dev_info(&dev->dev, "single event channel\n");
 	}
 
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-order", "%u",
@@ -559,12 +585,17 @@ static int connect_rings(struct backend_info *be)
 	err = xenvif_connect(vif,
 			     tx_ring_ref, (1U << tx_ring_order),
 			     rx_ring_ref, (1U << rx_ring_order),
-			     evtchn);
+			     tx_evtchn, rx_evtchn);
 	if (err) {
 		int i;
-		xenbus_dev_fatal(dev, err,
-				 "binding port %u",
-				 evtchn);
+		if (tx_evtchn == rx_evtchn)
+			xenbus_dev_fatal(dev, err,
+					 "binding port %u",
+					 tx_evtchn);
+		else
+			xenbus_dev_fatal(dev, err,
+					 "binding tx port %u, rx port %u",
+					 tx_evtchn, rx_evtchn);
 		for (i = 0; i < (1U << tx_ring_order); i++)
 			xenbus_dev_fatal(dev, err,
 					 "mapping tx ring handle: %lu",
-- 
1.7.2.5
