From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: fix link behavior for SFP+ when driver is
	brought down
Date: Fri, 03 Dec 2010 05:31:51 -0800
Message-ID: <20101203133151.21637.52883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:52916
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754880Ab0LCNiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:38:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We have had several requests to have ifconfig down command disable
the SFP+ laser and thus make link go down.  Likewise on ifconfig up
the laser would be enabled and link would come up.  This patch enables
that behavior.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   12 +++++++++---
 drivers/net/ixgbe/ixgbe_main.c  |   26 ++++++++++++++++++--------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 26b8ceb..743bdec 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -65,9 +65,9 @@ static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
 static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
-	if (hw->phy.multispeed_fiber) {
-		/* Set up dual speed SFP+ support */
-		mac->ops.setup_link = &ixgbe_setup_mac_link_multispeed_fiber;
+
+	/* enable the laser control functions for SFP+ fiber */
+	if (mac->ops.get_media_type(hw) == ixgbe_media_type_fiber) {
 		mac->ops.disable_tx_laser =
 		                       &ixgbe_disable_tx_laser_multispeed_fiber;
 		mac->ops.enable_tx_laser =
@@ -77,6 +77,12 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 		mac->ops.disable_tx_laser = NULL;
 		mac->ops.enable_tx_laser = NULL;
 		mac->ops.flap_tx_laser = NULL;
+	}
+
+	if (hw->phy.multispeed_fiber) {
+		/* Set up dual speed SFP+ support */
+		mac->ops.setup_link = &ixgbe_setup_mac_link_multispeed_fiber;
+	} else {
 		if ((mac->ops.get_media_type(hw) ==
 		     ixgbe_media_type_backplane) &&
 		    (hw->phy.smart_speed == ixgbe_smart_speed_auto ||
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bd64a4d..fb81418 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3793,8 +3793,11 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	else
 		ixgbe_configure_msi_and_legacy(adapter);
 
-	/* enable the optics */
-	if (hw->phy.multispeed_fiber && hw->mac.ops.enable_tx_laser)
+	/* enable the optics for both mult-speed fiber and 82599 SFP+ fiber */
+	if (hw->mac.ops.enable_tx_laser &&
+	    ((hw->phy.multispeed_fiber) ||
+	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.enable_tx_laser(hw);
 
 	clear_bit(__IXGBE_DOWN, &adapter->state);
@@ -4106,15 +4109,19 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	/* power down the optics */
-	if (hw->phy.multispeed_fiber && hw->mac.ops.disable_tx_laser)
-		hw->mac.ops.disable_tx_laser(hw);
-
 	/* clear n-tuple filters that are cached */
 	ethtool_ntuple_flush(netdev);
 
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
+
+	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
+	if (hw->mac.ops.disable_tx_laser &&
+	    ((hw->phy.multispeed_fiber) ||
+	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	      (hw->mac.type == ixgbe_mac_82599EB))))
+		hw->mac.ops.disable_tx_laser(hw);
+
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
@@ -7200,8 +7207,11 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	/* power down the optics */
-	if (hw->phy.multispeed_fiber && hw->mac.ops.disable_tx_laser)
+	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
+	if (hw->mac.ops.disable_tx_laser &&
+	    ((hw->phy.multispeed_fiber) ||
+	     ((hw->phy.type == ixgbe_media_type_fiber) &&
+	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.disable_tx_laser(hw);
 
 	init_timer(&adapter->watchdog_timer);

