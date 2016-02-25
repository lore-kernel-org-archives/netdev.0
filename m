From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 09/10] bnxt_en: Refactor _hwrm_send_message().
Date: Thu, 25 Feb 2016 03:19:33 -0500
Message-ID: <1456388374-1440-10-git-send-email-michael.chan@broadcom.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:54425
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759771AbcBYITg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:36 -0500
In-Reply-To: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new function bnxt_do_send_msg() to do essentially the same thing
with an additional paramter to silence error response messages.  All
current callers will set silent to false.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 09a3636..8476733 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2608,7 +2608,8 @@ void bnxt_hwrm_cmd_hdr_init(struct bnxt *bp, void *request, u16 req_type,
 	req->resp_addr = cpu_to_le64(bp->hwrm_cmd_resp_dma_addr);
 }
 
-int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
+static int bnxt_hwrm_do_send_msg(struct bnxt *bp, void *msg, u32 msg_len,
+				 int timeout, bool silent)
 {
 	int i, intr_process, rc;
 	struct input *req = msg;
@@ -2686,13 +2687,16 @@ int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
 	}
 
 	rc = le16_to_cpu(resp->error_code);
-	if (rc) {
+	if (rc && !silent)
 		netdev_err(bp->dev, "hwrm req_type 0x%x seq id 0x%x error 0x%x\n",
 			   le16_to_cpu(resp->req_type),
 			   le16_to_cpu(resp->seq_id), rc);
-		return rc;
-	}
-	return 0;
+	return rc;
+}
+
+int _hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
+{
+	return bnxt_hwrm_do_send_msg(bp, msg, msg_len, timeout, false);
 }
 
 int hwrm_send_message(struct bnxt *bp, void *msg, u32 msg_len, int timeout)
-- 
1.8.3.1
