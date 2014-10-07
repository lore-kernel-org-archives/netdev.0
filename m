From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 6/8] gianfar: Make MAC addr setup endian safe, cleanup
Date: Tue, 7 Oct 2014 10:44:33 +0300
Message-ID: <1412667875-18225-7-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.169.135] ([65.55.169.135]:54432 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752784AbaJGHrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:16 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the 32-bit memory access that is not endian safe,
i.e. not giving the desired byte layout for a LE CPU:
tempval = *((u32 *) (tmpbuf + 4)), where 'char tmpbuf[]'.

Get rid of rendundant local vars (tmpbuf[] and idx) and
forced casts.  Cleanup comments.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - none

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
