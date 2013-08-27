From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6:examine the IP source address legitimacy
Date: Tue, 27 Aug 2013 16:20:59 +0200
Message-ID: <20130827142059.GA23120@order.stressinduktion.org>
References: <521C90A0.60708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49293 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab3H0OVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 10:21:01 -0400
Content-Disposition: inline
In-Reply-To: <521C90A0.60708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 07:42:24PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> RFC4861 8.1:
> The IP source address of the Redirect is the
> same as the current first-hop router for the
> specified ICMP Destination Address.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/route.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 8d9a93e..d4f0f72 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1685,6 +1685,7 @@ static int ip6_route_del(struct fib6_config *cfg)
>  static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
>  {
>  	struct net *net = dev_net(skb->dev);
> +	struct ipv6hdr *iph = ipv6_hdr(skb);
>  	struct netevent_redirect netevent;
>  	struct rt6_info *rt, *nrt = NULL;
>  	struct ndisc_options ndopts;
> @@ -1745,7 +1746,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>  	}
>  
>  	rt = (struct rt6_info *) dst;
> -	if (rt == net->ipv6.ip6_null_entry) {
> +	if (rt == net->ipv6.ip6_null_entry || !ipv6_addr_equal(&rt->rt6i_gateway, &iph->saddr)) {
>  		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
>  		return;
>  	}

Hmm, that's difficult...

There was once this check:

        /*
         *      RFC 2461 specifies that redirects should only be
         *      accepted if they come from the nexthop to the target.
         *      Due to the way default routers are chosen, this notion
         *      is a bit fuzzy and one might need to check all default
         *      routers.
         */
        if (!ipv6_addr_equal(saddr, &rt->rt6i_gateway)) {
                if (rt->rt6i_flags & RTF_DEFAULT) {
                        struct rt6_info *rt1;

                        read_lock(&rt6_lock);
                        for (rt1 = ip6_routing_table.leaf; rt1; rt1 = rt1->u.next) {
                                if (ipv6_addr_equal(saddr, &rt1->rt6i_gateway)) {
                                        dst_hold(&rt1->u.dst);
                                        dst_release(&rt->u.dst);
                                        read_unlock(&rt6_lock);
                                        rt = rt1;
                                        goto source_ok;
                                }
                        }
                        read_unlock(&rt6_lock);
                }
                if (net_ratelimit())
                        printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
                               "for redirect target\n");
                goto out;
        }


And even got more complicated in commit
a6279458c534d01ccc39498aba61c93083ee0372 ("NDISC: Search over all possible
rules on receipt of redirect.").

Today we even have ECMP routes maybe making this decision even a bit
more complicated. But I agree, there should be a check, but it will be
a bit more complicated.

Greetings,

  Hannes
