From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/6] be2net: use SET/GET_MAC_LIST for SH-R
Date: Tue, 23 Jul 2013 15:25:03 +0530
Message-ID: <1374573304-6865-6-git-send-email-sathya.perla@emulex.com>
References: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:49017 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328Ab3GWJwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 05:52:02 -0400
In-Reply-To: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SH-R and Lancer-R, GET_MAC_LIST cmd is better supported
(instead of NTWK_MAC_QUERY cmd) to query provisioned MAC addresses.
Similiarly, (on SH-R and Lancer-R) SET_MAC_LIST must be used by the PF to
provision a permanent MAC addresses to the VF.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   49 ++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +
 drivers/net/ethernet/emulex/benet/be_main.c |   35 ++++++++-----------
 3 files changed, 50 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f4ee94e..613d887 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2740,19 +2740,15 @@ out:
 
 int be_cmd_get_active_mac(struct be_adapter *adapter, u32 curr_pmac_id, u8 *mac)
 {
-	int status;
 	bool active = true;
 
-	/* When SH FW is ready, SH should use Lancer path too */
-	if (lancer_chip(adapter)) {
-		/* Fetch the MAC address using pmac_id */
-		status = be_cmd_get_mac_from_list(adapter, mac, &active,
-						  &curr_pmac_id, 0);
-		return status;
-	} else {
+	if (BEx_chip(adapter))
 		return be_cmd_mac_addr_query(adapter, mac, false,
 					     adapter->if_handle, curr_pmac_id);
-	}
+	else
+		/* Fetch the MAC address using pmac_id */
+		return be_cmd_get_mac_from_list(adapter, mac, &active,
+						&curr_pmac_id, 0);
 }
 
 int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac)
@@ -2762,14 +2758,18 @@ int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac)
 
 	memset(mac, 0, ETH_ALEN);
 
-	if (lancer_chip(adapter))
+	if (BEx_chip(adapter)) {
+		if (be_physfn(adapter))
+			status = be_cmd_mac_addr_query(adapter, mac, true, 0,
+						       0);
+		else
+			status = be_cmd_mac_addr_query(adapter, mac, false,
+						       adapter->if_handle, 0);
+	} else {
 		status = be_cmd_get_mac_from_list(adapter, mac, &pmac_valid,
 						  NULL, 0);
-	else if (be_physfn(adapter))
-		status = be_cmd_mac_addr_query(adapter, mac, true, 0, 0);
-	else
-		status = be_cmd_mac_addr_query(adapter, mac, false,
-					       adapter->if_handle, 0);
+	}
+
 	return status;
 }
 
@@ -2816,6 +2816,25 @@ err:
 	return status;
 }
 
+/* Wrapper to delete any active MACs and provision the new mac.
+ * Changes to MAC_LIST are allowed iff none of the MAC addresses in the
+ * current list are active.
+ */
+int be_cmd_set_mac(struct be_adapter *adapter, u8 *mac, int if_id, u32 dom)
+{
+	bool active_mac = false;
+	u8 old_mac[ETH_ALEN];
+	u32 pmac_id;
+	int status;
+
+	status = be_cmd_get_mac_from_list(adapter, old_mac, &active_mac,
+					  &pmac_id, dom);
+	if (!status && active_mac)
+		be_cmd_pmac_del(adapter, if_id, pmac_id, dom);
+
+	return be_cmd_set_mac_list(adapter, mac, mac ? 1 : 0, dom);
+}
+
 int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 			u32 domain, u16 intf_id)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5e9e2b0..eb541f0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1937,6 +1937,8 @@ extern int be_cmd_get_active_mac(struct be_adapter *adapter, u32 pmac_id,
 extern int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac);
 extern int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
 						u8 mac_count, u32 domain);
+extern int be_cmd_set_mac(struct be_adapter *adapter, u8 *mac, int if_id,
+			  u32 dom);
 extern int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 			u32 domain, u16 intf_id);
 extern int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 97279af..9b22791 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1140,9 +1140,6 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
 	int status;
-	bool active_mac = false;
-	u32 pmac_id;
-	u8 old_mac[ETH_ALEN];
 
 	if (!sriov_enabled(adapter))
 		return -EPERM;
@@ -1150,20 +1147,15 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!is_valid_ether_addr(mac) || vf >= adapter->num_vfs)
 		return -EINVAL;
 
-	if (lancer_chip(adapter)) {
-		status = be_cmd_get_mac_from_list(adapter, old_mac, &active_mac,
-						  &pmac_id, vf + 1);
-		if (!status && active_mac)
-			be_cmd_pmac_del(adapter, vf_cfg->if_handle,
-					pmac_id, vf + 1);
-
-		status = be_cmd_set_mac_list(adapter,  mac, 1, vf + 1);
-	} else {
-		status = be_cmd_pmac_del(adapter, vf_cfg->if_handle,
-					 vf_cfg->pmac_id, vf + 1);
+	if (BEx_chip(adapter)) {
+		be_cmd_pmac_del(adapter, vf_cfg->if_handle, vf_cfg->pmac_id,
+				vf + 1);
 
 		status = be_cmd_pmac_add(adapter, mac, vf_cfg->if_handle,
 					 &vf_cfg->pmac_id, vf + 1);
+	} else {
+		status = be_cmd_set_mac(adapter, mac, vf_cfg->if_handle,
+					vf + 1);
 	}
 
 	if (status)
@@ -2729,13 +2721,13 @@ static int be_vf_eth_addr_config(struct be_adapter *adapter)
 	be_vf_eth_addr_generate(adapter, mac);
 
 	for_all_vfs(adapter, vf_cfg, vf) {
-		if (lancer_chip(adapter)) {
-			status = be_cmd_set_mac_list(adapter,  mac, 1, vf + 1);
-		} else {
+		if (BEx_chip(adapter))
 			status = be_cmd_pmac_add(adapter, mac,
 						 vf_cfg->if_handle,
 						 &vf_cfg->pmac_id, vf + 1);
-		}
+		else
+			status = be_cmd_set_mac(adapter, mac, vf_cfg->if_handle,
+						vf + 1);
 
 		if (status)
 			dev_err(&adapter->pdev->dev,
@@ -2782,11 +2774,12 @@ static void be_vf_clear(struct be_adapter *adapter)
 	pci_disable_sriov(adapter->pdev);
 
 	for_all_vfs(adapter, vf_cfg, vf) {
-		if (lancer_chip(adapter))
-			be_cmd_set_mac_list(adapter, NULL, 0, vf + 1);
-		else
+		if (BEx_chip(adapter))
 			be_cmd_pmac_del(adapter, vf_cfg->if_handle,
 					vf_cfg->pmac_id, vf + 1);
+		else
+			be_cmd_set_mac(adapter, NULL, vf_cfg->if_handle,
+				       vf + 1);
 
 		be_cmd_if_destroy(adapter, vf_cfg->if_handle, vf + 1);
 	}
-- 
1.7.1
