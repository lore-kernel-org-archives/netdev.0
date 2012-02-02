From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 10/13] netback: multi page ring support
Date: Thu, 2 Feb 2012 16:49:20 +0000
Message-ID: <1328201363-13915-11-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18042 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab2BBQto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 11:49:44 -0500
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend netback to support multi page ring.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   35 +++++++---
 drivers/net/xen-netback/interface.c |   43 ++++++++++--
 drivers/net/xen-netback/netback.c   |   74 ++++++++------------
 drivers/net/xen-netback/xenbus.c    |  129 +++++++++++++++++++++++++++++++++--
 4 files changed, 213 insertions(+), 68 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index b7d4442..1bb16ec 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -59,10 +59,18 @@ struct xenvif_rx_meta {
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define NETBK_TX_RING_SIZE(_nr_pages)					\
+	(__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages)))
+#define NETBK_RX_RING_SIZE(_nr_pages)					\
+	(__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages)))
 
-#define MAX_PENDING_REQS 256
+#define NETBK_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
+#define NETBK_MAX_RING_PAGES      (1U << NETBK_MAX_RING_PAGE_ORDER)
+
+#define NETBK_MAX_TX_RING_SIZE NETBK_TX_RING_SIZE(NETBK_MAX_RING_PAGES)
+#define NETBK_MAX_RX_RING_SIZE NETBK_RX_RING_SIZE(NETBK_MAX_RING_PAGES)
+
+#define MAX_PENDING_REQS NETBK_MAX_TX_RING_SIZE
 
 struct xenvif {
 	/* Unique identifier for this interface. */
@@ -83,6 +91,8 @@ struct xenvif {
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
 	struct xen_netif_rx_back_ring rx;
+	int nr_tx_handles;
+	int nr_rx_handles;
 
 	/* Frontend feature information. */
 	u8 can_sg:1;
@@ -132,8 +142,10 @@ struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn);
+int xenvif_connect(struct xenvif *vif,
+		   unsigned long tx_ring_ref[], unsigned int tx_ring_order,
+		   unsigned long rx_ring_ref[], unsigned int rx_ring_order,
+		   unsigned int evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
 int xenvif_xenbus_init(void);
@@ -146,10 +158,12 @@ int xenvif_rx_ring_full(struct xenvif *vif);
 int xenvif_must_stop_queue(struct xenvif *vif);
 
 /* (Un)Map communication rings. */
-void xenvif_unmap_frontend_rings(struct xenvif *vif);
-int xenvif_map_frontend_rings(struct xenvif *vif,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref);
+void xenvif_unmap_frontend_ring(struct xenvif *vif, void *addr);
+int xenvif_map_frontend_ring(struct xenvif *vif,
+			     void **vaddr,
+			     int domid,
+			     int ring_ref[],
+			     unsigned int  ring_ref_count);
 
 /* Check for SKBs from frontend and schedule backend processing */
 void xenvif_check_rx_xenvif(struct xenvif *vif);
@@ -167,4 +181,7 @@ void xenvif_rx_action(struct xenvif *vif);
 
 int xenvif_kthread(void *data);
 
+extern unsigned int MODPARM_netback_max_tx_ring_page_order;
+extern unsigned int MODPARM_netback_max_rx_ring_page_order;
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index b2bde8f..e1aa003 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -319,10 +319,16 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	return vif;
 }
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn)
+int xenvif_connect(struct xenvif *vif,
+		   unsigned long tx_ring_ref[], unsigned int tx_ring_ref_count,
+		   unsigned long rx_ring_ref[], unsigned int rx_ring_ref_count,
+		   unsigned int evtchn)
 {
 	int err = -ENOMEM;
+	void *addr;
+	struct xen_netif_tx_sring *txs;
+	struct xen_netif_rx_sring *rxs;
+	int tmp[NETBK_MAX_RING_PAGES], i;
 
 	/* Already connected through? */
 	if (vif->irq)
@@ -330,15 +336,33 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	__module_get(THIS_MODULE);
 
-	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
-	if (err < 0)
+	for (i = 0; i < tx_ring_ref_count; i++)
+		tmp[i] = tx_ring_ref[i];
+
+	err = xenvif_map_frontend_ring(vif, &addr, vif->domid,
+				       tmp, tx_ring_ref_count);
+	if (err)
 		goto err;
+	txs = addr;
+	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE * tx_ring_ref_count);
+	vif->nr_tx_handles = tx_ring_ref_count;
+
+	for (i = 0; i < rx_ring_ref_count; i++)
+		tmp[i] = rx_ring_ref[i];
+
+	err = xenvif_map_frontend_ring(vif, &addr, vif->domid,
+					tmp, rx_ring_ref_count);
+	if (err)
+		goto err_tx_unmap;
+	rxs = addr;
+	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
+	vif->nr_rx_handles = rx_ring_ref_count;
 
 	err = bind_interdomain_evtchn_to_irqhandler(
 		vif->domid, evtchn, xenvif_interrupt, 0,
 		vif->dev->name, vif);
 	if (err < 0)
-		goto err_unmap;
+		goto err_rx_unmap;
 	vif->irq = err;
 	disable_irq(vif->irq);
 
@@ -366,8 +390,10 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	return 0;
 err_unbind:
 	unbind_from_irqhandler(vif->irq, vif);
-err_unmap:
-	xenvif_unmap_frontend_rings(vif);
+err_rx_unmap:
+	xenvif_unmap_frontend_ring(vif, (void *)vif->tx.sring);
+err_tx_unmap:
+	xenvif_unmap_frontend_ring(vif, (void *)vif->rx.sring);
 err:
 	module_put(THIS_MODULE);
 	return err;
@@ -400,7 +426,8 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	xenvif_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_ring(vif, (void *)vif->tx.sring);
+	xenvif_unmap_frontend_ring(vif, (void *)vif->rx.sring);
 
 	free_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index cb1a661..60c8951 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -49,6 +49,17 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
+unsigned int MODPARM_netback_max_rx_ring_page_order = NETBK_MAX_RING_PAGE_ORDER;
+module_param_named(netback_max_rx_ring_page_order,
+		   MODPARM_netback_max_rx_ring_page_order, uint, 0);
+MODULE_PARM_DESC(netback_max_rx_ring_page_order,
+		 "Maximum supported receiver ring page order");
+
+unsigned int MODPARM_netback_max_tx_ring_page_order = NETBK_MAX_RING_PAGE_ORDER;
+module_param_named(netback_max_tx_ring_page_order,
+		   MODPARM_netback_max_tx_ring_page_order, uint, 0);
+MODULE_PARM_DESC(netback_max_tx_ring_page_order,
+		 "Maximum supported transmitter ring page order");
 
 DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
 
@@ -134,7 +145,8 @@ int xenvif_rx_ring_full(struct xenvif *vif)
 	RING_IDX needed = max_required_rx_slots(vif);
 
 	return ((vif->rx.sring->req_prod - peek) < needed) ||
-	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
+	       ((vif->rx.rsp_prod_pvt +
+		 NETBK_RX_RING_SIZE(vif->nr_rx_handles) - peek) < needed);
 }
 
 int xenvif_must_stop_queue(struct xenvif *vif)
@@ -520,7 +532,8 @@ void xenvif_rx_action(struct xenvif *vif)
 		__skb_queue_tail(&rxq, skb);
 
 		/* Filled the batch queue? */
-		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
+		if (count + MAX_SKB_FRAGS >=
+		    NETBK_RX_RING_SIZE(vif->nr_rx_handles))
 			break;
 	}
 
@@ -532,7 +545,7 @@ void xenvif_rx_action(struct xenvif *vif)
 		return;
 	}
 
-	BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));
+	BUG_ON(npo.copy_prod > (2 * NETBK_MAX_RX_RING_SIZE));
 	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
 					npo.copy_prod);
 	BUG_ON(ret != 0);
@@ -1419,48 +1432,22 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
-void xenvif_unmap_frontend_rings(struct xenvif *vif)
+void xenvif_unmap_frontend_ring(struct xenvif *vif, void *addr)
 {
-	if (vif->tx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->tx.sring);
-	if (vif->rx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->rx.sring);
+	if (addr)
+		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif), addr);
 }
 
-int xenvif_map_frontend_rings(struct xenvif *vif,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref)
+int xenvif_map_frontend_ring(struct xenvif *vif,
+			      void **vaddr,
+			      int domid,
+			      int ring_ref[],
+			      unsigned int  ring_ref_count)
 {
-	void *addr;
-	struct xen_netif_tx_sring *txs;
-	struct xen_netif_rx_sring *rxs;
-
-	int err = -ENOMEM;
+	int err = 0;
 
 	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-				     &tx_ring_ref, 1, &addr);
-	if (err)
-		goto err;
-
-	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
-
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-				     &rx_ring_ref, 1, &addr);
-	if (err)
-		goto err;
-
-	rxs = (struct xen_netif_rx_sring *)addr;
-	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
-
-	vif->rx_req_cons_peek = 0;
-
-	return 0;
-
-err:
-	xenvif_unmap_frontend_rings(vif);
+				     ring_ref, ring_ref_count, vaddr);
 	return err;
 }
 
@@ -1486,7 +1473,6 @@ int xenvif_kthread(void *data)
 
 static int __create_percpu_scratch_space(unsigned int cpu)
 {
-	/* Guard against race condition */
 	if (per_cpu(tx_copy_ops, cpu) ||
 	    per_cpu(grant_copy_op, cpu) ||
 	    per_cpu(meta, cpu))
@@ -1502,19 +1488,19 @@ static int __create_percpu_scratch_space(unsigned int cpu)
 
 	per_cpu(grant_copy_op, cpu) =
 		vzalloc_node(sizeof(struct gnttab_copy)
-			     * 2 * XEN_NETIF_RX_RING_SIZE, cpu_to_node(cpu));
+			     * 2 * NETBK_MAX_RX_RING_SIZE, cpu_to_node(cpu));
 
 	if (!per_cpu(grant_copy_op, cpu))
 		per_cpu(grant_copy_op, cpu) =
 			vzalloc(sizeof(struct gnttab_copy)
-				* 2 * XEN_NETIF_RX_RING_SIZE);
+				* 2 * NETBK_MAX_RX_RING_SIZE);
 
 	per_cpu(meta, cpu) = vzalloc_node(sizeof(struct xenvif_rx_meta)
-					  * 2 * XEN_NETIF_RX_RING_SIZE,
+					  * 2 * NETBK_MAX_RX_RING_SIZE,
 					  cpu_to_node(cpu));
 	if (!per_cpu(meta, cpu))
 		per_cpu(meta, cpu) = vzalloc(sizeof(struct xenvif_rx_meta)
-					     * 2 * XEN_NETIF_RX_RING_SIZE);
+					     * 2 * NETBK_MAX_RX_RING_SIZE);
 
 	if (!per_cpu(tx_copy_ops, cpu) ||
 	    !per_cpu(grant_copy_op, cpu) ||
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index f1e89ca..79499fc 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -113,6 +113,23 @@ static int netback_probe(struct xenbus_device *dev,
 			message = "writing feature-rx-flip";
 			goto abort_transaction;
 		}
+		err = xenbus_printf(xbt, dev->nodename,
+				    "max-tx-ring-page-order",
+				    "%u",
+				    MODPARM_netback_max_tx_ring_page_order);
+		if (err) {
+			message = "writing max-tx-ring-page-order";
+			goto abort_transaction;
+		}
+
+		err = xenbus_printf(xbt, dev->nodename,
+				    "max-rx-ring-page-order",
+				    "%u",
+				    MODPARM_netback_max_rx_ring_page_order);
+		if (err) {
+			message = "writing max-rx-ring-page-order";
+			goto abort_transaction;
+		}
 
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
@@ -391,22 +408,108 @@ static int connect_rings(struct backend_info *be)
 {
 	struct xenvif *vif = be->vif;
 	struct xenbus_device *dev = be->dev;
-	unsigned long tx_ring_ref, rx_ring_ref;
 	unsigned int evtchn, rx_copy;
 	int err;
 	int val;
+	unsigned long tx_ring_ref[NETBK_MAX_RING_PAGES];
+	unsigned long rx_ring_ref[NETBK_MAX_RING_PAGES];
+	unsigned int  tx_ring_order;
+	unsigned int  rx_ring_order;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "tx-ring-ref", "%lu", &tx_ring_ref,
-			    "rx-ring-ref", "%lu", &rx_ring_ref,
 			    "event-channel", "%u", &evtchn, NULL);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
-				 "reading %s/ring-ref and event-channel",
+				 "reading %s/event-channel",
 				 dev->otherend);
 		return err;
 	}
 
+	err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-order", "%u",
+			   &tx_ring_order);
+	if (err < 0) {
+		tx_ring_order = 0;
+
+		err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-ref", "%lu",
+				   &tx_ring_ref[0]);
+		if (err < 0) {
+			xenbus_dev_fatal(dev, err, "reading %s/tx-ring-ref",
+					 dev->otherend);
+			return err;
+		}
+	} else {
+		unsigned int i;
+
+		if (tx_ring_order > MODPARM_netback_max_tx_ring_page_order) {
+			err = -EINVAL;
+
+			xenbus_dev_fatal(dev, err,
+					 "%s/tx-ring-page-order too big",
+					 dev->otherend);
+			return err;
+		}
+
+		for (i = 0; i < (1U << tx_ring_order); i++) {
+			char ring_ref_name[sizeof("tx-ring-ref") + 2];
+
+			snprintf(ring_ref_name, sizeof(ring_ref_name),
+				 "tx-ring-ref%u", i);
+
+			err = xenbus_scanf(XBT_NIL, dev->otherend,
+					   ring_ref_name, "%lu",
+					   &tx_ring_ref[i]);
+			if (err < 0) {
+				xenbus_dev_fatal(dev, err,
+						 "reading %s/%s",
+						 dev->otherend,
+						 ring_ref_name);
+				return err;
+			}
+		}
+	}
+
+	err = xenbus_scanf(XBT_NIL, dev->otherend, "rx-ring-order", "%u",
+			   &rx_ring_order);
+	if (err < 0) {
+		rx_ring_order = 0;
+		err = xenbus_scanf(XBT_NIL, dev->otherend, "rx-ring-ref", "%lu",
+				   &rx_ring_ref[0]);
+		if (err < 0) {
+			xenbus_dev_fatal(dev, err, "reading %s/rx-ring-ref",
+					 dev->otherend);
+			return err;
+		}
+	} else {
+		unsigned int i;
+
+		if (rx_ring_order > MODPARM_netback_max_rx_ring_page_order) {
+			err = -EINVAL;
+
+			xenbus_dev_fatal(dev, err,
+					 "%s/rx-ring-page-order too big",
+					 dev->otherend);
+			return err;
+		}
+
+		for (i = 0; i < (1U << rx_ring_order); i++) {
+			char ring_ref_name[sizeof("rx-ring-ref") + 2];
+
+			snprintf(ring_ref_name, sizeof(ring_ref_name),
+				 "rx-ring-ref%u", i);
+
+			err = xenbus_scanf(XBT_NIL, dev->otherend,
+					   ring_ref_name, "%lu",
+					   &rx_ring_ref[i]);
+			if (err < 0) {
+				xenbus_dev_fatal(dev, err,
+						 "reading %s/%s",
+						 dev->otherend,
+						 ring_ref_name);
+				return err;
+			}
+		}
+	}
+
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
 			   &rx_copy);
 	if (err == -ENOENT) {
@@ -453,11 +556,23 @@ static int connect_rings(struct backend_info *be)
 	vif->csum = !val;
 
 	/* Map the shared frame, irq etc. */
-	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
+	err = xenvif_connect(vif,
+			     tx_ring_ref, (1U << tx_ring_order),
+			     rx_ring_ref, (1U << rx_ring_order),
+			     evtchn);
 	if (err) {
+		int i;
 		xenbus_dev_fatal(dev, err,
-				 "mapping shared-frames %lu/%lu port %u",
-				 tx_ring_ref, rx_ring_ref, evtchn);
+				 "binding port %u",
+				 evtchn);
+		for (i = 0; i < (1U << tx_ring_order); i++)
+			xenbus_dev_fatal(dev, err,
+					 "mapping tx ring handle: %lu",
+					 tx_ring_ref[i]);
+		for (i = 0; i < (1U << rx_ring_order); i++)
+			xenbus_dev_fatal(dev, err,
+					 "mapping rx ring handle: %lu",
+					 tx_ring_ref[i]);
 		return err;
 	}
 	return 0;
-- 
1.7.2.5
