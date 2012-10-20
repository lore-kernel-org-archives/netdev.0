From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 03/14] be2net: Fix change MAC operation for VF for Lancer
Date: Sat, 20 Oct 2012 21:32:13 +0530
Message-ID: <708dbd00-9aed-4ec9-b75c-d4e21e5d4146@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22339 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab2JTQDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:03:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For changing MAC of VF from PF, delete MAC operation needs to be done before
assigning new MAC. Also in ndo_set_mac_address operation avoid delete MAC if
it has been already deleted by PF.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   52 +++++++++++++++++++++-----
 1 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0b49201..41f935a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -237,23 +237,46 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	int status = 0;
 	u8 current_mac[ETH_ALEN];
 	u32 pmac_id = adapter->pmac_id[0];
+	bool active_mac = true;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	status = be_cmd_mac_addr_query(adapter, current_mac, false,
-				       adapter->if_handle, 0);
+	/* For BE VF, MAC address is already activated by PF.
+	 * Hence only operation left is updating netdev->devaddr.
+	 * Update it if user is passing the same MAC which was used
+	 * during configuring VF MAC from PF(Hypervisor).
+	 */
+	if (!lancer_chip(adapter) && !be_physfn(adapter)) {
+		status = be_cmd_mac_addr_query(adapter, current_mac,
+					       false, adapter->if_handle, 0);
+		if (!status && !memcmp(current_mac, addr->sa_data, ETH_ALEN))
+			goto done;
+		else
+			goto err;
+	}
+
+	if (!memcmp(addr->sa_data, netdev->dev_addr, ETH_ALEN))
+		goto done;
+
+	/* For Lancer check if any MAC is active.
+	 * If active, get its mac id.
+	 */
+	if (lancer_chip(adapter) && !be_physfn(adapter))
+		be_cmd_get_mac_from_list(adapter, current_mac, &active_mac,
+					 &pmac_id, 0);
+
+	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
+				 adapter->if_handle,
+				 &adapter->pmac_id[0], 0);
+
 	if (status)
 		goto err;
 
-	if (memcmp(addr->sa_data, current_mac, ETH_ALEN)) {
-		status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
-				adapter->if_handle, &adapter->pmac_id[0], 0);
-		if (status)
-			goto err;
-
-		be_cmd_pmac_del(adapter, adapter->if_handle, pmac_id, 0);
-	}
+	if (active_mac)
+		be_cmd_pmac_del(adapter, adapter->if_handle,
+				pmac_id, 0);
+done:
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	return 0;
 err:
@@ -962,6 +985,9 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
 	int status;
+	bool active_mac = false;
+	u32 pmac_id;
+	u8 old_mac[ETH_ALEN];
 
 	if (!sriov_enabled(adapter))
 		return -EPERM;
@@ -970,6 +996,12 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 		return -EINVAL;
 
 	if (lancer_chip(adapter)) {
+		status = be_cmd_get_mac_from_list(adapter, old_mac, &active_mac,
+						  &pmac_id, vf + 1);
+		if (!status && active_mac)
+			be_cmd_pmac_del(adapter, vf_cfg->if_handle,
+					pmac_id, vf + 1);
+
 		status = be_cmd_set_mac_list(adapter,  mac, 1, vf + 1);
 	} else {
 		status = be_cmd_pmac_del(adapter, vf_cfg->if_handle,
-- 
1.6.0.2
