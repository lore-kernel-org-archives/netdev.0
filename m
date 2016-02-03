From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH v2 net-next 5/8] be2net: Don't run ethtool self-tests for VFs
Date: Wed,  3 Feb 2016 09:49:20 +0530
Message-ID: <1454473163-18781-6-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:52531 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755659AbcBCEVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 23:21:16 -0500
In-Reply-To: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@broadcom.com>

The CMD_SUBSYSTEM_LOWLEVEL cmds need DEV_CFG Privilege to run
which VFs don't have by default.
Self-tests need to be issued only for PFs.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3b665f1..7d51d47 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -65,7 +65,22 @@ static struct be_cmd_priv_map cmd_priv_map[] = {
 		CMD_SUBSYSTEM_COMMON,
 		BE_PRIV_LNKMGMT | BE_PRIV_VHADM |
 		BE_PRIV_DEVCFG | BE_PRIV_DEVSEC
-	}
+	},
+	{
+		OPCODE_LOWLEVEL_HOST_DDR_DMA,
+		CMD_SUBSYSTEM_LOWLEVEL,
+		BE_PRIV_DEVCFG | BE_PRIV_DEVSEC
+	},
+	{
+		OPCODE_LOWLEVEL_LOOPBACK_TEST,
+		CMD_SUBSYSTEM_LOWLEVEL,
+		BE_PRIV_DEVCFG | BE_PRIV_DEVSEC
+	},
+	{
+		OPCODE_LOWLEVEL_SET_LOOPBACK_MODE,
+		CMD_SUBSYSTEM_LOWLEVEL,
+		BE_PRIV_DEVCFG | BE_PRIV_DEVSEC
+	},
 };
 
 static bool be_cmd_allowed(struct be_adapter *adapter, u8 opcode, u8 subsystem)
@@ -3169,6 +3184,10 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 	struct be_cmd_req_set_lmode *req;
 	int status;
 
+	if (!be_cmd_allowed(adapter, OPCODE_LOWLEVEL_SET_LOOPBACK_MODE,
+			    CMD_SUBSYSTEM_LOWLEVEL))
+		return -EPERM;
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -3214,6 +3233,10 @@ int be_cmd_loopback_test(struct be_adapter *adapter, u32 port_num,
 	struct be_cmd_resp_loopback_test *resp;
 	int status;
 
+	if (!be_cmd_allowed(adapter, OPCODE_LOWLEVEL_LOOPBACK_TEST,
+			    CMD_SUBSYSTEM_LOWLEVEL))
+		return -EPERM;
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -3260,6 +3283,10 @@ int be_cmd_ddr_dma_test(struct be_adapter *adapter, u64 pattern,
 	int status;
 	int i, j = 0;
 
+	if (!be_cmd_allowed(adapter, OPCODE_LOWLEVEL_HOST_DDR_DMA,
+			    CMD_SUBSYSTEM_LOWLEVEL))
+		return -EPERM;
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
-- 
2.3.0.rc2
