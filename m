From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] ipv4: Allow configuring subnets as local addresses
Date: Tue, 25 May 2010 07:13:51 +0930
Message-ID: <20100525071351.349d2e78@opy.nosense.org>
References: <alpine.DEB.1.00.1005232249380.18495@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:33223 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755915Ab0EYCsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 22:48:35 -0400
In-Reply-To: <alpine.DEB.1.00.1005232249380.18495@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Sun, 23 May 2010 22:54:12 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> This patch allows a host to be configured to respond to any address in
> a specified range as if it were local, without actually needing to
> configure the address on an interface.  This is done through routing
> table configuration.  For instance, to configure a host to respond
> to any address in 10.1/16 received on eth0 as a local address we can do:
> 
> ip rule add from all iif eth0 lookup 200
> ip route add local 10.1/16 dev lo proto kernel scope host src 127.0.0.1 table 200
> 
> This host is now reachable by any 10.1/16 address (route lookup on
> input for packets received on eth0 can find the route).  On output, the
> rule will not be matched so that this host can still send packets to
> 10.1/16 (not sent on loopback).  Presumably, external routing can be
> configured to make sense out of this.
> 

I'd be careful about making that assumption. IIRC, a very popular
router vendor's IP implementation treats 'connected' routes fairly
specially, and won't let you create a static route that covers a subset
of connected addresses with a next hop. IOW, connected routes,
regardless of their prefix length, win over the longest match rule, and
can't have their preference lowered. I think I got around it by
assigning a /32 to the interface, and having a static route for the
rest of the local address space pointing out the interface. It was
mostly a bit of an experiment, and probably quite unobvious to most
people if they saw it in production. I probably wouldn't want to do it
that way for that reason.

The more traditional way to have a host support multiple addresses is
to have a static route towards it for address space that is different
to what is assigned to the link between the host and the router. e.g.
[router].1-- 172.16.0/24--.2[host][10.1/16], possibly with 10.1/16
addresses assigned to (the|a) loopback or dummy interface. Would your
code work in this scenario?

Regards,
Mark.


> To make this work, we needed to modify the logic in finding the
> interface which is assigned a given source address for output
> (dev_ip_find).  We perform a normal fib_lookup instead of just a
> lookup on the local table, and in the lookup we ignore the input
> interface for matching.
> 
> This patch is useful to implement IP-anycast for subnets of virtual
> addresses.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/include/net/flow.h b/include/net/flow.h
> index bb08692..0ac3fb5 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -49,6 +49,7 @@ struct flowi {
>  	__u8	proto;
>  	__u8	flags;
>  #define FLOWI_FLAG_ANYSRC 0x01
> +#define FLOWI_FLAG_MATCH_ANY_IIF 0x02
>  	union {
>  		struct {
>  			__be16	sport;
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 42e84e0..f6e18b2 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -182,7 +182,8 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
>  {
>  	int ret = 0;
>  
> -	if (rule->iifindex && (rule->iifindex != fl->iif))
> +	if (rule->iifindex && (rule->iifindex != fl->iif) &&
> +	    !(fl->flags & FLOWI_FLAG_MATCH_ANY_IIF))
>  		goto out;
>  
>  	if (rule->oifindex && (rule->oifindex != fl->oif))
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 4f0ed45..64f953e 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -153,17 +153,16 @@ static void fib_flush(struct net *net)
>  
>  struct net_device * ip_dev_find(struct net *net, __be32 addr)
>  {
> -	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = addr } } };
> +	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = addr } },
> +			    .flags = FLOWI_FLAG_MATCH_ANY_IIF };
>  	struct fib_result res;
>  	struct net_device *dev = NULL;
> -	struct fib_table *local_table;
>  
>  #ifdef CONFIG_IP_MULTIPLE_TABLES
>  	res.r = NULL;
>  #endif
>  
> -	local_table = fib_get_table(net, RT_TABLE_LOCAL);
> -	if (!local_table || fib_table_lookup(local_table, &fl, &res))
> +	if (fib_lookup(net, &fl, &res))
>  		return NULL;
>  	if (res.type != RTN_LOCAL)
>  		goto out;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
