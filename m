From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: Add new ndo to allow VF multicast promiscuous mode
Date: Sat,  2 May 2015 03:42:35 -0700
Message-ID: <1430563358-113833-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Sy Jong Choi <sy.jong.choi@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8026 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927AbbEBKmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:50 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Implements the new netdev op to allow VF multicast promiscuous mode.
The multicast promiscuous mode is not allowed for all VFs by default.

The administrator can allow to VF multicast promiscuous mode for only
trusted VM. After allowing multicast promiscuous mode from the host,
we can use over 30 IPv6 addresses on VM.
 # ip link set dev eth0 vf 1 mc_promisc on

When disallowing multicast promiscuous mode, ixgbevf can only handle 30
IPv6 addresses at most.
 # ip link set dev eth0 vf 1 mc_promisc off

CC: Sy Jong Choi <sy.jong.choi@intel.com>
Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  5 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32 ++++++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
 4 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 08e65b6..4a9f74d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -153,6 +153,7 @@ struct vf_data_storage {
 	u16 vlan_count;
 	u8 spoofchk_enabled;
 	bool rss_query_enabled;
+	u8 mc_promisc_allowed;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d3f4b0c..36072af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3662,6 +3662,10 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 		/* Enable/Disable RSS query feature  */
 		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
 					  adapter->vfinfo[i].rss_query_enabled);
+
+		/* Reconfigure multicast promiscuous mode */
+		ixgbe_ndo_set_vf_mc_promisc(adapter->netdev, i,
+					    adapter->vfinfo[i].mc_promisc_allowed);
 	}
 }
 
@@ -8165,6 +8169,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
+	.ndo_set_vf_mc_promisc	= ixgbe_ndo_set_vf_mc_promisc,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 615f651..42b24a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -117,8 +117,11 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			 */
 			adapter->vfinfo[i].rss_query_enabled = 0;
 
-			/* Turn multicast promiscuous mode off for all VFs */
+			/* Disallow VF multicast promiscuous capability
+			 * and turn it off for all VFs
+			 */
 			adapter->vfinfo[i].mc_promisc = false;
+			adapter->vfinfo[i].mc_promisc_allowed = false;
 		}
 
 		return 0;
@@ -1068,7 +1071,7 @@ static int ixgbe_set_vf_mc_promisc(struct ixgbe_adapter *adapter,
 
 	adapter->vfinfo[vf].mc_promisc = enable;
 
-	if (enable)
+	if (enable && adapter->vfinfo[vf].mc_promisc_allowed)
 		return ixgbe_enable_vf_mc_promisc(adapter, vf);
 	else
 		return ixgbe_disable_vf_mc_promisc(adapter, vf);
@@ -1492,6 +1495,30 @@ int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	/* nothing to do */
+	if (adapter->vfinfo[vf].mc_promisc_allowed == setting)
+		return 0;
+
+	adapter->vfinfo[vf].mc_promisc_allowed = setting;
+
+	/* if VF requests multicast promiscuous */
+	if (adapter->vfinfo[vf].mc_promisc) {
+		if (setting)
+			ixgbe_enable_vf_mc_promisc(adapter, vf);
+		else
+			ixgbe_disable_vf_mc_promisc(adapter, vf);
+	}
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1506,5 +1533,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
 	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
+	ivi->mc_promisc = adapter->vfinfo[vf].mc_promisc_allowed;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 2c197e6..bf5b8f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -49,6 +49,8 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 				  bool setting);
+int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev,
+				int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
2.1.0
