From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/2]: netdrv intel: disable VLAN filtering in promiscous mode
Date: Wed, 16 Jul 2008 11:44:04 +0200
Message-ID: <487DC2E4.3070403@trash.net>
References: <487DC2C4.9030006@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205000201070401060309"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50194 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbYGPJoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 05:44:08 -0400
In-Reply-To: <487DC2C4.9030006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010205000201070401060309
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit



--------------010205000201070401060309
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit acec641127a35c44173d243ef300f7fa6cbec646
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 16 11:03:55 2008 +0200

    netdrv intel: disable VLAN filtering in promiscous mode
    
    As discussed in this thread:
    
    http://www.mail-archive.com/netdev@vger.kernel.org/msg53976.html
    
    promiscous mode means to disable *all* filters. Currently only unicast
    and multicast filtering is disabled. This patch changes all Intel
    drivers to also disable VLAN filtering.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7aa458f..80e3a65 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2477,10 +2477,15 @@ e1000_set_rx_mode(struct net_device *netdev)
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
+		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		rctl &= ~E1000_RCTL_MPE;
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+		} else {
+			rctl &= ~E1000_RCTL_MPE;
+		}
+		if (adapter->vlgrp && adapter->hw.mac_type != e1000_ich8lan)
+			rctl |= E1000_RCTL_VFE;
 	}
 
 	uc_ptr = NULL;
@@ -4962,7 +4967,8 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
-			rctl |= E1000_RCTL_VFE;
+			if (!(netdev->flags & IFF_PROMISC))
+				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 80592bd..3fe6026 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1792,7 +1792,8 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
 			/* enable VLAN receive filtering */
 			rctl = er32(RCTL);
-			rctl |= E1000_RCTL_VFE;
+			if (!(netdev->flags & IFF_PROMISC))
+				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			ew32(RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
@@ -2230,11 +2231,16 @@ static void e1000_set_multi(struct net_device *netdev)
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
+		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+			rctl &= ~E1000_RCTL_UPE;
+		} else {
+			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		}
+		if (adapter->vlgrp && adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
+			rctl |= E1000_RCTL_VFE;
 	}
 
 	ew32(RCTL, rctl);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index aaed129..1ab8e3e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2268,14 +2268,18 @@ static void igb_set_multi(struct net_device *netdev)
 
 	rctl = rd32(E1000_RCTL);
 
-	if (netdev->flags & IFF_PROMISC)
+	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
-	} else
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
-
+		rctl &= ~E1000_RCTL_VFE;
+	} else {
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+			rctl &= ~E1000_RCTL_UPE;
+		} else
+			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		if (adapter->vlgrp)
+			rctl |= E1000_RCTL_VFE;
+	}
 	wr32(E1000_RCTL, rctl);
 
 	if (!netdev->mc_count) {
@@ -4220,7 +4224,8 @@ static void igb_vlan_rx_register(struct net_device *netdev,
 
 		/* enable VLAN receive filtering */
 		rctl = rd32(E1000_RCTL);
-		rctl |= E1000_RCTL_VFE;
+		if (!(netdev->flags & IFF_PROMISC))
+			rctl |= E1000_RCTL_VFE;
 		rctl &= ~E1000_RCTL_CFIEN;
 		wr32(E1000_RCTL, rctl);
 		igb_update_mng_vlan(adapter);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e83feaf..ec95cd4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1053,11 +1053,16 @@ ixgb_set_multi(struct net_device *netdev)
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= IXGB_RCTL_MPE;
-		rctl &= ~IXGB_RCTL_UPE;
+		rctl &= ~IXGB_RCTL_VFE;
 	} else {
-		rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= IXGB_RCTL_MPE;
+			rctl &= ~IXGB_RCTL_UPE;
+		} else {
+			rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
+		}
+		if (adapter->vlgrp)
+			rctl |= IXGB_RCTL_VFE;
 	}
 
 	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
@@ -2104,7 +2109,8 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		/* enable VLAN receive filtering */
 
 		rctl = IXGB_READ_REG(&adapter->hw, RCTL);
-		rctl |= IXGB_RCTL_VFE;
+		if (!(netdev->flags & IFF_PROMISC))
+			rctl |= IXGB_RCTL_VFE;
 		rctl &= ~IXGB_RCTL_CFIEN;
 		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 	} else {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 10a1c8c..afe3a1c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1574,7 +1574,9 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	if (grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
-		ctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
+		ctrl |= IXGBE_VLNCTRL_VME;
+		if (!(netdev->flags & IFF_PROMISC))
+			ctrl |= IXGBE_VLNCTRL_VFE;
 		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
 	}
@@ -1645,11 +1647,16 @@ static void ixgbe_set_multi(struct net_device *netdev)
 
 	if (netdev->flags & IFF_PROMISC) {
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		fctrl |= IXGBE_FCTRL_MPE;
-		fctrl &= ~IXGBE_FCTRL_UPE;
+		fctrl &= ~IXGBE_VLNCTRL_VFE;
 	} else {
-		fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+		if (netdev->flags & IFF_ALLMULTI) {
+			fctrl |= IXGBE_FCTRL_MPE;
+			fctrl &= ~IXGBE_FCTRL_UPE;
+		} else {
+			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+		}
+		if (adapter->vlgrp)
+			fctrl |= IXGBE_VLNCTRL_VFE;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);

--------------010205000201070401060309--
