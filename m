From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 4 Dec 2015 15:31:05 +0100
Message-ID: <20151204143105.GA26391@lunn.ch>
References: <561FF9E2.30102@opensource.altera.com>
 <56200687.9040903@gmail.com>
 <562005AD.8020903@opensource.altera.com>
 <56200BD7.8020505@gmail.com>
 <20151203204811.GB14427@amd>
 <5660B2EC.1050705@caviumnetworks.com>
 <5660CD87.5050603@opensource.altera.com>
 <20151204011050.GC26934@lunn.ch>
 <20151204015057.GB28005@lunn.ch>
 <alpine.DEB.2.02.1512040522350.32296@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Pavel Machek <pavel@denx.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1512040522350.32296@linux-builds1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > @@ -339,9 +340,19 @@ static int ksz9021_config_init(struct phy_device *phydev)
> >  {
> >  	const struct device *dev = &phydev->dev;
> >  	const struct device_node *of_node = dev->of_node;
> > +	const struct device *dev_walker;
> >  
> > -	if (!of_node && dev->parent->of_node)
> > -		of_node = dev->parent->of_node;
> > +	dev_info(dev, "dev->parent: %s\n", dev_name(dev->parent));
> > +	dev_info(dev, "phydev->attached_dev->dev: %s\n", dev_name(&phydev->attached_dev->dev));
> > +
> > +	dev_walker = &phydev->dev;
> > +	do {
> > +		of_node = dev_walker->of_node;
> > +		dev_info(dev, "walking: %s %p\n",
> > +			 dev_name(dev_walker), of_node);
> > +		dev_walker = dev_walker->parent;
> > +
> > +	} while (!of_node && dev_walker);
> >  
> >  	if (of_node) {
> >  		ksz9021_load_values_from_of(phydev, of_node,
> > 
> 
> Here is the output from the above patch:
> 
> [    1.042049] mmc0: new high speed SDHC card at address aaaa
> [    1.048017] mmcblk0: mmc0:aaaa SU32G 29.7 GiB
> [    1.053506]  mmcblk0: p1 p2 p3 p4
> [    1.057708] dwc2 ffb40000.usb: Configuration mismatch. Forcing host mode
> [    1.064418] dwc2 ffb40000.usb: no platform data or transceiver defined
> [    1.070966] Micrel KSZ9021 Gigabit PHY stmmac-0:04: dev->parent: stmmac-0
> [    1.077746] Micrel KSZ9021 Gigabit PHY stmmac-0:04: phydev->attached_dev->dev: eth0
> [    1.085389] Micrel KSZ9021 Gigabit PHY stmmac-0:04: walking: stmmac-0:04   (null)
> [    1.092841] Micrel KSZ9021 Gigabit PHY stmmac-0:04: walking: stmmac-0   (null)
> [    1.100042] Micrel KSZ9021 Gigabit PHY stmmac-0:04: walking: ff702000.ethernet ef9f3538

Ah! So we have an intermediary device in the
chain. phydev->attached_dev->dev points to this intermediate device,
rather than the platform device, which is why my patch failed.

I don't know the network stack well enough. Is this consider broken?
Is this valid? Is there any generic code which might try looking in
netdev->dev.of_node?  Do other MAC drivers have an intermediate
device?

We could modify the stmac driver so that phydev->attached_dev->dev
does point to the platform device, and then my patch works. But if
there are other MAC drivers which are structured like this, they are
also broken when used with the Micrel PHY. So then walking up the
device tree is a better solution.

Comments from more knowledgeable people requested!

       Andrew
