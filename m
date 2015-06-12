From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Fri, 12 Jun 2015 20:38:31 +0200
Message-ID: <20150612183831.GA15388@lunn.ch>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
 <1434129537-15252-3-git-send-email-andrew@lunn.ch>
 <557B2181.9090900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55400 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755722AbbFLSoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 14:44:14 -0400
Content-Disposition: inline
In-Reply-To: <557B2181.9090900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 11:14:25AM -0700, Florian Fainelli wrote:
> On 12/06/15 10:18, Andrew Lunn wrote:
> > By default, DSA and CPU ports are configured to the maximum speed the
> > switch supports. However there can be use cases where the peer device
> > port is slower. Allow a fixed-link property to be used with the DSA
> > and CPU port in the device tree, and use this information to configure
> > the port.
> 
> Humm, I suppose this means that we might end-up with two fixed PHY
> devices, one for the Ethernet MAC, and another one for the switch?

Yes. This is exactly what i have for the board i'm working on. The
concept also applies for DSA ports, so you could have two switches and
two fixed phys for one inter-switch link.

> That might duplicate the same information, though I cannot think of
> a better solution than using phandles to resolve that.

This seems the simplest solution. It would be possible to create a
"dual port" fixed phy, meaning it exposes two phy_device structures,
one for each side. But that seems overkill.

> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> >  include/net/dsa.h |  1 +
> >  net/dsa/dsa.c     | 39 +++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 40 insertions(+)
> > 
> > diff --git a/include/net/dsa.h b/include/net/dsa.h
> > index fbca63ba8f73..24572f99224c 100644
> > --- a/include/net/dsa.h
> > +++ b/include/net/dsa.h
> > @@ -160,6 +160,7 @@ struct dsa_switch {
> >  	 * Slave mii_bus and devices for the individual ports.
> >  	 */
> >  	u32			dsa_port_mask;
> > +	u32			cpu_port_mask;
> >  	u32			phys_port_mask;
> >  	u32			phys_mii_mask;
> >  	struct mii_bus		*slave_mii_bus;
> > diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> > index 392e29a0227d..f9c8f4e7ebce 100644
> > --- a/net/dsa/dsa.c
> > +++ b/net/dsa/dsa.c
> > @@ -176,6 +176,36 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
> >  #endif /* CONFIG_NET_DSA_HWMON */
> >  
> >  /* basic switch operations **************************************************/
> > +static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
> > +{
> > +	struct dsa_chip_data *cd = ds->pd;
> > +	struct device_node *port_dn;
> > +	struct phy_device *phydev;
> > +	int ret, port;
> > +
> > +	for (port = 0; port < DSA_MAX_PORTS; port++) {
> > +		if (!((ds->cpu_port_mask | ds->dsa_port_mask) & (1 << port)))
> > +			continue;
> > +
> > +		port_dn = cd->port_dn[port];
> > +		if (of_phy_is_fixed_link(port_dn)) {
> > +			ret = of_phy_register_fixed_link(port_dn);
> > +			if (ret) {
> > +				netdev_err(master,
> > +					   "failed to register fixed PHY\n");
> > +				return ret;
> > +			}
> > +			phydev = of_phy_find_device(port_dn);
> > +			phydev->is_pseudo_fixed_link = true;
> > +			genphy_config_init(phydev);
> > +			genphy_read_status(phydev);
> 
> I was curious as to why you were doing this at first, but I guess this
> is because the PHY state machine is not started for this fixed PHY that
> you just created, right?

For the fixed phy to be of any use in adjust_link(), it needs to set
phydev->link, phydev->speed and phydev->duplex. That only happens when
genphy_read_status() is called. And you don't get sensible values
unless genphy_config_init() is called first. We don't have a netdev we
can attach this phydev to, so the core has no chance to do these
genphy_XXX calls.

> > +			if (ds->drv->adjust_link)
> > +				ds->drv->adjust_link(ds, port, phydev);
> > +		}
> > +	}
> > +	return 0;
> > +}
> > +
> >  static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
> >  {
> >  	struct dsa_switch_driver *drv = ds->drv;
> > @@ -204,6 +234,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
> >  			}
> >  			dst->cpu_switch = index;
> >  			dst->cpu_port = i;
> > +			ds->cpu_port_mask |= 1 << i;
> 
> Same question as Guenter here, I assume this is because you plan on
> having multiple CPU ports connected to the switch and this makes it
> easier to deal with, is that right?

Yes, sort of. At the time i wrote this code, i already had multiple
CPU ports working. But the order i'm submitting the patches has been
reversed. This could be simplified for a single CPU port.

The multiple CPU ports is turning out to be messy, but not because of
the code. It works on my DIR665, but the second ethernet does not have
a MAC address, which is causing issues i need to track down. For
testing i've set one in device tree. And my WRT1900AC has something
funny going on with its second interface resulting in it never
sending/receiving packets, but works fine with OpenWRT swconfig
drivers. Until i have one platform in a state i can mainline, i'm
holding off with the multi-cpu patches. I do want to work on them next
though, but i guess i'm going to miss this merge window.

	Andrew
