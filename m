From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: new WIP version of au1000_eth.c phylib conversion (was Re: RFC: au1000_etc.c phylib rewrite)
Date: Mon, 8 May 2006 17:24:13 -0500
Message-ID: <6BF86C09-0732-4322-A43E-29705849886D@freescale.com>
References: <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <1146510542.16643.10.camel@localhost.localdomain> <1146510542.16643.10.camel@localhost.localdomain> <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3> <5.1.0.14.2.20060502095256.01fd4210@205.166.54.3> <1146674056.31241.18.camel@localhost.localdomain> <1146734223.31241.44.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Schank <mschank@dcbnet.com>, ppopov@embeddedalley.com,
	sshtylyov@ru.mvista.com, linux-mips@linux-mips.org,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	"Robin H. Johnson" <robbat2@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:29370 "EHLO
	az33egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1751329AbWEHWYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 18:24:35 -0400
In-Reply-To: <1146734223.31241.44.camel@localhost.localdomain>
To: Herbert Valerio Riedel <hvr@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 4, 2006, at 04:17, Herbert Valerio Riedel wrote:

> Hello,
>
> I've tried to adapt the PHY detection code to allow for dynamic  
> runtime
> configuration (with fallback to search for the 2nd MAC PHY on the 1st
> MAC's MII bus), as well as selectable static PHY configuration through
> Kconfig (e.g. for supporting PHYs w/o MII connection)

Comments inline, below:

> diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
> index 0823cb8..8c0b26f 100644
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -9,6 +9,9 @@

[snip]

> -/* FIXME
> - * All of the PHY code really should be detached from the MAC
> - * code.
> - */
> -

[snip]

Nothing to say so far, except seeing all those "-" signs was quite  
the thrill, since one of the goals of the phylib was to lead to  
reduced complexity.  That said, it looked like there were about a  
dozen PHY-specific code blocks in there.  I saw you submit one PHY  
driver.  Were there others in there that could be ported?

[snip]

> +static int mdiobus_read(struct mii_bus *bus, int phy_addr, int  
> regnum)
> {
> -	int i, val;
> +	struct net_device *const dev = bus->priv; /* beware: bus->phy_map 
> [phy_addr].attached_dev == dev does _NOT_ hold always  */
> +	enable_mac(dev, 0); /* make sure MAC associated with this mii_bus  
> is enabled */
> +	return mdio_read(dev, phy_addr, regnum);
> +}


Why is attached_dev not always correct?  I'm not sure if I'm not  
understanding the hardware (I'm unfamiliar with this NIC), or if  
you've misinterpreted the meaning of the attached_dev field.  It's  
supposed to be a connection between the network device and a PHY,  
mainly used for allowing the PHY to signal state changes back to the  
ethernet device.  Is it actually the case that there is one MAC being  
used for two PHYs at the same time?  If so, how do you resolve which  
PHY's state gets used at any given moment?

The same question applies for the code in mdiobus_write()

[snip]

> -static int mii_probe (struct net_device * dev)
> +static int mdiobus_reset(struct mii_bus *bus)
> {
> -	struct au1000_private *aup = (struct au1000_private *) dev->priv;
> -	int phy_addr;
> -#ifdef CONFIG_MIPS_BOSPORUS
> -	int phy_found=0;
> -#endif
> +	struct net_device *dev = bus->priv;
> -	/* search for total of 32 possible mii phy addresses */
> -	for (phy_addr = 0; phy_addr < 32; phy_addr++) {
> -		u16 mii_status;
> -		u16 phy_id0, phy_id1;
> -		int i;
> +	enable_mac(dev, 0); /* make sure MAC associated with this mii_bus  
> is enabled */
>

Do you need to call enable_mac() every time?  If it needs to be up,  
wouldn't it be easier to make sure it's up during bus initialization?

[snip]

> 	aup->mac->control = control;
> @@ -1685,57 +808,75 @@ static int au1000_init(struct net_device
>

[snip]

> +
> +	if (phydev->link && (aup->old_speed != phydev->speed)) {
> +		// speed changed
> +
> +		switch(phydev->speed) {
> +		case 10:
> +		case 100:
> +			break;
> +		default:
> +			printk(KERN_WARNING
> +			       "%s: Speed (%d) is not 10/100/1000 ??\n",
> +			       dev->name, phydev->speed);
> +			break;
> 		}


Might want to change that to be "...not 10/100..." or add a case for  
1000.

[snip]

> +	spin_unlock_irqrestore(&aup->lock, flags);
> +	if (status_change) {
> +		phy_print_status(phydev);
> +	}
> }


Stylistic issue (I've seen it a couple times, at least):  don't use  
"{" and "}" if your block only has one line.
ie:
	if (status_change)
		phy_print_status(phydev);



