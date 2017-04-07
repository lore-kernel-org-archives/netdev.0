From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/5] qede: Update receive statistic once per NAPI
Date: Fri, 7 Apr 2017 11:04:57 +0300
Message-ID: <1491552301-23953-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56669 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754150AbdDGIGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:21 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, each time an ingress packet is passed to networking stack
the driver increments a per-queue SW statistic.
As we want to have additional fields in the first cache-line of the
Rx-queue struct, change flow so this statistic would be updated once per
NAPI run. We will later push the statistic to a different cache line.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_fp.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 1e65038..c77e697 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -624,7 +624,6 @@ static inline void qede_skb_receive(struct qede_dev *edev,
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
 	napi_gro_receive(&fp->napi, skb);
-	rxq->rcv_pkts++;
 }
 
 static void qede_set_gro_params(struct qede_dev *edev,
@@ -884,9 +883,9 @@ static inline void qede_tpa_cont(struct qede_dev *edev,
 		       "Strange - TPA cont with more than a single len_list entry\n");
 }
 
-static void qede_tpa_end(struct qede_dev *edev,
-			 struct qede_fastpath *fp,
-			 struct eth_fast_path_rx_tpa_end_cqe *cqe)
+static int qede_tpa_end(struct qede_dev *edev,
+			struct qede_fastpath *fp,
+			struct eth_fast_path_rx_tpa_end_cqe *cqe)
 {
 	struct qede_rx_queue *rxq = fp->rxq;
 	struct qede_agg_info *tpa_info;
@@ -934,11 +933,12 @@ static void qede_tpa_end(struct qede_dev *edev,
 
 	tpa_info->state = QEDE_AGG_STATE_NONE;
 
-	return;
+	return 1;
 err:
 	tpa_info->state = QEDE_AGG_STATE_NONE;
 	dev_kfree_skb_any(tpa_info->skb);
 	tpa_info->skb = NULL;
+	return 0;
 }
 
 static u8 qede_check_notunn_csum(u16 flag)
@@ -1178,8 +1178,7 @@ static int qede_rx_process_tpa_cqe(struct qede_dev *edev,
 		qede_tpa_cont(edev, rxq, &cqe->fast_path_tpa_cont);
 		return 0;
 	case ETH_RX_CQE_TYPE_TPA_END:
-		qede_tpa_end(edev, fp, &cqe->fast_path_tpa_end);
-		return 1;
+		return qede_tpa_end(edev, fp, &cqe->fast_path_tpa_end);
 	default:
 		return 0;
 	}
@@ -1229,7 +1228,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	/* Run eBPF program if one is attached */
 	if (xdp_prog)
 		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe))
-			return 1;
+			return 0;
 
 	/* If this is an error packet then drop it */
 	flags = cqe->fast_path_regular.pars_flags.flags;
@@ -1290,8 +1289,8 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 {
 	struct qede_rx_queue *rxq = fp->rxq;
 	struct qede_dev *edev = fp->edev;
+	int work_done = 0, rcv_pkts = 0;
 	u16 hw_comp_cons, sw_comp_cons;
-	int work_done = 0;
 
 	hw_comp_cons = le16_to_cpu(*rxq->hw_cons_ptr);
 	sw_comp_cons = qed_chain_get_cons_idx(&rxq->rx_comp_ring);
@@ -1305,12 +1304,14 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 
 	/* Loop to complete all indicated BDs */
 	while ((sw_comp_cons != hw_comp_cons) && (work_done < budget)) {
-		qede_rx_process_cqe(edev, fp, rxq);
+		rcv_pkts += qede_rx_process_cqe(edev, fp, rxq);
 		qed_chain_recycle_consumed(&rxq->rx_comp_ring);
 		sw_comp_cons = qed_chain_get_cons_idx(&rxq->rx_comp_ring);
 		work_done++;
 	}
 
+	rxq->rcv_pkts += rcv_pkts;
+
 	/* Allocate replacement buffers */
 	while (rxq->num_rx_buffers - rxq->filled_buffers)
 		if (qede_alloc_rx_buffer(rxq, false))
-- 
1.9.3
