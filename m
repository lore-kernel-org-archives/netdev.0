From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 02/10] bnx2x: Fix chip hanging due to TX pipe stall.
Date: Wed, 3 Aug 2011 11:59:18 +0300
Message-ID: <1312361958.21665.92.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1083 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1HCI71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 04:59:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem in which the 578xx chip hangs after running traffic, and then pulling the network cable.
This occurs since TX pipe is stalled due to missing XON indication towards the NIG.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index aa9958e..0a7091d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1667,10 +1667,20 @@ static void bnx2x_xmac_disable(struct link_params *params)
 {
 	u8 port = params->port;
 	struct bnx2x *bp = params->bp;
-	u32 xmac_base = (port) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
+	u32 pfc_ctrl, xmac_base = (port) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
 
 	if (REG_RD(bp, MISC_REG_RESET_REG_2) &
 	    MISC_REGISTERS_RESET_REG_2_XMAC) {
+		/*
+		 * Send an indication to change the state in the NIG back to XON
+		 * Clearing this bit enables the next set of this bit to get
+		 * rising edge
+		 */
+		pfc_ctrl = REG_RD(bp, xmac_base + XMAC_REG_PFC_CTRL_HI);
+		REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL_HI,
+		       (pfc_ctrl & ~(1<<1)));
+		REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL_HI,
+		       (pfc_ctrl | (1<<1)));
 		DP(NETIF_MSG_LINK, "Disable XMAC on port %x\n", port);
 		REG_WR(bp, xmac_base + XMAC_REG_CTRL, 0);
 		usleep_range(1000, 1000);
-- 
1.7.1










