From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] ixgbe: Add new ndo to trust VF
Date: Fri, 23 Oct 2015 06:17:58 -0700
Message-ID: <1445606279-19345-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60580 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbbJWNST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:19 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Implements the new netdev op to trust VF in ixgbe.

The administrator can turn on and off VF trusted by ip command which
supports trust message.
 # ip link set dev eth0 vf 1 trust on
or
 # ip link set dev eth0 vf 1 trust off

Send a ping to reset VF on changing the status of trusting.
VF driver will reconfigure its features on reset.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 37 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  1 +
 4 files changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dda0f67..920de98 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -152,6 +152,7 @@ struct vf_data_storage {
 	u16 vlan_count;
 	u8 spoofchk_enabled;
 	bool rss_query_enabled;
+	u8 trusted;
 	unsigned int vf_api;
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9f8a7fd..47395ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8407,6 +8407,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
+	.ndo_set_vf_trust	= ixgbe_ndo_set_vf_trust,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1d17b58..65aeb58 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -116,6 +116,9 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 			 * we want to disable the querying by default.
 			 */
 			adapter->vfinfo[i].rss_query_enabled = 0;
+
+			/* Untrust all VFs */
+			adapter->vfinfo[i].trusted = false;
 		}
 
 		return 0;
@@ -1124,6 +1127,17 @@ void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(1), 0);
 }
 
+static inline void ixgbe_ping_vf(struct ixgbe_adapter *adapter, int vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 ping;
+
+	ping = IXGBE_PF_CONTROL_MSG;
+	if (adapter->vfinfo[vf].clear_to_send)
+		ping |= IXGBE_VT_MSGTYPE_CTS;
+	ixgbe_write_mbx(hw, &ping, 1, vf);
+}
+
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1416,6 +1430,28 @@ int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_trust(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	/* nothing to do */
+	if (adapter->vfinfo[vf].trusted == setting)
+		return 0;
+
+	adapter->vfinfo[vf].trusted = setting;
+
+	/* reset VF to reconfigure features */
+	adapter->vfinfo[vf].clear_to_send = false;
+	ixgbe_ping_vf(adapter, vf);
+
+	e_info(drv, "VF %u is %strusted\n", vf, setting ? "" : "not ");
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -1430,5 +1466,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
 	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
 	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
+	ivi->trusted = adapter->vfinfo[vf].trusted;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 2c197e6..dad9257 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -49,6 +49,7 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
 				  bool setting);
+int ixgbe_ndo_set_vf_trust(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
2.4.3
