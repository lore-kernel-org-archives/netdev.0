From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 07/10] bnxt_en: Fix dmesg log firmware error messages.
Date: Fri, 26 Feb 2016 04:00:05 -0500
Message-ID: <1456477208-30692-8-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:16640
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbcBZJAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:45 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use appropriate firmware request header structure to prepare the
firmware messages.  This avoids the unnecessary conversion of the
fields to 32-bit fields.  Add appropriate endian conversion when
printing out the message fields in dmesg so that they appear correct
in the log.

Reported-by: Rob Swindell <swindell@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 29 +++++++++++--------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       | 15 ++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  4 ++--
 3 files changed, 17 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 05a93a7..9ff498e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2600,28 +2600,26 @@ alloc_mem_err:
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *bp, void *request, u16 req_type,
 			    u16 cmpl_ring, u16 target_id)
 {
-	struct hwrm_cmd_req_hdr *req = request;
+	struct input *req = request;
 
-	req->cmpl_ring_req_type =
-		cpu_to_le32(req_type | (cmpl_ring << HWRM_CMPL_RING_SFT));
-	req->target_id_seq_id = cpu_to_le32(target_id << HWRM_TARGET_FID_SFT);
+	req->req_type = cpu_to_le16(req_type);
+	req->cmpl_ring = cpu_to_le16(cmpl_ring);
+	req->target_id = cpu_to_le16(target_id);
 	req->resp_addr = cpu_to_le64(bp->hwrm_cmd_resp_dma_addr);
 }
 
 int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 {
 	int i, intr_process, rc;
-	struct hwrm_cmd_req_hdr *req = msg;
+	struct input *req = msg;
 	u32 *data = msg;
 	__le32 *resp_len, *valid;
 	u16 cp_ring_id, len = 0;
 	struct hwrm_err_output *resp = bp->hwrm_cmd_resp_addr;
 
-	req->target_id_seq_id |= cpu_to_le32(bp->hwrm_cmd_seq++);
+	req->seq_id = cpu_to_le16(bp->hwrm_cmd_seq++);
 	memset(resp, 0, PAGE_SIZE);
-	cp_ring_id = (le32_to_cpu(req->cmpl_ring_req_type) &
-		      HWRM_CMPL_RING_MASK) >>
-		     HWRM_CMPL_RING_SFT;
+	cp_ring_id = le16_to_cpu(req->cmpl_ring);
 	intr_process = (cp_ring_id == INVALID_HW_RING_ID) ? 0 : 1;
 
 	/* Write request msg to hwrm channel */
@@ -2632,8 +2630,7 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 
 	/* currently supports only one outstanding message */
 	if (intr_process)
-		bp->hwrm_intr_seq_id = le32_to_cpu(req->target_id_seq_id) &
-				       HWRM_SEQ_ID_MASK;
+		bp->hwrm_intr_seq_id = le16_to_cpu(req->seq_id);
 
 	/* Ring channel doorbell */
 	writel(1, bp->bar0 + 0x100);
@@ -2651,7 +2648,7 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 
 		if (bp->hwrm_intr_seq_id != HWRM_SEQ_ID_INVALID) {
 			netdev_err(bp->dev, "Resp cmpl intr err msg: 0x%x\n",
-				   req->cmpl_ring_req_type);
+				   le16_to_cpu(req->req_type));
 			return -1;
 		}
 	} else {
@@ -2667,8 +2664,8 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 
 		if (i >= timeout) {
 			netdev_err(bp->dev, "Error (timeout: %d) msg {0x%x 0x%x} len:%d\n",
-				   timeout, req->cmpl_ring_req_type,
-				   req->target_id_seq_id, *resp_len);
+				   timeout, le16_to_cpu(req->req_type),
+				   le16_to_cpu(req->seq_id), *resp_len);
 			return -1;
 		}
 
@@ -2682,8 +2679,8 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 
 		if (i >= timeout) {
 			netdev_err(bp->dev, "Error (timeout: %d) msg {0x%x 0x%x} len:%d v:%d\n",
-				   timeout, req->cmpl_ring_req_type,
-				   req->target_id_seq_id, len, *valid);
+				   timeout, le16_to_cpu(req->req_type),
+				   le16_to_cpu(req->seq_id), len, *valid);
 			return -1;
 		}
 	}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index a3d4940..3936e96 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -481,9 +481,11 @@ struct rx_tpa_end_cmp_ext {
 #define HWRM_CMD_TIMEOUT		(bp->hwrm_cmd_timeout)
 #define HWRM_RESET_TIMEOUT		((HWRM_CMD_TIMEOUT) * 4)
 #define HWRM_RESP_ERR_CODE_MASK		0xffff
+#define HWRM_RESP_LEN_OFFSET		4
 #define HWRM_RESP_LEN_MASK		0xffff0000
 #define HWRM_RESP_LEN_SFT		16
 #define HWRM_RESP_VALID_MASK		0xff000000
+#define HWRM_SEQ_ID_INVALID		-1
 #define BNXT_HWRM_REQ_MAX_SIZE		128
 #define BNXT_HWRM_REQS_PER_PAGE		(BNXT_PAGE_SIZE /	\
 					 BNXT_HWRM_REQ_MAX_SIZE)
@@ -645,19 +647,6 @@ struct bnxt_irq {
 
 #define INVALID_STATS_CTX_ID	-1
 
-struct hwrm_cmd_req_hdr {
-#define HWRM_CMPL_RING_MASK	0xffff0000
-#define HWRM_CMPL_RING_SFT	16
-	__le32	cmpl_ring_req_type;
-#define HWRM_SEQ_ID_MASK	0xffff
-#define HWRM_SEQ_ID_INVALID -1
-#define HWRM_RESP_LEN_OFFSET	4
-#define HWRM_TARGET_FID_MASK	0xffff0000
-#define HWRM_TARGET_FID_SFT	16
-	__le32	target_id_seq_id;
-	__le64	resp_addr;
-};
-
 struct bnxt_ring_grp_info {
 	u16	fw_stats_ctx;
 	u16	fw_grp_id;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 9f6b4cc..0c5f510 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -801,8 +801,8 @@ static int bnxt_vf_set_link(struct bnxt *bp, struct bnxt_vf_info *vf)
 static int bnxt_vf_req_validate_snd(struct bnxt *bp, struct bnxt_vf_info *vf)
 {
 	int rc = 0;
-	struct hwrm_cmd_req_hdr *encap_req = vf->hwrm_cmd_req_addr;
-	u32 req_type = le32_to_cpu(encap_req->cmpl_ring_req_type) & 0xffff;
+	struct input *encap_req = vf->hwrm_cmd_req_addr;
+	u32 req_type = le16_to_cpu(encap_req->req_type);
 
 	switch (req_type) {
 	case HWRM_CFA_L2_FILTER_ALLOC:
-- 
1.8.3.1
