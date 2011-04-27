From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 3/4] ethtool: Use the full 32 bit speed range in
 ethtool's set_settings
Date: Wed, 27 Apr 2011 20:27:57 +0100
Message-ID: <1303932477.2875.130.camel@bwh-desktop>
References: <1303001651-4074-1-git-send-email-decot@google.com>
	 <1303929290-21037-4-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303929290-21037-4-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 11:34 -0700, David Decotigny wrote:
> This makes sure the ethtool's set_settings() callback of network
> drivers don't ignore the 16 most significant bits when ethtool calls
> their set_settings().
> 
> All the driver compiled with make allyesconfig on x86_64 have been
> updated.
> 
> Signed-off-by: David Decotigny <decot@google.com>
[...]
> --- a/drivers/net/cxgb4/cxgb4_main.c
> +++ b/drivers/net/cxgb4/cxgb4_main.c
> @@ -1460,6 +1460,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	unsigned int cap;
>  	struct port_info *p = netdev_priv(dev);
>  	struct link_config *lc = &p->link_cfg;
> +	u32 speed = ethtool_cmd_speed(cmd);
>  
>  	if (cmd->duplex != DUPLEX_FULL)     /* only full-duplex supported */
>  		return -EINVAL;
> @@ -1470,16 +1471,16 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  		 * being requested.
>  		 */
>  		if (cmd->autoneg == AUTONEG_DISABLE &&
> -		    (lc->supported & speed_to_caps(cmd->speed)))
> -				return 0;
> +		    (lc->supported & speed_to_caps(speed)))
> +			return 0;
>  		return -EINVAL;
>  	}
>  
>  	if (cmd->autoneg == AUTONEG_DISABLE) {
> -		cap = speed_to_caps(cmd->speed);
> +		cap = speed_to_caps(speed);
>  
> -		if (!(lc->supported & cap) || cmd->speed == SPEED_1000 ||
> -		    cmd->speed == SPEED_10000)
> +		if (!(lc->supported & cap) || (speed == SPEED_1000) ||
> +		    (ethtool_cmd_speed(cmd) == SPEED_10000))

This second call to ethtool_cmd_speed() is unnecessary.

[...]
> diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
> index c05db60..ed3cb6a 100644
> --- a/drivers/net/dl2k.c
> +++ b/drivers/net/dl2k.c
> @@ -1219,31 +1219,26 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	} else {
>  		np->an_enable = 0;
>  		if (np->speed == 1000) {
> -			cmd->speed = SPEED_100;
> +			ethtool_cmd_speed_set(cmd, SPEED_100);
>  			cmd->duplex = DUPLEX_FULL;
>  			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, change to Manual 100Mbps, Full duplex.\n");

Ugh, this is totally bogus.  You don't have to fix it but it should
really be removed.

>  		}
> -		switch(cmd->speed + cmd->duplex) {
> +		switch (ethtool_cmd_speed(cmd)) {
>  
> -		case SPEED_10 + DUPLEX_HALF:
> +		case SPEED_10:
>  			np->speed = 10;
> -			np->full_duplex = 0;
> +			np->full_duplex = (cmd->duplex == DUPLEX_FULL) ? 1 : 0;

The '==' operator already yields 1 or 0, so don't use ?: as well.

>  			break;
>  
> -		case SPEED_10 + DUPLEX_FULL:
> -			np->speed = 10;
> -			np->full_duplex = 1;
> -			break;
> -		case SPEED_100 + DUPLEX_HALF:
> +		case SPEED_100:
>  			np->speed = 100;
> -			np->full_duplex = 0;
> +			np->full_duplex = (cmd->duplex == DUPLEX_FULL) ? 1 : 0;
>  			break;
> -		case SPEED_100 + DUPLEX_FULL:
> -			np->speed = 100;
> -			np->full_duplex = 1;
> +
> +		case SPEED_1000:
> +			/* handled above */

No it isn't; you're confusing cmd->speed and np-speed.  This should fall
through to the default case (or simply be removed).

[...]  
> diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
> index 2c37a38..66037b1 100644
> --- a/drivers/net/ksz884x.c
> +++ b/drivers/net/ksz884x.c
> @@ -5998,6 +5998,7 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	struct dev_priv *priv = netdev_priv(dev);
>  	struct dev_info *hw_priv = priv->adapter;
>  	struct ksz_port *port = &priv->port;
> +	u32 speed = ethtool_cmd_speed(cmd);
>  	int rc;
>  
>  	/*
> @@ -6006,11 +6007,11 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  	 */
>  	if (cmd->autoneg && priv->advertising == cmd->advertising) {
>  		cmd->advertising |= ADVERTISED_ALL;
> -		if (10 == cmd->speed)
> +		if (SPEED_10 == speed)
>  			cmd->advertising &=
>  				~(ADVERTISED_100baseT_Full |
>  				ADVERTISED_100baseT_Half);
> -		else if (100 == cmd->speed)
> +		else if (SPEED_100 == speed)
>  			cmd->advertising &=
>  				~(ADVERTISED_10baseT_Full |
>  				ADVERTISED_10baseT_Half);
> @@ -6032,8 +6033,8 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  		port->force_link = 0;
>  	} else {
>  		port->duplex = cmd->duplex + 1;
> -		if (cmd->speed != 1000)
> -			port->speed = cmd->speed;
> +		if (speed != SPEED_1000)
> +			port->speed = speed;
>  		if (cmd->autoneg)
>  			port->force_link = 0;
>  		else

There's no good reason for the SPEED macros, so please don't add uses.

[...] 
> diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> index c35d105..98587dc 100644
> --- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
> +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> @@ -109,12 +109,13 @@ static int pch_gbe_set_settings(struct net_device *netdev,
>  {
>  	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>  	struct pch_gbe_hw *hw = &adapter->hw;
> +	u32 speed = ethtool_cmd_speed(ecmd);
>  	int ret;
>  
>  	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
>  
> -	if (ecmd->speed == USHRT_MAX) {
> -		ecmd->speed = SPEED_1000;
> +	if (speed == USHRT_MAX) {

When the link is down, the driver reports speed = -1 (which is dumb, but
sadly common practice).  If the user changes some other setting but not
speed, then the driver will see speed == USHRT_MAX here, and this is
meant to allow for that.

This is fine so far, but your next change is going to break this because
the driver will set the high 16 bits of speed and then it will see speed
== UINT_MAX here.

[...]
> diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
> index b13c6b0..f8d26bf 100644
> --- a/drivers/net/tulip/de2104x.c
> +++ b/drivers/net/tulip/de2104x.c
> @@ -1549,10 +1549,11 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
>  {
>  	u32 new_media;
>  	unsigned int media_lock;
> +	u32 speed = ethtool_cmd_speed(ecmd);
>  
> -	if (ecmd->speed != SPEED_10 && ecmd->speed != 5 && ecmd->speed != 2)
> +	if (speed != SPEED_10 && speed != 5 && speed != 2)
>  		return -EINVAL;
> -	if (de->de21040 && ecmd->speed == 2)
> +	if (de->de21040 && speed == 2)
>  		return -EINVAL;
>  	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
>  		return -EINVAL;
[...]

This implementation is absolute crap - it's using speed values as
mnemonics for different physical ports!  Please change it to report and
accept only speed = 10.  (Both get_settings and set_settings have to be
changed at the same time.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
