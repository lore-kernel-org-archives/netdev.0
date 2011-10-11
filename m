From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] igb: fix recent VLAN changes that would leave VLANs disabled after reset
Date: Tue, 11 Oct 2011 08:45:50 -0700
Message-ID: <1318347952-25068-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29971 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754947Ab1JKPp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:58 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up several issues with VLANs on igb after the recent
changes that were meant to leave the VLANs enabled/disable via the
netdev->features flags.

Specifically the Rx VLAN settings were being dropped after reset due to the
fact that they were not being restored correctly.  In addition I removed
the IRQ disable/enable since those were in place to protect the setting of
vlgrp.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6917c33..689c2c2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2065,8 +2065,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	igb_vlan_mode(netdev, netdev->features);
-
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
@@ -5050,7 +5048,6 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 			}
 
 			adapter->vf_data[vf].vlans_enabled++;
-			return 0;
 		}
 	} else {
 		if (i < E1000_VLVF_ARRAY_SIZE) {
@@ -6315,10 +6312,9 @@ static void igb_vlan_mode(struct net_device *netdev, u32 features)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
+	bool enable = !!(features & NETIF_F_HW_VLAN_RX);
 
-	igb_irq_disable(adapter);
-
-	if (features & NETIF_F_HW_VLAN_RX) {
+	if (enable) {
 		/* enable VLAN tag insert/strip */
 		ctrl = rd32(E1000_CTRL);
 		ctrl |= E1000_CTRL_VME;
@@ -6336,9 +6332,6 @@ static void igb_vlan_mode(struct net_device *netdev, u32 features)
 	}
 
 	igb_rlpml_set(adapter);
-
-	if (!test_bit(__IGB_DOWN, &adapter->state))
-		igb_irq_enable(adapter);
 }
 
 static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -6363,11 +6356,6 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	int pf_id = adapter->vfs_allocated_count;
 	s32 err;
 
-	igb_irq_disable(adapter);
-
-	if (!test_bit(__IGB_DOWN, &adapter->state))
-		igb_irq_enable(adapter);
-
 	/* remove vlan from VLVF table array */
 	err = igb_vlvf_set(adapter, vid, false, pf_id);
 
@@ -6382,6 +6370,8 @@ static void igb_restore_vlan(struct igb_adapter *adapter)
 {
 	u16 vid;
 
+	igb_vlan_mode(adapter->netdev, adapter->netdev->features);
+
 	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
 		igb_vlan_rx_add_vid(adapter->netdev, vid);
 }
-- 
1.7.6.4
