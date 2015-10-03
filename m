From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: better error reporting
Date: Sat, 3 Oct 2015 21:27:11 +0200
Message-ID: <20151003192711.GF19778@lunn.ch>
References: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35157 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbbJCT1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 15:27:13 -0400
Content-Disposition: inline
In-Reply-To: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 03, 2015 at 06:09:07PM +0100, Russell King wrote:
> Add additional error reporting to the generic DSA code, so it's easier
> to debug when things go wrong.  This was useful when initially bringing
> up 88e6176 on a new board.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  net/dsa/dsa.c   |  4 ++--
>  net/dsa/slave.c | 24 ++++++++++++++++--------
>  2 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index c59fa5d9c22c..aa398bcef9e3 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -326,8 +326,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  
>  		ret = dsa_slave_create(ds, parent, i, pd->port_names[i]);
>  		if (ret < 0) {
> -			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s)\n",
> -				   index, i, pd->port_names[i]);
> +			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
> +				   index, i, pd->port_names[i], ret);
>  			ret = 0;
>  		}
>  	}
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index cce97385f743..115a3fda36b3 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1010,8 +1010,10 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
>  	struct dsa_switch *ds = p->parent;
>  
>  	p->phy = ds->slave_mii_bus->phy_map[addr];
> -	if (!p->phy)
> +	if (!p->phy) {
> +		netdev_err(slave_dev, "no phy at %d\n", addr);
>  		return -ENODEV;
> +	}
>  
>  	/* Use already configured phy mode */
>  	if (p->phy_interface == PHY_INTERFACE_MODE_NA)
> @@ -1045,7 +1047,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  		 */
>  		ret = of_phy_register_fixed_link(port_dn);
>  		if (ret) {
> -			netdev_err(slave_dev, "failed to register fixed PHY\n");
> +			netdev_err(slave_dev, "failed to register fixed PHY: %d\n", ret);
>  			return ret;
>  		}
>  		phy_is_fixed = true;
> @@ -1056,17 +1058,20 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  		phy_flags = ds->drv->get_phy_flags(ds, p->port);
>  
>  	if (phy_dn) {
> -		ret = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
> +		int phy_id = of_mdio_parse_addr(&slave_dev->dev, phy_dn);
> +
>  		/* If this PHY address is part of phys_mii_mask, which means
>  		 * that we need to divert reads and writes to/from it, then we
>  		 * want to bind this device using the slave MII bus created by
>  		 * DSA to make that happen.
>  		 */
> -		if (!phy_is_fixed && ret >= 0 &&
> -		    (ds->phys_mii_mask & (1 << ret))) {
> -			ret = dsa_slave_phy_connect(p, slave_dev, ret);
> -			if (ret)
> +		if (!phy_is_fixed && phy_id >= 0 &&
> +		    (ds->phys_mii_mask & (1 << phy_id))) {
> +			ret = dsa_slave_phy_connect(p, slave_dev, phy_id);
> +			if (ret) {
> +				netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
>  				return ret;
> +			}
>  		} else {
>  			p->phy = of_phy_connect(slave_dev, phy_dn,
>  						dsa_slave_adjust_link,
> @@ -1083,8 +1088,10 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  	 */
>  	if (!p->phy) {
>  		ret = dsa_slave_phy_connect(p, slave_dev, p->port);
> -		if (ret)
> +		if (ret) {
> +			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
>  			return ret;
> +		}
>  	} else {
>  		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
>  			    p->phy->addr, p->phy->drv->name);
> @@ -1195,6 +1202,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  
>  	ret = dsa_slave_phy_setup(p, slave_dev);
>  	if (ret) {
> +		netdev_err(master, "error %d setting up slave phy\n", ret);
>  		free_netdev(slave_dev);
>  		return ret;
>  	}
> -- 
> 2.1.0
> 
