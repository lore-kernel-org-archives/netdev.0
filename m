From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: Move rth handling from
 ip_route_input_slow to helper
Date: Tue, 22 Sep 2015 19:33:24 -0700
Message-ID: <56020F74.8000605@gmail.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <1442962523-3974-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35496 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069AbbIWCd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 22:33:26 -0400
Received: by pacfv12 with SMTP id fv12so26604873pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 19:33:25 -0700 (PDT)
In-Reply-To: <1442962523-3974-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2015 03:55 PM, David Ahern wrote:
> Move the rth lookup and allocation from ip_route_input_slow into a
> helper function. Code move only; no operational change intended.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   net/ipv4/route.c | 104 ++++++++++++++++++++++++++++++++-----------------------
>   1 file changed, 60 insertions(+), 44 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e3b18cc1952f..79c4cecdb7a1 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1667,6 +1667,63 @@ static int ip_mkroute_input(struct sk_buff *skb,
>   	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
>   }
>
> +static int ip_route_local_input(struct sk_buff *skb,
> +				struct fib_result *res,
> +				struct net_device *loopback_dev,
> +				unsigned int flags,
> +				u32 itag,
> +				int rth_err,
> +				bool nopolicy)

Why pass loopback_dev instead of just passing the net pointer?  Seems 
like in the path below there are cases where you end up not needing to 
dereference it and it might be worth the effort to avoid dereferencing 
it if you don't need to.

Same thing for nopolicy.  Why not just pass the in_dev pointer and 
handle getting the policy if you need it.

> +{
> +	bool do_cache = false;
> +	struct rtable *rth;
> +	int err = 0;
> +
> +	if (res->fi) {
> +		if (!itag) {
> +			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
> +			if (rt_cache_valid(rth)) {
> +				skb_dst_set_noref(skb, &rth->dst);
> +				goto out;
> +			}
> +			do_cache = true;
> +		}
> +	}
> +
> +	rth = rt_dst_alloc(loopback_dev, flags | RTCF_LOCAL, res->type,
> +			   nopolicy, false, do_cache);
> +	if (!rth) {
> +		err = -ENOBUFS;
> +		goto out;
> +	}
> +
> +	rth->dst.output = ip_rt_bug;
> +#ifdef CONFIG_IP_ROUTE_CLASSID
> +	rth->dst.tclassid = itag;
> +#endif
> +	rth->rt_is_input = 1;
> +	if (res->table)
> +		rth->rt_table_id = res->table->tb_id;
> +
> +	RT_CACHE_STAT_INC(in_slow_tot);
> +	if (res->type == RTN_UNREACHABLE) {
> +		rth->dst.input = ip_error;
> +		rth->dst.error = -rth_err;
> +		rth->rt_flags &= ~RTCF_LOCAL;
> +	}
> +
> +	if (do_cache) {
> +		if (unlikely(!rt_cache_route(&FIB_RES_NH(*res), rth))) {
> +			rth->dst.flags |= DST_NOCACHE;
> +			rt_add_uncached_list(rth);
> +		}
> +	}
> +	skb_dst_set(skb, &rth->dst);
> +
> +out:
> +	return err;
> +}
> +
>   /*
>    *	NOTE. We drop all the packets that has local source
>    *	addresses, because every properly looped back packet
> @@ -1687,10 +1744,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>   	struct flowi4	fl4;
>   	unsigned int	flags = 0;
>   	u32		itag = 0;
> -	struct rtable	*rth;
>   	int		err = -EINVAL;
>   	struct net    *net = dev_net(dev);
> -	bool do_cache;
>
>   	/* IP on this device is disabled. */
>
> @@ -1790,48 +1845,9 @@ out:	return err;
>   	RT_CACHE_STAT_INC(in_brd);
>
>   local_input:
> -	do_cache = false;
> -	if (res.fi) {
> -		if (!itag) {
> -			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
> -			if (rt_cache_valid(rth)) {
> -				skb_dst_set_noref(skb, &rth->dst);
> -				err = 0;
> -				goto out;
> -			}
> -			do_cache = true;
> -		}
> -	}
> -
> -	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
> -			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
> -	if (!rth) {
> -		err = -ENOBUFS;
> -		goto out;
> -	}
> -
> -	rth->dst.output= ip_rt_bug;
> -#ifdef CONFIG_IP_ROUTE_CLASSID
> -	rth->dst.tclassid = itag;
> -#endif
> -	rth->rt_is_input = 1;
> -	if (res.table)
> -		rth->rt_table_id = res.table->tb_id;
> -
> -	RT_CACHE_STAT_INC(in_slow_tot);
> -	if (res.type == RTN_UNREACHABLE) {
> -		rth->dst.input= ip_error;
> -		rth->dst.error= -err;
> -		rth->rt_flags 	&= ~RTCF_LOCAL;
> -	}
> -	if (do_cache) {
> -		if (unlikely(!rt_cache_route(&FIB_RES_NH(res), rth))) {
> -			rth->dst.flags |= DST_NOCACHE;
> -			rt_add_uncached_list(rth);
> -		}
> -	}
> -	skb_dst_set(skb, &rth->dst);
> -	err = 0;
> +	err = ip_route_local_input(skb, &res, net->loopback_dev,
> +				   flags, itag, err,
> +				   IN_DEV_CONF_GET(in_dev, NOPOLICY));
>   	goto out;
>
>   no_route:
>
