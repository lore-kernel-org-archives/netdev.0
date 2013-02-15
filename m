From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 5/8] netback: multi-page ring support
Date: Fri, 15 Feb 2013 16:00:06 +0000
Message-ID: <1360944010-15336-6-git-send-email-wei.liu2@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27169 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935826Ab3BOQAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 11:00:55 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   30 ++++++--
 drivers/net/xen-netback/interface.c |   46 +++++++++--
 drivers/net/xen-netback/netback.c   |   73 ++++++++----------
 drivers/net/xen-netback/xenbus.c    |  143 +++++++++++++++++++++++++++++++++--
 4 files changed, 229 insertions(+), 63 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 35d8772..f541ba9 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,6 +45,12 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
+#define NETBK_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
+#define NETBK_MAX_RING_PAGES      (1U << NETBK_MAX_RING_PAGE_ORDER)
+
+#define NETBK_MAX_TX_RING_SIZE XEN_NETIF_TX_RING_SIZE(NETBK_MAX_RING_PAGES)
+#define NETBK_MAX_RX_RING_SIZE XEN_NETIF_RX_RING_SIZE(NETBK_MAX_RING_PAGES)
+
 struct xen_netbk;
 
 struct xenvif {
@@ -66,6 +72,8 @@ struct xenvif {
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
 	struct xen_netif_rx_back_ring rx;
+	unsigned int nr_tx_handles;
+	unsigned int nr_rx_handles;
 
 	/* Frontend feature information. */
 	u8 can_sg:1;
@@ -105,15 +113,19 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
 	return to_xenbus_device(vif->dev->dev.parent);
 }
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define XEN_NETIF_TX_RING_SIZE(_nr_pages)		\
+	__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages))
+#define XEN_NETIF_RX_RING_SIZE(_nr_pages)		\
+	__CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages))
 
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn);
+int xenvif_connect(struct xenvif *vif,
+		   unsigned long *tx_ring_ref, unsigned int tx_ring_order,
+		   unsigned long *rx_ring_ref, unsigned int rx_ring_order,
+		   unsigned int evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
 void xenvif_get(struct xenvif *vif);
@@ -129,10 +141,12 @@ int xen_netbk_rx_ring_full(struct xenvif *vif);
 int xen_netbk_must_stop_queue(struct xenvif *vif);
 
 /* (Un)Map communication rings. */
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
+void xen_netbk_unmap_frontend_rings(struct xenvif *vif, void *addr);
 int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref);
+				 void **addr,
+				 int domid,
+				 int *ring_ref,
+				 unsigned int ring_ref_count);
 
 /* (De)Register a xenvif with the netback backend. */
 void xen_netbk_add_xenvif(struct xenvif *vif);
@@ -158,4 +172,6 @@ void xenvif_carrier_off(struct xenvif *vif);
 /* Returns number of ring slots required to send an skb to the frontend */
 unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
 
+extern unsigned int MODPARM_netback_max_tx_ring_page_order;
+extern unsigned int MODPARM_netback_max_rx_ring_page_order;
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index db638e1..fa4d46d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -305,10 +305,16 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	return vif;
 }
 
-int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn)
+int xenvif_connect(struct xenvif *vif,
+		   unsigned long *tx_ring_ref, unsigned int tx_ring_ref_count,
+		   unsigned long *rx_ring_ref, unsigned int rx_ring_ref_count,
+		   unsigned int evtchn)
 {
 	int err = -ENOMEM;
+	void *addr;
+	struct xen_netif_tx_sring *txs;
+	struct xen_netif_rx_sring *rxs;
+	int tmp[NETBK_MAX_RING_PAGES], i;
 
 	/* Already connected through? */
 	if (vif->irq)
@@ -316,15 +322,36 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 
 	__module_get(THIS_MODULE);
 
-	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
+	for (i = 0; i < tx_ring_ref_count; i++)
+		tmp[i] = tx_ring_ref[i];
+
+	err = xen_netbk_map_frontend_rings(vif, &addr, vif->domid,
+					   tmp, tx_ring_ref_count);
 	if (err < 0)
 		goto err;
 
+	txs = addr;
+	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE * tx_ring_ref_count);
+	vif->nr_tx_handles = tx_ring_ref_count;
+
+	for (i = 0; i < rx_ring_ref_count; i++)
+		tmp[i] = rx_ring_ref[i];
+
+	err = xen_netbk_map_frontend_rings(vif, &addr, vif->domid,
+					   tmp, rx_ring_ref_count);
+
+	if (err < 0)
+		goto err_tx_unmap;
+
+	rxs = addr;
+	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE * rx_ring_ref_count);
+	vif->nr_rx_handles = rx_ring_ref_count;
+
 	err = bind_interdomain_evtchn_to_irqhandler(
 		vif->domid, evtchn, xenvif_interrupt, 0,
 		vif->dev->name, vif);
 	if (err < 0)
-		goto err_unmap;
+		goto err_rx_unmap;
 	vif->irq = err;
 	disable_irq(vif->irq);
 
@@ -340,8 +367,12 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	rtnl_unlock();
 
 	return 0;
-err_unmap:
-	xen_netbk_unmap_frontend_rings(vif);
+err_rx_unmap:
+	xen_netbk_unmap_frontend_rings(vif, (void *)vif->rx.sring);
+	vif->nr_rx_handles = 0;
+err_tx_unmap:
+	xen_netbk_unmap_frontend_rings(vif, (void *)vif->tx.sring);
+	vif->nr_tx_handles = 0;
 err:
 	module_put(THIS_MODULE);
 	return err;
@@ -382,7 +413,8 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	xen_netbk_unmap_frontend_rings(vif);
+	xen_netbk_unmap_frontend_rings(vif, (void *)vif->tx.sring);
+	xen_netbk_unmap_frontend_rings(vif, (void *)vif->rx.sring);
 
 	free_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 98ccea9..644c760 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -47,6 +47,19 @@
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
+
+
 struct pending_tx_info {
 	struct xen_netif_tx_request req;
 	struct xenvif *vif;
@@ -59,7 +72,7 @@ struct netbk_rx_meta {
 	int gso_size;
 };
 
-#define MAX_PENDING_REQS 256
+#define MAX_PENDING_REQS NETBK_MAX_TX_RING_SIZE
 
 /* Discriminate from any valid pending_idx value. */
 #define INVALID_PENDING_IDX 0xFFFF
@@ -111,8 +124,8 @@ struct xen_netbk {
 	 * head/fragment page uses 2 copy operations because it
 	 * straddles two buffers in the frontend.
 	 */
-	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
-	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
+	struct gnttab_copy grant_copy_op[2*NETBK_MAX_RX_RING_SIZE];
+	struct netbk_rx_meta meta[2*NETBK_MAX_RX_RING_SIZE];
 };
 
 static struct xen_netbk *xen_netbk;
@@ -262,7 +275,8 @@ int xen_netbk_rx_ring_full(struct xenvif *vif)
 	RING_IDX needed = max_required_rx_slots(vif);
 
 	return ((vif->rx.sring->req_prod - peek) < needed) ||
-	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < needed);
+	       ((vif->rx.rsp_prod_pvt +
+		 XEN_NETIF_RX_RING_SIZE(vif->nr_rx_handles) - peek) < needed);
 }
 
 int xen_netbk_must_stop_queue(struct xenvif *vif)
@@ -657,7 +671,8 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		__skb_queue_tail(&rxq, skb);
 
 		/* Filled the batch queue? */
-		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
+		if (count + MAX_SKB_FRAGS >=
+		    XEN_NETIF_RX_RING_SIZE(vif->nr_rx_handles))
 			break;
 	}
 
@@ -1292,12 +1307,12 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 			continue;
 
 		if (vif->tx.sring->req_prod - vif->tx.req_cons >
-		    XEN_NETIF_TX_RING_SIZE) {
+		    XEN_NETIF_TX_RING_SIZE(vif->nr_tx_handles)) {
 			netdev_err(vif->dev,
 				   "Impossible number of requests. "
 				   "req_prod %d, req_cons %d, size %ld\n",
 				   vif->tx.sring->req_prod, vif->tx.req_cons,
-				   XEN_NETIF_TX_RING_SIZE);
+				   XEN_NETIF_TX_RING_SIZE(vif->nr_tx_handles));
 			netbk_fatal_tx_err(vif);
 			continue;
 		}
@@ -1644,48 +1659,22 @@ static int xen_netbk_kthread(void *data)
 	return 0;
 }
 
-void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
+void xen_netbk_unmap_frontend_rings(struct xenvif *vif, void *addr)
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
 
 int xen_netbk_map_frontend_rings(struct xenvif *vif,
-				 grant_ref_t tx_ring_ref,
-				 grant_ref_t rx_ring_ref)
+				 void **vaddr,
+				 int domid,
+				 int *ring_ref,
+				 unsigned int ring_ref_count)
 {
-	void *addr;
-	struct xen_netif_tx_sring *txs;
-	struct xen_netif_rx_sring *rxs;
-
-	int err = -ENOMEM;
-
-	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
-				     &tx_ring_ref, 1, &addr);
-	if (err)
-		goto err;
-
-	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
+	int err = 0;
 
 	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
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
-	xen_netbk_unmap_frontend_rings(vif);
+				     ring_ref, ring_ref_count, vaddr);
 	return err;
 }
 
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 65d14f2..1791807 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -114,6 +114,33 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		/* Multi-page ring support */
+		if (MODPARM_netback_max_tx_ring_page_order >
+		    NETBK_MAX_RING_PAGE_ORDER)
+			MODPARM_netback_max_tx_ring_page_order =
+				NETBK_MAX_RING_PAGE_ORDER;
+		err = xenbus_printf(xbt, dev->nodename,
+				    "max-tx-ring-page-order",
+				    "%u",
+				    MODPARM_netback_max_tx_ring_page_order);
+		if (err) {
+			message = "writing max-tx-ring-page-order";
+			goto abort_transaction;
+		}
+
+		if (MODPARM_netback_max_rx_ring_page_order >
+		    NETBK_MAX_RING_PAGE_ORDER)
+			MODPARM_netback_max_rx_ring_page_order =
+				NETBK_MAX_RING_PAGE_ORDER;
+		err = xenbus_printf(xbt, dev->nodename,
+				    "max-rx-ring-page-order",
+				    "%u",
+				    MODPARM_netback_max_rx_ring_page_order);
+		if (err) {
+			message = "writing max-rx-ring-page-order";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -392,22 +419,107 @@ static int connect_rings(struct backend_info *be)
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
+
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
@@ -454,11 +566,28 @@ static int connect_rings(struct backend_info *be)
 	vif->csum = !val;
 
 	/* Map the shared frame, irq etc. */
-	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
+	err = xenvif_connect(vif, tx_ring_ref, (1U << tx_ring_order),
+			     rx_ring_ref, (1U << rx_ring_order),
+			     evtchn);
 	if (err) {
+		/* construct 1 2 3 / 4 5 6 */
+		int i;
+		char txs[3 * (1U << MODPARM_netback_max_tx_ring_page_order)];
+		char rxs[3 * (1U << MODPARM_netback_max_rx_ring_page_order)];
+
+		txs[0] = rxs[0] = 0;
+
+		for (i = 0; i < (1U << tx_ring_order); i++)
+			snprintf(txs+strlen(txs), sizeof(txs)-strlen(txs)-1,
+				 " %lu", tx_ring_ref[i]);
+
+		for (i = 0; i < (1U << rx_ring_order); i++)
+			snprintf(rxs+strlen(rxs), sizeof(rxs)-strlen(rxs)-1,
+				 " %lu", rx_ring_ref[i]);
+
 		xenbus_dev_fatal(dev, err,
-				 "mapping shared-frames %lu/%lu port %u",
-				 tx_ring_ref, rx_ring_ref, evtchn);
+				 "mapping shared-frames%s /%s port %u",
+				 txs, rxs, evtchn);
 		return err;
 	}
 	return 0;
-- 
1.7.10.4
