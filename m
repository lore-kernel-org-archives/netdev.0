From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 09/11] be2net: use GET_MAC_LIST cmd to query mac-address from a pmac-id
Date: Wed, 15 Jan 2014 13:23:39 +0530
Message-ID: <1389772421-24925-10-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20741 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaAOHtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:22 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

The use of NTKW_MAC_QUERY cmd has been deprecated for Skyhawk-R.
Replace the last remaining usage in be_vfs_mac_query() routine.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   22 ++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    6 ++++--
 drivers/net/ethernet/emulex/benet/be_main.c |   12 +++++-------
 3 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index cf5b8b0..5635f1e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2742,7 +2742,8 @@ err:
  *		  If pmac_id is returned, pmac_id_valid is returned as true
  */
 int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
-			     bool *pmac_id_valid, u32 *pmac_id, u8 domain)
+			     bool *pmac_id_valid, u32 *pmac_id, u32 if_handle,
+			     u8 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_mac_list *req;
@@ -2780,7 +2781,7 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 	req->mac_type = MAC_ADDRESS_TYPE_NETWORK;
 	if (*pmac_id_valid) {
 		req->mac_id = cpu_to_le32(*pmac_id);
-		req->iface_id = cpu_to_le16(adapter->if_handle);
+		req->iface_id = cpu_to_le16(if_handle);
 		req->perm_override = 0;
 	} else {
 		req->perm_override = 1;
@@ -2833,17 +2834,21 @@ out:
 	return status;
 }
 
-int be_cmd_get_active_mac(struct be_adapter *adapter, u32 curr_pmac_id, u8 *mac)
+int be_cmd_get_active_mac(struct be_adapter *adapter, u32 curr_pmac_id, u8 *mac,
+			  u32 if_handle, bool active, u32 domain)
 {
-	bool active = true;
 
+	if (!active)
+		be_cmd_get_mac_from_list(adapter, mac, &active, &curr_pmac_id,
+					 if_handle, domain);
 	if (BEx_chip(adapter))
 		return be_cmd_mac_addr_query(adapter, mac, false,
-					     adapter->if_handle, curr_pmac_id);
+					     if_handle, curr_pmac_id);
 	else
 		/* Fetch the MAC address using pmac_id */
 		return be_cmd_get_mac_from_list(adapter, mac, &active,
-						&curr_pmac_id, 0);
+						&curr_pmac_id,
+						if_handle, domain);
 }
 
 int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac)
@@ -2862,7 +2867,7 @@ int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac)
 						       adapter->if_handle, 0);
 	} else {
 		status = be_cmd_get_mac_from_list(adapter, mac, &pmac_valid,
-						  NULL, 0);
+						  NULL, adapter->if_handle, 0);
 	}
 
 	return status;
@@ -2923,7 +2928,8 @@ int be_cmd_set_mac(struct be_adapter *adapter, u8 *mac, int if_id, u32 dom)
 	int status;
 
 	status = be_cmd_get_mac_from_list(adapter, old_mac, &active_mac,
-					  &pmac_id, dom);
+					  &pmac_id, if_id, dom);
+
 	if (!status && active_mac)
 		be_cmd_pmac_del(adapter, if_id, pmac_id, dom);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index da182c0..fc4e076 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2057,8 +2057,10 @@ int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 privileges,
 			     u32 vf_num);
 int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
-			     bool *pmac_id_active, u32 *pmac_id, u8 domain);
-int be_cmd_get_active_mac(struct be_adapter *adapter, u32 pmac_id, u8 *mac);
+			     bool *pmac_id_active, u32 *pmac_id,
+			     u32 if_handle, u8 domain);
+int be_cmd_get_active_mac(struct be_adapter *adapter, u32 pmac_id, u8 *mac,
+			  u32 if_handle, bool active, u32 domain);
 int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac);
 int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array, u8 mac_count,
 			u32 domain);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9704a1b..43cb458 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -280,7 +280,8 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	/* Decide if the new MAC is successfully activated only after
 	 * querying the FW
 	 */
-	status = be_cmd_get_active_mac(adapter, curr_pmac_id, mac);
+	status = be_cmd_get_active_mac(adapter, curr_pmac_id, mac,
+				       adapter->if_handle, true, 0);
 	if (status)
 		goto err;
 
@@ -2872,14 +2873,11 @@ static int be_vfs_mac_query(struct be_adapter *adapter)
 	int status, vf;
 	u8 mac[ETH_ALEN];
 	struct be_vf_cfg *vf_cfg;
-	bool active = false;
 
 	for_all_vfs(adapter, vf_cfg, vf) {
-		be_cmd_get_mac_from_list(adapter, mac, &active,
-					 &vf_cfg->pmac_id, 0);
-
-		status = be_cmd_mac_addr_query(adapter, mac, false,
-					       vf_cfg->if_handle, 0);
+		status = be_cmd_get_active_mac(adapter, vf_cfg->pmac_id,
+					       mac, vf_cfg->if_handle,
+					       false, vf+1);
 		if (status)
 			return status;
 		memcpy(vf_cfg->mac_addr, mac, ETH_ALEN);
-- 
1.7.1
