From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH -next] net: fib: use fib result when zero-length prefix
 aliases exist
Date: Fri, 17 Jul 2015 09:36:18 -0700
Message-ID: <55A92F02.5010306@redhat.com>
References: <1437146248-21311-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbbGQQgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 12:36:19 -0400
In-Reply-To: <1437146248-21311-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2015 08:17 AM, Florian Westphal wrote:
> default route selection is not deterministic when TOS keys are used:
>
> ip route del default
>
> ip route add tos 0x00 via 10.2.100.100
> ip route add tos 0x04 via 10.2.100.101
> ip route add tos 0x08 via 10.2.100.102
> ip route add tos 0x0C via 10.2.100.103
> ip route add tos 0x10 via 10.2.100.104
>
> [ i.e. 5 routes with prefix length 0, differentiated via TOS key ]
>
> ip route get 10.3.1.1 tos 0x4
> -> 10.2.100.101
> ip route get 10.3.1.1 tos 0x8
> -> 10.2.100.102
> ip route get tos 0x0C
> -> 10.2.100.103
>
> But for 0x10, we'll get round-robin results among all the aliases.
> Repeated queries return .100, 101, 102, etc. in turn.
>
> This behaviour is not new  -- fib_select_default can be traced back to
> fn_hash_select_default in CVS history.
>
> Routing cache made 'round-robin' behaviour less visible.
>
> This changes fib_select_default to not change the FIB chosen result EXCEPT
> if this nexthop appears to be unreachable.
>
> fib_detect_death() logic is reversed -- we consider a nexthop 'dead' only
> if it has a neigh entry in unreachable state.
>
> Only then we search fib_aliases for an alternative and use one of these in
> a round-robin fashion.  If all are believed to be unreachable, no change is
> made and fib-chosen nh_gw is used.
>
> Reported-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>   net/ipv4/fib_semantics.c | 71 ++++++++++++++++++++++++------------------------
>   1 file changed, 36 insertions(+), 35 deletions(-)
>
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index c7358ea..83b485b 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -410,28 +410,24 @@ errout:
>   		rtnl_set_sk_err(info->nl_net, RTNLGRP_IPV4_ROUTE, err);
>   }
>
> -static int fib_detect_death(struct fib_info *fi, int order,
> -			    struct fib_info **last_resort, int *last_idx,
> -			    int dflt)
> +static bool fib_nud_is_unreach(const struct fib_info *fi)
>   {
>   	struct neighbour *n;
>   	int state = NUD_NONE;
>
> -	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
> -	if (n) {
> +	local_bh_disable();
> +
> +	n = __neigh_lookup_noref(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
> +	if (n)
>   		state = n->nud_state;
> -		neigh_release(n);
> -	}
> -	if (state == NUD_REACHABLE)
> -		return 0;
> -	if ((state & NUD_VALID) && order != dflt)
> -		return 0;
> -	if ((state & NUD_VALID) ||
> -	    (*last_idx < 0 && order > dflt)) {
> -		*last_resort = fi;
> -		*last_idx = order;
> -	}
> -	return 1;
> +
> +	local_bh_enable();
> +
> +	/* Caller might be able to find alternate (reachable) nexthop */
> +	if (state & (NUD_INCOMPLETE | NUD_FAILED))
> +		return true;
> +
> +	return false;
>   }
>
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> @@ -1204,12 +1200,17 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
>   /* Must be invoked inside of an RCU protected region.  */
>   void fib_select_default(struct fib_result *res)
>   {
> -	struct fib_info *fi = NULL, *last_resort = NULL;
>   	struct hlist_head *fa_head = res->fa_head;
> +	struct fib_info *last_resort = NULL;
>   	struct fib_table *tb = res->table;
>   	int order = -1, last_idx = -1;
>   	struct fib_alias *fa;
> +	bool unreach = fib_nud_is_unreach(res->fi);
>
> +	if (likely(!unreach))
> +		return;
> +

There probably isn't any need for the boolean variable.  You could just 
place the function in the if statement itself.

> +	/* attempt to pick another nexthop */
>   	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
>   		struct fib_info *next_fi = fa->fa_info;
>
> @@ -1223,33 +1224,33 @@ void fib_select_default(struct fib_result *res)
>   		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
>   			continue;
>
> +		order++;
> +
> +		if (next_fi == res->fi) /* already tested, not reachable */
> +			continue;
> +
>   		fib_alias_accessed(fa);
>
> -		if (!fi) {
> -			if (next_fi != res->fi)
> +		unreach = fib_nud_is_unreach(next_fi);
> +		if (unreach)
> +			continue;
> +

Same here.  It seems like this is just an extra variable that isn't 
really needed.

> +		/* try to round-robin among all fa_aliases in case
> +		 * res->fi nexthop is unreachable.
> +		 */
> +		if (last_idx < 0 || order > tb->tb_default) {
> +			last_resort = next_fi;
> +			last_idx = order;
> +			if (order > tb->tb_default)
>   				break;

You might want to update the variable naming as it can be a bit 
confusing.  The last_resort and last_idx represent either the first 
fib_info and index, or the next one after current entry in tb_default. 
Since you aren't using fi anymore you might use that variable name 
instead just to make this more readable.

> -		} else if (!fib_detect_death(fi, order, &last_resort,
> -					     &last_idx, tb->tb_default)) {
> -			fib_result_assign(res, fi);
> -			tb->tb_default = order;
> -			goto out;
>   		}
> -		fi = next_fi;
> -		order++;
>   	}
>
> -	if (order <= 0 || !fi) {
> +	if (order < 0) {
>   		tb->tb_default = -1;
>   		goto out;
>   	}
>

You can probably just get rid of this statement entirely.  If order < 0 
then last_idx should be -1 as well.  In which case the code below should 
handle it correctly anyway.

> -	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
> -				tb->tb_default)) {
> -		fib_result_assign(res, fi);
> -		tb->tb_default = order;
> -		goto out;
> -	}
> -
>   	if (last_idx >= 0)
>   		fib_result_assign(res, last_resort);
>   	tb->tb_default = last_idx;
>
