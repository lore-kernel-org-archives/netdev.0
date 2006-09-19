From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/23] e1000: Jumbo frames fixes for 82573
Date: Tue, 19 Sep 2006 10:28:57 -0700
Message-ID: <20060919172857.4605.51747.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:20493 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030347AbWISRUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:02 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Disable jumbo frames for 82573L alltogether and when ASPM is enabled
since the hardware has problems with it. For the NICs that do support
this in the 82573 series we set ERT_2048 to attempt to receive as much
traffic as early as we can.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e81aa03..2ecec51 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3138,11 +3138,13 @@ e1000_change_mtu(struct net_device *netd
 		}
 		break;
 	case e1000_82573:
-		/* only enable jumbo frames if ASPM is disabled completely
-		 * this means both bits must be zero in 0x1A bits 3:2 */
+		/* Jumbo Frames not supported if:
+		 * - this is not an 82573L device
+		 * - ASPM is enabled in any way (0x1A bits 3:2) */
 		e1000_read_eeprom(&adapter->hw, EEPROM_INIT_3GIO_3, 1,
 		                  &eeprom_data);
-		if (eeprom_data & EEPROM_WORD1A_ASPM_MASK) {
+		if ((adapter->hw.device_id != E1000_DEV_ID_82573L) ||
+		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
 			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
 				DPRINTK(PROBE, ERR,
 			            	"Jumbo Frames not supported.\n");
@@ -3150,6 +3152,8 @@ e1000_change_mtu(struct net_device *netd
 			}
 			break;
 		}
+		/* ERT will be enabled later to enable wire speed receives */
+
 		/* fall through to get support */
 	case e1000_82571:
 	case e1000_82572:



---
Auke Kok <auke-jan.h.kok@intel.com>
