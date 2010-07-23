From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 3/7] be2net: add vlan support for sriov virtual
 functions
Date: Fri, 23 Jul 2010 17:21:22 +0530
Message-ID: <20100723115112.GA24955@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:24854 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757836Ab0GWLvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 07:51:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_main.c |   54 ++++++++++++++++++++++++++++++++++++------
 2 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index a8e95da..f693b9e 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -224,6 +224,7 @@ struct be_vf_cfg {
 	unsigned char vf_mac_addr[ETH_ALEN];
 	u32 vf_if_handle;
 	u32 vf_pmac_id;
+	u16 vf_vlan_tag;
 };
 
 #define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a8c4548..46f087e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -552,11 +552,18 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
  * A max of 64 (BE_NUM_VLANS_SUPPORTED) vlans can be configured in BE.
  * If the user configures more, place BE in vlan promiscuous mode.
  */
-static int be_vid_config(struct be_adapter *adapter)
+static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 {
 	u16 vtag[BE_NUM_VLANS_SUPPORTED];
 	u16 ntags = 0, i;
 	int status = 0;
+	u32 if_handle;
+
+	if (vf) {
+		if_handle = adapter->vf_cfg[vf_num].vf_if_handle;
+		vtag[0] = cpu_to_le16(adapter->vf_cfg[vf_num].vf_vlan_tag);
+		status = be_cmd_vlan_config(adapter, if_handle, vtag, 1, 1, 0);
+	}
 
 	if (adapter->vlans_added <= adapter->max_vlans)  {
 		/* Construct VLAN Table to give to HW */
@@ -572,6 +579,7 @@ static int be_vid_config(struct be_adapter *adapter)
 		status = be_cmd_vlan_config(adapter, adapter->if_handle,
 					NULL, 0, 1, 1);
 	}
+
 	return status;
 }
 
@@ -592,27 +600,28 @@ static void be_vlan_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	adapter->vlans_added++;
 	if (!be_physfn(adapter))
 		return;
 
 	adapter->vlan_tag[vid] = 1;
-	adapter->vlans_added++;
 	if (adapter->vlans_added <= (adapter->max_vlans + 1))
-		be_vid_config(adapter);
+		be_vid_config(adapter, false, 0);
 }
 
 static void be_vlan_rem_vid(struct net_device *netdev, u16 vid)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
+	adapter->vlans_added--;
+	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
+
 	if (!be_physfn(adapter))
 		return;
 
 	adapter->vlan_tag[vid] = 0;
-	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
-	adapter->vlans_added--;
 	if (adapter->vlans_added <= adapter->max_vlans)
-		be_vid_config(adapter);
+		be_vid_config(adapter, false, 0);
 }
 
 static void be_set_multicast_list(struct net_device *netdev)
@@ -687,13 +696,41 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 
 	vi->vf = vf;
 	vi->tx_rate = 0;
-	vi->vlan = 0;
+	vi->vlan = adapter->vf_cfg[vf].vf_vlan_tag;
 	vi->qos = 0;
 	memcpy(&vi->mac, adapter->vf_cfg[vf].vf_mac_addr, ETH_ALEN);
 
 	return 0;
 }
 
+static int be_set_vf_vlan(struct net_device *netdev,
+			int vf, u16 vlan, u8 qos)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
+
+	if (!adapter->sriov_enabled)
+		return -EPERM;
+
+	if ((vf >= num_vfs) || (vlan > 4095))
+		return -EINVAL;
+
+	if (vlan) {
+		adapter->vf_cfg[vf].vf_vlan_tag = vlan;
+		adapter->vlans_added++;
+	} else {
+		adapter->vf_cfg[vf].vf_vlan_tag = 0;
+		adapter->vlans_added--;
+	}
+
+	status = be_vid_config(adapter, true, vf);
+
+	if (status)
+		dev_info(&adapter->pdev->dev,
+				"VLAN %d config on VF %d failed\n", vlan, vf);
+	return status;
+}
+
 static void be_rx_rate_update(struct be_adapter *adapter)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
@@ -1849,7 +1886,7 @@ static int be_open(struct net_device *netdev)
 	be_link_status_update(adapter, link_up);
 
 	if (be_physfn(adapter)) {
-		status = be_vid_config(adapter);
+		status = be_vid_config(adapter, false, 0);
 		if (status)
 			goto err;
 
@@ -2218,6 +2255,7 @@ static struct net_device_ops be_netdev_ops = {
 	.ndo_vlan_rx_add_vid	= be_vlan_add_vid,
 	.ndo_vlan_rx_kill_vid	= be_vlan_rem_vid,
 	.ndo_set_vf_mac		= be_set_vf_mac,
+	.ndo_set_vf_vlan	= be_set_vf_vlan,
 	.ndo_get_vf_config	= be_get_vf_config
 };
 
-- 
1.7.0.4

