From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 12/16] netback: multi-page ring support
Date: Mon, 30 Jan 2012 14:45:30 +0000
Message-ID: <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45960 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab2A3Opt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:49 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend netback to support multi-page ring.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   44 ++++++++++---
 drivers/net/xen-netback/interface.c |   33 +++++++--
 drivers/net/xen-netback/netback.c   |  116 +++++++++++++++++++++----------
 drivers/net/xen-netback/xenbus.c    |  129 +++++++++++++++++++++++++++++++++--
 4 files changed, 262 insertions(+), 60 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 28121f1..3cf9b8f 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -58,16 +58,36 @@ struct xenvif_rx_meta {
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define NETBK_TX_RING_SIZE(_nr_pages)					\
+	(__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages)))
+#define NETBK_RX_RING_SIZE(_nr_pages)					\
+	(__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages)))
 
-#define MAX_PENDING_REQS 256
+#define NETBK_MAX_RING_PAGE_ORDER 2
+#define NETBK_MAX_RING_PAGES      (1U << NETBK_MAX_RING_PAGE_ORDER)
+
+#define NETBK_MAX_TX_RING_SIZE NETBK_TX_RING_SIZE(NETBK_MAX_RING_PAGES)
+#define NETBK_MAX_RX_RING_SIZE NETBK_RX_RING_SIZE(NETBK_MAX_RING_PAGES)
+
+#define INVALID_GRANT_HANDLE ((grant_handle_t)~0U)
+
+#define MAX_PENDING_REQS NETBK_MAX_TX_RING_SIZE
+
+struct xen_comms {
+	struct vm_struct *ring_area;
+	grant_handle_t    shmem_handle[NETBK_MAX_RING_PAGES];
+	unsigned int      nr_handles;
+};
 
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
 	unsigned int     handle;
 
+	/* Multi-page ring support */
+	struct xen_comms tx_comms;
+	struct xen_comms rx_comms;
+
 	/* Use NAPI for guest TX */
 	struct napi_struct napi;
 	/* Use kthread for guest RX */
@@ -131,8 +151,10 @@ struct xenvif *xenvif_alloc(struct device *parent,
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
@@ -145,10 +167,11 @@ int xenvif_rx_ring_full(struct xenvif *vif);
 int xenvif_must_stop_queue(struct xenvif *vif);
 
 /* (Un)Map communication rings. */
-void xenvif_unmap_frontend_rings(struct xenvif *vif);
-int xenvif_map_frontend_rings(struct xenvif *vif,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref);
+void xenvif_unmap_frontend_rings(struct xen_comms *comms);
+int xenvif_map_frontend_rings(struct xen_comms *comms,
+			      int domid,
+			      unsigned long ring_ref[],
+			      unsigned int  ring_ref_count);
 
 /* Check for SKBs from frontend and schedule backend processing */
 void xenvif_check_rx_xenvif(struct xenvif *vif);
@@ -166,4 +189,7 @@ void xenvif_rx_action(struct xenvif *vif);
 
 int xenvif_kthread(void *data);
 
+extern unsigned int MODPARM_netback_max_tx_ring_page_order;
+extern unsigned int MODPARM_netback_max_rx_ring_page_order;
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index a5de556..29f4fd9 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -322,10 +322,14 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
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
+	struct xen_netif_tx_sring *txs;
+	struct xen_netif_rx_sring *rxs;
 
 	/* Already connected through? */
 	if (vif->irq)
@@ -333,15 +337,25 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	__module_get(THIS_MODULE);
 
-	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
-	if (err < 0)
+	err = xenvif_map_frontend_rings(&vif->tx_comms, vif->domid,
+					tx_ring_ref, tx_ring_ref_count);
+	if (err)
 		goto err;
+	txs = (struct xen_netif_tx_sring *)vif->tx_comms.ring_area->addr;
+	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE * tx_ring_ref_count);
+
+	err = xenvif_map_frontend_rings(&vif->rx_comms, vif->domid,
+					rx_ring_ref, rx_ring_ref_count);
+	if (err)
+		goto err_tx_unmap;
+	rxs = (struct xen_netif_rx_sring *)vif->rx_comms.ring_area->addr;
+	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
 
 	err = bind_interdomain_evtchn_to_irqhandler(
 		vif->domid, evtchn, xenvif_interrupt, 0,
 		vif->dev->name, vif);
 	if (err < 0)
-		goto err_unmap;
+		goto err_rx_unmap;
 	vif->irq = err;
 	disable_irq(vif->irq);
 
@@ -369,8 +383,10 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	return 0;
 err_unbind:
 	unbind_from_irqhandler(vif->irq, vif);
-err_unmap:
-	xenvif_unmap_frontend_rings(vif);
+err_rx_unmap:
+	xenvif_unmap_frontend_rings(&vif->rx_comms);
+err_tx_unmap:
+	xenvif_unmap_frontend_rings(&vif->tx_comms);
 err:
 	module_put(THIS_MODULE);
 	return err;
@@ -403,7 +419,8 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	xenvif_unmap_frontend_rings(vif);
+	xenvif_unmap_frontend_rings(&vif->tx_comms);
+	xenvif_unmap_frontend_rings(&vif->rx_comms);
 
 	free_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index df63703..96f354c 100644
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
 
@@ -132,9 +143,11 @@ int xenvif_rx_ring_full(struct xenvif *vif)
 {
 	RING_IDX peek   = vif->rx_req_cons_peek;
 	RING_IDX needed = max_required_rx_slots(vif);
+	struct xen_comms *comms = &vif->rx_comms;
 
 	return ((vif->rx.sring->req_prod - peek) < needed) ||
-	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
+	       ((vif->rx.rsp_prod_pvt +
+		 NETBK_RX_RING_SIZE(comms->nr_handles) - peek) < needed);
 }
 
 int xenvif_must_stop_queue(struct xenvif *vif)
@@ -481,6 +494,7 @@ void xenvif_rx_action(struct xenvif *vif)
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
 	int need_to_notify = 0;
+	struct xen_comms *comms = &vif->rx_comms;
 
 	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
 	struct xenvif_rx_meta *m = get_cpu_var(meta);
@@ -515,7 +529,8 @@ void xenvif_rx_action(struct xenvif *vif)
 		__skb_queue_tail(&rxq, skb);
 
 		/* Filled the batch queue? */
-		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
+		if (count + MAX_SKB_FRAGS >=
+		    NETBK_RX_RING_SIZE(comms->nr_handles))
 			break;
 	}
 
@@ -527,7 +542,7 @@ void xenvif_rx_action(struct xenvif *vif)
 		return;
 	}
 
-	BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));
+	BUG_ON(npo.copy_prod > (2 * NETBK_MAX_RX_RING_SIZE));
 	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
 					npo.copy_prod);
 	BUG_ON(ret != 0);
@@ -1405,48 +1420,77 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
-void xenvif_unmap_frontend_rings(struct xenvif *vif)
+void xenvif_unmap_frontend_rings(struct xen_comms *comms)
 {
-	if (vif->tx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->tx.sring);
-	if (vif->rx.sring)
-		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
-					vif->rx.sring);
+	struct gnttab_unmap_grant_ref op[NETBK_MAX_RING_PAGES];
+	unsigned int i;
+	unsigned int j;
+
+	if (!comms->ring_area)
+		return;
+
+	j = 0;
+	for (i = 0; i < comms->nr_handles; i++) {
+		unsigned long addr = (unsigned long)comms->ring_area->addr +
+			(i * PAGE_SIZE);
+
+		if (comms->shmem_handle[i] != INVALID_GRANT_HANDLE) {
+			gnttab_set_unmap_op(&op[j++], addr,
+					    GNTMAP_host_map,
+					    comms->shmem_handle[i]);
+			comms->shmem_handle[i] = INVALID_GRANT_HANDLE;
+		}
+	}
+
+	comms->nr_handles = 0;
+
+	if (j != 0) {
+		if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref,
+					      op, j))
+			BUG();
+	}
+
+	free_vm_area(comms->ring_area);
 }
 
-int xenvif_map_frontend_rings(struct xenvif *vif,
-			      grant_ref_t tx_ring_ref,
-			      grant_ref_t rx_ring_ref)
+int xenvif_map_frontend_rings(struct xen_comms *comms,
+			      int domid,
+			      unsigned long ring_ref[],
+			      unsigned int  ring_ref_count)
 {
-	void *addr;
-	struct xen_netif_tx_sring *txs;
-	struct xen_netif_rx_sring *rxs;
-
-	int err = -ENOMEM;
+	struct gnttab_map_grant_ref op[NETBK_MAX_RING_PAGES];
+	unsigned int i;
+	int err = 0;
 
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-				     tx_ring_ref, &addr);
-	if (err)
-		goto err;
+	comms->ring_area = alloc_vm_area(PAGE_SIZE * ring_ref_count, NULL);
+	if (comms->ring_area == NULL)
+		return -ENOMEM;
 
-	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
+	for (i = 0; i < ring_ref_count; i++) {
+		unsigned long addr = (unsigned long)comms->ring_area->addr +
+			(i * PAGE_SIZE);
+		gnttab_set_map_op(&op[i], addr, GNTMAP_host_map,
+				  ring_ref[i], domid);
+	}
 
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-				     rx_ring_ref, &addr);
-	if (err)
-		goto err;
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref,
+				      &op, ring_ref_count))
+		BUG();
 
-	rxs = (struct xen_netif_rx_sring *)addr;
-	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
+	comms->nr_handles = ring_ref_count;
 
-	vif->rx_req_cons_peek = 0;
+	for (i = 0; i < ring_ref_count; i++) {
+		if (op[i].status != 0) {
+			err = op[i].status;
+			comms->shmem_handle[i] = INVALID_GRANT_HANDLE;
+			continue;
+		}
+		comms->shmem_handle[i] = op[i].handle;
+	}
 
-	return 0;
+	if (err != 0)
+		xenvif_unmap_frontend_rings(comms);
 
-err:
-	xenvif_unmap_frontend_rings(vif);
 	return err;
 }
 
@@ -1477,10 +1521,10 @@ static int __create_percpu_scratch_space(unsigned int cpu)
 
 	per_cpu(grant_copy_op, cpu) =
 		vzalloc(sizeof(struct gnttab_copy)
-			* 2 * XEN_NETIF_RX_RING_SIZE);
+			* 2 * NETBK_MAX_RX_RING_SIZE);
 
 	per_cpu(meta, cpu) = vzalloc(sizeof(struct xenvif_rx_meta)
-				     * 2 * XEN_NETIF_RX_RING_SIZE);
+				     * 2 * NETBK_MAX_RX_RING_SIZE);
 
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
