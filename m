From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Thu, 13 Apr 2017 00:10:16 +0200
Message-ID: <20170412221016.GA29708@lunn.ch>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
 <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
 <20170411231424.GA6174@lunn.ch>
 <6de72d4c-5634-f3d6-5bfd-fcc0acda0b83@gmail.com>
 <417fdaa1-7aba-e646-8a50-043322f1410d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <417fdaa1-7aba-e646-8a50-043322f1410d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >>> To give some more background and rational for this change.
> >>>
> >>> On a platform where we have a parent MDIO bus, backed by the
> >>> mdio-bcm-unimac.c driver, we also register a slave MII bus (through
> >>> net/dsa/dsa2.c) which is parented to this UniMAC MDIO bus through an
> >>> assignment of of_node. This slave MII bus is created in order to
> >>> intercept reads/writes to problematic addresses (e.g: that clashes with
> >>> another piece of hardware).
> >>>
> >>> This means that the slave DSA MII bus inherits all child nodes from the
> >>> originating master MII bus. This also means that when the slave MII bus
> >>> is probed via of_mdiobus_register(), we probe the same devices twice:
> >>> once through the master, another time through the slave.
> >>
> >> Ah, O.K. This makes more sense. On the hardware i have, we get three
> >> deep in MDIO busses. We have the FEC mdio bus. On top of that we have
> >> a gpio-mux-mdio, and on top of that we have the mv88e6xxx mdio
> >> bus. And i've never seen issues.
> >>
> >> So your real problem here is you have two mdio busses using the same
> >> device tree properties. I would actually say that is just plain
> >> broken.
> > 
> > From a Device Tree/HW representation perspective, we do have the
> > external BCM53125 switch physically attached to the 7445/7278
> > SWITCH_MDIO bus (backed by mdio-bcm-unimac) so in that regard the
> > representation is correct. There is also an integrated Gigabit PHY
> > (bcm7xxx) which is attached to that bus.

This is made harder by you talking about a board which does not appear
to have its DT file in mainline. So i'm having to guess what it looks
like.

So what i think we are talking about is this bit of code:

static int bcm_sf2_mdio_register(struct dsa_switch *ds)
{
        struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
        struct device_node *dn;
        static int index;
        int err;

        /* Find our integrated MDIO bus node */
        dn = of_find_compatible_node(NULL, NULL, "brcm,unimac-mdio");
        priv->master_mii_bus = of_mdio_find_bus(dn);
        if (!priv->master_mii_bus)
                return -EPROBE_DEFER;

        get_device(&priv->master_mii_bus->dev);
        priv->master_mii_dn = dn;

        priv->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
        if (!priv->slave_mii_bus)
                return -ENOMEM;

        priv->slave_mii_bus->priv = priv;
        priv->slave_mii_bus->name = "sf2 slave mii";
        priv->slave_mii_bus->read = bcm_sf2_sw_mdio_read;
        priv->slave_mii_bus->write = bcm_sf2_sw_mdio_write;
        snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "sf2-%d",
                 index++);
        priv->slave_mii_bus->dev.of_node = dn;

If i get you right, your switch is hanging off the MDIO bus
"brcm,unimac-mdio" you find the dn for. You then register another MDIO
bus using the exact same node? How does that make any sense? Isn't it
a physical separate MDIO bus? So it should have its own set of nodes
in the device tree. This is how we do it for the Marvell switches. See
Documentation/devicetree/binding/net/dsa/marvell.txt and
arch/arm/boot/dts/vf610-zii-dev-rev-b.dts. That DT blob uses
phy-handle to link the switch ports to the phys on the mdio bus.

	   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
