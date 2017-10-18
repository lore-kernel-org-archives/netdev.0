From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 1/2] ipv6: start fib6 gc on RTF_CACHE dst creation
Date: Wed, 18 Oct 2017 22:23:31 +0200
Message-ID: <22a7dd612b11e30164ad489fb1446b9f6e2de9e6.1508358132.git.pabeni@redhat.com>
References: <cover.1508358132.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52298 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751783AbdJRUXp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 16:23:45 -0400
In-Reply-To: <cover.1508358132.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit Fixes: 2b760fcf5cfb ("ipv6: hook up exception
table to store dst cache"), the fib6 gc is not started after
the creation of a RTF_CACHE via a redirect or pmtu update, since
fib6_add() isn't invoked anymore for such dsts.

We need the fib6 gc to run periodically to clean the RTF_CACHE,
or the dst will stay there forever.

Fix it by explicitly calling fib6_force_start_gc() on successful
exception creation. gc_args->more accounting will ensure that
the gc timer will run for whatever time needed to properly
clean the table.

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 01a103c23a6c..5c27313803d2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1340,8 +1340,10 @@ static int rt6_insert_exception(struct rt6_info *nrt,
 	spin_unlock_bh(&rt6_exception_lock);
 
 	/* Update fn->fn_sernum to invalidate all cached dst */
-	if (!err)
+	if (!err) {
 		fib6_update_sernum(ort);
+		fib6_force_start_gc(net);
+	}
 
 	return err;
 }
-- 
2.13.6
