From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] macsonic: Updated printk() statement to
 netdev_info function
Date: Fri, 25 Oct 2013 21:26:10 -0700
Message-ID: <1382761570.2591.8.camel@joe-AO722>
References: <1382738000-24202-1-git-send-email-zanchm@rpi.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Zanchelli <zanchm@rpi.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0148.hostedemail.com ([216.40.44.148]:45111 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751255Ab3JZE03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 00:26:29 -0400
In-Reply-To: <1382738000-24202-1-git-send-email-zanchm@rpi.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 21:53 +0000, Matt Zanchelli wrote:
> Updated the printk() statement in mac_sonic_probe() to recommended netdev_info.

Hi again Matt.

> Reviewed-by: Mukkai Krishnamoorthy <mskmoorthy@gmail.com>
> Reviewed-by: Maxwell Ensley-Field <mensleyfield@gmail.com>
> Reviewed-by: Nicole Negedly <nnegedly@gmail.com>
> Reviewed-by: Daniel Felizardo <danfelizardo@gmail.com>
> Signed-off-by: Matt Zanchelli <zanchm@rpi.edu>

Does it really take 4 reviewers for a single line change?

I'd rather have each of these reviewers submit patches to
different files rather than have them review this pretty
trivial change to a pretty old driver that really doesn't
need much in the way of changes.

And please, if you modify this file all, please be more
comprehensive in the printk conversions.

There are many printks in this file, not just this one.

> diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
[]
> @@ -601,7 +601,7 @@ found:
>  	if (err)
>  		goto out;
>  
> -	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
> +	netdev_info(dev, "MAC %pM IRQ %d\n", dev->dev_addr, dev->irq);
>  
>  	return 0;

Something like:

 drivers/net/ethernet/natsemi/macsonic.c | 66 +++++++++++++++------------------
 drivers/net/ethernet/natsemi/sonic.h    |  3 +-
 2 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 346a4e0..bc33181 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -31,6 +31,8 @@
  *          on centris.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -80,8 +82,6 @@ static unsigned int sonic_debug = SONIC_DEBUG;
 static unsigned int sonic_debug = 1;
 #endif
 
-static int sonic_version_printed;
-
 /* For onboard SONIC */
 #define ONBOARD_SONIC_REGISTERS	0x50F0A000
 #define ONBOARD_SONIC_PROM_BASE	0x50f08000
@@ -143,8 +143,7 @@ static int macsonic_open(struct net_device* dev)
 
 	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
-		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
-				dev->name, dev->irq);
+		netdev_err(dev, "unable to get IRQ %d\n", dev->irq);
 		goto err;
 	}
 	/* Under the A/UX interrupt scheme, the onboard SONIC interrupt comes
@@ -155,8 +154,7 @@ static int macsonic_open(struct net_device* dev)
 		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt, 0,
 				     "sonic", dev);
 		if (retval) {
-			printk(KERN_ERR "%s: unable to get IRQ %d.\n",
-					dev->name, IRQ_NUBUS_9);
+			netdev_err(dev, "unable to get IRQ %d\n", IRQ_NUBUS_9);
 			goto err_irq;
 		}
 	}
@@ -277,11 +275,9 @@ static void mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 		 * If we still have what seems to be a bogus address, we'll
 		 * look in the CAM. The top entry should be ours.
 		 */
-		printk(KERN_WARNING "macsonic: MAC address in PROM seems "
-		                    "to be invalid, trying CAM\n");
+		netdev_warn(dev, "MAC address in PROM seems to be invalid, trying CAM\n");
 	} else {
-		printk(KERN_WARNING "macsonic: cannot read MAC address from "
-		                    "PROM, trying CAM\n");
+		netdev_warn(dev, "cannot read MAC address from PROM, trying CAM\n");
 	}
 
 	/* This only works if MacOS has already initialized the card. */
@@ -304,8 +300,7 @@ static void mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 
 	/* Still nonsense ... messed up someplace! */
 
-	printk(KERN_WARNING "macsonic: MAC address in CAM entry 15 "
-	                    "seems invalid, will use a random MAC\n");
+	netdev_warn(dev, "MAC address in CAM entry 15 seems invalid, will use a random MAC\n");
 	eth_hw_addr_random(dev);
 }
 
@@ -318,7 +313,7 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	if (!MACH_IS_MAC)
 		return -ENODEV;
 
-	printk(KERN_INFO "Checking for internal Macintosh ethernet (SONIC).. ");
+	netdev_info(dev, "Checking for internal Macintosh ethernet (SONIC).. ");
 
 	/* Bogus probing, on the models which may or may not have
 	   Ethernet (BTW, the Ethernet *is* always at the same
@@ -336,7 +331,7 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 		local_irq_restore(flags);
 
 		if (!card_present) {
-			printk("none.\n");
+			printk("none\n");
 			return -ENODEV;
 		}
 		commslot = 1;
@@ -352,12 +347,10 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	else
 		dev->irq = IRQ_NUBUS_9;
 
-	if (!sonic_version_printed) {
-		printk(KERN_INFO "%s", version);
-		sonic_version_printed = 1;
-	}
-	printk(KERN_INFO "%s: onboard / comm-slot SONIC at 0x%08lx\n",
-	       dev_name(lp->device), dev->base_addr);
+	pr_info_once("%s\n", version);
+
+	netdev_info(dev, "onboard / comm-slot SONIC at 0x%08lx\n",
+		    dev->base_addr);
 
 	/* The PowerBook's SONIC is 16 bit always. */
 	if (macintosh_config->ident == MAC_MODEL_PB520) {
@@ -388,13 +381,13 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 		lp->dma_bitmode = SONIC_BITMODE32;
 		sr = SONIC_READ(SONIC_SR);
 	}
-	printk(KERN_INFO
-	       "%s: revision 0x%04x, using %d bit DMA and register offset %d\n",
-	       dev_name(lp->device), sr, lp->dma_bitmode?32:16, lp->reg_offset);
+	netdev_info(dev, "revision 0x%04x, using %d bit DMA and register offset %d\n",
+		    sr, lp->dma_bitmode ? 32 : 16, lp->reg_offset);
 
 #if 0 /* This is sometimes useful to find out how MacOS configured the card. */
-	printk(KERN_INFO "%s: DCR: 0x%04x, DCR2: 0x%04x\n", dev_name(lp->device),
-	       SONIC_READ(SONIC_DCR) & 0xffff, SONIC_READ(SONIC_DCR2) & 0xffff);
+	netdev_info(dev, "DCR: 0x%04x, DCR2: 0x%04x\n",
+		    SONIC_READ(SONIC_DCR) & 0xffff,
+		    SONIC_READ(SONIC_DCR2) & 0xffff);
 #endif
 
 	/* Software reset, then initialize control registers. */
@@ -527,7 +520,7 @@ static int mac_nubus_sonic_probe(struct net_device *dev)
 		dma_bitmode = SONIC_BITMODE16;
 		break;
 	default:
-		printk(KERN_ERR "macsonic: WTF, id is %d\n", id);
+		netdev_err(dev, "WTF, id is %d\n", id);
 		return -ENODEV;
 	}
 
@@ -538,18 +531,17 @@ static int mac_nubus_sonic_probe(struct net_device *dev)
 	lp->dma_bitmode = dma_bitmode;
 	dev->irq = SLOT2IRQ(ndev->board->slot);
 
-	if (!sonic_version_printed) {
-		printk(KERN_INFO "%s", version);
-		sonic_version_printed = 1;
-	}
-	printk(KERN_INFO "%s: %s in slot %X\n",
-	       dev_name(lp->device), ndev->board->name, ndev->board->slot);
-	printk(KERN_INFO "%s: revision 0x%04x, using %d bit DMA and register offset %d\n",
-	       dev_name(lp->device), SONIC_READ(SONIC_SR), dma_bitmode?32:16, reg_offset);
+	pr_info_once("%s\n", version);
+
+	netdev_info(dev, "%s in slot %X\n",
+		    ndev->board->name, ndev->board->slot);
+	netdev_info(dev, "revision 0x%04x, using %d bit DMA and register offset %d\n",
+		    SONIC_READ(SONIC_SR), dma_bitmode ? 32 : 16, reg_offset);
 
 #if 0 /* This is sometimes useful to find out how MacOS configured the card. */
-	printk(KERN_INFO "%s: DCR: 0x%04x, DCR2: 0x%04x\n", dev_name(lp->device),
-	       SONIC_READ(SONIC_DCR) & 0xffff, SONIC_READ(SONIC_DCR2) & 0xffff);
+	netdev_info(dev, "DCR: 0x%04x, DCR2: 0x%04x\n",
+		    SONIC_READ(SONIC_DCR) & 0xffff,
+		    SONIC_READ(SONIC_DCR2) & 0xffff);
 #endif
 
 	/* Software reset, then initialize control registers. */
@@ -601,7 +593,7 @@ found:
 	if (err)
 		goto out;
 
-	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
+	netdev_info(dev, "MAC %pM IRQ %d\n", dev->dev_addr, dev->irq);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/natsemi/sonic.h b/drivers/net/ethernet/natsemi/sonic.h
index 07091dd..6d31916 100644
--- a/drivers/net/ethernet/natsemi/sonic.h
+++ b/drivers/net/ethernet/natsemi/sonic.h
@@ -444,7 +444,6 @@ static inline __u16 sonic_rra_get(struct net_device* dev, int entry,
 			     (entry * SIZEOF_SONIC_RR) + offset);
 }
 
-static const char *version =
-    "sonic.c:v0.92 20.9.98 tsbogend@alpha.franken.de\n";
+static const char *version = "v0.92 20.9.98 tsbogend@alpha.franken.de";
 
 #endif /* SONIC_H */
