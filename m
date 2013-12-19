From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 05/15] i40e: add set settings and pauseparam
Date: Thu, 19 Dec 2013 20:42:23 +0000
Message-ID: <1387485743.1876.51.camel@bwh-desktop.uk.level5networks.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387434891-19719-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Shannon Nelson <shannon.nelson@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17604 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374Ab3LSUm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:42:28 -0500
In-Reply-To: <1387434891-19719-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 22:34 -0800, Jeff Kirsher wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> This implements the set_settings and set_pauseparam ethtool
> functionality.
> 
> Change-Id: I4634ee2c8bce00204edac7df9f0af4fb7bf33b75
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 97 ++++++++++++++++++++++++++
>  1 file changed, 97 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index 255a138..a12dd01 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -261,6 +261,61 @@ static int i40e_get_settings(struct net_device *netdev,
>  }
>  
>  /**
> + * i40e_set_settings - Set Speed and Duplex
> + * @netdev: network interface device structure
> + * @ecmd: ethtool command
> + *
> + * Set speed/duplex per media_types advertised/forced
> + **/
> +static int i40e_set_settings(struct net_device *netdev,
> +			     struct ethtool_cmd *ecmd)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_pf *pf = np->vsi->back;
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_hw *hw = &pf->hw;
> +	u32 old_link, advertised;
> +	int err = 0;
> +
> +	if (vsi != pf->vsi[pf->lan_vsi])
> +		return -EOPNOTSUPP;
> +
> +	while (test_and_set_bit(__I40E_CONFIG_BUSY, &vsi->state))
> +		usleep_range(1000, 2000);
> +
> +	if ((hw->phy.media_type == I40E_MEDIA_TYPE_BASET) ||
> +	    (hw->phy.media_type == I40E_MEDIA_TYPE_FIBER)) {
> +		if (ecmd->autoneg == AUTONEG_DISABLE)
> +			goto clear_reset;

So if the media_type is not one of the above, or ecmd->autoneg is
AUTONEG_DISABLE, this returns success even though it hasn't done
anything.  This can't be right.

> +		if (ecmd->advertising & ~ecmd->supported)
> +			goto clear_reset;

You can't trust ecmd->supported.  And again this is returning success.

> +		old_link = hw->phy.autoneg_advertised;
> +		advertised = 0;
> +
> +		if (ecmd->advertising & (ADVERTISED_40000baseCR4_Full |
> +					 ADVERTISED_40000baseKR4_Full |
> +					 ADVERTISED_40000baseSR4_Full |
> +					 ADVERTISED_40000baseLR4_Full))
> +			advertised |= I40E_LINK_SPEED_40GB;
> +		if (ecmd->advertising & (ADVERTISED_10000baseKX4_Full |
> +					 ADVERTISED_10000baseKR_Full |
> +					 ADVERTISED_10000baseT_Full))
> +			advertised |= I40E_LINK_SPEED_10GB;
> +		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
> +			advertised |= I40E_LINK_SPEED_1GB;
> +		if (old_link == advertised) {
> +			err = 0;

Hmm... so maybe err was meant to be initialised to -EINVAL above?

[...]
> +/**
> + * i40e_set_pauseparam - Set Flow Control parameter
> + * @netdev: network interface device structure
> + * @pause: return tx/rx flow control status
> + **/
> +static int i40e_set_pauseparam(struct net_device *netdev,
> +			       struct ethtool_pauseparam *pause)
[...]
> +	/* if the status changed, then we will use updated autoneg*/
> +	if (memcmp(&fc, &hw->fc, sizeof(struct i40e_fc_info)))
> +		hw->fc = fc;
[...]

Why bother with the memcmp()?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
