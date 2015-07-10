From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 8/9] be2net: make SET_LOOPBACK_MODE cmd asynchrounous
Date: Fri, 10 Jul 2015 05:32:50 -0400
Message-ID: <1436520771-11656-9-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56759 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753438AbbGJJ0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:38 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

The SET_LOOPBACK_MODE command is always issued from ethtool only in a
process context. So, while waiting for the cmd to complete, the driver
can sleep instead of holding spin_lock_bh() on the mcc_lock. This is done
by calling be_mcc_notify() instead of be_mcc_notify_wait() (that returns
only after the cmd completes while the MCCQ is locked).

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 23 ++++++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  2 ++
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 15 +++++++++++++--
 3 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 93934d3..ecad46f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -172,6 +172,12 @@ static void be_async_cmd_process(struct be_adapter *adapter,
 		return;
 	}
 
+	if (opcode == OPCODE_LOWLEVEL_SET_LOOPBACK_MODE &&
+	    subsystem == CMD_SUBSYSTEM_LOWLEVEL) {
+		complete(&adapter->et_cmd_compl);
+		return;
+	}
+
 	if ((opcode == OPCODE_COMMON_WRITE_FLASHROM ||
 	     opcode == OPCODE_COMMON_WRITE_OBJECT) &&
 	    subsystem == CMD_SUBSYSTEM_COMMON) {
@@ -2600,7 +2606,7 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
 		status = -EBUSY;
-		goto err;
+		goto err_unlock;
 	}
 
 	req = embedded_payload(wrb);
@@ -2614,8 +2620,19 @@ int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 	req->loopback_type = loopback_type;
 	req->loopback_state = enable;
 
-	status = be_mcc_notify_wait(adapter);
-err:
+	status = be_mcc_notify(adapter);
+	if (status)
+		goto err_unlock;
+
+	spin_unlock_bh(&adapter->mcc_lock);
+
+	if (!wait_for_completion_timeout(&adapter->et_cmd_compl,
+					 msecs_to_jiffies(SET_LB_MODE_TIMEOUT)))
+		status = -ETIMEDOUT;
+
+	return status;
+
+err_unlock:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index f0a92b7..a4479f7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1495,6 +1495,8 @@ struct be_cmd_resp_acpi_wol_magic_config_v1 {
 #define BE_PME_D3COLD_CAP		0x80
 
 /********************** LoopBack test *********************/
+#define SET_LB_MODE_TIMEOUT		12000
+
 struct be_cmd_req_loopback_test {
 	struct be_cmd_req_hdr hdr;
 	u32 loopback_type;
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index b2476db..d20ff05 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -847,10 +847,21 @@ err:
 static u64 be_loopback_test(struct be_adapter *adapter, u8 loopback_type,
 			    u64 *status)
 {
-	be_cmd_set_loopback(adapter, adapter->hba_port_num, loopback_type, 1);
+	int ret;
+
+	ret = be_cmd_set_loopback(adapter, adapter->hba_port_num,
+				  loopback_type, 1);
+	if (ret)
+		return ret;
+
 	*status = be_cmd_loopback_test(adapter, adapter->hba_port_num,
 				       loopback_type, 1500, 2, 0xabc);
-	be_cmd_set_loopback(adapter, adapter->hba_port_num, BE_NO_LOOPBACK, 1);
+
+	ret = be_cmd_set_loopback(adapter, adapter->hba_port_num,
+				  BE_NO_LOOPBACK, 1);
+	if (ret)
+		return ret;
+
 	return *status;
 }
 
-- 
2.4.1
