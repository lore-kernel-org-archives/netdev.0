From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] ixgbe: Add new netdev op to turn spoof checking on or off per VF
Date: Sun, 16 Oct 2011 13:37:01 -0700
Message-ID: <1318797423-19897-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7001 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172Ab1JPUhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Oct 2011 16:37:08 -0400
In-Reply-To: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Implements the new netdev op to allow user configuration of spoof
checking on a per VF basis.

V2 - Change netdev spoof check op setting to bool

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   10 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   48 ++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    1 +
 4 files changed, 52 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index c1f76aa..6c4d693 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -130,6 +130,8 @@ struct vf_data_storage {
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 	u16 tx_rate;
+	u16 vlan_count;
+	u8 spoofchk_enabled;
 	struct pci_dev *vfdev;
 };
 
@@ -509,7 +511,6 @@ struct ixgbe_adapter {
 	int vf_rate_link_speed;
 	struct vf_macvlans vf_mvs;
 	struct vf_macvlans *mv_list;
-	bool antispoofing_enabled;
 
 	struct hlist_head fdir_filter_list;
 	union ixgbe_atr_input fdir_mask;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f740a8e..fb7d884 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2816,6 +2816,7 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	u32 vt_reg_bits;
 	u32 reg_offset, vf_shift;
 	u32 vmdctl;
+	int i;
 
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return;
@@ -2851,9 +2852,13 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 	/* Enable MAC Anti-Spoofing */
 	hw->mac.ops.set_mac_anti_spoofing(hw,
-					  (adapter->antispoofing_enabled =
-					   (adapter->num_vfs != 0)),
+					   (adapter->num_vfs != 0),
 					  adapter->num_vfs);
+	/* For VFs that have spoof checking turned off */
+	for (i = 0; i < adapter->num_vfs; i++) {
+		if (!adapter->vfinfo[i].spoofchk_enabled)
+			ixgbe_ndo_set_vf_spoofchk(adapter->netdev, i, false);
+	}
 }
 
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
@@ -7277,6 +7282,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_mac		= ixgbe_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
+	.ndo_set_vf_spoofchk    = ixgbe_ndo_set_vf_spoofchk,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 	.ndo_setup_tc		= ixgbe_setup_tc,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 468ddd0..db95731 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -151,6 +151,8 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 		/* Disable RSC when in SR-IOV mode */
 		adapter->flags2 &= ~(IXGBE_FLAG2_RSC_CAPABLE |
 				     IXGBE_FLAG2_RSC_ENABLED);
+		for (i = 0; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].spoofchk_enabled = true;
 		return;
 	}
 
@@ -620,7 +622,13 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 			       vf);
 			retval = -1;
 		} else {
+			if (add)
+				adapter->vfinfo[vf].vlan_count++;
+			else if (adapter->vfinfo[vf].vlan_count)
+				adapter->vfinfo[vf].vlan_count--;
 			retval = ixgbe_set_vf_vlan(adapter, add, vid, vf);
+			if (!retval && adapter->vfinfo[vf].spoofchk_enabled)
+				hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
 		}
 		break;
 	case IXGBE_VF_SET_MACVLAN:
@@ -632,12 +640,8 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		 * greater than 0 will indicate the VF is setting a
 		 * macvlan MAC filter.
 		 */
-		if (index > 0 && adapter->antispoofing_enabled) {
-			hw->mac.ops.set_mac_anti_spoofing(hw, false,
-							  adapter->num_vfs);
-			hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
-			adapter->antispoofing_enabled = false;
-		}
+		if (index > 0 && adapter->vfinfo[vf].spoofchk_enabled)
+			ixgbe_ndo_set_vf_spoofchk(adapter->netdev, vf, false);
 		retval = ixgbe_set_vf_macvlan(adapter, vf, index,
 					      (unsigned char *)(&msgbuf[1]));
 		break;
@@ -748,8 +752,9 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 			goto out;
 		ixgbe_set_vmvir(adapter, vlan | (qos << VLAN_PRIO_SHIFT), vf);
 		ixgbe_set_vmolr(hw, vf, false);
-		if (adapter->antispoofing_enabled)
+		if (adapter->vfinfo[vf].spoofchk_enabled)
 			hw->mac.ops.set_vlan_anti_spoofing(hw, true, vf);
+		adapter->vfinfo[vf].vlan_count++;
 		adapter->vfinfo[vf].pf_vlan = vlan;
 		adapter->vfinfo[vf].pf_qos = qos;
 		dev_info(&adapter->pdev->dev,
@@ -768,6 +773,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos)
 		ixgbe_set_vmvir(adapter, vlan, vf);
 		ixgbe_set_vmolr(hw, vf, true);
 		hw->mac.ops.set_vlan_anti_spoofing(hw, false, vf);
+		if (adapter->vfinfo[vf].vlan_count)
+			adapter->vfinfo[vf].vlan_count--;
 		adapter->vfinfo[vf].pf_vlan = 0;
 		adapter->vfinfo[vf].pf_qos = 0;
        }
@@ -877,6 +884,32 @@ int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate)
 	return 0;
 }
 
+int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int vf_target_reg = vf >> 3;
+	int vf_target_shift = vf % 8;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 regval;
+
+	adapter->vfinfo[vf].spoofchk_enabled = setting;
+
+	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
+	regval &= ~(1 << vf_target_shift);
+	regval |= (setting << vf_target_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg), regval);
+
+	if (adapter->vfinfo[vf].vlan_count) {
+		vf_target_shift += IXGBE_SPOOF_VLANAS_SHIFT;
+		regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
+		regval &= ~(1 << vf_target_shift);
+		regval |= (setting << vf_target_shift);
+		IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg), regval);
+	}
+
+	return 0;
+}
+
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi)
 {
@@ -888,5 +921,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 	ivi->tx_rate = adapter->vfinfo[vf].tx_rate;
 	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
 	ivi->qos = adapter->vfinfo[vf].pf_qos;
+	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 2781847..5a7e1eb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -38,6 +38,7 @@ int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
 			   u8 qos);
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
+int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-- 
1.7.6.4
