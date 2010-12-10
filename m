From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/27] ixgb: Don't check for vlan group on transmit
Date: Fri, 10 Dec 2010 01:50:50 -0800
Message-ID: <1291974667-30254-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, jesse@nicira.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:38746
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113Ab0LJJ5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 04:57:15 -0500
To: davem@davemloft.net
In-Reply-To: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Based on a patch from Jesse Gross.

Enable vlan tag insertion even when vlan group is not configured.

For ixgb HW both CTRL0.VME and VLE bit in the Tx descriptor need to be set
in order to enable HW acceleration.

Introduced separate functions for enabling/disabling of vlan tag stripping
similar to ixgbe.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgb/ixgb_main.c |   51 ++++++++++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 211a169..2e98506 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -98,6 +98,8 @@ static void ixgb_alloc_rx_buffers(struct ixgb_adapter *, int);
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
 
+static void ixgb_vlan_strip_enable(struct ixgb_adapter *adapter);
+static void ixgb_vlan_strip_disable(struct ixgb_adapter *adapter);
 static void ixgb_vlan_rx_register(struct net_device *netdev,
                                   struct vlan_group *grp);
 static void ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
@@ -1076,6 +1078,8 @@ ixgb_set_multi(struct net_device *netdev)
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
+		/* disable VLAN filtering */
+		rctl &= ~IXGB_RCTL_CFIEN;
 		rctl &= ~IXGB_RCTL_VFE;
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
@@ -1084,7 +1088,9 @@ ixgb_set_multi(struct net_device *netdev)
 		} else {
 			rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 		}
+		/* enable VLAN filtering */
 		rctl |= IXGB_RCTL_VFE;
+		rctl &= ~IXGB_RCTL_CFIEN;
 	}
 
 	if (netdev_mc_count(netdev) > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
@@ -1103,6 +1109,12 @@ ixgb_set_multi(struct net_device *netdev)
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
 	}
+
+	if (netdev->features & NETIF_F_HW_VLAN_RX)
+		ixgb_vlan_strip_enable(adapter);
+	else
+		ixgb_vlan_strip_disable(adapter);
+
 }
 
 /**
@@ -2150,33 +2162,30 @@ static void
 ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	u32 ctrl, rctl;
 
-	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
+}
 
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
-		ctrl |= IXGB_CTRL0_VME;
-		IXGB_WRITE_REG(&adapter->hw, CTRL0, ctrl);
-
-		/* enable VLAN receive filtering */
+static void
+ixgb_vlan_strip_enable(struct ixgb_adapter *adapter)
+{
+	u32 ctrl;
 
-		rctl = IXGB_READ_REG(&adapter->hw, RCTL);
-		rctl &= ~IXGB_RCTL_CFIEN;
-		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
-	} else {
-		/* disable VLAN tag insert/strip */
+	/* enable VLAN tag insert/strip */
+	ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
+	ctrl |= IXGB_CTRL0_VME;
+	IXGB_WRITE_REG(&adapter->hw, CTRL0, ctrl);
+}
 
-		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
-		ctrl &= ~IXGB_CTRL0_VME;
-		IXGB_WRITE_REG(&adapter->hw, CTRL0, ctrl);
-	}
+static void
+ixgb_vlan_strip_disable(struct ixgb_adapter *adapter)
+{
+	u32 ctrl;
 
-	/* don't enable interrupts unless we are UP */
-	if (adapter->netdev->flags & IFF_UP)
-		ixgb_irq_enable(adapter);
+	/* disable VLAN tag insert/strip */
+	ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
+	ctrl &= ~IXGB_CTRL0_VME;
+	IXGB_WRITE_REG(&adapter->hw, CTRL0, ctrl);
 }
 
 static void
-- 
1.7.3.2

