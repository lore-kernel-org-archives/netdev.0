From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 10/11] qede: Add basic XDP support
Date: Tue, 29 Nov 2016 16:47:09 +0200
Message-ID: <1480430830-17671-11-git-send-email-Yuval.Mintz@cavium.com>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52308 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757880AbcK2Orm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:47:42 -0500
In-Reply-To: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the ndo_xdp callback. This patch would support XDP_PASS,
XDP_DROP and XDP_ABORTED commands.

This also adds a per Rx queue statistic which counts number of packets
which didn't reach the stack [due to XDP].

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |   9 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |   1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 120 +++++++++++++++++++++++-
 3 files changed, 127 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 21e8533..56ab446 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -16,6 +16,7 @@
 #include <linux/bitmap.h>
 #include <linux/kernel.h>
 #include <linux/mutex.h>
+#include <linux/bpf.h>
 #include <linux/io.h>
 #include <linux/qed/common_hsi.h>
 #include <linux/qed/eth_common.h>
@@ -187,6 +188,8 @@ struct qede_dev {
 	bool wol_enabled;
 
 	struct qede_rdma_dev		rdma_info;
+
+	struct bpf_prog *xdp_prog;
 };
 
 enum QEDE_STATE {
@@ -249,6 +252,8 @@ struct qede_rx_queue {
 	/* Required for the allocation of replacement buffers */
 	struct device *dev;
 
+	struct bpf_prog *xdp_prog;
+
 	u16 sw_rx_cons;
 	u16 sw_rx_prod;
 
@@ -271,6 +276,8 @@ struct qede_rx_queue {
 	u64 rx_alloc_errors;
 	u64 rx_ip_frags;
 
+	u64 xdp_no_pass;
+
 	void *handle;
 };
 
@@ -325,6 +332,7 @@ struct qede_fastpath {
 	struct qede_dev	*edev;
 #define QEDE_FASTPATH_TX	BIT(0)
 #define QEDE_FASTPATH_RX	BIT(1)
+#define QEDE_FASTPATH_XDP	BIT(2)
 #define QEDE_FASTPATH_COMBINED	(QEDE_FASTPATH_TX | QEDE_FASTPATH_RX)
 	u8			type;
 	u8			id;
@@ -358,6 +366,7 @@ struct qede_reload_args {
 	void (*func)(struct qede_dev *edev, struct qede_reload_args *args);
 	union {
 		netdev_features_t features;
+		struct bpf_prog *new_prog;
 		u16 mtu;
 	} u;
 };
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 60a2e58..6c70e29 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -32,6 +32,7 @@
 	QEDE_RQSTAT(rx_hw_errors),
 	QEDE_RQSTAT(rx_alloc_errors),
 	QEDE_RQSTAT(rx_ip_frags),
+	QEDE_RQSTAT(xdp_no_pass),
 };
 
 #define QEDE_NUM_RQSTATS ARRAY_SIZE(qede_rqstats_arr)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 15520bf..67e08c6 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1418,6 +1418,39 @@ static bool qede_pkt_is_ip_fragmented(struct eth_fast_path_rx_reg_cqe *cqe,
 	return false;
 }
 
+/* Return true iff packet is to be passed to stack */
+static bool qede_rx_xdp(struct qede_dev *edev,
+			struct qede_fastpath *fp,
+			struct qede_rx_queue *rxq,
+			struct bpf_prog *prog,
+			struct sw_rx_data *bd,
+			struct eth_fast_path_rx_reg_cqe *cqe)
+{
+	u16 len = le16_to_cpu(cqe->len_on_first_bd);
+	struct xdp_buff xdp;
+	enum xdp_action act;
+
+	xdp.data = page_address(bd->data) + cqe->placement_offset;
+	xdp.data_end = xdp.data + len;
+	act = bpf_prog_run_xdp(prog, &xdp);
+
+	if (act == XDP_PASS)
+		return true;
+
+	/* Count number of packets not to be passed to stack */
+	rxq->xdp_no_pass++;
+
+	switch (act) {
+	default:
+		bpf_warn_invalid_xdp_action(act);
+	case XDP_ABORTED:
+	case XDP_DROP:
+		qede_recycle_rx_bd_ring(rxq, cqe->bd_num);
+	}
+
+	return false;
+}
+
 static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 					    struct qede_rx_queue *rxq,
 					    struct sw_rx_data *bd, u16 len,
@@ -1560,6 +1593,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 			       struct qede_fastpath *fp,
 			       struct qede_rx_queue *rxq)
 {
+	struct bpf_prog *xdp_prog = READ_ONCE(rxq->xdp_prog);
 	struct eth_fast_path_rx_reg_cqe *fp_cqe;
 	u16 len, pad, bd_cons_idx, parse_flag;
 	enum eth_rx_cqe_type cqe_type;
@@ -1596,6 +1630,11 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	len = le16_to_cpu(fp_cqe->len_on_first_bd);
 	pad = fp_cqe->placement_offset;
 
+	/* Run eBPF program if one is attached */
+	if (xdp_prog)
+		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe))
+			return 1;
+
 	/* If this is an error packet then drop it */
 	flags = cqe->fast_path_regular.pars_flags.flags;
 	parse_flag = le16_to_cpu(flags);
@@ -2226,7 +2265,16 @@ int qede_set_features(struct net_device *dev, netdev_features_t features)
 		args.u.features = features;
 		args.func = &qede_set_features_reload;
 
-		qede_reload(edev, &args, false);
+		/* Make sure that we definitely need to reload.
+		 * In case of an eBPF attached program, there will be no FW
+		 * aggregations, so no need to actually reload.
+		 */
+		__qede_lock(edev);
+		if (edev->xdp_prog)
+			args.func(edev, &args);
+		else
+			qede_reload(edev, &args, true);
+		__qede_unlock(edev);
 
 		return 1;
 	}
@@ -2338,6 +2386,43 @@ static netdev_features_t qede_features_check(struct sk_buff *skb,
 	return features;
 }
 
+static void qede_xdp_reload_func(struct qede_dev *edev,
+				 struct qede_reload_args *args)
+{
+	struct bpf_prog *old;
+
+	old = xchg(&edev->xdp_prog, args->u.new_prog);
+	if (old)
+		bpf_prog_put(old);
+}
+
+static int qede_xdp_set(struct qede_dev *edev, struct bpf_prog *prog)
+{
+	struct qede_reload_args args;
+
+	/* If we're called, there was already a bpf reference increment */
+	args.func = &qede_xdp_reload_func;
+	args.u.new_prog = prog;
+	qede_reload(edev, &args, false);
+
+	return 0;
+}
+
+static int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return qede_xdp_set(edev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = !!edev->xdp_prog;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -2363,6 +2448,7 @@ static netdev_features_t qede_features_check(struct sk_buff *skb,
 	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
 	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
 	.ndo_features_check = qede_features_check,
+	.ndo_xdp = qede_xdp,
 };
 
 /* -------------------------------------------------------------------------
@@ -2559,6 +2645,9 @@ static int qede_alloc_fp_array(struct qede_dev *edev)
 			fp->rxq = kzalloc(sizeof(*fp->rxq), GFP_KERNEL);
 			if (!fp->rxq)
 				goto err;
+
+			if (edev->xdp_prog)
+				fp->type |= QEDE_FASTPATH_XDP;
 		}
 	}
 
@@ -2756,6 +2845,10 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	pci_set_drvdata(pdev, NULL);
 
+	/* Release edev's reference to XDP's bpf if such exist */
+	if (edev->xdp_prog)
+		bpf_prog_put(edev->xdp_prog);
+
 	free_netdev(ndev);
 
 	/* Use global ops since we've freed edev */
@@ -2907,6 +3000,10 @@ static int qede_alloc_sge_mem(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	dma_addr_t mapping;
 	int i;
 
+	/* Don't perform FW aggregations in case of XDP */
+	if (edev->xdp_prog)
+		edev->gro_disable = 1;
+
 	if (edev->gro_disable)
 		return 0;
 
@@ -2959,8 +3056,13 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	if (rxq->rx_buf_size > PAGE_SIZE)
 		rxq->rx_buf_size = PAGE_SIZE;
 
-	/* Segment size to spilt a page in multiple equal parts */
-	rxq->rx_buf_seg_size = roundup_pow_of_two(rxq->rx_buf_size);
+	/* Segment size to spilt a page in multiple equal parts,
+	 * unless XDP is used in which case we'd use the entire page.
+	 */
+	if (!edev->xdp_prog)
+		rxq->rx_buf_seg_size = roundup_pow_of_two(rxq->rx_buf_size);
+	else
+		rxq->rx_buf_seg_size = PAGE_SIZE;
 
 	/* Allocate the parallel driver ring for Rx buffers */
 	size = sizeof(*rxq->sw_rx_ring) * RX_RING_SIZE;
@@ -3368,6 +3470,9 @@ static int qede_stop_queues(struct qede_dev *edev)
 				return rc;
 			}
 		}
+
+		if (fp->type & QEDE_FASTPATH_XDP)
+			bpf_prog_put(fp->rxq->xdp_prog);
 	}
 
 	/* Stop the vport */
@@ -3495,6 +3600,15 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 			qede_update_rx_prod(edev, rxq);
 		}
 
+		if (fp->type & QEDE_FASTPATH_XDP) {
+			fp->rxq->xdp_prog = bpf_prog_add(edev->xdp_prog, 1);
+			if (IS_ERR(fp->rxq->xdp_prog)) {
+				rc = PTR_ERR(fp->rxq->xdp_prog);
+				fp->rxq->xdp_prog = NULL;
+				return rc;
+			}
+		}
+
 		if (fp->type & QEDE_FASTPATH_TX) {
 			rc = qede_start_txq(edev, fp, fp->txq, i, TX_PI(0));
 			if (rc)
-- 
1.9.3
