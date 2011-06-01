From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 05/11] bnx2x: Fix over current port display
Date: Wed, 1 Jun 2011 10:27:48 +0300
Message-ID: <1306913268.20872.112.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4820 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab1FAH1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 03:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 57712 chip, port number is enumerated per engine, so it requires adjustment in port display to the user.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 87c5d9f..ffc3c16 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4919,15 +4919,14 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 	 */
 	if (phy->flags & FLAGS_NOC)
 		return;
-	if (!(phy->flags &
-	      FLAGS_NOC) && is_power_up)
+	if (is_power_up)
 		val = (1<<4);
 	else
 		/*
 		 * Set GPIO control to OUTPUT, and set the power bit
 		 * to according to the is_power_up
 		 */
-		val = ((!(is_power_up)) << 1);
+		val = (1<<1);
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
@@ -5928,7 +5927,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 
 {
 	struct bnx2x *bp = params->bp;
-	u8 link_up = 0;
+	u8 link_up = 0, oc_port = params->port;
 	u16 link_status = 0;
 	u16 rx_alarm_status, lasi_ctrl, val1;
 
@@ -5969,8 +5968,10 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 				&val1);
 
 		if ((val1 & (1<<8)) == 0) {
+			if (!CHIP_IS_E1x(bp))
+				oc_port = BP_PATH(bp) + (params->port << 1);
 			DP(NETIF_MSG_LINK, "8727 Power fault has been detected"
-				       " on port %d\n", params->port);
+				       " on port %d\n", oc_port);
 			netdev_err(bp->dev, "Error:  Power fault on Port %d has"
 					    " been detected and the power to "
 					    "that SFP+ module has been removed"
@@ -5978,7 +5979,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 					    " Please remove the SFP+ module and"
 					    " restart the system to clear this"
 					    " error.\n",
-			 params->port);
+			 oc_port);
 			/* Disable all RX_ALARMs except for mod_abs */
 			bnx2x_cl45_write(bp, phy,
 					 MDIO_PMA_DEVAD,
-- 
1.7.1






