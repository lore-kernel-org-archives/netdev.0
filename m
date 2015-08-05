From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 1/3] be2net: enable IFACE filters only after creating RXQs
Date: Wed,  5 Aug 2015 03:27:48 -0400
Message-ID: <1438759670-2134-2-git-send-email-sathya.perla@avagotech.com>
References: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56692 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751000AbbHEHVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 03:21:32 -0400
In-Reply-To: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@avagotech.com>

HW issues were observed on Lancer adapters if IFACE filters
(flags, mac addrs etc) are enabled *before* creating RXQs.  This patch
changes the driver design by enabling filters in be_open() --
instead of be_setup() -- after RXQs are created and buffers posted.
Two new wrapper functions, be_enable_if_filters() and
be_disable_if_filters() are introduced to enable/disable IFACE filters in
be_open()/be_close() respectively. In be_setup() the IFACE is now created
only with the RSS flag.

Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |   5 ++
 drivers/net/ethernet/emulex/benet/be_main.c | 127 ++++++++++++++++++----------
 2 files changed, 85 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 2716e6f..00e3a6b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -620,6 +620,11 @@ enum be_if_flags {
 					 BE_IF_FLAGS_VLAN_PROMISCUOUS |\
 					 BE_IF_FLAGS_MCAST_PROMISCUOUS)
 
+#define BE_IF_EN_FLAGS	(BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |\
+			BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_UNTAGGED)
+
+#define BE_IF_ALL_FILT_FLAGS	(BE_IF_EN_FLAGS | BE_IF_FLAGS_ALL_PROMISCUOUS)
+
 /* An RX interface is an object with one or more MAC addresses and
  * filtering capabilities. */
 struct be_cmd_req_if_create {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6f64242..7730f21 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -273,6 +273,10 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	if (ether_addr_equal(addr->sa_data, netdev->dev_addr))
 		return 0;
 
+	/* if device is not running, copy MAC to netdev->dev_addr */
+	if (!netif_running(netdev))
+		goto done;
+
 	/* The PMAC_ADD cmd may fail if the VF doesn't have FILTMGMT
 	 * privilege or if PF did not provision the new MAC address.
 	 * On BE3, this cmd will always fail if the VF doesn't have the
@@ -307,9 +311,9 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 		status = -EPERM;
 		goto err;
 	}
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	dev_info(dev, "MAC address changed to %pM\n", mac);
+done:
+	ether_addr_copy(netdev->dev_addr, addr->sa_data);
+	dev_info(dev, "MAC address changed to %pM\n", addr->sa_data);
 	return 0;
 err:
 	dev_warn(dev, "MAC address change to %pM failed\n", addr->sa_data);
@@ -3361,6 +3365,33 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 	}
 }
 
+static void be_disable_if_filters(struct be_adapter *adapter)
+{
+	be_cmd_pmac_del(adapter, adapter->if_handle,
+			adapter->pmac_id[0], 0);
+
+	be_clear_uc_list(adapter);
+
+	/* The IFACE flags are enabled in the open path and cleared
+	 * in the close path. When a VF gets detached from the host and
+	 * assigned to a VM the following happens:
+	 *	- VF's IFACE flags get cleared in the detach path
+	 *	- IFACE create is issued by the VF in the attach path
+	 * Due to a bug in the BE3/Skyhawk-R FW
+	 * (Lancer FW doesn't have the bug), the IFACE capability flags
+	 * specified along with the IFACE create cmd issued by a VF are not
+	 * honoured by FW.  As a consequence, if a *new* driver
+	 * (that enables/disables IFACE flags in open/close)
+	 * is loaded in the host and an *old* driver is * used by a VM/VF,
+	 * the IFACE gets created *without* the needed flags.
+	 * To avoid this, disable RX-filter flags only for Lancer.
+	 */
+	if (lancer_chip(adapter)) {
+		be_cmd_rx_filter(adapter, BE_IF_ALL_FILT_FLAGS, OFF);
+		adapter->if_flags &= ~BE_IF_ALL_FILT_FLAGS;
+	}
+}
+
 static int be_close(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -3373,6 +3404,8 @@ static int be_close(struct net_device *netdev)
 	if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
 		return 0;
 
+	be_disable_if_filters(adapter);
+
 	be_roce_dev_close(adapter);
 
 	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
@@ -3392,7 +3425,6 @@ static int be_close(struct net_device *netdev)
 	be_tx_compl_clean(adapter);
 
 	be_rx_qs_destroy(adapter);
-	be_clear_uc_list(adapter);
 
 	for_all_evt_queues(adapter, eqo, i) {
 		if (msix_enabled(adapter))
@@ -3477,6 +3509,31 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 	return 0;
 }
 
+static int be_enable_if_filters(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_cmd_rx_filter(adapter, BE_IF_EN_FLAGS, ON);
+	if (status)
+		return status;
+
+	/* For BE3 VFs, the PF programs the initial MAC address */
+	if (!(BEx_chip(adapter) && be_virtfn(adapter))) {
+		status = be_cmd_pmac_add(adapter, adapter->netdev->dev_addr,
+					 adapter->if_handle,
+					 &adapter->pmac_id[0], 0);
+		if (status)
+			return status;
+	}
+
+	if (adapter->vlans_added)
+		be_vid_config(adapter);
+
+	be_set_rx_mode(adapter->netdev);
+
+	return 0;
+}
+
 static int be_open(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -3490,6 +3547,10 @@ static int be_open(struct net_device *netdev)
 	if (status)
 		goto err;
 
+	status = be_enable_if_filters(adapter);
+	if (status)
+		goto err;
+
 	status = be_irq_register(adapter);
 	if (status)
 		goto err;
@@ -3686,16 +3747,6 @@ static void be_cancel_err_detection(struct be_adapter *adapter)
 	}
 }
 
-static void be_mac_clear(struct be_adapter *adapter)
-{
-	if (adapter->pmac_id) {
-		be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id[0], 0);
-		kfree(adapter->pmac_id);
-		adapter->pmac_id = NULL;
-	}
-}
-
 #ifdef CONFIG_BE2NET_VXLAN
 static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 {
@@ -3770,8 +3821,8 @@ static int be_clear(struct be_adapter *adapter)
 #ifdef CONFIG_BE2NET_VXLAN
 	be_disable_vxlan_offloads(adapter);
 #endif
-	/* delete the primary mac along with the uc-mac list */
-	be_mac_clear(adapter);
+	kfree(adapter->pmac_id);
+	adapter->pmac_id = NULL;
 
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
@@ -3782,25 +3833,11 @@ static int be_clear(struct be_adapter *adapter)
 	return 0;
 }
 
-static int be_if_create(struct be_adapter *adapter, u32 *if_handle,
-			u32 cap_flags, u32 vf)
-{
-	u32 en_flags;
-
-	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |
-		   BE_IF_FLAGS_RSS | BE_IF_FLAGS_DEFQ_RSS;
-
-	en_flags &= cap_flags;
-
-	return be_cmd_if_create(adapter, cap_flags, en_flags, if_handle, vf);
-}
-
 static int be_vfs_if_create(struct be_adapter *adapter)
 {
 	struct be_resources res = {0};
+	u32 cap_flags, en_flags, vf;
 	struct be_vf_cfg *vf_cfg;
-	u32 cap_flags, vf;
 	int status;
 
 	/* If a FW profile exists, then cap_flags are updated */
@@ -3821,8 +3858,12 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 			}
 		}
 
-		status = be_if_create(adapter, &vf_cfg->if_handle,
-				      cap_flags, vf + 1);
+		en_flags = cap_flags & (BE_IF_FLAGS_UNTAGGED |
+					BE_IF_FLAGS_BROADCAST |
+					BE_IF_FLAGS_MULTICAST |
+					BE_IF_FLAGS_PASS_L3L4_ERRORS);
+		status = be_cmd_if_create(adapter, cap_flags, en_flags,
+					  &vf_cfg->if_handle, vf + 1);
 		if (status)
 			return status;
 	}
@@ -4194,15 +4235,8 @@ static int be_mac_setup(struct be_adapter *adapter)
 
 		memcpy(adapter->netdev->dev_addr, mac, ETH_ALEN);
 		memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
-	} else {
-		/* Maybe the HW was reset; dev_addr must be re-programmed */
-		memcpy(mac, adapter->netdev->dev_addr, ETH_ALEN);
 	}
 
-	/* For BE3-R VFs, the PF programs the initial MAC address */
-	if (!(BEx_chip(adapter) && be_virtfn(adapter)))
-		be_cmd_pmac_add(adapter, mac, adapter->if_handle,
-				&adapter->pmac_id[0], 0);
 	return 0;
 }
 
@@ -4342,6 +4376,7 @@ static int be_func_init(struct be_adapter *adapter)
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u32 en_flags;
 	int status;
 
 	status = be_func_init(adapter);
@@ -4364,8 +4399,11 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	status = be_if_create(adapter, &adapter->if_handle,
-			      be_if_cap_flags(adapter), 0);
+	/* will enable all the needed filter flags in be_open() */
+	en_flags = BE_IF_FLAGS_RSS | BE_IF_FLAGS_DEFQ_RSS;
+	en_flags = en_flags & be_if_cap_flags(adapter);
+	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
+				  &adapter->if_handle, 0);
 	if (status)
 		goto err;
 
@@ -4391,11 +4429,6 @@ static int be_setup(struct be_adapter *adapter)
 		dev_err(dev, "Please upgrade firmware to version >= 4.0\n");
 	}
 
-	if (adapter->vlans_added)
-		be_vid_config(adapter);
-
-	be_set_rx_mode(adapter->netdev);
-
 	status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					 adapter->rx_fc);
 	if (status)
-- 
2.4.1
