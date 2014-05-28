From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/6] be2net: move async cmd processing to a separate routine
Date: Wed, 28 May 2014 12:01:04 +0530
Message-ID: <1401258665-6238-6-git-send-email-sathya.perla@emulex.com>
References: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:44468 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbaE1G2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 02:28:15 -0400
In-Reply-To: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some FW cmds, the caller just issues the cmd and doesn't wait for a
response. The response handling is done in the MCCQ compl processing context
only. Move this code into a separate routine to make be_mcc_compl_process()
more manageable.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   92 ++++++++++++++++-----------
 1 files changed, 54 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index a2ecdff..de3bd8c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -132,13 +132,61 @@ static bool be_skip_err_log(u8 opcode, u16 base_status, u16 addl_status)
 		return false;
 }
 
+/* Place holder for all the async MCC cmds wherein the caller is not in a busy
+ * loop (has not issued be_mcc_notify_wait())
+ */
+static void be_async_cmd_process(struct be_adapter *adapter,
+				 struct be_mcc_compl *compl,
+				 struct be_cmd_resp_hdr *resp_hdr)
+{
+	enum mcc_base_status base_status = base_status(compl->status);
+	u8 opcode = resp_hdr->opcode;
+	u8 subsystem = resp_hdr->subsystem;
+
+	if (opcode == OPCODE_LOWLEVEL_LOOPBACK_TEST &&
+	    subsystem == CMD_SUBSYSTEM_LOWLEVEL) {
+		complete(&adapter->et_cmd_compl);
+		return;
+	}
+
+	if ((opcode == OPCODE_COMMON_WRITE_FLASHROM ||
+	     opcode == OPCODE_COMMON_WRITE_OBJECT) &&
+	    subsystem == CMD_SUBSYSTEM_COMMON) {
+		adapter->flash_status = compl->status;
+		complete(&adapter->et_cmd_compl);
+		return;
+	}
+
+	if ((opcode == OPCODE_ETH_GET_STATISTICS ||
+	     opcode == OPCODE_ETH_GET_PPORT_STATS) &&
+	    subsystem == CMD_SUBSYSTEM_ETH &&
+	    base_status == MCC_STATUS_SUCCESS) {
+		be_parse_stats(adapter);
+		adapter->stats_cmd_sent = false;
+		return;
+	}
+
+	if (opcode == OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES &&
+	    subsystem == CMD_SUBSYSTEM_COMMON) {
+		if (base_status == MCC_STATUS_SUCCESS) {
+			struct be_cmd_resp_get_cntl_addnl_attribs *resp =
+							(void *)resp_hdr;
+			adapter->drv_stats.be_on_die_temperature =
+						resp->on_die_temperature;
+		} else {
+			adapter->be_get_temp_freq = 0;
+		}
+		return;
+	}
+}
+
 static int be_mcc_compl_process(struct be_adapter *adapter,
 				struct be_mcc_compl *compl)
 {
 	enum mcc_base_status base_status;
 	enum mcc_addl_status addl_status;
 	struct be_cmd_resp_hdr *resp_hdr;
-	u8 opcode = 0, subsystem = 0;
+	u8 opcode, subsystem;
 
 	/* Just swap the status to host endian; mcc tag is opaquely copied
 	 * from mcc_wrb */
@@ -148,45 +196,13 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	addl_status = addl_status(compl->status);
 
 	resp_hdr = be_decode_resp_hdr(compl->tag0, compl->tag1);
+	opcode = resp_hdr->opcode;
+	subsystem = resp_hdr->subsystem;
 
-	if (resp_hdr) {
-		opcode = resp_hdr->opcode;
-		subsystem = resp_hdr->subsystem;
-	}
-
-	if (opcode == OPCODE_LOWLEVEL_LOOPBACK_TEST &&
-	    subsystem == CMD_SUBSYSTEM_LOWLEVEL) {
-		complete(&adapter->et_cmd_compl);
-		return 0;
-	}
-
-	if (((opcode == OPCODE_COMMON_WRITE_FLASHROM) ||
-	     (opcode == OPCODE_COMMON_WRITE_OBJECT)) &&
-	    (subsystem == CMD_SUBSYSTEM_COMMON)) {
-		adapter->flash_status = compl->status;
-		complete(&adapter->et_cmd_compl);
-	}
-
-	if (base_status == MCC_STATUS_SUCCESS) {
-		if (((opcode == OPCODE_ETH_GET_STATISTICS) ||
-		     (opcode == OPCODE_ETH_GET_PPORT_STATS)) &&
-		    (subsystem == CMD_SUBSYSTEM_ETH)) {
-			be_parse_stats(adapter);
-			adapter->stats_cmd_sent = false;
-		}
-		if (opcode == OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES &&
-		    subsystem == CMD_SUBSYSTEM_COMMON) {
-			struct be_cmd_resp_get_cntl_addnl_attribs *resp =
-				(void *)resp_hdr;
-			adapter->drv_stats.be_on_die_temperature =
-				resp->on_die_temperature;
-		}
-	} else {
-		if (opcode == OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES)
-			adapter->be_get_temp_freq = 0;
+	be_async_cmd_process(adapter, compl, resp_hdr);
 
-		if (be_skip_err_log(opcode, base_status, addl_status))
-			return compl->status;
+	if (base_status != MCC_STATUS_SUCCESS &&
+	    !be_skip_err_log(opcode, base_status, addl_status)) {
 
 		if (base_status == MCC_STATUS_UNAUTHORIZED_REQUEST) {
 			dev_warn(&adapter->pdev->dev,
-- 
1.7.1
