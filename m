From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v9 2/7] ixgbe: Add a new netdev op to allow/prevent
 a VF from querying an RSS info
Date: Sun, 29 Mar 2015 15:32:50 -0700
Message-ID: <55187D92.7070704@gmail.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-3-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36402 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbC2Wcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:32:52 -0400
Received: by padcy3 with SMTP id cy3so148693661pad.3
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 15:32:51 -0700 (PDT)
In-Reply-To: <1427645497-8339-3-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
> Implements the new netdev op to allow user to enable/disable the ability
> of a specific VF to query its RSS Indirection Table and an RSS Hash Key.
>
> This patch limits the new feature support to 82599 and x540 devices only.
> Support for other devices will be added later.
>
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 30 ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 40 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 42ed4b4..639aa1b 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -151,6 +151,7 @@ struct vf_data_storage {
>  	u16 tx_rate;
>  	u16 vlan_count;
>  	u8 spoofchk_enabled;
> +	bool rss_query_enabled;
>  	unsigned int vf_api;
>  };
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index a99bc5d..1b04cb1 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -3656,6 +3656,12 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
>  		if (hw->mac.ops.set_ethertype_anti_spoofing)
>  			hw->mac.ops.set_ethertype_anti_spoofing(hw, true, i);
>  	}
> +
> +	/* Enable/Disable RSS query feature  */
> +	for (i = 0; i < adapter->num_vfs; i++)
> +		ixgbe_ndo_set_vf_rss_query_en(adapter->netdev, i,
> +					      adapter->vfinfo[i].rss_query_enabled);
> +
>  }
>  
>  static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)

Instead of looking through the VFs twice you could probably look at
combining  this with the loop directly above it.
> @@ -8096,6 +8102,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
>  	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
>  	.ndo_set_vf_rate	= ixgbe_ndo_set_vf_bw,
>  	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
> +	.ndo_set_vf_rss_query_en = ixgbe_ndo_set_vf_rss_query_en,
>  	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
>  	.ndo_get_stats64	= ixgbe_get_stats64,
>  #ifdef CONFIG_IXGBE_DCB
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 09a291b..f08672a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -108,6 +108,15 @@ static int __ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
>  		/* enable spoof checking for all VFs */
>  		for (i = 0; i < adapter->num_vfs; i++)
>  			adapter->vfinfo[i].spoofchk_enabled = true;
> +
> +		/* We support VF RSS querying only for 82599 and x540 devices at
> +		 * the moment. These devices share RSS indirection table and
> +		 * RSS hash key with PF therefore we want to disable the
> +		 * querying by default.
> +		 */
> +		for (i = 0; i < adapter->num_vfs; i++)
> +			adapter->vfinfo[i].rss_query_enabled = 0;
> +
>  		return 0;
>  	}
>  

Same here, no point in looping through all the VFs twice, just take care
of sppofchk_enabled, and rss_query_enabled in one loop.

> @@ -1330,6 +1339,26 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
>  	return 0;
>  }
>  
> +int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
> +				  bool setting)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> +
> +	/* This operation is currently supported only for 82599 and x540
> +	 * devices.
> +	 */
> +	if (adapter->hw.mac.type < ixgbe_mac_82599EB ||
> +	    adapter->hw.mac.type >= ixgbe_mac_X550)
> +		return -EPERM;
> +

This should be not supported, not EPERM.

> +	if (vf >= adapter->num_vfs)
> +		return -EINVAL;
> +
> +	adapter->vfinfo[vf].rss_query_enabled = setting;
> +
> +	return 0;
> +}
> +
>  int ixgbe_ndo_get_vf_config(struct net_device *netdev,
>  			    int vf, struct ifla_vf_info *ivi)
>  {
> @@ -1343,5 +1372,6 @@ int ixgbe_ndo_get_vf_config(struct net_device *netdev,
>  	ivi->vlan = adapter->vfinfo[vf].pf_vlan;
>  	ivi->qos = adapter->vfinfo[vf].pf_qos;
>  	ivi->spoofchk = adapter->vfinfo[vf].spoofchk_enabled;
> +	ivi->rss_query_en = adapter->vfinfo[vf].rss_query_enabled;
>  	return 0;
>  }
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
> index 32c26d5..2c197e6 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
> @@ -47,6 +47,8 @@ int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
>  int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int min_tx_rate,
>  			int max_tx_rate);
>  int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
> +int ixgbe_ndo_set_vf_rss_query_en(struct net_device *netdev, int vf,
> +				  bool setting);
>  int ixgbe_ndo_get_vf_config(struct net_device *netdev,
>  			    int vf, struct ifla_vf_info *ivi);
>  void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
