From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] ipv6: remove some useless RCU read lock
Date: Fri, 17 Aug 2012 15:11:39 +0800
Message-ID: <1345187499-16929-2-git-send-email-amwang@redhat.com>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932156Ab2HQHMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 03:12:08 -0400
In-Reply-To: <1345187499-16929-1-git-send-email-amwang@redhat.com>
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
index 5b2d63e..9f67746 100644
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
@@ -980,7 +975,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
-	rcu_read_lock();
 	rt = (struct rt6_info *) *dst;
 	n = rt->n;
 	if (n && !(n->nud_state & NUD_VALID)) {
@@ -988,7 +982,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		struct flowi6 fl_gw6;
 		int redirect;
 
-		rcu_read_unlock();
 		ifp = ipv6_get_ifaddr(net, &fl6->saddr,
 				      (*dst)->dev, 1);
 
@@ -1008,8 +1001,6 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			if ((err = (*dst)->error))
 				goto out_err_release;
 		}
-	} else {
-		rcu_read_unlock();
 	}
 #endif
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7a36df2..0aeeb98 100644
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
@@ -475,8 +474,6 @@ static void rt6_probe(struct rt6_info *rt)
 	} else {
 		read_unlock_bh(&neigh->lock);
 	}
-out:
-	rcu_read_unlock();
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -503,7 +500,6 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 	struct neighbour *neigh;
 	int m;
 
-	rcu_read_lock();
 	neigh = rt->n;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
@@ -521,7 +517,6 @@ static inline int rt6_check_neigh(struct rt6_info *rt)
 		read_unlock_bh(&neigh->lock);
 	} else
 		m = 0;
-	rcu_read_unlock();
 	return m;
 }
 
@@ -2470,15 +2465,11 @@ static int rt6_fill_node(struct net *net,
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
@@ -2680,14 +2671,12 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
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
