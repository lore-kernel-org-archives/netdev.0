From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: fix a race in update_or_create_fnhe()
Date: Wed, 03 Sep 2014 22:21:56 -0700
Message-ID: <1409808116.26422.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:61314 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbaIDFWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 01:22:01 -0400
Received: by mail-pd0-f178.google.com with SMTP id y13so12859845pdi.9
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 22:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

nh_exceptions is effectively used under rcu, but lacks proper
barriers. Between kzalloc() and setting of nh->nh_exceptions(),
we need a proper memory barrier.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 4895c771c7f00 ("ipv4: Add FIB nexthop exceptions.")
---
 include/net/ip_fib.h     |    2 +-
 net/ipv4/fib_semantics.c |    8 +++++---
 net/ipv4/route.c         |    6 +++---
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9922093f575e..f30fd554127e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -87,7 +87,7 @@ struct fib_nh {
 	int			nh_saddr_genid;
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
-	struct fnhe_hash_bucket	*nh_exceptions;
+	struct fnhe_hash_bucket	__rcu *nh_exceptions;
 };
 
 /*
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b10cd43a4722..5b6efb3d2308 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -157,9 +157,12 @@ static void rt_fibinfo_free(struct rtable __rcu **rtp)
 
 static void free_nh_exceptions(struct fib_nh *nh)
 {
-	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	struct fnhe_hash_bucket *hash;
 	int i;
 
+	hash = rcu_dereference_protected(nh->nh_exceptions, 1);
+	if (!hash)
+		return;
 	for (i = 0; i < FNHE_HASH_SIZE; i++) {
 		struct fib_nh_exception *fnhe;
 
@@ -205,8 +208,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
-		if (nexthop_nh->nh_exceptions)
-			free_nh_exceptions(nexthop_nh);
+		free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b000c7b4..44b0cbdd76f1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -628,12 +628,12 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 
 	spin_lock_bh(&fnhe_lock);
 
-	hash = nh->nh_exceptions;
+	hash = rcu_dereference(nh->nh_exceptions);
 	if (!hash) {
 		hash = kzalloc(FNHE_HASH_SIZE * sizeof(*hash), GFP_ATOMIC);
 		if (!hash)
 			goto out_unlock;
-		nh->nh_exceptions = hash;
+		rcu_assign_pointer(nh->nh_exceptions, hash);
 	}
 
 	hash += hval;
@@ -1242,7 +1242,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 
 static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 {
-	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	struct fnhe_hash_bucket *hash = rcu_dereference(nh->nh_exceptions);
 	struct fib_nh_exception *fnhe;
 	u32 hval;
 
