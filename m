From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3] ipv6: fix incorrect route 'expires' value passed to
 userspace
Date: Wed, 25 Jul 2012 08:51:54 +0200
Message-ID: <1343199114.2626.11088.camel@edumazet-glaptop>
References: <20120719.104906.38765587582698093.davem@davemloft.net>
	 <5008B794.7010904@cn.fujitsu.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
	 <20120720.112241.2111041227435292899.davem@davemloft.net>
	 <500F8356.5040008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37695 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2GYGwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 02:52:00 -0400
Received: by bkwj10 with SMTP id j10so249720bkw.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 23:51:59 -0700 (PDT)
In-Reply-To: <500F8356.5040008@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 13:25 +0800, Li Wei wrote:
> When userspace use RTM_GETROUTE to dump route table, with an already
> expired route entry, we always got an 'expires' value(2147157)
> calculated base on INT_MAX.
> 
> The reason of this problem is in the following satement:
> 	rt->dst.expires - jiffies < INT_MAX
> gcc promoted the type of both sides of '<' to unsigned long, thus
> a small negative value would be considered greater than INT_MAX.
> 
> This patch fix this by use the same trick as time_after macro to
> avoid the 'unsigned long' type promotion and deal with jiffies
> wrapping.
> 
> Also we should do some fix in rtnl_put_cacheinfo() which use
> jiffies_to_clock_t(which take an unsigned long as parameter) to
> convert jiffies to clock_t to handle the negative expires.
> 
> With the help of David Laight, we can make the code a little clean.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> ---
>  net/core/rtnetlink.c |    3 ++-
>  net/ipv6/route.c     |   11 ++++++-----
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 334b930..2e96396 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -626,7 +626,8 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
>  	};
>  
>  	if (expires)
> -		ci.rta_expires = jiffies_to_clock_t(expires);
> +		ci.rta_expires = expires > 0 ? jiffies_to_clock_t(expires)
> +			: -jiffies_to_clock_t(-expires);
>  
>  	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
>  }
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index cf02cb9..6efeb28 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2480,12 +2480,13 @@ static int rt6_fill_node(struct net *net,
>  		goto nla_put_failure;
>  	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
>  		goto nla_put_failure;
> -	if (!(rt->rt6i_flags & RTF_EXPIRES))
> +	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
>  		expires = 0;
> -	else if (rt->dst.expires - jiffies < INT_MAX)
> -		expires = rt->dst.expires - jiffies;
> -	else
> -		expires = INT_MAX;
> +	} else {
> +		expires = (long)rt->dst.expires - (long)jiffies;
> +		if (expires != (int)expires)
> +			expires = expires > 0 ? INT_MAX : INT_MIN;
> +	}
>  
>  	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
>  		goto nla_put_failure;

All this sounds not very clean.

rtnl_put_cacheinfo( ... long expires ... )

Any out of bound checks should be done in rtnl_put_cacheinfo(), _after_
conversion to clock_t.


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 334b930..c1c950b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -625,9 +625,13 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 		.rta_id =  id,
 	};
 
-	if (expires)
-		ci.rta_expires = jiffies_to_clock_t(expires);
+	if (expires) {
+		unsigned long clock;
 
+		clock = jiffies_to_clock_t(abs(expires));
+		clock = min_t(unsigned long, clock, INT_MAX);
+		ci.rta_expires = (expires > 0) ? clock : -clock;
+	}
 	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
 }
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cf02cb9..8e80fd2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2480,12 +2480,8 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
 		goto nla_put_failure;
-	if (!(rt->rt6i_flags & RTF_EXPIRES))
-		expires = 0;
-	else if (rt->dst.expires - jiffies < INT_MAX)
-		expires = rt->dst.expires - jiffies;
-	else
-		expires = INT_MAX;
+
+	expires = (rt->rt6i_flags & RTF_EXPIRES) ? rt->dst.expires - jiffies : 0;
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
