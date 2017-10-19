From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 2/2] ipv6: remove from fib tree aged out RTF_CACHE dst
Date: Thu, 19 Oct 2017 16:07:11 +0200
Message-ID: <6440bf87fe967880ff90c1eb732081769f81f4a0.1508421311.git.pabeni@redhat.com>
References: <cover.1508421311.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753599AbdJSOIL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 10:08:11 -0400
In-Reply-To: <cover.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
dst cache") partially reverted the commit 1e2ea8ad37be ("ipv6: set
dst.obsolete when a cached route has expired").

As a result, RTF_CACHE dst referenced outside the fib tree will
not be removed until the next sernum change; dst_check() does not
fail on aged-out dst, and dst->__refcnt can't decrease: the aged
out dst will stay valid for a potentially unlimited time after the
timeout expiration.

This change explicitly removes RTF_CACHE dst from the fib tree when
aged out. The rt6_remove_exception() logic will then obsolete the
dst and other entities will drop the related reference on next
dst_check().

pMTU exceptions are not aged-out, and are removed from the exception
table only when the - usually considerably longer - ip6_rt_mtu_expires
timeout expires.

v1 -> v2:
  - do not touch dst.obsolete in rt6_remove_exception(), not needed
v2 -> v3:
  - take care of pMTU exceptions, too

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5c27313803d2..87a15cbd0e8b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1575,7 +1575,13 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
 {
 	struct rt6_info *rt = rt6_ex->rt6i;
 
-	if (atomic_read(&rt->dst.__refcnt) == 1 &&
+	/* we are pruning and obsoleting aged-out and non gateway exceptions
+	 * even if others have still references to them, so that on next
+	 * dst_check() such references can be dropped.
+	 * EXPIRES exceptions - e.g. pmtu-generated ones are pruned when
+	 * expired, independently from their aging, as per RFC 8201 section 4
+	 */
+	if (!(rt->rt6i_flags & RTF_EXPIRES) &&
 	    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
 		RT6_TRACE("aging clone %p\n", rt);
 		rt6_remove_exception(bucket, rt6_ex);
@@ -1595,6 +1601,10 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
 			rt6_remove_exception(bucket, rt6_ex);
 			return;
 		}
+	} else if (__rt6_check_expired(rt)) {
+		RT6_TRACE("purging expired route %p\n", rt);
+		rt6_remove_exception(bucket, rt6_ex);
+		return;
 	}
 	gc_args->more++;
 }
-- 
2.13.6
