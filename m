From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/6] qed: Don't over-do producer cleanup for Rx
Date: Wed, 27 Jul 2016 14:45:21 +0300
Message-ID: <1469619924-12806-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59988 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755310AbcG0Lpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:40 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before requesting the firmware to start Rx queues,
driver goes and sets the queue producer in the device to 0.
But while the producer is 32-bit, the driver currently clears 64 bits,
effectively zeroing an additional CID's producer as well.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 4 ++--
 drivers/net/ethernet/qlogic/qed/qed_vf.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index aada4c7..ff388208 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -587,7 +587,7 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 			  u16 cqe_pbl_size, void __iomem **pp_prod)
 {
 	struct qed_hw_cid_data *p_rx_cid;
-	u64 init_prod_val = 0;
+	u32 init_prod_val = 0;
 	u16 abs_l2_queue = 0;
 	u8 abs_stats_id = 0;
 	int rc;
@@ -615,7 +615,7 @@ qed_sp_eth_rx_queue_start(struct qed_hwfn *p_hwfn,
 				 MSTORM_PRODS_OFFSET(abs_l2_queue);
 
 	/* Init the rcq, rx bd and rx sge (if valid) producers to 0 */
-	__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u64),
+	__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u32),
 			  (u32 *)(&init_prod_val));
 
 	/* Allocate a CID for the queue */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 72e69c0..c39e26a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -353,7 +353,7 @@ int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
 
 	/* Learn the address of the producer from the response */
 	if (pp_prod) {
-		u64 init_prod_val = 0;
+		u32 init_prod_val = 0;
 
 		*pp_prod = (u8 __iomem *)p_hwfn->regview + resp->offset;
 		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
@@ -361,7 +361,7 @@ int qed_vf_pf_rxq_start(struct qed_hwfn *p_hwfn,
 			   rx_qid, *pp_prod, resp->offset);
 
 		/* Init the rcq, rx bd and rx sge (if valid) producers to 0 */
-		__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u64),
+		__internal_ram_wr(p_hwfn, *pp_prod, sizeof(u32),
 				  (u32 *)&init_prod_val);
 	}
 
-- 
1.9.3
