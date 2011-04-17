From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] ethtool: Call ethtool's get/set_settings callbacks
 with cleaned data
Date: Sun, 17 Apr 2011 02:53:14 +0100
Message-ID: <1303005194.5282.904.camel@localhost>
References: <1303001651-4074-1-git-send-email-decot@google.com>
	 <1303001651-4074-3-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	ilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34025 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab1DQBxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 21:53:19 -0400
In-Reply-To: <1303001651-4074-3-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-04-16 at 17:54 -0700, David Decotigny wrote:
> This makes sure that when a driver calls the ethtool's
> get/set_settings() callback of another driver,

Many of them are calling themselves, and they can ignore speed_hi
because they will never set it.

> the data passed to it
> is clean. This guarantees that speed_hi will be zeroed correctly if
> the called callback doesn't explicitely set it: we are sure we don't
> get a corrupted speed from the underlying driver. We also take care of
> setting the cmd field appropriately (ETHTOOL_GSET/SSET).

I think this initialisation ought to be done in
dev_ethtool_get_settings(), and that function moved into net/core/dev.c,
to avoid code bloat.  (Yes it's minimal in this case, but these things
add up.)

Maybe also in mii_ethtool_gset().

> All drivers visible to make allyesconfig under x86_64 have been
> updated.
>
> Tested: make allyesconfig compiles + e1000 & bnx2x work
> 
> Signed-off-by: David Decotigny <decot@google.com>
> ---
>  arch/mips/txx9/generic/setup_tx4939.c |   15 ++++--------
>  drivers/net/e100.c                    |   10 +++++---
>  drivers/net/pch_gbe/pch_gbe_main.c    |    6 ++--
>  drivers/net/pch_gbe/pch_gbe_phy.c     |    2 +-
>  drivers/net/pcnet32.c                 |   15 ++++++-----
>  drivers/net/sfc/mdio_10g.c            |    4 +-
>  drivers/net/stmmac/stmmac_ethtool.c   |    4 +-
>  drivers/net/usb/asix.c                |   28 ++++++++++++----------
>  drivers/net/usb/dm9601.c              |    6 ++--
>  drivers/net/usb/smsc75xx.c            |    7 +++--
>  drivers/net/usb/smsc95xx.c            |    7 +++--
>  drivers/scsi/bnx2fc/bnx2fc_fcoe.c     |   36 +++++++++++++++++------------
>  drivers/scsi/fcoe/fcoe.c              |   41 ++++++++++++++++++--------------
>  include/rdma/ib_addr.h                |   15 ++++++-----
>  net/core/net-sysfs.c                  |   24 ++++++++-----------
>  15 files changed, 115 insertions(+), 105 deletions(-)
> 
> diff --git a/arch/mips/txx9/generic/setup_tx4939.c b/arch/mips/txx9/generic/setup_tx4939.c
> index 3dc19f4..af0588f 100644
> --- a/arch/mips/txx9/generic/setup_tx4939.c
> +++ b/arch/mips/txx9/generic/setup_tx4939.c
> @@ -320,16 +320,11 @@ void __init tx4939_sio_init(unsigned int sclk, unsigned int cts_mask)
>  #if defined(CONFIG_TC35815) || defined(CONFIG_TC35815_MODULE)
>  static int tx4939_get_eth_speed(struct net_device *dev)
>  {
> -	struct ethtool_cmd cmd = { ETHTOOL_GSET };
> -	int speed = 100;	/* default 100Mbps */
> -	int err;
> -	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
> -		return speed;
> -	err = dev->ethtool_ops->get_settings(dev, &cmd);
> -	if (err < 0)
> -		return speed;
> -	speed = cmd.speed == SPEED_100 ? 100 : 10;
> -	return speed;
> +	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
> +	if (dev_ethtool_get_settings(dev, &cmd))
> +		return 100;	/* default 100Mbps */
> +
> +	return (ethtool_cmd_speed(&cmd) == SPEED_100 ? 100 : 10);

If you're going to rewrite the whole function then at least get rid of
this stupid conditional and return ethtool_cmd_speed(&cmd).

>  }
>  static int tx4939_netdev_event(struct notifier_block *this,
>  			       unsigned long event,
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index b0aa9e6..c810cda 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c

e100 is just getting its own settings and doesn't need to be changed.

[...]
> diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
> index 2ef2f9c..7d4452e 100644
> --- a/drivers/net/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/pch_gbe/pch_gbe_main.c

Ditto pch_gbe.

[...] 
> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> index 0a1efba..07398bc 100644
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -2099,7 +2099,7 @@ static int pcnet32_open(struct net_device *dev)
>  		int first_phy = -1;
>  		u16 bmcr;
>  		u32 bcr9;
> -		struct ethtool_cmd ecmd;
> +		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
>  
>  		/*
>  		 * There is really no good other way to handle multiple PHYs
> @@ -2115,9 +2115,9 @@ static int pcnet32_open(struct net_device *dev)
>  			ecmd.port = PORT_MII;
>  			ecmd.transceiver = XCVR_INTERNAL;
>  			ecmd.autoneg = AUTONEG_DISABLE;
> -			ecmd.speed =
> -			    lp->
> -			    options & PCNET32_PORT_100 ? SPEED_100 : SPEED_10;
> +			ethtool_cmd_speed_set(&ecmd,
> +					      (lp->options & PCNET32_PORT_100) ?
> +					      SPEED_100 : SPEED_10);
>  			bcr9 = lp->a.read_bcr(ioaddr, 9);
>  
>  			if (lp->options & PCNET32_PORT_FD) {
> @@ -2763,11 +2763,12 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
>  		netif_carrier_on(dev);
>  		if (lp->mii) {
>  			if (netif_msg_link(lp)) {
> -				struct ethtool_cmd ecmd;
> +				struct ethtool_cmd ecmd = {
> +					.cmd = ETHTOOL_GSET };
>  				mii_ethtool_gset(&lp->mii_if, &ecmd);
>  				netdev_info(dev, "link up, %sMbps, %s-duplex\n",
> -					    (ecmd.speed == SPEED_100)
> -					    ? "100" : "10",
> +					    (ethtool_cmd_speed(&ecmd)
> +					     == SPEED_100) ? "100" : "10",

Just use ethtool_cmd_speed() and %u rather than this conditional.

>  					    (ecmd.duplex == DUPLEX_FULL)
>  					    ? "full" : "half");
>  			}
> diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
> index 19e68c2..7115914 100644
> --- a/drivers/net/sfc/mdio_10g.c
> +++ b/drivers/net/sfc/mdio_10g.c
> @@ -232,12 +232,12 @@ void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
>   */
>  int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
>  {
> -	struct ethtool_cmd prev;
> +	struct ethtool_cmd prev = { .cmd = ETHTOOL_GSET };
>  
>  	efx->phy_op->get_settings(efx, &prev);
>  
>  	if (ecmd->advertising == prev.advertising &&
> -	    ecmd->speed == prev.speed &&
> +	    ethtool_cmd_speed(ecmd) == ethtool_cmd_speed(&prev) &&
>  	    ecmd->duplex == prev.duplex &&
>  	    ecmd->port == prev.port &&
>  	    ecmd->autoneg == prev.autoneg)

That looks correct.

> diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
> index 0e61ac8..33cf0b1 100644
> --- a/drivers/net/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/stmmac/stmmac_ethtool.c
> @@ -237,13 +237,13 @@ stmmac_set_pauseparam(struct net_device *netdev,
>  
>  	if (phy->autoneg) {
>  		if (netif_running(netdev)) {
> -			struct ethtool_cmd cmd;
> +			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
>  			/* auto-negotiation automatically restarted */
>  			cmd.cmd = ETHTOOL_NWAY_RST;

This line immediately changes cmd.cmd.  The original author is clearly
confused, as the phy_ethtool_sset() ignores cmd.cmd and ETHTOOL_NWAY_RST
does not take any parameters.

I think this whole block should really just be:

			ret = phy_start_aneg(phy);

[...]
> diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> index e2e6475..6df9540 100644
> --- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> +++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> @@ -664,22 +664,28 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
>  	struct fcoe_port *port = lport_priv(lport);
>  	struct bnx2fc_hba *hba = port->priv;
>  	struct net_device *netdev = hba->netdev;
> -	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
> -
> -	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
> -		lport->link_supported_speeds &=
> -			~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
> -		if (ecmd.supported & (SUPPORTED_1000baseT_Half |
> -				      SUPPORTED_1000baseT_Full))
> -			lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
> -		if (ecmd.supported & SUPPORTED_10000baseT_Full)
> -			lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
> -
> -		if (ecmd.speed == SPEED_1000)
> -			lport->link_speed = FC_PORTSPEED_1GBIT;
> -		if (ecmd.speed == SPEED_10000)
> -			lport->link_speed = FC_PORTSPEED_10GBIT;
> +	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
> +
> +	if (dev_ethtool_get_settings(netdev, &ecmd))
> +		return;
> +
> +	lport->link_supported_speeds &=
> +		~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
> +	if (ecmd.supported & (SUPPORTED_1000baseT_Half |
> +			      SUPPORTED_1000baseT_Full))
> +		lport->link_supported_speeds |= FC_PORTSPEED_1GBIT;
> +	if (ecmd.supported & SUPPORTED_10000baseT_Full)
> +		lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
> +
> +	switch (ethtool_cmd_speed(&ecmd)) {
> +	case SPEED_1000:
> +		lport->link_speed = FC_PORTSPEED_1GBIT;
> +		break;
> +	case SPEED_10000:
> +		lport->link_speed = FC_PORTSPEED_10GBIT;
> +		break;
>  	}
> +
>  	return;
>  }
>  static int bnx2fc_link_ok(struct fc_lport *lport)

This restructuring looks entirely unnecessary, and obscures the real
change being made.

> diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
> index bde6ee5..ba9e84a 100644
> --- a/drivers/scsi/fcoe/fcoe.c
> +++ b/drivers/scsi/fcoe/fcoe.c
> @@ -2026,25 +2026,30 @@ out_nodev:
>  int fcoe_link_speed_update(struct fc_lport *lport)
>  {
[...]

Ditto here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

