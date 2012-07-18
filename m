From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: Update configure virtualization to allow for multiple PF pools
Date: Wed, 18 Jul 2012 13:31:53 -0700
Message-ID: <1342643516-2696-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18725 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984Ab2GRUcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:03 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change allows all pools from the default pool forward to be enabled vi
ixgbe_configure_virtualization.  This is needed as we are planning to use
queues belonging to adjacent pools for FCoE when SR-IOV and FCoE are both
enabled.

In addition this patch contains some minor formatting changes as there were
a few spots that seemed to be in need of some cleanup.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2b4b791..ea94fa2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3130,28 +3130,28 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 gcr_ext;
-	u32 vt_reg_bits;
 	u32 reg_offset, vf_shift;
-	u32 vmdctl;
+	u32 gcr_ext, vmdctl;
 	int i;
 
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
 		return;
 
 	vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
-	vt_reg_bits = IXGBE_VMD_CTL_VMDQ_EN | IXGBE_VT_CTL_REPLEN;
-	vt_reg_bits |= (adapter->num_vfs << IXGBE_VT_CTL_POOL_SHIFT);
-	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl | vt_reg_bits);
+	vmdctl |= IXGBE_VMD_CTL_VMDQ_EN;
+	vmdctl &= ~IXGBE_VT_CTL_POOL_MASK;
+	vmdctl |= (adapter->num_vfs << IXGBE_VT_CTL_POOL_SHIFT);
+	vmdctl |= IXGBE_VT_CTL_REPLEN;
+	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl);
 
 	vf_shift = adapter->num_vfs % 32;
 	reg_offset = (adapter->num_vfs >= 32) ? 1 : 0;
 
 	/* Enable only the PF's pool for Tx/Rx */
-	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
-	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), 0);
-	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
-	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (~0) << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), reg_offset - 1);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (~0) << vf_shift);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), reg_offset - 1);
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
@@ -3168,9 +3168,9 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 
 	/* enable Tx loopback for VF/PF communication */
 	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+
 	/* Enable MAC Anti-Spoofing */
-	hw->mac.ops.set_mac_anti_spoofing(hw,
-					   (adapter->num_vfs != 0),
+	hw->mac.ops.set_mac_anti_spoofing(hw, (adapter->num_vfs != 0),
 					  adapter->num_vfs);
 	/* For VFs that have spoof checking turned off */
 	for (i = 0; i < adapter->num_vfs; i++) {
-- 
1.7.10.4
