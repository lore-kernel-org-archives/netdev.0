From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCHv2 bluetooth-next 08/10] ipv6: export ndisc functions
Date: Wed, 4 May 2016 14:23:22 +0200
Message-ID: <5729E9BA.50504@osg.samsung.com>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
 <1461140382-4784-9-git-send-email-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461140382-4784-9-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 20/04/16 10:19, Alexander Aring wrote:
> This patch exports some neighbour discovery functions which can be used
> by 6lowpan neighbour discovery ops functionality then.
>
> Cc: David S. Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Alexey Kuznetsov<kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
> Cc: James Morris<jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Hideaki YOSHIFUJI<yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
> Cc: Patrick McHardy<kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> Signed-off-by: Alexander Aring<aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>   include/net/ndisc.h | 16 ++++++++++++++++
>   net/ipv6/addrconf.c |  1 +
>   net/ipv6/ndisc.c    | 28 ++++++++++------------------
>   3 files changed, 27 insertions(+), 18 deletions(-)
>
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 14ed016..35a4396 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -53,6 +53,15 @@ enum {
>   
>   #include <net/neighbour.h>
>   
> +/* Set to 3 to get tracing... */
> +#define ND_DEBUG 1
> +
> +#define ND_PRINTK(val, level, fmt, ...)				\
> +do {								\
> +	if (val <= ND_DEBUG)					\
> +		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
> +} while (0)
> +
>   struct ctl_table;
>   struct inet6_dev;
>   struct net_device;
> @@ -267,6 +276,13 @@ int ndisc_late_init(void);
>   void ndisc_late_cleanup(void);
>   void ndisc_cleanup(void);
>   
> +void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +			    int data_len);
> +struct sk_buff *ndisc_alloc_skb(struct net_device *dev, int len);
> +void ndisc_send_skb(struct sk_buff *skb, const struct in6_addr *daddr,
> +		    const struct in6_addr *saddr);
> +int pndisc_is_router(const void *pkey, struct net_device *dev);
> +
>   int ndisc_rcv(struct sk_buff *skb);
>   
>   void ndisc_send_rs(struct net_device *dev,
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index a2ef04b..8f05ef8 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1775,6 +1775,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
>   
>   	return result;
>   }
> +EXPORT_SYMBOL(ipv6_get_ifaddr);
>   
>   /* Gets referenced address, destroys ifaddr */
>   
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 297080a..dc8bfec 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -73,15 +73,6 @@
>   #include <linux/netfilter.h>
>   #include <linux/netfilter_ipv6.h>
>   
> -/* Set to 3 to get tracing... */
> -#define ND_DEBUG 1
> -
> -#define ND_PRINTK(val, level, fmt, ...)				\
> -do {								\
> -	if (val <= ND_DEBUG)					\
> -		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
> -} while (0)
> -
>   static u32 ndisc_hash(const void *pkey,
>   		      const struct net_device *dev,
>   		      __u32 *hash_rnd);
> @@ -150,8 +141,8 @@ struct neigh_table nd_tbl = {
>   };
>   EXPORT_SYMBOL_GPL(nd_tbl);
>   
> -static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> -				   int data_len)
> +void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +			    int data_len)
>   {
>   	int pad   = ndisc_addr_option_pad(skb->dev->type);
>   	int space = ndisc_opt_addr_space(skb->dev, data_len);
> @@ -171,6 +162,7 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
>   	if (space > 0)
>   		memset(opt, 0, space);
>   }
> +EXPORT_SYMBOL(ndisc_fill_addr_option);

Hmm, one export in this files uses EXPORT_SYMBOL while another one uses  
EXPORT_SYMBOL_GPL. Not sure which one is preferred in this file.
>   
>   static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>   					    struct nd_opt_hdr *end)
> @@ -378,8 +370,7 @@ static void pndisc_destructor(struct pneigh_entry *n)
>   	ipv6_dev_mc_dec(dev, &maddr);
>   }
>   
> -static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
> -				       int len)
> +struct sk_buff *ndisc_alloc_skb(struct net_device *dev, int len)
>   {
>   	int hlen = LL_RESERVED_SPACE(dev);
>   	int tlen = dev->needed_tailroom;
> @@ -406,6 +397,7 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
>   
>   	return skb;
>   }
> +EXPORT_SYMBOL(ndisc_alloc_skb);

Same here.
>   
>   static void ip6_nd_hdr(struct sk_buff *skb,
>   		       const struct in6_addr *saddr,
> @@ -428,9 +420,8 @@ static void ip6_nd_hdr(struct sk_buff *skb,
>   	hdr->daddr = *daddr;
>   }
>   
> -static void ndisc_send_skb(struct sk_buff *skb,
> -			   const struct in6_addr *daddr,
> -			   const struct in6_addr *saddr)
> +void ndisc_send_skb(struct sk_buff *skb, const struct in6_addr *daddr,
> +		    const struct in6_addr *saddr)
>   {
>   	struct dst_entry *dst = skb_dst(skb);
>   	struct net *net = dev_net(skb->dev);
> @@ -479,6 +470,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
>   
>   	rcu_read_unlock();
>   }
> +EXPORT_SYMBOL(ndisc_send_skb);

And here.
>   
>   static void ip6_ndisc_send_na(struct net_device *dev,
>   			      const struct in6_addr *daddr,
> @@ -692,8 +684,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
>   	}
>   }
>   
> -static int pndisc_is_router(const void *pkey,
> -			    struct net_device *dev)
> +int pndisc_is_router(const void *pkey, struct net_device *dev)
>   {
>   	struct pneigh_entry *n;
>   	int ret = -1;
> @@ -706,6 +697,7 @@ static int pndisc_is_router(const void *pkey,
>   
>   	return ret;
>   }
> +EXPORT_SYMBOL(pndisc_is_router);
>   
>   static void ip6_ndisc_recv_ns(struct sk_buff *skb)
>   {

Reviewed-by: Stefan Schmidt<stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

regards
Stefan Schmidt
