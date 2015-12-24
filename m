From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [net-next PATCH 01/10] be2net: fix VF link state transition from disabled to auto
Date: Thu, 24 Dec 2015 04:26:23 -0500
Message-ID: <1450949192-4574-2-git-send-email-sathya.perla@avagotech.com>
References: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:64903 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752954AbbLXJnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:43:37 -0500
In-Reply-To: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

The VF link state setting transition from "disable" to "auto" does not work
due to a bug in SET_LOGICAL_LINK_CONFIG_V1 cmd in FW. This issue could not
be fixed in FW due to some backward compatibility issues it causes with
some released drivers. The issue has been fixed by introducing a new
version (v2) of the cmd from 10.6 FW onwards. In v2, to set the VF link
state to auto, both PLINK_ENABLE and PLINK_TRACK bits have to be set to 1.

The VF link state setting feature now works on Lancer chips too from
FW ver 10.6.315.0 onwards.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 35 +++++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |  3 ++-
 2 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 1795c93..8083eca 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4260,16 +4260,13 @@ err:
 	return status;
 }
 
-int be_cmd_set_logical_link_config(struct be_adapter *adapter,
-				   int link_state, u8 domain)
+int __be_cmd_set_logical_link_config(struct be_adapter *adapter,
+				     int link_state, int version, u8 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_ll_link *req;
 	int status;
 
-	if (BEx_chip(adapter) || lancer_chip(adapter))
-		return -EOPNOTSUPP;
-
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -4284,14 +4281,15 @@ int be_cmd_set_logical_link_config(struct be_adapter *adapter,
 			       OPCODE_COMMON_SET_LOGICAL_LINK_CONFIG,
 			       sizeof(*req), wrb, NULL);
 
-	req->hdr.version = 1;
+	req->hdr.version = version;
 	req->hdr.domain = domain;
 
-	if (link_state == IFLA_VF_LINK_STATE_ENABLE)
-		req->link_config |= 1;
+	if (link_state == IFLA_VF_LINK_STATE_ENABLE ||
+	    link_state == IFLA_VF_LINK_STATE_AUTO)
+		req->link_config |= PLINK_ENABLE;
 
 	if (link_state == IFLA_VF_LINK_STATE_AUTO)
-		req->link_config |= 1 << PLINK_TRACK_SHIFT;
+		req->link_config |= PLINK_TRACK;
 
 	status = be_mcc_notify_wait(adapter);
 err:
@@ -4299,6 +4297,25 @@ err:
 	return status;
 }
 
+int be_cmd_set_logical_link_config(struct be_adapter *adapter,
+				   int link_state, u8 domain)
+{
+	int status;
+
+	if (BEx_chip(adapter))
+		return -EOPNOTSUPP;
+
+	status = __be_cmd_set_logical_link_config(adapter, link_state,
+						  2, domain);
+
+	/* Version 2 of the command will not be recognized by older FW.
+	 * On such a failure issue version 1 of the command.
+	 */
+	if (base_status(status) == MCC_STATUS_ILLEGAL_REQUEST)
+		status = __be_cmd_set_logical_link_config(adapter, link_state,
+							  1, domain);
+	return status;
+}
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 		    int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 91155ea..9690c3a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2246,7 +2246,8 @@ struct be_cmd_resp_get_iface_list {
 };
 
 /*************** Set logical link ********************/
-#define PLINK_TRACK_SHIFT	8
+#define PLINK_ENABLE            BIT(0)
+#define PLINK_TRACK             BIT(8)
 struct be_cmd_req_set_ll_link {
 	struct be_cmd_req_hdr hdr;
 	u32 link_config; /* Bit 0: UP_DOWN, Bit 9: PLINK */
-- 
2.4.1
