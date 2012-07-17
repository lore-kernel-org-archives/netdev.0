From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Fix nexthop exception hash computation.
Date: Tue, 17 Jul 2012 13:23:50 -0700 (PDT)
Message-ID: <20120717.132350.1202093690532763592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544Ab2GQUX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:23:56 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C37B7583A2B
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 13:23:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Need to mask it with (FNHE_HASH_SIZE - 1).

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a5bd0b4..812e444 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1347,6 +1347,16 @@ static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be3
 	return oldest;
 }
 
+static inline u32 fnhe_hashfun(__be32 daddr)
+{
+	u32 hval;
+
+	hval = (__force u32) daddr;
+	hval ^= (hval >> 11) ^ (hval >> 22);
+
+	return hval & (FNHE_HASH_SIZE - 1);
+}
+
 static struct fib_nh_exception *find_or_create_fnhe(struct fib_nh *nh, __be32 daddr)
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
@@ -1361,8 +1371,7 @@ static struct fib_nh_exception *find_or_create_fnhe(struct fib_nh *nh, __be32 da
 			return NULL;
 	}
 
-	hval = (__force u32) daddr;
-	hval ^= (hval >> 11) ^ (hval >> 22);
+	hval = fnhe_hashfun(daddr);
 	hash += hval;
 
 	depth = 0;
@@ -1890,8 +1899,7 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 	struct fib_nh_exception *fnhe;
 	u32 hval;
 
-	hval = (__force u32) daddr;
-	hval ^= (hval >> 11) ^ (hval >> 22);
+	hval = fnhe_hashfun(daddr);
 
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
-- 
1.7.10.4
