From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 11/12] [IPSEC]: Reinject packet instead of calling
 netfilter directly on input
Date: Wed, 17 Oct 2007 00:05:47 +0900 (JST)
Message-ID: <20071017.000547.102039099.yoshfuji@linux-ipv6.org>
References: <20071016141843.GA11956@gondor.apana.org.au>
	<E1IhnTz-0003HT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org, kozakai@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34384 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387AbXJPPFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 11:05:51 -0400
In-Reply-To: <E1IhnTz-0003HT-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

I think with this change, we parse extension headers, twice.
We really do not want to do this.

--yoshfuji

In article <E1IhnTz-0003HT-00@gondolin.me.apana.org.au> (at Tue, 16 Oct 2007 22:33:19 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> [IPSEC]: Reinject packet instead of calling netfilter directly on input
> 
> Currently we call netfilter directly on input after a series of transport
> mode transforms (and BEET but that's a separate bug).  This is inconsistent
> because other parts of the stack such AF_PACKET cannot see the decapsulated
> packet.  In fact this is a common complaint about the Linux IPsec stack.
> 
> Another problem is that there is a potential for stack overflow if we
> encounter a DNAT rule which turns a foreign packet into a local one that
> contains another transport mode SA.
> 
> This patch introduces a major behavioural change by reinjecting the
> packet instead of calling netfilter directly.
> 
> This solves both of the aformentioned problems.
> 
> It is still inconsistent with how we do things on output since we don't
> pass things through AF_PACKET there either but the same inconsistency
> exists for tunnel mode too so it's not a new problem.
> 
> To make things easier I've added a new function called netif_rerx which
> resets netfilter and the dst before reinjecting the packet using netif_rx.
> This can be used by other tunnel code as well.
> 
> I haven't added a reinject function for RO mode since it can never be
> called on that path and if it does we want to know about it through an
> OOPS.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  include/linux/netdevice.h       |    1 +
>  include/net/xfrm.h              |    8 ++++++++
>  net/core/dev.c                  |   12 ++++++++++++
>  net/ipv4/xfrm4_input.c          |   24 ++----------------------
>  net/ipv4/xfrm4_mode_beet.c      |    7 +++++++
>  net/ipv4/xfrm4_mode_transport.c |   11 +++++++++++
>  net/ipv4/xfrm4_mode_tunnel.c    |    7 +++++++
>  net/ipv6/xfrm6_input.c          |   23 ++---------------------
>  net/ipv6/xfrm6_mode_beet.c      |    7 +++++++
>  net/ipv6/xfrm6_mode_transport.c |   10 ++++++++++
>  net/ipv6/xfrm6_mode_tunnel.c    |    7 +++++++
>  11 files changed, 74 insertions(+), 43 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 39dd83b..097f911 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1039,6 +1039,7 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
>  #define HAVE_NETIF_RX 1
>  extern int		netif_rx(struct sk_buff *skb);
>  extern int		netif_rx_ni(struct sk_buff *skb);
> +extern int		netif_rerx(struct sk_buff *skb);
>  #define HAVE_NETIF_RECEIVE_SKB 1
>  extern int		netif_receive_skb(struct sk_buff *skb);
>  extern int		dev_valid_name(const char *name);
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index a9e8247..e5ae5fa 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -311,6 +311,14 @@ struct xfrm_mode {
>  	 */
>  	int (*output)(struct xfrm_state *x,struct sk_buff *skb);
>  
> +	/*
> +	 * Reinject packet into stack.
> +	 *
> +	 * On entry, the packet is in the state as on exit from the
> +	 * input function above.
> +	 */
> +	int (*reinject)(struct xfrm_state *x,struct sk_buff *skb);
> +
>  	struct xfrm_state_afinfo *afinfo;
>  	struct module *owner;
>  	unsigned int encap;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 38b03da..b753ec8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1808,6 +1808,18 @@ int netif_rx_ni(struct sk_buff *skb)
>  
>  EXPORT_SYMBOL(netif_rx_ni);
>  
> +/* Reinject a packet that has previously been processed, e.g., by tunneling. */
> +int netif_rerx(struct sk_buff *skb)
> +{
> +	nf_reset(skb);
> +
> +	dst_release(skb->dst);
> +	skb->dst = NULL;
> +
> +	return netif_rx(skb);
> +}
> +EXPORT_SYMBOL(netif_rerx);
> +
>  static inline struct net_device *skb_bond(struct sk_buff *skb)
>  {
>  	struct net_device *dev = skb->dev;
> diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
> index 5cb0b59..f5576d5 100644
> --- a/net/ipv4/xfrm4_input.c
> +++ b/net/ipv4/xfrm4_input.c
> @@ -41,7 +41,6 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
>  	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
>  	struct xfrm_state *x;
>  	int xfrm_nr = 0;
> -	int decaps = 0;
>  	unsigned int nhoff = offsetof(struct iphdr, protocol);
>  
>  	seq = 0;
> @@ -95,7 +94,6 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
>  			goto drop;
>  
>  		if (x->props.mode == XFRM_MODE_TUNNEL) {
> -			decaps = 1;
>  			break;
>  		}
>  
> @@ -122,26 +120,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
>  	       xfrm_nr * sizeof(xfrm_vec[0]));
>  	skb->sp->len += xfrm_nr;
>  
> -	nf_reset(skb);
> -
> -	if (decaps) {
> -		dst_release(skb->dst);
> -		skb->dst = NULL;
> -		netif_rx(skb);
> -		return 0;
> -	} else {
> -#ifdef CONFIG_NETFILTER
> -		__skb_push(skb, skb->data - skb_network_header(skb));
> -		ip_hdr(skb)->tot_len = htons(skb->len);
> -		ip_send_check(ip_hdr(skb));
> -
> -		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
> -			xfrm4_rcv_encap_finish);
> -		return 0;
> -#else
> -		return -ip_hdr(skb)->protocol;
> -#endif
> -	}
> +	x->mode->reinject(x, skb);
> +	return 0;
>  
>  drop_unlock:
>  	spin_unlock(&x->lock);
> diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
> index 73d2338..012ae98 100644
> --- a/net/ipv4/xfrm4_mode_beet.c
> +++ b/net/ipv4/xfrm4_mode_beet.c
> @@ -11,6 +11,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dst.h>
> @@ -109,9 +110,15 @@ out:
>  	return err;
>  }
>  
> +static int xfrm4_beet_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm4_beet_mode = {
>  	.input = xfrm4_beet_input,
>  	.output = xfrm4_beet_output,
> +	.reinject = xfrm4_beet_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_BEET,
>  };
> diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
> index fd840c7..602418b 100644
> --- a/net/ipv4/xfrm4_mode_transport.c
> +++ b/net/ipv4/xfrm4_mode_transport.c
> @@ -7,6 +7,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dst.h>
> @@ -54,9 +55,19 @@ static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
>  	return 0;
>  }
>  
> +static int xfrm4_transport_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	__skb_push(skb, skb->data - skb_network_header(skb));
> +	ip_hdr(skb)->tot_len = htons(skb->len);
> +	ip_send_check(ip_hdr(skb));
> +
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm4_transport_mode = {
>  	.input = xfrm4_transport_input,
>  	.output = xfrm4_transport_output,
> +	.reinject = xfrm4_transport_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_TRANSPORT,
>  };
> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
> index 1ae9d32..780908a 100644
> --- a/net/ipv4/xfrm4_mode_tunnel.c
> +++ b/net/ipv4/xfrm4_mode_tunnel.c
> @@ -7,6 +7,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dst.h>
> @@ -134,9 +135,15 @@ out:
>  	return err;
>  }
>  
> +static int xfrm4_tunnel_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm4_tunnel_mode = {
>  	.input = xfrm4_tunnel_input,
>  	.output = xfrm4_tunnel_output,
> +	.reinject = xfrm4_tunnel_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_TUNNEL,
>  };
> diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> index b1201c3..1347e0a 100644
> --- a/net/ipv6/xfrm6_input.c
> +++ b/net/ipv6/xfrm6_input.c
> @@ -23,7 +23,6 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
>  	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
>  	struct xfrm_state *x;
>  	int xfrm_nr = 0;
> -	int decaps = 0;
>  	unsigned int nhoff;
>  
>  	nhoff = IP6CB(skb)->nhoff;
> @@ -72,7 +71,6 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
>  			goto drop;
>  
>  		if (x->props.mode == XFRM_MODE_TUNNEL) { /* XXX */
> -			decaps = 1;
>  			break;
>  		}
>  
> @@ -98,25 +96,8 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
>  	       xfrm_nr * sizeof(xfrm_vec[0]));
>  	skb->sp->len += xfrm_nr;
>  
> -	nf_reset(skb);
> -
> -	if (decaps) {
> -		dst_release(skb->dst);
> -		skb->dst = NULL;
> -		netif_rx(skb);
> -		return -1;
> -	} else {
> -#ifdef CONFIG_NETFILTER
> -		ipv6_hdr(skb)->payload_len = htons(skb->len);
> -		__skb_push(skb, skb->data - skb_network_header(skb));
> -
> -		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
> -			ip6_rcv_finish);
> -		return -1;
> -#else
> -		return 1;
> -#endif
> -	}
> +	x->mode->reinject(x, skb);
> +	return -1;
>  
>  drop_unlock:
>  	spin_unlock(&x->lock);
> diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
> index 13bb1e8..17622cf 100644
> --- a/net/ipv6/xfrm6_mode_beet.c
> +++ b/net/ipv6/xfrm6_mode_beet.c
> @@ -11,6 +11,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dsfield.h>
> @@ -74,9 +75,15 @@ out:
>  	return err;
>  }
>  
> +static int xfrm6_beet_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm6_beet_mode = {
>  	.input = xfrm6_beet_input,
>  	.output = xfrm6_beet_output,
> +	.reinject = xfrm6_beet_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_BEET,
>  };
> diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
> index 4e34410..e165442 100644
> --- a/net/ipv6/xfrm6_mode_transport.c
> +++ b/net/ipv6/xfrm6_mode_transport.c
> @@ -8,6 +8,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dst.h>
> @@ -59,9 +60,18 @@ static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
>  	return 0;
>  }
>  
> +static int xfrm6_transport_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	ipv6_hdr(skb)->payload_len = htons(skb->len);
> +	__skb_push(skb, skb->data - skb_network_header(skb));
> +
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm6_transport_mode = {
>  	.input = xfrm6_transport_input,
>  	.output = xfrm6_transport_output,
> +	.reinject = xfrm6_transport_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_TRANSPORT,
>  };
> diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
> index ea22838..1329d6a 100644
> --- a/net/ipv6/xfrm6_mode_tunnel.c
> +++ b/net/ipv6/xfrm6_mode_tunnel.c
> @@ -8,6 +8,7 @@
>  #include <linux/init.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/netdevice.h>
>  #include <linux/skbuff.h>
>  #include <linux/stringify.h>
>  #include <net/dsfield.h>
> @@ -113,9 +114,15 @@ out:
>  	return err;
>  }
>  
> +static int xfrm6_tunnel_reinject(struct xfrm_state *x, struct sk_buff *skb)
> +{
> +	return netif_rerx(skb);
> +}
> +
>  static struct xfrm_mode xfrm6_tunnel_mode = {
>  	.input = xfrm6_tunnel_input,
>  	.output = xfrm6_tunnel_output,
> +	.reinject = xfrm6_tunnel_reinject,
>  	.owner = THIS_MODULE,
>  	.encap = XFRM_MODE_TUNNEL,
>  };
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
