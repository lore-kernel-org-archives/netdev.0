From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 05/16] ipv6: prepare rt6_clean_tohost() for exception table
Date: Fri,  6 Oct 2017 12:06:00 -0700
Message-ID: <20171006190611.110633-6-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:49544 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751491AbdJFTGm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:42 -0400
Received: by mail-pg0-f54.google.com with SMTP id v13so10385101pgq.6
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:42 -0700 (PDT)
In-Reply-To: <20171006190611.110633-5-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

If we move all cached dst into the exception table under the main route,
current rt6_clean_tohost() will no longer be able to access them.
This commit makes fib6_clean_tohost() to also go through all cached
routes in exception table and removes cached gateway routes to the
passed in gateway.
This is a preparation in order to move all cached routes into the
exception table.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c | 48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 47 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d9805a857809..e8e901589564 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1491,6 +1491,43 @@ static void rt6_exceptions_update_pmtu(struct rt6_info *rt, int mtu)
 	}
 }
 
+#define RTF_CACHE_GATEWAY	(RTF_GATEWAY | RTF_CACHE)
+
+static void rt6_exceptions_clean_tohost(struct rt6_info *rt,
+					struct in6_addr *gateway)
+{
+	struct rt6_exception_bucket *bucket;
+	struct rt6_exception *rt6_ex;
+	struct hlist_node *tmp;
+	int i;
+
+	if (!rcu_access_pointer(rt->rt6i_exception_bucket))
+		return;
+
+	spin_lock_bh(&rt6_exception_lock);
+	bucket = rcu_dereference_protected(rt->rt6i_exception_bucket,
+				     lockdep_is_held(&rt6_exception_lock));
+
+	if (bucket) {
+		for (i = 0; i < FIB6_EXCEPTION_BUCKET_SIZE; i++) {
+			hlist_for_each_entry_safe(rt6_ex, tmp,
+						  &bucket->chain, hlist) {
+				struct rt6_info *entry = rt6_ex->rt6i;
+
+				if ((entry->rt6i_flags & RTF_CACHE_GATEWAY) ==
+				    RTF_CACHE_GATEWAY &&
+				    ipv6_addr_equal(gateway,
+						    &entry->rt6i_gateway)) {
+					rt6_remove_exception(bucket, rt6_ex);
+				}
+			}
+			bucket++;
+		}
+	}
+
+	spin_unlock_bh(&rt6_exception_lock);
+}
+
 struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			       int oif, struct flowi6 *fl6, int flags)
 {
@@ -3240,18 +3277,27 @@ void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
 }
 
 #define RTF_RA_ROUTER		(RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)
-#define RTF_CACHE_GATEWAY	(RTF_GATEWAY | RTF_CACHE)
 
 /* Remove routers and update dst entries when gateway turn into host. */
 static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
 {
 	struct in6_addr *gateway = (struct in6_addr *)arg;
 
+	/* RTF_CACHE_GATEWAY case will be removed once the exception
+	 * table is hooked up to store all cached routes.
+	 */
 	if ((((rt->rt6i_flags & RTF_RA_ROUTER) == RTF_RA_ROUTER) ||
 	     ((rt->rt6i_flags & RTF_CACHE_GATEWAY) == RTF_CACHE_GATEWAY)) &&
 	     ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
 		return -1;
 	}
+
+	/* Further clean up cached routes in exception table.
+	 * This is needed because cached route may have a different
+	 * gateway than its 'parent' in the case of an ip redirect.
+	 */
+	rt6_exceptions_clean_tohost(rt, gateway);
+
 	return 0;
 }
 
-- 
2.14.2.920.gcf0c67979c-goog
