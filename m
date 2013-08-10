From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: fix potential kernel paging errors for unicast transmissions
Date: Sat, 10 Aug 2013 23:08:01 +0200
Message-ID: <1376168881-4079-2-git-send-email-ordex@autistici.org>
References: <1376168881-4079-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:44242 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758758Ab3HJVfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 17:35:17 -0400
In-Reply-To: <1376168881-4079-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

There are several functions which might reallocate skb data. Currently
some places keep reusing their old ethhdr pointer regardless of whether
they became invalid after such a reallocation or not. This potentially
leads to kernel paging errors.

This patch fixes these by refetching the ethdr pointer after the
potential reallocations.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |  2 ++
 net/batman-adv/gateway_client.c        | 13 ++++++++++++-
 net/batman-adv/gateway_client.h        |  3 +--
 net/batman-adv/soft-interface.c        |  9 ++++++++-
 net/batman-adv/unicast.c               | 13 ++++++++++---
 5 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index e14531f..264de88 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1529,6 +1529,8 @@ out:
  * in these cases, the skb is further handled by this function and
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
+ *
+ * This call might reallocate skb data.
  */
 int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		  unsigned short vid)
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index f105219..7614af3 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -508,6 +508,7 @@ out:
 	return 0;
 }
=20
+/* this call might reallocate skb data */
 static bool batadv_is_type_dhcprequest(struct sk_buff *skb, int header=
_len)
 {
 	int ret =3D false;
@@ -568,6 +569,7 @@ out:
 	return ret;
 }
=20
+/* this call might reallocate skb data */
 bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *heade=
r_len)
 {
 	struct ethhdr *ethhdr;
@@ -619,6 +621,12 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb,=
 unsigned int *header_len)
=20
 	if (!pskb_may_pull(skb, *header_len + sizeof(*udphdr)))
 		return false;
+
+	/* skb->data might have been reallocated by pskb_may_pull() */
+	ethhdr =3D (struct ethhdr *)skb->data;
+	if (ntohs(ethhdr->h_proto) =3D=3D ETH_P_8021Q)
+		ethhdr =3D (struct ethhdr *)(skb->data + VLAN_HLEN);
+
 	udphdr =3D (struct udphdr *)(skb->data + *header_len);
 	*header_len +=3D sizeof(*udphdr);
=20
@@ -634,12 +642,14 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb=
, unsigned int *header_len)
 	return true;
 }
=20
+/* this call might reallocate skb data */
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
-			    struct sk_buff *skb, struct ethhdr *ethhdr)
+			    struct sk_buff *skb)
 {
 	struct batadv_neigh_node *neigh_curr =3D NULL, *neigh_old =3D NULL;
 	struct batadv_orig_node *orig_dst_node =3D NULL;
 	struct batadv_gw_node *curr_gw =3D NULL;
+	struct ethhdr *ethhdr;
 	bool ret, out_of_range =3D false;
 	unsigned int header_len =3D 0;
 	uint8_t curr_tq_avg;
@@ -648,6 +658,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat=
_priv,
 	if (!ret)
 		goto out;
=20
+	ethhdr =3D (struct ethhdr *)skb->data;
 	orig_dst_node =3D batadv_transtable_search(bat_priv, ethhdr->h_source=
,
 						 ethhdr->h_dest);
 	if (!orig_dst_node)
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_c=
lient.h
index 039902d..1037d75 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -34,7 +34,6 @@ void batadv_gw_node_delete(struct batadv_priv *bat_pr=
iv,
 void batadv_gw_node_purge(struct batadv_priv *bat_priv);
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset=
);
 bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *heade=
r_len);
-bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
-			    struct sk_buff *skb, struct ethhdr *ethhdr);
+bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_bu=
ff *skb);
=20
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 700d0b4..0f04e1c 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -180,6 +180,9 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (batadv_bla_tx(bat_priv, skb, vid))
 		goto dropped;
=20
+	/* skb->data might have been reallocated by batadv_bla_tx() */
+	ethhdr =3D (struct ethhdr *)skb->data;
+
 	/* Register the client MAC in the transtable */
 	if (!is_multicast_ether_addr(ethhdr->h_source))
 		batadv_tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
@@ -220,6 +223,10 @@ static int batadv_interface_tx(struct sk_buff *skb=
,
 		default:
 			break;
 		}
+
+		/* reminder: ethhdr might have become unusable from here on
+		 * (batadv_gw_is_dhcp_target() might have reallocated skb data)
+		 */
 	}
=20
 	/* ethernet packet should be broadcasted */
@@ -266,7 +273,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	/* unicast packet */
 	} else {
 		if (atomic_read(&bat_priv->gw_mode) !=3D BATADV_GW_MODE_OFF) {
-			ret =3D batadv_gw_out_of_range(bat_priv, skb, ethhdr);
+			ret =3D batadv_gw_out_of_range(bat_priv, skb);
 			if (ret)
 				goto dropped;
 		}
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index dc8b5d4..688a041 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -326,7 +326,9 @@ static bool batadv_unicast_push_and_fill_skb(struct=
 sk_buff *skb, int hdr_size,
  * @skb: the skb containing the payload to encapsulate
  * @orig_node: the destination node
  *
- * Returns false if the payload could not be encapsulated or true othe=
rwise
+ * Returns false if the payload could not be encapsulated or true othe=
rwise.
+ *
+ * This call might reallocate skb data.
  */
 static bool batadv_unicast_prepare_skb(struct sk_buff *skb,
 				       struct batadv_orig_node *orig_node)
@@ -343,7 +345,9 @@ static bool batadv_unicast_prepare_skb(struct sk_bu=
ff *skb,
  * @orig_node: the destination node
  * @packet_subtype: the batman 4addr packet subtype to use
  *
- * Returns false if the payload could not be encapsulated or true othe=
rwise
+ * Returns false if the payload could not be encapsulated or true othe=
rwise.
+ *
+ * This call might reallocate skb data.
  */
 bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
 				      struct sk_buff *skb,
@@ -401,7 +405,7 @@ int batadv_unicast_generic_send_skb(struct batadv_p=
riv *bat_priv,
 	struct batadv_neigh_node *neigh_node;
 	int data_len =3D skb->len;
 	int ret =3D NET_RX_DROP;
-	unsigned int dev_mtu;
+	unsigned int dev_mtu, header_len;
=20
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
@@ -429,10 +433,12 @@ find_router:
 	switch (packet_type) {
 	case BATADV_UNICAST:
 		batadv_unicast_prepare_skb(skb, orig_node);
+		header_len =3D sizeof(struct batadv_unicast_packet);
 		break;
 	case BATADV_UNICAST_4ADDR:
 		batadv_unicast_4addr_prepare_skb(bat_priv, skb, orig_node,
 						 packet_subtype);
+		header_len =3D sizeof(struct batadv_unicast_4addr_packet);
 		break;
 	default:
 		/* this function supports UNICAST and UNICAST_4ADDR only. It
@@ -441,6 +447,7 @@ find_router:
 		goto out;
 	}
=20
+	ethhdr =3D (struct ethhdr *)(skb->data + header_len);
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	/* inform the destination node that we are still missing a correct ro=
ute
--=20
1.8.1.5
