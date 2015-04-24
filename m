From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 17/21] ARCNET: com20020: replace magic numbers with readable macros
Date: Fri, 24 Apr 2015 19:20:51 +0200
Message-ID: <1429896055-31680-18-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces all magic numbers in the driver with
proper named macros. For the case of XTOcfg and STARTIOcmd
it introduces the new macros.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c | 21 +++++++++++----------
 include/linux/arcdevice.h     |  1 +
 include/linux/com20020.h      |  1 +
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 4b4bb96..27ad484 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -92,9 +92,9 @@ int com20020_check(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 
 	/* reset the card */
-	outb(0x18 | 0x80, ioaddr + _CONFIG);
+	outb(XTOcfg(3) | RESETcfg, ioaddr + _CONFIG);
 	udelay(5);
-	outb(0x18, ioaddr + _CONFIG);
+	outb(XTOcfg(3), ioaddr + _CONFIG);
 	mdelay(RESETtime);
 
 	lp->setup = lp->clockm ? 0 : (lp->clockp << 1);
@@ -115,13 +115,13 @@ int com20020_check(struct net_device *dev)
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, ioaddr + _COMMAND);
+		outb(STARTIOcmd, ioaddr + _COMMAND);
 	}
 
-	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
+	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
 	outb(lp->config, ioaddr + _CONFIG);
-	outb(0x42, ioaddr + BUS_ALIGN*7);
+	outb(0x42, ioaddr + _XREG);
 
 	status = inb(ioaddr + _STATUS);
 
@@ -132,8 +132,9 @@ int com20020_check(struct net_device *dev)
 	BUGMSG(D_INIT_REASONS, "status after reset: %X\n", status);
 
 	/* Enable TX */
-	outb(0x39, ioaddr + _CONFIG);
-	outb(inb(ioaddr + BUS_ALIGN*8), ioaddr + BUS_ALIGN*7);
+	lp->config |= TXENcfg;
+	outb(lp->config, ioaddr + _CONFIG);
+	outb(inb(ioaddr + BUS_ALIGN * 8), ioaddr + _XREG);
 
 	outb((CFLAGScmd | RESETclear | CONFIGclear), ioaddr + _COMMAND);
 
@@ -212,10 +213,10 @@ int com20020_found(struct net_device *dev, int shared)
 
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
-		outb(0x18, ioaddr + _COMMAND);
+		outb(STARTIOcmd, ioaddr + _COMMAND);
 	}
 
-	lp->config = 0x20 | (lp->timeout << 3) | (lp->backplane << 2) | 1;
+	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* Default 0x38 + register: Node ID */
 	outb(lp->config, ioaddr + _CONFIG);
 	outb(dev->dev_addr[0], ioaddr + _XREG);
@@ -276,7 +277,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 
 	if (really_reset) {
 		/* reset the card */
-		outb(lp->config | 0x80, ioaddr + _CONFIG);
+		outb(lp->config | RESETcfg, ioaddr + _CONFIG);
 		udelay(5);
 		outb(lp->config, ioaddr + _CONFIG);
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index c20f100..bc3b085 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -155,6 +155,7 @@ extern int arcnet_debug;
 #define CONFIGcmd       0x05	/* define configuration */
 #define CFLAGScmd       0x06	/* clear flags */
 #define TESTcmd         0x07	/* load test flags */
+#define STARTIOcmd      0x18	/* start internal operation */
 
 /* flags for "clear flags" command */
 #define RESETclear      0x08	/* power-on-reset */
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index c2d8647..f194b74 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -92,6 +92,7 @@ struct com20020_dev {
 /* in the CONFIG register */
 #define RESETcfg	0x80	/* put card in reset state */
 #define TXENcfg		0x20	/* enable TX */
+#define XTOcfg(x)	((x) << 3)	/* extended timeout */
 
 /* in SETUP register */
 #define PROMISCset	0x10	/* enable RCV_ALL */
-- 
2.1.4
