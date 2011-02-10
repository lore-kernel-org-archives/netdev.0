From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 4/5] ipv4: Cache learned PMTU information in inetpeer.
Date: Wed, 09 Feb 2011 22:13:36 -0800 (PST)
Message-ID: <20110209.221336.115936680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752618Ab1BJGNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:13:01 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0CC2E24C088
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:13:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The general idea is that if we learn new PMTU information, we
bump the peer genid.

This triggers the dst_ops->check() code to validate and if
necessary propagate the new PMTU value into the metrics.

Learned PMTU information self-expires.

This means that it is not necessary to kill a cached route
entry just because the PMTU information is too old.

As a consequence:

1) When the path appears unreachable (dst_ops->link_failure
   or dst_ops->negative_advice) we unwind the PMTU state if
   it is out of date, instead of killing the cached route.

   A redirected route will still be invlidated in these
   situations.

2) rt_check_expire(), rt_worker_func(), et al. are no longer
   necessary at all.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |  260 ++++++++++++++++++------------------------------------
 1 files changed, 86 insertions(+), 174 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0979e03..11faf14 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -131,9 +131,6 @@ static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
 static int rt_chain_length_max __read_mostly	= 20;
 
-static struct delayed_work expires_work;
-static unsigned long expires_ljiffies;
-
 /*
  *	Interface to generic destination cache.
  */
@@ -668,7 +665,7 @@ static inline int rt_fast_clean(struct rtable *rth)
 static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
-		rth->dst.expires;
+		(rth->peer && rth->peer->pmtu_expires);
 }
 
 static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
@@ -679,13 +676,7 @@ static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long t
 	if (atomic_read(&rth->dst.__refcnt))
 		goto out;
 
-	ret = 1;
-	if (rth->dst.expires &&
-	    time_after_eq(jiffies, rth->dst.expires))
-		goto out;
-
 	age = jiffies - rth->dst.lastuse;
-	ret = 0;
 	if ((age <= tmo1 && !rt_fast_clean(rth)) ||
 	    (age <= tmo2 && rt_valuable(rth)))
 		goto out;
@@ -829,97 +820,6 @@ static int has_noalias(const struct rtable *head, const struct rtable *rth)
 	return ONE;
 }
 
-static void rt_check_expire(void)
-{
-	static unsigned int rover;
-	unsigned int i = rover, goal;
-	struct rtable *rth;
-	struct rtable __rcu **rthp;
-	unsigned long samples = 0;
-	unsigned long sum = 0, sum2 = 0;
-	unsigned long delta;
-	u64 mult;
-
-	delta = jiffies - expires_ljiffies;
-	expires_ljiffies = jiffies;
-	mult = ((u64)delta) << rt_hash_log;
-	if (ip_rt_gc_timeout > 1)
-		do_div(mult, ip_rt_gc_timeout);
-	goal = (unsigned int)mult;
-	if (goal > rt_hash_mask)
-		goal = rt_hash_mask + 1;
-	for (; goal > 0; goal--) {
-		unsigned long tmo = ip_rt_gc_timeout;
-		unsigned long length;
-
-		i = (i + 1) & rt_hash_mask;
-		rthp = &rt_hash_table[i].chain;
-
-		if (need_resched())
-			cond_resched();
-
-		samples++;
-
-		if (rcu_dereference_raw(*rthp) == NULL)
-			continue;
-		length = 0;
-		spin_lock_bh(rt_hash_lock_addr(i));
-		while ((rth = rcu_dereference_protected(*rthp,
-					lockdep_is_held(rt_hash_lock_addr(i)))) != NULL) {
-			prefetch(rth->dst.rt_next);
-			if (rt_is_expired(rth)) {
-				*rthp = rth->dst.rt_next;
-				rt_free(rth);
-				continue;
-			}
-			if (rth->dst.expires) {
-				/* Entry is expired even if it is in use */
-				if (time_before_eq(jiffies, rth->dst.expires)) {
-nofree:
-					tmo >>= 1;
-					rthp = &rth->dst.rt_next;
-					/*
-					 * We only count entries on
-					 * a chain with equal hash inputs once
-					 * so that entries for different QOS
-					 * levels, and other non-hash input
-					 * attributes don't unfairly skew
-					 * the length computation
-					 */
-					length += has_noalias(rt_hash_table[i].chain, rth);
-					continue;
-				}
-			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
-				goto nofree;
-
-			/* Cleanup aged off entries. */
-			*rthp = rth->dst.rt_next;
-			rt_free(rth);
-		}
-		spin_unlock_bh(rt_hash_lock_addr(i));
-		sum += length;
-		sum2 += length*length;
-	}
-	if (samples) {
-		unsigned long avg = sum / samples;
-		unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
-		rt_chain_length_max = max_t(unsigned long,
-					ip_rt_gc_elasticity,
-					(avg + 4*sd) >> FRACT_BITS);
-	}
-	rover = i;
-}
-
-/*
- * rt_worker_func() is run in process context.
- * we call rt_check_expire() to scan part of the hash table
- */
-static void rt_worker_func(struct work_struct *work)
-{
-	rt_check_expire();
-	schedule_delayed_work(&expires_work, ip_rt_gc_interval);
-}
-
 /*
  * Pertubation of rt_genid by a small quantity [1..256]
  * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
@@ -1535,9 +1435,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 		if (dst->obsolete > 0) {
 			ip_rt_put(rt);
 			ret = NULL;
-		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
-			   (rt->dst.expires &&
-			    time_after_eq(jiffies, rt->dst.expires))) {
+		} else if (rt->rt_flags & RTCF_REDIRECTED) {
 			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
 						rt->fl.oif,
 						rt_genid(dev_net(dst->dev)));
@@ -1547,6 +1445,14 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 #endif
 			rt_del(hash, rt);
 			ret = NULL;
+		} else if (rt->peer &&
+			   rt->peer->pmtu_expires &&
+			   time_after_eq(jiffies, rt->peer->pmtu_expires)) {
+			unsigned long orig = rt->peer->pmtu_expires;
+
+			if (cmpxchg(&rt->peer->pmtu_expires, orig, 0) == orig)
+				dst_metric_set(dst, RTAX_MTU,
+					       rt->peer->pmtu_orig);
 		}
 	}
 	return ret;
@@ -1697,80 +1603,78 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 				 unsigned short new_mtu,
 				 struct net_device *dev)
 {
-	int i, k;
 	unsigned short old_mtu = ntohs(iph->tot_len);
-	struct rtable *rth;
-	int  ikeys[2] = { dev->ifindex, 0 };
-	__be32  skeys[2] = { iph->saddr, 0, };
-	__be32  daddr = iph->daddr;
 	unsigned short est_mtu = 0;
+	struct inet_peer *peer;
 
-	for (k = 0; k < 2; k++) {
-		for (i = 0; i < 2; i++) {
-			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k],
-						rt_genid(net));
-
-			rcu_read_lock();
-			for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-			     rth = rcu_dereference(rth->dst.rt_next)) {
-				unsigned short mtu = new_mtu;
+	peer = inet_getpeer_v4(iph->daddr, 1);
+	if (peer) {
+		unsigned short mtu = new_mtu;
 
-				if (rth->fl.fl4_dst != daddr ||
-				    rth->fl.fl4_src != skeys[i] ||
-				    rth->rt_dst != daddr ||
-				    rth->rt_src != iph->saddr ||
-				    rth->fl.oif != ikeys[k] ||
-				    rt_is_input_route(rth) ||
-				    dst_metric_locked(&rth->dst, RTAX_MTU) ||
-				    !net_eq(dev_net(rth->dst.dev), net) ||
-				    rt_is_expired(rth))
-					continue;
+		if (new_mtu < 68 || new_mtu >= old_mtu) {
+			/* BSD 4.2 derived systems incorrectly adjust
+			 * tot_len by the IP header length, and report
+			 * a zero MTU in the ICMP message.
+			 */
+			if (mtu == 0 &&
+			    old_mtu >= 68 + (iph->ihl << 2))
+				old_mtu -= iph->ihl << 2;
+			mtu = guess_mtu(old_mtu);
+		}
 
-				if (new_mtu < 68 || new_mtu >= old_mtu) {
+		if (mtu < ip_rt_min_pmtu)
+			mtu = ip_rt_min_pmtu;
+		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
+			est_mtu = mtu;
+			peer->pmtu_learned = mtu;
+			peer->pmtu_expires = jiffies + ip_rt_mtu_expires;
+		}
 
-					/* BSD 4.2 compatibility hack :-( */
-					if (mtu == 0 &&
-					    old_mtu >= dst_mtu(&rth->dst) &&
-					    old_mtu >= 68 + (iph->ihl << 2))
-						old_mtu -= iph->ihl << 2;
+		inet_putpeer(peer);
 
-					mtu = guess_mtu(old_mtu);
-				}
-				if (mtu <= dst_mtu(&rth->dst)) {
-					if (mtu < dst_mtu(&rth->dst)) {
-						dst_confirm(&rth->dst);
-						if (mtu < ip_rt_min_pmtu) {
-							u32 lock = dst_metric(&rth->dst,
-									      RTAX_LOCK);
-							mtu = ip_rt_min_pmtu;
-							lock |= (1 << RTAX_MTU);
-							dst_metric_set(&rth->dst, RTAX_LOCK,
-								       lock);
-						}
-						dst_metric_set(&rth->dst, RTAX_MTU, mtu);
-						dst_set_expires(&rth->dst,
-							ip_rt_mtu_expires);
-					}
-					est_mtu = mtu;
-				}
-			}
-			rcu_read_unlock();
-		}
+		atomic_inc(&__rt_peer_genid);
 	}
 	return est_mtu ? : new_mtu;
 }
 
+static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
+{
+	unsigned long expires = peer->pmtu_expires;
+
+	if (time_before(expires, jiffies)) {
+		u32 orig_dst_mtu = dst_mtu(dst);
+		if (peer->pmtu_learned < orig_dst_mtu) {
+			if (!peer->pmtu_orig)
+				peer->pmtu_orig = dst_metric_raw(dst, RTAX_MTU);
+			dst_metric_set(dst, RTAX_MTU, peer->pmtu_learned);
+		}
+	} else if (cmpxchg(&peer->pmtu_expires, expires, 0) == expires)
+		dst_metric_set(dst, RTAX_MTU, peer->pmtu_orig);
+}
+
 static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	if (dst_mtu(dst) > mtu && mtu >= 68 &&
-	    !(dst_metric_locked(dst, RTAX_MTU))) {
-		if (mtu < ip_rt_min_pmtu) {
-			u32 lock = dst_metric(dst, RTAX_LOCK);
+	struct rtable *rt = (struct rtable *) dst;
+	struct inet_peer *peer;
+
+	dst_confirm(dst);
+
+	if (!rt->peer)
+		rt_bind_peer(rt, 1);
+	peer = rt->peer;
+	if (peer) {
+		if (mtu < ip_rt_min_pmtu)
 			mtu = ip_rt_min_pmtu;
-			dst_metric_set(dst, RTAX_LOCK, lock | (1 << RTAX_MTU));
+		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
+			peer->pmtu_learned = mtu;
+			peer->pmtu_expires = jiffies + ip_rt_mtu_expires;
+
+			atomic_inc(&__rt_peer_genid);
+			rt->rt_peer_genid = rt_peer_genid();
+
+			check_peer_pmtu(dst, peer);
 		}
-		dst_metric_set(dst, RTAX_MTU, mtu);
-		dst_set_expires(dst, ip_rt_mtu_expires);
+		inet_putpeer(peer);
 	}
 }
 
@@ -1781,9 +1685,15 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 	if (rt_is_expired(rt))
 		return NULL;
 	if (rt->rt_peer_genid != rt_peer_genid()) {
+		struct inet_peer *peer;
+
 		if (!rt->peer)
 			rt_bind_peer(rt, 0);
 
+		peer = rt->peer;
+		if (peer && peer->pmtu_expires)
+			check_peer_pmtu(dst, peer);
+
 		rt->rt_peer_genid = rt_peer_genid();
 	}
 	return dst;
@@ -1812,8 +1722,14 @@ static void ipv4_link_failure(struct sk_buff *skb)
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
 	rt = skb_rtable(skb);
-	if (rt)
-		dst_set_expires(&rt->dst, 0);
+	if (rt &&
+	    rt->peer &&
+	    rt->peer->pmtu_expires) {
+		unsigned long orig = rt->peer->pmtu_expires;
+
+		if (cmpxchg(&rt->peer->pmtu_expires, orig, 0) == orig)
+			dst_metric_set(&rt->dst, RTAX_MTU, rt->peer->pmtu_orig);
+	}
 }
 
 static int ip_rt_bug(struct sk_buff *skb)
@@ -1911,6 +1827,9 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
 		dst_init_metrics(&rt->dst, peer->metrics, false);
+
+		if (peer->pmtu_expires)
+			check_peer_pmtu(&rt->dst, peer);
 	} else {
 		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
 			rt->fi = fi;
@@ -2961,7 +2880,8 @@ static int rt_fill_info(struct net *net,
 		NLA_PUT_BE32(skb, RTA_MARK, rt->fl.mark);
 
 	error = rt->dst.error;
-	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
+	expires = (rt->peer && rt->peer->pmtu_expires) ?
+		rt->peer->pmtu_expires - jiffies : 0;
 	if (rt->peer) {
 		inet_peer_refcheck(rt->peer);
 		id = atomic_read(&rt->peer->ip_id_count) & 0xffff;
@@ -3418,14 +3338,6 @@ int __init ip_rt_init(void)
 	devinet_init();
 	ip_fib_init();
 
-	/* All the timers, started at system startup tend
-	   to synchronize. Perturb it a bit.
-	 */
-	INIT_DELAYED_WORK_DEFERRABLE(&expires_work, rt_worker_func);
-	expires_ljiffies = jiffies;
-	schedule_delayed_work(&expires_work,
-		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
-
 	if (ip_rt_proc_init())
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
-- 
1.7.4

