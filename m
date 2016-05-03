From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 14/15] batman-adv: Merge batadv_v_ogm_orig_update into batadv_v_ogm_route_update
Date: Wed,  4 May 2016 06:23:49 +0800
Message-ID: <1462314230-16257-15-git-send-email-a__37223.7981450327$1462315963$gmane$org@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:48163 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932265AbcECWw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:52:26 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Since batadv_v_ogm_orig_update() was only called from one place and the
calling function became very short, merge these two functions together.

This should also reflect the protocol description of B.A.T.M.A.N. V
better.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_v_ogm.c | 117 ++++++++++++++++++---------------------------
 1 file changed, 46 insertions(+), 71 deletions(-)

diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 07c999734fba..4155fa57cf6d 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -234,73 +234,6 @@ void batadv_v_ogm_primary_iface_set(struct batadv_hard_iface *primary_iface)
 }
 
 /**
- * batadv_v_ogm_orig_update - update the originator status based on the received
- *  OGM
- * @bat_priv: the bat priv with all the soft interface information
- * @orig_node: the originator to update
- * @neigh_node: the neighbour the OGM has been received from (to update)
- * @ogm2: the received OGM
- * @if_outgoing: the interface where this OGM is going to be forwarded through
- */
-static void
-batadv_v_ogm_orig_update(struct batadv_priv *bat_priv,
-			 struct batadv_orig_node *orig_node,
-			 struct batadv_neigh_node *neigh_node,
-			 const struct batadv_ogm2_packet *ogm2,
-			 struct batadv_hard_iface *if_outgoing)
-{
-	struct batadv_neigh_ifinfo *router_ifinfo = NULL, *neigh_ifinfo = NULL;
-	struct batadv_neigh_node *router = NULL;
-	s32 neigh_seq_diff;
-	u32 neigh_last_seqno;
-	u32 router_last_seqno;
-	u32 router_throughput, neigh_throughput;
-
-	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Searching and updating originator entry of received packet\n");
-
-	/* if this neighbor already is our next hop there is nothing
-	 * to change
-	 */
-	router = batadv_orig_router_get(orig_node, if_outgoing);
-	if (router == neigh_node)
-		goto out;
-
-	/* don't consider neighbours with worse throughput.
-	 * also switch route if this seqno is BATADV_V_MAX_ORIGDIFF newer than
-	 * the last received seqno from our best next hop.
-	 */
-	if (router) {
-		router_ifinfo = batadv_neigh_ifinfo_get(router, if_outgoing);
-		neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
-
-		/* if these are not allocated, something is wrong. */
-		if (!router_ifinfo || !neigh_ifinfo)
-			goto out;
-
-		neigh_last_seqno = neigh_ifinfo->bat_v.last_seqno;
-		router_last_seqno = router_ifinfo->bat_v.last_seqno;
-		neigh_seq_diff = neigh_last_seqno - router_last_seqno;
-		router_throughput = router_ifinfo->bat_v.throughput;
-		neigh_throughput = neigh_ifinfo->bat_v.throughput;
-
-		if ((neigh_seq_diff < BATADV_OGM_MAX_ORIGDIFF) &&
-		    (router_throughput >= neigh_throughput))
-			goto out;
-	}
-
-	batadv_update_route(bat_priv, orig_node, if_outgoing, neigh_node);
-
-out:
-	if (router_ifinfo)
-		batadv_neigh_ifinfo_put(router_ifinfo);
-	if (neigh_ifinfo)
-		batadv_neigh_ifinfo_put(neigh_ifinfo);
-	if (router)
-		batadv_neigh_node_put(router);
-}
-
-/**
  * batadv_v_forward_penalty - apply a penalty to the throughput metric forwarded
  *  with B.A.T.M.A.N. V OGMs
  * @bat_priv: the bat priv with all the soft interface information
@@ -546,6 +479,11 @@ static bool batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 	struct batadv_neigh_node *router = NULL;
 	struct batadv_orig_node *orig_neigh_node = NULL;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL, *neigh_ifinfo = NULL;
+	u32 router_throughput, neigh_throughput;
+	u32 router_last_seqno;
+	u32 neigh_last_seqno;
+	s32 neigh_seq_diff;
 	bool forward = false;
 
 	orig_neigh_node = batadv_v_ogm_orig_get(bat_priv, ethhdr->h_source);
@@ -565,11 +503,44 @@ static bool batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 		goto out;
 	}
 
-	/* Update routes, and check if the OGM is from the best next hop */
-	batadv_v_ogm_orig_update(bat_priv, orig_node, neigh_node, ogm2,
-				 if_outgoing);
-
+	/* Mark the OGM to be considered for forwarding, and update routes
+	 * if needed.
+	 */
 	forward = true;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Searching and updating originator entry of received packet\n");
+
+	/* if this neighbor already is our next hop there is nothing
+	 * to change
+	 */
+	if (router == neigh_node)
+		goto out;
+
+	/* don't consider neighbours with worse throughput.
+	 * also switch route if this seqno is BATADV_V_MAX_ORIGDIFF newer than
+	 * the last received seqno from our best next hop.
+	 */
+	if (router) {
+		router_ifinfo = batadv_neigh_ifinfo_get(router, if_outgoing);
+		neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+
+		/* if these are not allocated, something is wrong. */
+		if (!router_ifinfo || !neigh_ifinfo)
+			goto out;
+
+		neigh_last_seqno = neigh_ifinfo->bat_v.last_seqno;
+		router_last_seqno = router_ifinfo->bat_v.last_seqno;
+		neigh_seq_diff = neigh_last_seqno - router_last_seqno;
+		router_throughput = router_ifinfo->bat_v.throughput;
+		neigh_throughput = neigh_ifinfo->bat_v.throughput;
+
+		if ((neigh_seq_diff < BATADV_OGM_MAX_ORIGDIFF) &&
+		    (router_throughput >= neigh_throughput))
+			goto out;
+	}
+
+	batadv_update_route(bat_priv, orig_node, if_outgoing, neigh_node);
 out:
 	if (router)
 		batadv_neigh_node_put(router);
@@ -577,6 +548,10 @@ out:
 		batadv_neigh_node_put(orig_neigh_router);
 	if (orig_neigh_node)
 		batadv_orig_node_put(orig_neigh_node);
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_put(router_ifinfo);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 
 	return forward;
 }
-- 
2.8.2
