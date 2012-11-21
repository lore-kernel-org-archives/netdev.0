From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/9] batman-adv: Add wrapper to look up neighbor and send skb
Date: Wed, 21 Nov 2012 13:11:54 +0100
Message-ID: <1353499919-28596-5-git-send-email-ordex@autistici.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:50566 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab2KUMNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:13:01 -0500
In-Reply-To: <1353499919-28596-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

By adding batadv_send_skb_to_orig() in send.c, we can remove duplicate
code that looks up the next hop and then calls batadv_send_skb_packet()=
=2E

=46urthermore, this prepares the upcoming new implementation of
fragmentation, which requires the next hop to route packets.

Please note that this doesn't entirely remove the next-hop lookup in
routing.c and unicast.c, since it is used by the current fragmentation
code.

Also note that the next-hop info is removed from debug messages in
translation-table.c, since it is looked up elsewhere.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c           | 37 +++++-----------------
 net/batman-adv/send.c              | 33 +++++++++++++++++++
 net/batman-adv/send.h              |  3 ++
 net/batman-adv/translation-table.c | 65 ++++++++++--------------------=
--------
 net/batman-adv/unicast.c           |  8 ++---
 net/batman-adv/vis.c               | 37 ++++++----------------
 6 files changed, 75 insertions(+), 108 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 78d6572..8d64348 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -285,7 +285,6 @@ static int batadv_recv_my_icmp_packet(struct batadv=
_priv *bat_priv,
 {
 	struct batadv_hard_iface *primary_if =3D NULL;
 	struct batadv_orig_node *orig_node =3D NULL;
-	struct batadv_neigh_node *router =3D NULL;
 	struct batadv_icmp_packet_rr *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -307,10 +306,6 @@ static int batadv_recv_my_icmp_packet(struct batad=
v_priv *bat_priv,
 	if (!orig_node)
 		goto out;
=20
-	router =3D batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto out;
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
@@ -322,14 +317,12 @@ static int batadv_recv_my_icmp_packet(struct bata=
dv_priv *bat_priv,
 	icmp_packet->msg_type =3D BATADV_ECHO_REPLY;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
-	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
-	ret =3D NET_RX_SUCCESS;
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+		ret =3D NET_RX_SUCCESS;
=20
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	if (router)
-		batadv_neigh_node_free_ref(router);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	return ret;
@@ -340,7 +333,6 @@ static int batadv_recv_icmp_ttl_exceeded(struct bat=
adv_priv *bat_priv,
 {
 	struct batadv_hard_iface *primary_if =3D NULL;
 	struct batadv_orig_node *orig_node =3D NULL;
-	struct batadv_neigh_node *router =3D NULL;
 	struct batadv_icmp_packet *icmp_packet;
 	int ret =3D NET_RX_DROP;
=20
@@ -362,10 +354,6 @@ static int batadv_recv_icmp_ttl_exceeded(struct ba=
tadv_priv *bat_priv,
 	if (!orig_node)
 		goto out;
=20
-	router =3D batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto out;
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
@@ -377,14 +365,12 @@ static int batadv_recv_icmp_ttl_exceeded(struct b=
atadv_priv *bat_priv,
 	icmp_packet->msg_type =3D BATADV_TTL_EXCEEDED;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
-	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
-	ret =3D NET_RX_SUCCESS;
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+		ret =3D NET_RX_SUCCESS;
=20
 out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
-	if (router)
-		batadv_neigh_node_free_ref(router);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	return ret;
@@ -398,7 +384,6 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	struct batadv_icmp_packet_rr *icmp_packet;
 	struct ethhdr *ethhdr;
 	struct batadv_orig_node *orig_node =3D NULL;
-	struct batadv_neigh_node *router =3D NULL;
 	int hdr_size =3D sizeof(struct batadv_icmp_packet);
 	int ret =3D NET_RX_DROP;
=20
@@ -447,10 +432,6 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	if (!orig_node)
 		goto out;
=20
-	router =3D batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto out;
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
@@ -461,12 +442,10 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	icmp_packet->header.ttl--;
=20
 	/* route it */
-	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
-	ret =3D NET_RX_SUCCESS;
+	if (batadv_send_skb_to_orig(skb, orig_node, recv_if))
+		ret =3D NET_RX_SUCCESS;
=20
 out:
-	if (router)
-		batadv_neigh_node_free_ref(router);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	return ret;
@@ -882,8 +861,8 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 			   skb->len + ETH_HLEN);
=20
 	/* route it */
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D NET_RX_SUCCESS;
+	if (batadv_send_skb_to_orig(skb, orig_node, recv_if))
+		ret =3D NET_RX_SUCCESS;
=20
 out:
 	if (neigh_node)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 660d9bf..c7f7023 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -78,6 +78,39 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
=20
+/**
+ * batadv_send_skb_to_orig - Lookup next-hop and transmit skb.
+ * @skb: Packet to be transmitted.
+ * @orig_node: Final destination of the packet.
+ * @recv_if: Interface used when receiving the packet (can be NULL).
+ *
+ * Looks up the best next-hop towards the passed originator and passes=
 the
+ * skb on for preparation of MAC header. If the packet originated from=
 this
+ * host, NULL can be passed as recv_if and no interface alternating is
+ * attempted.
+ *
+ * Returns TRUE on success; FALSE otherwise.
+ */
+bool batadv_send_skb_to_orig(struct sk_buff *skb,
+			     struct batadv_orig_node *orig_node,
+			     struct batadv_hard_iface *recv_if)
+{
+	struct batadv_priv *bat_priv =3D orig_node->bat_priv;
+	struct batadv_neigh_node *neigh_node;
+
+	/* batadv_find_router() increases neigh_nodes refcount if found. */
+	neigh_node =3D batadv_find_router(bat_priv, orig_node, recv_if);
+	if (!neigh_node)
+		return false;
+
+	/* route it */
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
+
+	batadv_neigh_node_free_ref(neigh_node);
+
+	return true;
+}
+
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 643329b..0078dec 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -23,6 +23,9 @@
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr);
+bool batadv_send_skb_to_orig(struct sk_buff *skb,
+			     struct batadv_orig_node *orig_node,
+			     struct batadv_hard_iface *recv_if);
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface);
 int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index cdad824..22457a7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1642,7 +1642,6 @@ static int batadv_send_tt_request(struct batadv_p=
riv *bat_priv,
 {
 	struct sk_buff *skb =3D NULL;
 	struct batadv_tt_query_packet *tt_request;
-	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_tt_req_node *tt_req_node =3D NULL;
 	int ret =3D 1;
@@ -1680,23 +1679,15 @@ static int batadv_send_tt_request(struct batadv=
_priv *bat_priv,
 	if (full_table)
 		tt_request->flags |=3D BATADV_TT_FULL_TABLE;
=20
-	neigh_node =3D batadv_orig_node_get_router(dst_orig_node);
-	if (!neigh_node)
-		goto out;
-
-	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending TT_REQUEST to %pM via %pM [%c]\n",
-		   dst_orig_node->orig, neigh_node->addr,
-		   (full_table ? 'F' : '.'));
+	batadv_dbg(BATADV_DBG_TT, bat_priv, "Sending TT_REQUEST to %pM [%c]\n=
",
+		   dst_orig_node->orig, (full_table ? 'F' : '.'));
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_TX);
=20
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D 0;
+	if (batadv_send_skb_to_orig(skb, dst_orig_node, NULL))
+		ret =3D 0;
=20
 out:
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 	if (ret)
@@ -1716,7 +1707,6 @@ batadv_send_other_tt_response(struct batadv_priv =
*bat_priv,
 {
 	struct batadv_orig_node *req_dst_orig_node;
 	struct batadv_orig_node *res_dst_orig_node =3D NULL;
-	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_hard_iface *primary_if =3D NULL;
 	uint8_t orig_ttvn, req_ttvn, ttvn;
 	int ret =3D false;
@@ -1742,10 +1732,6 @@ batadv_send_other_tt_response(struct batadv_priv=
 *bat_priv,
 	if (!res_dst_orig_node)
 		goto out;
=20
-	neigh_node =3D batadv_orig_node_get_router(res_dst_orig_node);
-	if (!neigh_node)
-		goto out;
-
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
@@ -1817,14 +1803,13 @@ batadv_send_other_tt_response(struct batadv_pri=
v *bat_priv,
 		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending TT_RESPONSE %pM via %pM for %pM (ttvn: %u)\n",
-		   res_dst_orig_node->orig, neigh_node->addr,
-		   req_dst_orig_node->orig, req_ttvn);
+		   "Sending TT_RESPONSE %pM for %pM (ttvn: %u)\n",
+		   res_dst_orig_node->orig, req_dst_orig_node->orig, req_ttvn);
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
=20
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D true;
+	if (batadv_send_skb_to_orig(skb, res_dst_orig_node, NULL))
+		ret =3D true;
 	goto out;
=20
 unlock:
@@ -1835,8 +1820,6 @@ out:
 		batadv_orig_node_free_ref(res_dst_orig_node);
 	if (req_dst_orig_node)
 		batadv_orig_node_free_ref(req_dst_orig_node);
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 	if (!ret)
@@ -1850,7 +1833,6 @@ batadv_send_my_tt_response(struct batadv_priv *ba=
t_priv,
 			   struct batadv_tt_query_packet *tt_request)
 {
 	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_hard_iface *primary_if =3D NULL;
 	uint8_t my_ttvn, req_ttvn, ttvn;
 	int ret =3D false;
@@ -1875,10 +1857,6 @@ batadv_send_my_tt_response(struct batadv_priv *b=
at_priv,
 	if (!orig_node)
 		goto out;
=20
-	neigh_node =3D batadv_orig_node_get_router(orig_node);
-	if (!neigh_node)
-		goto out;
-
 	primary_if =3D batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
@@ -1942,14 +1920,14 @@ batadv_send_my_tt_response(struct batadv_priv *=
bat_priv,
 		tt_response->flags |=3D BATADV_TT_FULL_TABLE;
=20
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending TT_RESPONSE to %pM via %pM [%c]\n",
-		   orig_node->orig, neigh_node->addr,
+		   "Sending TT_RESPONSE to %pM [%c]\n",
+		   orig_node->orig,
 		   (tt_response->flags & BATADV_TT_FULL_TABLE ? 'F' : '.'));
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
=20
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D true;
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+		ret =3D true;
 	goto out;
=20
 unlock:
@@ -1957,8 +1935,6 @@ unlock:
 out:
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 	if (!ret)
@@ -2223,7 +2199,6 @@ unlock:
 static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t=
 *client,
 				 struct batadv_orig_node *orig_node)
 {
-	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct sk_buff *skb =3D NULL;
 	struct batadv_roam_adv_packet *roam_adv_packet;
 	int ret =3D 1;
@@ -2256,23 +2231,17 @@ static void batadv_send_roam_adv(struct batadv_=
priv *bat_priv, uint8_t *client,
 	memcpy(roam_adv_packet->dst, orig_node->orig, ETH_ALEN);
 	memcpy(roam_adv_packet->client, client, ETH_ALEN);
=20
-	neigh_node =3D batadv_orig_node_get_router(orig_node);
-	if (!neigh_node)
-		goto out;
-
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Sending ROAMING_ADV to %pM (client %pM) via %pM\n",
-		   orig_node->orig, client, neigh_node->addr);
+		   "Sending ROAMING_ADV to %pM (client %pM)\n",
+		   orig_node->orig, client);
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_TX);
=20
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D 0;
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+		ret =3D 0;
=20
 out:
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
-	if (ret)
+	if (ret && skb)
 		kfree_skb(skb);
 	return;
 }
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index c9a1f65..10aff49 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -402,7 +402,7 @@ int batadv_unicast_generic_send_skb(struct batadv_p=
riv *bat_priv,
 	struct batadv_orig_node *orig_node;
 	struct batadv_neigh_node *neigh_node;
 	int data_len =3D skb->len;
-	int ret =3D 1;
+	int ret =3D NET_RX_DROP;
 	unsigned int dev_mtu;
=20
 	/* get routing information */
@@ -466,15 +466,15 @@ find_router:
 		goto out;
 	}
=20
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
-	ret =3D 0;
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+		ret =3D 0;
=20
 out:
 	if (neigh_node)
 		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
-	if (ret =3D=3D 1)
+	if (ret =3D=3D NET_RX_DROP)
 		kfree_skb(skb);
 	return ret;
 }
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index ad14a6c..0f65a9d 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -698,15 +698,12 @@ static void batadv_purge_vis_packets(struct batad=
v_priv *bat_priv)
 static void batadv_broadcast_vis_packet(struct batadv_priv *bat_priv,
 					struct batadv_vis_info *info)
 {
-	struct batadv_neigh_node *router;
 	struct batadv_hashtable *hash =3D bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct batadv_orig_node *orig_node;
 	struct batadv_vis_packet *packet;
 	struct sk_buff *skb;
-	struct batadv_hard_iface *hard_iface;
-	uint8_t dstaddr[ETH_ALEN];
 	uint32_t i;
=20
=20
@@ -722,30 +719,20 @@ static void batadv_broadcast_vis_packet(struct ba=
tadv_priv *bat_priv,
 			if (!(orig_node->flags & BATADV_VIS_SERVER))
 				continue;
=20
-			router =3D batadv_orig_node_get_router(orig_node);
-			if (!router)
-				continue;
-
 			/* don't send it if we already received the packet from
 			 * this node.
 			 */
 			if (batadv_recv_list_is_in(bat_priv, &info->recv_list,
-						   orig_node->orig)) {
-				batadv_neigh_node_free_ref(router);
+						   orig_node->orig))
 				continue;
-			}
=20
 			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
-			hard_iface =3D router->if_incoming;
-			memcpy(dstaddr, router->addr, ETH_ALEN);
-
-			batadv_neigh_node_free_ref(router);
-
 			skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
-			if (skb)
-				batadv_send_skb_packet(skb, hard_iface,
-						       dstaddr);
+			if (!skb)
+				continue;
=20
+			if (!batadv_send_skb_to_orig(skb, orig_node, NULL))
+				kfree_skb(skb);
 		}
 		rcu_read_unlock();
 	}
@@ -755,7 +742,6 @@ static void batadv_unicast_vis_packet(struct batadv=
_priv *bat_priv,
 				      struct batadv_vis_info *info)
 {
 	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *router =3D NULL;
 	struct sk_buff *skb;
 	struct batadv_vis_packet *packet;
=20
@@ -765,17 +751,14 @@ static void batadv_unicast_vis_packet(struct bata=
dv_priv *bat_priv,
 	if (!orig_node)
 		goto out;
=20
-	router =3D batadv_orig_node_get_router(orig_node);
-	if (!router)
-		goto out;
-
 	skb =3D skb_clone(info->skb_packet, GFP_ATOMIC);
-	if (skb)
-		batadv_send_skb_packet(skb, router->if_incoming, router->addr);
+	if (!skb)
+		goto out;
+
+	if (!batadv_send_skb_to_orig(skb, orig_node, NULL))
+		kfree_skb(skb);
=20
 out:
-	if (router)
-		batadv_neigh_node_free_ref(router);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 }
--=20
1.8.0
