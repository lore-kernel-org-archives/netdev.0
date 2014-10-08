From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 net 2/2] ipv6: Avoid restarting fib6_lookup()
 for RTF_CACHE hit case
Date: Wed, 08 Oct 2014 15:32:54 -0400 (EDT)
Message-ID: <20141008.153254.1700572195760396537.davem@davemloft.net>
References: <1412640315-22472-1-git-send-email-kafai@fb.com>
	<1412640315-22472-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234AbaJHTc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 15:32:57 -0400
In-Reply-To: <1412640315-22472-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 6 Oct 2014 17:05:15 -0700

> When there is a RTF_CACHE hit, no need to redo fib6_lookup()
> with reachable=0.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Ok this looks fine, and I can see how there is a dependency with patch
#1.

But I also want to point out how this change show my point about
BACKTRACK() even more.  Read this function after this patch is
applied and someone auditing might say "oh, 'out' label is now
unused, we can remove it"

Again, hidden control flow is really bad, and we've had very serious
bugs in the past because of it (which we've fixed by ditching the
side effect causing macros in favor of properly designed inline
functions).

Trying to be constructive, why don't we go in a direction like
the following?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a318dd89..99612c5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -772,6 +772,26 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 }
 #endif
 
+static struct fib6_node *rt6_backtrack(struct net *net, struct rt6_info *rt, struct fib6_node *fn, const struct in6_addr *saddr)
+{
+	if (rt == net->ipv6.ip6_null_entry) {
+		struct fib6_node *pn;
+
+		while (1) {
+			if (fn->fn_flags & RTN_TL_ROOT)
+				break;
+			pn = fn->parent;
+			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn)
+				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr);
+			else
+				fn = pn;
+			if (fn->fn_flags & RTN_RTINFO)
+				break;
+		}
+	}
+	return fn;
+}
+
 #define BACKTRACK(__net, saddr)			\
 do { \
 	if (rt == __net->ipv6.ip6_null_entry) {	\
@@ -934,10 +954,15 @@ restart:
 	rt = rt6_select(fn, oif, strict | reachable);
 	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
-	BACKTRACK(net, &fl6->saddr);
-	if (rt == net->ipv6.ip6_null_entry ||
-	    rt->rt6i_flags & RTF_CACHE)
-		goto out;
+	fn = rt6_backtrack(net, rt, fn, &fl6->saddr);
+	if (rt == net->ipv6.ip6_null_entry) {
+		if (fn->fn_flags & RTN_TL_ROOT)
+			goto out;
+		if (fn->fn_flags & RTN_RTINFO)
+			goto restart;
+	}
+	if (rt->rt6i_flags & RTF_CACHE)
+		goto out1;
 
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
@@ -974,6 +999,7 @@ out:
 		reachable = 0;
 		goto restart_2;
 	}
+out1:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 out2:
