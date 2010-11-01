From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 3/8] bnx2x: Fix port selection in case of E2
Date: Mon, 1 Nov 2010 17:32:31 +0200
Message-ID: <1288625551.3533.15.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab0KAMO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On E2 flavor, dual-port mode, the port argument used for some functions is needed as the global port number rather than the port per path.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index b6588c5..fc637ce 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -5442,7 +5442,7 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port, initialize = 1;
+	u8 port, initialize = 1;
 	u16 val;
 	u16 temp;
 	u32 actual_phy_selection;
@@ -5451,6 +5451,10 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	/* This is just for MDIO_CTL_REG_84823_MEDIA register. */
 
 	msleep(1);
+	if (CHIP_IS_E2(bp))
+		port = BP_PATH(bp);
+	else
+		port = params->port;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 		       port);
@@ -5627,7 +5631,11 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 				   struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
+	u8 port;
+	if (CHIP_IS_E2(bp))
+		port = BP_PATH(bp);
+	else
+		port = params->port;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
 			    port);
@@ -7023,7 +7031,8 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 			return -EINVAL;
 		}
 		/* disable attentions */
-		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
+		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
+			       port_of_path*4,
 			     (NIG_MASK_XGXS0_LINK_STATUS |
 			      NIG_MASK_XGXS0_LINK10G |
 			      NIG_MASK_SERDES0_LINK_STATUS |
-- 
1.7.1




