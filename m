From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Fri, 29 Apr 2016 07:25:01 -0500
Message-ID: <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
References: <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Nathan Sullivan <nathan.sullivan@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 07:34:59PM -0500, Josh Cartwright wrote:
> On Thu, Apr 28, 2016 at 11:23:15PM +0200, Andrew Lunn wrote:
> > On Thu, Apr 28, 2016 at 04:03:57PM -0500, Josh Cartwright wrote:
> > > On Thu, Apr 28, 2016 at 08:59:32PM +0200, Andrew Lunn wrote:
> > > > On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
> > > > > On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
> > > > > > > I agree that is a valid fix for AT91, however it won't solve our problem, since
> > > > > > > we have no children on the second ethernet MAC in our devices' device trees. I'm
> > > > > > > starting to feel like our second MAC shouldn't even really register the MDIO bus
> > > > > > > since it isn't being used - maybe adding a DT property to not have a bus is a
> > > > > > > better option?
> > > > > > 
> > > > > > status = "disabled"
> > > > > > 
> > > > > > would be the unusual way.
> > > > > > 
> > > > > >       Andrew
> > > > > 
> > > > > Oh, sorry, I meant we use both MACs on Zynq, however the PHYs are on the MDIO
> > > > > bus of the first MAC.  So, the second MAC is used for ethernet but not for MDIO,
> > > > > and so it does not have any PHYs under its DT node.  It would be nice if there
> > > > > were a way to tell macb not to bother with MDIO for the second MAC, since that's
> > > > > handled by the first MAC.
> > > > 
> > > > Yes, exactly, add support for status = "disabled" in the mdio node.
> > > 
> > > Unfortunately, the 'macb' doesn't have a "mdio node", or alternatively:
> > > the node representing the mdio bus is the same node which represents the
> > > macb instance itself.  Setting 'status = "disabled"' on this node will
> > > just prevent the probing of the macb instance.
> > 
> > :-(
> > 
> > It is very common to have an mdio node within the MAC node, for example imx6sx-sdb.dtsi
> 
> Okay, I think that makes sense.  I think, then, perhaps the solution to
> our problem is to:
> 
>   1. Modify the macb driver to support an 'mdio' node. (And adjust the
>      binding document accordingly).  If the node is found, it's used for
>      of_mdiobus_register() w/o any of the manual scan madness.
>   2. For backwards compatibility, in the case where an 'mdio' node does
>      not exist, leave the existing behavior the way it is now
>      (of_mdiobus_register() followed by manual scan) [perhaps warn of
>      deprecation as well?]
>   3. Update binding docs to reflect the above.
> 
> In this way, for our usecase, the 'status = "disabled"' in the newly
> created 'mdio' node isn't necessary.  It's sufficient for the node to
> exist and be empty.

Here's a (only build tested) attempt at implementing a part of this.  I
macb_mii_init() was getting complicated enough that I lifted out two
helper functions for the dt/no-dt case.  Sweeping the in-tree
devicetrees to update them to place phys under an 'mdio' node is still
to be done.

  Josh

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index eec3200..d843bc9 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -419,11 +419,62 @@ static int macb_mii_probe(struct net_device *dev)
 	return 0;
 }
 
+static int macb_mii_of_init(struct macb *bp, struct device_node *np)
+{
+	struct device_node *mdio;
+	int err, i;
+
+	mdio = of_get_child_by_name(np, "mdio");
+	if (mdio)
+		return of_mdiobus_register(bp->mii_bus, mdio);
+
+	dev_warn(&bp->pdev->dev,
+		 "using deprecated PHY probing mechanism.  Please update device tree.");
+
+	/* try dt phy registration */
+	err = of_mdiobus_register(bp->mii_bus, np);
+	if (err)
+		return err;
+
+	/* fallback to standard phy registration if no phy were
+	 * found during dt phy registration
+	 */
+	if (!phy_find_first(bp->mii_bus)) {
+		for (i = 0; i < PHY_MAX_ADDR; i++) {
+			struct phy_device *phydev;
+
+			phydev = mdiobus_scan(bp->mii_bus, i);
+			if (IS_ERR(phydev)) {
+				err = PTR_ERR(phydev);
+				break;
+			}
+		}
+
+		if (err)
+			goto err_out_unregister_bus;
+	}
+
+	return err;
+
+err_out_unregister_bus:
+	mdiobus_unregister(bp->mii_bus);
+	return err;
+}
+
+static int macb_mii_pdata_init(struct macb *bp,
+			       struct macb_platform_data *pdata)
+{
+	if (pdata)
+		bp->mii_bus->phy_mask = pdata->phy_mask;
+
+	return mdiobus_register(bp->mii_bus);
+}
+
 static int macb_mii_init(struct macb *bp)
 {
 	struct macb_platform_data *pdata;
 	struct device_node *np;
-	int err = -ENXIO, i;
+	int err = -ENXIO;
 
 	/* Enable management port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
@@ -446,33 +497,10 @@ static int macb_mii_init(struct macb *bp)
 	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
 
 	np = bp->pdev->dev.of_node;
-	if (np) {
-		/* try dt phy registration */
-		err = of_mdiobus_register(bp->mii_bus, np);
-
-		/* fallback to standard phy registration if no phy were
-		 * found during dt phy registration
-		 */
-		if (!err && !phy_find_first(bp->mii_bus)) {
-			for (i = 0; i < PHY_MAX_ADDR; i++) {
-				struct phy_device *phydev;
-
-				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev)) {
-					err = PTR_ERR(phydev);
-					break;
-				}
-			}
-
-			if (err)
-				goto err_out_unregister_bus;
-		}
-	} else {
-		if (pdata)
-			bp->mii_bus->phy_mask = pdata->phy_mask;
-
-		err = mdiobus_register(bp->mii_bus);
-	}
+	if (np)
+		err = macb_mii_of_init(bp, np);
+	else
+		err = macb_mii_pdata_init(bp, pdata);
 
 	if (err)
 		goto err_out_free_mdiobus;
