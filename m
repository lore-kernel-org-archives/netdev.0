From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40evf: enable support for VF VLAN tag stripping control
Date: Fri,  6 Oct 2017 10:57:25 -0700
Message-ID: <20171006175727.868-14-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56459 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752604AbdJFR5v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:51 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A recent commit 809481484e5d ("i40e/i40evf: support for VF VLAN tag
stripping control") added support for VFs to negotiate the control of
VLAN tag stripping. This should have allowed VFs to disable the feature.
Unfortunately, the flag was set only in netdev->feature flags and not in
netdev->hw_features.

This ultimately causes the stack to assume that it cannot change the
flag, so it was unchangeable and marked as [fixed] in the ethtool -k
output.

Fix this by setting the feature in hw_features first, just as we do for
the PF code. This enables ethtool -K to disable the feature correctly,
and fully enables user control of the VLAN tag stripping feature.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index bc76378a71e2..1d2fc898b664 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2423,10 +2423,6 @@ static netdev_features_t i40evf_features_check(struct sk_buff *skb,
 	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 }
 
-#define I40EVF_VLAN_FEATURES (NETIF_F_HW_VLAN_CTAG_TX |\
-			      NETIF_F_HW_VLAN_CTAG_RX |\
-			      NETIF_F_HW_VLAN_CTAG_FILTER)
-
 /**
  * i40evf_fix_features - fix up the netdev feature bits
  * @netdev: our net device
@@ -2439,9 +2435,11 @@ static netdev_features_t i40evf_fix_features(struct net_device *netdev,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
-	features &= ~I40EVF_VLAN_FEATURES;
-	if (adapter->vf_res->vf_cap_flags & VIRTCHNL_VF_OFFLOAD_VLAN)
-		features |= I40EVF_VLAN_FEATURES;
+	if (!(adapter->vf_res->vf_cap_flags & VIRTCHNL_VF_OFFLOAD_VLAN))
+		features &= ~(NETIF_F_HW_VLAN_CTAG_TX |
+			      NETIF_F_HW_VLAN_CTAG_RX |
+			      NETIF_F_HW_VLAN_CTAG_FILTER);
+
 	return features;
 }
 
@@ -2572,9 +2570,17 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	 */
 	hw_features = hw_enc_features;
 
+	/* Enable VLAN features if supported */
+	if (vfres->vf_cap_flags & VIRTCHNL_VF_OFFLOAD_VLAN)
+		hw_features |= (NETIF_F_HW_VLAN_CTAG_TX |
+				NETIF_F_HW_VLAN_CTAG_RX);
+
 	netdev->hw_features |= hw_features;
 
-	netdev->features |= hw_features | I40EVF_VLAN_FEATURES;
+	netdev->features |= hw_features;
+
+	if (vfres->vf_cap_flags & VIRTCHNL_VF_OFFLOAD_VLAN)
+		netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	adapter->vsi.id = adapter->vsi_res->vsi_id;
 
-- 
2.14.2
