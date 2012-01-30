From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 14/16] netback: split event channels support
Date: Mon, 30 Jan 2012 14:45:32 +0000
Message-ID: <1327934734-8908-15-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25646 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416Ab2A3Opv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 09:45:51 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally, netback and netfront only use one event channel to do tx /
rx notification. This may cause unnecessary wake-up of NAPI / kthread.

When guest tx is completed, netback will only notify tx_irq.

Also modify xenvif_protocol0 to reflect this change. Rx protocol
only notifies rx_irq.

If split-event-channels feature is not activated, rx_irq = tx_irq, so
RX protocol will just work as expected.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h              |    9 ++-
 drivers/net/xen-netback/interface.c           |   90 ++++++++++++++++++++-----
 drivers/net/xen-netback/netback.c             |    2 +-
 drivers/net/xen-netback/xenbus.c              |   52 ++++++++++++---
 drivers/net/xen-netback/xenvif_rx_protocol0.c |    2 +-
 5 files changed, 123 insertions(+), 32 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index f3d95b3..376f0bf 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -100,8 +100,10 @@ struct xenvif {
 
 	u8               fe_dev_addr[6];
 
-	/* Physical parameters of the comms window. */
-	unsigned int     irq;
+	/* when split_irq == 0, only use tx_irq */
+	int              split_irq;
+	unsigned int     tx_irq;
+	unsigned int     rx_irq;
 
 	/* The shared tx ring and index. */
 	struct xen_netif_tx_back_ring tx;
@@ -162,7 +164,8 @@ struct xenvif *xenvif_alloc(struct device *parent,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_order,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_order,
-		   unsigned int evtchn, unsigned int rx_protocol);
+		   unsigned int evtchn[], int split_evtchn,
+		   unsigned int rx_protocol);
 void xenvif_disconnect(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 0f05f03..afccd5d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -46,15 +46,31 @@ int xenvif_schedulable(struct xenvif *vif)
 	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
 }
 
-static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif = dev_id;
+
+	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
+		napi_schedule(&vif->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
 	if (xenvif_schedulable(vif) && vif->event != NULL)
 		vif->event(vif);
 
-	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
-		napi_schedule(&vif->napi);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+{
+	xenvif_tx_interrupt(0, dev_id);
+
+	xenvif_rx_interrupt(0, dev_id);
 
 	return IRQ_HANDLED;
 }
@@ -118,14 +134,24 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 static void xenvif_up(struct xenvif *vif)
 {
 	napi_enable(&vif->napi);
-	enable_irq(vif->irq);
+	if (!vif->split_irq)
+		enable_irq(vif->tx_irq);
+	else {
+		enable_irq(vif->tx_irq);
+		enable_irq(vif->rx_irq);
+	}
 	xenvif_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
 	napi_disable(&vif->napi);
-	disable_irq(vif->irq);
+	if (!vif->split_irq)
+		disable_irq(vif->tx_irq);
+	else {
+		disable_irq(vif->tx_irq);
+		disable_irq(vif->rx_irq);
+	}
 }
 
 static int xenvif_open(struct net_device *dev)
@@ -308,13 +334,14 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 int xenvif_connect(struct xenvif *vif,
 		   unsigned long tx_ring_ref[], unsigned int tx_ring_ref_count,
 		   unsigned long rx_ring_ref[], unsigned int rx_ring_ref_count,
-		   unsigned int evtchn, unsigned int rx_protocol)
+		   unsigned int evtchn[], int split_evtchn,
+		   unsigned int rx_protocol)
 {
 	int err = -ENOMEM;
 	struct xen_netif_tx_sring *txs;
 
 	/* Already connected through? */
-	if (vif->irq)
+	if (vif->tx_irq)
 		return 0;
 
 	__module_get(THIS_MODULE);
@@ -345,13 +372,35 @@ int xenvif_connect(struct xenvif *vif,
 	if (vif->setup(vif))
 		goto err_rx_unmap;
 
-	err = bind_interdomain_evtchn_to_irqhandler(
-		vif->domid, evtchn, xenvif_interrupt, 0,
-		vif->dev->name, vif);
-	if (err < 0)
-		goto err_rx_unmap;
-	vif->irq = err;
-	disable_irq(vif->irq);
+	if (!split_evtchn) {
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, evtchn[0], xenvif_interrupt, 0,
+			vif->dev->name, vif);
+		if (err < 0)
+			goto err_rx_unmap;
+		vif->tx_irq = vif->rx_irq = err;
+		disable_irq(vif->tx_irq);
+		vif->split_irq = 0;
+	} else {
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, evtchn[0], xenvif_tx_interrupt,
+			0, vif->dev->name, vif);
+		if (err < 0)
+			goto err_rx_unmap;
+		vif->tx_irq = err;
+		disable_irq(vif->tx_irq);
+
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, evtchn[1], xenvif_rx_interrupt,
+			0, vif->dev->name, vif);
+		if (err < 0) {
+			unbind_from_irqhandler(vif->tx_irq, vif);
+			goto err_rx_unmap;
+		}
+		vif->rx_irq = err;
+		disable_irq(vif->rx_irq);
+		vif->split_irq = 1;
+	}
 
 	init_waitqueue_head(&vif->wq);
 	vif->task = kthread_create(xenvif_kthread,
@@ -376,7 +425,12 @@ int xenvif_connect(struct xenvif *vif,
 
 	return 0;
 err_unbind:
-	unbind_from_irqhandler(vif->irq, vif);
+	if (!vif->split_irq)
+		unbind_from_irqhandler(vif->tx_irq, vif);
+	else {
+		unbind_from_irqhandler(vif->tx_irq, vif);
+		unbind_from_irqhandler(vif->rx_irq, vif);
+	}
 err_rx_unmap:
 	xenvif_unmap_frontend_rings(&vif->rx_comms);
 err_tx_unmap:
@@ -406,10 +460,12 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	del_timer_sync(&vif->credit_timeout);
 
-	if (vif->irq) {
-		unbind_from_irqhandler(vif->irq, vif);
+	if (vif->tx_irq) {
+		unbind_from_irqhandler(vif->tx_irq, vif);
 		need_module_put = 1;
 	}
+	if (vif->split_irq && vif->rx_irq)
+		unbind_from_irqhandler(vif->rx_irq, vif);
 
 	unregister_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2ea43d4..f4ec292 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -895,7 +895,7 @@ static void make_tx_response(struct xenvif *vif,
 	vif->tx.rsp_prod_pvt = ++i;
 	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
 	if (notify)
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->tx_irq);
 }
 
 static inline int rx_work_todo(struct xenvif *vif)
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 4067286..c5a3b27 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -131,6 +131,14 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		err = xenbus_printf(xbt, dev->nodename,
+				    "split-event-channels",
+				    "%u", 1);
+		if (err) {
+			message = "writing split-event-channels";
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
+	unsigned int evtchn[2], split_evtchn, rx_copy;
 	int err;
 	int val;
 	unsigned long tx_ring_ref[NETBK_MAX_RING_PAGES];
@@ -418,12 +426,31 @@ static int connect_rings(struct backend_info *be)
 	unsigned int  rx_protocol;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "event-channel", "%u", &evtchn, NULL);
+			    "event-channel", "%u", &evtchn[0], NULL);
 	if (err) {
-		xenbus_dev_fatal(dev, err,
-				 "reading %s/event-channel",
-				 dev->otherend);
-		return err;
+		err = xenbus_gather(XBT_NIL, dev->otherend,
+				    "event-channel-tx", "%u", &evtchn[0],
+				    NULL);
+		if (err) {
+			xenbus_dev_fatal(dev, err,
+					 "reading %s/event-channel-tx",
+					 dev->otherend);
+			return err;
+		}
+		err = xenbus_gather(XBT_NIL, dev->otherend,
+				    "event-channel-rx", "%u", &evtchn[1],
+				    NULL);
+		if (err) {
+			xenbus_dev_fatal(dev, err,
+					 "reading %s/event-channel-rx",
+					 dev->otherend);
+			return err;
+		}
+		split_evtchn = 1;
+		dev_info(&dev->dev, "split event channels\n");
+	} else {
+		split_evtchn = 0;
+		dev_info(&dev->dev, "single event channel\n");
 	}
 
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-order", "%u",
@@ -565,12 +592,17 @@ static int connect_rings(struct backend_info *be)
 	err = xenvif_connect(vif,
 			     tx_ring_ref, (1U << tx_ring_order),
 			     rx_ring_ref, (1U << rx_ring_order),
-			     evtchn, rx_protocol);
+			     evtchn, split_evtchn, rx_protocol);
 	if (err) {
 		int i;
-		xenbus_dev_fatal(dev, err,
-				 "binding port %u",
-				 evtchn);
+		if (!split_evtchn)
+			xenbus_dev_fatal(dev, err,
+					 "binding port %u",
+					 evtchn[0]);
+		else
+			xenbus_dev_fatal(dev, err,
+					 "binding tx port %u, rx port %u",
+					 evtchn[0], evtchn[1]);
 		for (i = 0; i < (1U << tx_ring_order); i++)
 			xenbus_dev_fatal(dev, err,
 					 "mapping tx ring handle: %lu",
diff --git a/drivers/net/xen-netback/xenvif_rx_protocol0.c b/drivers/net/xen-netback/xenvif_rx_protocol0.c
index 3c95d65..6959a1d 100644
--- a/drivers/net/xen-netback/xenvif_rx_protocol0.c
+++ b/drivers/net/xen-netback/xenvif_rx_protocol0.c
@@ -550,7 +550,7 @@ void xenvif_rx_action(struct xenvif *vif)
 	}
 
 	if (need_to_notify)
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->rx_irq);
 
 	if (!skb_queue_empty(&vif->rx_queue))
 		xenvif_kick_thread(vif);
-- 
1.7.2.5
