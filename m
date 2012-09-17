From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] ixgbe: Fix ordering of things so that PF correctly configures its VLANs
Date: Sun, 16 Sep 2012 21:15:36 -0700
Message-ID: <1347855342-6610-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab2IQEPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:49 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The PF was not correctly registering any of its VLANs.  As a result any
VLAN tagged traffic from the VF would not be delivered to the PF because
the VLAN was never assigned to the PF pool.

In addition the VF was not allowed to receive traffic from VLAN 0 if it was
allowed to receive untagged frames.  This change corrects that so that it
will correctly receive traffic from VLAN 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 9 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 5 +++++
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1cbb34f..ac91567 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3660,8 +3660,6 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		netif_set_gso_max_size(adapter->netdev, 32768);
 
-	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
-
 #ifdef IXGBE_FCOE
 	if (adapter->netdev->features & NETIF_F_FCOE_MTU)
 		max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
@@ -3861,6 +3859,11 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_IXGBE_DCB
 	ixgbe_configure_dcb(adapter);
 #endif
+	/*
+	 * We must restore virtualization before VLANs or else
+	 * the VLVF registers will not be populated
+	 */
+	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_set_rx_mode(adapter->netdev);
 	ixgbe_restore_vlan(adapter);
@@ -3892,8 +3895,6 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	ixgbe_configure_virtualization(adapter);
-
 #ifdef IXGBE_FCOE
 	/* configure FCoE L2 filters, redirection table, and Rx control */
 	ixgbe_configure_fcoe(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 4fea871..3b1c914 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -346,6 +346,10 @@ void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter)
 static int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid,
 			     u32 vf)
 {
+	/* VLAN 0 is a special case, don't allow it to be removed */
+	if (!vid && !add)
+		return 0;
+
 	return adapter->hw.mac.ops.set_vfta(&adapter->hw, vid, vf, (bool)add);
 }
 
@@ -414,6 +418,7 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 				  VLAN_PRIO_SHIFT)), vf);
 		ixgbe_set_vmolr(hw, vf, false);
 	} else {
+		ixgbe_set_vf_vlan(adapter, true, 0, vf);
 		ixgbe_set_vmvir(adapter, 0, vf);
 		ixgbe_set_vmolr(hw, vf, true);
 	}
-- 
1.7.11.4
