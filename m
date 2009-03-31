From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Patch: Fix fec_mpc52xx driver to use net_device_ops
Date: Tue, 31 Mar 2009 07:48:06 -0700
Message-ID: <20090331074806.432a882a@nehalam>
References: <ae4f76fd0903310344s2d46edf2l505a1d21a4778d54@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Henk Stegeman <henk.stegeman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37291 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbZCaOsK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 10:48:10 -0400
In-Reply-To: <ae4f76fd0903310344s2d46edf2l505a1d21a4778d54@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Mar 2009 12:44:15 +0200
Henk Stegeman <henk.stegeman@gmail.com> wrote:

> Fix fec_mpc52xx driver to use net_device_ops and to be careful not to
> dereference phy_device if a phy has not yet been connected.
> 
> Signed-off-by: Henk Stegeman <henk.stegeman@gmail.com>
> 
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index cd8e98b..ca76b95 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -847,24 +847,40 @@ static void mpc52xx_fec_get_drvinfo(struct
> net_device *dev,
>  static int mpc52xx_fec_get_settings(struct net_device *dev, struct
> ethtool_cmd *cmd)
>  {
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->phydev)
> +			return -ENODEV;
> +
>  	return phy_ethtool_gset(priv->phydev, cmd);
>  }
> 
>  static int mpc52xx_fec_set_settings(struct net_device *dev, struct
> ethtool_cmd *cmd)
>  {
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->phydev)
> +			return -ENODEV;
> +
>  	return phy_ethtool_sset(priv->phydev, cmd);
>  }
> 
>  static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
>  {
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->phydev)
> +		return 0;
> +
>  	return priv->msg_enable;
>  }
> 
>  static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level)
>  {
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->phydev)
> +			return;
> +
>  	priv->msg_enable = level;
>  }
> 
> @@ -882,12 +898,31 @@ static int mpc52xx_fec_ioctl(struct net_device
> *dev, struct ifreq *rq, int cmd)
>  {
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> 
> +	if (!priv->phydev)
> +			return -ENODEV;
> +
>  	return mpc52xx_fec_phy_mii_ioctl(priv, if_mii(rq), cmd);
>  }
> 
>  /* ======================================================================== */
>  /* OF Driver                                                                */
>  /* ======================================================================== */
> +static const struct net_device_ops mpc52xx_fec_netdev_ops = {
> +       .ndo_open               = mpc52xx_fec_open,
> +       .ndo_stop               = mpc52xx_fec_close,
> +       .ndo_start_xmit         = mpc52xx_fec_hard_start_xmit,
> +       .ndo_tx_timeout         = mpc52xx_fec_tx_timeout,
> +       .ndo_get_stats          = mpc52xx_fec_get_stats,
> +       .ndo_set_multicast_list = mpc52xx_fec_set_multicast_list,
> +       .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_set_mac_address    = mpc52xx_fec_set_mac_address,
> +       .ndo_do_ioctl           = mpc52xx_fec_ioctl,
> 
What about change_mtu? Don't you want:
          .ndo_change_mtu         = eth_change_mtu,
