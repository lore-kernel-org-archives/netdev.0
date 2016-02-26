From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 06/10] bnxt_en: Use firmware provided message timeout value.
Date: Fri, 26 Feb 2016 04:00:04 -0500
Message-ID: <1456477208-30692-7-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:34255
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751161AbcBZJAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:46 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch, we used a hardcoded value of 500 msec as the default
value for firmware message response timeout.  For better portability with
future hardware or debug platforms, use the value provided by firmware in
the first response and store it for all susequent messages.  Redefine the
macro HWRM_CMD_TIMEOUT to the stored value.  Since we don't have the
value yet in the first message, use the 500 ms default if the stored value
is zero.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 7 +++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 4 +++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 198c69d4..05a93a7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2638,6 +2638,9 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 	/* Ring channel doorbell */
 	writel(1, bp->bar0 + 0x100);
 
+	if (!timeout)
+		timeout = DFLT_HWRM_CMD_TIMEOUT;
+
 	i = 0;
 	if (intr_process) {
 		/* Wait until hwrm response cmpl interrupt is processed */
@@ -3809,6 +3812,10 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 		 resp->hwrm_fw_maj, resp->hwrm_fw_min, resp->hwrm_fw_bld,
 		 resp->hwrm_intf_maj, resp->hwrm_intf_min, resp->hwrm_intf_upd);
 
+	bp->hwrm_cmd_timeout = le16_to_cpu(resp->def_req_timeout);
+	if (!bp->hwrm_cmd_timeout)
+		bp->hwrm_cmd_timeout = DFLT_HWRM_CMD_TIMEOUT;
+
 hwrm_ver_get_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index ba67c4a..a3d4940 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -477,7 +477,8 @@ struct rx_tpa_end_cmp_ext {
 #define RING_CMP(idx)		((idx) & bp->cp_ring_mask)
 #define NEXT_CMP(idx)		RING_CMP(ADV_RAW_CMP(idx, 1))
 
-#define HWRM_CMD_TIMEOUT		500
+#define DFLT_HWRM_CMD_TIMEOUT		500
+#define HWRM_CMD_TIMEOUT		(bp->hwrm_cmd_timeout)
 #define HWRM_RESET_TIMEOUT		((HWRM_CMD_TIMEOUT) * 4)
 #define HWRM_RESP_ERR_CODE_MASK		0xffff
 #define HWRM_RESP_LEN_MASK		0xffff0000
@@ -957,6 +958,7 @@ struct bnxt {
 	void			*hwrm_dbg_resp_addr;
 	dma_addr_t		hwrm_dbg_resp_dma_addr;
 #define HWRM_DBG_REG_BUF_SIZE	128
+	int			hwrm_cmd_timeout;
 	struct mutex		hwrm_cmd_lock;	/* serialize hwrm messages */
 	struct hwrm_ver_get_output	ver_resp;
 #define FW_VER_STR_LEN		32
-- 
1.8.3.1
