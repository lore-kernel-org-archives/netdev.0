From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] ila: Cache a route to translated address
Date: Thu, 13 Oct 2016 23:22:14 -0700
Message-ID: <58007996.2070500@cumulusnetworks.com>
References: <20161014005743.288956-1-tom@herbertland.com> <20161014005743.288956-3-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36666 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754879AbcJNGWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:22:21 -0400
Received: by mail-pf0-f176.google.com with SMTP id e6so45329443pfk.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 23:22:15 -0700 (PDT)
In-Reply-To: <20161014005743.288956-3-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/16, 5:57 PM, Tom Herbert wrote:
> Add a dst_cache to ila_lwt structure. This holds a cached route for the
> translated address. In ila_output we now perform a route lookup after
> translation and if possible (destination in original route is full 128
> bits) we set the dst_cache. Subsequent calls to ila_output can then use
> the cache to avoid the route lookup.
>
> This eliminates the need to set the gateway on ILA routes as previously
> was being done. Now we can do something like:
>
> ./ip route add 3333::2000:0:0:2/128 encap ila 2222:0:0:2 \
>     csum-mode neutral-map dev eth0  ## No via needed!
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
 Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

This is a nice way to cache and redirect to a new dst.

This removes the last and only user of lwt orig_output. we can drop it
subsequently. But since orig_input is still in use, probably better to keep it
around for symmetry and for other uses in the future.

thanks.



>  net/ipv6/ila/ila_lwt.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 72 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
> index e50c27a..df14b00 100644
> --- a/net/ipv6/ila/ila_lwt.c
> +++ b/net/ipv6/ila/ila_lwt.c
> @@ -6,29 +6,80 @@
>  #include <linux/socket.h>
>  #include <linux/types.h>
>  #include <net/checksum.h>
> +#include <net/dst_cache.h>
>  #include <net/ip.h>
>  #include <net/ip6_fib.h>
> +#include <net/ip6_route.h>
>  #include <net/lwtunnel.h>
>  #include <net/protocol.h>
>  #include <uapi/linux/ila.h>
>  #include "ila.h"
>  
> +struct ila_lwt {
> +	struct ila_params p;
> +	struct dst_cache dst_cache;
> +	u32 connected : 1;
> +};
> +
> +static inline struct ila_lwt *ila_lwt_lwtunnel(
> +	struct lwtunnel_state *lwstate)
> +{
> +	return (struct ila_lwt *)lwstate->data;
> +}
> +
>  static inline struct ila_params *ila_params_lwtunnel(
>  	struct lwtunnel_state *lwstate)
>  {
> -	return (struct ila_params *)lwstate->data;
> +	return &((struct ila_lwt *)lwstate->data)->p;
>  }
>  
>  static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  {
> -	struct dst_entry *dst = skb_dst(skb);
> +	struct dst_entry *orig_dst = skb_dst(skb);
> +	struct ila_lwt *ilwt = ila_lwt_lwtunnel(orig_dst->lwtstate);
> +	struct dst_entry *dst;
> +	int err = -EINVAL;
>  
>  	if (skb->protocol != htons(ETH_P_IPV6))
>  		goto drop;
>  
> -	ila_update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate), true);
> +	ila_update_ipv6_locator(skb, ila_params_lwtunnel(orig_dst->lwtstate),
> +				true);
>  
> -	return dst->lwtstate->orig_output(net, sk, skb);
> +	dst = dst_cache_get(&ilwt->dst_cache);
> +	if (unlikely(!dst)) {
> +		struct ipv6hdr *ip6h = ipv6_hdr(skb);
> +		struct flowi6 fl6;
> +
> +		/* Lookup a route for the new destination. Take into
> +		 * account that the base route may already have a gateway.
> +		 */
> +
> +		memset(&fl6, 0, sizeof(fl6));
> +		fl6.flowi6_oif = orig_dst->dev->ifindex;
> +		fl6.flowi6_iif = LOOPBACK_IFINDEX;
> +		fl6.daddr = *rt6_nexthop((struct rt6_info *)orig_dst,
> +					 &ip6h->daddr);
> +
> +		dst = ip6_route_output(net, NULL, &fl6);
> +		if (dst->error) {
> +			err = -EHOSTUNREACH;
> +			dst_release(dst);
> +			goto drop;
> +		}
> +
> +		dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
> +		if (IS_ERR(dst)) {
> +			err = PTR_ERR(dst);
> +			goto drop;
> +		}
> +
> +		if (ilwt->connected)
> +			dst_cache_set_ip6(&ilwt->dst_cache, dst, &fl6.saddr);
> +	}
> +
> +	skb_dst_set(skb, dst);
> +	return dst_output(dev_net(skb_dst(skb)->dev), sk, skb);
>  
>  drop:
>  	kfree_skb(skb);
> @@ -60,6 +111,7 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
>  			   unsigned int family, const void *cfg,
>  			   struct lwtunnel_state **ts)
>  {
> +	struct ila_lwt *ilwt;
>  	struct ila_params *p;
>  	struct nlattr *tb[ILA_ATTR_MAX + 1];
>  	size_t encap_len = sizeof(*p);
> @@ -99,6 +151,13 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
>  	if (!newts)
>  		return -ENOMEM;
>  
> +	ilwt = ila_lwt_lwtunnel(newts);
> +	ret = dst_cache_init(&ilwt->dst_cache, GFP_ATOMIC);
> +	if (ret) {
> +		kfree(newts);
> +		return ret;
> +	}
> +
>  	newts->len = encap_len;
>  	p = ila_params_lwtunnel(newts);
>  
> @@ -120,11 +179,19 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
>  	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
>  			LWTUNNEL_STATE_INPUT_REDIRECT;
>  
> +	if (cfg6->fc_dst_len == sizeof(struct in6_addr))
> +		ilwt->connected = 1;
> +
>  	*ts = newts;
>  
>  	return 0;
>  }
>  
> +static void ila_destroy_state(struct lwtunnel_state *lwt)
> +{
> +	dst_cache_destroy(&ila_lwt_lwtunnel(lwt)->dst_cache);
> +}
> +
>  static int ila_fill_encap_info(struct sk_buff *skb,
>  			       struct lwtunnel_state *lwtstate)
>  {
> @@ -159,6 +226,7 @@ static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
>  
>  static const struct lwtunnel_encap_ops ila_encap_ops = {
>  	.build_state = ila_build_state,
> +	.destroy_state = ila_destroy_state,
>  	.output = ila_output,
>  	.input = ila_input,
>  	.fill_encap = ila_fill_encap_info,
