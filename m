From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/10] bnxt_en: Add hwrm_send_message_silent().
Date: Thu, 25 Feb 2016 03:19:34 -0500
Message-ID: <1456388374-1440-11-git-send-email-michael.chan@broadcom.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:35781
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759862AbcBYITg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:36 -0500
In-Reply-To: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used to send NVM_FIND_DIR_ENTRY messages which can return error
if the entry is not found.  This is normal and the error message will
cause unnecessary alarm, so silence it.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 11 +++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  2 +-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8476733..77e8c2b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2709,6 +2709,17 @@ int hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 	return rc;
 }
 
+int hwrm_send_message_silent(struct bnxt *bp, void *msg, u32 msg_len,
+			     int timeout)
+{
+	int rc;
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = bnxt_hwrm_do_send_msg(bp, msg, msg_len, timeout, true);
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 {
 	struct hwrm_func_drv_rgtr_input req = {0};
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3936e96..9aa38f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1095,6 +1095,7 @@ void bnxt_set_ring_params(struct bnxt *);
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
+int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
 int bnxt_hwrm_func_qcaps(struct bnxt *);
 int bnxt_hwrm_set_pause(struct bnxt *);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index bfda92e..84ea26d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1141,7 +1141,7 @@ static int bnxt_find_nvram_item(struct net_device *dev, u16 type, u16 ordinal,
 	req.dir_ordinal = cpu_to_le16(ordinal);
 	req.dir_ext = cpu_to_le16(ext);
 	req.opt_ordinal = NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_EQ;
-	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	rc = hwrm_send_message_silent(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 	if (rc == 0) {
 		if (index)
 			*index = le16_to_cpu(output->dir_idx);
-- 
1.8.3.1
