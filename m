From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/7] bnxt_en: Support for Short Firmware Message
Date: Mon, 29 May 2017 19:06:04 -0400
Message-ID: <1496099170-701-2-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33706 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdE2XGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:49 -0400
Received: by mail-qk0-f170.google.com with SMTP id y201so56897533qka.0
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:44 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

The new short message format is used on the new BCM57454 VFs.  Each
firmware message is a fixed 16-byte message sent using the standard
firmware communication channel.  The short message has a DMA address
pointing to the legacy long firmware message.

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 66 ++++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 ++
 2 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 69b6829..47bc4f3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2868,6 +2868,32 @@ static int bnxt_alloc_hwrm_resources(struct bnxt *bp)
 	return 0;
 }
 
+static void bnxt_free_hwrm_short_cmd_req(struct bnxt *bp)
+{
+	if (bp->hwrm_short_cmd_req_addr) {
+		struct pci_dev *pdev = bp->pdev;
+
+		dma_free_coherent(&pdev->dev, BNXT_HWRM_MAX_REQ_LEN,
+				  bp->hwrm_short_cmd_req_addr,
+				  bp->hwrm_short_cmd_req_dma_addr);
+		bp->hwrm_short_cmd_req_addr = NULL;
+	}
+}
+
+static int bnxt_alloc_hwrm_short_cmd_req(struct bnxt *bp)
+{
+	struct pci_dev *pdev = bp->pdev;
+
+	bp->hwrm_short_cmd_req_addr =
+		dma_alloc_coherent(&pdev->dev, BNXT_HWRM_MAX_REQ_LEN,
+				   &bp->hwrm_short_cmd_req_dma_addr,
+				   GFP_KERNEL);
+	if (!bp->hwrm_short_cmd_req_addr)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static void bnxt_free_stats(struct bnxt *bp)
 {
 	u32 size, i;
@@ -3215,16 +3241,41 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 	__le32 *resp_len, *valid;
 	u16 cp_ring_id, len = 0;
 	struct hwrm_err_output *resp = bp->hwrm_cmd_resp_addr;
+	u16 max_req_len = BNXT_HWRM_MAX_REQ_LEN;
 
 	req->seq_id = cpu_to_le16(bp->hwrm_cmd_seq++);
 	memset(resp, 0, PAGE_SIZE);
 	cp_ring_id = le16_to_cpu(req->cmpl_ring);
 	intr_process = (cp_ring_id == INVALID_HW_RING_ID) ? 0 : 1;
 
+	if (bp->flags & BNXT_FLAG_SHORT_CMD) {
+		void *short_cmd_req = bp->hwrm_short_cmd_req_addr;
+		struct hwrm_short_input short_input = {0};
+
+		memcpy(short_cmd_req, req, msg_len);
+		memset(short_cmd_req + msg_len, 0, BNXT_HWRM_MAX_REQ_LEN -
+						   msg_len);
+
+		short_input.req_type = req->req_type;
+		short_input.signature =
+				cpu_to_le16(SHORT_REQ_SIGNATURE_SHORT_CMD);
+		short_input.size = cpu_to_le16(msg_len);
+		short_input.req_addr =
+			cpu_to_le64(bp->hwrm_short_cmd_req_dma_addr);
+
+		data = (u32 *)&short_input;
+		msg_len = sizeof(short_input);
+
+		/* Sync memory write before updating doorbell */
+		wmb();
+
+		max_req_len = BNXT_HWRM_SHORT_REQ_LEN;
+	}
+
 	/* Write request msg to hwrm channel */
 	__iowrite32_copy(bp->bar0, data, msg_len / 4);
 
-	for (i = msg_len; i < BNXT_HWRM_MAX_REQ_LEN; i += 4)
+	for (i = msg_len; i < max_req_len; i += 4)
 		writel(0, bp->bar0 + i);
 
 	/* currently supports only one outstanding message */
@@ -4662,6 +4713,7 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 	int rc;
 	struct hwrm_ver_get_input req = {0};
 	struct hwrm_ver_get_output *resp = bp->hwrm_cmd_resp_addr;
+	u32 dev_caps_cfg;
 
 	bp->hwrm_max_req_len = HWRM_MAX_REQ_LEN;
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VER_GET, -1, -1);
@@ -4699,6 +4751,11 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 	    !resp->chip_metal)
 		bp->flags |= BNXT_FLAG_CHIP_NITRO_A0;
 
+	dev_caps_cfg = le32_to_cpu(resp->dev_caps_cfg);
+	if ((dev_caps_cfg & VER_GET_RESP_DEV_CAPS_CFG_SHORT_CMD_SUPPORTED) &&
+	    (dev_caps_cfg & VER_GET_RESP_DEV_CAPS_CFG_SHORT_CMD_REQUIRED))
+		bp->flags |= BNXT_FLAG_SHORT_CMD;
+
 hwrm_ver_get_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
@@ -7357,6 +7414,7 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	bnxt_clear_int_mode(bp);
 	bnxt_hwrm_func_drv_unrgtr(bp);
 	bnxt_free_hwrm_resources(bp);
+	bnxt_free_hwrm_short_cmd_req(bp);
 	bnxt_ethtool_free(bp);
 	bnxt_dcb_free(bp);
 	kfree(bp->edev);
@@ -7607,6 +7665,12 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err_pci_clean;
 
+	if (bp->flags & BNXT_FLAG_SHORT_CMD) {
+		rc = bnxt_alloc_hwrm_short_cmd_req(bp);
+		if (rc)
+			goto init_err_pci_clean;
+	}
+
 	rc = bnxt_hwrm_func_reset(bp);
 	if (rc)
 		goto init_err_pci_clean;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3ef42db..cb56678 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -500,6 +500,7 @@ struct rx_tpa_end_cmp_ext {
 #define NEXT_CMP(idx)		RING_CMP(ADV_RAW_CMP(idx, 1))
 
 #define BNXT_HWRM_MAX_REQ_LEN		(bp->hwrm_max_req_len)
+#define BNXT_HWRM_SHORT_REQ_LEN		sizeof(struct hwrm_short_input)
 #define DFLT_HWRM_CMD_TIMEOUT		500
 #define HWRM_CMD_TIMEOUT		(bp->hwrm_cmd_timeout)
 #define HWRM_RESET_TIMEOUT		((HWRM_CMD_TIMEOUT) * 4)
@@ -1006,6 +1007,7 @@ struct bnxt {
 	#define BNXT_FLAG_RX_PAGE_MODE	0x40000
 	#define BNXT_FLAG_FW_LLDP_AGENT	0x80000
 	#define BNXT_FLAG_MULTI_HOST	0x100000
+	#define BNXT_FLAG_SHORT_CMD	0x200000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
@@ -1106,6 +1108,8 @@ struct bnxt {
 	u32			hwrm_spec_code;
 	u16			hwrm_cmd_seq;
 	u32			hwrm_intr_seq_id;
+	void			*hwrm_short_cmd_req_addr;
+	dma_addr_t		hwrm_short_cmd_req_dma_addr;
 	void			*hwrm_cmd_resp_addr;
 	dma_addr_t		hwrm_cmd_resp_dma_addr;
 	void			*hwrm_dbg_resp_addr;
-- 
1.8.3.1
