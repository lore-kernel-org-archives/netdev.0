From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 11:36:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207181105320.2154@ja.ssi.bg>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>  <20120717.134651.562831385960975623.davem@davemloft.net>  <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>  <20120717.150920.1324071045620152376.davem@davemloft.net>  <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
  <1342583166.2626.1367.camel@edumazet-glaptop>  <alpine.LFD.2.00.1207181014050.1652@ja.ssi.bg> <1342596648.2626.1831.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55550 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902Ab2GRI3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 04:29:00 -0400
In-Reply-To: <1342596648.2626.1831.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 18 Jul 2012, Eric Dumazet wrote:

> On Wed, 2012-07-18 at 10:28 +0300, Julian Anastasov wrote:
> 
> > 	This is going to read all values in the chain
> > before reaching daddr? Or may be FNHE_RECLAIM_DEPTH is
> > small and nobody will increase it. May be I can create
> > some func that searches daddr in chain instead. Do you still
> > prefer to remove the first daddr check or it is only
> > that the code is intended too much?
> > 
> 
> I would not bother, since real cost is the initial cache line miss.
> Once you read one field, reading others is really fast.

	Is the cost of read_seqbegin a problem? Here is a
2nd version, I still keep this first check for now.

> > > +		if (fnhe_daddr == daddr) {
> > 
> > 	Also, do we need some rcu locking in
> > __ip_rt_update_pmtu or may be ipv4_update_pmtu is
> > called always under rcu lock?
> 
> Sorry, I dont understand, we use the full lock
> write_seqlock_bh(&fnhe_seqlock);/write_sequnlock_bh(&fnhe_seqlock);

	No, it is not related to the fnhe locking, I mean:

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c7a40c3..c911caf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1686,12 +1686,14 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
+	rcu_read_lock();
 	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
 		struct fib_nh *nh = &FIB_RES_NH(res);
 
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
 				      jiffies + ip_rt_mtu_expires);
 	}
+	rcu_read_unlock();
 	rt->rt_pmtu = mtu;
 	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
 }


	How about the following, is the first daddr check
still a problem?

Subject: [PATCH v2] ipv4: use seqlock for nh_exceptions

From: Julian Anastasov <ja@ssi.bg>

	Use global seqlock for the nh_exceptions. Call
fnhe_oldest with the right hash chain. Correct the diff
value for dst_set_expires.

v2: after suggestions from Eric Dumazet:
* get rid of spin lock fnhe_lock, rearrange update_or_create_fnhe
* continue daddr search in rt_bind_exception

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h |    2 +-
 net/ipv4/route.c     |  119 +++++++++++++++++++++++++++++---------------------
 2 files changed, 70 insertions(+), 51 deletions(-)

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
index f67e702..1485db1 100644
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
@@ -1904,21 +1910,34 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 
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
+		if (fnhe->fnhe_daddr != daddr)
+			continue;
+		do {
+			seq = read_seqbegin(&fnhe_seqlock);
+			fnhe_daddr = fnhe->fnhe_daddr;
+			gw = fnhe->fnhe_gw;
+			pmtu = fnhe->fnhe_pmtu;
+			expires = fnhe->fnhe_expires;
+		} while (read_seqretry(&fnhe_seqlock, seq));
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
