From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 2/7] be2net: add support to get vf config
Date: Fri, 23 Jul 2010 17:20:34 +0530
Message-ID: <20100723115022.GA24909@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:24680 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756109Ab0GWLuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:50:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    9 ++++++-
 drivers/net/benet/be_main.c |   51 +++++++++++++++++++++++++++++++++---------
 2 files changed, 47 insertions(+), 13 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index c730bd6..a8e95da 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -220,6 +220,12 @@ struct be_rx_obj {
 	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
 };
 
+struct be_vf_cfg {
+	unsigned char vf_mac_addr[ETH_ALEN];
+	u32 vf_if_handle;
+	u32 vf_pmac_id;
+};
+
 #define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
 #define BE_INVALID_PMAC_ID		0xffffffff
 struct be_adapter {
@@ -289,8 +295,7 @@ struct be_adapter {
 	struct completion flash_compl;
 
 	bool sriov_enabled;
-	u32 vf_if_handle[BE_MAX_VF];
-	u32 vf_pmac_id[BE_MAX_VF];
+	struct be_vf_cfg vf_cfg[BE_MAX_VF];
 	u8 base_eq_id;
 	u8 is_virtfn;
 };
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 899881b..a8c4548 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -656,18 +656,44 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!is_valid_ether_addr(mac) || (vf >= num_vfs))
 		return -EINVAL;
 
-	if (adapter->vf_pmac_id[vf] != BE_INVALID_PMAC_ID)
-		status = be_cmd_pmac_del(adapter, adapter->vf_if_handle[vf],
-					adapter->vf_pmac_id[vf]);
+	if (adapter->vf_cfg[vf].vf_pmac_id != BE_INVALID_PMAC_ID)
+		status = be_cmd_pmac_del(adapter,
+					adapter->vf_cfg[vf].vf_if_handle,
+					adapter->vf_cfg[vf].vf_pmac_id);
 
-	status = be_cmd_pmac_add(adapter, mac, adapter->vf_if_handle[vf],
-				&adapter->vf_pmac_id[vf]);
-	if (!status)
+	status = be_cmd_pmac_add(adapter, mac,
+				adapter->vf_cfg[vf].vf_if_handle,
+				&adapter->vf_cfg[vf].vf_pmac_id);
+
+	if (status)
 		dev_err(&adapter->pdev->dev, "MAC %pM set on VF %d Failed\n",
 				mac, vf);
+	else
+		memcpy(adapter->vf_cfg[vf].vf_mac_addr, mac, ETH_ALEN);
+
 	return status;
 }
 
+static int be_get_vf_config(struct net_device *netdev, int vf,
+			struct ifla_vf_info *vi)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (!adapter->sriov_enabled)
+		return -EPERM;
+
+	if (vf >= num_vfs)
+		return -EINVAL;
+
+	vi->vf = vf;
+	vi->tx_rate = 0;
+	vi->vlan = 0;
+	vi->qos = 0;
+	memcpy(&vi->mac, adapter->vf_cfg[vf].vf_mac_addr, ETH_ALEN);
+
+	return 0;
+}
+
 static void be_rx_rate_update(struct be_adapter *adapter)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
@@ -1904,14 +1930,15 @@ static int be_setup(struct be_adapter *adapter)
 			cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED
 					| BE_IF_FLAGS_BROADCAST;
 			status = be_cmd_if_create(adapter, cap_flags, en_flags,
-					mac, true, &adapter->vf_if_handle[vf],
+					mac, true,
+					&adapter->vf_cfg[vf].vf_if_handle,
 					NULL, vf+1);
 			if (status) {
 				dev_err(&adapter->pdev->dev,
 				"Interface Create failed for VF %d\n", vf);
 				goto if_destroy;
 			}
-			adapter->vf_pmac_id[vf] = BE_INVALID_PMAC_ID;
+			adapter->vf_cfg[vf].vf_pmac_id = BE_INVALID_PMAC_ID;
 			vf++;
 		}
 	} else if (!be_physfn(adapter)) {
@@ -1945,8 +1972,9 @@ tx_qs_destroy:
 	be_tx_queues_destroy(adapter);
 if_destroy:
 	for (vf = 0; vf < num_vfs; vf++)
-		if (adapter->vf_if_handle[vf])
-			be_cmd_if_destroy(adapter, adapter->vf_if_handle[vf]);
+		if (adapter->vf_cfg[vf].vf_if_handle)
+			be_cmd_if_destroy(adapter,
+					adapter->vf_cfg[vf].vf_if_handle);
 	be_cmd_if_destroy(adapter, adapter->if_handle);
 do_none:
 	return status;
@@ -2189,7 +2217,8 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_vlan_rx_register	= be_vlan_register,
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
-	.ndo_set_vf_mac		= be_set_vf_mac
+	.ndo_set_vf_mac		= be_set_vf_mac,
+	.ndo_get_vf_config	= be_get_vf_config
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.7.0.4

