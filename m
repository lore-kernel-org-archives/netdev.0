From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] ixgbe: Force VLNCTRL.VFE to be set in all VMDq paths
Date: Tue, 16 Aug 2016 13:40:12 -0700
Message-ID: <1471380014-134435-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56287 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753810AbcHPUkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:18 -0400
In-Reply-To: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When I was adding the code for enabling VLAN promiscuous mode with SR-IOV
enabled I had inadvertently left the VLNCTRL.VFE bit unchanged as I has
assumed there was code in another path that was setting it when we enabled
SR-IOV.  This wasn't the case and as a result we were just disabling VLAN
filtering for all the VFs apparently.

Also the previous patches were always clearing CFIEN which was always set
to 0 by the hardware anyway so I am dropping the redundant bit clearing.

Fixes: 16369564915a ("ixgbe: Add support for VLAN promiscuous with SR-IOV")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5418c69a..e0fdef8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4100,6 +4100,8 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 vlnctrl, i;
 
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
@@ -4112,8 +4114,7 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 		/* fall through */
 	case ixgbe_mac_82598EB:
 		/* legacy case, we can just disable VLAN filtering */
-		vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
-		vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
+		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		return;
 	}
@@ -4125,6 +4126,10 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 	/* Set flag so we don't redo unnecessary work */
 	adapter->flags2 |= IXGBE_FLAG2_VLAN_PROMISC;
 
+	/* For VMDq and SR-IOV we must leave VLAN filtering enabled */
+	vlnctrl |= IXGBE_VLNCTRL_VFE;
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+
 	/* Add PF to all active pools */
 	for (i = IXGBE_VLVF_ENTRIES; --i;) {
 		u32 reg_offset = IXGBE_VLVFB(i * 2 + VMDQ_P(0) / 32);
@@ -4191,6 +4196,11 @@ static void ixgbe_vlan_promisc_disable(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 vlnctrl, i;
 
+	/* Set VLAN filtering to enabled */
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	vlnctrl |= IXGBE_VLNCTRL_VFE;
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
@@ -4202,10 +4212,6 @@ static void ixgbe_vlan_promisc_disable(struct ixgbe_adapter *adapter)
 			break;
 		/* fall through */
 	case ixgbe_mac_82598EB:
-		vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
-		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		vlnctrl |= IXGBE_VLNCTRL_VFE;
-		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		return;
 	}
 
-- 
2.7.4
