From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 03/16] ipv6: prepare fib6_remove_prefsrc() for exception table
Date: Fri,  6 Oct 2017 12:05:58 -0700
Message-ID: <20171006190611.110633-4-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:43631 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752629AbdJFTGj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:39 -0400
Received: by mail-pf0-f170.google.com with SMTP id d2so6790829pfh.0
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:39 -0700 (PDT)
In-Reply-To: <20171006190611.110633-3-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

After we move cached dst entries into the exception table under its
parent route, current fib6_remove_prefsrc() no longer can access them.
This commit makes fib6_remove_prefsrc() also go through all routes
in the exception table to remove the pref src.
This is a preparation patch in order to move all cached dst into the
exception table.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc5e70975966..f52ac57dcc99 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1264,6 +1264,12 @@ static int rt6_insert_exception(struct rt6_info *nrt,
 	if (ort->rt6i_src.plen)
 		src_key = &nrt->rt6i_src.addr;
 #endif
+
+	/* Update rt6i_prefsrc as it could be changed
+	 * in rt6_remove_prefsrc()
+	 */
+	nrt->rt6i_prefsrc = ort->rt6i_prefsrc;
+
 	rt6_ex = __rt6_find_exception_spinlock(&bucket, &nrt->rt6i_dst.addr,
 					       src_key);
 	if (rt6_ex)
@@ -1432,6 +1438,25 @@ static void rt6_update_exception_stamp_rt(struct rt6_info *rt)
 	rcu_read_unlock();
 }
 
+static void rt6_exceptions_remove_prefsrc(struct rt6_info *rt)
+{
+	struct rt6_exception_bucket *bucket;
+	struct rt6_exception *rt6_ex;
+	int i;
+
+	bucket = rcu_dereference_protected(rt->rt6i_exception_bucket,
+					lockdep_is_held(&rt6_exception_lock));
+
+	if (bucket) {
+		for (i = 0; i < FIB6_EXCEPTION_BUCKET_SIZE; i++) {
+			hlist_for_each_entry(rt6_ex, &bucket->chain, hlist) {
+				rt6_ex->rt6i->rt6i_prefsrc.plen = 0;
+			}
+			bucket++;
+		}
+	}
+}
+
 struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			       int oif, struct flowi6 *fl6, int flags)
 {
@@ -3159,8 +3184,12 @@ static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
 	if (((void *)rt->dst.dev == dev || !dev) &&
 	    rt != net->ipv6.ip6_null_entry &&
 	    ipv6_addr_equal(addr, &rt->rt6i_prefsrc.addr)) {
+		spin_lock_bh(&rt6_exception_lock);
 		/* remove prefsrc entry */
 		rt->rt6i_prefsrc.plen = 0;
+		/* need to update cache as well */
+		rt6_exceptions_remove_prefsrc(rt);
+		spin_unlock_bh(&rt6_exception_lock);
 	}
 	return 0;
 }
-- 
2.14.2.920.gcf0c67979c-goog
