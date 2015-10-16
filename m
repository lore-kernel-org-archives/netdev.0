From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 16 Oct 2015 09:47:05 -0700
Message-ID: <56212A09.5080206@caviumnetworks.com>
References: <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <56200E15.9080603@caviumnetworks.com> <56201158.8040806@opensource.altera.com> <56201AE7.2020103@gmail.com> <alpine.DEB.2.02.1510152102280.22844@linux-builds1> <20151016033143.GA28207@lunn.ch> <alpine.DEB.2.02.1510160935310.22648@linux-builds1> <20151016150345.GI10146@lunn.ch> <alpine.DEB.2.02.1510161027590.16637@linux-builds1> <20151016155644.GJ10146@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151016155644.GJ10146@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2015 08:56 AM, Andrew Lunn wrote:
>> So I think I'll move to inspect what Florian had suggested, and that was to look
>> at: drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c::stmmac_mdio_register
>
> I have a suspicion. If you look at the phy driver it does:
>
> static int ksz9021_config_init(struct phy_device *phydev)
> {
>          const struct device *dev = &phydev->dev;
>          const struct device_node *of_node = dev->of_node;
>
>          if (!of_node && dev->parent->of_node)
>                  of_node = dev->parent->of_node;
>

Maybe we need to walk up the hierarchy.

Perhaps something like:

const struct device *dev_walker;

dev_walker = &phydev->dev;
do {
    of_node = dev_walker->of_node;
    dev_walker = dev_walker->parent;
} while (!of_node && dev_walker);

An alternative would be to assign the bus the same of_node as the bus 
parent.

If either approach works, you can add:
  Acked-by: David Daney <david.daney@cavium.com>

to the patch that implements it.

>
> In your case, you don't have a phy node in your device tree, so of_node
> is NULL. So it looks in the parent device.
>
>      phylib: Make PHYs children of their MDIO bus, not the bus' parent.
>
> changed what the parent is. It is now the mdio device. Before, i
> suspect it was the MAC. Hence it found your properties in the MAC
> node.
>
> What i think you might want to do is change this code. Rather than
> look a dev->parent->of_node; you might want
> phydev->attached_dev->dev->of_node.
>
> This assumes the phy has been attached to the MAC. I've no idea of the
> ordering, so maybe it has not been attached yet?
>
> dp83867.c has similar code. However quick grep did not find any
> mainline users with properties in the MAC node. If that is true, i
> would suggest removing the code looking in the parent for that phy
> driver.
>
> 	Andrew
>
