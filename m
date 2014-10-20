From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v5 net 1/3] ipv6: Remove BACKTRACK macro
Date: Mon, 20 Oct 2014 13:42:43 -0700
Message-ID: <1413837765-5446-2-git-send-email-kafai@fb.com>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:2144 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753292AbaJTUnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 16:43:46 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s9KKckpK023718
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 13:43:46 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1q58f6082r-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 13:43:45 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c7ab505a589911e48e9b24be0595f910-d6ae73e0 for <netdev@vger.kernel.org>;	Mon,
 20 Oct 2014 13:43:43 -0700
In-Reply-To: <1413837765-5446-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is the prep work to reduce the number of calls to fib6_lookup().

The BACKTRACK macro could be hard-to-read and error-prone due to
its side effects (mainly goto).

This patch is to:
1. Replace BACKTRACK macro with a function (fib6_backtrack) with the following
   return values:
   * If it is backtrack-able, returns next fn for retry.
   * If it reaches the root, returns NULL.
2. The caller needs to decide if a backtrack is needed (by testing
   rt == net->ipv6.ip6_null_entry).
3. Rename the goto labels in ip6_pol_route() to make the next few
   patches easier to read.

Cc: David Miller <davem@davemloft.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 70 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a318dd89..f1ab2f4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -772,23 +772,22 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 }
 #endif
 
-#define BACKTRACK(__net, saddr)			\
-do { \
-	if (rt == __net->ipv6.ip6_null_entry) {	\
-		struct fib6_node *pn; \
-		while (1) { \
-			if (fn->fn_flags & RTN_TL_ROOT) \
-				goto out; \
-			pn = fn->parent; \
-			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn) \
-				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr); \
-			else \
-				fn = pn; \
-			if (fn->fn_flags & RTN_RTINFO) \
-				goto restart; \
-		} \
-	} \
-} while (0)
+static struct fib6_node* fib6_backtrack(struct fib6_node *fn,
+					struct in6_addr *saddr)
+{
+	struct fib6_node *pn;
+	while (1) {
+		if (fn->fn_flags & RTN_TL_ROOT)
+			return NULL;
+		pn = fn->parent;
+		if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn)
+			fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr);
+		else
+			fn = pn;
+		if (fn->fn_flags & RTN_RTINFO)
+			return fn;
+	}
+}
 
 static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 					     struct fib6_table *table,
@@ -804,8 +803,11 @@ restart:
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
 	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
 		rt = rt6_multipath_select(rt, fl6, fl6->flowi6_oif, flags);
-	BACKTRACK(net, &fl6->saddr);
-out:
+	if (rt == net->ipv6.ip6_null_entry) {
+		fn = fib6_backtrack(fn, &fl6->saddr);
+		if (fn)
+			goto restart;
+	}
 	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
 	return rt;
@@ -924,19 +926,25 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 
-relookup:
+redo_fib6_lookup_lock:
 	read_lock_bh(&table->tb6_lock);
 
-restart_2:
+redo_fib6_lookup:
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 
-restart:
+redo_rt6_select:
 	rt = rt6_select(fn, oif, strict | reachable);
 	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
-	BACKTRACK(net, &fl6->saddr);
-	if (rt == net->ipv6.ip6_null_entry ||
-	    rt->rt6i_flags & RTF_CACHE)
+	if (rt == net->ipv6.ip6_null_entry) {
+		fn = fib6_backtrack(fn, &fl6->saddr);
+		if (fn)
+			goto redo_rt6_select;
+		else
+			goto out;
+	}
+
+	if (rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
 	dst_hold(&rt->dst);
@@ -967,12 +975,12 @@ restart:
 	 * released someone could insert this route.  Relookup.
 	 */
 	ip6_rt_put(rt);
-	goto relookup;
+	goto redo_fib6_lookup_lock;
 
 out:
 	if (reachable) {
 		reachable = 0;
-		goto restart_2;
+		goto redo_fib6_lookup;
 	}
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
@@ -1235,10 +1243,12 @@ restart:
 		rt = net->ipv6.ip6_null_entry;
 	else if (rt->dst.error) {
 		rt = net->ipv6.ip6_null_entry;
-		goto out;
+	} else if (rt == net->ipv6.ip6_null_entry) {
+		fn = fib6_backtrack(fn, &fl6->saddr);
+		if (fn)
+			goto restart;
 	}
-	BACKTRACK(net, &fl6->saddr);
-out:
+
 	dst_hold(&rt->dst);
 
 	read_unlock_bh(&table->tb6_lock);
-- 
1.8.1
