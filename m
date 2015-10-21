From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH net-next 2/6] arcnet: com20020: add enable and disable device on open/close
Date: Wed, 21 Oct 2015 17:45:28 +0200
Message-ID: <1445442332-10625-3-git-send-email-m.grzeschik@pengutronix.de>
References: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56969 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbJUPpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:45:45 -0400
In-Reply-To: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to properly work with the linux netif
interface. The controller gets enabled on open and disabled on close.
Therefor it removes every bogus start of the xceiver. It only gets
enabled on com20020_open and disabled on com20020_close.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index c82f323..436951b 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -118,7 +118,7 @@ int com20020_check(struct net_device *dev)
 		arcnet_outb(STARTIOcmd, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
+	lp->config = (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
 	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arcnet_outb(0x42, ioaddr, COM20020_REG_W_XREG);
@@ -131,11 +131,6 @@ int com20020_check(struct net_device *dev)
 	}
 	arc_printk(D_INIT_REASONS, dev, "status after reset: %X\n", status);
 
-	/* Enable TX */
-	lp->config |= TXENcfg;
-	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
-	arcnet_outb(arcnet_inb(ioaddr, 8), ioaddr, COM20020_REG_W_XREG);
-
 	arcnet_outb(CFLAGScmd | RESETclear | CONFIGclear,
 		    ioaddr, COM20020_REG_W_COMMAND);
 	status = arcnet_inb(ioaddr, COM20020_REG_R_STATUS);
@@ -169,9 +164,33 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 	return 0;
 }
 
+int com20020_netdev_open(struct net_device *dev)
+{
+	int ioaddr = dev->base_addr;
+	struct arcnet_local *lp = netdev_priv(dev);
+
+	lp->config |= TXENcfg;
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
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
+	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
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
@@ -215,7 +234,7 @@ int com20020_found(struct net_device *dev, int shared)
 		arcnet_outb(STARTIOcmd, ioaddr, COM20020_REG_W_COMMAND);
 	}
 
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
+	lp->config = (lp->timeout << 3) | (lp->backplane << 2) | SUB_NODE;
 	/* Default 0x38 + register: Node ID */
 	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arcnet_outb(dev->dev_addr[0], ioaddr, COM20020_REG_W_XREG);
@@ -274,7 +293,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		   dev->name, arcnet_inb(ioaddr, COM20020_REG_R_STATUS));
 
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
-	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
+	lp->config |= (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	arcnet_outb(lp->config, ioaddr, COM20020_REG_W_CONFIG);
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
-- 
2.6.1
