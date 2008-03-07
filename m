From: Olof Johansson <olof@lixom.net>
Subject: Re: I2C MDIO support for pasemi_mac driver
Date: Fri, 7 Mar 2008 12:37:38 -0600
Message-ID: <20080307183738.GA22366@lixom.net>
References: <1204911643.8864.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pasemi-linux@ozlabs.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: Nathaniel Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:35984 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757675AbYCGSb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 13:31:58 -0500
Content-Disposition: inline
In-Reply-To: <1204911643.8864.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(Adding Andy Fleming and netdev as cc)

On Fri, Mar 07, 2008 at 11:40:43AM -0600, Nathaniel Case wrote:
> Olof,
> 
> I'm working on cleaning up our i2c_mdio driver for submission upstream.
> One issue we're facing is how to uniquely number the MDIO bus ID which
> gets passed to the PHY layer and how the OFW device tree should look.
> 
> For example, pasemi_mac currently gets the PHY address from the "reg"
> property of the ethernet-phy node.  It assigns the MDIO bus ID from the
> "reg" field of the ethernet-phy node's parent.  I'm referring to the two
> components of the phy_id that gets passed to phy_connect().
> 
> As you've mentioned in the past, an I2C PHY node should go underneath
> the appropriate SMBus.  I think we could just use the lower 5 bits of
> the I2C slave address for the PHY address, but the issue of the MDIO bus
> ID is a little more tricky.
> 
> For my case, the parent of the I2C PHY node would be the i2c@1c,2 node,
> so pasemi_mac could no longer just look at "reg" of the parent node.
> Specifically, the i2c@ nodes and the mdio@ nodes don't agree on the
> "reg" property so it can't be used for determining a MDIO bus ID.
> 
> Do you have any suggestions for addressing this?  The only solution I
> can think of is adding a 'mdio-bus' property to both the mdio@ and i2C@
> nodes (if applicable), and then changing pasemi_mac to look for these
> instead.

A good start is probably to check the compatible field of the parent and
see if it's the mdio bus. Looks like the i2c device nodes lack a
compatible field, so we'd need to check device_type there (or fall back
and assume i2c on non-mdio).

For the i2c devices that are right below the controller node it's not
too hard, since we know for sure they are added to the system using
i2c_add_numbered_adapter with the same bus number as the PCI function
number.

But the generic case is tricker, since there's nothing that says the
phy isn't sitting on a (for example) muxed sub-bus instead (a gemeni in
an electra/chitra would be configured like this, but I haven't done any
phy work for them yet).

The i2c bus number should be available in the phy driver when it's
probed/registered, so you should be able to get to it there. It's awkward
that the MDIO and i2c busses have separate namespaces, it'll make it hard
if there's ever a system with both mdio and smbus-based phys. We could
control that by how the mdio bus is specified in device tree on those
systems though, and make sure the bus number for the "real" mdio bus is
sufficiently offset to give room for the smbus-based bus numbers below.

How about something like the below? Completely untested due to lack of
hardware, and needs some cleanup w.r.t. error handling.

Thoughts? Comments? Flames?


-Olof

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index c50f0f4..febf1b6 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1086,7 +1086,7 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct device_node *dn, *phy_dn;
 	struct phy_device *phydev;
-	unsigned int phy_id;
+	unsigned int phy_id, bus_id;
 	const phandle *ph;
 	const unsigned int *prop;
 	struct resource r;
@@ -1099,12 +1099,26 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	phy_dn = of_find_node_by_phandle(*ph);
 
 	prop = of_get_property(phy_dn, "reg", NULL);
-	ret = of_address_to_resource(phy_dn->parent, 0, &r);
-	if (ret)
-		goto err;
-
 	phy_id = *prop;
-	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, (int)r.start, phy_id);
+	if (of_device_is_compatible(phy_dn->parent, "gpio-mdio")) {
+		ret = of_address_to_resource(phy_dn->parent, 0, &r);
+		if (ret)
+			goto err;
+
+		bus_id = (int)r.start;
+	} else if (phy_dn->parent->type && !strcmp(phy_dn->parent->type, "i2c")) {
+		struct pci_dn *pdn;
+		/* PHY is on smbus. Right now we only support them directly on root buses,
+		 * and there we know that the bus ID is the same as the PCI function.
+		 */
+		pdn = PCI_DN(phy_dn->parent);
+		bus_id = PCI_FUNC(pdn->devfn);
+	} else {
+		printk("Unknown PHY device in device tree\n");
+		bus_id = -1;
+	}
+
+	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, bus_id, phy_id);
 
 	of_node_put(phy_dn);
 
