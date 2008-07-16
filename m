From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/2]: netdrv intel: always enable VLAN filtering except in
 promiscous mode
Date: Wed, 16 Jul 2008 11:44:35 +0200
Message-ID: <487DC303.8010604@trash.net>
References: <487DC2C4.9030006@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070206010602010503040406"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50220 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580AbYGPJoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 05:44:37 -0400
In-Reply-To: <487DC2C4.9030006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070206010602010503040406
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------070206010602010503040406
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 6e3767e854209df125d7c2d70f23ae97ab61e5f2
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 16 11:05:21 2008 +0200

    netdrv intel: always enable VLAN filtering except in promiscous mode
    
    Currently VLAN filtering is enabled when the first VLAN is added.
    Obviously before that there's no point in receiving any VLAN packets.
    Now that we disable VLAN filtering in promiscous mode, we can keep
    the VLAN filters enabled the remaining time.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 80e3a65..f8df8bd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2484,7 +2484,7 @@ e1000_set_rx_mode(struct net_device *netdev)
 		} else {
 			rctl &= ~E1000_RCTL_MPE;
 		}
-		if (adapter->vlgrp && adapter->hw.mac_type != e1000_ich8lan)
+		if (adapter->hw.mac_type != e1000_ich8lan)
 			rctl |= E1000_RCTL_VFE;
 	}
 
@@ -4967,8 +4967,6 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
-			if (!(netdev->flags & IFF_PROMISC))
-				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
@@ -4980,10 +4978,6 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 
 		if (adapter->hw.mac_type != e1000_ich8lan) {
-			/* disable VLAN filtering */
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
-			rctl &= ~E1000_RCTL_VFE;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			if (adapter->mng_vlan_id !=
 			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3fe6026..be59533 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1792,8 +1792,6 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
 			/* enable VLAN receive filtering */
 			rctl = er32(RCTL);
-			if (!(netdev->flags & IFF_PROMISC))
-				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			ew32(RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
@@ -1805,10 +1803,6 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		ew32(CTRL, ctrl);
 
 		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
-			/* disable VLAN filtering */
-			rctl = er32(RCTL);
-			rctl &= ~E1000_RCTL_VFE;
-			ew32(RCTL, rctl);
 			if (adapter->mng_vlan_id !=
 			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
@@ -2239,7 +2233,7 @@ static void e1000_set_multi(struct net_device *netdev)
 		} else {
 			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
 		}
-		if (adapter->vlgrp && adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
+		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 			rctl |= E1000_RCTL_VFE;
 	}
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1ab8e3e..74dc43e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2277,8 +2277,7 @@ static void igb_set_multi(struct net_device *netdev)
 			rctl &= ~E1000_RCTL_UPE;
 		} else
 			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
-		if (adapter->vlgrp)
-			rctl |= E1000_RCTL_VFE;
+		rctl |= E1000_RCTL_VFE;
 	}
 	wr32(E1000_RCTL, rctl);
 
@@ -4224,8 +4223,6 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 
 		/* enable VLAN receive filtering */
 		rctl = rd32(E1000_RCTL);
-		if (!(netdev->flags & IFF_PROMISC))
-			rctl |= E1000_RCTL_VFE;
 		rctl &= ~E1000_RCTL_CFIEN;
 		wr32(E1000_RCTL, rctl);
 		igb_update_mng_vlan(adapter);
@@ -4237,10 +4234,6 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 		ctrl &= ~E1000_CTRL_VME;
 		wr32(E1000_CTRL, ctrl);
 
-		/* disable VLAN filtering */
-		rctl = rd32(E1000_RCTL);
-		rctl &= ~E1000_RCTL_VFE;
-		wr32(E1000_RCTL, rctl);
 		if (adapter->mng_vlan_id != (u16)IGB_MNG_VLAN_NONE) {
 			igb_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 			adapter->mng_vlan_id = IGB_MNG_VLAN_NONE;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ec95cd4..aa75385 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1061,8 +1061,7 @@ ixgb_set_multi(struct net_device *netdev)
 		} else {
 			rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 		}
-		if (adapter->vlgrp)
-			rctl |= IXGB_RCTL_VFE;
+		rctl |= IXGB_RCTL_VFE;
 	}
 
 	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
@@ -2109,8 +2108,6 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		/* enable VLAN receive filtering */
 
 		rctl = IXGB_READ_REG(&adapter->hw, RCTL);
-		if (!(netdev->flags & IFF_PROMISC))
-			rctl |= IXGB_RCTL_VFE;
 		rctl &= ~IXGB_RCTL_CFIEN;
 		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 	} else {
@@ -2119,12 +2116,6 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
 		ctrl &= ~IXGB_CTRL0_VME;
 		IXGB_WRITE_REG(&adapter->hw, CTRL0, ctrl);
-
-		/* disable VLAN filtering */
-
-		rctl = IXGB_READ_REG(&adapter->hw, RCTL);
-		rctl &= ~IXGB_RCTL_VFE;
-		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 	}
 
 	/* don't enable interrupts unless we are UP */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index afe3a1c..7d8bf94 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1575,8 +1575,6 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
 		ctrl |= IXGBE_VLNCTRL_VME;
-		if (!(netdev->flags & IFF_PROMISC))
-			ctrl |= IXGBE_VLNCTRL_VFE;
 		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
 	}
@@ -1655,8 +1653,7 @@ static void ixgbe_set_multi(struct net_device *netdev)
 		} else {
 			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
-		if (adapter->vlgrp)
-			fctrl |= IXGBE_VLNCTRL_VFE;
+		fctrl |= IXGBE_VLNCTRL_VFE;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);

--------------070206010602010503040406--
