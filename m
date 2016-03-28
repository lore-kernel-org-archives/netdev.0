From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/4] bnxt_en: Implement proper firmware message padding.
Date: Mon, 28 Mar 2016 19:46:05 -0400
Message-ID: <1459208767-4225-3-git-send-email-michael.chan@broadcom.com>
References: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:26572 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbcC1Xzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 19:55:52 -0400
In-Reply-To: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size of every padded firmware message is specified in the first
HWRM_VER_GET response message.  Use this value to pad every message
after that.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 +++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 2 ++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c92053c..4600a05 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2653,7 +2653,7 @@ static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
 	/* Write request msg to hwrm channel */
 	__iowrite32_copy(bp->bar0, data, msg_len / 4);
 
-	for (i = msg_len; i < HWRM_MAX_REQ_LEN; i += 4)
+	for (i = msg_len; i < BNXT_HWRM_MAX_REQ_LEN; i += 4)
 		writel(0, bp->bar0 + i);
 
 	/* currently supports only one outstanding message */
@@ -3830,6 +3830,7 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 	struct hwrm_ver_get_input req = {0};
 	struct hwrm_ver_get_output *resp = bp->hwrm_cmd_resp_addr;
 
+	bp->hwrm_max_req_len = HWRM_MAX_REQ_LEN;
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VER_GET, -1, -1);
 	req.hwrm_intf_maj = HWRM_VERSION_MAJOR;
 	req.hwrm_intf_min = HWRM_VERSION_MINOR;
@@ -3855,6 +3856,9 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 	if (!bp->hwrm_cmd_timeout)
 		bp->hwrm_cmd_timeout = DFLT_HWRM_CMD_TIMEOUT;
 
+	if (resp->hwrm_intf_maj >= 1)
+		bp->hwrm_max_req_len = le16_to_cpu(resp->max_req_win_len);
+
 hwrm_ver_get_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index ec04c47..709b95b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -477,6 +477,7 @@ struct rx_tpa_end_cmp_ext {
 #define RING_CMP(idx)		((idx) & bp->cp_ring_mask)
 #define NEXT_CMP(idx)		RING_CMP(ADV_RAW_CMP(idx, 1))
 
+#define BNXT_HWRM_MAX_REQ_LEN		(bp->hwrm_max_req_len)
 #define DFLT_HWRM_CMD_TIMEOUT		500
 #define HWRM_CMD_TIMEOUT		(bp->hwrm_cmd_timeout)
 #define HWRM_RESET_TIMEOUT		((HWRM_CMD_TIMEOUT) * 4)
@@ -953,6 +954,7 @@ struct bnxt {
 	dma_addr_t		hw_tx_port_stats_map;
 	int			hw_port_stats_size;
 
+	u16			hwrm_max_req_len;
 	int			hwrm_cmd_timeout;
 	struct mutex		hwrm_cmd_lock;	/* serialize hwrm messages */
 	struct hwrm_ver_get_output	ver_resp;
-- 
1.8.3.1
