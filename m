From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Fri, 1 Jun 2007 02:18:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0706010123020.2683@u.domain.uli>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli> <200705301138.29582@nienna>
 <Pine.LNX.4.58.0705310239240.3745@u.domain.uli> <200705311450.36492@nienna>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	horms@verge.net.au, jkrzyszt@tis.icnet.pl, netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:4928 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750822AbXEaXTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 19:19:11 -0400
In-Reply-To: <200705311450.36492@nienna>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 31 May 2007, KOVACS Krisztian wrote:

>   So what about this one?

	May be we can try with better coding style. Also, this version
adds undefined behavior for using FLOWI_FLAG_ANYSRC with multicast
oldflp->fl4_dst

> Loosen source address check on IPv4 output
> 
> From: KOVACS Krisztian <hidden@balabit.hu>
> 
> ip_route_output() contains a check to make sure that no flows with
> non-local source IP addresses are routed. This obviously makes using
> such addresses impossible.
> 
> This patch introduces a flowi flag which makes omitting this check
> possible. The new flag provides a way of handling transparent and
> non-transparent connections differently.
> 
> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
> ---
> 
>  include/net/flow.h |    1 +
>  net/ipv4/route.c   |   47 +++++++++++++++++++++++++----------------------
>  2 files changed, 26 insertions(+), 22 deletions(-)
> 
> diff --git a/include/net/flow.h b/include/net/flow.h
> index f3cc1f8..1bfc0dc 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -49,6 +49,7 @@ struct flowi {
>  	__u8	proto;
>  	__u8	flags;
>  #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x01
> +#define FLOWI_FLAG_ANYSRC 0x02
>  	union {
>  		struct {
>  			__be16	sport;
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 8603cfb..88d0a79 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2396,7 +2396,7 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
>  
>  		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
>  		dev_out = ip_dev_find(oldflp->fl4_src);
> -		if (dev_out == NULL)
> +		if (dev_out == NULL && !(oldflp->flags & FLOWI_FLAG_ANYSRC))
>  			goto out;
>  
>  		/* I removed check for oif == dev_out->oif here.
> @@ -2407,29 +2407,32 @@ static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
>  		      of another iface. --ANK
>  		 */
>  
> -		if (oldflp->oif == 0
> -		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
> -			/* Special hack: user can direct multicasts
> -			   and limited broadcast via necessary interface
> -			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
> -			   This hack is not just for fun, it allows
> -			   vic,vat and friends to work.
> -			   They bind socket to loopback, set ttl to zero
> -			   and expect that it will work.
> -			   From the viewpoint of routing cache they are broken,
> -			   because we are not allowed to build multicast path
> -			   with loopback source addr (look, routing cache
> -			   cannot know, that ttl is zero, so that packet
> -			   will not leave this host and route is valid).
> -			   Luckily, this hack is good workaround.
> -			 */
> +		if (dev_out) {
> +			if (oldflp->oif == 0
> +			    && (MULTICAST(oldflp->fl4_dst)
> +				|| oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
> +				/* Special hack: user can direct multicasts
> +				   and limited broadcast via necessary interface
> +				   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
> +				   This hack is not just for fun, it allows
> +				   vic,vat and friends to work.
> +				   They bind socket to loopback, set ttl to zero
> +				   and expect that it will work.
> +				   From the viewpoint of routing cache they are broken,
> +				   because we are not allowed to build multicast path
> +				   with loopback source addr (look, routing cache
> +				   cannot know, that ttl is zero, so that packet
> +				   will not leave this host and route is valid).
> +				   Luckily, this hack is good workaround.
> +				*/
> +
> +				fl.oif = dev_out->ifindex;
> +				goto make_route;
> +			}
>  
> -			fl.oif = dev_out->ifindex;
> -			goto make_route;
> -		}
> -		if (dev_out)
>  			dev_put(dev_out);
> -		dev_out = NULL;
> +			dev_out = NULL;
> +		}
>  	}

	What about something like this, it even reduces checks
in the fast path. You can post new version if the following change
looks good to you and to other developers. If additional sign line is 
needed here it is:

Signed-off-by: Julian Anastasov <ja@ssi.bg>

@@ -2396,8 +2396,6 @@ static int ip_route_output_slow(struct r
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
@@ -2409,6 +2407,8 @@ static int ip_route_output_slow(struct r
 
 		if (oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+			if (dev_out == NULL)
+				goto out;
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2427,9 +2427,11 @@ static int ip_route_output_slow(struct r
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
+		if (dev_out) {
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		} else if (!(oldflp->flags & FLOWI_FLAG_ANYSRC))
+			goto out;
 	}
 
 

	Or we can go further and to avoid ip_dev_find? For me, this
second variant is preferred because calling ip_dev_find() is useless for
FLOWI_FLAG_ANYSRC.

@@ -2394,11 +2394,6 @@ static int ip_route_output_slow(struct r
 		    ZERONET(oldflp->fl4_src))
 			goto out;
 
-		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
-
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
 		   1. ip_dev_find(saddr) can return wrong iface, if saddr is
@@ -2409,6 +2404,11 @@ static int ip_route_output_slow(struct r
 
 		if (oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
+
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
@@ -2427,9 +2427,14 @@ static int ip_route_output_slow(struct r
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
+		if (!(oldflp->flags & FLOWI_FLAG_ANYSRC)) {
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
 			dev_put(dev_out);
-		dev_out = NULL;
+			dev_out = NULL;
+		}
 	}
 
 
