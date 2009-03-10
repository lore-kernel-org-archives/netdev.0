From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 5/5] net: make mpc5200 fec driver use of_mdio
	infrastructure
Date: Tue, 10 Mar 2009 23:29:49 +0300
Message-ID: <20090310202949.GA17184@oksana.dev.rtsoft.ru>
References: <20090310150751.12455.70598.stgit@localhost.localdomain> <20090310152224.12455.99348.stgit@localhost.localdomain> <20090310191638.GA8539@oksana.dev.rtsoft.ru> <fa686aa40903101248n33ee35c2o32c4b24b349b14fc@mail.gmail.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:2117 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753154AbZCJU3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 16:29:52 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40903101248n33ee35c2o32c4b24b349b14fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 01:48:26PM -0600, Grant Likely wrote:
[...]
> >> eliminates the assumption that the PHY for the FEC is always
> >> attached to the FEC's own MDIO bus. With this patch, the FEC can
> >> use a PHY attached to any MDIO bus if it is described in the device
> >> tree.
> >
> > AFAIK, Gianfar and UCC Geth drivers can do this too, so I'm assuming
> > that this isn't the cause for these major changes.
> 
> Certainly the mpc5200-fec driver's original phy code certainly wasn't
> as robust as the ucc_geth and gianfar phy handling.
> 
> ucc_geth open codes a solution to decode the phy_device name from
> several nodes in the device tree and doesn't handle the case where the
> ucc_geth is initialized before the phy_device is registered.  gianfar
> open codes the same thing.  This solution uses common code to locate
> the phy_device, and it works regardless of what order devices are
> registered in.
> 
> That being said, the 5200 driver originally using probe() time to
> connect to the phy.  If I change it to be connected at open time, then
> does the registration order issue become irrelevant?

Yup. `ifconfig ethX up' calls ->open(). If it fails (and prints
nice error), you can try `ifconfig ethX up' again later.

> Regardless, I
> think all the drivers should be using common code for obtaining the
> phy_device from the device tree.

Not necessary `struct phy_device'. All we need is some common
routine for translating PHY's "mdio_node->full_name + phy id" to
phy_bus_id.

That is, you can just factor out this code from the gianfar driver,

void gfar_mdio_bus_name(char *name, struct device_node *np)
{
        const u32 *reg;

        reg = of_get_property(np, "reg", NULL);

        snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
}

...
        gfar_mdio_bus_name(bus_name, mdio);
        snprintf(priv->phy_bus_id, sizeof(priv->phy_bus_id), "%s:%02x",
                 bus_name, *id);
...

And make sure FEC MDIO driver does mdio_bus->parent = &ofdev->dev;

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
