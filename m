From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCHv3 net-next 09/12] ipv6: export several functions
Date: Wed, 15 Jun 2016 17:18:40 +0200
Message-ID: <576171D0.5070009@osg.samsung.com>
References: <20160614115239.17788-1-aar@pengutronix.de>
 <20160614115239.17788-10-aar@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexander Aring <aar@pengutronix.de>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:60649 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932121AbcFOPSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:18:46 -0400
In-Reply-To: <20160614115239.17788-10-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 14/06/16 13:52, Alexander Aring wrote:
> This patch exports some neighbour discovery functions which can be used
> by 6lowpan neighbour discovery ops functionality then.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <aar@pengutronix.de>
> ---
>   include/net/addrconf.h |  7 +++++++
>   include/net/ndisc.h    | 12 ++++++++++++
>   net/ipv6/addrconf.c    | 15 +++++++--------
>   net/ipv6/ndisc.c       | 14 +++-----------
>   4 files changed, 29 insertions(+), 19 deletions(-)
>
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index b1774eb..9826d3a 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -97,6 +97,13 @@ void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
>   void addrconf_add_linklocal(struct inet6_dev *idev,
>   			    const struct in6_addr *addr, u32 flags);
>   
> +int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
> +				 const struct prefix_info *pinfo,
> +				 struct inet6_dev *in6_dev,
> +				 const struct in6_addr *addr, int addr_type,
> +				 u32 addr_flags, bool sllao, bool tokenized,
> +				 __u32 valid_lft, u32 prefered_lft);
> +
>   static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>   {
>   	if (dev->addr_len != ETH_ALEN)
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index a5e2767..3f0f41d 100644
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
> @@ -115,6 +124,9 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
>   					  u8 *opt, int opt_len,
>   					  struct ndisc_options *ndopts);
>   
> +void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +			      int data_len, int pad);
> +
>   #define NDISC_OPS_REDIRECT_DATA_SPACE	2
>   
>   /*
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2d678c0..9c7d660 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2333,14 +2333,12 @@ static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
>   	       idev->addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
>   }
>   
> -static int addrconf_prefix_rcv_add_addr(struct net *net,
> -					struct net_device *dev,
> -					const struct prefix_info *pinfo,
> -					struct inet6_dev *in6_dev,
> -					const struct in6_addr *addr,
> -					int addr_type, u32 addr_flags,
> -					bool sllao, bool tokenized,
> -					__u32 valid_lft, u32 prefered_lft)
> +int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
> +				 const struct prefix_info *pinfo,
> +				 struct inet6_dev *in6_dev,
> +				 const struct in6_addr *addr, int addr_type,
> +				 u32 addr_flags, bool sllao, bool tokenized,
> +				 __u32 valid_lft, u32 prefered_lft)
>   {
>   	struct inet6_ifaddr *ifp = ipv6_get_ifaddr(net, addr, dev, 1);
>   	int create = 0, update_lft = 0;
> @@ -2430,6 +2428,7 @@ static int addrconf_prefix_rcv_add_addr(struct net *net,
>   
>   	return 0;
>   }
> +EXPORT_SYMBOL_GPL(addrconf_prefix_rcv_add_addr);
>   
>   void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>   {
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 2f4afd1..fe65cdc 100644
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
> -static void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> -				     int data_len, int pad)
> +void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
> +			      int data_len, int pad)
>   {
>   	int space = __ndisc_opt_addr_space(data_len, pad);
>   	u8 *opt = skb_put(skb, space);
> @@ -170,6 +161,7 @@ static void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
>   	if (space > 0)
>   		memset(opt, 0, space);
>   }
> +EXPORT_SYMBOL_GPL(__ndisc_fill_addr_option);
>   
>   static inline void ndisc_fill_addr_option(struct sk_buff *skb, int type,
>   					  void *data, u8 icmp6_type)

Reviewed-by: Stefan Schmidt<stefan@osg.samsung.com>

regards
Stefan Schmidt
