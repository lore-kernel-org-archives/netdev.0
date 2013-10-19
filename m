From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Sat, 19 Oct 2013 10:53:42 +0200
Message-ID: <20131019085342.GB31333@order.stressinduktion.org>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net> <20131018030440.GI18135@order.stressinduktion.org> <5260D8DE.30303@blub.net> <20131019084225.GA31333@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Valentijn Sessink <valentyn@blub.net>, netdev@vger.kernel.org,
	sgunderson@bigfoot.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44478 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab3JSIxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 04:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20131019084225.GA31333@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 10:42:25AM +0200, Hannes Frederic Sowa wrote:
> This patch should fix this:
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c3130ff..7629022 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1064,10 +1064,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
>  	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
>  		return NULL;
>  
> -	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
> -		return dst;
> +	if (!rt->rt6i_node && (rt->rt6i_node->fn_sernum != cookie))
> +		return NULL;

I just rewrote this patch to have a clean diff. I missed to rewrite the '&&'
to '||'.

Correct patch is:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3130ff..17b3cc1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1064,10 +1064,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
 		return NULL;
 
-	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
-		return dst;
+	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
+		return NULL;
 
-	return NULL;
+	if (rt6_check_expired(rt))
+		return NULL;
+
+	return dst;
 }
 
 static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)
