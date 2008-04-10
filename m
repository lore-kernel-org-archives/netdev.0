From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 01:51:18 -0700 (PDT)
Message-ID: <20080410.015118.103465510.davem@davemloft.net>
References: <20080401004724.601457403@vyatta.com>
	<47F1CD83.8090905@cosmosbay.com>
	<20080401130842.579e0ebc@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753197AbYDJIvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:51:17 -0400
In-Reply-To: <20080401130842.579e0ebc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Apr 2008 13:08:42 -0700

> The flow fields are all together, and the other parameters are local variables
> in registers so that compare should be in one cache line.
> 
> --- a/net/ipv4/route.c	2008-03-31 17:12:30.000000000 -0700
> +++ b/net/ipv4/route.c	2008-04-01 13:05:46.000000000 -0700
> @@ -2079,12 +2079,12 @@ int ip_route_input(struct sk_buff *skb, 
>  	rcu_read_lock();
>  	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
>  	     rth = rcu_dereference(rth->u.dst.rt_next)) {
> -		if (rth->fl.fl4_dst == daddr &&
> -		    rth->fl.fl4_src == saddr &&
> -		    rth->fl.iif == iif &&
> -		    rth->fl.oif == 0 &&
> +		if (((rth->fl.fl4_dst ^ daddr) |
> +		     (rth->fl.fl4_src ^ saddr) |
> +		     (rth->fl.iif ^ iif) |
> +		     rth->fl.oif |
> +		     (rth->fl.fl4_tos ^ tos)) == 0 &&
>  		    rth->fl.mark == skb->mark &&
> -		    rth->fl.fl4_tos == tos &&
>  		    net_eq(dev_net(rth->u.dst.dev), net) &&
>  		    rth->rt_genid == atomic_read(&rt_genid)) {
>  			dst_use(&rth->u.dst, jiffies);

Eric, any objections to this version?
