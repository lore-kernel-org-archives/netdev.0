From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH net-2.6] be2net: Bug fix to avoid disabling bottom half
 during firmware upgrade.
Date: Tue, 25 May 2010 13:45:24 +0530
Message-ID: <20100525081514.GA5695@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44455 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754367Ab0EYIP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 04:15:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Certain firmware commands/operations to upgrade firmware could take several
seconds to complete. The code presently disables bottom half during these
operations which could lead to unpredictable behaviour in certain cases. This
patch now does all firmware upgrade operations asynchronously using a
completion variable.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h      |    2 ++
 drivers/net/benet/be_cmds.c |   19 +++++++++++++++++--
 drivers/net/benet/be_main.c |    1 +
 3 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 373c1a5..b46be49 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -283,6 +283,8 @@ struct be_adapter {
 	u8 port_type;
 	u8 transceiver;
 	u8 generation;		/* BladeEngine ASIC generation */
+	u32 flash_status;
+	struct completion flash_compl;
 
 	bool sriov_enabled;
 	u32 vf_if_handle[BE_MAX_VF];
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index e79bf8b..c911bfb 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -59,6 +59,13 @@ static int be_mcc_compl_process(struct b
 
 	compl_status = (compl->status >> CQE_STATUS_COMPL_SHIFT) &
 				CQE_STATUS_COMPL_MASK;
+
+	if ((compl->tag0 == OPCODE_COMMON_WRITE_FLASHROM) &&
+		(compl->tag1 == CMD_SUBSYSTEM_COMMON)) {
+		adapter->flash_status = compl_status;
+		complete(&adapter->flash_compl);
+	}
+
 	if (compl_status == MCC_STATUS_SUCCESS) {
 		if (compl->tag0 == OPCODE_ETH_GET_STATISTICS) {
 			struct be_cmd_resp_get_stats *resp =
@@ -1417,6 +1424,7 @@ int be_cmd_write_flashrom(struct be_adap
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
+	adapter->flash_status = 0;
 
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
@@ -1428,6 +1436,7 @@ int be_cmd_write_flashrom(struct be_adap
 
 	be_wrb_hdr_prepare(wrb, cmd->size, false, 1,
 			OPCODE_COMMON_WRITE_FLASHROM);
+	wrb->tag1 = CMD_SUBSYSTEM_COMMON;
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_WRITE_FLASHROM, cmd->size);
@@ -1439,10 +1448,16 @@ int be_cmd_write_flashrom(struct be_adap
 	req->params.op_code = cpu_to_le32(flash_opcode);
 	req->params.data_buf_size = cpu_to_le32(buf_size);
 
-	status = be_mcc_notify_wait(adapter);
+	be_mcc_notify(adapter);
+	spin_unlock_bh(&adapter->mcc_lock);
+
+	if (!wait_for_completion_timeout(&adapter->flash_compl,
+			msecs_to_jiffies(12000)))
+		status = -1;
+	else
+		status = adapter->flash_status;
 
 err:
-	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1c79c20..aa065c7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2319,6 +2319,7 @@ static int be_ctrl_init(struct be_adapte
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 
+	init_completion(&adapter->flash_compl);
 	pci_save_state(adapter->pdev);
 	return 0;
 
-- 
1.4.0

