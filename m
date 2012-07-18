From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 04:06:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg> <20120717.134651.562831385960975623.davem@davemloft.net> <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg> <20120717.150920.1324071045620152376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55056 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713Ab2GRA7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 20:59:01 -0400
In-Reply-To: <20120717.150920.1324071045620152376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 17 Jul 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 18 Jul 2012 01:14:04 +0300 (EEST)
> 
> > 	Aha, I see. Something around fnhe_oldest() and its
> > daddr arg does not look good. If the goal is to hijack
> > some entry, probably for another daddr and comparing it with
> > tcpm_new(), may be we should remove this daddr arg and fully
> > reset all parameters such as fnhe_pmtu, fnhe_gw, fnhe_expires
> > because the find_or_create_fnhe() callers modify only specific
> > fields, we should not end up with wrong gateway inherited from
> > another daddr, for example.
> 
> Better would be to use a seqlock when reading it's values.
> 
> Either way, patches welcome :-)

	I created patch with seqlock usage. This version
is with global seqlock because I'm not sure if 2048 locks
per NH are good idea. This is only compile tested.
After comments may be I have to resubmit in separate message.


Subject: [PATCH] ipv4: use seqlock for nh_exceptions

From: Julian Anastasov <ja@ssi.bg>

	Use global seqlock for the nh_exceptions. Call
fnhe_oldest with the right hash chain. Correct the diff
value for dst_set_expires.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h |    2 +-
 net/ipv4/route.c     |  117 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 76 insertions(+), 43 deletions(-)

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
index f67e702..e037c73 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1334,8 +1334,9 @@ static void ip_rt_build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 }
 
 static DEFINE_SPINLOCK(fnhe_lock);
+static DEFINE_SEQLOCK(fnhe_seqlock);
 
-static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be32 daddr)
+static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 {
 	struct fib_nh_exception *fnhe, *oldest;
 
@@ -1358,47 +1359,76 @@ static inline u32 fnhe_hashfun(__be32 daddr)
 	return hval & (FNHE_HASH_SIZE - 1);
 }
 
-static struct fib_nh_exception *find_or_create_fnhe(struct fib_nh *nh, __be32 daddr)
+static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
+				  u32 pmtu, unsigned long expires)
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
 	struct fib_nh_exception *fnhe;
 	int depth;
 	u32 hval;
 
-	if (!hash) {
-		hash = nh->nh_exceptions = kzalloc(FNHE_HASH_SIZE * sizeof(*hash),
-						   GFP_ATOMIC);
-		if (!hash)
-			return NULL;
-	}
+	if (!hash)
+		goto start;
 
+repeat:
 	hval = fnhe_hashfun(daddr);
 	hash += hval;
 
 	depth = 0;
+	write_seqlock_bh(&fnhe_seqlock);
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
-	}
-	fnhe = kzalloc(sizeof(*fnhe), GFP_ATOMIC);
-	if (!fnhe)
-		return NULL;
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
+			if (!fnhe) {
+				write_sequnlock_bh(&fnhe_seqlock);
+				return;
+			}
 
-	fnhe->fnhe_next = hash->chain;
-	rcu_assign_pointer(hash->chain, fnhe);
+			fnhe->fnhe_next = hash->chain;
+			rcu_assign_pointer(hash->chain, fnhe);
+		}
+		fnhe->fnhe_daddr = daddr;
+		fnhe->fnhe_gw = gw;
+		fnhe->fnhe_pmtu = pmtu;
+		fnhe->fnhe_expires = expires;
+	}
 
-out_daddr:
-	fnhe->fnhe_daddr = daddr;
-out:
 	fnhe->fnhe_stamp = jiffies;
-	return fnhe;
+	write_sequnlock_bh(&fnhe_seqlock);
+	return;
+
+start:
+	spin_lock_bh(&fnhe_lock);
+	hash = nh->nh_exceptions;
+	if (hash) {
+		spin_unlock_bh(&fnhe_lock);
+		goto repeat;
+	}
+	nh->nh_exceptions = kzalloc(FNHE_HASH_SIZE * sizeof(*hash),
+				    GFP_ATOMIC);
+	if (!nh->nh_exceptions) {
+		spin_unlock_bh(&fnhe_lock);
+		return;
+	}
+	hash = nh->nh_exceptions;
+	spin_unlock_bh(&fnhe_lock);
+	goto repeat;
 }
 
 static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4)
@@ -1452,13 +1482,9 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
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
@@ -1663,15 +1689,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 
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
@@ -1898,6 +1918,7 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
 	struct fib_nh_exception *fnhe;
+	unsigned int seq;
 	u32 hval;
 
 	hval = fnhe_hashfun(daddr);
@@ -1905,17 +1926,29 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
 		if (fnhe->fnhe_daddr == daddr) {
-			if (fnhe->fnhe_pmtu) {
-				unsigned long expires = fnhe->fnhe_expires;
-				unsigned long diff = jiffies - expires;
+			__be32 fnhe_daddr, gw;
+			u32 pmtu;
+			unsigned long expires;
+
+			do {
+				seq = read_seqbegin(&fnhe_seqlock);
+				fnhe_daddr = fnhe->fnhe_daddr;
+				gw = fnhe->fnhe_gw;
+				pmtu = fnhe->fnhe_pmtu;
+				expires = fnhe->fnhe_expires;
+			} while (read_seqretry(&fnhe_seqlock, seq));
+			if (daddr != fnhe_daddr)
+				break;
+			if (pmtu) {
+				unsigned long diff = expires - jiffies;
 
 				if (time_before(jiffies, expires)) {
-					rt->rt_pmtu = fnhe->fnhe_pmtu;
+					rt->rt_pmtu = pmtu;
 					dst_set_expires(&rt->dst, diff);
 				}
 			}
-			if (fnhe->fnhe_gw)
-				rt->rt_gateway = fnhe->fnhe_gw;
+			if (gw)
+				rt->rt_gateway = gw;
 			fnhe->fnhe_stamp = jiffies;
 			break;
 		}
-- 
1.7.3.4
