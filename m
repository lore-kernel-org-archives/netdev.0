From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/9] be2net: refactor be_set_rx_mode() and be_vid_config() for readability
Date: Fri, 6 Feb 2015 08:18:41 -0500
Message-ID: <1423228723-10919-8-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28175 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082AbbBFNPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:41 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch re-factors the filter setting (uc-list, mc-list, promisc, vlan)
code in be_set_rx_mode() and be_vid_config() to make it more readable
and reduce code duplication.
This patch adds a separate field to track the state/mode of filtering,
along with moving all the filtering related fields to one place in be
be_adapter structure.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  13 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 211 ++++++++++++++++------------
 2 files changed, 127 insertions(+), 97 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 9869556..98716e1 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -364,8 +364,6 @@ enum vf_state {
 #define BE_FLAGS_LINK_STATUS_INIT		BIT(1)
 #define BE_FLAGS_SRIOV_ENABLED			BIT(2)
 #define BE_FLAGS_WORKER_SCHEDULED		BIT(3)
-#define BE_FLAGS_VLAN_PROMISC			BIT(4)
-#define BE_FLAGS_MCAST_PROMISC			BIT(5)
 #define BE_FLAGS_NAPI_ENABLED			BIT(6)
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		BIT(7)
 #define BE_FLAGS_VXLAN_OFFLOADS			BIT(8)
@@ -449,8 +447,6 @@ struct be_adapter {
 
 	struct be_drv_stats drv_stats;
 	struct be_aic_obj aic_obj[MAX_EVT_QS];
-	u16 vlans_added;
-	unsigned long vids[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
 	u16 recommended_prio;	/* Recommended Priority */
 	struct be_dma_mem rx_filter; /* Cmd DMA mem for rx-filter */
@@ -466,8 +462,15 @@ struct be_adapter {
 	/* Ethtool knobs and info */
 	char fw_ver[FW_VER_LEN];
 	char fw_on_flash[FW_VER_LEN];
+
+	/* IFACE filtering fields */
 	int if_handle;		/* Used to configure filtering */
+	u32 if_flags;		/* Interface filtering flags */
 	u32 *pmac_id;		/* MAC addr handle used by BE card */
+	u32 uc_macs;		/* Count of secondary UC MAC programmed */
+	unsigned long vids[BITS_TO_LONGS(VLAN_N_VID)];
+	u16 vlans_added;
+
 	u32 beacon_state;	/* for set_phys_id */
 
 	bool eeh_error;
@@ -475,7 +478,6 @@ struct be_adapter {
 	bool hw_error;
 
 	u32 port_num;
-	bool promiscuous;
 	u8 mc_type;
 	u32 function_mode;
 	u32 function_caps;
@@ -508,7 +510,6 @@ struct be_adapter {
 	struct phy_info phy;
 	u8 wol_cap;
 	bool wol_en;
-	u32 uc_macs;		/* Count of secondary UC MAC programmed */
 	u16 asic_rev;
 	u16 qnq_vid;
 	u32 msg_enable;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4f7a14b..fbe7b6f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1104,6 +1104,43 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+static inline bool be_in_all_promisc(struct be_adapter *adapter)
+{
+	return (adapter->if_flags & BE_IF_FLAGS_ALL_PROMISCUOUS) ==
+			BE_IF_FLAGS_ALL_PROMISCUOUS;
+}
+
+static int be_set_vlan_promisc(struct be_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	if (adapter->if_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS)
+		return 0;
+
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS, ON);
+	if (!status) {
+		dev_info(dev, "Enabled VLAN promiscuous mode\n");
+		adapter->if_flags |= BE_IF_FLAGS_VLAN_PROMISCUOUS;
+	} else {
+		dev_err(dev, "Failed to enable VLAN promiscuous mode\n");
+	}
+	return status;
+}
+
+static int be_clear_vlan_promisc(struct be_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS, OFF);
+	if (!status) {
+		dev_info(dev, "Disabling VLAN promiscuous mode\n");
+		adapter->if_flags &= ~BE_IF_FLAGS_VLAN_PROMISCUOUS;
+	}
+	return status;
+}
+
 /*
  * A max of 64 (BE_NUM_VLANS_SUPPORTED) vlans can be configured in BE.
  * If the user configures more, place BE in vlan promiscuous mode.
@@ -1116,11 +1153,11 @@ static int be_vid_config(struct be_adapter *adapter)
 	int status = 0;
 
 	/* No need to further configure vids if in promiscuous mode */
-	if (adapter->promiscuous)
+	if (be_in_all_promisc(adapter))
 		return 0;
 
 	if (adapter->vlans_added > be_max_vlans(adapter))
-		goto set_vlan_promisc;
+		return be_set_vlan_promisc(adapter);
 
 	/* Construct VLAN Table to give to HW */
 	for_each_set_bit(i, adapter->vids, VLAN_N_VID)
@@ -1128,32 +1165,14 @@ static int be_vid_config(struct be_adapter *adapter)
 
 	status = be_cmd_vlan_config(adapter, adapter->if_handle, vids, num);
 	if (status) {
+		dev_err(dev, "Setting HW VLAN filtering failed\n");
 		/* Set to VLAN promisc mode as setting VLAN filter failed */
 		if (addl_status(status) ==
 				MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
-			goto set_vlan_promisc;
-		dev_err(dev, "Setting HW VLAN filtering failed\n");
-	} else if (adapter->flags & BE_FLAGS_VLAN_PROMISC) {
-		status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS,
-					  OFF);
-		if (!status) {
-			dev_info(dev, "Disabling VLAN Promiscuous mode\n");
-			adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
-		}
+			return be_set_vlan_promisc(adapter);
+	} else if (adapter->if_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
+		status = be_clear_vlan_promisc(adapter);
 	}
-
-	return status;
-
-set_vlan_promisc:
-	if (adapter->flags & BE_FLAGS_VLAN_PROMISC)
-		return 0;
-
-	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_VLAN_PROMISCUOUS, ON);
-	if (!status) {
-		dev_info(dev, "Enable VLAN Promiscuous mode\n");
-		adapter->flags |= BE_FLAGS_VLAN_PROMISC;
-	} else
-		dev_err(dev, "Failed to enable VLAN Promiscuous mode\n");
 	return status;
 }
 
@@ -1195,80 +1214,99 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	return be_vid_config(adapter);
 }
 
-static void be_clear_promisc(struct be_adapter *adapter)
+static void be_clear_all_promisc(struct be_adapter *adapter)
 {
-	adapter->promiscuous = false;
-	adapter->flags &= ~(BE_FLAGS_VLAN_PROMISC | BE_FLAGS_MCAST_PROMISC);
-
 	be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS, OFF);
+	adapter->if_flags &= ~BE_IF_FLAGS_ALL_PROMISCUOUS;
 }
 
-static void be_set_rx_mode(struct net_device *netdev)
+static void be_set_all_promisc(struct be_adapter *adapter)
+{
+	be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS, ON);
+	adapter->if_flags |= BE_IF_FLAGS_ALL_PROMISCUOUS;
+}
+
+static void be_set_mc_promisc(struct be_adapter *adapter)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
 	int status;
 
-	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS, ON);
-		adapter->promiscuous = true;
-		goto done;
-	}
+	if (adapter->if_flags & BE_IF_FLAGS_MCAST_PROMISCUOUS)
+		return;
 
-	/* BE was previously in promiscuous mode; disable it */
-	if (adapter->promiscuous) {
-		be_clear_promisc(adapter);
-		if (adapter->vlans_added)
-			be_vid_config(adapter);
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MCAST_PROMISCUOUS, ON);
+	if (!status)
+		adapter->if_flags |= BE_IF_FLAGS_MCAST_PROMISCUOUS;
+}
+
+static void be_set_mc_list(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MULTICAST, ON);
+	if (!status)
+		adapter->if_flags &= ~BE_IF_FLAGS_MCAST_PROMISCUOUS;
+	else
+		be_set_mc_promisc(adapter);
+}
+
+static void be_set_uc_list(struct be_adapter *adapter)
+{
+	struct netdev_hw_addr *ha;
+	int i = 1; /* First slot is claimed by the Primary MAC */
+
+	for (; adapter->uc_macs > 0; adapter->uc_macs--, i++)
+		be_cmd_pmac_del(adapter, adapter->if_handle,
+				adapter->pmac_id[i], 0);
+
+	if (netdev_uc_count(adapter->netdev) > be_max_uc(adapter)) {
+		be_set_all_promisc(adapter);
+		return;
 	}
 
-	/* Enable multicast promisc if num configured exceeds what we support */
-	if (netdev->flags & IFF_ALLMULTI ||
-	    netdev_mc_count(netdev) > be_max_mc(adapter))
-		goto set_mcast_promisc;
+	netdev_for_each_uc_addr(ha, adapter->netdev) {
+		adapter->uc_macs++; /* First slot is for Primary MAC */
+		be_cmd_pmac_add(adapter, (u8 *)ha->addr, adapter->if_handle,
+				&adapter->pmac_id[adapter->uc_macs], 0);
+	}
+}
 
-	if (netdev_uc_count(netdev) != adapter->uc_macs) {
-		struct netdev_hw_addr *ha;
-		int i = 1; /* First slot is claimed by the Primary MAC */
+static void be_clear_uc_list(struct be_adapter *adapter)
+{
+	int i;
 
-		for (; adapter->uc_macs > 0; adapter->uc_macs--, i++) {
-			be_cmd_pmac_del(adapter, adapter->if_handle,
-					adapter->pmac_id[i], 0);
-		}
+	for (i = 1; i < (adapter->uc_macs + 1); i++)
+		be_cmd_pmac_del(adapter, adapter->if_handle,
+				adapter->pmac_id[i], 0);
+	adapter->uc_macs = 0;
+}
 
-		if (netdev_uc_count(netdev) > be_max_uc(adapter)) {
-			be_cmd_rx_filter(adapter, BE_IF_FLAGS_ALL_PROMISCUOUS,
-					 ON);
-			adapter->promiscuous = true;
-			goto done;
-		}
+static void be_set_rx_mode(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
 
-		netdev_for_each_uc_addr(ha, adapter->netdev) {
-			adapter->uc_macs++; /* First slot is for Primary MAC */
-			be_cmd_pmac_add(adapter, (u8 *)ha->addr,
-					adapter->if_handle,
-					&adapter->pmac_id[adapter->uc_macs], 0);
-		}
+	if (netdev->flags & IFF_PROMISC) {
+		be_set_all_promisc(adapter);
+		return;
 	}
 
-	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MULTICAST, ON);
-	if (!status) {
-		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
-			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
-		goto done;
+	/* Interface was previously in promiscuous mode; disable it */
+	if (be_in_all_promisc(adapter)) {
+		be_clear_all_promisc(adapter);
+		if (adapter->vlans_added)
+			be_vid_config(adapter);
 	}
 
-set_mcast_promisc:
-	if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+	/* Enable multicast promisc if num configured exceeds what we support */
+	if (netdev->flags & IFF_ALLMULTI ||
+	    netdev_mc_count(netdev) > be_max_mc(adapter)) {
+		be_set_mc_promisc(adapter);
 		return;
+	}
 
-	/* Set to MCAST promisc mode if setting MULTICAST address fails
-	 * or if num configured exceeds what we support
-	 */
-	status = be_cmd_rx_filter(adapter, BE_IF_FLAGS_MCAST_PROMISCUOUS, ON);
-	if (!status)
-		adapter->flags |= BE_FLAGS_MCAST_PROMISC;
-done:
-	return;
+	if (netdev_uc_count(netdev) != adapter->uc_macs)
+		be_set_uc_list(adapter);
+
+	be_set_mc_list(adapter);
 }
 
 static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
@@ -2947,11 +2985,7 @@ static int be_close(struct net_device *netdev)
 	be_tx_compl_clean(adapter);
 
 	be_rx_qs_destroy(adapter);
-
-	for (i = 1; i < (adapter->uc_macs + 1); i++)
-		be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id[i], 0);
-	adapter->uc_macs = 0;
+	be_clear_uc_list(adapter);
 
 	for_all_evt_queues(adapter, eqo, i) {
 		if (msix_enabled(adapter))
@@ -3235,14 +3269,9 @@ static void be_cancel_worker(struct be_adapter *adapter)
 
 static void be_mac_clear(struct be_adapter *adapter)
 {
-	int i;
-
 	if (adapter->pmac_id) {
-		for (i = 0; i < (adapter->uc_macs + 1); i++)
-			be_cmd_pmac_del(adapter, adapter->if_handle,
-					adapter->pmac_id[i], 0);
-		adapter->uc_macs = 0;
-
+		be_cmd_pmac_del(adapter, adapter->if_handle,
+				adapter->pmac_id[0], 0);
 		kfree(adapter->pmac_id);
 		adapter->pmac_id = NULL;
 	}
@@ -3526,7 +3555,7 @@ static void be_setup_init(struct be_adapter *adapter)
 	adapter->phy.link_speed = -1;
 	adapter->if_handle = -1;
 	adapter->be3_native = false;
-	adapter->promiscuous = false;
+	adapter->if_flags = 0;
 	if (be_physfn(adapter))
 		adapter->cmd_privileges = MAX_PRIVILEGES;
 	else
-- 
2.2.0
