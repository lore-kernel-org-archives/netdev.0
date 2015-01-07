From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v5 2/7] ixgbe: Add a new netdev op to allow/prevent a VF from querying an RSS info
Date: Wed,  7 Jan 2015 21:26:37 +0200
Message-ID: <1420658802-18061-3-git-send-email-vladz@cloudius-systems.com>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:36889 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603AbbAGT06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:26:58 -0500
Received: by mail-we0-f170.google.com with SMTP id w61so1768047wes.15
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:26:57 -0800 (PST)
In-Reply-To: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements the new netdev op to allow user to enable/disable the ability
of a specific VF to query its RSS Indirection Table and an RSS Hash Key.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 +++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 27 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
 4 files changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 38fc64c..5e3ff3e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -149,6 +149,7 @@ struct vf_data_storage {
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
+	bool rss_query_enabled;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..0074e63 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3569,6 +3569,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 		if (!adapter->vfinfo[i].spoofchk_enabled)
 			ixgbe_ndo_set_vf_spoofchk(adapter->netdev, i, false);
 	}
+
+	/* Enable/Disable RSS query feature  */
+	for (i = 0; i < adapter->num_vfs; i++)
+		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
+					  adapter->vfinfo[i].rss_query_enabled);
+
 }
 
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
@@ -7955,6 +7961,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
+	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..c903ab2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -111,6 +111,19 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		/* enable spoof checking for all VFs */
 		for (i = 0; i < adapter->num_vfs; i++)
 			adapter->vfinfo[i].spoofchk_enabled = true;
+
+		/* by default:
+		 *   - Enable RSS query for x550 devices. x550 VFs don't share
+		 *     RSS Redirection Table and RSS Hash Key with a PF, so
+		 *     there isn't any possible security threat in allowing them
+		 *     to query this information.
+		 *   - disable - for all the rest since they do share it with a
+		 *     PF.
+		 */
+		for (i = 0; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].rss_query_enabled =
+				       (adapter->hw.mac.type >= ixgbe_mac_X550);
+
 		return 0;
 	}
 
@@ -1330,6 +1343,19 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
+				  bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
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
@@ -1343,5 +1369,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
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
2.1.0
