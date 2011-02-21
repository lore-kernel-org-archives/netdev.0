From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/9] ax88796: remove first_init parameter from ax_init_dev()
Date: Mon, 21 Feb 2011 14:03:15 +0100
Message-ID: <1298293400-21570-5-git-send-email-mkl@pengutronix.de>
References: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35849 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067Ab1BUND3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:29 -0500
In-Reply-To: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ax_init_dev() is always called with first_init=1.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/ax88796.c |   44 +++++++++++++++++++-------------------------
 1 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 885f04e..eac5b10 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -675,7 +675,7 @@ static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
  * the device is ready to be used by lib8390.c and registerd with
  * the network layer.
  */
-static int ax_init_dev(struct net_device *dev, int first_init)
+static int ax_init_dev(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
 	struct ax_device *ax = to_ax_dev(dev);
@@ -695,7 +695,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 
 	/* read the mac from the card prom if we need it */
 
-	if (first_init && ax->plat->flags & AXFLG_HAS_EEPROM) {
+	if (ax->plat->flags & AXFLG_HAS_EEPROM) {
 		unsigned char SA_prom[32];
 
 		for (i = 0; i < sizeof(SA_prom); i += 2) {
@@ -711,7 +711,7 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	}
 
 #ifdef CONFIG_AX88796_93CX6
-	if (first_init && ax->plat->flags & AXFLG_HAS_93CX6) {
+	if (ax->plat->flags & AXFLG_HAS_93CX6) {
 		unsigned char mac_addr[6];
 		struct eeprom_93cx6 eeprom;
 
@@ -737,25 +737,20 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 		stop_page = NE1SM_STOP_PG;
 	}
 
-	/*
-	 * load the mac-address from the device if this is the first
-	 * time we've initialised
-	 */
-	if (first_init) {
-		if (ax->plat->flags & AXFLG_MAC_FROMDEV) {
-			ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
-				ei_local->mem + E8390_CMD); /* 0x61 */
-			for (i = 0; i < ETHER_ADDR_LEN; i++)
-				dev->dev_addr[i] =
-					ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
-		}
-
-		if ((ax->plat->flags & AXFLG_MAC_FROMPLATFORM) &&
-		     ax->plat->mac_addr)
-			memcpy(dev->dev_addr, ax->plat->mac_addr,
-				ETHER_ADDR_LEN);
+	/* load the mac-address from the device */
+	if (ax->plat->flags & AXFLG_MAC_FROMDEV) {
+		ei_outb(E8390_NODMA + E8390_PAGE1 + E8390_STOP,
+			ei_local->mem + E8390_CMD); /* 0x61 */
+		for (i = 0; i < ETHER_ADDR_LEN; i++)
+			dev->dev_addr[i] =
+				ei_inb(ioaddr + EN1_PHYS_SHIFT(i));
 	}
 
+	if ((ax->plat->flags & AXFLG_MAC_FROMPLATFORM) &&
+	    ax->plat->mac_addr)
+		memcpy(dev->dev_addr, ax->plat->mac_addr,
+		       ETHER_ADDR_LEN);
+
 	ax_reset_8390(dev);
 
 	ei_local->name = "AX88796";
@@ -790,10 +785,9 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 
 	ax_NS8390_init(dev, 0);
 
-	if (first_init)
-		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
-			 ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
-			 dev->dev_addr);
+	dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
+		 ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
+		 dev->dev_addr);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -949,7 +943,7 @@ static int ax_probe(struct platform_device *pdev)
 
 	/* got resources, now initialise and register device */
 
-	ret = ax_init_dev(dev, 1);
+	ret = ax_init_dev(dev);
 	if (!ret)
 		return 0;
 
-- 
1.7.2.3

