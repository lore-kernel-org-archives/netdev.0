From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] igb: add support for spoofchk config
Date: Thu, 18 Apr 2013 16:30:21 -0700
Message-ID: <1366327822-10741-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33249 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936735Ab3DRXbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:31:16 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

Add support for spoofchk configuration per VF via iproute2 tool.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |  1 +
 drivers/net/ethernet/intel/igb/igb_main.c | 34 +++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index cef8ec1..d47ac2a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -103,6 +103,7 @@ struct vf_data_storage {
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 	u16 tx_rate;
+	bool spoofchk_enabled;
 };
 
 #define IGB_VF_FLAG_CTS            0x00000001 /* VF is clear to send data */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c54ba42..666f87c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -169,6 +169,8 @@ static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8 *mac);
 static int igb_ndo_set_vf_vlan(struct net_device *netdev,
 			       int vf, u16 vlan, u8 qos);
 static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
+static int igb_ndo_set_vf_spoofchk(struct net_device *netdev, int vf,
+				   bool setting);
 static int igb_ndo_get_vf_config(struct net_device *netdev, int vf,
 				 struct ifla_vf_info *ivi);
 static void igb_check_vf_rate_limit(struct igb_adapter *);
@@ -1896,6 +1898,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_set_vf_mac		= igb_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= igb_ndo_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= igb_ndo_set_vf_bw,
+	.ndo_set_vf_spoofchk	= igb_ndo_set_vf_spoofchk,
 	.ndo_get_vf_config	= igb_ndo_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= igb_netpoll,
@@ -5230,6 +5233,9 @@ static int igb_vf_configure(struct igb_adapter *adapter, int vf)
 	eth_zero_addr(mac_addr);
 	igb_set_vf_mac(adapter, vf, mac_addr);
 
+	/* By default spoof check is enabled for all VFs */
+	adapter->vf_data[vf].spoofchk_enabled = true;
+
 	return 0;
 }
 
@@ -7592,6 +7598,33 @@ static int igb_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 	return 0;
 }
 
+static int igb_ndo_set_vf_spoofchk(struct net_device *netdev, int vf,
+				   bool setting)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg_val, reg_offset;
+
+	if (!adapter->vfs_allocated_count)
+		return -EOPNOTSUPP;
+
+	if (vf >= adapter->vfs_allocated_count)
+		return -EINVAL;
+
+	reg_offset = (hw->mac.type == e1000_82576) ? E1000_DTXSWC : E1000_TXSWC;
+	reg_val = rd32(reg_offset);
+	if (setting)
+		reg_val |= ((1 << vf) |
+			    (1 << (vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT)));
+	else
+		reg_val &= ~((1 << vf) |
+			     (1 << (vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT)));
+	wr32(reg_offset, reg_val);
+
+	adapter->vf_data[vf].spoofchk_enabled = setting;
+	return E1000_SUCCESS;
+}
+
 static int igb_ndo_get_vf_config(struct net_device *netdev,
 				 int vf, struct ifla_vf_info *ivi)
 {
@@ -7603,6 +7636,7 @@ static int igb_ndo_get_vf_config(struct net_device *netdev,
 	ivi->tx_rate = adapter->vf_data[vf].tx_rate;
 	ivi->vlan = adapter->vf_data[vf].pf_vlan;
 	ivi->qos = adapter->vf_data[vf].pf_qos;
+	ivi->spoofchk = adapter->vf_data[vf].spoofchk_enabled;
 	return 0;
 }
 
-- 
1.7.11.7
