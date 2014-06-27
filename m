From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/4] be2net: remove be_cmd_get_profile_config_mbox/mccq() variants
Date: Fri, 27 Jun 2014 17:13:18 +0530
Message-ID: <1403869401-6545-2-git-send-email-sathya.perla@emulex.com>
References: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3476 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbaF0Lku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 07:40:50 -0400
In-Reply-To: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Fix be_cmd_get_profile_cmd() to use be_cmd_notify_wait() routine,
which uses MBOX if MCCQ has not been created. Doing this reduces
code duplication; we don't need the _mbox/_mccq() variants anymore.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   81 +++++----------------------
 1 files changed, 14 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f4ea349..0e2f6e1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3440,76 +3440,16 @@ err:
 	return status;
 }
 
-/* Uses mbox */
-static int be_cmd_get_profile_config_mbox(struct be_adapter *adapter,
-					  u8 domain, struct be_dma_mem *cmd)
-{
-	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_get_profile_config *req;
-	int status;
-
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
-	wrb = wrb_from_mbox(adapter);
-
-	req = cmd->va;
-	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			       OPCODE_COMMON_GET_PROFILE_CONFIG,
-			       cmd->size, wrb, cmd);
-
-	req->type = ACTIVE_PROFILE_TYPE;
-	req->hdr.domain = domain;
-	if (!lancer_chip(adapter))
-		req->hdr.version = 1;
-
-	status = be_mbox_notify_wait(adapter);
-
-	mutex_unlock(&adapter->mbox_lock);
-	return status;
-}
-
-/* Uses sync mcc */
-static int be_cmd_get_profile_config_mccq(struct be_adapter *adapter,
-					  u8 domain, struct be_dma_mem *cmd)
-{
-	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_get_profile_config *req;
-	int status;
-
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-
-	req = cmd->va;
-	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			       OPCODE_COMMON_GET_PROFILE_CONFIG,
-			       cmd->size, wrb, cmd);
-
-	req->type = ACTIVE_PROFILE_TYPE;
-	req->hdr.domain = domain;
-	if (!lancer_chip(adapter))
-		req->hdr.version = 1;
-
-	status = be_mcc_notify_wait(adapter);
-
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
-	return status;
-}
-
-/* Uses sync mcc, if MCCQ is already created otherwise mbox */
+/* Will use MBOX only if MCCQ has not been created */
 int be_cmd_get_profile_config(struct be_adapter *adapter,
 			      struct be_resources *res, u8 domain)
 {
 	struct be_cmd_resp_get_profile_config *resp;
+	struct be_cmd_req_get_profile_config *req;
 	struct be_pcie_res_desc *pcie;
 	struct be_port_res_desc *port;
 	struct be_nic_res_desc *nic;
-	struct be_queue_info *mccq = &adapter->mcc_obj.q;
+	struct be_mcc_wrb wrb = {0};
 	struct be_dma_mem cmd;
 	u32 desc_count;
 	int status;
@@ -3520,10 +3460,17 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	if (!cmd.va)
 		return -ENOMEM;
 
-	if (!mccq->created)
-		status = be_cmd_get_profile_config_mbox(adapter, domain, &cmd);
-	else
-		status = be_cmd_get_profile_config_mccq(adapter, domain, &cmd);
+	req = cmd.va;
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_GET_PROFILE_CONFIG,
+			       cmd.size, &wrb, &cmd);
+
+	req->hdr.domain = domain;
+	if (!lancer_chip(adapter))
+		req->hdr.version = 1;
+	req->type = ACTIVE_PROFILE_TYPE;
+
+	status = be_cmd_notify_wait(adapter, &wrb);
 	if (status)
 		goto err;
 
-- 
1.7.1
