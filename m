From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Fri, 1 Apr 2016 22:51:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604012211510.1833@ja.home.ssi.bg>
References: <1459523824-29828-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47840 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750750AbcDATvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2016 15:51:49 -0400
In-Reply-To: <1459523824-29828-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 1 Apr 2016, David Ahern wrote:

> v3
> - Julian comments: changed use of dead in documentation to failed,
>   init state to NUD_REACHABLE which simplifies fib_good_nh, use of
>   nh_dev for neighbor lookup, fallback to first entry which is what
>   current logic does
> 
> v2
> - use rcu locking to avoid refcnts per Eric's suggestion
> - only consider neighbor info for nh_scope == RT_SCOPE_LINK per Julian's
>   comment
> - drop the 'state == NUD_REACHABLE' from the state check since it is
>   part of NUD_VALID (comment from Julian)
> - wrapped the use of the neigh in a sysctl
> 
>  Documentation/networking/ip-sysctl.txt | 10 ++++++++++
>  include/net/netns/ipv4.h               |  3 +++
>  net/ipv4/fib_semantics.c               | 32 ++++++++++++++++++++++++++++----
>  net/ipv4/sysctl_net_ipv4.c             | 11 +++++++++++
>  4 files changed, 52 insertions(+), 4 deletions(-)
> 

> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d97268e8ff10..e08abf96824a 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1559,21 +1559,45 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>  }
>  
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> +static bool fib_good_nh(const struct fib_nh *nh)
> +{
> +	int state = NUD_REACHABLE;
> +
> +	if (nh->nh_scope == RT_SCOPE_LINK) {
> +		struct neighbour *n = NULL;

	NULL is not needed anymore.

> +
> +		rcu_read_lock_bh();
> +
> +		n = __neigh_lookup_noref(&arp_tbl, &nh->nh_gw, nh->nh_dev);
> +		if (n)
> +			state = n->nud_state;
> +
> +		rcu_read_unlock_bh();
> +	}
> +
> +	return !!(state & NUD_VALID);
> +}
>  
>  void fib_select_multipath(struct fib_result *res, int hash)
>  {
>  	struct fib_info *fi = res->fi;
> +	struct net *net = fi->fib_net;
> +	unsigned char first_nhsel = 0;

	Looking at fib_table_lookup() res->nh_sel is not 0
in all cases. I personally don't like that we do not
fallback properly but to make this logic more correct we
can use something like this:

	bool first = false;

>  
>  	for_nexthops(fi) {
>  		if (hash > atomic_read(&nh->nh_upper_bound))
>  			continue;
>  
> -		res->nh_sel = nhsel;
> -		return;
> +		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
> +		    fib_good_nh(nh)) {
> +			res->nh_sel = nhsel;
> +			return;
> +		}
> +		if (!first_nhsel)
> +			first_nhsel = nhsel;

		if (!first) {
			res->nh_sel = nhsel;
			first = true;
		}

>  	} endfor_nexthops(fi);
>  
> -	/* Race condition: route has just become dead. */
> -	res->nh_sel = 0;
> +	res->nh_sel = first_nhsel;

	And then this is not needed anymore. Even setting
to 0 was not needed because 0 is not better than current
nh_sel when both are DEAD/LINKDOWN.

Regards
