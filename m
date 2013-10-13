From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 07/16] batman-adv: Remove old fragmentation code
Date: Sun, 13 Oct 2013 13:22:52 +0200
Message-ID: <1381663381-626-8-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:43018 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab3JMLYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:33 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Remove the existing fragmentation code before adding the new version
and delete unicast.{h,c}.

batadv_unicast_send_skb() is moved to send.c and renamed to
batadv_send_skb_unicast().

fragmentation entry in sysfs (bat_priv->fragmentation) is kept for use =
in
the new fragmentation code.

BATADV_UNICAST_FRAG packet type is renamed to BATADV_FRAG for use in th=
e
new fragmentation code.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Makefile                |   1 -
 net/batman-adv/distributed-arp-table.c |  11 +-
 net/batman-adv/hard-interface.c        |   1 -
 net/batman-adv/main.c                  |   4 -
 net/batman-adv/originator.c            |   9 -
 net/batman-adv/packet.h                |  16 --
 net/batman-adv/routing.c               |  86 +-----
 net/batman-adv/routing.h               |   2 -
 net/batman-adv/send.c                  | 174 ++++++++++++
 net/batman-adv/send.h                  |  40 +++
 net/batman-adv/soft-interface.c        |   4 +-
 net/batman-adv/types.h                 |  19 --
 net/batman-adv/unicast.c               | 491 -------------------------=
--------
 net/batman-adv/unicast.h               |  92 ------
 14 files changed, 221 insertions(+), 729 deletions(-)
 delete mode 100644 net/batman-adv/unicast.c
 delete mode 100644 net/batman-adv/unicast.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 8ddbfe6..f9b465b 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -37,4 +37,3 @@ batman-adv-y +=3D send.o
 batman-adv-y +=3D soft-interface.o
 batman-adv-y +=3D sysfs.o
 batman-adv-y +=3D translation-table.o
-batman-adv-y +=3D unicast.o
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index f07ec32..99da412 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -29,7 +29,6 @@
 #include "send.h"
 #include "types.h"
 #include "translation-table.h"
-#include "unicast.h"
=20
 static void batadv_dat_purge(struct work_struct *work);
=20
@@ -592,9 +591,9 @@ static bool batadv_dat_send_data(struct batadv_priv=
 *bat_priv,
 			goto free_orig;
=20
 		tmp_skb =3D pskb_copy(skb, GFP_ATOMIC);
-		if (!batadv_unicast_4addr_prepare_skb(bat_priv, tmp_skb,
-						      cand[i].orig_node,
-						      packet_subtype)) {
+		if (!batadv_send_skb_prepare_unicast_4addr(bat_priv, tmp_skb,
+							   cand[i].orig_node,
+							   packet_subtype)) {
 			kfree_skb(tmp_skb);
 			goto free_neigh;
 		}
@@ -990,10 +989,10 @@ bool batadv_dat_snoop_incoming_arp_request(struct=
 batadv_priv *bat_priv,
 	 * that a node not using the 4addr packet format doesn't support it.
 	 */
 	if (hdr_size =3D=3D sizeof(struct batadv_unicast_4addr_packet))
-		err =3D batadv_unicast_4addr_send_skb(bat_priv, skb_new,
+		err =3D batadv_send_skb_unicast_4addr(bat_priv, skb_new,
 						    BATADV_P_DAT_CACHE_REPLY);
 	else
-		err =3D batadv_unicast_send_skb(bat_priv, skb_new);
+		err =3D batadv_send_skb_unicast(bat_priv, skb_new);
=20
 	if (!err) {
 		batadv_inc_counter(bat_priv, BATADV_CNT_DAT_CACHED_REPLY_TX);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index eeb6671..0c8602e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -444,7 +444,6 @@ int batadv_hardif_enable_interface(struct batadv_ha=
rd_iface *hard_iface,
 	hard_iface->batman_adv_ptype.dev =3D hard_iface->net_dev;
 	dev_add_pack(&hard_iface->batman_adv_ptype);
=20
-	atomic_set(&hard_iface->frag_seqno, 1);
 	batadv_info(hard_iface->soft_iface, "Adding interface: %s\n",
 		    hard_iface->net_dev->name);
=20
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8b195e6..8822fad 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -36,7 +36,6 @@
 #include "gateway_client.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
-#include "unicast.h"
 #include "gateway_common.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -399,7 +398,6 @@ static void batadv_recv_handler_init(void)
 	/* compile time checks for struct member offsets */
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_4addr_packet, src) !=3D 1=
0);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_packet, dest) !=3D 4);
-	BUILD_BUG_ON(offsetof(struct batadv_unicast_frag_packet, dest) !=3D 4=
);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_tvlv_packet, dst) !=3D 4)=
;
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, dst) !=3D 4);
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, dst) !=3D 4);
@@ -412,8 +410,6 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_UNICAST_4ADDR] =3D batadv_recv_unicast_packe=
t;
 	/* unicast packet */
 	batadv_rx_handler[BATADV_UNICAST] =3D batadv_recv_unicast_packet;
-	/* fragmented unicast packet */
-	batadv_rx_handler[BATADV_UNICAST_FRAG] =3D batadv_recv_ucast_frag_pac=
ket;
 	/* unicast tvlv packet */
 	batadv_rx_handler[BATADV_UNICAST_TVLV] =3D batadv_recv_unicast_tvlv;
 	/* batman icmp packet */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 5d53d2f..898b0ce 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -25,7 +25,6 @@
 #include "routing.h"
 #include "gateway_client.h"
 #include "hard-interface.h"
-#include "unicast.h"
 #include "soft-interface.h"
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
@@ -146,7 +145,6 @@ static void batadv_orig_node_free_rcu(struct rcu_he=
ad *rcu)
 	/* Free nc_nodes */
 	batadv_nc_purge_orig(orig_node->bat_priv, orig_node, NULL);
=20
-	batadv_frag_list_free(&orig_node->frag_list);
 	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node,
 				  "originator timed out");
=20
@@ -269,9 +267,6 @@ struct batadv_orig_node *batadv_get_orig_node(struc=
t batadv_priv *bat_priv,
 	size =3D bat_priv->num_ifaces * sizeof(uint8_t);
 	orig_node->bcast_own_sum =3D kzalloc(size, GFP_ATOMIC);
=20
-	INIT_LIST_HEAD(&orig_node->frag_list);
-	orig_node->last_frag_packet =3D 0;
-
 	if (!orig_node->bcast_own_sum)
 		goto free_bcast_own;
=20
@@ -393,10 +388,6 @@ static void _batadv_purge_orig(struct batadv_priv =
*bat_priv)
 				batadv_orig_node_free_ref(orig_node);
 				continue;
 			}
-
-			if (batadv_has_timed_out(orig_node->last_frag_packet,
-						 BATADV_FRAG_TIMEOUT))
-				batadv_frag_list_free(&orig_node->frag_list);
 		}
 		spin_unlock_bh(list_lock);
 	}
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 4361bae..5e3b102 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -91,12 +91,6 @@ enum batadv_icmp_packettype {
 	BATADV_PARAMETER_PROBLEM       =3D 12,
 };
=20
-/* fragmentation defines */
-enum batadv_unicast_frag_flags {
-	BATADV_UNI_FRAG_HEAD	  =3D BIT(0),
-	BATADV_UNI_FRAG_LARGETAIL =3D BIT(1),
-};
-
 /* tt data subtypes */
 #define BATADV_TT_DATA_TYPE_MASK 0x0F
=20
@@ -255,16 +249,6 @@ struct batadv_unicast_4addr_packet {
 	 */
 };
=20
-struct batadv_unicast_frag_packet {
-	struct batadv_header header;
-	uint8_t  ttvn; /* destination translation table version number */
-	uint8_t  dest[ETH_ALEN];
-	uint8_t  flags;
-	uint8_t  align;
-	uint8_t  orig[ETH_ALEN];
-	__be16   seqno;
-} __packed;
-
 struct batadv_bcast_packet {
 	struct batadv_header header;
 	uint8_t  reserved;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 0dc1c0e..fd2cdbc 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -25,7 +25,6 @@
 #include "icmp_socket.h"
 #include "translation-table.h"
 #include "originator.h"
-#include "unicast.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "network-coding.h"
@@ -653,11 +652,9 @@ static int batadv_route_unicast_packet(struct sk_b=
uff *skb,
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_orig_node *orig_node =3D NULL;
-	struct batadv_neigh_node *neigh_node =3D NULL;
 	struct batadv_unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr =3D eth_hdr(skb);
 	int res, hdr_len, ret =3D NET_RX_DROP;
-	struct sk_buff *new_skb;
=20
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
@@ -674,46 +671,12 @@ static int batadv_route_unicast_packet(struct sk_=
buff *skb,
 	if (!orig_node)
 		goto out;
=20
-	/* find_router() increases neigh_nodes refcount if found. */
-	neigh_node =3D batadv_find_router(bat_priv, orig_node, recv_if);
-
-	if (!neigh_node)
-		goto out;
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, ETH_HLEN) < 0)
 		goto out;
=20
-	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
-
-	if (unicast_packet->header.packet_type =3D=3D BATADV_UNICAST &&
-	    atomic_read(&bat_priv->fragmentation) &&
-	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
-		ret =3D batadv_frag_send_skb(skb, bat_priv,
-					   neigh_node->if_incoming,
-					   neigh_node->addr);
-		goto out;
-	}
-
-	if (unicast_packet->header.packet_type =3D=3D BATADV_UNICAST_FRAG &&
-	    batadv_frag_can_reassemble(skb,
-				       neigh_node->if_incoming->net_dev->mtu)) {
-		ret =3D batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
-
-		if (ret =3D=3D NET_RX_DROP)
-			goto out;
-
-		/* packet was buffered for late merge */
-		if (!new_skb) {
-			ret =3D NET_RX_SUCCESS;
-			goto out;
-		}
-
-		skb =3D new_skb;
-		unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
-	}
-
 	/* decrement ttl */
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
 	unicast_packet->header.ttl--;
=20
 	switch (unicast_packet->header.packet_type) {
@@ -748,8 +711,6 @@ static int batadv_route_unicast_packet(struct sk_bu=
ff *skb,
 	}
=20
 out:
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	return ret;
@@ -1003,51 +964,6 @@ rx_success:
 	return batadv_route_unicast_packet(skb, recv_if);
 }
=20
-int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
-				  struct batadv_hard_iface *recv_if)
-{
-	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
-	struct batadv_unicast_frag_packet *unicast_packet;
-	int hdr_size =3D sizeof(*unicast_packet);
-	struct sk_buff *new_skb =3D NULL;
-	int ret;
-
-	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
-		return NET_RX_DROP;
-
-	if (!batadv_check_unicast_ttvn(bat_priv, skb, hdr_size))
-		return NET_RX_DROP;
-
-	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
-
-	/* packet for me */
-	if (batadv_is_my_mac(bat_priv, unicast_packet->dest)) {
-		ret =3D batadv_frag_reassemble_skb(skb, bat_priv, &new_skb);
-
-		if (ret =3D=3D NET_RX_DROP)
-			return NET_RX_DROP;
-
-		/* packet was buffered for late merge */
-		if (!new_skb)
-			return NET_RX_SUCCESS;
-
-		if (batadv_dat_snoop_incoming_arp_request(bat_priv, new_skb,
-							  hdr_size))
-			goto rx_success;
-		if (batadv_dat_snoop_incoming_arp_reply(bat_priv, new_skb,
-							hdr_size))
-			goto rx_success;
-
-		batadv_interface_rx(recv_if->soft_iface, new_skb, recv_if,
-				    sizeof(struct batadv_unicast_packet), NULL);
-
-rx_success:
-		return NET_RX_SUCCESS;
-	}
-
-	return batadv_route_unicast_packet(skb, recv_if);
-}
-
 /**
  * batadv_recv_unicast_tvlv - receive and process unicast tvlv packets
  * @skb: unicast tvlv packet to process
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index ea15fa6..efab583 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -30,8 +30,6 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if);
 int batadv_recv_unicast_packet(struct sk_buff *skb,
 			       struct batadv_hard_iface *recv_if);
-int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
-				  struct batadv_hard_iface *recv_if);
 int batadv_recv_bcast_packet(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if);
 int batadv_recv_tt_query(struct sk_buff *skb,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 81d69fb..b8356ec 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -25,6 +25,7 @@
 #include "soft-interface.h"
 #include "hard-interface.h"
 #include "gateway_common.h"
+#include "gateway_client.h"
 #include "originator.h"
 #include "network-coding.h"
=20
@@ -127,6 +128,179 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	return ret;
 }
=20
+/**
+ * batadv_send_skb_push_fill_unicast - extend the buffer and initializ=
e the
+ *  common fields for unicast packets
+ * @skb: the skb carrying the unicast header to initialize
+ * @hdr_size: amount of bytes to push at the beginning of the skb
+ * @orig_node: the destination node
+ *
+ * Returns false if the buffer extension was not possible or true othe=
rwise.
+ */
+static bool
+batadv_send_skb_push_fill_unicast(struct sk_buff *skb, int hdr_size,
+				  struct batadv_orig_node *orig_node)
+{
+	struct batadv_unicast_packet *unicast_packet;
+	uint8_t ttvn =3D (uint8_t)atomic_read(&orig_node->last_ttvn);
+
+	if (batadv_skb_head_push(skb, hdr_size) < 0)
+		return false;
+
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
+	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
+	/* batman packet type: unicast */
+	unicast_packet->header.packet_type =3D BATADV_UNICAST;
+	/* set unicast ttl */
+	unicast_packet->header.ttl =3D BATADV_TTL;
+	/* copy the destination for faster routing */
+	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
+	/* set the destination tt version number */
+	unicast_packet->ttvn =3D ttvn;
+
+	return true;
+}
+
+/**
+ * batadv_send_skb_prepare_unicast - encapsulate an skb with a unicast=
 header
+ * @skb: the skb containing the payload to encapsulate
+ * @orig_node: the destination node
+ *
+ * Returns false if the payload could not be encapsulated or true othe=
rwise.
+ */
+static bool batadv_send_skb_prepare_unicast(struct sk_buff *skb,
+					    struct batadv_orig_node *orig_node)
+{
+	size_t uni_size =3D sizeof(struct batadv_unicast_packet);
+
+	return batadv_send_skb_push_fill_unicast(skb, uni_size, orig_node);
+}
+
+/**
+ * batadv_send_skb_prepare_unicast_4addr - encapsulate an skb with a
+ *  unicast 4addr header
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the skb containing the payload to encapsulate
+ * @orig_node: the destination node
+ * @packet_subtype: the unicast 4addr packet subtype to use
+ *
+ * Returns false if the payload could not be encapsulated or true othe=
rwise.
+ */
+bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_pri=
v,
+					   struct sk_buff *skb,
+					   struct batadv_orig_node *orig,
+					   int packet_subtype)
+{
+	struct batadv_hard_iface *primary_if;
+	struct batadv_unicast_4addr_packet *uc_4addr_packet;
+	bool ret =3D false;
+
+	primary_if =3D batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* Pull the header space and fill the unicast_packet substructure.
+	 * We can do that because the first member of the uc_4addr_packet
+	 * is of type struct unicast_packet
+	 */
+	if (!batadv_send_skb_push_fill_unicast(skb, sizeof(*uc_4addr_packet),
+					       orig))
+		goto out;
+
+	uc_4addr_packet =3D (struct batadv_unicast_4addr_packet *)skb->data;
+	uc_4addr_packet->u.header.packet_type =3D BATADV_UNICAST_4ADDR;
+	memcpy(uc_4addr_packet->src, primary_if->net_dev->dev_addr, ETH_ALEN)=
;
+	uc_4addr_packet->subtype =3D packet_subtype;
+	uc_4addr_packet->reserved =3D 0;
+
+	ret =3D true;
+out:
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	return ret;
+}
+
+/**
+ * batadv_send_generic_unicast_skb - send an skb as unicast
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: payload to send
+ * @packet_type: the batman unicast packet type to use
+ * @packet_subtype: the unicast 4addr packet subtype (only relevant fo=
r unicast
+ *  4addr packets)
+ *
+ * Returns 1 in case of error or 0 otherwise.
+ */
+int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int packet_type,
+				    int packet_subtype)
+{
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
+	struct batadv_unicast_packet *unicast_packet;
+	struct batadv_orig_node *orig_node;
+	struct batadv_neigh_node *neigh_node;
+	int ret =3D NET_RX_DROP;
+
+	/* get routing information */
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		orig_node =3D batadv_gw_get_selected_orig(bat_priv);
+		if (orig_node)
+			goto find_router;
+	}
+
+	/* check for tt host - increases orig_node refcount.
+	 * returns NULL in case of AP isolation
+	 */
+	orig_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source,
+					     ethhdr->h_dest);
+
+find_router:
+	/* find_router():
+	 *  - if orig_node is NULL it returns NULL
+	 *  - increases neigh_nodes refcount if found.
+	 */
+	neigh_node =3D batadv_find_router(bat_priv, orig_node, NULL);
+
+	if (!neigh_node)
+		goto out;
+
+	switch (packet_type) {
+	case BATADV_UNICAST:
+		batadv_send_skb_prepare_unicast(skb, orig_node);
+		break;
+	case BATADV_UNICAST_4ADDR:
+		batadv_send_skb_prepare_unicast_4addr(bat_priv, skb, orig_node,
+						      packet_subtype);
+		break;
+	default:
+		/* this function supports UNICAST and UNICAST_4ADDR only. It
+		 * should never be invoked with any other packet type
+		 */
+		goto out;
+	}
+
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
+
+	/* inform the destination node that we are still missing a correct ro=
ute
+	 * for this client. The destination will receive this packet and will
+	 * try to reroute it because the ttvn contained in the header is less
+	 * than the current one
+	 */
+	if (batadv_tt_global_client_is_roaming(bat_priv, ethhdr->h_dest))
+		unicast_packet->ttvn =3D unicast_packet->ttvn - 1;
+
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
+		ret =3D 0;
+
+out:
+	if (neigh_node)
+		batadv_neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		batadv_orig_node_free_ref(orig_node);
+	if (ret =3D=3D NET_RX_DROP)
+		kfree_skb(skb);
+	return ret;
+}
+
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index e7b1788..ad63184 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -34,5 +34,45 @@ void batadv_send_outstanding_bat_ogm_packet(struct w=
ork_struct *work);
 void
 batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 				 const struct batadv_hard_iface *hard_iface);
+bool batadv_send_skb_prepare_unicast_4addr(struct batadv_priv *bat_pri=
v,
+					   struct sk_buff *skb,
+					   struct batadv_orig_node *orig_node,
+					   int packet_subtype);
+int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int packet_type,
+				    int packet_subtype);
+
+
+/**
+ * batadv_send_unicast_skb - send the skb encapsulated in a unicast pa=
cket
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the payload to send
+ *
+ * Returns 1 in case of error or 0 otherwise.
+ */
+static inline int batadv_send_skb_unicast(struct batadv_priv *bat_priv=
,
+					  struct sk_buff *skb)
+{
+	return batadv_send_skb_generic_unicast(bat_priv, skb, BATADV_UNICAST,
+					       0);
+}
+
+/**
+ * batadv_send_4addr_unicast_skb - send the skb encapsulated in a unic=
ast 4addr
+ *  packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the payload to send
+ * @packet_subtype: the unicast 4addr packet subtype to use
+ *
+ * Returns 1 in case of error or 0 otherwise.
+ */
+static inline int batadv_send_skb_unicast_4addr(struct batadv_priv *ba=
t_priv,
+						struct sk_buff *skb,
+						int packet_subtype)
+{
+	return batadv_send_skb_generic_unicast(bat_priv, skb,
+					       BATADV_UNICAST_4ADDR,
+					       packet_subtype);
+}
=20
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 25e6004..504d0bb 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -34,8 +34,6 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
-#include <linux/if_ether.h>
-#include "unicast.h"
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
=20
@@ -286,7 +284,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
=20
 		batadv_dat_snoop_outgoing_arp_reply(bat_priv, skb);
=20
-		ret =3D batadv_unicast_send_skb(bat_priv, skb);
+		ret =3D batadv_send_skb_unicast(bat_priv, skb);
 		if (ret !=3D 0)
 			goto dropped_freed;
 	}
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8fbd89d..795a079 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -60,7 +60,6 @@ struct batadv_hard_iface_bat_iv {
  * @if_num: identificator of the interface
  * @if_status: status of the interface for batman-adv
  * @net_dev: pointer to the net_device
- * @frag_seqno: last fragment sequence number sent by this interface
  * @num_bcasts: number of payload re-broadcasts on this interface (ARQ=
)
  * @hardif_obj: kobject of the per interface sysfs "mesh" directory
  * @refcount: number of contexts the object is used
@@ -76,7 +75,6 @@ struct batadv_hard_iface {
 	int16_t if_num;
 	char if_status;
 	struct net_device *net_dev;
-	atomic_t frag_seqno;
 	uint8_t num_bcasts;
 	struct kobject *hardif_obj;
 	atomic_t refcount;
@@ -116,9 +114,6 @@ struct batadv_hard_iface {
  *  last_bcast_seqno)
  * @last_bcast_seqno: last broadcast sequence number received by this =
host
  * @neigh_list: list of potential next hop neighbor towards this orig =
node
- * @frag_list: fragmentation buffer list for fragment re-assembly
- * @last_frag_packet: time when last fragmented packet from this node =
was
- *  received
  * @neigh_list_lock: lock protecting neigh_list, router and bonding_li=
st
  * @hash_entry: hlist node for batadv_priv::orig_hash
  * @bat_priv: pointer to soft_iface this orig node belongs to
@@ -159,8 +154,6 @@ struct batadv_orig_node {
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
 	uint32_t last_bcast_seqno;
 	struct hlist_head neigh_list;
-	struct list_head frag_list;
-	unsigned long last_frag_packet;
 	/* neigh_list_lock protects: neigh_list, router & bonding_list */
 	spinlock_t neigh_list_lock;
 	struct hlist_node hash_entry;
@@ -874,18 +867,6 @@ struct batadv_forw_packet {
 };
=20
 /**
- * struct batadv_frag_packet_list_entry - storage for fragment packet
- * @list: list node for orig_node::frag_list
- * @seqno: sequence number of the fragment
- * @skb: fragment's skb buffer
- */
-struct batadv_frag_packet_list_entry {
-	struct list_head list;
-	uint16_t seqno;
-	struct sk_buff *skb;
-};
-
-/**
  * struct batadv_algo_ops - mesh algorithm callbacks
  * @list: list node for the batadv_algo_list
  * @name: name of the algorithm
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
deleted file mode 100644
index 48b31d3..0000000
--- a/net/batman-adv/unicast.c
+++ /dev/null
@@ -1,491 +0,0 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
- *
- * Andreas Langer
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#include "main.h"
-#include "unicast.h"
-#include "send.h"
-#include "soft-interface.h"
-#include "gateway_client.h"
-#include "originator.h"
-#include "hash.h"
-#include "translation-table.h"
-#include "routing.h"
-#include "hard-interface.h"
-
-
-static struct sk_buff *
-batadv_frag_merge_packet(struct list_head *head,
-			 struct batadv_frag_packet_list_entry *tfp,
-			 struct sk_buff *skb)
-{
-	struct batadv_unicast_frag_packet *up;
-	struct sk_buff *tmp_skb;
-	struct batadv_unicast_packet *unicast_packet;
-	int hdr_len =3D sizeof(*unicast_packet);
-	int uni_diff =3D sizeof(*up) - hdr_len;
-	uint8_t *packet_pos;
-
-	up =3D (struct batadv_unicast_frag_packet *)skb->data;
-	/* set skb to the first part and tmp_skb to the second part */
-	if (up->flags & BATADV_UNI_FRAG_HEAD) {
-		tmp_skb =3D tfp->skb;
-	} else {
-		tmp_skb =3D skb;
-		skb =3D tfp->skb;
-	}
-
-	if (skb_linearize(skb) < 0 || skb_linearize(tmp_skb) < 0)
-		goto err;
-
-	skb_pull(tmp_skb, sizeof(*up));
-	if (pskb_expand_head(skb, 0, tmp_skb->len, GFP_ATOMIC) < 0)
-		goto err;
-
-	/* move free entry to end */
-	tfp->skb =3D NULL;
-	tfp->seqno =3D 0;
-	list_move_tail(&tfp->list, head);
-
-	memcpy(skb_put(skb, tmp_skb->len), tmp_skb->data, tmp_skb->len);
-	kfree_skb(tmp_skb);
-
-	memmove(skb->data + uni_diff, skb->data, hdr_len);
-	packet_pos =3D skb_pull(skb, uni_diff);
-	unicast_packet =3D (struct batadv_unicast_packet *)packet_pos;
-	unicast_packet->header.packet_type =3D BATADV_UNICAST;
-
-	return skb;
-
-err:
-	/* free buffered skb, skb will be freed later */
-	kfree_skb(tfp->skb);
-	return NULL;
-}
-
-static void batadv_frag_create_entry(struct list_head *head,
-				     struct sk_buff *skb)
-{
-	struct batadv_frag_packet_list_entry *tfp;
-	struct batadv_unicast_frag_packet *up;
-
-	up =3D (struct batadv_unicast_frag_packet *)skb->data;
-
-	/* free and oldest packets stand at the end */
-	tfp =3D list_entry((head)->prev, typeof(*tfp), list);
-	kfree_skb(tfp->skb);
-
-	tfp->seqno =3D ntohs(up->seqno);
-	tfp->skb =3D skb;
-	list_move(&tfp->list, head);
-	return;
-}
-
-static int batadv_frag_create_buffer(struct list_head *head)
-{
-	int i;
-	struct batadv_frag_packet_list_entry *tfp;
-
-	for (i =3D 0; i < BATADV_FRAG_BUFFER_SIZE; i++) {
-		tfp =3D kmalloc(sizeof(*tfp), GFP_ATOMIC);
-		if (!tfp) {
-			batadv_frag_list_free(head);
-			return -ENOMEM;
-		}
-		tfp->skb =3D NULL;
-		tfp->seqno =3D 0;
-		INIT_LIST_HEAD(&tfp->list);
-		list_add(&tfp->list, head);
-	}
-
-	return 0;
-}
-
-static struct batadv_frag_packet_list_entry *
-batadv_frag_search_packet(struct list_head *head,
-			  const struct batadv_unicast_frag_packet *up)
-{
-	struct batadv_frag_packet_list_entry *tfp;
-	struct batadv_unicast_frag_packet *tmp_up =3D NULL;
-	bool is_head_tmp, is_head;
-	uint16_t search_seqno;
-
-	if (up->flags & BATADV_UNI_FRAG_HEAD)
-		search_seqno =3D ntohs(up->seqno)+1;
-	else
-		search_seqno =3D ntohs(up->seqno)-1;
-
-	is_head =3D up->flags & BATADV_UNI_FRAG_HEAD;
-
-	list_for_each_entry(tfp, head, list) {
-		if (!tfp->skb)
-			continue;
-
-		if (tfp->seqno =3D=3D ntohs(up->seqno))
-			goto mov_tail;
-
-		tmp_up =3D (struct batadv_unicast_frag_packet *)tfp->skb->data;
-
-		if (tfp->seqno =3D=3D search_seqno) {
-			is_head_tmp =3D tmp_up->flags & BATADV_UNI_FRAG_HEAD;
-			if (is_head_tmp !=3D is_head)
-				return tfp;
-			else
-				goto mov_tail;
-		}
-	}
-	return NULL;
-
-mov_tail:
-	list_move_tail(&tfp->list, head);
-	return NULL;
-}
-
-void batadv_frag_list_free(struct list_head *head)
-{
-	struct batadv_frag_packet_list_entry *pf, *tmp_pf;
-
-	if (!list_empty(head)) {
-		list_for_each_entry_safe(pf, tmp_pf, head, list) {
-			kfree_skb(pf->skb);
-			list_del(&pf->list);
-			kfree(pf);
-		}
-	}
-	return;
-}
-
-/* frag_reassemble_skb():
- * returns NET_RX_DROP if the operation failed - skb is left intact
- * returns NET_RX_SUCCESS if the fragment was buffered (skb_new will b=
e NULL)
- * or the skb could be reassembled (skb_new will point to the new pack=
et and
- * skb was freed)
- */
-int batadv_frag_reassemble_skb(struct sk_buff *skb,
-			       struct batadv_priv *bat_priv,
-			       struct sk_buff **new_skb)
-{
-	struct batadv_orig_node *orig_node;
-	struct batadv_frag_packet_list_entry *tmp_frag_entry;
-	int ret =3D NET_RX_DROP;
-	struct batadv_unicast_frag_packet *unicast_packet;
-
-	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
-	*new_skb =3D NULL;
-
-	orig_node =3D batadv_orig_hash_find(bat_priv, unicast_packet->orig);
-	if (!orig_node)
-		goto out;
-
-	orig_node->last_frag_packet =3D jiffies;
-
-	if (list_empty(&orig_node->frag_list) &&
-	    batadv_frag_create_buffer(&orig_node->frag_list)) {
-		pr_debug("couldn't create frag buffer\n");
-		goto out;
-	}
-
-	tmp_frag_entry =3D batadv_frag_search_packet(&orig_node->frag_list,
-						   unicast_packet);
-
-	if (!tmp_frag_entry) {
-		batadv_frag_create_entry(&orig_node->frag_list, skb);
-		ret =3D NET_RX_SUCCESS;
-		goto out;
-	}
-
-	*new_skb =3D batadv_frag_merge_packet(&orig_node->frag_list,
-					    tmp_frag_entry, skb);
-	/* if not, merge failed */
-	if (*new_skb)
-		ret =3D NET_RX_SUCCESS;
-
-out:
-	if (orig_node)
-		batadv_orig_node_free_ref(orig_node);
-	return ret;
-}
-
-int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_=
priv,
-			 struct batadv_hard_iface *hard_iface,
-			 const uint8_t dstaddr[])
-{
-	struct batadv_unicast_packet tmp_uc, *unicast_packet;
-	struct batadv_hard_iface *primary_if;
-	struct sk_buff *frag_skb;
-	struct batadv_unicast_frag_packet *frag1, *frag2;
-	int uc_hdr_len =3D sizeof(*unicast_packet);
-	int ucf_hdr_len =3D sizeof(*frag1);
-	int data_len =3D skb->len - uc_hdr_len;
-	int large_tail =3D 0, ret =3D NET_RX_DROP;
-	uint16_t seqno;
-
-	primary_if =3D batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto dropped;
-
-	frag_skb =3D dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
-	if (!frag_skb)
-		goto dropped;
-
-	skb->priority =3D TC_PRIO_CONTROL;
-	skb_reserve(frag_skb, ucf_hdr_len);
-
-	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
-	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
-	skb_split(skb, frag_skb, data_len / 2 + uc_hdr_len);
-
-	if (batadv_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
-	    batadv_skb_head_push(frag_skb, ucf_hdr_len) < 0)
-		goto drop_frag;
-
-	frag1 =3D (struct batadv_unicast_frag_packet *)skb->data;
-	frag2 =3D (struct batadv_unicast_frag_packet *)frag_skb->data;
-
-	memcpy(frag1, &tmp_uc, sizeof(tmp_uc));
-
-	frag1->header.ttl--;
-	frag1->header.version =3D BATADV_COMPAT_VERSION;
-	frag1->header.packet_type =3D BATADV_UNICAST_FRAG;
-
-	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(frag2, frag1, sizeof(*frag2));
-
-	if (data_len & 1)
-		large_tail =3D BATADV_UNI_FRAG_LARGETAIL;
-
-	frag1->flags =3D BATADV_UNI_FRAG_HEAD | large_tail;
-	frag2->flags =3D large_tail;
-
-	seqno =3D atomic_add_return(2, &hard_iface->frag_seqno);
-	frag1->seqno =3D htons(seqno - 1);
-	frag2->seqno =3D htons(seqno);
-
-	batadv_send_skb_packet(skb, hard_iface, dstaddr);
-	batadv_send_skb_packet(frag_skb, hard_iface, dstaddr);
-	ret =3D NET_RX_SUCCESS;
-	goto out;
-
-drop_frag:
-	kfree_skb(frag_skb);
-dropped:
-	kfree_skb(skb);
-out:
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
-	return ret;
-}
-
-/**
- * batadv_unicast_push_and_fill_skb - extends the buffer and initializ=
es the
- * common fields for unicast packets
- * @skb: packet
- * @hdr_size: amount of bytes to push at the beginning of the skb
- * @orig_node: the destination node
- *
- * Returns false if the buffer extension was not possible or true othe=
rwise
- */
-static bool batadv_unicast_push_and_fill_skb(struct sk_buff *skb, int =
hdr_size,
-					     struct batadv_orig_node *orig_node)
-{
-	struct batadv_unicast_packet *unicast_packet;
-	uint8_t ttvn =3D (uint8_t)atomic_read(&orig_node->last_ttvn);
-
-	if (batadv_skb_head_push(skb, hdr_size) < 0)
-		return false;
-
-	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
-	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
-	/* batman packet type: unicast */
-	unicast_packet->header.packet_type =3D BATADV_UNICAST;
-	/* set unicast ttl */
-	unicast_packet->header.ttl =3D BATADV_TTL;
-	/* copy the destination for faster routing */
-	memcpy(unicast_packet->dest, orig_node->orig, ETH_ALEN);
-	/* set the destination tt version number */
-	unicast_packet->ttvn =3D ttvn;
-
-	return true;
-}
-
-/**
- * batadv_unicast_prepare_skb - encapsulate an skb with a unicast head=
er
- * @skb: the skb containing the payload to encapsulate
- * @orig_node: the destination node
- *
- * Returns false if the payload could not be encapsulated or true othe=
rwise.
- *
- * This call might reallocate skb data.
- */
-static bool batadv_unicast_prepare_skb(struct sk_buff *skb,
-				       struct batadv_orig_node *orig_node)
-{
-	size_t uni_size =3D sizeof(struct batadv_unicast_packet);
-	return batadv_unicast_push_and_fill_skb(skb, uni_size, orig_node);
-}
-
-/**
- * batadv_unicast_4addr_prepare_skb - encapsulate an skb with a unicas=
t4addr
- * header
- * @bat_priv: the bat priv with all the soft interface information
- * @skb: the skb containing the payload to encapsulate
- * @orig_node: the destination node
- * @packet_subtype: the batman 4addr packet subtype to use
- *
- * Returns false if the payload could not be encapsulated or true othe=
rwise.
- *
- * This call might reallocate skb data.
- */
-bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
-				      struct sk_buff *skb,
-				      struct batadv_orig_node *orig,
-				      int packet_subtype)
-{
-	struct batadv_hard_iface *primary_if;
-	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
-	bool ret =3D false;
-
-	primary_if =3D batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	/* pull the header space and fill the unicast_packet substructure.
-	 * We can do that because the first member of the unicast_4addr_packe=
t
-	 * is of type struct unicast_packet
-	 */
-	if (!batadv_unicast_push_and_fill_skb(skb,
-					      sizeof(*unicast_4addr_packet),
-					      orig))
-		goto out;
-
-	unicast_4addr_packet =3D (struct batadv_unicast_4addr_packet *)skb->d=
ata;
-	unicast_4addr_packet->u.header.packet_type =3D BATADV_UNICAST_4ADDR;
-	memcpy(unicast_4addr_packet->src, primary_if->net_dev->dev_addr,
-	       ETH_ALEN);
-	unicast_4addr_packet->subtype =3D packet_subtype;
-	unicast_4addr_packet->reserved =3D 0;
-
-	ret =3D true;
-out:
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
-	return ret;
-}
-
-/**
- * batadv_unicast_generic_send_skb - send an skb as unicast
- * @bat_priv: the bat priv with all the soft interface information
- * @skb: payload to send
- * @packet_type: the batman unicast packet type to use
- * @packet_subtype: the batman packet subtype. It is ignored if packet=
_type is
- *		    not BATADV_UNICAT_4ADDR
- *
- * Returns 1 in case of error or 0 otherwise
- */
-int batadv_unicast_generic_send_skb(struct batadv_priv *bat_priv,
-				    struct sk_buff *skb, int packet_type,
-				    int packet_subtype)
-{
-	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
-	struct batadv_unicast_packet *unicast_packet;
-	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *neigh_node;
-	int data_len =3D skb->len;
-	int ret =3D NET_RX_DROP;
-	unsigned int dev_mtu, header_len;
-
-	/* get routing information */
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		orig_node =3D batadv_gw_get_selected_orig(bat_priv);
-		if (orig_node)
-			goto find_router;
-	}
-
-	/* check for tt host - increases orig_node refcount.
-	 * returns NULL in case of AP isolation
-	 */
-	orig_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source,
-					     ethhdr->h_dest);
-
-find_router:
-	/* find_router():
-	 *  - if orig_node is NULL it returns NULL
-	 *  - increases neigh_nodes refcount if found.
-	 */
-	neigh_node =3D batadv_find_router(bat_priv, orig_node, NULL);
-
-	if (!neigh_node)
-		goto out;
-
-	switch (packet_type) {
-	case BATADV_UNICAST:
-		if (!batadv_unicast_prepare_skb(skb, orig_node))
-			goto out;
-
-		header_len =3D sizeof(struct batadv_unicast_packet);
-		break;
-	case BATADV_UNICAST_4ADDR:
-		if (!batadv_unicast_4addr_prepare_skb(bat_priv, skb, orig_node,
-						      packet_subtype))
-			goto out;
-
-		header_len =3D sizeof(struct batadv_unicast_4addr_packet);
-		break;
-	default:
-		/* this function supports UNICAST and UNICAST_4ADDR only. It
-		 * should never be invoked with any other packet type
-		 */
-		goto out;
-	}
-
-	ethhdr =3D (struct ethhdr *)(skb->data + header_len);
-	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
-
-	/* inform the destination node that we are still missing a correct ro=
ute
-	 * for this client. The destination will receive this packet and will
-	 * try to reroute it because the ttvn contained in the header is less
-	 * than the current one
-	 */
-	if (batadv_tt_global_client_is_roaming(bat_priv, ethhdr->h_dest))
-		unicast_packet->ttvn =3D unicast_packet->ttvn - 1;
-
-	dev_mtu =3D neigh_node->if_incoming->net_dev->mtu;
-	/* fragmentation mechanism only works for UNICAST (now) */
-	if (packet_type =3D=3D BATADV_UNICAST &&
-	    atomic_read(&bat_priv->fragmentation) &&
-	    data_len + sizeof(*unicast_packet) > dev_mtu) {
-		/* send frag skb decreases ttl */
-		unicast_packet->header.ttl++;
-		ret =3D batadv_frag_send_skb(skb, bat_priv,
-					   neigh_node->if_incoming,
-					   neigh_node->addr);
-		goto out;
-	}
-
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
-		ret =3D 0;
-
-out:
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
-	if (orig_node)
-		batadv_orig_node_free_ref(orig_node);
-	if (ret =3D=3D NET_RX_DROP)
-		kfree_skb(skb);
-	return ret;
-}
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
deleted file mode 100644
index 429cf8a..0000000
--- a/net/batman-adv/unicast.h
+++ /dev/null
@@ -1,92 +0,0 @@
-/* Copyright (C) 2010-2013 B.A.T.M.A.N. contributors:
- *
- * Andreas Langer
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#ifndef _NET_BATMAN_ADV_UNICAST_H_
-#define _NET_BATMAN_ADV_UNICAST_H_
-
-#include "packet.h"
-
-#define BATADV_FRAG_TIMEOUT 10000 /* purge frag list entries after tim=
e in ms */
-#define BATADV_FRAG_BUFFER_SIZE 6 /* number of list elements in buffer=
 */
-
-int batadv_frag_reassemble_skb(struct sk_buff *skb,
-			       struct batadv_priv *bat_priv,
-			       struct sk_buff **new_skb);
-void batadv_frag_list_free(struct list_head *head);
-int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_=
priv,
-			 struct batadv_hard_iface *hard_iface,
-			 const uint8_t dstaddr[]);
-bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
-				      struct sk_buff *skb,
-				      struct batadv_orig_node *orig_node,
-				      int packet_subtype);
-int batadv_unicast_generic_send_skb(struct batadv_priv *bat_priv,
-				    struct sk_buff *skb, int packet_type,
-				    int packet_subtype);
-
-
-/**
- * batadv_unicast_send_skb - send the skb encapsulated in a unicast pa=
cket
- * @bat_priv: the bat priv with all the soft interface information
- * @skb: the payload to send
- */
-static inline int batadv_unicast_send_skb(struct batadv_priv *bat_priv=
,
-					  struct sk_buff *skb)
-{
-	return batadv_unicast_generic_send_skb(bat_priv, skb, BATADV_UNICAST,
-					       0);
-}
-
-/**
- * batadv_unicast_send_skb - send the skb encapsulated in a unicast4ad=
dr packet
- * @bat_priv: the bat priv with all the soft interface information
- * @skb: the payload to send
- * @packet_subtype: the batman 4addr packet subtype to use
- */
-static inline int batadv_unicast_4addr_send_skb(struct batadv_priv *ba=
t_priv,
-						struct sk_buff *skb,
-						int packet_subtype)
-{
-	return batadv_unicast_generic_send_skb(bat_priv, skb,
-					       BATADV_UNICAST_4ADDR,
-					       packet_subtype);
-}
-
-static inline int batadv_frag_can_reassemble(const struct sk_buff *skb=
, int mtu)
-{
-	const struct batadv_unicast_frag_packet *unicast_packet;
-	int uneven_correction =3D 0;
-	unsigned int merged_size;
-
-	unicast_packet =3D (struct batadv_unicast_frag_packet *)skb->data;
-
-	if (unicast_packet->flags & BATADV_UNI_FRAG_LARGETAIL) {
-		if (unicast_packet->flags & BATADV_UNI_FRAG_HEAD)
-			uneven_correction =3D 1;
-		else
-			uneven_correction =3D -1;
-	}
-
-	merged_size =3D (skb->len - sizeof(*unicast_packet)) * 2;
-	merged_size +=3D sizeof(struct batadv_unicast_packet) + uneven_correc=
tion;
-
-	return merged_size <=3D mtu;
-}
-
-#endif /* _NET_BATMAN_ADV_UNICAST_H_ */
--=20
1.8.3.2
