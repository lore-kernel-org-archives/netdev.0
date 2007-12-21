From: "Medve Emilian" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH 2/2] phylib: add module owner to the mii_bus structure
Date: Fri, 21 Dec 2007 13:55:22 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E27018DF0C6@az33exm24.fsl.freescale.net>
References: <1198245451-13929-1-git-send-email-ionut.nicu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Nicu Ioan Petru" <ionut.nicu@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61725 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbXLUUzq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 15:55:46 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id lBLKtNIL013230
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 13:55:34 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id lBLKtN1H004988
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:55:23 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <1198245451-13929-1-git-send-email-ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Emil Medve <Emilian.Medve@Freescale.com>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Nicu Ioan Petru
> Sent: Friday, December 21, 2007 7:58 AM
> To: netdev@vger.kernel.org
> Cc: Nicu Ioan Petru
> Subject: [PATCH 2/2] phylib: add module owner to the mii_bus structure
> 
> Prevent unloading mii bus driver module when other modules 
> have references to some
> phydevs on that bus. Added a new member (module owner) to 
> struct mii_bus and added
> code to increment the mii bus owner module usage count on 
> phy_connect and decrement
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
> diff --git a/drivers/net/phy/phy_device.c 
> b/drivers/net/phy/phy_device.c
> index 5b9e175..7dc5480 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -178,6 +178,10 @@ struct phy_device * phy_connect(struct 
> net_device *dev, const char *phy_id,
>  	if (phydev->irq > 0)
>  		phy_start_interrupts(phydev);
>  
> +	/* Increment the usage count of the mii bus owner */
> +	if (!try_module_get(phydev->bus->owner))
> +		return ERR_PTR(-EFAULT);
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
> @@ -217,6 +217,9 @@ static int uec_mdio_probe(struct 
> of_device *ofdev, const struct of_device_id *ma
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
>  	int (*write)(struct mii_bus *bus, int phy_id, int 
> regnum, u16 val);
>  	int (*reset)(struct mii_bus *bus);
> -- 
> 1.5.4.rc0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
