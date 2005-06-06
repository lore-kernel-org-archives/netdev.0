From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] tg3: Fix link failure in 5701
Date: Mon, 06 Jun 2005 12:42:22 -0700
Message-ID: <1118086942.5008.14.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: iod00d@hp.com, peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On some 5701 devices with older bootcode, the LED configuration bits in
SRAM may be invalid with value zero. The fix is to check for invalid
bits (0) and default to PHY 1 mode. Incorrect LED mode will lead to
error in programming the PHY.

Thanks to Grant Grundler for debugging the problem.

>From Grant:
| In May, 2004,  tg3 v3.4 changed how MAC_LED_CTRL (0x40c) was getting
| programmed and how to determine what to program into LED_CTRL. The new
| code trusted NIC_SRAM_DATA_CFG (0x00000b58) to indicate what to write
| to LED_CTRL and MII EXT_CTRL registers. On "IOX Core Lan", SRAM was
| saying MODE_MAC (0x0) and that doesn't work.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff -Nru led1/drivers/net/tg3.c led2/drivers/net/tg3.c
--- led1/drivers/net/tg3.c	2005-06-06 10:19:56.692541944 -0700
+++ led2/drivers/net/tg3.c	2005-06-06 10:34:49.251852304 -0700
@@ -8555,6 +8555,16 @@
 
 		case NIC_SRAM_DATA_CFG_LED_MODE_MAC:
 			tp->led_ctrl = LED_CTRL_MODE_MAC;
+
+			/* Default to PHY_1_MODE if 0 (MAC_MODE) is
+			 * read on some older 5700/5701 bootcode.
+			 */
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
+			    ASIC_REV_5700 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) ==
+			    ASIC_REV_5701)
+				tp->led_ctrl = LED_CTRL_MODE_PHY_1;
+
 			break;
 
 		case SHASTA_EXT_LED_SHARED:
