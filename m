From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 2/3] phylib: move to dynamic allocation of struct mii_bus
Date: Mon, 29 Sep 2008 16:31:24 -0500
Message-ID: <3586F2DA-EF30-41CE-82F4-1AE514C3C7CD@freescale.com>
References: <20080929021342.GD21560@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61741 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922AbYI2Vbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 17:31:50 -0400
In-Reply-To: <20080929021342.GD21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 28, 2008, at 21:13, Lennert Buytenhek wrote:

> This patch introduces mdiobus_alloc() and mdiobus_free(), and
> makes all mdio bus drivers use these functions to allocate their
> struct mii_bus'es dynamically.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
> drivers/net/au1000_eth.c          |   43 +++++++++++++++---------
> drivers/net/au1000_eth.h          |    2 +-
> drivers/net/bfin_mac.c            |   31 ++++++++++-------
> drivers/net/bfin_mac.h            |    2 +-
> drivers/net/cpmac.c               |   51 +++++++++++++++++------------
> drivers/net/fec_mpc52xx_phy.c     |    6 ++--
> drivers/net/fs_enet/mii-bitbang.c |    7 ++--
> drivers/net/fs_enet/mii-fec.c     |    6 ++--
> drivers/net/gianfar_mii.c         |    7 ++--
> drivers/net/macb.c                |   49 ++++++++++++++++-----------
> drivers/net/macb.h                |    2 +-
> drivers/net/mv643xx_eth.c         |   32 +++++++++++-------
> drivers/net/phy/fixed.c           |   29 ++++++++++-----
> drivers/net/phy/mdio-bitbang.c    |    6 +--
> drivers/net/phy/mdio-ofgpio.c     |    9 ++---
> drivers/net/phy/mdio_bus.c        |   24 +++++++++++++
> drivers/net/sb1250-mac.c          |   36 ++++++++++++--------
> drivers/net/sh_eth.c              |    2 +-
> drivers/net/tc35815.c             |   45 +++++++++++++++----------
> drivers/net/tg3.c                 |   66 ++++++++++++++++++ 
> +------------------
> drivers/net/tg3.h                 |    2 +-
> drivers/net/ucc_geth_mii.c        |    7 ++--
> include/linux/phy.h               |    2 +
> 23 files changed, 279 insertions(+), 187 deletions(-)


Hrm.  I know this is to set up for your next patch, which does  
something with mdiobus_alloc(), but this patch creates an abstraction  
which actually increases the total amount of code.  I'm not quite sure  
the following patch provides additional functionality that justifies  
abstracting kzalloc.

What is the motivation for doing this?  Is it necessary to make the  
bus dynamically allocated for the device layer to function properly?

A few more comments below:



> +	if (aup->mii_bus != NULL) {
> +		mdiobus_unregister(aup->mii_bus);
> +		mdiobus_free(aup->mii_bus);

Should we consider merging free and unregister, since they seem like  
they'd be called together every time.


>
> @@ -231,12 +231,11 @@ static int fs_enet_mdio_remove(struct  
> of_device *ofdev)
> 	struct bb_info *bitbang = bus->priv;
>
> 	mdiobus_unregister(bus);
> -	free_mdio_bitbang(bus);
> 	dev_set_drvdata(&ofdev->dev, NULL);
> 	kfree(bus->irq);
> +	free_mdio_bitbang(bus);
> 	iounmap(bitbang->dir);
> 	kfree(bitbang);
> -	kfree(bus);
>
> 	return 0;
> }

Hm.  Was the original kfree(bus) a bug?  It looks like  
free_mdio_bitbang was doing that, anyway...

If not, why don't we need an mdiobus_free() here?



> --- a/drivers/net/phy/mdio-bitbang.c
> +++ b/drivers/net/phy/mdio-bitbang.c
> @@ -165,9 +165,7 @@ struct mii_bus *alloc_mdio_bitbang(struct  
> mdiobb_ctrl *ctrl)
> {
> 	struct mii_bus *bus;
>
> -	bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
> -	if (!bus)
> -		return NULL;
> +	bus = mdiobus_alloc();


I think you removed the error checking, here.



> @@ -168,11 +168,10 @@ static int mdio_ofgpio_remove(struct of_device  
> *ofdev)
> 	struct mdio_gpio_info *bitbang = bus->priv;
>
> 	mdiobus_unregister(bus);
> +	kfree(bus->irq);
> 	free_mdio_bitbang(bus);
> 	dev_set_drvdata(&ofdev->dev, NULL);
> -	kfree(bus->irq);
> 	kfree(bitbang);
> -	kfree(bus);


Same question here as the previous free_mdio_bitbang() invocation.




