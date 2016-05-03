From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/15] batman-adv: move and restructure batadv_v_ogm_forward
Date: Wed,  4 May 2016 06:23:48 +0800
Message-ID: <1462314230-16257-14-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:17473 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436AbcECWlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:41:03 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

To match our code better to the protocol description of B.A.T.M.A.N. V,
move batadv_v_ogm_forward() out into batadv_v_ogm_process_per_outif()
and move all checks directly deciding whether the OGM should be
forwarded into batadv_v_ogm_forward().

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_v_ogm.c | 110 ++++++++++++++++++++++++++-------------------
 1 file changed, 63 insertions(+), 47 deletions(-)

diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index d9bcbe6e7d65..07c999734fba 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -347,10 +347,12 @@ static u32 batadv_v_forward_penalty(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_v_ogm_forward - forward an OGM to the given outgoing interface
+ * batadv_v_ogm_forward - check conditions and forward an OGM to the given
+ *  outgoing interface
  * @bat_priv: the bat priv with all the soft interface information
  * @ogm_received: previously received OGM to be forwarded
- * @throughput: throughput to announce, may vary per outgoing interface
+ * @orig_node: the originator which has been updated
+ * @neigh_node: the neigh_node through with the OGM has been received
  * @if_incoming: the interface on which this OGM was received on
  * @if_outgoing: the interface to which the OGM has to be forwarded to
  *
@@ -359,28 +361,57 @@ static u32 batadv_v_forward_penalty(struct batadv_priv *bat_priv,
  */
 static void batadv_v_ogm_forward(struct batadv_priv *bat_priv,
 				 const struct batadv_ogm2_packet *ogm_received,
-				 u32 throughput,
+				 struct batadv_orig_node *orig_node,
+				 struct batadv_neigh_node *neigh_node,
 				 struct batadv_hard_iface *if_incoming,
 				 struct batadv_hard_iface *if_outgoing)
 {
+	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
+	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	struct batadv_neigh_node *router = NULL;
 	struct batadv_ogm2_packet *ogm_forward;
 	unsigned char *skb_buff;
 	struct sk_buff *skb;
 	size_t packet_len;
 	u16 tvlv_len;
 
+	/* only forward for specific interfaces, not for the default one. */
+	if (if_outgoing == BATADV_IF_DEFAULT)
+		goto out;
+
+	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
+	if (!orig_ifinfo)
+		goto out;
+
+	/* acquire possibly updated router */
+	router = batadv_orig_router_get(orig_node, if_outgoing);
+
+	/* strict rule: forward packets coming from the best next hop only */
+	if (neigh_node != router)
+		goto out;
+
+	/* don't forward the same seqno twice on one interface */
+	if (orig_ifinfo->last_seqno_forwarded == ntohl(ogm_received->seqno))
+		goto out;
+
+	orig_ifinfo->last_seqno_forwarded = ntohl(ogm_received->seqno);
+
 	if (ogm_received->ttl <= 1) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
-		return;
+		goto out;
 	}
 
+	neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+	if (!neigh_ifinfo)
+		goto out;
+
 	tvlv_len = ntohs(ogm_received->tvlv_len);
 
 	packet_len = BATADV_OGM2_HLEN + tvlv_len;
 	skb = netdev_alloc_skb_ip_align(if_outgoing->net_dev,
 					ETH_HLEN + packet_len);
 	if (!skb)
-		return;
+		goto out;
 
 	skb_reserve(skb, ETH_HLEN);
 	skb_buff = skb_put(skb, packet_len);
@@ -388,15 +419,23 @@ static void batadv_v_ogm_forward(struct batadv_priv *bat_priv,
 
 	/* apply forward penalty */
 	ogm_forward = (struct batadv_ogm2_packet *)skb_buff;
-	ogm_forward->throughput = htonl(throughput);
+	ogm_forward->throughput = htonl(neigh_ifinfo->bat_v.throughput);
 	ogm_forward->ttl--;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 		   "Forwarding OGM2 packet on %s: throughput %u, ttl %u, received via %s\n",
-		   if_outgoing->net_dev->name, throughput, ogm_forward->ttl,
-		   if_incoming->net_dev->name);
+		   if_outgoing->net_dev->name, ntohl(ogm_forward->throughput),
+		   ogm_forward->ttl, if_incoming->net_dev->name);
 
 	batadv_v_ogm_send_to_if(skb, if_outgoing);
+
+out:
+	if (orig_ifinfo)
+		batadv_orig_ifinfo_put(orig_ifinfo);
+	if (router)
+		batadv_neigh_node_put(router);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
 }
 
 /**
@@ -493,8 +532,10 @@ out:
  * @neigh_node: the neigh_node through with the OGM has been received
  * @if_incoming: the interface where this packet was received
  * @if_outgoing: the interface for which the packet should be considered
+ *
+ * Return: true if the packet should be forwarded, false otherwise
  */
-static void batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
+static bool batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 				      const struct ethhdr *ethhdr,
 				      const struct batadv_ogm2_packet *ogm2,
 				      struct batadv_orig_node *orig_node,
@@ -503,14 +544,9 @@ static void batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 				      struct batadv_hard_iface *if_outgoing)
 {
 	struct batadv_neigh_node *router = NULL;
-	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
 	struct batadv_orig_node *orig_neigh_node = NULL;
-	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
 	struct batadv_neigh_node *orig_neigh_router = NULL;
-
-	neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
-	if (!neigh_ifinfo)
-		goto out;
+	bool forward = false;
 
 	orig_neigh_node = batadv_v_ogm_orig_get(bat_priv, ethhdr->h_source);
 	if (!orig_neigh_node)
@@ -529,47 +565,20 @@ static void batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 		goto out;
 	}
 
-	if (router)
-		batadv_neigh_node_put(router);
-
 	/* Update routes, and check if the OGM is from the best next hop */
 	batadv_v_ogm_orig_update(bat_priv, orig_node, neigh_node, ogm2,
 				 if_outgoing);
 
-	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
-	if (!orig_ifinfo)
-		goto out;
-
-	/* don't forward the same seqno twice on one interface */
-	if (orig_ifinfo->last_seqno_forwarded == ntohl(ogm2->seqno))
-		goto out;
-
-	/* acquire possibly updated router */
-	router = batadv_orig_router_get(orig_node, if_outgoing);
-
-	/* strict rule: forward packets coming from the best next hop only */
-	if (neigh_node != router)
-		goto out;
-
-	/* only forward for specific interface, not for the default one. */
-	if (if_outgoing != BATADV_IF_DEFAULT) {
-		orig_ifinfo->last_seqno_forwarded = ntohl(ogm2->seqno);
-		batadv_v_ogm_forward(bat_priv, ogm2,
-				     neigh_ifinfo->bat_v.throughput,
-				     if_incoming, if_outgoing);
-	}
-
+	forward = true;
 out:
-	if (orig_ifinfo)
-		batadv_orig_ifinfo_put(orig_ifinfo);
 	if (router)
 		batadv_neigh_node_put(router);
 	if (orig_neigh_router)
 		batadv_neigh_node_put(orig_neigh_router);
 	if (orig_neigh_node)
 		batadv_orig_node_put(orig_neigh_node);
-	if (neigh_ifinfo)
-		batadv_neigh_ifinfo_put(neigh_ifinfo);
+
+	return forward;
 }
 
 /**
@@ -592,6 +601,7 @@ batadv_v_ogm_process_per_outif(struct batadv_priv *bat_priv,
 			       struct batadv_hard_iface *if_outgoing)
 {
 	int seqno_age;
+	bool forward;
 
 	/* first, update the metric with according sanity checks */
 	seqno_age = batadv_v_ogm_metric_update(bat_priv, ogm2, orig_node,
@@ -610,8 +620,14 @@ batadv_v_ogm_process_per_outif(struct batadv_priv *bat_priv,
 					       ntohs(ogm2->tvlv_len));
 
 	/* if the metric update went through, update routes if needed */
-	batadv_v_ogm_route_update(bat_priv, ethhdr, ogm2, orig_node,
-				  neigh_node, if_incoming, if_outgoing);
+	forward = batadv_v_ogm_route_update(bat_priv, ethhdr, ogm2, orig_node,
+					    neigh_node, if_incoming,
+					    if_outgoing);
+
+	/* if the routes have been processed correctly, check and forward */
+	if (forward)
+		batadv_v_ogm_forward(bat_priv, ogm2, orig_node, neigh_node,
+				     if_incoming, if_outgoing);
 }
 
 /**
-- 
2.8.2
