From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2x: Add support for EXTPHY2 LED mode
Date: Sat, 28 Sep 2013 08:46:11 +0300
Message-ID: <1380347172-16670-6-git-send-email-yuvalmin@broadcom.com>
References: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4231 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503Ab3I1Fqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 01:46:44 -0400
In-Reply-To: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Add new LED mode for the BCM848xx to support new board type.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 32767f6..cf1df8b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -172,6 +172,7 @@ struct shared_hw_cfg {			 /* NVRAM Offset */
 		#define SHARED_HW_CFG_LED_MAC4                       0x000c0000
 		#define SHARED_HW_CFG_LED_PHY8                       0x000d0000
 		#define SHARED_HW_CFG_LED_EXTPHY1                    0x000e0000
+		#define SHARED_HW_CFG_LED_EXTPHY2                    0x000f0000
 
 
 	#define SHARED_HW_CFG_AN_ENABLE_MASK                0x3f000000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 92112e2..c60cf43 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6344,9 +6344,15 @@ int bnx2x_set_led(struct link_params *params,
 			 * intended override.
 			 */
 			break;
-		} else
+		} else {
+			u32 nig_led_mode = ((params->hw_led_mode <<
+					     SHARED_HW_CFG_LED_MODE_SHIFT) ==
+					    SHARED_HW_CFG_LED_EXTPHY2) ?
+				(SHARED_HW_CFG_LED_PHY1 >>
+				 SHARED_HW_CFG_LED_MODE_SHIFT) : hw_led_mode;
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
-			       hw_led_mode);
+			       nig_led_mode);
+		}
 
 		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
@@ -10608,10 +10614,18 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 0x40);
 
 		} else {
+			/* EXTPHY2 LED mode indicate that the 100M/1G/10G LED
+			 * sources are all wired through LED1, rather than only
+			 * 10G in other modes.
+			 */
+			val = ((params->hw_led_mode <<
+				SHARED_HW_CFG_LED_MODE_SHIFT) ==
+			       SHARED_HW_CFG_LED_EXTPHY2) ? 0x98 : 0x80;
+
 			bnx2x_cl45_write(bp, phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LED1_MASK,
-					 0x80);
+					 val);
 
 			/* Tell LED3 to blink on source */
 			bnx2x_cl45_read(bp, phy,
-- 
1.8.1.227.g44fe835
