From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Tue, 22 Apr 2008 19:36:31 +0400
Message-ID: <20080422153631.GA30309@polina.dev.rtsoft.ru>
References: <200804161640.42693.laurentp@cse-semaphore.com> <200804221055.09038.laurentp@cse-semaphore.com> <20080422150844.GA15474@ld0162-tx32.am.freescale.net> <200804221721.51461.laurentp@cse-semaphore.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:46242 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751462AbYDVPgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 11:36:35 -0400
Content-Disposition: inline
In-Reply-To: <200804221721.51461.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2008 at 05:21:49PM +0200, Laurent Pinchart wrote:
> On Tuesday 22 April 2008 17:08, Scott Wood wrote:
> > On Tue, Apr 22, 2008 at 10:55:06AM +0200, Laurent Pinchart wrote:
> > > On Monday 21 April 2008 19:56, Scott Wood wrote:
> > > > The memory-constrained platform I had in mind was 8xx, which doesn't use
> > > > bitbanged MDIO.  It might nice to keep the gpiolib bit separate to avoid
> > > > situations such as ep8248e where mdiobb would be the only thing
> > > > requiring a gpiolib binding, though -- but it shouldn't be two separate
> > > > bitbang drivers, just the existing bitbang driver plus some glue code
> > > > that binds it to gpiolib.
> > > 
> > > I would be fine with that if the glue code wasn't 90% of the whole driver. 
> > > There is really little (not to say nothing) that can be shared between the 
> > > two drivers.
> > 
> > I think we're thinking of a different pair of drivers...  I thought you
> > were talking about duplicating drivers/net/phy/mdio-bitbang.c, not
> > drivers/net/fs_enet/mii-bitbang.c.
> 
> I don't plan to touch drivers/net/phy/mdio-bitbang.c at all, it does its job 
> well enough.
> 
> As the openfirmware + gpio + mdio driver might benefit non-powerpc platforms, 
> I plan to create a new driver (probably drivers/net/phy/mdio-ofgpio.c) that 
> mostly ports drivers/net/fs_enet/mii-bitbang.c to the gpiolib (this replaces 
> around 90% of the code).
> 
> If both drivers/net/fs_enet/mii-bitbang.c and drivers/net/phy/mdio-ofgpio.c 
> must live together, I'll have a problem in 
> drivers/net/fs_enet/fs_enet-main.c. The net device probing code searches the 
> device tree for an associated PHY, and creates a PHY id from the PHY node. As 
> the id will be generated from different bus ids in the two mdio drivers (the 
> bus number is the register address for drivers/net/fs_enet/mii-bitbang.c, and 
> is the gpio index for drivers/net/phy/mdio-ofgpio.c), things will break.
> 
> Any idea regarding how to get rid of that fs_enet/mii-bitbang hardcoded 
> dependency ?

Hm... PHYs are having bus_id equal to MDIOBUS:PHYID, for example
e0024520:02, see fs_enet-main.c find_phy() and fs_init_phy():

        data = of_get_property(np, "phy-handle", &len);
        phynode = of_find_node_by_phandle(*data);
        mdionode = of_get_parent(phynode);
        ret = of_address_to_resource(mdionode, 0, &res);
        data = of_get_property(phynode, "reg", &len);
        snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
...
	phydev = phy_connect(dev, fep->fpi->bus_id, &fs_adjust_link, 0,
		PHY_INTERFACE_MODE_MII);

So in the device tree you could do this:

mdio@<GPIO bank addr> {
	compatible = "linux,mdio-gpio";
	...
	phy123: ethernet-phy@2 {
		reg = <2>;
		device_type = "ethernet-phy";
	};
};

ethernet@... {
	...
	compatible = "fs_enet";
	...
	phy-handle = <&phy123>;
};

And fs_enet will match mdio-ofgpio driver.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
