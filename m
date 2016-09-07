From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 3/6] be2net: Add privilege level check for OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES SLI cmd.
Date: Wed,  7 Sep 2016 19:57:51 +0530
Message-ID: <20160907142754.13284-4-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S934334AbcIGOpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:55 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@broadcom.com>

Driver issues OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES cmd during init which
when issued by VFs results in the logging of a cmd failure message since
they don't have the required privilege for this cmd. Fix by checking
privilege before issuing the cmd.

Also fixed typo in CAPABILITIES.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 13 +++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |  4 ++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 92794f3..15d02da 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -92,6 +92,11 @@ static struct be_cmd_priv_map cmd_priv_map[] = {
 		CMD_SUBSYSTEM_COMMON,
 		BE_PRIV_DEVCFG | BE_PRIV_VHADM
 	},
+	{
+		OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES,
+		CMD_SUBSYSTEM_COMMON,
+		BE_PRIV_DEVCFG
+	}
 };
 
 static bool be_cmd_allowed(struct be_adapter *adapter, u8 opcode, u8 subsystem)
@@ -4127,6 +4132,10 @@ int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 	struct be_cmd_req_get_ext_fat_caps *req;
 	int status;
 
+	if (!be_cmd_allowed(adapter, OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES,
+			    CMD_SUBSYSTEM_COMMON))
+		return -EPERM;
+
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
 
@@ -4138,7 +4147,7 @@ int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 
 	req = cmd->va;
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			       OPCODE_COMMON_GET_EXT_FAT_CAPABILITES,
+			       OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES,
 			       cmd->size, wrb, cmd);
 	req->parameter_type = cpu_to_le32(1);
 
@@ -4167,7 +4176,7 @@ int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 	req = cmd->va;
 	memcpy(&req->set_params, configs, sizeof(struct be_fat_conf_params));
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			       OPCODE_COMMON_SET_EXT_FAT_CAPABILITES,
+			       OPCODE_COMMON_SET_EXT_FAT_CAPABILITIES,
 			       cmd->size, wrb, cmd);
 
 	status = be_mcc_notify_wait(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 686cbe0..1bd82bc 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -295,8 +295,8 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
-#define OPCODE_COMMON_GET_EXT_FAT_CAPABILITES		125
-#define OPCODE_COMMON_SET_EXT_FAT_CAPABILITES		126
+#define OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES		125
+#define OPCODE_COMMON_SET_EXT_FAT_CAPABILITIES		126
 #define OPCODE_COMMON_GET_MAC_LIST			147
 #define OPCODE_COMMON_SET_MAC_LIST			148
 #define OPCODE_COMMON_GET_HSW_CONFIG			152
-- 
2.10.0.rc2.20.g5b18e70
