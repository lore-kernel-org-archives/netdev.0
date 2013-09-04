From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  6/9] igb: Support to get 2_5G link status for appropriate media type
Date: Wed,  4 Sep 2013 06:08:53 -0700
Message-ID: <1378300136-26003-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56125 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932450Ab3IDNJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:09:02 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Since i354 2.5Gb devices are not Copper media type but SerDes, so this
patch changes the way we detect speed/duplex link info for this device.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 25 ++++++++++++++++++-------
 drivers/net/ethernet/intel/igb/e1000_mac.c   | 11 -----------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index d796e29..68dd7c8 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1217,7 +1217,7 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 						u16 *duplex)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	u32 pcs;
+	u32 pcs, status;
 
 	/* Set up defaults for the return values of this function */
 	mac->serdes_has_link = false;
@@ -1238,20 +1238,31 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 		mac->serdes_has_link = true;
 
 		/* Detect and store PCS speed */
-		if (pcs & E1000_PCS_LSTS_SPEED_1000) {
+		if (pcs & E1000_PCS_LSTS_SPEED_1000)
 			*speed = SPEED_1000;
-		} else if (pcs & E1000_PCS_LSTS_SPEED_100) {
+		else if (pcs & E1000_PCS_LSTS_SPEED_100)
 			*speed = SPEED_100;
-		} else {
+		else
 			*speed = SPEED_10;
-		}
 
 		/* Detect and store PCS duplex */
-		if (pcs & E1000_PCS_LSTS_DUPLEX_FULL) {
+		if (pcs & E1000_PCS_LSTS_DUPLEX_FULL)
 			*duplex = FULL_DUPLEX;
-		} else {
+		else
 			*duplex = HALF_DUPLEX;
+
+	/* Check if it is an I354 2.5Gb backplane connection. */
+		if (mac->type == e1000_i354) {
+			status = rd32(E1000_STATUS);
+			if ((status & E1000_STATUS_2P5_SKU) &&
+			    !(status & E1000_STATUS_2P5_SKU_OVER)) {
+				*speed = SPEED_2500;
+				*duplex = FULL_DUPLEX;
+				hw_dbg("2500 Mbs, ");
+				hw_dbg("Full Duplex\n");
+			}
 		}
+
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index bab556a..f0dfd41 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1171,17 +1171,6 @@ s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
 		hw_dbg("Half Duplex\n");
 	}
 
-	/* Check if it is an I354 2.5Gb backplane connection. */
-	if (hw->mac.type == e1000_i354) {
-		if ((status & E1000_STATUS_2P5_SKU) &&
-		    !(status & E1000_STATUS_2P5_SKU_OVER)) {
-			*speed = SPEED_2500;
-			*duplex = FULL_DUPLEX;
-			hw_dbg("2500 Mbs, ");
-			hw_dbg("Full Duplex\n");
-		}
-	}
-
 	return 0;
 }
 
-- 
1.8.3.1
