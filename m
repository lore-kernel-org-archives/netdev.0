From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 4/8] qede: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:13 -0800
Message-ID: <20170221193417.3641224-5-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55717 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751938AbdBUTe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:29 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJWinT029734
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:29 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28rut5r07a-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:28 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 c1f05b5ef86c11e692b70002c99331b0-305976c0 for <netdev@vger.kernel.org>;        Tue,
 21 Feb 2017 11:34:27 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  3 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c  | 39 ++++++++++---------------
 drivers/net/ethernet/qlogic/qede/qede_fp.c      | 36 +++++++++++++----------
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 23 ++++-----------
 5 files changed, 45 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index f2aaef2..fdd2874 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -217,10 +217,9 @@ struct qede_dev {
 	u16				geneve_dst_port;
 
 	bool wol_enabled;
+	bool xdp_enabled;
 
 	struct qede_rdma_dev		rdma_info;
-
-	struct bpf_prog *xdp_prog;
 };
 
 enum QEDE_STATE {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 8979531..5d22764 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -342,7 +342,7 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 		num_stats += QEDE_RSS_COUNT(edev) * QEDE_NUM_RQSTATS;
 
 		/* Account for XDP statistics [if needed] */
-		if (edev->xdp_prog)
+		if (edev->xdp_enabled)
 			num_stats += QEDE_RSS_COUNT(edev) * QEDE_NUM_TQSTATS;
 		return num_stats;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 107c3fd..9c9db44 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -426,7 +426,7 @@ int qede_set_features(struct net_device *dev, netdev_features_t features)
 		 * aggregations, so no need to actually reload.
 		 */
 		__qede_lock(edev);
-		if (edev->xdp_prog)
+		if (edev->xdp_enabled)
 			args.func(edev, &args);
 		else
 			qede_reload(edev, &args, true);
@@ -506,29 +506,21 @@ void qede_udp_tunnel_del(struct net_device *dev, struct udp_tunnel_info *ti)
 	schedule_delayed_work(&edev->sp_task, 0);
 }
 
-static void qede_xdp_reload_func(struct qede_dev *edev,
-				 struct qede_reload_args *args)
+static int qede_xdp_check_bpf(struct qede_dev *edev, struct bpf_prog *prog)
 {
-	struct bpf_prog *old;
-
-	old = xchg(&edev->xdp_prog, args->u.new_prog);
-	if (old)
-		bpf_prog_put(old);
-}
-
-static int qede_xdp_set(struct qede_dev *edev, struct bpf_prog *prog)
-{
-	struct qede_reload_args args;
-
 	if (prog && prog->xdp_adjust_head) {
 		DP_ERR(edev, "Does not support bpf_xdp_adjust_head()\n");
 		return -EOPNOTSUPP;
 	}
 
-	/* If we're called, there was already a bpf reference increment */
-	args.func = &qede_xdp_reload_func;
-	args.u.new_prog = prog;
-	qede_reload(edev, &args, false);
+	return 0;
+}
+
+static int qede_xdp_init(struct qede_dev *edev, bool enable)
+{
+	edev->xdp_enabled = enable;
+
+	qede_reload(edev, NULL, false);
 
 	return 0;
 }
@@ -538,11 +530,12 @@ int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	struct qede_dev *edev = netdev_priv(dev);
 
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return qede_xdp_set(edev, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!edev->xdp_prog;
-		return 0;
+	case XDP_MODE_OFF:
+		return qede_xdp_init(edev, true);
+	case XDP_MODE_ON:
+		return qede_xdp_init(edev, false);
+	case XDP_CHECK_BPF_PROG:
+		return qede_xdp_check_bpf(edev, xdp->prog);
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 1e65038..7423317 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -41,6 +41,7 @@
 #include <linux/if_vlan.h>
 #include <net/ip6_checksum.h>
 #include "qede_ptp.h"
+#include <net/xdp.h>
 
 #include <linux/qed/qed_if.h>
 #include "qede.h"
@@ -988,13 +989,14 @@ static bool qede_pkt_is_ip_fragmented(struct eth_fast_path_rx_reg_cqe *cqe,
 static bool qede_rx_xdp(struct qede_dev *edev,
 			struct qede_fastpath *fp,
 			struct qede_rx_queue *rxq,
-			struct bpf_prog *prog,
 			struct sw_rx_data *bd,
 			struct eth_fast_path_rx_reg_cqe *cqe)
 {
 	u16 len = le16_to_cpu(cqe->len_on_first_bd);
 	struct xdp_buff xdp;
 	enum xdp_action act;
+	struct xdp_hook *last_hook;
+	bool retval = false;
 
 	xdp.data = page_address(bd->data) + cqe->placement_offset;
 	xdp.data_end = xdp.data + len;
@@ -1004,11 +1006,13 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 	 * side for map helpers.
 	 */
 	rcu_read_lock();
-	act = bpf_prog_run_xdp(prog, &xdp);
-	rcu_read_unlock();
 
-	if (act == XDP_PASS)
-		return true;
+	act = xdp_hook_run_ret_last(&fp->napi, &xdp, &last_hook);
+
+	if (act == XDP_PASS) {
+		retval = true;
+		goto out;
+	}
 
 	/* Count number of packets not to be passed to stack */
 	rxq->xdp_no_pass++;
@@ -1018,8 +1022,8 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 		/* We need the replacement buffer before transmit. */
 		if (qede_alloc_rx_buffer(rxq, true)) {
 			qede_recycle_rx_bd_ring(rxq, 1);
-			trace_xdp_exception(edev->ndev, prog, act);
-			return false;
+			trace_xdp_hook_exception(edev->ndev, last_hook, act);
+			goto out;
 		}
 
 		/* Now if there's a transmission problem, we'd still have to
@@ -1029,22 +1033,25 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 			dma_unmap_page(rxq->dev, bd->mapping,
 				       PAGE_SIZE, DMA_BIDIRECTIONAL);
 			__free_page(bd->data);
-			trace_xdp_exception(edev->ndev, prog, act);
+			trace_xdp_hook_exception(edev->ndev, last_hook, act);
 		}
 
 		/* Regardless, we've consumed an Rx BD */
 		qede_rx_bd_ring_consume(rxq);
-		return false;
+		goto out;
 
 	default:
-		bpf_warn_invalid_xdp_action(act);
+		xdp_warn_invalid_action(act);
 	case XDP_ABORTED:
-		trace_xdp_exception(edev->ndev, prog, act);
+		trace_xdp_hook_exception(edev->ndev, last_hook, act);
 	case XDP_DROP:
 		qede_recycle_rx_bd_ring(rxq, cqe->bd_num);
 	}
 
-	return false;
+out:
+	rcu_read_unlock();
+
+	return retval;
 }
 
 static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
@@ -1189,7 +1196,6 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 			       struct qede_fastpath *fp,
 			       struct qede_rx_queue *rxq)
 {
-	struct bpf_prog *xdp_prog = READ_ONCE(rxq->xdp_prog);
 	struct eth_fast_path_rx_reg_cqe *fp_cqe;
 	u16 len, pad, bd_cons_idx, parse_flag;
 	enum eth_rx_cqe_type cqe_type;
@@ -1227,8 +1233,8 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	pad = fp_cqe->placement_offset;
 
 	/* Run eBPF program if one is attached */
-	if (xdp_prog)
-		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe))
+	if (xdp_hook_run_needed_check(edev->ndev, &fp->napi))
+		if (!qede_rx_xdp(edev, fp, rxq, bd, fp_cqe))
 			return 1;
 
 	/* If this is an error packet then drop it */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 3a78c3f..312da1c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -581,7 +581,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 {
 	struct net_device *ndev = edev->ndev;
 	struct pci_dev *pdev = edev->pdev;
-	u32 hw_features;
+	netdev_features_t hw_features;
 
 	pci_set_drvdata(pdev, ndev);
 
@@ -601,7 +601,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 	/* user-changeble features */
 	hw_features = NETIF_F_GRO | NETIF_F_SG |
 		      NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		      NETIF_F_TSO | NETIF_F_TSO6;
+		      NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_XDP;
 
 	/* Encap features*/
 	hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
@@ -730,7 +730,7 @@ static int qede_alloc_fp_array(struct qede_dev *edev)
 			if (!fp->rxq)
 				goto err;
 
-			if (edev->xdp_prog) {
+			if (edev->xdp_enabled) {
 				fp->xdp_tx = kzalloc(sizeof(*fp->xdp_tx),
 						     GFP_KERNEL);
 				if (!fp->xdp_tx)
@@ -952,9 +952,7 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	pci_set_drvdata(pdev, NULL);
 
-	/* Release edev's reference to XDP's bpf if such exist */
-	if (edev->xdp_prog)
-		bpf_prog_put(edev->xdp_prog);
+	free_netdev(ndev);
 
 	/* Use global ops since we've freed edev */
 	qed_ops->common->slowpath_stop(cdev);
@@ -1114,7 +1112,7 @@ static int qede_alloc_sge_mem(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	int i;
 
 	/* Don't perform FW aggregations in case of XDP */
-	if (edev->xdp_prog)
+	if (edev->xdp_enabled)
 		edev->gro_disable = 1;
 
 	if (edev->gro_disable)
@@ -1172,7 +1170,7 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 	/* Segment size to spilt a page in multiple equal parts,
 	 * unless XDP is used in which case we'd use the entire page.
 	 */
-	if (!edev->xdp_prog)
+	if (!edev->xdp_enabled)
 		rxq->rx_buf_seg_size = roundup_pow_of_two(rxq->rx_buf_size);
 	else
 		rxq->rx_buf_seg_size = PAGE_SIZE;
@@ -1625,8 +1623,6 @@ static int qede_stop_queues(struct qede_dev *edev)
 			rc = qede_stop_txq(edev, fp->xdp_tx, i);
 			if (rc)
 				return rc;
-
-			bpf_prog_put(fp->rxq->xdp_prog);
 		}
 	}
 
@@ -1770,13 +1766,6 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 			rc = qede_start_txq(edev, fp, fp->xdp_tx, i, XDP_PI);
 			if (rc)
 				goto out;
-
-			fp->rxq->xdp_prog = bpf_prog_add(edev->xdp_prog, 1);
-			if (IS_ERR(fp->rxq->xdp_prog)) {
-				rc = PTR_ERR(fp->rxq->xdp_prog);
-				fp->rxq->xdp_prog = NULL;
-				goto out;
-			}
 		}
 
 		if (fp->type & QEDE_FASTPATH_TX) {
-- 
2.9.3
