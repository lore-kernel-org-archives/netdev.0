From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: remove vlan_filter_disable and enable functions
Date: Wed, 23 Apr 2014 04:15:15 -0700
Message-ID: <1398251726-13638-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753046AbaDWLPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:34 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Previously these functions handled stripping setup as well, but this has
already been removed from these functions. Rather than encapsulating
this into a function, we can just do the work directly in set_rx_mode.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 40 ++++-----------------------
 1 file changed, 6 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7a67a9f..220937ba 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3768,35 +3768,6 @@ static int ixgbe_vlan_rx_kill_vid(struct net_device *netdev,
 }
 
 /**
- * ixgbe_vlan_filter_disable - helper to disable hw vlan filtering
- * @adapter: driver data
- */
-static void ixgbe_vlan_filter_disable(struct ixgbe_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 vlnctrl;
-
-	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
-	vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
-	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
-}
-
-/**
- * ixgbe_vlan_filter_enable - helper to enable hw vlan filtering
- * @adapter: driver data
- */
-static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 vlnctrl;
-
-	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
-	vlnctrl |= IXGBE_VLNCTRL_VFE;
-	vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
-	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
-}
-
-/**
  * ixgbe_vlan_strip_disable - helper to disable hw vlan stripping
  * @adapter: driver data
  */
@@ -3933,11 +3904,13 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 fctrl, vmolr = IXGBE_VMOLR_BAM | IXGBE_VMOLR_AUPE;
+	u32 vlnctrl;
 	int count;
 
 	/* Check for Promiscuous and All Multicast modes */
 
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 
 	/* set all bits that we expect to always be set */
 	fctrl &= ~IXGBE_FCTRL_SBP; /* disable store-bad-packets */
@@ -3947,7 +3920,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 
 	/* clear the bits we are changing the status of */
 	fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
-
+	vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
 	if (netdev->flags & IFF_PROMISC) {
 		hw->addr_ctrl.user_set_promisc = true;
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
@@ -3958,15 +3931,13 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		 */
 		if (!(adapter->flags & (IXGBE_FLAG_VMDQ_ENABLED |
 					IXGBE_FLAG_SRIOV_ENABLED)))
-			ixgbe_vlan_filter_disable(adapter);
-		else
-			ixgbe_vlan_filter_enable(adapter);
+			vlnctrl |= (IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
 			vmolr |= IXGBE_VMOLR_MPE;
 		}
-		ixgbe_vlan_filter_enable(adapter);
+		vlnctrl |= IXGBE_VLNCTRL_VFE;
 		hw->addr_ctrl.user_set_promisc = false;
 	}
 
@@ -4010,6 +3981,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		/* NOTE:  VLAN filtering is disabled by setting PROMISC */
 	}
 
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 
 	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
-- 
1.9.0
