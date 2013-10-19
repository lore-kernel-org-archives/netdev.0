From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/18] batman-adv: refine API calls for unicast transmissions of SKBs
Date: Sun, 20 Oct 2013 00:22:05 +0200
Message-ID: <1382221330-3769-14-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22362 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab3JSWlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:41:35 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

With this patch the functions batadv_send_skb_unicast() and
batadv_send_skb_unicast_4addr() are further refined into
batadv_send_skb_via_tt(), batadv_send_skb_via_tt_4addr() and
batadv_send_skb_via_gw(). This way we avoid any "guessing" about where =
to send
a packet in the unicast forwarding methods and let the callers decide.

This is going to be useful for the upcoming multicast related patches i=
n
particular.

=46urther, the return values were polished a little to use the more
appropriate NET_XMIT_* defines.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/distributed-arp-table.c | 10 ++--
 net/batman-adv/send.c                  | 87 ++++++++++++++++++++++++++=
--------
 net/batman-adv/send.h                  | 51 ++++++++++++--------
 net/batman-adv/soft-interface.c        |  8 +++-
 4 files changed, 108 insertions(+), 48 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index 47dbe9a..6c8c393 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1037,13 +1037,13 @@ bool batadv_dat_snoop_incoming_arp_request(stru=
ct batadv_priv *bat_priv,
 	 * that a node not using the 4addr packet format doesn't support it.
 	 */
 	if (hdr_size =3D=3D sizeof(struct batadv_unicast_4addr_packet))
-		err =3D batadv_send_skb_unicast_4addr(bat_priv, skb_new,
-						    BATADV_P_DAT_CACHE_REPLY,
-						    vid);
+		err =3D batadv_send_skb_via_tt_4addr(bat_priv, skb_new,
+						   BATADV_P_DAT_CACHE_REPLY,
+						   vid);
 	else
-		err =3D batadv_send_skb_unicast(bat_priv, skb_new, vid);
+		err =3D batadv_send_skb_via_tt(bat_priv, skb_new, vid);
=20
-	if (!err) {
+	if (err !=3D NET_XMIT_DROP) {
 		batadv_inc_counter(bat_priv, BATADV_CNT_DAT_CACHED_REPLY_TX);
 		ret =3D true;
 	}
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index acaa7ff..c83be5e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -234,35 +234,31 @@ out:
 }
=20
 /**
- * batadv_send_generic_unicast_skb - send an skb as unicast
+ * batadv_send_skb_unicast - encapsulate and send an skb via unicast
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: payload to send
  * @packet_type: the batman unicast packet type to use
  * @packet_subtype: the unicast 4addr packet subtype (only relevant fo=
r unicast
  *  4addr packets)
+ * @orig_node: the originator to send the packet to
  * @vid: the vid to be used to search the translation table
  *
- * Returns 1 in case of error or 0 otherwise.
+ * Wrap the given skb into a batman-adv unicast or unicast-4addr heade=
r
+ * depending on whether BATADV_UNICAST or BATADV_UNICAST_4ADDR was sup=
plied
+ * as packet_type. Then send this frame to the given orig_node and rel=
ease a
+ * reference to this orig_node.
+ *
+ * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
  */
-int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
-				    struct sk_buff *skb, int packet_type,
-				    int packet_subtype,
-				    unsigned short vid)
+static int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
+				   struct sk_buff *skb, int packet_type,
+				   int packet_subtype,
+				   struct batadv_orig_node *orig_node,
+				   unsigned short vid)
 {
 	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
 	struct batadv_unicast_packet *unicast_packet;
-	struct batadv_orig_node *orig_node;
-	int ret =3D NET_RX_DROP;
-
-	/* get routing information */
-	if (is_multicast_ether_addr(ethhdr->h_dest))
-		orig_node =3D batadv_gw_get_selected_orig(bat_priv);
-	else
-		/* check for tt host - increases orig_node refcount.
-		 * returns NULL in case of AP isolation
-		 */
-		orig_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source,
-						     ethhdr->h_dest, vid);
+	int ret =3D NET_XMIT_DROP;
=20
 	if (!orig_node)
 		goto out;
@@ -296,16 +292,67 @@ int batadv_send_skb_generic_unicast(struct batadv=
_priv *bat_priv,
 		unicast_packet->ttvn =3D unicast_packet->ttvn - 1;
=20
 	if (batadv_send_skb_to_orig(skb, orig_node, NULL) !=3D NET_XMIT_DROP)
-		ret =3D 0;
+		ret =3D NET_XMIT_SUCCESS;
=20
 out:
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
-	if (ret =3D=3D NET_RX_DROP)
+	if (ret =3D=3D NET_XMIT_DROP)
 		kfree_skb(skb);
 	return ret;
 }
=20
+/**
+ * batadv_send_skb_via_tt_generic - send an skb via TT lookup
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: payload to send
+ * @packet_type: the batman unicast packet type to use
+ * @packet_subtype: the unicast 4addr packet subtype (only relevant fo=
r unicast
+ *  4addr packets)
+ * @vid: the vid to be used to search the translation table
+ *
+ * Look up the recipient node for the destination address in the ether=
net
+ * header via the translation table. Wrap the given skb into a batman-=
adv
+ * unicast or unicast-4addr header depending on whether BATADV_UNICAST=
 or
+ * BATADV_UNICAST_4ADDR was supplied as packet_type. Then send this fr=
ame
+ * to the according destination node.
+ *
+ * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
+ */
+int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
+				   struct sk_buff *skb, int packet_type,
+				   int packet_subtype, unsigned short vid)
+{
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb->data;
+	struct batadv_orig_node *orig_node;
+
+	orig_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source,
+					     ethhdr->h_dest, vid);
+	return batadv_send_skb_unicast(bat_priv, skb, packet_type,
+				       packet_subtype, orig_node, vid);
+}
+
+/**
+ * batadv_send_skb_via_gw - send an skb via gateway lookup
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: payload to send
+ * @vid: the vid to be used to search the translation table
+ *
+ * Look up the currently selected gateway. Wrap the given skb into a b=
atman-adv
+ * unicast header and send this frame to this gateway node.
+ *
+ * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
+ */
+int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buf=
f *skb,
+			   unsigned short vid)
+{
+	struct batadv_orig_node *orig_node;
+
+	orig_node =3D batadv_gw_get_selected_orig(bat_priv);
+	return batadv_send_skb_unicast(bat_priv, skb, BATADV_UNICAST, 0,
+				       orig_node, vid);
+}
+
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index c030cb7..aa2e253 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -38,45 +38,54 @@ bool batadv_send_skb_prepare_unicast_4addr(struct b=
atadv_priv *bat_priv,
 					   struct sk_buff *skb,
 					   struct batadv_orig_node *orig_node,
 					   int packet_subtype);
-int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
-				    struct sk_buff *skb, int packet_type,
-				    int packet_subtype,
-				    unsigned short vid);
+int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
+				   struct sk_buff *skb, int packet_type,
+				   int packet_subtype, unsigned short vid);
+int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buf=
f *skb,
+			   unsigned short vid);
=20
 /**
- * batadv_send_unicast_skb - send the skb encapsulated in a unicast pa=
cket
+ * batadv_send_skb_via_tt - send an skb via TT lookup
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the payload to send
  * @vid: the vid to be used to search the translation table
  *
- * Returns 1 in case of error or 0 otherwise.
+ * Look up the recipient node for the destination address in the ether=
net
+ * header via the translation table. Wrap the given skb into a batman-=
adv
+ * unicast header. Then send this frame to the according destination n=
ode.
+ *
+ * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
  */
-static inline int batadv_send_skb_unicast(struct batadv_priv *bat_priv=
,
-					  struct sk_buff *skb,
-					  unsigned short vid)
+static inline int batadv_send_skb_via_tt(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb,
+					 unsigned short vid)
 {
-	return batadv_send_skb_generic_unicast(bat_priv, skb, BATADV_UNICAST,
-					       0, vid);
+	return batadv_send_skb_via_tt_generic(bat_priv, skb, BATADV_UNICAST, =
0,
+					      vid);
 }
=20
 /**
- * batadv_send_4addr_unicast_skb - send the skb encapsulated in a unic=
ast 4addr
- *  packet
+ * batadv_send_skb_via_tt_4addr - send an skb via TT lookup
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the payload to send
  * @packet_subtype: the unicast 4addr packet subtype to use
  * @vid: the vid to be used to search the translation table
  *
- * Returns 1 in case of error or 0 otherwise.
+ * Look up the recipient node for the destination address in the ether=
net
+ * header via the translation table. Wrap the given skb into a batman-=
adv
+ * unicast-4addr header. Then send this frame to the according destina=
tion
+ * node.
+ *
+ * Returns NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwis=
e.
  */
-static inline int batadv_send_skb_unicast_4addr(struct batadv_priv *ba=
t_priv,
-						struct sk_buff *skb,
-						int packet_subtype,
-						unsigned short vid)
+static inline int batadv_send_skb_via_tt_4addr(struct batadv_priv *bat=
_priv,
+					       struct sk_buff *skb,
+					       int packet_subtype,
+					       unsigned short vid)
 {
-	return batadv_send_skb_generic_unicast(bat_priv, skb,
-					       BATADV_UNICAST_4ADDR,
-					       packet_subtype, vid);
+	return batadv_send_skb_via_tt_generic(bat_priv, skb,
+					      BATADV_UNICAST_4ADDR,
+					      packet_subtype, vid);
 }
=20
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index baa74b9..e70f530 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -298,8 +298,12 @@ static int batadv_interface_tx(struct sk_buff *skb=
,
=20
 		batadv_dat_snoop_outgoing_arp_reply(bat_priv, skb);
=20
-		ret =3D batadv_send_skb_unicast(bat_priv, skb, vid);
-		if (ret !=3D 0)
+		if (is_multicast_ether_addr(ethhdr->h_dest))
+			ret =3D batadv_send_skb_via_gw(bat_priv, skb, vid);
+		else
+			ret =3D batadv_send_skb_via_tt(bat_priv, skb, vid);
+
+		if (ret =3D=3D NET_XMIT_DROP)
 			goto dropped_freed;
 	}
=20
--=20
1.8.4
