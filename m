From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/4] be2net: refactor VF setup/teardown code into be_vf_setup/clear()
Date: Mon, 24 Oct 2011 18:15:01 +0530
Message-ID: <1319460303-25560-3-git-send-email-sathya.perla@emulex.com>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:57529 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932276Ab1JXMp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:45:26 -0400
In-Reply-To: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the code for VF setup/teardown done by a PF (if_create, mac_add_config, link_status_query etc) is scattered; this patch refactors this code into be_vf_setup() and be_vf_clear().
The if_create/if_destroy/mac_addr_query cmds are now called after the MCCQ is created; so these cmds are now modified to use the MCCQ instead of MBOX.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   66 +++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  233 ++++++++++++---------------
 3 files changed, 149 insertions(+), 154 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6e7b521..8ae5a4c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -615,7 +615,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 	return status;
 }
 
-/* Uses mbox */
+/* Use MCC */
 int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle)
 {
@@ -623,10 +623,13 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 	struct be_cmd_req_mac_query *req;
 	int status;
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mbox(adapter);
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
@@ -643,13 +646,14 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 		req->permanent = 0;
 	}
 
-	status = be_mbox_notify_wait(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_mac_query *resp = embedded_payload(wrb);
 		memcpy(mac_addr, resp->mac.addr, ETH_ALEN);
 	}
 
-	mutex_unlock(&adapter->mbox_lock);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1111,20 +1115,22 @@ err:
 }
 
 /* Create an rx filtering policy configuration on an i/f
- * Uses mbox
+ * Uses MCCQ 
  */
 int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
-		u8 *mac, bool pmac_invalid, u32 *if_handle, u32 *pmac_id,
-		u32 domain)
+		u8 *mac, u32 *if_handle, u32 *pmac_id, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_if_create *req;
 	int status;
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mbox(adapter);
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
@@ -1136,23 +1142,25 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	req->hdr.domain = domain;
 	req->capability_flags = cpu_to_le32(cap_flags);
 	req->enable_flags = cpu_to_le32(en_flags);
-	req->pmac_invalid = pmac_invalid;
-	if (!pmac_invalid)
+	if (mac)
 		memcpy(req->mac_addr, mac, ETH_ALEN);
+	else
+		req->pmac_invalid = true;
 
-	status = be_mbox_notify_wait(adapter);
+	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_if_create *resp = embedded_payload(wrb);
 		*if_handle = le32_to_cpu(resp->interface_id);
-		if (!pmac_invalid)
+		if (mac)
 			*pmac_id = le32_to_cpu(resp->pmac_id);
 	}
 
-	mutex_unlock(&adapter->mbox_lock);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
-/* Uses mbox */
+/* Uses MCCQ */
 int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
@@ -1162,10 +1170,16 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 	if (adapter->eeh_err)
 		return -EIO;
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
+	if (!interface_id)
+		return 0;
 
-	wrb = wrb_from_mbox(adapter);
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
@@ -1177,10 +1191,9 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 	req->hdr.domain = domain;
 	req->interface_id = cpu_to_le32(interface_id);
 
-	status = be_mbox_notify_wait(adapter);
-
-	mutex_unlock(&adapter->mbox_lock);
-
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
@@ -1301,7 +1314,8 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
 		if (resp->mac_speed != PHY_LINK_SPEED_ZERO) {
 			*link_speed = le16_to_cpu(resp->link_speed);
-			*mac_speed = resp->mac_speed;
+			if (mac_speed)
+				*mac_speed = resp->mac_speed;
 		}
 	}
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index abaa90c..75b7574 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1413,8 +1413,8 @@ extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id,
 			u32 pmac_id, u32 domain);
 extern int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags,
-			u32 en_flags, u8 *mac, bool pmac_invalid,
-			u32 *if_handle, u32 *pmac_id, u32 domain);
+			u32 en_flags, u8 *mac, u32 *if_handle, u32 *pmac_id,
+			u32 domain);
 extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle,
 			u32 domain);
 extern int be_cmd_eq_create(struct be_adapter *adapter,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 88c9dca..4ab182f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2069,7 +2069,7 @@ done:
 	return;
 }
 
-static void be_sriov_enable(struct be_adapter *adapter)
+static int be_sriov_enable(struct be_adapter *adapter)
 {
 	be_check_sriov_fn_type(adapter);
 #ifdef CONFIG_PCI_IOV
@@ -2091,8 +2091,17 @@ static void be_sriov_enable(struct be_adapter *adapter)
 
 		status = pci_enable_sriov(adapter->pdev, num_vfs);
 		adapter->sriov_enabled = status ? false : true;
+
+		if (adapter->sriov_enabled) {
+			adapter->vf_cfg = kcalloc(num_vfs,
+						sizeof(struct be_vf_cfg),
+						GFP_KERNEL);
+			if (!adapter->vf_cfg)
+				return -ENOMEM;
+		}
 	}
 #endif
+	return 0;
 }
 
 static void be_sriov_disable(struct be_adapter *adapter)
@@ -2100,6 +2109,7 @@ static void be_sriov_disable(struct be_adapter *adapter)
 #ifdef CONFIG_PCI_IOV
 	if (adapter->sriov_enabled) {
 		pci_disable_sriov(adapter->pdev);
+		kfree(adapter->vf_cfg);
 		adapter->sriov_enabled = false;
 	}
 #endif
@@ -2405,7 +2415,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
  */
 static inline int be_vf_eth_addr_config(struct be_adapter *adapter)
 {
-	u32 vf = 0;
+	u32 vf;
 	int status = 0;
 	u8 mac[ETH_ALEN];
 
@@ -2427,7 +2437,7 @@ static inline int be_vf_eth_addr_config(struct be_adapter *adapter)
 	return status;
 }
 
-static inline void be_vf_eth_addr_rem(struct be_adapter *adapter)
+static void be_vf_clear(struct be_adapter *adapter)
 {
 	u32 vf;
 
@@ -2437,29 +2447,25 @@ static inline void be_vf_eth_addr_rem(struct be_adapter *adapter)
 					adapter->vf_cfg[vf].vf_if_handle,
 					adapter->vf_cfg[vf].vf_pmac_id, vf + 1);
 	}
+
+	for (vf = 0; vf < num_vfs; vf++)
+		if (adapter->vf_cfg[vf].vf_if_handle)
+			be_cmd_if_destroy(adapter,
+				adapter->vf_cfg[vf].vf_if_handle, vf + 1);
 }
 
 static int be_clear(struct be_adapter *adapter)
 {
-	int vf;
-
 	if (be_physfn(adapter) && adapter->sriov_enabled)
-		be_vf_eth_addr_rem(adapter);
+		be_vf_clear(adapter);
+
+	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
 	be_mcc_queues_destroy(adapter);
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
 	adapter->eq_next_idx = 0;
 
-	if (be_physfn(adapter) && adapter->sriov_enabled)
-		for (vf = 0; vf < num_vfs; vf++)
-			if (adapter->vf_cfg[vf].vf_if_handle)
-				be_cmd_if_destroy(adapter,
-					adapter->vf_cfg[vf].vf_if_handle,
-					vf + 1);
-
-	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
-
 	adapter->be3_native = false;
 	adapter->promiscuous = false;
 
@@ -2468,59 +2474,92 @@ static int be_clear(struct be_adapter *adapter)
 	return 0;
 }
 
+static int be_vf_setup(struct be_adapter *adapter)
+{
+	u32 cap_flags, en_flags, vf;
+	u16 lnk_speed;
+	int status;
+
+	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST;
+	for (vf = 0; vf < num_vfs; vf++) {
+		status = be_cmd_if_create(adapter, cap_flags, en_flags, NULL,
+					&adapter->vf_cfg[vf].vf_if_handle,
+					NULL, vf+1);
+		if (status)
+			goto err;
+		adapter->vf_cfg[vf].vf_pmac_id = BE_INVALID_PMAC_ID;
+	}
+
+	if (!lancer_chip(adapter)) {
+		status = be_vf_eth_addr_config(adapter);
+		if (status)
+			goto err;
+	}
+
+	for (vf = 0; vf < num_vfs; vf++) {
+		status = be_cmd_link_status_query(adapter, NULL, &lnk_speed,
+				vf + 1);
+		if (status)
+			goto err;
+		adapter->vf_cfg[vf].vf_tx_rate = lnk_speed * 10;
+	}
+	return 0;
+err:
+	return status;
+}
+
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 cap_flags, en_flags, vf = 0;
+	u32 cap_flags, en_flags;
 	u32 tx_fc, rx_fc;
 	int status;
 	u8 mac[ETH_ALEN];
 
+	/* Allow all priorities by default. A GRP5 evt may modify this */
+	adapter->vlan_prio_bmap = 0xff;
+	adapter->link_speed = -1;
+
 	be_cmd_req_native_mode(adapter);
 
-	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED |
-				BE_IF_FLAGS_BROADCAST |
-				BE_IF_FLAGS_MULTICAST;
-
-	if (be_physfn(adapter)) {
-		cap_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS |
-				BE_IF_FLAGS_PROMISCUOUS |
-				BE_IF_FLAGS_PASS_L3L4_ERRORS;
-		en_flags |= BE_IF_FLAGS_PASS_L3L4_ERRORS;
-
-		if (adapter->function_caps & BE_FUNCTION_CAPS_RSS) {
-			cap_flags |= BE_IF_FLAGS_RSS;
-			en_flags |= BE_IF_FLAGS_RSS;
-		}
+	status = be_tx_queues_create(adapter);
+	if (status != 0)
+		goto err;
+
+	status = be_rx_queues_create(adapter);
+	if (status != 0)
+		goto err;
+
+	status = be_mcc_queues_create(adapter);
+	if (status != 0)
+		goto err;
+
+	memset(mac, 0, ETH_ALEN);
+	status = be_cmd_mac_addr_query(adapter, mac, MAC_ADDRESS_TYPE_NETWORK,
+			true /*permanent */, 0);
+	if (status)
+		return status;
+	memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
+	memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
+
+	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
+			BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
+	cap_flags = en_flags | BE_IF_FLAGS_MCAST_PROMISCUOUS |
+			BE_IF_FLAGS_PROMISCUOUS;
+	if (adapter->function_caps & BE_FUNCTION_CAPS_RSS) {
+		cap_flags |= BE_IF_FLAGS_RSS;
+		en_flags |= BE_IF_FLAGS_RSS;
 	}
-
 	status = be_cmd_if_create(adapter, cap_flags, en_flags,
-			netdev->dev_addr, false/* pmac_invalid */,
-			&adapter->if_handle, &adapter->pmac_id, 0);
+			netdev->dev_addr, &adapter->if_handle,
+			&adapter->pmac_id, 0);
 	if (status != 0)
 		goto err;
-
-	if (be_physfn(adapter)) {
-		if (adapter->sriov_enabled) {
-			while (vf < num_vfs) {
-				cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED |
-							BE_IF_FLAGS_BROADCAST;
-				status = be_cmd_if_create(adapter, cap_flags,
-					en_flags, mac, true,
-					&adapter->vf_cfg[vf].vf_if_handle,
-					NULL, vf+1);
-				if (status) {
-					dev_err(&adapter->pdev->dev,
-					"Interface Create failed for VF %d\n",
-					vf);
-					goto err;
-				}
-				adapter->vf_cfg[vf].vf_pmac_id =
-							BE_INVALID_PMAC_ID;
-				vf++;
-			}
-		}
-	} else {
+	
+	/* For BEx, the VF's permanent mac queried from card is incorrect.
+	 * Query the mac configued by the PF using if_handle
+	 */
+	if (!be_physfn(adapter) && !lancer_chip(adapter)) {
 		status = be_cmd_mac_addr_query(adapter, mac,
 			MAC_ADDRESS_TYPE_NETWORK, false, adapter->if_handle);
 		if (!status) {
@@ -2529,23 +2568,6 @@ static int be_setup(struct be_adapter *adapter)
 		}
 	}
 
-	status = be_tx_queues_create(adapter);
-	if (status != 0)
-		goto err;
-
-	status = be_rx_queues_create(adapter);
-	if (status != 0)
-		goto err;
-
-	/* Allow all priorities by default. A GRP5 evt may modify this */
-	adapter->vlan_prio_bmap = 0xff;
-
-	status = be_mcc_queues_create(adapter);
-	if (status != 0)
-		goto err;
-
-	adapter->link_speed = -1;
-
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 
 	status = be_vid_config(adapter, false, 0);
@@ -2565,8 +2587,14 @@ static int be_setup(struct be_adapter *adapter)
 	}	
 
 	pcie_set_readrq(adapter->pdev, 4096);
-	return 0;
 
+	if (be_physfn(adapter) && adapter->sriov_enabled) {
+		status = be_vf_setup(adapter);
+		if (status)
+			goto err;
+	}
+		
+	return 0;
 err:
 	be_clear(adapter);
 	return status;
@@ -3123,7 +3151,6 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_ctrl_cleanup(adapter);
 
-	kfree(adapter->vf_cfg);
 	be_sriov_disable(adapter);
 
 	be_msix_disable(adapter);
@@ -3138,30 +3165,12 @@ static void __devexit be_remove(struct pci_dev *pdev)
 static int be_get_config(struct be_adapter *adapter)
 {
 	int status;
-	u8 mac[ETH_ALEN];
 
 	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num,
 			&adapter->function_mode, &adapter->function_caps);
 	if (status)
 		return status;
 
-	memset(mac, 0, ETH_ALEN);
-
-	/* A default permanent address is given to each VF for Lancer*/
-	if (be_physfn(adapter) || lancer_chip(adapter)) {
-		status = be_cmd_mac_addr_query(adapter, mac,
-			MAC_ADDRESS_TYPE_NETWORK, true /*permanent */, 0);
-
-		if (status)
-			return status;
-
-		if (!is_valid_ether_addr(mac))
-			return -EADDRNOTAVAIL;
-
-		memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
-		memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
-	}
-
 	if (adapter->function_mode & 0x400)
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
 	else
@@ -3310,18 +3319,13 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		}
 	}
 
-	be_sriov_enable(adapter);
-	if (adapter->sriov_enabled) {
-		adapter->vf_cfg = kcalloc(num_vfs,
-			sizeof(struct be_vf_cfg), GFP_KERNEL);
-
-		if (!adapter->vf_cfg)
-			goto free_netdev;
-	}
+	status = be_sriov_enable(adapter);
+	if (status)
+		goto free_netdev;
 
 	status = be_ctrl_init(adapter);
 	if (status)
-		goto free_vf_cfg;
+		goto disable_sriov;
 
 	if (lancer_chip(adapter)) {
 		status = lancer_test_and_set_rdy_state(adapter);
@@ -3375,33 +3379,11 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status != 0)
 		goto unsetup;
 
-	if (be_physfn(adapter) && adapter->sriov_enabled) {
-		u8 mac_speed;
-		u16 vf, lnk_speed;
-
-		if (!lancer_chip(adapter)) {
-			status = be_vf_eth_addr_config(adapter);
-			if (status)
-				goto unreg_netdev;
-		}
-
-		for (vf = 0; vf < num_vfs; vf++) {
-			status = be_cmd_link_status_query(adapter, &mac_speed,
-						&lnk_speed, vf + 1);
-			if (!status)
-				adapter->vf_cfg[vf].vf_tx_rate = lnk_speed * 10;
-			else
-				goto unreg_netdev;
-		}
-	}
-
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
-unreg_netdev:
-	unregister_netdev(netdev);
 unsetup:
 	be_clear(adapter);
 msix_disable:
@@ -3410,10 +3392,9 @@ stats_clean:
 	be_stats_cleanup(adapter);
 ctrl_clean:
 	be_ctrl_cleanup(adapter);
-free_vf_cfg:
-	kfree(adapter->vf_cfg);
+disable_sriov:
+	be_sriov_disable(adapter);
 free_netdev:
-	be_sriov_disable(adapter);
 	free_netdev(netdev);
 	pci_set_drvdata(pdev, NULL);
 rel_reg:
-- 
1.7.4
