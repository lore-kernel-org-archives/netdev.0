From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 2/2] ipv6: remove from fib tree aged out RTF_CACHE dst
Date: Wed, 18 Oct 2017 22:23:32 +0200
Message-ID: <12138554b307c66d0de7afd582ba83e027c383a2.1508358132.git.pabeni@redhat.com>
References: <cover.1508358132.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751801AbdJRUXr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 16:23:47 -0400
In-Reply-To: <cover.1508358132.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
dst cache") partially reverted 1e2ea8ad37be ("ipv6: set
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

v1 -> v2:
  - do not touch dst.obsolete in rt6_remove_exception(), not needed

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5c27313803d2..a4a7f199120e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1575,8 +1575,11 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
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
