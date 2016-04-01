From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next] net: ipv4: Consider unreachable nexthops in
 multipath routes
Date: Fri, 1 Apr 2016 11:09:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604011005480.2190@ja.home.ssi.bg>
References: <1459463081-20206-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58089 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753249AbcDAIJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2016 04:09:11 -0400
In-Reply-To: <1459463081-20206-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 31 Mar 2016, David Ahern wrote:

> To maintain backward compatibility use of the neighbor information is
> based on a new sysctl, fib_multipath_use_neigh.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
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
>  net/ipv4/fib_semantics.c               | 32 ++++++++++++++++++++++++++++++--
>  net/ipv4/sysctl_net_ipv4.c             | 11 +++++++++++
>  4 files changed, 54 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index b183e2b606c8..5b316d33a23f 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -63,6 +63,16 @@ fwmark_reflect - BOOLEAN
>  	fwmark of the packet they are replying to.
>  	Default: 0
>  
> +fib_multipath_use_neigh - BOOLEAN
> +	Use status of existing neighbor entry when determining nexthop for
> +	multipath routes. If disabled neighbor information is not used then
> +	packets could be directed to a dead nexthop. Only valid for kernels

	Some may associate "dead" with RTNH_F_DEAD while
in context of nexthop "failed" or "unreachable" can be
more suitable? Can we use something like this?:

	If disabled<COMMA_ALLOWED_HERE?> neighbor information is not used
and packets could be directed to a failed nexthop.

> +	built with CONFIG_IP_ROUTE_MULTIPATH enabled.
> +	Default: 0 (disabled)
> +	Possible values:
> +	0 - disabled
> +	1 - enabled
> +
>  route/max_size - INTEGER
>  	Maximum number of routes allowed in the kernel.  Increase
>  	this when using large numbers of interfaces and/or routes.
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index a69cde3ce460..d061ffeb1e71 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -133,6 +133,9 @@ struct netns_ipv4 {
>  	struct fib_rules_ops	*mr_rules_ops;
>  #endif
>  #endif
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +	int sysctl_fib_multipath_use_neigh;
> +#endif
>  	atomic_t	rt_genid;
>  };
>  #endif
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d97268e8ff10..6d423faff0ce 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1559,17 +1559,45 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>  }
>  
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> +static bool fib_good_nh(const struct fib_nh *nh, struct net_device *dev)
> +{
> +	struct neighbour *n = NULL;
> +	int state = NUD_NONE;

	Looks like we can do it even better.
If we use NUD_REACHABLE here...

> +
> +	if (nh->nh_scope == RT_SCOPE_LINK) {
> +		rcu_read_lock_bh();
> +
> +		n = __neigh_lookup_noref(&arp_tbl, &nh->nh_gw, dev);
> +		if (n)
> +			state = n->nud_state;
> +
> +		rcu_read_unlock_bh();
> +	}
> +
> +	/* outside of rcu locking using n only as a boolean
> +	 * on whether a neighbor entry existed
> +	 */
> +	if (!n || (state & NUD_VALID))

	then check for '!n' is not needed. For bool type
'return state & NUD_VALID;' should work.

> +		return true;
> +
> +	return false;
> +}
>  
>  void fib_select_multipath(struct fib_result *res, int hash)
>  {
>  	struct fib_info *fi = res->fi;
> +	struct net_device *dev = fi->fib_dev;
> +	struct net *net = fi->fib_net;
>  
>  	for_nexthops(fi) {
>  		if (hash > atomic_read(&nh->nh_upper_bound))
>  			continue;
>  
> -		res->nh_sel = nhsel;
> -		return;
> +		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
> +		    fib_good_nh(nh, dev)) {

	This dev is from first nexthop. Better fib_good_nh
to use nh->nh_dev instead, it is present for all nexthops
in multipath route. We should not copy the bugs from
fib_detect_death.

> +			res->nh_sel = nhsel;
> +			return;
> +		}
>  	} endfor_nexthops(fi);

	So, you dropped the idea to give full chance for
fallback? Now if last nexthop fails we do not fallback at all.
We promised to prefer reachable nexthops.

Regards
