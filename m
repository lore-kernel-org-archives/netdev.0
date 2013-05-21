From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] igb: Changed LEDs blink mechanism to include designs using cathode
Date: Tue, 21 May 2013 15:03:12 -0700
Message-ID: <1369173800-20326-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46592 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944Ab3EUWD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:27 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch addresses the changes needed to make LEDs work properly with
negative logic. This implementation uses LED Invert bit to reverse the
logic issue that occurred when LEDs are driven by cathode. Keep LEDs
blinking for SerDes devices. Also made changes to magic number and the
for loop to reduce number of shifts.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |  6 +++--
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 37 +++++++++++++++++++-------
 2 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 31a0f82..aa17649 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -270,8 +270,10 @@
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
 
 /* LED Control */
-#define E1000_LEDCTL_LED0_MODE_SHIFT      0
-#define E1000_LEDCTL_LED0_BLINK           0x00000080
+#define E1000_LEDCTL_LED0_MODE_SHIFT	0
+#define E1000_LEDCTL_LED0_BLINK		0x00000080
+#define E1000_LEDCTL_LED0_MODE_MASK	0x0000000F
+#define E1000_LEDCTL_LED0_IVRT		0x00000040
 
 #define E1000_LEDCTL_MODE_LED_ON        0xE
 #define E1000_LEDCTL_MODE_LED_OFF       0xF
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 2559d70..660b7ad 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1406,15 +1406,34 @@ s32 igb_blink_led(struct e1000_hw *hw)
 	u32 ledctl_blink = 0;
 	u32 i;
 
-	/* set the blink bit for each LED that's "on" (0x0E)
-	 * in ledctl_mode2
-	 */
-	ledctl_blink = hw->mac.ledctl_mode2;
-	for (i = 0; i < 4; i++)
-		if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
-		    E1000_LEDCTL_MODE_LED_ON)
-			ledctl_blink |= (E1000_LEDCTL_LED0_BLINK <<
-					 (i * 8));
+	if (hw->phy.media_type == e1000_media_type_fiber) {
+		/* always blink LED0 for PCI-E fiber */
+		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
+		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
+	} else {
+		/* Set the blink bit for each LED that's "on" (0x0E)
+		 * (or "off" if inverted) in ledctl_mode2.  The blink
+		 * logic in hardware only works when mode is set to "on"
+		 * so it must be changed accordingly when the mode is
+		 * "off" and inverted.
+		 */
+		ledctl_blink = hw->mac.ledctl_mode2;
+		for (i = 0; i < 32; i += 8) {
+			u32 mode = (hw->mac.ledctl_mode2 >> i) &
+			    E1000_LEDCTL_LED0_MODE_MASK;
+			u32 led_default = hw->mac.ledctl_default >> i;
+
+			if ((!(led_default & E1000_LEDCTL_LED0_IVRT) &&
+			     (mode == E1000_LEDCTL_MODE_LED_ON)) ||
+			    ((led_default & E1000_LEDCTL_LED0_IVRT) &&
+			     (mode == E1000_LEDCTL_MODE_LED_OFF))) {
+				ledctl_blink &=
+				    ~(E1000_LEDCTL_LED0_MODE_MASK << i);
+				ledctl_blink |= (E1000_LEDCTL_LED0_BLINK |
+						 E1000_LEDCTL_MODE_LED_ON) << i;
+			}
+		}
+	}
 
 	wr32(E1000_LEDCTL, ledctl_blink);
 
-- 
1.7.11.7
