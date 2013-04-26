From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 2/7] qlcnic: Fix bug in tuning offloads using QLogic
 application
Date: Fri, 26 Apr 2013 21:54:25 +0100
Message-ID: <1367009665.4035.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1366978183-7282-3-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13735 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab3DZUyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 16:54:33 -0400
In-Reply-To: <1366978183-7282-3-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-26 at 08:09 -0400, Shahed Shaikh wrote:
> From: Manish Chopra <manish.chopra@qlogic.com>
> 
> o LRO was not getting disabled when disabling checksum offloads
>   using QLogic application.
> o LRO was not getting re-enabled while enabling checksum offloads
>   back
[...]
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -975,7 +975,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
>  		struct qlcnic_esw_func_cfg *esw_cfg)
>  {
>  	struct net_device *netdev = adapter->netdev;
> -	unsigned long features, vlan_features;
> +	netdev_features_t features, vlan_features;
>  
>  	if (qlcnic_83xx_check(adapter))
>  		return;
> @@ -994,8 +994,14 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
>  		features |= NETIF_F_LRO;
>  
>  	if (esw_cfg->offload_flags & BIT_0) {
> -		netdev->features |= features;
>  		adapter->rx_csum = 1;
> +		if (adapter->flags & QLCNIC_LRO_WAS_ENABLED) {
> +			if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_ENABLED))
> +				return;
> +			netdev_info(netdev, "Enabling LRO as Rx checksum is on\n");
> +			netdev->features |= NETIF_F_LRO;
> +		}
[...]

This is absolutely wrong for mainline Linux.  The networking core keeps
track of whether the user wanted a feature enabled in
netdev->wanted_features.  You must not try to manage this yourself.

The proper thing to do is to implement ndo_fix_features and mask out
NETIF_F_LRO there whenever it depends on another feature that has been
disabled.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
