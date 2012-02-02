From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 05/13] netback: switch to per-cpu scratch
	space.
Date: Thu, 2 Feb 2012 16:49:15 +0000
Message-ID: <1328201363-13915-6-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	konrad.wilk@oracle.com
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

In the 1:1 model, given that there are maximum nr_online_cpus netbacks
running, we can use per-cpu scratch space, thus shrinking size of
struct xen_netbk.

Changes in V4:

Carefully guard against CPU hotplug race condition. NAPI and kthread
will bail when scratch spaces are not available.

Scratch space allocation is NUMA awared.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |   15 ++
 drivers/net/xen-netback/netback.c |  261 ++++++++++++++++++++++++++++++-------
 2 files changed, 229 insertions(+), 47 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 1e4d462..65df480 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,6 +45,21 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
+#define DRV_NAME "netback: "
+
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
index 8e4c9a9..5584853 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1,3 +1,4 @@
+
 /*
  * Back-end of the driver for virtual network devices. This portion of the
  * driver exports a 'unified' network-device interface that can be accessed
@@ -38,6 +39,7 @@
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
 #include <linux/udp.h>
+#include <linux/cpu.h>
 
 #include <net/tcp.h>
 
@@ -47,18 +49,17 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
-struct netbk_rx_meta {
-	int id;
-	int size;
-	int gso_size;
-};
 
-#define MAX_PENDING_REQS 256
+DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
 
-/* Discriminate from any valid pending_idx value. */
-#define INVALID_PENDING_IDX 0xFFFF
+/*
+ * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
+ * head/fragment page uses 2 copy operations because it
+ * straddles two buffers in the frontend.
+ */
+DEFINE_PER_CPU(struct gnttab_copy *, grant_copy_op);
+DEFINE_PER_CPU(struct netbk_rx_meta *, meta);
 
-#define MAX_BUFFER_OFFSET PAGE_SIZE
 
 struct xen_netbk {
 	struct sk_buff_head rx_queue;
@@ -71,17 +72,7 @@ struct xen_netbk {
 
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
@@ -508,12 +499,29 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 	unsigned long offset;
 	struct skb_cb_overlay *sco;
 	int need_to_notify = 0;
+	static int unusable_count;
+
+	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
+	struct netbk_rx_meta *m = get_cpu_var(meta);
 
 	struct netrx_pending_operations npo = {
-		.copy  = netbk->grant_copy_op,
-		.meta  = netbk->meta,
+		.copy  = gco,
+		.meta  = m,
 	};
 
+	if (gco == NULL || m == NULL) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
+		if (unusable_count == 1000) {
+			pr_alert("CPU %x scratch space is not usable,"
+				 " not doing any TX work for vif%u.%u\n",
+				 smp_processor_id(),
+				 netbk->vif->domid, netbk->vif->handle);
+			unusable_count = 0;
+		}
+		return;
+	}
+
 	skb_queue_head_init(&rxq);
 
 	count = 0;
@@ -534,13 +542,16 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 			break;
 	}
 
-	BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
+	BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
 
-	if (!npo.copy_prod)
+	if (!npo.copy_prod) {
+		put_cpu_var(grant_copy_op);
+		put_cpu_var(meta);
 		return;
+	}
 
-	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
+	BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, gco,
 					npo.copy_prod);
 	BUG_ON(ret != 0);
 
@@ -549,14 +560,14 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
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
@@ -581,12 +592,12 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
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
@@ -594,7 +605,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.size = netbk->meta[npo.meta_cons].gso_size;
+			gso->u.gso.size = m[npo.meta_cons].gso_size;
 			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
@@ -604,7 +615,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 		}
 
 		netbk_add_frag_responses(vif, status,
-					 netbk->meta + npo.meta_cons + 1,
+					 m + npo.meta_cons + 1,
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
@@ -622,6 +633,9 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 	if (!skb_queue_empty(&netbk->rx_queue))
 		xen_netbk_kick_thread(netbk);
+
+	put_cpu_var(grant_copy_op);
+	put_cpu_var(meta);
 }
 
 void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
@@ -1052,9 +1066,10 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
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
@@ -1213,18 +1228,18 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 
 		vif->tx.req_cons = idx;
 
-		if ((gop-netbk->tx_copy_ops) >= ARRAY_SIZE(netbk->tx_copy_ops))
+		if ((gop - tco) >= MAX_PENDING_REQS)
 			break;
 	}
 
-	return gop - netbk->tx_copy_ops;
+	return gop - tco;
 }
 
 static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 				struct gnttab_copy *tco,
 				int budget)
 {
-	struct gnttab_copy *gop = netbk->tx_copy_ops;
+	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
 	struct xenvif *vif = netbk->vif;
 	int work_done = 0;
@@ -1309,20 +1324,42 @@ int xen_netbk_tx_action(struct xen_netbk *netbk, int budget)
 	unsigned nr_gops;
 	int ret;
 	int work_done;
+	struct gnttab_copy *tco;
+	static int unusable_count;
 
 	if (unlikely(!tx_work_todo(netbk)))
 		return 0;
 
-	nr_gops = xen_netbk_tx_build_gops(netbk);
+	tco = get_cpu_var(tx_copy_ops);
+
+	if (tco == NULL) {
+		put_cpu_var(tx_copy_ops);
+		unusable_count++;
+		if (unusable_count == 1000) {
+			pr_alert("CPU %x scratch space"
+				 " is not usable,"
+				 " not doing any RX work for vif%u.%u\n",
+				 smp_processor_id(),
+				 netbk->vif->domid, netbk->vif->handle);
+			unusable_count = 0;
+		}
+		return -ENOMEM;
+	}
+
+	nr_gops = xen_netbk_tx_build_gops(netbk, tco);
 
-	if (nr_gops == 0)
+	if (nr_gops == 0) {
+		put_cpu_var(tx_copy_ops);
 		return 0;
+	}
 
 	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
-					netbk->tx_copy_ops, nr_gops);
+					tco, nr_gops);
 	BUG_ON(ret);
 
-	work_done = xen_netbk_tx_submit(netbk, netbk->tx_copy_ops, budget);
+	work_done = xen_netbk_tx_submit(netbk, tco, budget);
+
+	put_cpu_var(tx_copy_ops);
 
 	return work_done;
 }
@@ -1461,7 +1498,7 @@ struct xen_netbk *xen_netbk_alloc_netbk(struct xenvif *vif)
 
 	netbk = vzalloc(sizeof(struct xen_netbk));
 	if (!netbk) {
-		printk(KERN_ALERT "%s: out of memory\n", __func__);
+		pr_alert(DRV_NAME "%s: out of memory\n", __func__);
 		return NULL;
 	}
 
@@ -1507,31 +1544,161 @@ int xen_netbk_kthread(void *data)
 	return 0;
 }
 
+static int __create_percpu_scratch_space(unsigned int cpu)
+{
+	/* Guard against race condition */
+	if (per_cpu(tx_copy_ops, cpu) ||
+	    per_cpu(grant_copy_op, cpu) ||
+	    per_cpu(meta, cpu))
+		return 0;
+
+	per_cpu(tx_copy_ops, cpu) =
+		vzalloc_node(sizeof(struct gnttab_copy) * MAX_PENDING_REQS,
+			     cpu_to_node(cpu));
+
+	if (!per_cpu(tx_copy_ops, cpu))
+		per_cpu(tx_copy_ops, cpu) = vzalloc(sizeof(struct gnttab_copy)
+						    * MAX_PENDING_REQS);
+
+	per_cpu(grant_copy_op, cpu) =
+		vzalloc_node(sizeof(struct gnttab_copy)
+			     * 2 * XEN_NETIF_RX_RING_SIZE, cpu_to_node(cpu));
+
+	if (!per_cpu(grant_copy_op, cpu))
+		per_cpu(grant_copy_op, cpu) =
+			vzalloc(sizeof(struct gnttab_copy)
+				* 2 * XEN_NETIF_RX_RING_SIZE);
+
+
+	per_cpu(meta, cpu) = vzalloc_node(sizeof(struct xenvif_rx_meta)
+					  * 2 * XEN_NETIF_RX_RING_SIZE,
+					  cpu_to_node(cpu));
+	if (!per_cpu(meta, cpu))
+		per_cpu(meta, cpu) = vzalloc(sizeof(struct xenvif_rx_meta)
+					     * 2 * XEN_NETIF_RX_RING_SIZE);
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
+	/* freeing NULL pointer is legit */
+	/* carefully work around race condition */
+	void *tmp;
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
+		pr_info("CPU %x online, creating scratch space\n", cpu);
+		rc = __create_percpu_scratch_space(cpu);
+		if (rc) {
+			pr_alert("failed to create scratch space"
+				 " for CPU %x\n", cpu);
+			/* FIXME: nothing more we can do here, we will
+			 * print out warning message when thread or
+			 * NAPI runs on this cpu. Also stop getting
+			 * called in the future.
+			 */
+			__free_percpu_scratch_space(cpu);
+			rc = NOTIFY_BAD;
+		} else {
+			rc = NOTIFY_OK;
+		}
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		pr_info("CPU %x offline, destroying scratch space\n",
+			cpu);
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
 
 static int __init netback_init(void)
 {
-	int rc = 0;
+	int rc = -ENOMEM;
+	int cpu;
 
 	if (!xen_domain())
 		return -ENODEV;
 
+	/* Don't need to disable preempt here, since nobody else will
+	 * touch these percpu areas during start up. */
+	for_each_online_cpu(cpu) {
+		rc = __create_percpu_scratch_space(cpu);
+
+		if (rc)
+			goto failed_init;
+	}
+
+	register_hotcpu_notifier(&netback_notifier_block);
+
 	rc = page_pool_init();
 	if (rc)
-		goto failed_init;
+		goto failed_init_pool;
 
-	return xenvif_xenbus_init();
+	rc = xenvif_xenbus_init();
+	if (rc)
+		goto failed_init_xenbus;
 
-failed_init:
 	return rc;
 
+failed_init_xenbus:
+	page_pool_destroy();
+failed_init_pool:
+	unregister_hotcpu_notifier(&netback_notifier_block);
+failed_init:
+	for_each_online_cpu(cpu)
+		__free_percpu_scratch_space(cpu);
+	return rc;
 }
 
 module_init(netback_init);
 
 static void __exit netback_exit(void)
 {
+	int cpu;
+
 	xenvif_xenbus_exit();
 	page_pool_destroy();
+
+	unregister_hotcpu_notifier(&netback_notifier_block);
+
+	/* Since we're here, nobody else will touch per-cpu area. */
+	for_each_online_cpu(cpu)
+		__free_percpu_scratch_space(cpu);
 }
 module_exit(netback_exit);
 
-- 
1.7.2.5
