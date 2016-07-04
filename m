From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Mon, 4 Jul 2016 22:45:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51836 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753712AbcGDTqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 15:46:01 -0400
In-Reply-To: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 4 Jul 2016, Vegard Nossum wrote:

> struct fib_nh->nh_dev can be NULL, so we should check it before calling
> __in_dev_get_rcu on it.
> 
> Multiple places seem to want this (and check the return value), so we can
> add a convenience wrapper for this.
> 
> This fixes a crash in AF_NETLINK sendmsg().
> 
> Please double check that I caught all the callers that need the NULL
> guard.

	What kind of configuration causes such crash?

> Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>  include/linux/inetdevice.h | 7 +++++++
>  net/ipv4/fib_semantics.c   | 8 ++++----
>  2 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index ee971f3..2d8bea1 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -222,6 +222,13 @@ static inline struct in_device *__in_dev_get_rtnl(const struct net_device *dev)
>  	return rtnl_dereference(dev->ip_ptr);
>  }
>  
> +static inline struct in_device *in_dev_get_rtnl(const struct net_device *dev)
> +{
> +	if (!dev)
> +		return NULL;
> +	return __in_dev_get_rtnl(dev);
> +}
> +
>  static inline struct neigh_parms *__in_dev_arp_parms_get_rcu(const struct net_device *dev)
>  {
>  	struct in_device *in_dev = __in_dev_get_rcu(dev);
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d09173b..8289799 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -545,7 +545,7 @@ static void fib_rebalance(struct fib_info *fi)
>  		if (nh->nh_flags & RTNH_F_DEAD)
>  			continue;
>  
> -		in_dev = __in_dev_get_rtnl(nh->nh_dev);
> +		in_dev = in_dev_get_rtnl(nh->nh_dev);

	fib_rebalance can not crash because for multipath
routes (fib_nhs > 1) all nexthops should have valid nh_dev.

>  
>  		if (in_dev &&
>  		    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
> @@ -559,7 +559,7 @@ static void fib_rebalance(struct fib_info *fi)
>  	change_nexthops(fi) {
>  		int upper_bound;
>  
> -		in_dev = __in_dev_get_rtnl(nexthop_nh->nh_dev);
> +		in_dev = in_dev_get_rtnl(nexthop_nh->nh_dev);
>  
>  		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
>  			upper_bound = -1;
> @@ -1261,7 +1261,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
>  			goto nla_put_failure;
>  		if (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN) {
> -			in_dev = __in_dev_get_rtnl(fi->fib_nh->nh_dev);
> +			in_dev = in_dev_get_rtnl(fi->fib_nh->nh_dev);

	Looks like this is the only place that can crash,
adding extra cycles to the other places is not good. And this
can happen only because fib_create_info() allows RTNH_F_LINKDOWN
to come for routes with error. May be fc_flags should be masked
there? Or there is another place that sets the flag when nh_dev
is NULL?

>  			if (in_dev &&
>  			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
>  				rtm->rtm_flags |= RTNH_F_DEAD;
> @@ -1292,7 +1292,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  
>  			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
>  			if (nh->nh_flags & RTNH_F_LINKDOWN) {
> -				in_dev = __in_dev_get_rtnl(nh->nh_dev);
> +				in_dev = in_dev_get_rtnl(nh->nh_dev);

	Not needed because fib_nhs > 1

>  				if (in_dev &&
>  				    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
>  					rtnh->rtnh_flags |= RTNH_F_DEAD;
> -- 

Regards
