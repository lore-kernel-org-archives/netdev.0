From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v3] ipv4: use seqlock for nh_exceptions
Date: Wed, 18 Jul 2012 23:15:35 +0300
Message-ID: <1342642535-2545-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33942 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351Ab2GRUIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Use global seqlock for the nh_exceptions. Call
fnhe_oldest with the right hash chain. Correct the diff
value for dst_set_expires.

v2: after suggestions from Eric Dumazet:
* get rid of spin lock fnhe_lock, rearrange update_or_create_fnhe
* continue daddr search in rt_bind_exception

v3:
* remove the daddr check before seqlock in rt_bind_exception
* restart lookup in rt_bind_exception on detected seqlock change,
as suggested by David Miller

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h |    2 +-
 net/ipv4/route.c     |  118 +++++++++++++++++++++++++++++---------------------
 2 files changed, 69 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e9ee1ca..2daf096 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -51,7 +51,7 @@ struct fib_nh_exception {
 	struct fib_nh_exception __rcu	*fnhe_next;
 	__be32				fnhe_daddr;
 	u32				fnhe_pmtu;
-	u32				fnhe_gw;
+	__be32				fnhe_gw;
 	unsigned long			fnhe_expires;
 	unsigned long			fnhe_stamp;
 };
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f67e702..e9802d8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1333,9 +1333,9 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 		build_sk_flow_key(fl4, sk);
 }
 
-static DEFINE_SPINLOCK(fnhe_lock);
+static DEFINE_SEQLOCK(fnhe_seqlock);
 
-static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be32 daddr)
+static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 {
 	struct fib_nh_exception *fnhe, *oldest;
 
@@ -1358,47 +1358,63 @@ static inline u32 fnhe_hashfun(__be32 daddr)
 	return hval & (FNHE_HASH_SIZE - 1);
 }
 
-static struct fib_nh_exception *find_or_create_fnhe(struct fib_nh *nh, __be32 daddr)
+static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
+				  u32 pmtu, unsigned long expires)
 {
-	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	struct fnhe_hash_bucket *hash;
 	struct fib_nh_exception *fnhe;
 	int depth;
-	u32 hval;
+	u32 hval = fnhe_hashfun(daddr);
+
+	write_seqlock_bh(&fnhe_seqlock);
 
+	hash = nh->nh_exceptions;
 	if (!hash) {
-		hash = nh->nh_exceptions = kzalloc(FNHE_HASH_SIZE * sizeof(*hash),
-						   GFP_ATOMIC);
+		hash = kzalloc(FNHE_HASH_SIZE * sizeof(*hash), GFP_ATOMIC);
 		if (!hash)
-			return NULL;
+			goto out_unlock;
+		nh->nh_exceptions = hash;
 	}
 
-	hval = fnhe_hashfun(daddr);
 	hash += hval;
 
 	depth = 0;
 	for (fnhe = rcu_dereference(hash->chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
 		if (fnhe->fnhe_daddr == daddr)
-			goto out;
+			break;
 		depth++;
 	}
 
-	if (depth > FNHE_RECLAIM_DEPTH) {
-		fnhe = fnhe_oldest(hash + hval, daddr);
-		goto out_daddr;
+	if (fnhe) {
+		if (gw)
+			fnhe->fnhe_gw = gw;
+		if (pmtu) {
+			fnhe->fnhe_pmtu = pmtu;
+			fnhe->fnhe_expires = expires;
+		}
+	} else {
+		if (depth > FNHE_RECLAIM_DEPTH)
+			fnhe = fnhe_oldest(hash);
+		else {
+			fnhe = kzalloc(sizeof(*fnhe), GFP_ATOMIC);
+			if (!fnhe)
+				goto out_unlock;
+
+			fnhe->fnhe_next = hash->chain;
+			rcu_assign_pointer(hash->chain, fnhe);
+		}
+		fnhe->fnhe_daddr = daddr;
+		fnhe->fnhe_gw = gw;
+		fnhe->fnhe_pmtu = pmtu;
+		fnhe->fnhe_expires = expires;
 	}
-	fnhe = kzalloc(sizeof(*fnhe), GFP_ATOMIC);
-	if (!fnhe)
-		return NULL;
-
-	fnhe->fnhe_next = hash->chain;
-	rcu_assign_pointer(hash->chain, fnhe);
 
-out_daddr:
-	fnhe->fnhe_daddr = daddr;
-out:
 	fnhe->fnhe_stamp = jiffies;
-	return fnhe;
+
+out_unlock:
+	write_sequnlock_bh(&fnhe_seqlock);
+	return;
 }
 
 static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4)
@@ -1452,13 +1468,9 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 		} else {
 			if (fib_lookup(net, fl4, &res) == 0) {
 				struct fib_nh *nh = &FIB_RES_NH(res);
-				struct fib_nh_exception *fnhe;
 
-				spin_lock_bh(&fnhe_lock);
-				fnhe = find_or_create_fnhe(nh, fl4->daddr);
-				if (fnhe)
-					fnhe->fnhe_gw = new_gw;
-				spin_unlock_bh(&fnhe_lock);
+				update_or_create_fnhe(nh, fl4->daddr, new_gw,
+						      0, 0);
 			}
 			rt->rt_gateway = new_gw;
 			rt->rt_flags |= RTCF_REDIRECTED;
@@ -1663,15 +1675,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 
 	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
 		struct fib_nh *nh = &FIB_RES_NH(res);
-		struct fib_nh_exception *fnhe;
 
-		spin_lock_bh(&fnhe_lock);
-		fnhe = find_or_create_fnhe(nh, fl4->daddr);
-		if (fnhe) {
-			fnhe->fnhe_pmtu = mtu;
-			fnhe->fnhe_expires = jiffies + ip_rt_mtu_expires;
-		}
-		spin_unlock_bh(&fnhe_lock);
+		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
+				      jiffies + ip_rt_mtu_expires);
 	}
 	rt->rt_pmtu = mtu;
 	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
@@ -1902,23 +1908,35 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 
 	hval = fnhe_hashfun(daddr);
 
+restart:
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
-		if (fnhe->fnhe_daddr == daddr) {
-			if (fnhe->fnhe_pmtu) {
-				unsigned long expires = fnhe->fnhe_expires;
-				unsigned long diff = jiffies - expires;
-
-				if (time_before(jiffies, expires)) {
-					rt->rt_pmtu = fnhe->fnhe_pmtu;
-					dst_set_expires(&rt->dst, diff);
-				}
+		__be32 fnhe_daddr, gw;
+		u32 pmtu;
+		unsigned long expires;
+		unsigned int seq;
+
+		seq = read_seqbegin(&fnhe_seqlock);
+		fnhe_daddr = fnhe->fnhe_daddr;
+		gw = fnhe->fnhe_gw;
+		pmtu = fnhe->fnhe_pmtu;
+		expires = fnhe->fnhe_expires;
+		if (read_seqretry(&fnhe_seqlock, seq))
+			goto restart;
+		if (daddr != fnhe_daddr)
+			continue;
+		if (pmtu) {
+			unsigned long diff = expires - jiffies;
+
+			if (time_before(jiffies, expires)) {
+				rt->rt_pmtu = pmtu;
+				dst_set_expires(&rt->dst, diff);
 			}
-			if (fnhe->fnhe_gw)
-				rt->rt_gateway = fnhe->fnhe_gw;
-			fnhe->fnhe_stamp = jiffies;
-			break;
 		}
+		if (gw)
+			rt->rt_gateway = gw;
+		fnhe->fnhe_stamp = jiffies;
+		break;
 	}
 }
 
-- 
1.7.3.4
