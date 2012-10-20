From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 10/14] be2net: Fix VF driver load on newer Lancer FW
Date: Sat, 20 Oct 2012 21:33:49 +0530
Message-ID: <a9c2d8ef-0a9b-4b7d-ac4a-cb6a4833fef8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40027 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab2JTQE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:04:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PF driver should enable VF so that VF goes to ready state in
new Lancer FW.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   32 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    8 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 15202d0..8d35750 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3131,6 +3131,38 @@ err:
 	return status;
 }
 
+/* Uses sync mcc */
+int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_enable_disable_vf *req;
+	int status;
+
+	if (!lancer_chip(adapter))
+		return 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_ENABLE_DISABLE_VF, sizeof(*req),
+			       wrb, NULL);
+
+	req->hdr.domain = domain;
+	req->enable = 1;
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 			int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index a438777..68de6c6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -203,6 +203,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_FN_PRIVILEGES			170
 #define OPCODE_COMMON_READ_OBJECT			171
 #define OPCODE_COMMON_WRITE_OBJECT			172
+#define OPCODE_COMMON_ENABLE_DISABLE_VF			196
 
 #define OPCODE_ETH_RSS_CONFIG				1
 #define OPCODE_ETH_ACPI_CONFIG				2
@@ -1802,6 +1803,12 @@ struct be_cmd_resp_set_profile_config {
 	struct be_cmd_req_hdr hdr;
 };
 
+struct be_cmd_enable_disable_vf {
+	struct be_cmd_req_hdr hdr;
+	u8 enable;
+	u8 rsvd[3];
+};
+
 static inline bool check_privilege(struct be_adapter *adapter, u32 flags)
 {
 	return flags & adapter->cmd_privileges ? true : false;
@@ -1929,3 +1936,4 @@ extern int be_cmd_get_profile_config(struct be_adapter *adapter, u32 *cap_flags,
 
 extern int be_cmd_set_profile_config(struct be_adapter *adapter, u32 bps,
 				     u8 domain);
+extern int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 410834d..136ed64 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2731,6 +2731,8 @@ static int be_vf_setup(struct be_adapter *adapter)
 		if (status)
 			goto err;
 		vf_cfg->def_vid = def_vlan;
+
+		be_cmd_enable_vf(adapter, vf + 1);
 	}
 	return 0;
 err:
-- 
1.6.0.2
