From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 19/21] ARCNET: com20020: add enable and disable device on open/close
Date: Fri, 24 Apr 2015 19:20:53 +0200
Message-ID: <1429896055-31680-20-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44283 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031542AbbDXRWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:24 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to properly work with the linux netif
interface. The controller gets enabled on open and disabled on close.
Therefor it removes every bogus start of the xceiver. It only gets
enabled on com20020_open and disabled on com20020_close.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 1dbc748..713eb5d 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -118,7 +118,7 @@ int com20020_check(struct net_device *dev)
 		outb(STARTIOcmd, ioaddr + _COMMAND);
 	}
 
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
+	lp->config = (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
 	outb(lp->config, ioaddr + _CONFIG);
 	outb(0x42, ioaddr + _XREG);
@@ -131,11 +131,6 @@ int com20020_check(struct net_device *dev)
 	}
 	BUGMSG(D_INIT_REASONS, "status after reset: %X\n", status);
 
-	/* Enable TX */
-	lp->config |= TXENcfg;
-	outb(lp->config, ioaddr + _CONFIG);
-	outb(inb(ioaddr + 8), ioaddr + _XREG);
-
 	outb((CFLAGScmd | RESETclear | CONFIGclear), ioaddr + _COMMAND);
 
 	status = inb(ioaddr + _STATUS);
@@ -169,9 +164,33 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 	return 0;
 }
 
+int com20020_netdev_open(struct net_device *dev)
+{
+	int ioaddr = dev->base_addr;
+	struct arcnet_local *lp = netdev_priv(dev);
+
+	lp->config |= TXENcfg;
+	outb(lp->config, ioaddr + _CONFIG);
+
+	return arcnet_open(dev);
+}
+
+int com20020_netdev_close(struct net_device *dev)
+{
+	int ioaddr = dev->base_addr;
+	struct arcnet_local *lp = netdev_priv(dev);
+
+	arcnet_close(dev);
+
+	/* disable transmitter */
+	lp->config &= ~TXENcfg;
+	outb(lp->config, ioaddr + _CONFIG);
+	return 0;
+}
+
 const struct net_device_ops com20020_netdev_ops = {
-	.ndo_open	= arcnet_open,
-	.ndo_stop	= arcnet_close,
+	.ndo_open	= com20020_netdev_open,
+	.ndo_stop	= com20020_netdev_close,
 	.ndo_start_xmit = arcnet_send_packet,
 	.ndo_tx_timeout = arcnet_timeout,
 	.ndo_set_mac_address = com20020_set_hwaddr,
@@ -216,8 +235,8 @@ int com20020_found(struct net_device *dev, int shared)
 		outb(STARTIOcmd, ioaddr + _COMMAND);
 	}
 
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
-	/* Default 0x38 + register: Node ID */
+	lp->config = (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
+	/* Default 0x18 + register: Node ID */
 	outb(lp->config, ioaddr + _CONFIG);
 	outb(dev->dev_addr[0], ioaddr + _XREG);
 
@@ -270,7 +289,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	       dev->name, inb(ioaddr + _STATUS));
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
+	lp->config |= (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	outb(lp->config, ioaddr + _CONFIG);
 	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-- 
2.1.4
