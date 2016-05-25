From: YOSHIFUJI Hideaki <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Subject: Re: [RFC 04/12] ndisc: get rid off dev parameter in
 ndisc_opt_addr_space
Date: Wed, 25 May 2016 14:15:36 +0900
Message-ID: <574534F8.20308@miraclelinux.com>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-5-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464031328-17524-5-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Alexander Aring wrote:
> This patch removes the net_device parameter from ndisc_opt_addr_space
> function. This can be useful for calling such functionality which
> doesn't depends on dev parameter. For current existing functionality
> which depends on dev parameter, we introduce ndisc_dev_opt_addr_space to have
> an easy replacement for the ndisc_opt_addr_space function.
> 
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  include/net/ndisc.h | 13 +++++++++----
>  net/ipv6/ndisc.c    | 12 ++++++------
>  2 files changed, 15 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 2d8edaa..dbc8d01 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
>  	}
>  }
>  
> -static inline int ndisc_opt_addr_space(struct net_device *dev)
> +static inline int ndisc_opt_addr_space(unsigned char addr_len, int pad)
>  {
> -	return NDISC_OPT_SPACE(dev->addr_len +
> -			       ndisc_addr_option_pad(dev->type));
> +	return NDISC_OPT_SPACE(addr_len + pad);
> +}
> +
> +static inline int ndisc_dev_opt_addr_space(const struct net_device *dev)
> +{
> +	return ndisc_opt_addr_space(dev->addr_len,
> +				    ndisc_addr_option_pad(dev->type));
>  }
>  

I prefer not to change existing functions such as ndisc_opt_addr_space(),
and name new function __ndisc_opt_addr_space() etc.

Plus, my original thought (when I implement these functions) was to
have per-net_device ndisc_opt_addr_spece(), ndisc_opt_adr_data() etc.

What do you think of that?

>  static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> @@ -139,7 +144,7 @@ static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
>  	u8 *lladdr = (u8 *)(p + 1);
>  	int lladdrlen = p->nd_opt_len << 3;
>  	int prepad = ndisc_addr_option_pad(dev->type);
> -	if (lladdrlen != ndisc_opt_addr_space(dev))
> +	if (lladdrlen != ndisc_opt_addr_space(dev->addr_len, prepad))
>  		return NULL;
>  	return lladdr + prepad;
>  }
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index c245895..2241f06 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -152,9 +152,9 @@ EXPORT_SYMBOL_GPL(nd_tbl);
>  
>  static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
>  {
> -	int pad   = ndisc_addr_option_pad(skb->dev->type);
> +	int pad = ndisc_addr_option_pad(skb->dev->type);
>  	int data_len = skb->dev->addr_len;
> -	int space = ndisc_opt_addr_space(skb->dev);
> +	int space = ndisc_opt_addr_space(data_len, pad);
>  	u8 *opt = skb_put(skb, space);
>  
>  	opt[0] = type;
> @@ -509,7 +509,7 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
>  	if (!dev->addr_len)
>  		inc_opt = 0;
>  	if (inc_opt)
> -		optlen += ndisc_opt_addr_space(dev);
> +		optlen += ndisc_dev_opt_addr_space(dev);
>  
>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -574,7 +574,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
>  	if (ipv6_addr_any(saddr))
>  		inc_opt = false;
>  	if (inc_opt)
> -		optlen += ndisc_opt_addr_space(dev);
> +		optlen += ndisc_dev_opt_addr_space(dev);
>  
>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -626,7 +626,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>  	}
>  #endif
>  	if (send_sllao)
> -		optlen += ndisc_opt_addr_space(dev);
> +		optlen += ndisc_dev_opt_addr_space(dev);
>  
>  	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
>  	if (!skb)
> @@ -1563,7 +1563,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  			memcpy(ha_buf, neigh->ha, dev->addr_len);
>  			read_unlock_bh(&neigh->lock);
>  			ha = ha_buf;
> -			optlen += ndisc_opt_addr_space(dev);
> +			optlen += ndisc_dev_opt_addr_space(dev);
>  		} else
>  			read_unlock_bh(&neigh->lock);
>  
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji-GmhWrQMWH5w7YuNMryXyOw@public.gmane.org>
Technical Division, MIRACLE LINUX CORPORATION
