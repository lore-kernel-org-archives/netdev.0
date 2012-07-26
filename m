From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 19:43:53 +0200
Message-ID: <1343324633.2626.11801.camel@edumazet-glaptop>
References: <1343290414.2626.11181.camel@edumazet-glaptop>
	 <20120726.011853.973075299731735416.davem@davemloft.net>
	 <1343291278.2626.11188.camel@edumazet-glaptop>
	 <20120726.014736.1066206957795563053.davem@davemloft.net>
	 <CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
	 <1343323858.2626.11783.camel@edumazet-glaptop>
	 <1343324175.2626.11790.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57217 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2GZRn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 13:43:58 -0400
Received: by bkwj10 with SMTP id j10so1430591bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 10:43:57 -0700 (PDT)
In-Reply-To: <1343324175.2626.11790.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 19:36 +0200, Eric Dumazet wrote:
> On Thu, 2012-07-26 at 19:31 +0200, Eric Dumazet wrote:
> > On Thu, 2012-07-26 at 10:18 -0700, Alexander Duyck wrote:
> > 
> > > I tested this patch and it looks like it runs, but still has the same
> > > performance issue.  I did some digging into the annotation for
> > > ip_route_intput_noref and it seems like the issue is that I am hitting
> > > the dst_hold call in  __mkroute_input.
> > 
> > David suggested a percpu cache.
> > 
> > nh_rth_input would be allocated by alloc_percpu(struct dst *)
> > 
> > I can work on this.
> 
> Wait a minute, on input we should use the noref trick too.
> 

Something like : (on top of latest David patch)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7a591aa..d5d2ad1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1371,8 +1371,7 @@ static void ip_handle_martian_source(struct net_device *dev,
 static int __mkroute_input(struct sk_buff *skb,
 			   const struct fib_result *res,
 			   struct in_device *in_dev,
-			   __be32 daddr, __be32 saddr, u32 tos,
-			   struct rtable **result)
+			   __be32 daddr, __be32 saddr, u32 tos)
 {
 	struct rtable *rth;
 	int err;
@@ -1423,7 +1422,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		if (!itag) {
 			rth = FIB_RES_NH(*res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
-				dst_hold(&rth->dst);
+				skb_dst_set_noref(skb, &rth->dst);
 				goto out;
 			}
 			do_cache = true;
@@ -1451,7 +1450,6 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
 out:
-	*result = rth;
 	err = 0;
  cleanup:
 	return err;
@@ -1463,21 +1461,13 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-	struct rtable *rth = NULL;
-	int err;
-
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
 		fib_select_multipath(res);
 #endif
 
 	/* create a routing cache entry */
-	err = __mkroute_input(skb, res, in_dev, daddr, saddr, tos, &rth);
-	if (err)
-		return err;
-
-	skb_dst_set(skb, &rth->dst);
-	return 0;
+	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 }
 
 /*
