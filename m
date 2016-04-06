From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40evf: Fix VLAN features
Date: Tue,  5 Apr 2016 20:35:59 -0700
Message-ID: <1459913769-56510-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40669 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760280AbcDFDgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:18 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Users of ethtool were being given the mistaken impression that this
driver was able to change its VLAN tagging features, and were
disappointed that this was not actually the case. Implement
ndo_fix_features method so that we can adjust these flags as needed to
avoid false impressions.

Change-ID: I08584f103a4fa73d6a4128d472e4ef44dcfda57f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e397368..2d018b4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2252,6 +2252,28 @@ static int i40evf_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+#define I40EVF_VLAN_FEATURES (NETIF_F_HW_VLAN_CTAG_TX |\
+			      NETIF_F_HW_VLAN_CTAG_RX |\
+			      NETIF_F_HW_VLAN_CTAG_FILTER)
+
+/**
+ * i40evf_fix_features - fix up the netdev feature bits
+ * @netdev: our net device
+ * @features: desired feature bits
+ *
+ * Returns fixed-up features bits
+ **/
+static netdev_features_t i40evf_fix_features(struct net_device *netdev,
+					     netdev_features_t features)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+
+	features &= ~I40EVF_VLAN_FEATURES;
+	if (adapter->vf_res->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_VLAN)
+		features |= I40EVF_VLAN_FEATURES;
+	return features;
+}
+
 static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_open		= i40evf_open,
 	.ndo_stop		= i40evf_close,
@@ -2264,6 +2286,7 @@ static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_tx_timeout		= i40evf_tx_timeout,
 	.ndo_vlan_rx_add_vid	= i40evf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= i40evf_vlan_rx_kill_vid,
+	.ndo_fix_features	= i40evf_fix_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= i40evf_netpoll,
 #endif
-- 
2.5.5
