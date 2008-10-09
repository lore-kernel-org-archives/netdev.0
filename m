From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: phylib: move to dynamic allocation of struct mii_bus
Date: Thu, 9 Oct 2008 11:32:24 +0200
Message-ID: <20081009093224.GB9038@xi.wantstofly.org>
References: <20081008.163040.109671916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40772 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbYJIJc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:32:27 -0400
Content-Disposition: inline
In-Reply-To: <20081008.163040.109671916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 04:30:40PM -0700, David Miller wrote:

> Applied to net-next-2.6, thanks!

This was an older version of the patch (sorry for the confusion),
please apply this fix patch on top of net-next.

I've diffed the relevant files in my branch head against net-next
plus this patch, and that looks as intended.

Thanks for your time!



commit 74d1bdca480e7fad3eba61bb6dd14ae364c8e4f8
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Thu Oct 9 11:23:40 2008 +0200

    phylib: two dynamic mii_bus allocation fallout fixes
    
    1. arch/powerpc/platforms/pasemi/gpio_mdio.c also needs to be
       converted over to mdiobus_{alloc,free}().
    
    2. drivers/net/phy/fixed.c used to embed a struct mii_bus into its
       struct fixed_mdio_bus and then use container_of() to go from the
       former to the latter.  Since mii bus structures are no longer
       embedded, we need to do something like use the mii bus private
       pointer to go from mii_bus to fixed_mdio_bus instead.
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 798c7ab..75cc165 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -230,7 +230,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	if (!priv)
 		goto out;
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	new_bus = mdiobus_alloc();
 
 	if (!new_bus)
 		goto out_free_priv;
@@ -306,7 +306,7 @@ static int gpio_mdio_remove(struct of_device *dev)
 
 	kfree(bus->priv);
 	bus->priv = NULL;
-	kfree(bus);
+	mdiobus_free(bus);
 
 	return 0;
 }
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index b5e13f8..cf24cc3 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -115,8 +115,7 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 
 static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
 {
-	struct fixed_mdio_bus *fmb = container_of(bus, struct fixed_mdio_bus,
-						  mii_bus);
+	struct fixed_mdio_bus *fmb = bus->priv;
 	struct fixed_phy *fp;
 
 	if (reg_num >= MII_REGS_NUM)
@@ -221,6 +220,7 @@ static int __init fixed_mdio_bus_init(void)
 
 	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
 	fmb->mii_bus->name = "Fixed MDIO Bus";
+	fmb->mii_bus->priv = fmb;
 	fmb->mii_bus->parent = &pdev->dev;
 	fmb->mii_bus->read = &fixed_mdio_read;
 	fmb->mii_bus->write = &fixed_mdio_write;
