From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/8] r6040: consolidate MAC reset to its own function
Date: Wed, 11 Apr 2012 19:18:36 +0200
Message-ID: <1334164723-9627-2-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45795 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760772Ab2DKRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:13 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset of the MAC is currently done identically from two places
and one place is not waiting for the MAC_SM bit to be set after reset.
Everytime the MAC is software resetted a state machine is also needed
so consolidate the reset to its own function.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index a26307f..c10b0b8 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -358,27 +358,35 @@ err_exit:
 	return rc;
 }
 
-static void r6040_init_mac_regs(struct net_device *dev)
+static void r6040_reset_mac(struct r6040_private *lp)
 {
-	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	int limit = 2048;
 	u16 cmd;
 
-	/* Mask Off Interrupt */
-	iowrite16(MSK_INT, ioaddr + MIER);
-
-	/* Reset RDC MAC */
 	iowrite16(MAC_RST, ioaddr + MCR1);
 	while (limit--) {
 		cmd = ioread16(ioaddr + MCR1);
 		if (cmd & MAC_RST)
 			break;
 	}
+
 	/* Reset internal state machine */
 	iowrite16(MAC_SM_RST, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
 	mdelay(5);
+}
+
+static void r6040_init_mac_regs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	/* Mask Off Interrupt */
+	iowrite16(MSK_INT, ioaddr + MIER);
+
+	/* Reset RDC MAC */
+	r6040_reset_mac(lp);
 
 	/* MAC Bus Control Register */
 	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
@@ -445,18 +453,13 @@ static void r6040_down(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
-	int limit = 2048;
 	u16 *adrp;
-	u16 cmd;
 
 	/* Stop MAC */
 	iowrite16(MSK_INT, ioaddr + MIER);	/* Mask Off Interrupt */
-	iowrite16(MAC_RST, ioaddr + MCR1);	/* Reset RDC MAC */
-	while (limit--) {
-		cmd = ioread16(ioaddr + MCR1);
-		if (cmd & MAC_RST)
-			break;
-	}
+
+	/* Reset RDC MAC */
+	r6040_reset_mac(lp);
 
 	/* Restore MAC Address to MIDx */
 	adrp = (u16 *) dev->dev_addr;
@@ -736,11 +739,7 @@ static void r6040_mac_address(struct net_device *dev)
 	u16 *adrp;
 
 	/* Reset MAC */
-	iowrite16(MAC_RST, ioaddr + MCR1);
-	/* Reset internal state machine */
-	iowrite16(MAC_SM_RST, ioaddr + MAC_SM);
-	iowrite16(0, ioaddr + MAC_SM);
-	mdelay(5);
+	r6040_reset_mac(lp);
 
 	/* Restore MAC Address */
 	adrp = (u16 *) dev->dev_addr;
-- 
1.7.5.4
