From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] ixgbe: fix tag stripping for VLAN ID 0
Date: Mon, 19 Jan 2009 16:11:26 -0800
Message-ID: <20090120001126.22544.65196.stgit@lost.foo-projects.org>
References: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:56019
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764044AbZATALr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:11:47 -0500
In-Reply-To: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Register VLAN ID 0 so that frames with VLAN ID 0 are received and get their tag stripped when ixgbe is not in DCB mode.  VLAN ID 0 means that the frame is 'priority tagged' only - it is not a VLAN, but the priority value is the tag in valid.  The functions ixgbe_vlan_rx_register() and
ixgbe_vlan_rx_kill_vid() were moved up a couple functions to correct compiling issues with this change.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   53 ++++++++++++++++++++--------------------
 1 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 92d9b17..bf36737 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1744,6 +1744,32 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 }
 
+static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	/* add VID to filter table */
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, true);
+}
+
+static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_disable(adapter);
+
+	vlan_group_set_device(adapter->vlgrp, vid, NULL);
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter);
+
+	/* remove VID from filter table */
+	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, false);
+}
+
 static void ixgbe_vlan_rx_register(struct net_device *netdev,
                                    struct vlan_group *grp)
 {
@@ -1763,6 +1789,7 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	ctrl |= IXGBE_VLNCTRL_VME;
 	ctrl &= ~IXGBE_VLNCTRL_CFIEN;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+	ixgbe_vlan_rx_add_vid(netdev, 0);
 
 	if (grp) {
 		/* enable VLAN tag insert/strip */
@@ -1776,32 +1803,6 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 		ixgbe_irq_enable(adapter);
 }
 
-static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	/* add VID to filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, true);
-}
-
-static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_disable(adapter);
-
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter);
-
-	/* remove VID from filter table */
-	hw->mac.ops.set_vfta(&adapter->hw, vid, 0, false);
-}
-
 static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 {
 	ixgbe_vlan_rx_register(adapter->netdev, adapter->vlgrp);

