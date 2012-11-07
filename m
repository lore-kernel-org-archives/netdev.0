From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/12] batman-adv: Add get_ethtool_stats() support for DAT
Date: Wed,  7 Nov 2012 20:11:41 +0100
Message-ID: <1352315502-20324-12-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44643 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab2KGTMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:38 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Added additional counters for D.A.T.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 19 +++++++++++++++++--
 net/batman-adv/distributed-arp-table.h | 27 ++++++++++++++++++++++++++=
+
 net/batman-adv/routing.c               |  8 +++++++-
 net/batman-adv/soft-interface.c        |  7 +++++++
 net/batman-adv/types.h                 |  7 +++++++
 5 files changed, 65 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index c1a74a1..8e1d89d 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -601,9 +601,22 @@ static bool batadv_dat_send_data(struct batadv_pri=
v *bat_priv,
 		send_status =3D batadv_send_skb_packet(tmp_skb,
 						     neigh_node->if_incoming,
 						     neigh_node->addr);
-		if (send_status =3D=3D NET_XMIT_SUCCESS)
+		if (send_status =3D=3D NET_XMIT_SUCCESS) {
+			/* count the sent packet */
+			switch (packet_subtype) {
+			case BATADV_P_DAT_DHT_GET:
+				batadv_inc_counter(bat_priv,
+						   BATADV_CNT_DAT_GET_TX);
+				break;
+			case BATADV_P_DAT_DHT_PUT:
+				batadv_inc_counter(bat_priv,
+						   BATADV_CNT_DAT_PUT_TX);
+				break;
+			}
+
 			/* packet sent to a candidate: return true */
 			ret =3D true;
+		}
 free_neigh:
 		batadv_neigh_node_free_ref(neigh_node);
 free_orig:
@@ -909,8 +922,10 @@ bool batadv_dat_snoop_incoming_arp_request(struct =
batadv_priv *bat_priv,
 	else
 		err =3D batadv_unicast_send_skb(bat_priv, skb_new);
=20
-	if (!err)
+	if (!err) {
+		batadv_inc_counter(bat_priv, BATADV_CNT_DAT_CACHED_REPLY_TX);
 		ret =3D true;
+	}
 out:
 	if (dat_entry)
 		batadv_dat_entry_free_ref(dat_entry);
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/di=
stributed-arp-table.h
index fdb3522..d060c03 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -74,6 +74,28 @@ int batadv_dat_init(struct batadv_priv *bat_priv);
 void batadv_dat_free(struct batadv_priv *bat_priv);
 int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset=
);
=20
+/**
+ * batadv_dat_inc_counter - increment the correct DAT packet counter
+ * @bat_priv: the bat priv with all the soft interface information
+ * @subtype: the 4addr subtype of the packet to be counted
+ *
+ * Updates the ethtool statistics for the received packet if it is a D=
AT subtype
+ */
+static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv=
,
+					  uint8_t subtype)
+{
+	switch (subtype) {
+	case BATADV_P_DAT_DHT_GET:
+		batadv_inc_counter(bat_priv,
+				   BATADV_CNT_DAT_GET_RX);
+		break;
+	case BATADV_P_DAT_DHT_PUT:
+		batadv_inc_counter(bat_priv,
+				   BATADV_CNT_DAT_PUT_RX);
+		break;
+	}
+}
+
 #else
=20
 static inline bool
@@ -135,6 +157,11 @@ static inline void batadv_dat_free(struct batadv_p=
riv *bat_priv)
 {
 }
=20
+static inline void batadv_dat_inc_counter(struct batadv_priv *bat_priv=
,
+					  uint8_t subtype)
+{
+}
+
 #endif /* CONFIG_BATMAN_ADV_DAT */
=20
 #endif /* _NET_BATMAN_ADV_ARP_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1826699..3f21c09 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -985,15 +985,17 @@ int batadv_recv_unicast_packet(struct sk_buff *sk=
b,
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_packet *unicast_packet;
+	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
 	int hdr_size =3D sizeof(*unicast_packet);
 	bool is4addr;
=20
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
+	unicast_4addr_packet =3D (struct batadv_unicast_4addr_packet *)skb->d=
ata;
=20
 	is4addr =3D unicast_packet->header.packet_type =3D=3D BATADV_UNICAST_=
4ADDR;
 	/* the caller function should have already pulled 2 bytes */
 	if (is4addr)
-		hdr_size =3D sizeof(struct batadv_unicast_4addr_packet);
+		hdr_size =3D sizeof(*unicast_4addr_packet);
=20
 	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
 		return NET_RX_DROP;
@@ -1003,6 +1005,10 @@ int batadv_recv_unicast_packet(struct sk_buff *s=
kb,
=20
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
+		if (is4addr)
+			batadv_dat_inc_counter(bat_priv,
+					       unicast_4addr_packet->subtype);
+
 		if (batadv_dat_snoop_incoming_arp_request(bat_priv, skb,
 							  hdr_size))
 			goto rx_success;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 7b4a3a3..c283d87 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -625,6 +625,13 @@ static const struct {
 	{ "tt_response_rx" },
 	{ "tt_roam_adv_tx" },
 	{ "tt_roam_adv_rx" },
+#ifdef CONFIG_BATMAN_ADV_DAT
+	{ "dat_get_tx" },
+	{ "dat_get_rx" },
+	{ "dat_put_tx" },
+	{ "dat_put_rx" },
+	{ "dat_cached_reply_tx" },
+#endif
 };
=20
 static void batadv_get_strings(struct net_device *dev, uint32_t string=
set,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 0afeb2b..8ce16c1 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -186,6 +186,13 @@ enum batadv_counters {
 	BATADV_CNT_TT_RESPONSE_RX,
 	BATADV_CNT_TT_ROAM_ADV_TX,
 	BATADV_CNT_TT_ROAM_ADV_RX,
+#ifdef CONFIG_BATMAN_ADV_DAT
+	BATADV_CNT_DAT_GET_TX,
+	BATADV_CNT_DAT_GET_RX,
+	BATADV_CNT_DAT_PUT_TX,
+	BATADV_CNT_DAT_PUT_RX,
+	BATADV_CNT_DAT_CACHED_REPLY_TX,
+#endif
 	BATADV_CNT_NUM,
 };
=20
--=20
1.8.0
