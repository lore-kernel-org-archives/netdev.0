From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v10 01/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 28 Aug 2013 03:39:44 -0700
Message-ID: <1377686384.8828.177.camel@edumazet-glaptop>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	 <1377667379-2315-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:62870 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3H1Kjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 06:39:46 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so6102842pbb.14
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 03:39:46 -0700 (PDT)
In-Reply-To: <1377667379-2315-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 13:22 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> It will be used by vxlan.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/net/ip6_route.h |   23 +++++++++++++++++++++--
>  net/ipv6/route.c        |   19 -------------------
>  2 files changed, 21 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index f667248..2afcd0d 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
> @@ -21,6 +21,7 @@ struct route_info {
>  #include <net/flow.h>
>  #include <net/ip6_fib.h>
>  #include <net/sock.h>
> +#include <net/addrconf.h>
>  #include <linux/ip.h>
>  #include <linux/ipv6.h>
>  #include <linux/route.h>
> @@ -112,8 +113,6 @@ extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>  					   const struct in6_addr *addr,
>  					   bool anycast);
>  
> -extern int			ip6_dst_hoplimit(struct dst_entry *dst);
> -
>  /*
>   *	support functions for ND
>   *
> @@ -203,4 +202,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
>  	return dest;
>  }
>  
> +#if IS_ENABLED(CONFIG_IPV6)
> +static inline int ip6_dst_hoplimit(struct dst_entry *dst)
> +{
> +	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
> +	if (hoplimit == 0) {
> +		struct net_device *dev = dst->dev;
> +		struct inet6_dev *idev;
> +
> +		rcu_read_lock();
> +		idev = __in6_dev_get(dev);
> +		if (idev)
> +			hoplimit = idev->cnf.hop_limit;
> +		else
> +			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
> +		rcu_read_unlock();
> +	}
> +	return hoplimit;
> +}
> +#endif
> +

It probably be not inlined (10 call sites), but moved into
net/ipv6/output_core.c
