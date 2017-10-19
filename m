From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 1/2] ipv6: start fib6 gc on RTF_CACHE dst creation
Date: Thu, 19 Oct 2017 16:07:10 +0200
Message-ID: <f699f29b3fb7675fdfe5d85ab39e153c147c12f8.1508421311.git.pabeni@redhat.com>
References: <cover.1508421311.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49228 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932139AbdJSOIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 10:08:09 -0400
In-Reply-To: <cover.1508421311.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit 2b760fcf5cfb ("ipv6: hook up exception table
to store dst cache"), the fib6 gc is not started after the
creation of a RTF_CACHE via a redirect or pmtu update, since
fib6_add() isn't invoked anymore for such dsts.

We need the fib6 gc to run periodically to clean the RTF_CACHE,
or the dst will stay there forever.

Fix it by explicitly calling fib6_force_start_gc() on successful
exception creation. gc_args->more accounting will ensure that
the gc timer will run for whatever time needed to properly
clean the table.

v2 -> v3:
 - clarified the commit message

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
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
