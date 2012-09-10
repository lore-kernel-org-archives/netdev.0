From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/3] ipv6: remove some useless RCU read lock
Date: Mon, 10 Sep 2012 20:48:44 +0800
Message-ID: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757856Ab2IJMsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 08:48:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this commit:
	commit 97cac0821af4474ec4ba3a9e7a36b98ed9b6db88
	Author: David S. Miller <davem@davemloft.net>
	Date:   Mon Jul 2 22:43:47 2012 -0700

	    ipv6: Store route neighbour in rt6_info struct.

we no longer use RCU to protect route neighbour.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/ip6_output.c |   13 ++-----------
 net/ipv6/route.c      |   15 ++-------------
 2 files changed, 4 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4f6263..3dd4a37 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -123,16 +123,11 @@ static int ip6_finish_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	rcu_read_lock();
 	rt = (struct rt6_info *) dst;
 	neigh = rt->n;
-	if (neigh) {
-		int res = dst_neigh_output(dst, neigh, skb);
+	if (neigh)
+		return dst_neigh_output(dst, neigh, skb);
 
-		rcu_read_unlock();
-		return res;
-	}
-	rcu_read_unlock();
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
@@ -983,7 +978,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
-	rcu_read_lock();
 	rt = (struct rt6_info *) *dst;
 	n = rt->n;
 	if (n && !(n->nud_state & NUD_VALID)) {
@@ -991,7 +985,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		struct flowi6 fl_gw6;
 		int redirect;
 
-		rcu_read_unlock();
 		ifp = ipv6_get_ifaddr(net, &fl6->saddr,
 				      (*dst)->dev, 1);
 
@@ -1011,8 +1004,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			if ((err = (*dst)->error))
 				goto out_err_release;
 		}
-	} else {
-		rcu_read_unlock();
 	}
 #endif
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 339d921..b130bf2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -451,10 +451,9 @@ static void rt6_probe(struct rt6_info *rt)
 	 * Router Reachability Probe MUST be rate-limited
 	 * to no more than one per minute.
 	 */
-	rcu_read_lock();
 	neigh = rt ? rt->n : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
-		goto out;
+		return;
 	read_lock_bh(&neigh->lock);
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
@@ -470,8 +469,6 @@ static void rt6_probe(struct rt6_info *rt)
 	} else {
 		read_unlock_bh(&neigh->lock);
 	}
-out:
-	rcu_read_unlock();
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -498,7 +495,6 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	struct neighbour *neigh;
 	int m;
 
-	rcu_read_lock();
 	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
@@ -516,7 +512,6 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 		read_unlock_bh(&neigh->lock);
 	} else
 		m = 0;
-	rcu_read_unlock();
 	return m;
 }
 
@@ -2496,15 +2491,11 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	rcu_read_lock();
 	n = rt->n;
 	if (n) {
-		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0) {
-			rcu_read_unlock();
+		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0)
 			goto nla_put_failure;
-		}
 	}
-	rcu_read_unlock();
 
 	if (rt->dst.dev &&
 	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
@@ -2706,14 +2697,12 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
-	rcu_read_lock();
 	n = rt->n;
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-	rcu_read_unlock();
 	seq_printf(m, " %08x %08x %08x %08x %8s\n",
 		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
 		   rt->dst.__use, rt->rt6i_flags,
-- 
1.7.7.6
