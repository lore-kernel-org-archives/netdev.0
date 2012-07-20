From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 14/16] ipv4: Kill rt->rt_oif
Date: Fri, 20 Jul 2012 04:10:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207200219010.5516@ja.ssi.bg>
References: <20120719.143616.1125314165355374962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38263 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066Ab2GTBC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:02:56 -0400
In-Reply-To: <20120719.143616.1125314165355374962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	Added CC to Patrick McHardy as mrule author...

On Thu, 19 Jul 2012, David Miller wrote:

> Never actually used.
> 
> It was being set on output routes to the original OIF specified in the
> flow key used for the lookup.
> 
> But the only user was in ipmr_rt_fib_lookup() which always runs on an
> input route.

	It can also work with output route, it seems
copy of locally originated traffic can be sent to local
mrouter for forwarding to remote recipients. Now we search
this mrouter with rules. We can loopback traffic to
local applications or to local multicast router (even
when no local applications are listening).

> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index eee3bf6..fa75f73 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -1795,7 +1795,6 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
>  		.daddr = iph->daddr,
>  		.saddr = iph->saddr,
>  		.flowi4_tos = RT_TOS(iph->tos),
> -		.flowi4_oif = rt->rt_oif,
>  		.flowi4_iif = rt->rt_iif,
>  		.flowi4_mark = skb->mark,

	But it was wrong at first place to use rt_iif
here. May be we should provide devices to "mrule" just
like we do for "rule", with the only difference that
oif now is possible to match outdev instead of preferred
device, i.e. oif is always set for output routes.

	.flowi4_oif = rt_is_output_route(rt) ?
			skb->dev->ifindex : 0,
	.flowi4_iif = rt_is_output_route(rt) ?
			net->loopback_dev->ifindex :
			skb->dev->ifindex;

	Before now it was risky to use just "mrule iif XXX"
because rt_iif contains the output device for output
routes and we can match output route by mistake.

	With above code it is now safe to use just
"iif eth0" for input routes and "iif lo" for output
routes. Here is what will see the mrule now:

local_app -> mrouter: lo->dev
remote_app -> mrouter: dev->0 (only iif match is possible)

	Let me know if patch is needed

> @@ -1802,7 +1799,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>  	rth->rt_type	= type;
>  	rth->rt_route_iif = 0;
>  	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
> -	rth->rt_oif	= orig_oif;
>  	rth->rt_pmtu	= 0;
>  	rth->rt_gateway = 0;
>  	rth->fi = NULL;

Regards

--
Julian Anastasov <ja@ssi.bg>
