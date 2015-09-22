From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 31/33] arcnet: com20020: replace magic numbers with readable macros
Date: Tue, 22 Sep 2015 11:02:12 +0200
Message-ID: <1442912534-10821-32-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48755 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces all magic numbers in the driver with
proper named macros. For the case of XTOcfg and STARTIOcmd
it introduces the new macros.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h |  1 +
 drivers/net/arcnet/com20020.c  | 17 +++++++++--------
 drivers/net/arcnet/com20020.h  |  1 +
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 4c1c44c..d7fdea1 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -164,6 +164,7 @@ do {									\
 #define CONFIGcmd       0x05	/* define configuration */
 #define CFLAGScmd       0x06	/* clear flags */
 #define TESTcmd         0x07	/* load test flags */
+#define STARTIOcmd      0x18	/* start internal operation */
 
 /* flags for "clear flags" command */
 #define RESETclear      0x08	/* power-on-reset */
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index d416275..c82f323 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -94,9 +94,9 @@ int com20020_check(struct net_device *dev)
 	int ioaddr = dev->base_addr, status;
 	struct arcnet_local *lp = netdev_priv(dev);
 
-	arcnet_outb(0x18 | 0x80, ioaddr, COM20020_REG_W_CONFIG);
+	arcnet_outb(XTOcfg(3) | RESETcfg, ioaddr, COM20020_REG_W_CONFIG);
 	udelay(5);
-	arcnet_outb(0x18 , ioaddr, COM20020_REG_W_CONFIG);
+	arcnet_outb(XTOcfg(3), ioaddr, COM20020_REG_W_CONFIG);
 	mdelay(RESETtime);
 
 	lp->setup = lp->clockm ? 0 : (lp->clockp << 1);
@@ -115,10 +115,10 @@ int com20020_check(struct net_device *dev)
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		arcnet_outb(0x18, ioaddr, COM20020_REG_W_COMMAND);
+		arcnet_outb(STARTIOcmd, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
-	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
+	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
 	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arcnet_outb(0x42, ioaddr, COM20020_REG_W_XREG);
@@ -132,7 +132,8 @@ int com20020_check(struct net_device *dev)
 	arc_printk(D_INIT_REASONS, dev, "status after reset: %X\n", status);
 
 	/* Enable TX */
-	arcnet_outb(0x39, ioaddr, COM20020_REG_W_CONFIG);
+	lp->config |= TXENcfg;
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arcnet_outb(arcnet_inb(ioaddr, 8), ioaddr, COM20020_REG_W_XREG);
 
 	arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
@@ -211,10 +212,10 @@ int com20020_found(struct net_device *dev, int shared)
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		arcnet_outb(0x18, ioaddr, COM20020_REG_W_COMMAND);
+		arcnet_outb(STARTIOcmd, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
-	lp->config = 0x20 | (lp->timeout << 3) | (lp->backplane << 2) | 1;
+	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* Default 0x38 + register: Node ID */
 	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arcnet_outb(dev->dev_addr[0], ioaddr, COM20020_REG_W_XREG);
@@ -280,7 +281,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 
 	if (really_reset) {
 		/* reset the card */
-		arcnet_outb(lp->config | 0x80, ioaddr, COM20020_REG_W_CONFIG);
+		arcnet_outb(lp->config | RESETcfg, ioaddr, COM20020_REG_W_CONFIG);
 		udelay(5);
 		arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 		mdelay(RESETtime * 2);
diff --git a/drivers/net/arcnet/com20020.h b/drivers/net/arcnet/com20020.h
index ffb1946..22a460f 100644
--- a/drivers/net/arcnet/com20020.h
+++ b/drivers/net/arcnet/com20020.h
@@ -86,6 +86,7 @@ struct com20020_dev {
 /* in the CONFIG register */
 #define RESETcfg	0x80	/* put card in reset state */
 #define TXENcfg		0x20	/* enable TX */
+#define XTOcfg(x)	((x) << 3)	/* extended timeout */
 
 /* in SETUP register */
 #define PROMISCset	0x10	/* enable RCV_ALL */
-- 
2.5.1
