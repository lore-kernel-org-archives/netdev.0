From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 04/16] netback: switch to per-cpu scratch space.
Date: Mon, 30 Jan 2012 14:45:22 +0000
Message-ID: <1327934734-8908-5-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32427 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272Ab2A3Opi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 09:45:38 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the 1:1 model, given that there are maximum nr_online_cpus netbacks
running, we can use per-cpu scratch space, thus shrinking size of
struct xen_netbk.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |   13 ++++
 drivers/net/xen-netback/netback.c |  134 ++++++++++++++++++++++++-------------
 2 files changed, 100 insertions(+), 47 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 31c331c..3b85563 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,6 +45,19 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
+struct netbk_rx_meta {
+	int id;
+	int size;
+	int gso_size;
+};
+
+#define MAX_PENDING_REQS 256
+
+/* Discriminate from any valid pending_idx value. */
+#define INVALID_PENDING_IDX 0xFFFF
+
+#define MAX_BUFFER_OFFSET PAGE_SIZE
+
 struct pending_tx_info {
 	struct xen_netif_tx_request req;
 };
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9a72993..1c68afb 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1,3 +1,4 @@
+
 /*
  * Back-end of the driver for virtual network devices. This portion of the
  * driver exports a 'unified' network-device interface that can be accessed
@@ -47,18 +48,17 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
-struct netbk_rx_meta {
-	int id;
-	int size;
-	int gso_size;
-};
 
-#define MAX_PENDING_REQS 256
+struct gnttab_copy *tx_copy_ops;
 
-/* Discriminate from any valid pending_idx value. */
-#define INVALID_PENDING_IDX 0xFFFF
+/*
+ * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
+ * head/fragment page uses 2 copy operations because it
+ * straddles two buffers in the frontend.
+ */
+struct gnttab_copy *grant_copy_op;
+struct netbk_rx_meta *meta;
 
-#define MAX_BUFFER_OFFSET PAGE_SIZE
 
 struct xen_netbk {
 	struct sk_buff_head rx_queue;
@@ -71,17 +71,7 @@ struct xen_netbk {
 
 	struct xenvif *vif;
 
-	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
-
 	u16 pending_ring[MAX_PENDING_REQS];
-
-	/*
-	 * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
-	 * head/fragment page uses 2 copy operations because it
-	 * straddles two buffers in the frontend.
-	 */
-	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
-	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
 };
 
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx);
@@ -509,9 +499,12 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 	struct skb_cb_overlay *sco;
 	int need_to_notify = 0;
 
+	struct gnttab_copy *gco = get_cpu_ptr(grant_copy_op);
+	struct netbk_rx_meta *m = get_cpu_ptr(meta);
+
 	struct netrx_pending_operations npo = {
-		.copy  = netbk->grant_copy_op,
-		.meta  = netbk->meta,
+		.copy  = gco,
+		.meta  = m,
 	};
 
 	skb_queue_head_init(&rxq);
@@ -534,13 +527,16 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 			break;
 	}
 
-	BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
+	BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
 
-	if (!npo.copy_prod)
+	if (!npo.copy_prod) {
+		put_cpu_ptr(gco);
+		put_cpu_ptr(m);
 		return;
+	}
 
-	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
+	BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
 					npo.copy_prod);
 	BUG_ON(ret != 0);
 
@@ -549,14 +545,14 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 		vif = netdev_priv(skb->dev);
 
-		if (netbk->meta[npo.meta_cons].gso_size && vif->gso_prefix) {
+		if (m[npo.meta_cons].gso_size && vif->gso_prefix) {
 			resp = RING_GET_RESPONSE(&vif->rx,
 						vif->rx.rsp_prod_pvt++);
 
 			resp->flags = XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
 
-			resp->offset = netbk->meta[npo.meta_cons].gso_size;
-			resp->id = netbk->meta[npo.meta_cons].id;
+			resp->offset = m[npo.meta_cons].gso_size;
+			resp->id = m[npo.meta_cons].id;
 			resp->status = sco->meta_slots_used;
 
 			npo.meta_cons++;
@@ -581,12 +577,12 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 			flags |= XEN_NETRXF_data_validated;
 
 		offset = 0;
-		resp = make_rx_response(vif, netbk->meta[npo.meta_cons].id,
+		resp = make_rx_response(vif, m[npo.meta_cons].id,
 					status, offset,
-					netbk->meta[npo.meta_cons].size,
+					m[npo.meta_cons].size,
 					flags);
 
-		if (netbk->meta[npo.meta_cons].gso_size && !vif->gso_prefix) {
+		if (m[npo.meta_cons].gso_size && !vif->gso_prefix) {
 			struct xen_netif_extra_info *gso =
 				(struct xen_netif_extra_info *)
 				RING_GET_RESPONSE(&vif->rx,
@@ -594,7 +590,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.size = netbk->meta[npo.meta_cons].gso_size;
+			gso->u.gso.size = m[npo.meta_cons].gso_size;
 			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
@@ -604,7 +600,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 		}
 
 		netbk_add_frag_responses(vif, status,
-					 netbk->meta + npo.meta_cons + 1,
+					 m + npo.meta_cons + 1,
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
@@ -622,6 +618,9 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 	if (!skb_queue_empty(&netbk->rx_queue))
 		xen_netbk_kick_thread(netbk);
+
+	put_cpu_ptr(gco);
+	put_cpu_ptr(m);
 }
 
 void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
@@ -1053,9 +1052,10 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
+static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
+					struct gnttab_copy *tco)
 {
-	struct gnttab_copy *gop = netbk->tx_copy_ops, *request_gop;
+	struct gnttab_copy *gop = tco, *request_gop;
 	struct sk_buff *skb;
 	int ret;
 	struct xenvif *vif = netbk->vif;
@@ -1215,17 +1215,18 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		vif->tx.req_cons = idx;
 		xen_netbk_check_rx_xenvif(vif);
 
-		if ((gop-netbk->tx_copy_ops) >= ARRAY_SIZE(netbk->tx_copy_ops))
+		if ((gop - tco) >= MAX_PENDING_REQS)
 			break;
 	}
 
-	return gop - netbk->tx_copy_ops;
+	return gop - tco;
 }
 
 static void xen_netbk_tx_submit(struct xen_netbk *netbk,
+				struct gnttab_copy *tco,
 				int *work_done, int budget)
 {
-	struct gnttab_copy *gop = netbk->tx_copy_ops;
+	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
 	struct xenvif *vif = netbk->vif;
 
@@ -1306,19 +1307,25 @@ void xen_netbk_tx_action(struct xen_netbk *netbk, int *work_done, int budget)
 {
 	unsigned nr_gops;
 	int ret;
+	struct gnttab_copy *tco;
 
 	if (unlikely(!tx_work_todo(netbk)))
 		return;
 
-	nr_gops = xen_netbk_tx_build_gops(netbk);
+	tco = get_cpu_ptr(tx_copy_ops);
 
-	if (nr_gops == 0)
-		return;
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
-					netbk->tx_copy_ops, nr_gops);
+	nr_gops = xen_netbk_tx_build_gops(netbk, tco);
+
+	if (nr_gops == 0) {
+		put_cpu_ptr(tco);
+		return 0;
+	}
+
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, tco, nr_gops);
 	BUG_ON(ret);
 
-	xen_netbk_tx_submit(netbk, work_done, budget);
+	xen_netbk_tx_submit(netbk, tco, work_done, budget);
+	put_cpu_ptr(tco);
 }
 
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
@@ -1504,17 +1511,47 @@ int xen_netbk_kthread(void *data)
 
 static int __init netback_init(void)
 {
-	int rc = 0;
+	int rc = -ENOMEM;
 
 	if (!xen_domain())
 		return -ENODEV;
 
+	tx_copy_ops = __alloc_percpu(sizeof(struct gnttab_copy)
+				     * MAX_PENDING_REQS,
+				     __alignof__(struct gnttab_copy));
+	if (!tx_copy_ops)
+		goto failed_init;
+
+	grant_copy_op = __alloc_percpu(sizeof(struct gnttab_copy)
+				       * 2 * XEN_NETIF_RX_RING_SIZE,
+				       __alignof__(struct gnttab_copy));
+	if (!grant_copy_op)
+		goto failed_init_gco;
+
+	meta = __alloc_percpu(sizeof(struct netbk_rx_meta)
+			      * 2 * XEN_NETIF_RX_RING_SIZE,
+			      __alignof__(struct netbk_rx_meta));
+	if (!meta)
+		goto failed_init_meta;
+
 	rc = page_pool_init();
 	if (rc)
-		goto failed_init;
+		goto failed_init_pool;
+
+	rc = xenvif_xenbus_init();
+	if (rc)
+		goto failed_init_xenbus;
 
-	return xenvif_xenbus_init();
+	return rc;
 
+failed_init_xenbus:
+	page_pool_destroy();
+failed_init_pool:
+	free_percpu(meta);
+failed_init_meta:
+	free_percpu(grant_copy_op);
+failed_init_gco:
+	free_percpu(tx_copy_ops);
 failed_init:
 	return rc;
 
@@ -1526,6 +1563,9 @@ static void __exit netback_exit(void)
 {
 	xenvif_xenbus_exit();
 	page_pool_destroy();
+	free_percpu(meta);
+	free_percpu(grant_copy_op);
+	free_percpu(tx_copy_ops);
 }
 module_exit(netback_exit);
 
-- 
1.7.2.5
