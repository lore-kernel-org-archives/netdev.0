From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 2/3] xen-netback: switch to per-cpu scratch space
Date: Fri, 24 May 2013 11:32:32 +0100
Message-ID: <1369391553-16835-3-git-send-email-wei.liu2@citrix.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46452 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760412Ab3EXKcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 06:32:35 -0400
In-Reply-To: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are maximum nr_onlie_cpus netback threads running. We can make use of
per-cpu scratch space to reduce the size of buffer space when we move to 1:1
model.

In the unlikely event when per-cpu scratch space is not available, processing
routines will refuse to run on that CPU.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |  245 ++++++++++++++++++++++++++++++-------
 1 file changed, 203 insertions(+), 42 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 197f414..9bdc877 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -38,6 +38,7 @@
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
 #include <linux/udp.h>
+#include <linux/cpu.h>
 
 #include <net/tcp.h>
 
@@ -93,6 +94,24 @@ struct netbk_rx_meta {
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
+/* Coalescing tx requests before copying makes number of grant
+ * copy ops greater or equal to number of slots required. In
+ * worst case a tx request consumes 2 gnttab_copy. So the size
+ * of tx_copy_ops array should be 2*MAX_PENDING_REQS.
+ */
+#define TX_COPY_OPS_SIZE (2*MAX_PENDING_REQS)
+DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
+
+/* Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
+ * head/fragment page uses 2 copy operations because it
+ * straddles two buffers in the frontend. So the size of following
+ * arrays should be 2*XEN_NETIF_RX_RING_SIZE.
+ */
+#define GRANT_COPY_OP_SIZE (2*XEN_NETIF_RX_RING_SIZE)
+#define META_SIZE (2*XEN_NETIF_RX_RING_SIZE)
+DEFINE_PER_CPU(struct gnttab_copy *, grant_copy_op);
+DEFINE_PER_CPU(struct netbk_rx_meta *, meta);
+
 struct xen_netbk {
 	wait_queue_head_t wq;
 	struct task_struct *task;
@@ -114,21 +133,7 @@ struct xen_netbk {
 	atomic_t netfront_count;
 
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
-	/* Coalescing tx requests before copying makes number of grant
-	 * copy ops greater or equal to number of slots required. In
-	 * worst case a tx request consumes 2 gnttab_copy.
-	 */
-	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
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
 
 static struct xen_netbk *xen_netbk;
@@ -623,12 +628,31 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	int count;
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
+	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
+	struct netbk_rx_meta *m = get_cpu_var(meta);
+	static int unusable_count;
 
 	struct netrx_pending_operations npo = {
-		.copy  = netbk->grant_copy_op,
-		.meta  = netbk->meta,
+		.copy = gco,
+		.meta = m,
 	};
 
+	if (gco == NULL || m == NULL) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
+		if (unusable_count == 1000) {
+			printk(KERN_ALERT
+			       "xen-netback: "
+			       "CPU %d scratch space is not available,"
+			       " not doing any TX work for netback/%d\n",
+			       smp_processor_id(),
+			       (int)(netbk - xen_netbk));
+			unusable_count = 0;
+		} else
+			unusable_count++;
+		return;
+	}
+
 	skb_queue_head_init(&rxq);
 
 	count = 0;
@@ -650,27 +674,30 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 			break;
 	}
 
-	BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
+	BUG_ON(npo.meta_prod > META_SIZE);
 
-	if (!npo.copy_prod)
+	if (!npo.copy_prod) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
 		return;
+	}
 
-	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	gnttab_batch_copy(netbk->grant_copy_op, npo.copy_prod);
+	BUG_ON(npo.copy_prod > GRANT_COPY_OP_SIZE);
+	gnttab_batch_copy(gco, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
 		sco = (struct skb_cb_overlay *)skb->cb;
 
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
@@ -695,12 +722,12 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
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
@@ -708,7 +735,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.size = netbk->meta[npo.meta_cons].gso_size;
+			gso->u.gso.size = m[npo.meta_cons].gso_size;
 			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
@@ -718,7 +745,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		}
 
 		netbk_add_frag_responses(vif, status,
-					 netbk->meta + npo.meta_cons + 1,
+					 m + npo.meta_cons + 1,
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
@@ -741,6 +768,9 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	if (!skb_queue_empty(&netbk->rx_queue) &&
 			!timer_pending(&netbk->net_timer))
 		xen_netbk_kick_thread(netbk);
+
+	put_cpu_var(grant_copy_op);
+	put_cpu_var(meta);
 }
 
 void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
@@ -1369,9 +1399,10 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
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
 
@@ -1549,16 +1580,17 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		vif->tx.req_cons = idx;
 		xen_netbk_check_rx_xenvif(vif);
 
-		if ((gop-netbk->tx_copy_ops) >= ARRAY_SIZE(netbk->tx_copy_ops))
+		if ((gop-tco) >= TX_COPY_OPS_SIZE)
 			break;
 	}
 
-	return gop - netbk->tx_copy_ops;
+	return gop - tco;
 }
 
-static void xen_netbk_tx_submit(struct xen_netbk *netbk)
+static void xen_netbk_tx_submit(struct xen_netbk *netbk,
+				struct gnttab_copy *tco)
 {
-	struct gnttab_copy *gop = netbk->tx_copy_ops;
+	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
@@ -1633,15 +1665,37 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 static void xen_netbk_tx_action(struct xen_netbk *netbk)
 {
 	unsigned nr_gops;
+	struct gnttab_copy *tco;
+	static int unusable_count;
+
+	tco = get_cpu_var(tx_copy_ops);
+
+	if (tco == NULL) {
+		put_cpu_var(tx_copy_ops);
+		if (unusable_count == 1000) {
+			printk(KERN_ALERT
+			       "xen-netback: "
+			       "CPU %d scratch space is not available,"
+			       " not doing any RX work for netback/%d\n",
+			       smp_processor_id(),
+			       (int)(netbk - xen_netbk));
+		} else
+			unusable_count++;
+		return;
+	}
 
-	nr_gops = xen_netbk_tx_build_gops(netbk);
+	nr_gops = xen_netbk_tx_build_gops(netbk, tco);
 
-	if (nr_gops == 0)
+	if (nr_gops == 0) {
+		put_cpu_var(tx_copy_ops);
 		return;
+	}
 
-	gnttab_batch_copy(netbk->tx_copy_ops, nr_gops);
+	gnttab_batch_copy(tco, nr_gops);
 
-	xen_netbk_tx_submit(netbk);
+	xen_netbk_tx_submit(netbk, tco);
+
+	put_cpu_var(tx_copy_ops);
 }
 
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
@@ -1773,6 +1827,93 @@ static int xen_netbk_kthread(void *data)
 	return 0;
 }
 
+static int __create_percpu_scratch_space(unsigned int cpu)
+{
+	if (per_cpu(tx_copy_ops, cpu) ||
+	    per_cpu(grant_copy_op, cpu) ||
+	    per_cpu(meta, cpu))
+		return 0;
+
+	per_cpu(tx_copy_ops, cpu) =
+		vzalloc_node(sizeof(struct gnttab_copy) * TX_COPY_OPS_SIZE,
+			     cpu_to_node(cpu));
+
+	per_cpu(grant_copy_op, cpu) =
+		vzalloc_node(sizeof(struct gnttab_copy) * GRANT_COPY_OP_SIZE,
+			     cpu_to_node(cpu));
+
+	per_cpu(meta, cpu) =
+		vzalloc_node(sizeof(struct netbk_rx_meta) * META_SIZE,
+			     cpu_to_node(cpu));
+
+	if (!per_cpu(tx_copy_ops, cpu) ||
+	    !per_cpu(grant_copy_op, cpu) ||
+	    !per_cpu(meta, cpu))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __free_percpu_scratch_space(unsigned int cpu)
+{
+	void *tmp;
+
+	tmp = per_cpu(tx_copy_ops, cpu);
+	per_cpu(tx_copy_ops, cpu) = NULL;
+	vfree(tmp);
+
+	tmp = per_cpu(grant_copy_op, cpu);
+	per_cpu(grant_copy_op, cpu) = NULL;
+	vfree(tmp);
+
+	tmp = per_cpu(meta, cpu);
+	per_cpu(meta, cpu) = NULL;
+	vfree(tmp);
+}
+
+static int __netback_percpu_callback(struct notifier_block *nfb,
+				     unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+	int rc = NOTIFY_DONE;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		printk(KERN_INFO "xen-netback: CPU %d online, creating scratch space\n",
+		       cpu);
+		rc = __create_percpu_scratch_space(cpu);
+		if (rc) {
+			printk(KERN_ALERT "xen-netback: failed to create scratch space for CPU %d\n",
+			       cpu);
+			/* There is really nothing more we can do. Free any
+			 * partially allocated scratch space. When processing
+			 * routines get to run they will just print warning
+			 * message and stop processing.
+			 */
+			__free_percpu_scratch_space(cpu);
+			rc = NOTIFY_BAD;
+		} else
+			rc = NOTIFY_OK;
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		printk(KERN_INFO "xen-netback: CPU %d offline, destroying scratch space\n",
+		       cpu);
+		__free_percpu_scratch_space(cpu);
+		rc = NOTIFY_OK;
+		break;
+	default:
+		break;
+	}
+
+	return rc;
+}
+
+static struct notifier_block netback_notifier_block = {
+	.notifier_call = __netback_percpu_callback,
+};
+
 void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 {
 	if (vif->tx.sring)
@@ -1824,6 +1965,7 @@ static int __init netback_init(void)
 	int rc = 0;
 	int group;
 	unsigned int pool_size;
+	int cpu;
 
 	if (!xen_domain())
 		return -ENODEV;
@@ -1835,10 +1977,21 @@ static int __init netback_init(void)
 		fatal_skb_slots = XEN_NETBK_LEGACY_SLOTS_MAX;
 	}
 
+	for_each_online_cpu(cpu) {
+		rc = __create_percpu_scratch_space(cpu);
+		if (rc) {
+			rc = -ENOMEM;
+			goto failed_init;
+		}
+	}
+	register_hotcpu_notifier(&netback_notifier_block);
+
 	xen_netbk_group_nr = num_online_cpus();
 	xen_netbk = vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
-	if (!xen_netbk)
-		return -ENOMEM;
+	if (!xen_netbk) {
+		goto failed_init;
+		rc = -ENOMEM;
+	}
 
 	for (group = 0; group < xen_netbk_group_nr; group++) {
 		struct xen_netbk *netbk = &xen_netbk[group];
@@ -1880,7 +2033,7 @@ static int __init netback_init(void)
 	pool_size = num_online_cpus() * pool_entries_per_cpu;
 	rc = page_pool_init(pool_size);
 	if (rc)
-		goto failed_init;
+		goto failed_init_destroy_kthreads;
 
 	rc = xenvif_xenbus_init();
 	if (rc)
@@ -1890,13 +2043,16 @@ static int __init netback_init(void)
 
 failed_init_destroy_pool:
 	page_pool_destroy();
-failed_init:
+failed_init_destroy_kthreads:
 	while (--group >= 0) {
 		struct xen_netbk *netbk = &xen_netbk[group];
 		del_timer(&netbk->net_timer);
 		kthread_stop(netbk->task);
 	}
 	vfree(xen_netbk);
+failed_init:
+	for_each_online_cpu(cpu)
+		__free_percpu_scratch_space(cpu);
 	return rc;
 
 }
@@ -1918,6 +2074,11 @@ static void __exit netback_fini(void)
 	vfree(xen_netbk);
 
 	page_pool_destroy();
+
+	unregister_hotcpu_notifier(&netback_notifier_block);
+
+	for_each_online_cpu(i)
+		__free_percpu_scratch_space(i);
 }
 module_exit(netback_fini);
 
-- 
1.7.10.4
