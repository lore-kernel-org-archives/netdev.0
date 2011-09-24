From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 05/10] if_link: Add additional parameter to
 IFLA_VF_INFO for spoof checking
Date: Sat, 24 Sep 2011 17:40:56 +0100
Message-ID: <1316882459.4122.83.camel@deadeye>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26526 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab1IXQlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2011 12:41:07 -0400
In-Reply-To: <1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-09-24 at 02:17 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add configuration setting for drivers to turn spoof checking on or off
> for discrete VFs.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  include/linux/if_link.h   |    7 +++++++
>  include/linux/netdevice.h |    3 +++
>  net/core/rtnetlink.c      |   25 ++++++++++++++++++++++---
>  3 files changed, 32 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 0ee969a..8bd6d6d 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -279,6 +279,7 @@ enum {
>  	IFLA_VF_MAC,		/* Hardware queue specific attributes */
>  	IFLA_VF_VLAN,
>  	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> +	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
>  	__IFLA_VF_MAX,
>  };
>  
> @@ -300,12 +301,18 @@ struct ifla_vf_tx_rate {
>  	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
>  };
>  
> +struct ifla_vf_spoofchk {
> +	__u32 vf;
> +	__u32 setting;
> +};
> +
>  struct ifla_vf_info {
>  	__u32 vf;
>  	__u8 mac[32];
>  	__u32 vlan;
>  	__u32 qos;
>  	__u32 tx_rate;
> +	__u32 spoofchk;
>  };

Not something you need to change now, but shouldn't this last struct
definition be #ifdef __KERNEL__?

>  /* VF ports management section
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 43b3298..a2951a0 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -781,6 +781,7 @@ struct netdev_tc_txq {
>   * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
>   * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
>   * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
> + * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, u8 setting);
>   * int (*ndo_get_vf_config)(struct net_device *dev,
>   *			    int vf, struct ifla_vf_info *ivf);
>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
> @@ -900,6 +901,8 @@ struct net_device_ops {
>  						   int queue, u16 vlan, u8 qos);
>  	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
>  						      int vf, int rate);
> +	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
> +						       int vf, u8 setting);

Why u8 and not bool?

>  	int			(*ndo_get_vf_config)(struct net_device *dev,
>  						     int vf,
>  						     struct ifla_vf_info *ivf);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 39f8dd6..6535810 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -731,7 +731,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
>  		size += num_vfs *
>  			(nla_total_size(sizeof(struct ifla_vf_mac)) +
>  			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
> -			 nla_total_size(sizeof(struct ifla_vf_tx_rate)));
> +			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
> +			 nla_total_size(sizeof(struct ifla_vf_spoofchk)));
>  		return size;
>  	} else
>  		return 0;
> @@ -954,13 +955,19 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			struct ifla_vf_mac vf_mac;
>  			struct ifla_vf_vlan vf_vlan;
>  			struct ifla_vf_tx_rate vf_tx_rate;
> +			struct ifla_vf_spoofchk vf_spoofchk;
>  			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
>  				break;
> -			vf_mac.vf = vf_vlan.vf = vf_tx_rate.vf = ivi.vf;
> +			vf_mac.vf =
> +			vf_vlan.vf =
> +			vf_tx_rate.vf =
> +			vf_spoofchk.vf = ivi.vf;
> +
[...]

The continuation lines should be indented.  Or you could just write the
assignments as multiple statements.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
