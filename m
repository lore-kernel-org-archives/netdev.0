From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: Move check for multiple vlans to
 drivers
Date: Thu, 26 Mar 2015 04:55:36 -0700
Message-ID: <1427370936.25985.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1427346080-12086-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Linux NICS <linux.nics@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37819 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbbCZLzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:55:38 -0400
Received: by igcxg11 with SMTP id xg11so51444529igc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 04:55:38 -0700 (PDT)
In-Reply-To: <1427346080-12086-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 14:01 +0900, Toshiaki Makita wrote:
> To allow drivers to handle the features check for multiple tags,
> move the check to ndo_features_check().
> As no drivers currently handle multiple tagged TSO, introduce
> dflt_features_check() and call it if the driver does not have
> ndo_features_check().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---


> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index bc649dd..5ceb38f 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -606,4 +606,26 @@ static inline bool skb_vlan_tagged_multi(struct sk_buff *skb)
>  	return true;
>  }
>  
> +/**
> + * vlan_features_check - drop unsafe features for skb with multiple tags.
> + * @skb: skbuff to query
> + * @features: features to be checked
> + *
> + * Returns features without unsafe ones if the skb has multiple tags.
> + */
> +static inline netdev_features_t vlan_features_check(struct sk_buff *skb,

const struct sk_buff *skb

> +						    netdev_features_t features)
> +{
> +	if (skb_vlan_tagged_multi(skb))
> +		features = netdev_intersect_features(features,
> +						     NETIF_F_SG |
> +						     NETIF_F_HIGHDMA |
> +						     NETIF_F_FRAGLIST |
> +						     NETIF_F_GEN_CSUM |
> +						     NETIF_F_HW_VLAN_CTAG_TX |
> +						     NETIF_F_HW_VLAN_STAG_TX);
> +
> +	return features;
> +}
> +
>  #endif /* !(_LINUX_IF_VLAN_H_) */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 04bffcd..41d0db55 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2562,6 +2562,13 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
>  	return features;
>  }
>  
> +static netdev_features_t dflt_features_check(struct sk_buff *skb,

const struct sk_buff *skb

> +					     struct net_device *dev,
> +					     netdev_features_t features)
> +{
> +	return vlan_features_check(skb, features);
> +}
> +
