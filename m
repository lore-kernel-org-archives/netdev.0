From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v4 net 3/3] ipv6: Avoid redo-ing fib6_lookup() with reachable = 0 by saving fn
Date: Fri, 10 Oct 2014 11:48:08 -0700
Message-ID: <1412966888-31384-4-git-send-email-kafai@fb.com>
References: <1412966888-31384-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39515 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbaJJSsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:48:16 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s9AIkIi6026445
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1pxahr288p-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:48:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 fd9e13b250ad11e48f4a0002c99293a0-84bfd3e0 for <netdev@vger.kernel.org>;	Fri,
 10 Oct 2014 11:48:14 -0700
In-Reply-To: <1412966888-31384-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch saves the fn before doing rt6_backtrack.
Hence, without redo-ing the fib6_lookup(), saved_fn can be used
to redo rt6_select() with RT6_LOOKUP_F_REACHABLE off.

Some minor changes I think make sense to review as a single patch:
* Remove the 'out:' goto label.
* Remove the 'reachable' variable.

After this patch, "failing ip6_ins_rt()" is the only case that
requires a redo of fib6_lookup().

Cc: David Miller <davem@davemloft.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5469ecf..a8ecb9f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -900,31 +900,40 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
 				      struct flowi6 *fl6, int flags)
 {
-	struct fib6_node *fn;
+	struct fib6_node *fn, *saved_fn;
 	struct rt6_info *rt, *nrt;
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
+	if (net->ipv6.devconf_all->forwarding == 0)
+		strict |= RT6_LOOKUP_F_REACHABLE;
 
 redo_fib6_lookup_lock:
 	read_lock_bh(&table->tb6_lock);
 
-redo_fib6_lookup:
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
+	saved_fn = fn;
 
 redo_rt6_select:
-	rt = rt6_select(fn, oif, strict | reachable);
+	rt = rt6_select(fn, oif, strict);
 	if (rt->rt6i_nsiblings)
-		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
+		rt = rt6_multipath_select(rt, fl6, oif, strict);
 	if (rt == net->ipv6.ip6_null_entry) {
 		fn = fib6_backtrack(fn, &fl6->saddr);
 		if (fn)
 			goto redo_rt6_select;
-		else
-			goto out;
+		else if (strict & RT6_LOOKUP_F_REACHABLE) {
+			/* also consider unreachable route */
+			strict &= ~RT6_LOOKUP_F_REACHABLE;
+			fn = saved_fn;
+			goto redo_rt6_select;
+		} else {
+			dst_hold(&rt->dst);
+			read_unlock_bh(&table->tb6_lock);
+			goto out2;
+		}
 	}
 
 	dst_hold(&rt->dst);
@@ -960,13 +969,6 @@ redo_rt6_select:
 	ip6_rt_put(rt);
 	goto redo_fib6_lookup_lock;
 
-out:
-	if (reachable) {
-		reachable = 0;
-		goto redo_fib6_lookup;
-	}
-	dst_hold(&rt->dst);
-	read_unlock_bh(&table->tb6_lock);
 out2:
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
-- 
1.8.1
