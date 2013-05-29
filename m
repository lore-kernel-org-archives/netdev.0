From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 20/21] batman-adv: Move call to batadv_nc_skb_forward() from routing.c to send.c
Date: Wed, 29 May 2013 10:12:31 +0200
Message-ID: <1369815152-2750-3-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
 <1369815152-2750-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50582 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965092Ab3E2IOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:14:31 -0400
In-Reply-To: <1369815152-2750-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

The call to batadv_nc_skb_forward() fits better in
batadv_send_skb_to_orig(), as this is where the actual next hop is
looked up.

To let the caller of batadv_send_skb_to_orig() know wether the skb is
transmitted, buffered or failed, the return value is changed from
boolean to int.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c    |  5 ++---
 net/batman-adv/network-coding.h    |  6 ++----
 net/batman-adv/routing.c           | 23 +++++++++++++----------
 net/batman-adv/send.c              | 27 +++++++++++++++++++--------
 net/batman-adv/send.h              |  6 +++---
 net/batman-adv/translation-table.c | 12 +++++++-----
 net/batman-adv/unicast.c           |  2 +-
 net/batman-adv/vis.c               |  7 ++++---
 8 files changed, 51 insertions(+), 37 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 22cd51f..a487d46 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1359,18 +1359,17 @@ static bool batadv_nc_skb_add_to_path(struct sk=
_buff *skb,
  *  buffer
  * @skb: data skb to forward
  * @neigh_node: next hop to forward packet to
- * @ethhdr: pointer to the ethernet header inside the skb
  *
  * Returns true if the skb was consumed (encoded packet sent) or false=
 otherwise
  */
 bool batadv_nc_skb_forward(struct sk_buff *skb,
-			   struct batadv_neigh_node *neigh_node,
-			   struct ethhdr *ethhdr)
+			   struct batadv_neigh_node *neigh_node)
 {
 	const struct net_device *netdev =3D neigh_node->if_incoming->soft_ifa=
ce;
 	struct batadv_priv *bat_priv =3D netdev_priv(netdev);
 	struct batadv_unicast_packet *packet;
 	struct batadv_nc_path *nc_path;
+	struct ethhdr *ethhdr =3D eth_hdr(skb);
 	__be32 packet_id;
 	u8 *payload;
=20
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index 4fa6d0c..85a4ec8 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -36,8 +36,7 @@ void batadv_nc_purge_orig(struct batadv_priv *bat_pri=
v,
 void batadv_nc_init_bat_priv(struct batadv_priv *bat_priv);
 void batadv_nc_init_orig(struct batadv_orig_node *orig_node);
 bool batadv_nc_skb_forward(struct sk_buff *skb,
-			   struct batadv_neigh_node *neigh_node,
-			   struct ethhdr *ethhdr);
+			   struct batadv_neigh_node *neigh_node);
 void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
 				      struct sk_buff *skb);
 void batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
@@ -87,8 +86,7 @@ static inline void batadv_nc_init_orig(struct batadv_=
orig_node *orig_node)
 }
=20
 static inline bool batadv_nc_skb_forward(struct sk_buff *skb,
-					 struct batadv_neigh_node *neigh_node,
-					 struct ethhdr *ethhdr)
+					 struct batadv_neigh_node *neigh_node)
 {
 	return false;
 }
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index fad0846..2f0bd3f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -285,7 +285,7 @@ static int batadv_recv_my_icmp_packet(struct batadv=
_priv *bat_priv,
 	icmp_packet->msg_type =3D BATADV_ECHO_REPLY;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
 		ret =3D NET_RX_SUCCESS;
=20
 out:
@@ -333,7 +333,7 @@ static int batadv_recv_icmp_ttl_exceeded(struct bat=
adv_priv *bat_priv,
 	icmp_packet->msg_type =3D BATADV_TTL_EXCEEDED;
 	icmp_packet->header.ttl =3D BATADV_TTL;
=20
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
 		ret =3D NET_RX_SUCCESS;
=20
 out:
@@ -410,7 +410,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	icmp_packet->header.ttl--;
=20
 	/* route it */
-	if (batadv_send_skb_to_orig(skb, orig_node, recv_if))
+	if (batadv_send_skb_to_orig(skb, orig_node, recv_if) !=3D NET_XMIT_DR=
OP)
 		ret =3D NET_RX_SUCCESS;
=20
 out:
@@ -775,7 +775,7 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr =3D eth_hdr(skb);
-	int ret =3D NET_RX_DROP;
+	int res, ret =3D NET_RX_DROP;
 	struct sk_buff *new_skb;
=20
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
@@ -835,16 +835,19 @@ static int batadv_route_unicast_packet(struct sk_=
buff *skb,
 	/* decrement ttl */
 	unicast_packet->header.ttl--;
=20
-	/* network code packet if possible */
-	if (batadv_nc_skb_forward(skb, neigh_node, ethhdr)) {
-		ret =3D NET_RX_SUCCESS;
-	} else if (batadv_send_skb_to_orig(skb, orig_node, recv_if)) {
-		ret =3D NET_RX_SUCCESS;
+	res =3D batadv_send_skb_to_orig(skb, orig_node, recv_if);
=20
-		/* Update stats counter */
+	/* translate transmit result into receive result */
+	if (res =3D=3D NET_XMIT_SUCCESS) {
+		/* skb was transmitted and consumed */
 		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
 		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
 				   skb->len + ETH_HLEN);
+
+		ret =3D NET_RX_SUCCESS;
+	} else if (res =3D=3D NET_XMIT_POLICED) {
+		/* skb was buffered and consumed */
+		ret =3D NET_RX_SUCCESS;
 	}
=20
 out:
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index ce69f45..e9ff8d8 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -96,26 +96,37 @@ send_skb_err:
  * host, NULL can be passed as recv_if and no interface alternating is
  * attempted.
  *
- * Returns TRUE on success; FALSE otherwise.
+ * Returns NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
+ * NET_XMIT_POLICED if the skb is buffered for later transmit.
  */
-bool batadv_send_skb_to_orig(struct sk_buff *skb,
-			     struct batadv_orig_node *orig_node,
-			     struct batadv_hard_iface *recv_if)
+int batadv_send_skb_to_orig(struct sk_buff *skb,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_hard_iface *recv_if)
 {
 	struct batadv_priv *bat_priv =3D orig_node->bat_priv;
 	struct batadv_neigh_node *neigh_node;
+	int ret =3D NET_XMIT_DROP;
=20
 	/* batadv_find_router() increases neigh_nodes refcount if found. */
 	neigh_node =3D batadv_find_router(bat_priv, orig_node, recv_if);
 	if (!neigh_node)
-		return false;
+		return ret;
=20
-	/* route it */
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
+	/* try to network code the packet, if it is received on an interface
+	 * (i.e. being forwarded). If the packet originates from this node or=
 if
+	 * network coding fails, then send the packet as usual.
+	 */
+	if (recv_if && batadv_nc_skb_forward(skb, neigh_node)) {
+		ret =3D NET_XMIT_POLICED;
+	} else {
+		batadv_send_skb_packet(skb, neigh_node->if_incoming,
+				       neigh_node->addr);
+		ret =3D NET_XMIT_SUCCESS;
+	}
=20
 	batadv_neigh_node_free_ref(neigh_node);
=20
-	return true;
+	return ret;
 }
=20
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 38e662f..e7b1788 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -23,9 +23,9 @@
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr);
-bool batadv_send_skb_to_orig(struct sk_buff *skb,
-			     struct batadv_orig_node *orig_node,
-			     struct batadv_hard_iface *recv_if);
+int batadv_send_skb_to_orig(struct sk_buff *skb,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_hard_iface *recv_if);
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface);
 int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index e272f68..429aeef 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1713,7 +1713,7 @@ static int batadv_send_tt_request(struct batadv_p=
riv *bat_priv,
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_REQUEST_TX);
=20
-	if (batadv_send_skb_to_orig(skb, dst_orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, dst_orig_node, NULL) !=3D NET_XMIT_D=
ROP)
 		ret =3D 0;
=20
 out:
@@ -1737,7 +1737,7 @@ batadv_send_other_tt_response(struct batadv_priv =
*bat_priv,
 	struct batadv_orig_node *req_dst_orig_node;
 	struct batadv_orig_node *res_dst_orig_node =3D NULL;
 	uint8_t orig_ttvn, req_ttvn, ttvn;
-	int ret =3D false;
+	int res, ret =3D false;
 	unsigned char *tt_buff;
 	bool full_table;
 	uint16_t tt_len, tt_tot;
@@ -1832,8 +1832,10 @@ batadv_send_other_tt_response(struct batadv_priv=
 *bat_priv,
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
=20
-	if (batadv_send_skb_to_orig(skb, res_dst_orig_node, NULL))
+	res =3D batadv_send_skb_to_orig(skb, res_dst_orig_node, NULL);
+	if (res !=3D NET_XMIT_DROP)
 		ret =3D true;
+
 	goto out;
=20
 unlock:
@@ -1947,7 +1949,7 @@ batadv_send_my_tt_response(struct batadv_priv *ba=
t_priv,
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_RESPONSE_TX);
=20
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
 		ret =3D true;
 	goto out;
=20
@@ -2260,7 +2262,7 @@ static void batadv_send_roam_adv(struct batadv_pr=
iv *bat_priv, uint8_t *client,
=20
 	batadv_inc_counter(bat_priv, BATADV_CNT_TT_ROAM_ADV_TX);
=20
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
 		ret =3D 0;
=20
 out:
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 0bb3b59..dc8b5d4 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -464,7 +464,7 @@ find_router:
 		goto out;
 	}
=20
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
 		ret =3D 0;
=20
 out:
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 94eaeb5..4983340 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -697,7 +697,7 @@ static void batadv_broadcast_vis_packet(struct bata=
dv_priv *bat_priv,
 	struct batadv_orig_node *orig_node;
 	struct batadv_vis_packet *packet;
 	struct sk_buff *skb;
-	uint32_t i;
+	uint32_t i, res;
=20
=20
 	packet =3D (struct batadv_vis_packet *)info->skb_packet->data;
@@ -724,7 +724,8 @@ static void batadv_broadcast_vis_packet(struct bata=
dv_priv *bat_priv,
 			if (!skb)
 				continue;
=20
-			if (!batadv_send_skb_to_orig(skb, orig_node, NULL))
+			res =3D batadv_send_skb_to_orig(skb, orig_node, NULL);
+			if (res =3D=3D NET_XMIT_DROP)
 				kfree_skb(skb);
 		}
 		rcu_read_unlock();
@@ -748,7 +749,7 @@ static void batadv_unicast_vis_packet(struct batadv=
_priv *bat_priv,
 	if (!skb)
 		goto out;
=20
-	if (!batadv_send_skb_to_orig(skb, orig_node, NULL))
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) =3D=3D NET_XMIT_DRO=
P)
 		kfree_skb(skb);
=20
 out:
--=20
1.8.1.5
