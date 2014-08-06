From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next v2 02/12] net: dsa: add Broadcom tag hook
Date: Wed, 06 Aug 2014 07:47:26 -0700
Message-ID: <53E23FFE.2090707@intel.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com> <1407277906-19989-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26328 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221AbaHFOrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 10:47:46 -0400
In-Reply-To: <1407277906-19989-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2014 03:31 PM, Florian Fainelli wrote:
> Register a fake Ethertype for the Broadcom tag to allow us to hook into
> a given Ethernet device receive path and parse this Broadcom tag.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/linux/netdevice.h     | 10 ++++++++++
>  include/net/dsa.h             |  5 +++++
>  include/uapi/linux/if_ether.h |  1 +
>  net/ethernet/eth.c            |  2 ++
>  4 files changed, 18 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 38377392d082..290b44ceefec 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1801,6 +1801,16 @@ static inline bool netdev_uses_trailer_tags(struct net_device *dev)
>  	return 0;
>  }
>  
> +static inline bool netdev_uses_brcm_tags(struct net_device *dev)
> +{
> +#ifdef CONFIG_NET_DSA_TAG_BRCM
> +	if (dev->dsa_ptr != NULL)
> +		return dsa_uses_brcm_tags(dev->dsa_ptr);
> +#endif
> +
> +	return 0;
> +}
> +
>  /**
>   *	netdev_priv - access network device private data
>   *	@dev: network device
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 6efce384451e..0ada9c814ff9 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -203,4 +203,9 @@ static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
>  	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
>  }
>  
> +static inline bool dsa_uses_brcm_tags(struct dsa_switch_tree *dst)
> +{
> +	return !!(dst->tag_protocol == htons(ETH_P_BRCMTAG));
> +}
> +
>  #endif
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 0f8210b8e0bc..2e9f13768abd 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -128,6 +128,7 @@
>  #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
>  #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
>  #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
> +#define ETH_P_BRCMTAG	0x00F8		/* Broadcom tag (4 bytes *)	*/
>  
>  /*
>   *	This is an Ethernet frame header.
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index f405e0592407..6b67653d5283 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -186,6 +186,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (unlikely(netdev_uses_trailer_tags(dev)))
>  		return htons(ETH_P_TRAILER);
> +	if (netdev_uses_brcm_tags(dev))
> +		return htons(ETH_P_BRCMTAG);
>  
>  	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
>  		return eth->h_proto;
> 

Maybe we should consider some change to this logic.  Maybe a bit flag in
the dsa_switch_tree structure that indicates if eth_type_trans should
override the protocol or not.  Otherwise this is going to start becoming
a rather large conditional statement if we have to add a new if every
time a new switch is added.

Thanks,

Alex
