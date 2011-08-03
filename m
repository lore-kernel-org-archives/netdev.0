From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 05/10] bnx2x: Fix LED behavior
Date: Wed, 3 Aug 2011 11:59:40 +0300
Message-ID: <1312361980.21665.95.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1083 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105Ab1HCI7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 04:59:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix resolve two problems seen regarding LED:
1. LED doesn't flash during port identification.
2. Traffic LED sometimes do not blink.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 45255bd..d8f6eff 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -5922,20 +5922,30 @@ int bnx2x_set_led(struct link_params *params,
 				tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
 				EMAC_WR(bp, EMAC_REG_EMAC_LED,
 					(tmp | EMAC_LED_OVERRIDE));
-				return rc;
+				/*
+				 * return here without enabling traffic
+				 * LED blink andsetting rate in ON mode.
+				 * In oper mode, enabling LED blink
+				 * and setting rate is needed.
+				 */
+				if (mode == LED_MODE_ON)
+					return rc;
 			}
-		} else if (SINGLE_MEDIA_DIRECT(params) &&
-			   (CHIP_IS_E1x(bp) ||
-			    CHIP_IS_E2(bp))) {
+		} else if (SINGLE_MEDIA_DIRECT(params)) {
 			/*
 			 * This is a work-around for HW issue found when link
 			 * is up in CL73
 			 */
-			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
-		} else {
+			if (CHIP_IS_E1x(bp) ||
+			    CHIP_IS_E2(bp) ||
+			    (mode == LED_MODE_ON))
+				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
+			else
+				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
+				       hw_led_mode);
+		} else
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, hw_led_mode);
-		}
 
 		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
-- 
1.7.1








