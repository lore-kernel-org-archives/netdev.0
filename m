From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next] ipv6: router reachability probing
Date: Wed, 11 Dec 2013 13:48:20 +0100
Message-ID: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888Ab3LKMtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 07:49:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4191 states in 3.5:

   When a host avoids using any non-reachable router X and instead sends
   a data packet to another router Y, and the host would have used
   router X if router X were reachable, then the host SHOULD probe each
   such router X's reachability by sending a single Neighbor
   Solicitation to that router's address.  A host MUST NOT probe a
   router's reachability in the absence of useful traffic that the host
   would have sent to the router if it were reachable.  In any case,
   these probes MUST be rate-limited to no more than one per minute per
   router.

Currently, when the neighbour corresponding to a router falls into
NUD_FAILED, it's never considered again. Introduce a new rt6_nud_state
value, RT6_NUD_FAIL_PROBE, which suggests the route should not be used but
should be probed with a single NS. The probe is ratelimited by the existing
code. To better distinguish meanings of the failure values, rename
RT6_NUD_FAIL_SOFT to RT6_NUD_FAIL_DO_RR.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: put the neighbor into NUD_PROBE instead of accepting NAs in the failed
state
---
 include/net/neighbour.h |    1 +
 net/core/neighbour.c    |   15 +++++++++++++++
 net/ipv6/route.c        |   16 ++++++++++------
 3 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 41b1ce6c96a8..4c09bd23b832 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -252,6 +252,7 @@ static inline struct neighbour *neigh_create(struct neigh_table *tbl,
 void neigh_destroy(struct neighbour *neigh);
 int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
 int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, u32 flags);
+void __neigh_set_probe_once(struct neighbour *neigh);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8be82a7f0e0f..bf6f404c04aa 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1238,6 +1238,21 @@ out:
 }
 EXPORT_SYMBOL(neigh_update);
 
+/* Update the neigh to listen temporarily for probe responses, even if it is
+ * in a NUD_FAILED state. The caller has to hold neigh->lock for writing.
+ */
+void __neigh_set_probe_once(struct neighbour *neigh)
+{
+	neigh->updated = jiffies;
+	if (!(neigh->nud_state & NUD_FAILED))
+		return;
+	neigh->nud_state = NUD_PROBE;
+	atomic_set(&neigh->probes, NEIGH_VAR(neigh->parms, UCAST_PROBES));
+	neigh_add_timer(neigh,
+			jiffies + NEIGH_VAR(neigh->parms, RETRANS_TIME));
+}
+EXPORT_SYMBOL(__neigh_set_probe_once);
+
 struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 				 u8 *lladdr, void *saddr,
 				 struct net_device *dev)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddb9d41c8eea..a1a57523b158 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -66,8 +66,9 @@
 #endif
 
 enum rt6_nud_state {
-	RT6_NUD_FAIL_HARD = -2,
-	RT6_NUD_FAIL_SOFT = -1,
+	RT6_NUD_FAIL_HARD = -3,
+	RT6_NUD_FAIL_PROBE = -2,
+	RT6_NUD_FAIL_DO_RR = -1,
 	RT6_NUD_SUCCEED = 1
 };
 
@@ -521,7 +522,7 @@ static void rt6_probe(struct rt6_info *rt)
 		work = kmalloc(sizeof(*work), GFP_ATOMIC);
 
 		if (neigh && work)
-			neigh->updated = jiffies;
+			__neigh_set_probe_once(neigh);
 
 		if (neigh)
 			write_unlock(&neigh->lock);
@@ -577,11 +578,13 @@ static inline enum rt6_nud_state rt6_check_neigh(struct rt6_info *rt)
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		else if (!(neigh->nud_state & NUD_FAILED))
 			ret = RT6_NUD_SUCCEED;
+		else
+			ret = RT6_NUD_FAIL_PROBE;
 #endif
 		read_unlock(&neigh->lock);
 	} else {
 		ret = IS_ENABLED(CONFIG_IPV6_ROUTER_PREF) ?
-		      RT6_NUD_SUCCEED : RT6_NUD_FAIL_SOFT;
+		      RT6_NUD_SUCCEED : RT6_NUD_FAIL_DO_RR;
 	}
 	rcu_read_unlock_bh();
 
@@ -618,16 +621,17 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 		goto out;
 
 	m = rt6_score_route(rt, oif, strict);
-	if (m == RT6_NUD_FAIL_SOFT) {
+	if (m == RT6_NUD_FAIL_DO_RR) {
 		match_do_rr = true;
 		m = 0; /* lowest valid score */
-	} else if (m < 0) {
+	} else if (m == RT6_NUD_FAIL_HARD) {
 		goto out;
 	}
 
 	if (strict & RT6_LOOKUP_F_REACHABLE)
 		rt6_probe(rt);
 
+	/* note that m can be RT6_NUD_FAIL_PROBE at this point */
 	if (m > *mpri) {
 		*do_rr = match_do_rr;
 		*mpri = m;
-- 
1.7.6.5
