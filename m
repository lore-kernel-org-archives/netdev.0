From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: remove unused code in be_cmd_vlan_config()
Date: Fri, 9 May 2014 13:29:17 +0530
Message-ID: <1399622359-25926-6-git-send-email-sathya.perla@emulex.com>
References: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3300 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaEIH4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:56:13 -0400
In-Reply-To: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

For putting interface into vlan promiscuous mode, we use be_cmd_rx_filter()
and not be_cmd_vlan_config(). So remove the "promiscuous" argument from
be_cmd_vlan_config().

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   10 +++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +--
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 411ff9b..5b23664 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1788,7 +1788,7 @@ err:
 
 /* Uses sycnhronous mcc */
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-		       u32 num, bool promiscuous)
+		       u32 num)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_vlan_config *req;
@@ -1808,16 +1808,12 @@ int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 			       wrb, NULL);
 
 	req->interface_id = if_id;
-	req->promiscuous = promiscuous;
 	req->untagged = BE_IF_FLAGS_UNTAGGED & be_if_cap_flags(adapter) ? 1 : 0;
 	req->num_vlan = num;
-	if (!promiscuous) {
-		memcpy(req->normal_vlan, vtag_array,
-		       req->num_vlan * sizeof(vtag_array[0]));
-	}
+	memcpy(req->normal_vlan, vtag_array,
+	       req->num_vlan * sizeof(vtag_array[0]));
 
 	status = be_mcc_notify_wait(adapter);
-
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 4ea79b9..228d4b6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2060,7 +2060,7 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
 		      char *fw_on_flash);
 int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *, int num);
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
-		       u32 num, bool promiscuous);
+		       u32 num);
 int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc);
 int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2cd733b..3f04356 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1108,8 +1108,7 @@ static int be_vid_config(struct be_adapter *adapter)
 	for_each_set_bit(i, adapter->vids, VLAN_N_VID)
 		vids[num++] = cpu_to_le16(i);
 
-	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num, 0);
-
+	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num);
 	if (status) {
 		/* Set to VLAN promisc mode as setting VLAN filter failed */
 		if (status == MCC_ADDL_STS_INSUFFICIENT_RESOURCES)
-- 
1.7.1
