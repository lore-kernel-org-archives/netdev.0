From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/16] batman-adv: Fragment and send skbs larger than mtu
Date: Sun, 13 Oct 2013 13:22:54 +0200
Message-ID: <1381663381-626-10-git-send-email-antonio@meshcoding.com>
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
Received: from s3.neomailbox.net ([178.209.62.157]:31629 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab3JMLYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:32 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Non-broadcast packets larger than MTU are fragmented and sent with
an encapsulating header. Up to 16 fragments are supported, which are
sent in reverse order on the wire to allow minimal memory copying when
creating fragments.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c  | 121 ++++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/fragmentation.h  |   3 +
 net/batman-adv/send.c           |  21 +++++--
 net/batman-adv/soft-interface.c |   7 +++
 net/batman-adv/types.h          |   6 ++
 5 files changed, 154 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index c829d3c..271d321 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -368,3 +368,124 @@ out:
 		batadv_neigh_node_free_ref(neigh_node);
 	return ret;
 }
+
+/**
+ * batadv_frag_create - create a fragment from skb
+ * @skb: skb to create fragment from
+ * @frag_head: header to use in new fragment
+ * @mtu: size of new fragment
+ *
+ * Split the passed skb into two fragments: A new one with size matchi=
ng the
+ * passed mtu and the old one with the rest. The new skb contains data=
 from the
+ * tail of the old skb.
+ *
+ * Returns the new fragment, NULL on error.
+ */
+static struct sk_buff *batadv_frag_create(struct sk_buff *skb,
+					  struct batadv_frag_packet *frag_head,
+					  unsigned int mtu)
+{
+	struct sk_buff *skb_fragment;
+	unsigned header_size =3D sizeof(*frag_head);
+	unsigned fragment_size =3D mtu - header_size;
+
+	skb_fragment =3D netdev_alloc_skb(NULL, mtu + ETH_HLEN);
+	if (!skb_fragment)
+		goto err;
+
+	skb->priority =3D TC_PRIO_CONTROL;
+
+	/* Eat the last mtu-bytes of the skb */
+	skb_reserve(skb_fragment, header_size + ETH_HLEN);
+	skb_split(skb, skb_fragment, skb->len - fragment_size);
+
+	/* Add the header */
+	skb_push(skb_fragment, header_size);
+	memcpy(skb_fragment->data, frag_head, header_size);
+
+err:
+	return skb_fragment;
+}
+
+/**
+ * batadv_frag_send_packet - create up to 16 fragments from the passed=
 skb
+ * @skb: skb to create fragments from
+ * @orig_node: final destination of the created fragments
+ * @neigh_node: next-hop of the created fragments
+ *
+ * Returns true on success, false otherwise.
+ */
+bool batadv_frag_send_packet(struct sk_buff *skb,
+			     struct batadv_orig_node *orig_node,
+			     struct batadv_neigh_node *neigh_node)
+{
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if;
+	struct batadv_frag_packet frag_header;
+	struct sk_buff *skb_fragment;
+	unsigned mtu =3D neigh_node->if_incoming->net_dev->mtu;
+	unsigned header_size =3D sizeof(frag_header);
+	unsigned max_fragment_size, max_packet_size;
+
+	/* To avoid merge and refragmentation at next-hops we never send
+	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
+	 */
+	mtu =3D min_t(unsigned, mtu, BATADV_FRAG_MAX_FRAG_SIZE);
+	max_fragment_size =3D (mtu - header_size - ETH_HLEN);
+	max_packet_size =3D max_fragment_size * BATADV_FRAG_MAX_FRAGMENTS;
+
+	/* Don't even try to fragment, if we need more than 16 fragments */
+	if (skb->len > max_packet_size)
+		goto out_err;
+
+	bat_priv =3D orig_node->bat_priv;
+	primary_if =3D batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out_err;
+
+	/* Create one header to be copied to all fragments */
+	frag_header.header.packet_type =3D BATADV_UNICAST_FRAG;
+	frag_header.header.version =3D BATADV_COMPAT_VERSION;
+	frag_header.header.ttl =3D BATADV_TTL;
+	frag_header.seqno =3D htons(atomic_inc_return(&bat_priv->frag_seqno))=
;
+	frag_header.reserved =3D 0;
+	frag_header.no =3D 0;
+	frag_header.total_size =3D htons(skb->len);
+	memcpy(frag_header.orig, primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(frag_header.dest, orig_node->orig, ETH_ALEN);
+
+	/* Eat and send fragments from the tail of skb */
+	while (skb->len > max_fragment_size) {
+		skb_fragment =3D batadv_frag_create(skb, &frag_header, mtu);
+		if (!skb_fragment)
+			goto out_err;
+
+		batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
+		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
+				   skb_fragment->len + ETH_HLEN);
+		batadv_send_skb_packet(skb_fragment, neigh_node->if_incoming,
+				       neigh_node->addr);
+		frag_header.no++;
+
+		/* The initial check in this function should cover this case */
+		if (frag_header.no =3D=3D BATADV_FRAG_MAX_FRAGMENTS - 1)
+			goto out_err;
+	}
+
+	/* Make room for the fragment header. */
+	if (batadv_skb_head_push(skb, header_size) < 0 ||
+	    pskb_expand_head(skb, header_size + ETH_HLEN, 0, GFP_ATOMIC) < 0)
+		goto out_err;
+
+	memcpy(skb->data, &frag_header, header_size);
+
+	/* Send the last fragment */
+	batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
+	batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
+			   skb->len + ETH_HLEN);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
+
+	return true;
+out_err:
+	return false;
+}
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentat=
ion.h
index 883a6f4..ca029e2 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -27,6 +27,9 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 			 struct batadv_orig_node *orig_node_src);
 bool batadv_frag_skb_buffer(struct sk_buff **skb,
 			    struct batadv_orig_node *orig_node);
+bool batadv_frag_send_packet(struct sk_buff *skb,
+			     struct batadv_orig_node *orig_node,
+			     struct batadv_neigh_node *neigh_node);
=20
 /**
  * batadv_frag_check_entry - check if a list of fragments has timed ou=
t
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b8356ec..1a1aa59 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -28,8 +28,7 @@
 #include "gateway_client.h"
 #include "originator.h"
 #include "network-coding.h"
-
-#include <linux/if_ether.h>
+#include "fragmentation.h"
=20
 static void batadv_send_outstanding_bcast_packet(struct work_struct *w=
ork);
=20
@@ -109,7 +108,19 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	/* batadv_find_router() increases neigh_nodes refcount if found. */
 	neigh_node =3D batadv_find_router(bat_priv, orig_node, recv_if);
 	if (!neigh_node)
-		return ret;
+		goto out;
+
+	/* Check if the skb is too large to send in one piece and fragment
+	 * it if needed.
+	 */
+	if (atomic_read(&bat_priv->fragmentation) &&
+	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
+		/* Fragment and send packet. */
+		if (batadv_frag_send_packet(skb, orig_node, neigh_node))
+			ret =3D NET_XMIT_SUCCESS;
+
+		goto out;
+	}
=20
 	/* try to network code the packet, if it is received on an interface
 	 * (i.e. being forwarded). If the packet originates from this node or=
 if
@@ -123,7 +134,9 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 		ret =3D NET_XMIT_SUCCESS;
 	}
=20
-	batadv_neigh_node_free_ref(neigh_node);
+out:
+	if (neigh_node)
+		batadv_neigh_node_free_ref(neigh_node);
=20
 	return ret;
 }
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index dd189e6..18b1fd9 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -442,6 +442,7 @@ static void batadv_softif_destroy_finish(struct wor=
k_struct *work)
 static int batadv_softif_init_late(struct net_device *dev)
 {
 	struct batadv_priv *bat_priv;
+	uint32_t random_seqno;
 	int ret;
 	size_t cnt_len =3D sizeof(uint64_t) * BATADV_CNT_NUM;
=20
@@ -491,6 +492,10 @@ static int batadv_softif_init_late(struct net_devi=
ce *dev)
 	bat_priv->tt.last_changeset =3D NULL;
 	bat_priv->tt.last_changeset_len =3D 0;
=20
+	/* randomize initial seqno to avoid collision */
+	get_random_bytes(&random_seqno, sizeof(random_seqno));
+	atomic_set(&bat_priv->frag_seqno, random_seqno);
+
 	bat_priv->primary_if =3D NULL;
 	bat_priv->num_ifaces =3D 0;
=20
@@ -758,6 +763,8 @@ static const struct {
 	{ "mgmt_tx_bytes" },
 	{ "mgmt_rx" },
 	{ "mgmt_rx_bytes" },
+	{ "frag_tx" },
+	{ "frag_tx_bytes" },
 	{ "frag_rx" },
 	{ "frag_rx_bytes" },
 	{ "frag_fwd" },
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 5a2cc7a..d517d5d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -300,6 +300,8 @@ struct batadv_bcast_duplist_entry {
  * @BATADV_CNT_MGMT_TX_BYTES: transmitted routing protocol traffic byt=
es counter
  * @BATADV_CNT_MGMT_RX: received routing protocol traffic packet count=
er
  * @BATADV_CNT_MGMT_RX_BYTES: received routing protocol traffic bytes =
counter
+ * @BATADV_CNT_FRAG_TX: transmitted fragment traffic packet counter
+ * @BATADV_CNT_FRAG_TX_BYTES: transmitted fragment traffic bytes count=
er
  * @BATADV_CNT_FRAG_RX: received fragment traffic packet counter
  * @BATADV_CNT_FRAG_RX_BYTES: received fragment traffic bytes counter
  * @BATADV_CNT_FRAG_FWD: forwarded fragment traffic packet counter
@@ -341,6 +343,8 @@ enum batadv_counters {
 	BATADV_CNT_MGMT_TX_BYTES,
 	BATADV_CNT_MGMT_RX,
 	BATADV_CNT_MGMT_RX_BYTES,
+	BATADV_CNT_FRAG_TX,
+	BATADV_CNT_FRAG_TX_BYTES,
 	BATADV_CNT_FRAG_RX,
 	BATADV_CNT_FRAG_RX_BYTES,
 	BATADV_CNT_FRAG_FWD,
@@ -542,6 +546,7 @@ struct batadv_priv_nc {
  * @aggregated_ogms: bool indicating whether OGM aggregation is enable=
d
  * @bonding: bool indicating whether traffic bonding is enabled
  * @fragmentation: bool indicating whether traffic fragmentation is en=
abled
+ * @frag_seqno: incremental counter to identify chains of egress fragm=
ents
  * @ap_isolation: bool indicating whether ap isolation is enabled
  * @bridge_loop_avoidance: bool indicating whether bridge loop avoidan=
ce is
  *  enabled
@@ -585,6 +590,7 @@ struct batadv_priv {
 	atomic_t aggregated_ogms;
 	atomic_t bonding;
 	atomic_t fragmentation;
+	atomic_t frag_seqno;
 	atomic_t ap_isolation;
 #ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_t bridge_loop_avoidance;
--=20
1.8.3.2
