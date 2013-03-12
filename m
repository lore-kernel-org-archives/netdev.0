From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] mv643xx_eth with 88E1318S: support Wake on
 LAN
Date: Tue, 12 Mar 2013 06:59:47 +0100
Message-ID: <20130312055947.GP21478@lunn.ch>
References: <1363045162-16606-1-git-send-email-michael@stapelberg.de>
 <1363045162-16606-2-git-send-email-michael@stapelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Michael Stapelberg <michael@stapelberg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:56405 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601Ab3CLGAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 02:00:24 -0400
Content-Disposition: inline
In-Reply-To: <1363045162-16606-2-git-send-email-michael@stapelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 12:39:22AM +0100, Michael Stapelberg wrote:
> This has been tested on a qnap TS-119P II. Note that enabling WOL with
> "ethtool -s eth0 wol g" is not enough; you also need to tell the PIC
> microcontroller inside the qnap that WOL should be enabled by sending
> 0xF2 with qcontrol(1) and you have to disable EUP ("Energy-using
> Products", a European power-saving thing) by sending 0xF4.
> 
> Signed-off-by: Michael Stapelberg <michael@stapelberg.de>
> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c |   32 +++++++
>  drivers/net/phy/marvell.c                  |  127 ++++++++++++++++++++++++++++
>  2 files changed, 159 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index 2914050..64a405e 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -20,6 +20,8 @@
>   * Copyright (C) 2007-2008 Marvell Semiconductor
>   *			   Lennert Buytenhek <buytenh@marvell.com>
>   *
> + * Copyright (C) 2013 Michael Stapelberg <michael@stapelberg.de>
> + *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU General Public License
>   * as published by the Free Software Foundation; either version 2
> @@ -1484,6 +1486,34 @@ mv643xx_eth_get_settings_phyless(struct mv643xx_eth_private *mp,
>  	return 0;
>  }
>  
> +static void
> +mv643xx_eth_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	struct mv643xx_eth_private *mp = netdev_priv(dev);
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +	if (mp->phy)
> +		phy_ethtool_get_wol(mp->phy, wol);
> +}
> +
> +static int
> +mv643xx_eth_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	struct mv643xx_eth_private *mp = netdev_priv(dev);
> +	int err;
> +
> +	if (mp->phy == NULL)
> +		return -EOPNOTSUPP;
> +
> +	err = phy_ethtool_set_wol(mp->phy, wol);
> +	/* Given that mv643xx_eth works without the marvell-specific PHY driver,
> +	 * this debugging hint is useful to have.
> +	 */
> +	if (err == -EOPNOTSUPP)
> +		netdev_info(dev, "The PHY does not support set_wol, was CONFIG_MARVELL_PHY enabled?\n");
> +	return err;

Hi Michael

I would not have this netdev_info() message. Only a few boxes are
going to have a PHY with this capability, so printing when it does not
is rather annoying. Either just return the error code, or make it a
netdev_dbg().

      Andrew
