From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sat, 12 Jan 2013 16:47:41 +0100
Message-ID: <20130112164741.1a0ab7bb@stein>
References: <50F17178.3090705@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:60291 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3ALPsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 10:48:01 -0500
In-Reply-To: <50F17178.3090705@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 YOSHIFUJI Hideaki wrote:
> CC: Stephan Gatzka <stephan.gatzka@gmail.com>
> CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/net/ndisc.h |   14 +++++++++++-
>  net/ipv6/addrconf.c |    4 +++-
>  net/ipv6/ndisc.c    |   60 +++++++++++++++++++++++++++++++++++++++++++++++----
>  net/ipv6/route.c    |    2 ++
>  4 files changed, 74 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 3c53257..1de4e0c 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -52,6 +52,7 @@ enum {
>  #include <linux/hash.h>
>  
>  #include <net/neighbour.h>
> +#include <net/firewire.h>
>  
>  struct ctl_table;
>  struct inet6_dev;
> @@ -127,10 +128,19 @@ static int ndisc_addr_option_pad(unsigned short type)
>  	}
>  }
>  
> +static int ndisc_addr_option_postpad(unsigned short type)
> +{
> +	switch (type) {
> +	case ARPHRD_IEEE1394:	return sizeof(struct fwnet_peerinfo);
> +	default:		return 0;
> +	}
> +}
> +
>  static inline int ndisc_opt_addr_space(struct net_device *dev)
>  {
>  	return NDISC_OPT_SPACE(dev->addr_len +
> -			       ndisc_addr_option_pad(dev->type));
> +			       ndisc_addr_option_pad(dev->type) +
> +			       ndisc_addr_option_postpad(dev->type));
>  }
>  
>  static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
> @@ -203,6 +213,8 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
>  extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
>  					     struct net_device *dev, int dir);
>  
> +extern void			ndisc_update_peerinfo(struct net_device *dev,
> +						      void *lladdr);
>  
>  /*
>   *	IGMP
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 408cac4a..9a0728a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1729,6 +1729,7 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
>  	case ARPHRD_IPGRE:
>  		return addrconf_ifid_gre(eui, dev);
>  	case ARPHRD_IEEE802154:
> +	case ARPHRD_IEEE1394:
>  		return addrconf_ifid_eui64(eui, dev);
>  	}
>  	return -1;
> @@ -2571,7 +2572,8 @@ static void addrconf_dev_config(struct net_device *dev)
>  	    (dev->type != ARPHRD_FDDI) &&
>  	    (dev->type != ARPHRD_ARCNET) &&
>  	    (dev->type != ARPHRD_INFINIBAND) &&
> -	    (dev->type != ARPHRD_IEEE802154)) {
> +	    (dev->type != ARPHRD_IEEE802154) &&
> +	    (dev->type != ARPHRD_IEEE1394)) {
>  		/* Alas, we support only Ethernet autoconfiguration. */
>  		return;
>  	}
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 99cd286..9a0ba9c 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -72,6 +72,8 @@
>  #include <linux/netfilter.h>
>  #include <linux/netfilter_ipv6.h>
>  
> +#include <net/firewire.h>
> +
>  /* Set to 3 to get tracing... */
>  #define ND_DEBUG 1
>  
> @@ -143,6 +145,22 @@ struct neigh_table nd_tbl = {
>  	.gc_thresh3 =	1024,
>  };
>  
> +#if defined(CONFIG_FIREWIRE_NET)
> +static u8 *__ndisc_fill_addr_option_firewire_postpad(u8 *opt, int space, void *data,
> +						     struct net_device *dev)
> +{
> +	if (likely(space >= sizeof(struct fwnet_peerinfo))) {
> +		fwnet_fill_peerinfo(dev, (__be64 *)data, (struct fwnet_peerinfo *)opt);
> +		opt += sizeof(struct fwnet_peerinfo);
> +		space -= sizeof(struct fwnet_peerinfo);
> +	}

As noted, please do not add EXPORTs to drivers/firewire/net.c and call
those from net/ipv6/*.c or anywhere else.

Instead, let drivers/firewire/net.c provide a function pointer to
ndisc_build_skb() or, if possible, just let it provide a pointer to struct
fwnet_peerinfo source data to be copied here.

Whether the function pointer or the source data go via struct net_device
or some other struct or via an extended version of ndisc_build_skb() with
added arguments is something I can't decide, not having worked with the
networking code myself yet.

> +	if (space > 0)
> +		memset(opt, 0, space);
> +
> +	return opt + space;
> +}
> +#endif
> +
>  static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
>  				  struct net_device *dev)
>  {
> @@ -160,9 +178,20 @@ static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
>  	memcpy(opt+2, data, data_len);
>  	data_len += 2;
>  	opt += data_len;
> -	if ((space -= data_len) > 0)
> -		memset(opt, 0, space);
> -	return opt + space;
> +
> +	if ((space -= data_len) > 0) {
> +		switch (dev->type) {
> +#if defined(CONFIG_FIREWIRE_NET)
> +		case ARPHRD_IEEE1394:
> +			opt = __ndisc_fill_addr_option_firewire_postpad(opt, space,
> +									data, dev);
> +#endif
> +		default:
> +			memset(opt, 0, space);
> +			opt += space;
> +		}
> +	}
> +	return opt;
>  }
>  
>  static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
> @@ -366,6 +395,19 @@ static void pndisc_destructor(struct pneigh_entry *n)
>  	ipv6_dev_mc_dec(dev, &maddr);
>  }
>  
> +void ndisc_update_peerinfo(struct net_device *dev, void *lladdr)
> +{
> +#if defined(CONFIG_FIREWIRE_NET)
> +	switch (dev->type) {
> +	case ARPHRD_IEEE1394:
> +		fwnet_update_peerinfo(dev, lladdr, (struct fwnet_peerinfo *)((__u64 *)lladdr + 1));
> +		break;
> +	default:
> +		break;
> +	}
> +#endif
[...]

Dito, please do not solve this with an EXPORT from drivers/firewire/net.c.

Either a new driver callback is required, and the function pointer to this
callback needs to be reachable indirectly via the skb pointer.

Or drivers/firewire/net.c needs to be aware that it just received an NDP
packet, and then call a parser function in net/ipv6/ndisc.c which returns
the data that drivers/firewire/net.c wants to know.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
