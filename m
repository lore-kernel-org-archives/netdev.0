From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 07/21] ARCNET: rimi: remove unneeded macros
Date: Fri, 24 Apr 2015 19:20:41 +0200
Message-ID: <1429896055-31680-8-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44293 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031545AbbDXRWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:24 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The simple macros ARCRESET, ACOMMAND, ASTATUS, AINTMASK are unnecessary
indirections to the use of registers. This patch removes them and improves the
readability of the code.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 4c95d3c..c920b86 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -69,16 +69,6 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define _ADDR_LO  (ioaddr+14)
 #define _CONFIG  (ioaddr+2)	/* Configuration register */
 
-#undef ASTATUS
-#undef ACOMMAND
-#undef AINTMASK
-
-#define ASTATUS()	readb(_STATUS)
-#define ACOMMAND(cmd)	writeb((cmd),_COMMAND)
-#define AINTMASK(msk)	writeb((msk),_INTMASK)
-#define SETCONF()	writeb(lp->config,_CONFIG)
-
-
 /*
  * We cannot probe for a RIM I card; one reason is I don't know how to reset
  * them.  In fact, we can't even get their node ID automatically.  So, we
@@ -263,17 +253,17 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
+	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, readb(_STATUS));
 
 	if (really_reset) {
 		writeb(TESTvalue, ioaddr - 0x800);	/* fake reset */
 		return 0;
 	}
-	ACOMMAND(CFLAGScmd | RESETclear);	/* clear flags & end reset */
-	ACOMMAND(CFLAGScmd | CONFIGclear);
+	writeb(CFLAGScmd | RESETclear, _COMMAND);	/* clear flags & end reset */
+	writeb(CFLAGScmd | CONFIGclear, _COMMAND);
 
 	/* enable extended (512-byte) packets */
-	ACOMMAND(CONFIGcmd | EXTconf);
+	writeb(CONFIGcmd | EXTconf, _COMMAND);
 
 	/* done!  return success. */
 	return 0;
@@ -284,7 +274,7 @@ static void arcrimi_setmask(struct net_device *dev, int mask)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	AINTMASK(mask);
+	writeb(mask, _INTMASK);
 }
 
 static int arcrimi_status(struct net_device *dev)
@@ -292,7 +282,7 @@ static int arcrimi_status(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	return ASTATUS();
+	return readb(_STATUS);
 }
 
 static void arcrimi_command(struct net_device *dev, int cmd)
@@ -300,7 +290,7 @@ static void arcrimi_command(struct net_device *dev, int cmd)
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
-	ACOMMAND(cmd);
+	writeb(cmd, _COMMAND);
 }
 
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
-- 
2.1.4
