From: David Miller <davem@davemloft.net>
Subject: [PATCH 03/16] ipv4: Pull redirect instantiation out into a helper
 function.
Date: Thu, 12 Jul 2012 01:10:56 -0700 (PDT)
Message-ID: <20120712.011056.1351038732588424856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758807Ab2GLIK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:10:57 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C41615824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:10:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 95bfa1b..a4de87f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1271,6 +1271,26 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+static void ip_do_redirect(struct rtable *rt, __be32 old_gw, __be32 new_gw)
+{
+	struct neighbour *n;
+
+	if (rt->rt_gateway != old_gw)
+		return;
+
+	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
+	if (n) {
+		if (!(n->nud_state & NUD_VALID)) {
+			neigh_event_send(n, NULL);
+		} else {
+			rt->rt_gateway = new_gw;
+			rt->rt_flags |= RTCF_REDIRECTED;
+			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
+		}
+		neigh_release(n);
+	}
+}
+
 /* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
@@ -1311,8 +1331,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			rthp = &rt_hash_table[hash].chain;
 
 			while ((rt = rcu_dereference(*rthp)) != NULL) {
-				struct neighbour *n;
-
 				rthp = &rt->dst.rt_next;
 
 				if (rt->rt_key_dst != daddr ||
@@ -1322,21 +1340,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rt_is_expired(rt) ||
 				    !net_eq(dev_net(rt->dst.dev), net) ||
 				    rt->dst.error ||
-				    rt->dst.dev != dev ||
-				    rt->rt_gateway != old_gw)
+				    rt->dst.dev != dev)
 					continue;
 
-				n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
-				if (n) {
-					if (!(n->nud_state & NUD_VALID)) {
-						neigh_event_send(n, NULL);
-					} else {
-						rt->rt_gateway = new_gw;
-						rt->rt_flags |= RTCF_REDIRECTED;
-						call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-					}
-					neigh_release(n);
-				}
+				ip_do_redirect(rt, old_gw, new_gw);
 			}
 		}
 	}
-- 
1.7.10.4
