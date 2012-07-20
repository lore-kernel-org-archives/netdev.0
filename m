From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] ixgbe: Use VMDq offset to indicate the default pool
Date: Thu, 19 Jul 2012 18:23:58 -0700
Message-ID: <1342747446-16132-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55809 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099Ab2GTBYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:13 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we can use the VMDq ring feature offset value
to determine the default pool instead of using num_vfs.  The reason for
this change is to avoid issues should we fail to allocate vfinfo but have
pre-existing VFs.  What should happen in this case is that num_vfs will go
to 0, but the VMDq offset will contain the location of the first PF pool.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <Sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   33 +++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    5 ++++
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f7f6fe2..c236500 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -113,7 +113,7 @@
 #define IXGBE_MAX_VFTA_ENTRIES          128
 #define MAX_EMULATION_MAC_ADDRS         16
 #define IXGBE_MAX_PF_MACVLANS           15
-#define VMDQ_P(p)   ((p) + adapter->num_vfs)
+#define VMDQ_P(p)   ((p) + adapter->ring_feature[RING_F_VMDQ].offset)
 #define IXGBE_82599_VF_DEVICE_ID        0x10ED
 #define IXGBE_X540_VF_DEVICE_ID         0x1515
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a3dc965..f110e88 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3118,7 +3118,7 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 		psrtype |= 1 << 29;
 
 	for (p = 0; p < adapter->num_rx_pools; p++)
-		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(adapter->num_vfs + p),
+		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(p)),
 				psrtype);
 }
 
@@ -3135,12 +3135,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
 	vmdctl |= IXGBE_VMD_CTL_VMDQ_EN;
 	vmdctl &= ~IXGBE_VT_CTL_POOL_MASK;
-	vmdctl |= (adapter->num_vfs << IXGBE_VT_CTL_POOL_SHIFT);
+	vmdctl |= VMDQ_P(0) << IXGBE_VT_CTL_POOL_SHIFT;
 	vmdctl |= IXGBE_VT_CTL_REPLEN;
 	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl);
 
-	vf_shift = adapter->num_vfs % 32;
-	reg_offset = (adapter->num_vfs >= 32) ? 1 : 0;
+	vf_shift = VMDQ_P(0) % 32;
+	reg_offset = (VMDQ_P(0) >= 32) ? 1 : 0;
 
 	/* Enable only the PF's pool for Tx/Rx */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (~0) << vf_shift);
@@ -3150,7 +3150,7 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
-	hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
+	hw->mac.ops.set_vmdq(hw, 0, VMDQ_P(0));
 
 	/*
 	 * Set up VF register offsets for selected VT Mode,
@@ -3310,10 +3310,9 @@ static int ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	int pool_ndx = adapter->num_vfs;
 
 	/* add VID to filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, true);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, VMDQ_P(0), true);
 	set_bit(vid, adapter->active_vlans);
 
 	return 0;
@@ -3323,10 +3322,9 @@ static int ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	int pool_ndx = adapter->num_vfs;
 
 	/* remove VID from filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, false);
+	hw->mac.ops.set_vfta(&adapter->hw, vid, VMDQ_P(0), false);
 	clear_bit(vid, adapter->active_vlans);
 
 	return 0;
@@ -3444,7 +3442,6 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	unsigned int vfn = adapter->num_vfs;
 	unsigned int rar_entries = IXGBE_MAX_PF_MACVLANS;
 	int count = 0;
 
@@ -3462,7 +3459,7 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 			if (!rar_entries)
 				break;
 			hw->mac.ops.set_rar(hw, rar_entries--, ha->addr,
-					    vfn, IXGBE_RAH_AV);
+					    VMDQ_P(0), IXGBE_RAH_AV);
 			count++;
 		}
 	}
@@ -3536,12 +3533,14 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		vmolr |= IXGBE_VMOLR_ROPE;
 	}
 
-	if (adapter->num_vfs) {
+	if (adapter->num_vfs)
 		ixgbe_restore_vf_multicasts(adapter);
-		vmolr |= IXGBE_READ_REG(hw, IXGBE_VMOLR(adapter->num_vfs)) &
+
+	if (hw->mac.type != ixgbe_mac_82598EB) {
+		vmolr |= IXGBE_READ_REG(hw, IXGBE_VMOLR(VMDQ_P(0))) &
 			 ~(IXGBE_VMOLR_MPE | IXGBE_VMOLR_ROMPE |
 			   IXGBE_VMOLR_ROPE);
-		IXGBE_WRITE_REG(hw, IXGBE_VMOLR(adapter->num_vfs), vmolr);
+		IXGBE_WRITE_REG(hw, IXGBE_VMOLR(VMDQ_P(0)), vmolr);
 	}
 
 	/* This is useful for sniffing bad packets. */
@@ -4120,8 +4119,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
 
 	/* reprogram the RAR[0] in case user changed it. */
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
-			    IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, VMDQ_P(0), IXGBE_RAH_AV);
 }
 
 /**
@@ -6445,8 +6443,7 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
 
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
-			    IXGBE_RAH_AV);
+	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, VMDQ_P(0), IXGBE_RAH_AV);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d285443..c7d831d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -225,6 +225,11 @@ void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl);
 	IXGBE_WRITE_FLUSH(hw);
 
+	/* Disable VMDq flag so device will be set in VM mode */
+	if (adapter->ring_feature[RING_F_VMDQ].limit == 1)
+		adapter->flags &= ~IXGBE_FLAG_VMDQ_ENABLED;
+	adapter->ring_feature[RING_F_VMDQ].offset = 0;
+
 	/* take a breather then clean up driver data */
 	msleep(100);
 
-- 
1.7.10.4
