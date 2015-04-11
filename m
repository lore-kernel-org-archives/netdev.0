From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: Add a new netdev op to allow/prevent a VF from querying an RSS info
Date: Sat, 11 Apr 2015 12:07:51 -0700
Message-ID: <1428779276-22523-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18952 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407AbbDKTIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:01 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

Implements the new netdev op to allow user to enable/disable the ability
of a specific VF to query its RSS Indirection Table and an RSS Hash Key.

This patch limits the new feature support to 82599 and x540 devices only.
Support for other devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  5 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 34 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
 4 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index d3d27ec..636f9e3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -151,6 +151,7 @@ struct vf_data_storage {
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
+	bool rss_query_enabled;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fb096dd..d3f4b0c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3658,6 +3658,10 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 		/* enable ethertype anti spoofing if hw supports it */
 		if (hw->mac.ops.set_ethertype_anti_spoofing)
 			hw->mac.ops.set_ethertype_anti_spoofing(hw, true, i);
+
+		/* Enable/Disable RSS query feature  */
+		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
+					  adapter->vfinfo[i].rss_query_enabled);
 	}
 }
 
@@ -8160,6 +8164,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
+	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 2d98ecd..94fc43a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -106,9 +106,18 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 				     IXGBE_FLAG2_RSC_ENABLED);
 
-		/* enable spoof checking for all VFs */
-		for (i = 0; i < adapter->num_vfs; i++)
+		for (i = 0; i < adapter->num_vfs; i++) {
+			/* enable spoof checking for all VFs */
 			adapter->vfinfo[i].spoofchk_enabled = true;
+
+			/* We support VF RSS querying only for 82599 and x540
+			 * devices at the moment. These devices share RSS
+			 * indirection table and RSS hash key with PF therefore
+			 * we want to disable the querying by default.
+			 */
+			adapter->vfinfo[i].rss_query_enabled = 0;
+		}
+
 		return 0;
 	}
 
@@ -1331,6 +1340,26 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
+				  bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	/* This operation is currently supported only for 82599 and x540
+	 * devices.
+	 */
+	if (adapter->hw.mac.type < ixgbe_mac_82599EB ||
+	    adapter->hw.mac.type >= ixgbe_mac_X550)
+		return -EOPNOTSUPP;
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	adapter->vfinfo[vf].rss_query_enabled = setting;
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1344,5 +1373,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
+	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 32c26d5..2c197e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -47,6 +47,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 			int max_tx_rate);
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
+int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
+				  bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
1.9.3
