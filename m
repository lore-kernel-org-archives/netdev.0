From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v9 7/7] ixgbevf: Add the appropriate ethtool
 ops to query RSS indirection table and key
Date: Sun, 29 Mar 2015 15:19:56 -0700
Message-ID: <55187A8C.5060607@gmail.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-8-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:32967 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbC2WT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:19:58 -0400
Received: by pdnc3 with SMTP id c3so155697144pdn.0
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 15:19:58 -0700 (PDT)
In-Reply-To: <1427645497-8339-8-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
> Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops callbacks
> implementations.
> 
> This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for VF devices.
> 
> This patch adds the support for 82599 and x540 devices only. Support for other
> devices will be added later.
> 
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v9:
>    - Use IXGBEVF_RSS_HASH_KEY_SIZE macro.
> 
> New in v6:
>    - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.
> 
> New in v4:
>    - Removed not needed braces in if-statement in ixgbevf_get_rxfh_indir_size().
> 
> New in v3:
>    - Added a proper support for x550 devices: return the correct redirection table size.
> 
> New in v2:
>    - Added a detailed description to the patch.
> ---
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c | 58 ++++++++++++++++++++++++++++
>  1 file changed, 58 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> index e83c85b..4d2f59f 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> @@ -794,6 +794,60 @@ static int ixgbevf_set_coalesce(struct net_device *netdev,
>  	return 0;
>  }
>  
> +static int ixgbevf_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
> +			     u32 *rules __always_unused)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(dev);
> +
> +	switch (info->cmd) {
> +	case ETHTOOL_GRXRINGS:
> +		info->data = adapter->num_rx_queues;
> +		return 0;
> +	default:
> +		hw_dbg(&adapter->hw, "Command parameters not supported\n");
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static u32 ixgbevf_get_rxfh_indir_size(struct net_device *netdev)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +
> +	if (adapter->hw.mac.type >= ixgbe_mac_X550_vf)
> +		return 64;
> +	else
> +		return 128;
> +}
> +

You should return 0 for x550, not 64 since it isn't supported.

My suggestion would be to alter the code so that you return 128 for
everything <= x540_vf, and place a return 0 as the default return
without a need for the if statement.

> +static u32 ixgbevf_get_rxfh_key_size(struct net_device *netdev)
> +{
> +	return IXGBEVF_RSS_HASH_KEY_SIZE;
> +}
> +

Same thing here.  If you don't support this on x550 you should probably
return 0 instead of returning a value.

> +static int ixgbevf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
> +			    u8 *hfunc)
> +{
> +	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
> +	int err;
> +
> +	if (hfunc)
> +		*hfunc = ETH_RSS_HASH_TOP;
> +
> +	if (indir) {
> +		err = ixgbevf_get_reta(adapter, indir);
> +		if (err)
> +			return err;
> +	}
> +
> +	if (key) {
> +		err = ixgbevf_get_rss_key(adapter, key);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +

My advice here would be to just wrap these two functions in one mailbox
lock and update the second check so that it is if (!err && key) so that
you can simplify the path and just return err at the end.

>  static const struct ethtool_ops ixgbevf_ethtool_ops = {
>  	.get_settings		= ixgbevf_get_settings,
>  	.get_drvinfo		= ixgbevf_get_drvinfo,
> @@ -811,6 +865,10 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
>  	.get_ethtool_stats	= ixgbevf_get_ethtool_stats,
>  	.get_coalesce		= ixgbevf_get_coalesce,
>  	.set_coalesce		= ixgbevf_set_coalesce,
> +	.get_rxnfc		= ixgbevf_get_rxnfc,
> +	.get_rxfh_indir_size	= ixgbevf_get_rxfh_indir_size,
> +	.get_rxfh_key_size	= ixgbevf_get_rxfh_key_size,
> +	.get_rxfh		= ixgbevf_get_rxfh,
>  };
>  
>  void ixgbevf_set_ethtool_ops(struct net_device *netdev)
> 
