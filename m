From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 10/10] gianfar: free/iounmap memory after an error in mii bus initialization
Date: Mon, 22 Sep 2008 14:10:25 -0700
Message-ID: <200809222110.m8MLAPWg029903@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	afleming@freescale.com, danielm77@spray.se
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49506 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYIVVPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>

Recent changes to MII bus initialization code added exit points which
didn't free or iounmap the bus before returning.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=11372.

Signed-off-by: Andy Fleming <afleming@freescale.com>
Reported-by: Daniel Marjamki <danielm77@spray.se>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/gianfar_mii.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff -puN drivers/net/gianfar_mii.c~gianfar-free-iounmap-memory-after-an-error-in-mii-bus-initialization drivers/net/gianfar_mii.c
--- a/drivers/net/gianfar_mii.c~gianfar-free-iounmap-memory-after-an-error-in-mii-bus-initialization
+++ a/drivers/net/gianfar_mii.c
@@ -211,19 +211,21 @@ static int gfar_mdio_probe(struct device
 	gfar_write(&enet_regs->tbipa, 0);
 	for (i = PHY_MAX_ADDR; i > 0; i--) {
 		u32 phy_id;
-		int r;
 
-		r = get_phy_id(new_bus, i, &phy_id);
-		if (r)
-			return r;
+		err = get_phy_id(new_bus, i, &phy_id);
+		if (err)
+			goto bus_register_fail;
 
 		if (phy_id == 0xffffffff)
 			break;
 	}
 
 	/* The bus is full.  We don't support using 31 PHYs, sorry */
-	if (i == 0)
-		return -EBUSY;
+	if (i == 0) {
+		err = -EBUSY;
+
+		goto bus_register_fail;
+	}
 
 	gfar_write(&enet_regs->tbipa, i);
 
_
