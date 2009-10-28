From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/23] igb: rework handling of the vfta and vlvf
	registers in relation to mng_vlan
Date: Wed, 28 Oct 2009 02:47:35 -0700
Message-ID: <20091028094734.13156.1387.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:50346 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbZJ1JvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:51:18 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch corrects some errors in how vlans are being handled when vfs
start interacting with the management vlans.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   94 +++++++++++++++-----------------------------
 1 files changed, 32 insertions(+), 62 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3ab2978..9170927 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -963,24 +963,23 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 
 static void igb_update_mng_vlan(struct igb_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
 	u16 vid = adapter->hw.mng_cookie.vlan_id;
 	u16 old_vid = adapter->mng_vlan_id;
-	if (adapter->vlgrp) {
-		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
-			if (adapter->hw.mng_cookie.status &
-				E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
-				igb_vlan_rx_add_vid(netdev, vid);
-				adapter->mng_vlan_id = vid;
-			} else
-				adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
 
-			if ((old_vid != (u16)IGB_MNG_VLAN_NONE) &&
-					(vid != old_vid) &&
-			    !vlan_group_get_device(adapter->vlgrp, old_vid))
-				igb_vlan_rx_kill_vid(netdev, old_vid);
-		} else
-			adapter->mng_vlan_id = vid;
+	if (hw->mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
+		/* add VID to filter table */
+		igb_vfta_set(hw, vid, true);
+		adapter->mng_vlan_id = vid;
+	} else {
+		adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
+	}
+
+	if ((old_vid != (u16)IGB_MNG_VLAN_NONE) &&
+	    (vid != old_vid) &&
+	    !vlan_group_get_device(adapter->vlgrp, old_vid)) {
+		/* remove VID from filter table */
+		igb_vfta_set(hw, old_vid, false);
 	}
 }
 
@@ -1847,11 +1846,6 @@ static int igb_open(struct net_device *netdev)
 
 	/* e1000_power_up_phy(adapter); */
 
-	adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
-	if ((adapter->hw.mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
-		igb_update_mng_vlan(adapter);
-
 	/* before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our
@@ -1924,14 +1918,6 @@ static int igb_close(struct net_device *netdev)
 	igb_free_all_tx_resources(adapter);
 	igb_free_all_rx_resources(adapter);
 
-	/* kill manageability vlan ID if supported, but not if a vlan with
-	 * the same ID is registered on the host OS (let 8021q kill it) */
-	if ((adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
-	     !(adapter->vlgrp &&
-	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id)))
-		igb_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
-
 	return 0;
 }
 
@@ -4235,7 +4221,11 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 reg, i;
 
-	/* It is an error to call this function when VFs are not enabled */
+	/* The vlvf table only exists on 82576 hardware and newer */
+	if (hw->mac.type < e1000_82576)
+		return -1;
+
+	/* we only need to do this if VMDq is enabled */
 	if (!adapter->vfs_allocated_count)
 		return -1;
 
@@ -4265,16 +4255,12 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 
 			/* if !enabled we need to set this up in vfta */
 			if (!(reg & E1000_VLVF_VLANID_ENABLE)) {
-				/* add VID to filter table, if bit already set
-				 * PF must have added it outside of table */
-				if (igb_vfta_set(hw, vid, true))
-					reg |= 1 << (E1000_VLVF_POOLSEL_SHIFT +
-						adapter->vfs_allocated_count);
+				/* add VID to filter table */
+				igb_vfta_set(hw, vid, true);
 				reg |= E1000_VLVF_VLANID_ENABLE;
 			}
 			reg &= ~E1000_VLVF_VLANID_MASK;
 			reg |= vid;
-
 			wr32(E1000_VLVF(i), reg);
 
 			/* do not modify RLPML for PF devices */
@@ -4290,8 +4276,8 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 				reg |= size;
 				wr32(E1000_VMOLR(vf), reg);
 			}
-			adapter->vf_data[vf].vlans_enabled++;
 
+			adapter->vf_data[vf].vlans_enabled++;
 			return 0;
 		}
 	} else {
@@ -5393,21 +5379,15 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 		ctrl |= E1000_CTRL_VME;
 		wr32(E1000_CTRL, ctrl);
 
-		/* enable VLAN receive filtering */
+		/* Disable CFI check */
 		rctl = rd32(E1000_RCTL);
 		rctl &= ~E1000_RCTL_CFIEN;
 		wr32(E1000_RCTL, rctl);
-		igb_update_mng_vlan(adapter);
 	} else {
 		/* disable VLAN tag insert/strip */
 		ctrl = rd32(E1000_CTRL);
 		ctrl &= ~E1000_CTRL_VME;
 		wr32(E1000_CTRL, ctrl);
-
-		if (adapter->mng_vlan_id != (u16)IGB_MNG_VLAN_NONE) {
-			igb_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
-			adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
-		}
 	}
 
 	igb_rlpml_set(adapter);
@@ -5422,16 +5402,11 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 	int pf_id = adapter->vfs_allocated_count;
 
-	if ((hw->mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
-	    (vid == adapter->mng_vlan_id))
-		return;
-
-	/* add vid to vlvf if sr-iov is enabled,
-	 * if that fails add directly to filter table */
-	if (igb_vlvf_set(adapter, vid, true, pf_id))
-		igb_vfta_set(hw, vid, true);
+	/* attempt to add filter to vlvf array */
+	igb_vlvf_set(adapter, vid, true, pf_id);
 
+	/* add the filter since PF can receive vlans w/o entry in vlvf */
+	igb_vfta_set(hw, vid, true);
 }
 
 static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -5439,6 +5414,7 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	int pf_id = adapter->vfs_allocated_count;
+	s32 err;
 
 	igb_irq_disable(adapter);
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
@@ -5446,17 +5422,11 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		igb_irq_enable(adapter);
 
-	if ((adapter->hw.mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
-	    (vid == adapter->mng_vlan_id)) {
-		/* release control to f/w */
-		igb_release_hw_control(adapter);
-		return;
-	}
+	/* remove vlan from VLVF table array */
+	err = igb_vlvf_set(adapter, vid, false, pf_id);
 
-	/* remove vid from vlvf if sr-iov is enabled,
-	 * if not in vlvf remove from vfta */
-	if (igb_vlvf_set(adapter, vid, false, pf_id))
+	/* if vid was not present in VLVF just remove it from table */
+	if (err)
 		igb_vfta_set(hw, vid, false);
 }
 

