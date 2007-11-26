From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/6] skge: retry on MAC shutdown
Date: Mon, 26 Nov 2007 11:54:50 -0800
Message-ID: <20071126195557.657291575@linux-foundation.org>
References: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44440 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754219AbXKZUEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 15:04:36 -0500
Content-Disposition: inline; filename=skge-stopping-retry.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure and retry when shutting down the MAC. This code is copied
from sk98lin driver.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/skge.c	2007-11-21 14:40:58.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-21 14:44:02.000000000 -0800
@@ -1713,7 +1713,7 @@ static void genesis_stop(struct skge_por
 {
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u32 reg;
+	unsigned retries = 1000;
 
 	genesis_reset(hw, port);
 
@@ -1721,20 +1721,17 @@ static void genesis_stop(struct skge_por
 	skge_write16(hw, B3_PA_CTRL,
 		     port == 0 ? PA_CLR_TO_TX1 : PA_CLR_TO_TX2);
 
-	/*
-	 * If the transfer sticks at the MAC the STOP command will not
-	 * terminate if we don't flush the XMAC's transmit FIFO !
-	 */
-	xm_write32(hw, port, XM_MODE,
-			xm_read32(hw, port, XM_MODE)|XM_MD_FTF);
-
-
 	/* Reset the MAC */
-	skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_SET_MAC_RST);
+	skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_CLR_MAC_RST);
+	do {
+		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1), MFF_SET_MAC_RST);
+		if (!(skge_read16(hw, SK_REG(port, TX_MFF_CTRL1)) & MFF_SET_MAC_RST))
+			break;
+	} while (--retries > 0);
 
 	/* For external PHYs there must be special handling */
 	if (hw->phy_type != SK_PHY_XMAC) {
-		reg = skge_read32(hw, B2_GP_IO);
+		u32 reg = skge_read32(hw, B2_GP_IO);
 		if (port == 0) {
 			reg |= GP_DIR_0;
 			reg &= ~GP_IO_0;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

