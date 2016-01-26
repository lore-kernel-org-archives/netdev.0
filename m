From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCH net] of: of_mdio: Ensure mdio device is a PHY
Date: Tue, 26 Jan 2016 18:36:51 +0200
Message-ID: <20160126163651.GM22974@ak-desktop.emea.nsn-net.net>
References: <1453817550-4770-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>, olof@lixom.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:34707 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966647AbcAZQg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 11:36:59 -0500
Content-Disposition: inline
In-Reply-To: <1453817550-4770-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 26, 2016 at 03:12:30PM +0100, Andrew Lunn wrote:
> of_phy_find_device() is used to find the phy device associated with a
> device node. It is expected the node is for a PHY device, but in fact
> it could of been probed as a generic MDIO device. Ensure the device is
> a PHY before returning it.
> 
> Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

This fixes the crash for me, so:

Tested-by: Aaro Koskinen <aaro.koskinen@nokia.com>

> ---
> 
> This is only 1/2 the fix. It will stop the NULL pointer dereference in
> the mutex code, but the Ethernet device probe is likely to return an
> error when it cannot find its PHY.

Yes, it's still not possible to actually use mgmt0:

$ ifconfig mgmt0 up
[   74.432849] octeon_mgmt 1070000100000.ethernet: Cannot initialize PHY on MIX0

A.

> ---
>  drivers/of/of_mdio.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 86829f8064a6..b5aa004a24b6 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -256,11 +256,19 @@ static int of_phy_match(struct device *dev, void *phy_np)
>  struct phy_device *of_phy_find_device(struct device_node *phy_np)
>  {
>  	struct device *d;
> +	struct mdio_device *mdiodev;
> +
>  	if (!phy_np)
>  		return NULL;
>  
>  	d = bus_find_device(&mdio_bus_type, NULL, phy_np, of_phy_match);
> -	return d ? to_phy_device(d) : NULL;
> +	if (d) {
> +		mdiodev = to_mdio_device(d);
> +		if (mdiodev->flags & MDIO_DEVICE_FLAG_PHY)
> +			return to_phy_device(d);
> +	}
> +
> +	return NULL;
>  }
>  EXPORT_SYMBOL(of_phy_find_device);
>  
> -- 
> 2.7.0
> 
