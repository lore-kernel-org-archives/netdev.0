From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 04/12] qed*: Change maximal number of queues
Date: Sun, 1 Jan 2017 13:57:03 +0200
Message-ID: <1483271831-25890-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53879 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932128AbdAAL6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:13 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today qede requests contexts that would suffice for 64 'whole'
combined queues [192 meant for 64 rx, tx and xdp tx queues],
but registers netdev and limits the number of queues based on
information received by qed. In turn, qed doesn't take context
into account when informing qede how many queues it can support.

This would lead to a configuration problem in case user tries
configuring >64 combined queues to interface [or >96 in case
xdp isn't enabled]. Since we don't have a mangement firware
that actually provides so many interrupt lines to a single
device we're currently safe but that's about to change soon.

The new maximum is hence changed:
  - For RoCE devices, the limit would remain 64.
  - For non-RoCE devices, the limit might be higher [depending
    on the actual configuration of the device].
qed would start enforcing that limit in both scenarios.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c     | 32 ++++++++++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 11 ++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  2 +-
 3 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index fd153d2..03d31b3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1753,13 +1753,31 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 		int max_vf_mac_filters = 0;
 
 		if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
-			for_each_hwfn(cdev, i)
-			    info->num_queues +=
-			    FEAT_NUM(&cdev->hwfns[i], QED_PF_L2_QUE);
-			if (cdev->int_params.fp_msix_cnt)
-				info->num_queues =
-				    min_t(u8, info->num_queues,
-					  cdev->int_params.fp_msix_cnt);
+			u16 num_queues = 0;
+
+			/* Since the feature controls only queue-zones,
+			 * make sure we have the contexts [rx, tx, xdp] to
+			 * match.
+			 */
+			for_each_hwfn(cdev, i) {
+				struct qed_hwfn *hwfn = &cdev->hwfns[i];
+				u16 l2_queues = (u16)FEAT_NUM(hwfn,
+							      QED_PF_L2_QUE);
+				u16 cids;
+
+				cids = hwfn->pf_params.eth_pf_params.num_cons;
+				num_queues += min_t(u16, l2_queues, cids / 3);
+			}
+
+			/* queues might theoretically be >256, but interrupts'
+			 * upper-limit guarantes that it would fit in a u8.
+			 */
+			if (cdev->int_params.fp_msix_cnt) {
+				u8 irqs = cdev->int_params.fp_msix_cnt;
+
+				info->num_queues = (u8)min_t(u16,
+							     num_queues, irqs);
+			}
 		} else {
 			info->num_queues = cdev->num_hwfns;
 		}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index e156842..93eee83 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -877,6 +877,17 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 		params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
 	}
 
+	/* In case we might support RDMA, don't allow qede to be greedy
+	 * with the L2 contexts. Allow for 64 queues [rx, tx, xdp] per hwfn.
+	 */
+	if (QED_LEADING_HWFN(cdev)->hw_info.personality ==
+	    QED_PCI_ETH_ROCE) {
+		u16 *num_cons;
+
+		num_cons = &params->eth_pf_params.num_cons;
+		*num_cons = min_t(u16, *num_cons, 192);
+	}
+
 	for (i = 0; i < cdev->num_hwfns; i++) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 334e414..a679d42 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -753,7 +753,7 @@ static void qede_update_pf_params(struct qed_dev *cdev)
 
 	/* 64 rx + 64 tx + 64 XDP */
 	memset(&pf_params, 0, sizeof(struct qed_pf_params));
-	pf_params.eth_pf_params.num_cons = 192;
+	pf_params.eth_pf_params.num_cons = (MAX_SB_PER_PF_MIMD - 1) * 3;
 	qed_ops->common->update_pf_params(cdev, &pf_params);
 }
 
-- 
1.9.3
