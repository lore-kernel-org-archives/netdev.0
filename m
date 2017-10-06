From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH net v2 6/9] net/sonic: Cleanup and modernize log messages
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)
Message-ID: <f918fe27c5f9eaa0894e6b23472269928af38df2.1507211120.git.fthain@telegraphics.com.au>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Chris Zankel <chris@zankel.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing printk severity levels.
Don't print the valid silicon revision number (it's in the source).
Avoid KERN_CONT usage as per advice from checkpatch.
Avoid ifdef around printk calls.

Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
Only the macsonic.c changes have been tested. The other changes
are similar but untested.
---
 drivers/net/ethernet/natsemi/jazzsonic.c |  9 +++------
 drivers/net/ethernet/natsemi/macsonic.c  | 24 ++++++++++--------------
 drivers/net/ethernet/natsemi/xtsonic.c   | 11 ++++-------
 3 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index a6caeb567c0d..6ec25c27cb73 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -132,17 +132,14 @@ static int sonic_probe1(struct net_device *dev)
 	 * the expected location.
 	 */
 	silicon_revision = SONIC_READ(SONIC_SR);
-	if (sonic_debug > 1)
-		printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
-
 	i = 0;
 	while (known_revisions[i] != 0xffff &&
 	       known_revisions[i] != silicon_revision)
 		i++;
 
 	if (known_revisions[i] == 0xffff) {
-		printk("SONIC ethernet controller not found (0x%4x)\n",
-		       silicon_revision);
+		pr_info("SONIC ethernet controller not found (0x%4x)\n",
+		        silicon_revision);
 		goto out;
 	}
 
@@ -248,7 +245,7 @@ static int jazz_sonic_probe(struct platform_device *pdev)
 	if (err)
 		goto out1;
 
-	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
+	netdev_info(dev, "MAC %pM, IRQ %d\n", dev->dev_addr, dev->irq);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 3ca6ae7caf55..795d71522617 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -315,8 +315,6 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	if (!MACH_IS_MAC)
 		return -ENODEV;
 
-	printk(KERN_INFO "Checking for internal Macintosh ethernet (SONIC).. ");
-
 	/* Bogus probing, on the models which may or may not have
 	   Ethernet (BTW, the Ethernet *is* always at the same
 	   address, and nothing else lives there, at least if Apple's
@@ -329,14 +327,12 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 
 		card_present = hwreg_present((void*)ONBOARD_SONIC_REGISTERS);
 		if (!card_present) {
-			printk("none.\n");
+			pr_info("No onboard or comm-slot SONIC was detected\n");
 			return -ENODEV;
 		}
 		commslot = 1;
 	}
 
-	printk("yes\n");
-
 	/* Danger!  My arms are flailing wildly!  You *must* set lp->reg_offset
 	 * and dev->base_addr before using SONIC_READ() or SONIC_WRITE() */
 	dev->base_addr = ONBOARD_SONIC_REGISTERS;
@@ -385,10 +381,10 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	       "%s: revision 0x%04x, using %d bit DMA and register offset %d\n",
 	       dev_name(lp->device), sr, lp->dma_bitmode?32:16, lp->reg_offset);
 
-#if 0 /* This is sometimes useful to find out how MacOS configured the card. */
-	printk(KERN_INFO "%s: DCR: 0x%04x, DCR2: 0x%04x\n", dev_name(lp->device),
-	       SONIC_READ(SONIC_DCR) & 0xffff, SONIC_READ(SONIC_DCR2) & 0xffff);
-#endif
+	/* This is sometimes useful to find out how MacOS configured the card */
+	pr_debug("%s: DCR=0x%04x, DCR2=0x%04x\n", __func__,
+	         SONIC_READ(SONIC_DCR) & 0xffff,
+	         SONIC_READ(SONIC_DCR2) & 0xffff);
 
 	/* Software reset, then initialize control registers. */
 	SONIC_WRITE(SONIC_CMD, SONIC_CR_RST);
@@ -540,10 +536,10 @@ static int mac_nubus_sonic_probe(struct net_device *dev)
 	printk(KERN_INFO "%s: revision 0x%04x, using %d bit DMA and register offset %d\n",
 	       dev_name(lp->device), SONIC_READ(SONIC_SR), dma_bitmode?32:16, reg_offset);
 
-#if 0 /* This is sometimes useful to find out how MacOS configured the card. */
-	printk(KERN_INFO "%s: DCR: 0x%04x, DCR2: 0x%04x\n", dev_name(lp->device),
-	       SONIC_READ(SONIC_DCR) & 0xffff, SONIC_READ(SONIC_DCR2) & 0xffff);
-#endif
+	/* This is sometimes useful to find out how MacOS configured the card */
+	pr_debug("%s: DCR=0x%04x, DCR2=0x%04x\n", __func__,
+	         SONIC_READ(SONIC_DCR) & 0xffff,
+	         SONIC_READ(SONIC_DCR2) & 0xffff);
 
 	/* Software reset, then initialize control registers. */
 	SONIC_WRITE(SONIC_CMD, SONIC_CR_RST);
@@ -594,7 +590,7 @@ static int mac_sonic_probe(struct platform_device *pdev)
 	if (err)
 		goto out;
 
-	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
+	netdev_info(dev, "MAC %pM, IRQ %d\n", dev->dev_addr, dev->irq);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 9ee0f69a83c0..bed89e8105e9 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -145,17 +145,14 @@ static int __init sonic_probe1(struct net_device *dev)
 	 * the expected location.
 	 */
 	silicon_revision = SONIC_READ(SONIC_SR);
-	if (sonic_debug > 1)
-		printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
-
 	i = 0;
 	while ((known_revisions[i] != 0xffff) &&
 			(known_revisions[i] != silicon_revision))
 		i++;
 
 	if (known_revisions[i] == 0xffff) {
-		printk("SONIC ethernet controller not found (0x%4x)\n",
-				silicon_revision);
+		pr_info("SONIC ethernet controller not found (0x%4x)\n",
+		        silicon_revision);
 		return -ENODEV;
 	}
 
@@ -275,8 +272,8 @@ int xtsonic_probe(struct platform_device *pdev)
 	if ((err = register_netdev(dev)))
 		goto out1;
 
-	printk("%s: SONIC ethernet @%08lx, MAC %pM, IRQ %d\n", dev->name,
-	       dev->base_addr, dev->dev_addr, dev->irq);
+	netdev_info(dev, "SONIC ethernet @%08lx, MAC %pM, IRQ %d\n",
+	            dev->base_addr, dev->dev_addr, dev->irq);
 
 	return 0;
 
-- 
2.13.5
