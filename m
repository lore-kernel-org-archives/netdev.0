From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] e1000: fix vlan processing regression
Date: Tue, 27 Mar 2012 23:52:25 -0700
Message-ID: <1332917548-13102-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247Ab2C1Gwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 02:52:31 -0400
In-Reply-To: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>

This patch fixes a regression introduced by commit "e1000: do vlan
cleanup (799d531)".

Apparently some e1000 chips (not mine) are sensitive about the order of
setting vlan filter and vlan stripping/inserting functionality. So this
patch changes the order so it's the same as before vlan cleanup.

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Tested-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   35 +++++++++++++++---------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 0e9aec8..bcba9cf 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -164,6 +164,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
 static bool e1000_vlan_used(struct e1000_adapter *adapter);
 static void e1000_vlan_mode(struct net_device *netdev,
 			    netdev_features_t features);
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on);
 static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -1214,7 +1216,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	e1000_vlan_mode(netdev, netdev->features);
+	e1000_vlan_filter_on_off(adapter, false);
 
 	/* print bus type/speed/width info */
 	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
@@ -4770,6 +4772,22 @@ static bool e1000_vlan_used(struct e1000_adapter *adapter)
 	return false;
 }
 
+static void __e1000_vlan_mode(struct e1000_adapter *adapter,
+			      netdev_features_t features)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl;
+
+	ctrl = er32(CTRL);
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		ctrl |= E1000_CTRL_VME;
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl &= ~E1000_CTRL_VME;
+	}
+	ew32(CTRL, ctrl);
+}
 static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 				     bool filter_on)
 {
@@ -4779,6 +4797,7 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
+	__e1000_vlan_mode(adapter, adapter->netdev->features);
 	if (filter_on) {
 		/* enable VLAN receive filtering */
 		rctl = er32(RCTL);
@@ -4799,24 +4818,14 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 }
 
 static void e1000_vlan_mode(struct net_device *netdev,
-	netdev_features_t features)
+			    netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
-	ctrl = er32(CTRL);
-	if (features & NETIF_F_HW_VLAN_RX) {
-		/* enable VLAN tag insert/strip */
-		ctrl |= E1000_CTRL_VME;
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl &= ~E1000_CTRL_VME;
-	}
-	ew32(CTRL, ctrl);
+	__e1000_vlan_mode(adapter, features);
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
-- 
1.7.7.6
