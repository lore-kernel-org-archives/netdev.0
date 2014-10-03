From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net 6/8] gianfar: Make MAC addr setup endian safe, cleanup
Date: Fri, 3 Oct 2014 19:02:47 +0300
Message-ID: <1412352169-14414-7-git-send-email-claudiu.manoil@freescale.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0105.outbound.protection.outlook.com ([65.55.169.105]:54656
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752725AbaJCQlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:41:18 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the 32-bit memory access that is not endian safe,
i.e. not giving the desired byte layout for a LE CPU:
tempval = *((u32 *) (tmpbuf + 4)), where 'char tmpbuf[]'.

Get rid of rendundant local vars (tmpbuf[] and idx) and
forced casts.  Cleanup comments.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 37e0604..961198a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3248,22 +3248,21 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	int idx;
-	char tmpbuf[ETH_ALEN];
 	u32 tempval;
 	u32 __iomem *macptr = &regs->macstnaddr1;
 
 	macptr += num*2;
 
-	/* Now copy it into the mac registers backwards, cuz
-	 * little endian is silly
+	/* For a station address of 0x12345678ABCD in transmission
+	 * order (BE), MACnADDR1 is set to 0xCDAB7856 and
+	 * MACnADDR2 is set to 0x34120000.
 	 */
-	for (idx = 0; idx < ETH_ALEN; idx++)
-		tmpbuf[ETH_ALEN - 1 - idx] = addr[idx];
+	tempval = (addr[5] << 24) | (addr[4] << 16) |
+		  (addr[3] << 8)  |  addr[2];
 
-	gfar_write(macptr, *((u32 *) (tmpbuf)));
+	gfar_write(macptr, tempval);
 
-	tempval = *((u32 *) (tmpbuf + 4));
+	tempval = (addr[1] << 24) | (addr[0] << 16);
 
 	gfar_write(macptr+1, tempval);
 }
-- 
1.7.11.7
