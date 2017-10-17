From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/3] ipv6: obsolete cached dst when removing them from fib tree
Date: Tue, 17 Oct 2017 19:40:58 +0200
Message-ID: <59304478d82e52c817c92d183ef2105f35c17266.1508261949.git.pabeni@redhat.com>
References: <cover.1508261949.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933375AbdJQSAo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:00:44 -0400
In-Reply-To: <cover.1508261949.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
dst cache") partially reverted 1e2ea8ad37be ("ipv6: set
dst.obsolete when a cached route has expired").

This change brings back the dst obsoleting and push it a step
farther: cached dst are always obsoleted when removed from the
fib tree, and removal by time expiration is now performed
regardless of dst->__refcnt, to be consistent with what we
already do for RTF_GATEWAY dst.

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8b25a31b6b03..fce740049e3e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1147,6 +1147,12 @@ static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
 	if (!bucket || !rt6_ex)
 		return;
 
+	/* sockets, flow cache, etc. can hold a refence to this dst, be sure
+	 * they will drop it.
+	 */
+	if (rt6_ex->rt6i)
+		rt6_ex->rt6i->dst.obsolete = DST_OBSOLETE_FORCE_CHK;
+
 	net = dev_net(rt6_ex->rt6i->dst.dev);
 	rt6_ex->rt6i->rt6i_node = NULL;
 	hlist_del_rcu(&rt6_ex->hlist);
@@ -1575,8 +1581,11 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
 {
 	struct rt6_info *rt = rt6_ex->rt6i;
 
-	if (atomic_read(&rt->dst.__refcnt) == 1 &&
-	    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
+	/* we are pruning and obsoleting the exception route even if others
+	 * have still reference to it, so that on next dst_check() such
+	 * reference can be dropped
+	 */
+	if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
 		RT6_TRACE("aging clone %p\n", rt);
 		rt6_remove_exception(bucket, rt6_ex);
 		return;
-- 
2.13.6
