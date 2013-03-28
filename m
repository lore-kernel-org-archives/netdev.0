From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] e1000e: fix LED blink logic for designs with LEDs driven by cathode
Date: Thu, 28 Mar 2013 02:00:06 -0700
Message-ID: <1364461215-7793-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20438 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411Ab3C1JAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:22 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When the LEDs are driven by cathode, the bit logic is reversed.  Use the
LED Invert bit to invert the logic.  Cleanup use of a magic number and
change the for loop increment to reduce the number of shifts.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index b25cc43..2480c10 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1600,15 +1600,28 @@ s32 e1000e_blink_led_generic(struct e1000_hw *hw)
 		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
 		    (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
 	} else {
-		/* set the blink bit for each LED that's "on" (0x0E)
-		 * in ledctl_mode2
+		/* Set the blink bit for each LED that's "on" (0x0E)
+		 * (or "off" if inverted) in ledctl_mode2.  The blink
+		 * logic in hardware only works when mode is set to "on"
+		 * so it must be changed accordingly when the mode is
+		 * "off" and inverted.
 		 */
 		ledctl_blink = hw->mac.ledctl_mode2;
-		for (i = 0; i < 4; i++)
-			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
-			    E1000_LEDCTL_MODE_LED_ON)
-				ledctl_blink |= (E1000_LEDCTL_LED0_BLINK <<
-						 (i * 8));
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
 	}
 
 	ew32(LEDCTL, ledctl_blink);
-- 
1.7.11.7
