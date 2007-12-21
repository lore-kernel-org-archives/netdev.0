From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] phylib: add module owner to the mii_bus structure
Date: Fri, 21 Dec 2007 15:37:13 -0800
Message-ID: <20071221153713.641f010e@deepthought>
References: <1198245451-13929-1-git-send-email-ionut.nicu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:43112 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbXLVApc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 19:45:32 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J5sH4-0004sX-0G
	for netdev@vger.kernel.org; Sat, 22 Dec 2007 00:31:30 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2007 00:31:29 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2007 00:31:29 +0000
In-Reply-To: <1198245451-13929-1-git-send-email-ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007 15:57:31 +0200
Ionut Nicu <ionut.nicu@freescale.com> wrote:

> Prevent unloading mii bus driver module when other modules have references to some
> phydevs on that bus. Added a new member (module owner) to struct mii_bus and added
> code to increment the mii bus owner module usage count on phy_connect and decrement
> it on phy_disconnect
> 
> Set the module owner in the ucc_geth_mdio driver.
> 
> Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
> ---
>  drivers/net/phy/phy_device.c |    9 ++++++++-
>  drivers/net/ucc_geth_mii.c   |    3 +++
>  include/linux/phy.h          |    4 ++++
>  3 files changed, 15 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 5b9e175..7dc5480 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -178,6 +178,10 @@ struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
>  	if (phydev->irq > 0)
>  		phy_start_interrupts(phydev);
>  
> +	/* Increment the usage count of the mii bus owner */
> +	if (!try_module_get(phydev->bus->owner))
> +		return ERR_PTR(-EFAULT);

Shouldn't you get a handle before the first usage (start_interrupts)?

> +
>  	return phydev;
>  }
>  EXPORT_SYMBOL(phy_connect);
> @@ -192,9 +196,12 @@ void phy_disconnect(struct phy_device *phydev)
>  		phy_stop_interrupts(phydev);
>  
>  	phy_stop_machine(phydev);
> -	
> +
>  	phydev->adjust_link = NULL;
>  
> +	/* Decrement the reference count for the mii bus owner */
> +	module_put(phydev->bus->owner);
> +
>  	phy_detach(phydev);
>  }
>  EXPORT_SYMBOL(phy_disconnect);
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index a3af4ea..84c7295 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -217,6 +217,9 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
>  		}
>  	}
>  
> +	/* register ourselves as the owner of this bus */
> +	new_bus->owner = THIS_MODULE;
> +
>  	err = mdiobus_register(new_bus);
>  	if (0 != err) {
>  		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 554836e..04ff6a5 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -82,6 +82,10 @@ struct mii_bus {
>  	const char *name;
>  	int id;
>  	void *priv;
> +
> +	/* The module that owns this bus */
> +	struct module *owner;
> +
>  	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
>  	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
>  	int (*reset)(struct mii_bus *bus);


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

