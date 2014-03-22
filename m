From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/16] batman-adv: use vlan_/eth_hdr() instead of skb->data in interface_tx path
Date: Sat, 22 Mar 2014 09:56:02 +0100
Message-ID: <1395478576-10999-3-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32844 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaCVI4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:48 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

Our .ndo_start_xmit handler (batadv_interface_tx()) can rely on having
the skb mac header pointer set correctly since the following commit
present in kernels >=3D 3.9:

"net: reset mac header in dev_start_xmit()" (6d1ccff627)

Therefore we can safely use eth_hdr() and vlan_eth_hdr() instead of
skb->data now, which spares us some ugly type casts.

At the same time set the mac_header in batadv_dat_snoop_incoming_arp_re=
quest()
before sending the skb along the TX path.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bridge_loop_avoidance.c |  2 +-
 net/batman-adv/distributed-arp-table.c |  5 +++++
 net/batman-adv/gateway_client.c        |  6 +++---
 net/batman-adv/send.c                  | 11 +++++------
 net/batman-adv/soft-interface.c        |  8 ++++----
 5 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 05f0712..73d8372 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -882,7 +882,7 @@ static int batadv_bla_process_claim(struct batadv_p=
riv *bat_priv,
 	proto =3D ethhdr->h_proto;
 	headlen =3D ETH_HLEN;
 	if (vid & BATADV_VLAN_HAS_TAG) {
-		vhdr =3D (struct vlan_ethhdr *)ethhdr;
+		vhdr =3D vlan_eth_hdr(skb);
 		proto =3D vhdr->h_vlan_encapsulated_proto;
 		headlen +=3D VLAN_HLEN;
 	}
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index edee504..5bb37a8 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1027,6 +1027,11 @@ bool batadv_dat_snoop_incoming_arp_request(struc=
t batadv_priv *bat_priv,
 	if (!skb_new)
 		goto out;
=20
+	/* the rest of the TX path assumes that the mac_header offset pointin=
g
+	 * to the inner Ethernet header has been set, therefore reset it now.
+	 */
+	skb_reset_mac_header(skb_new);
+
 	if (vid & BATADV_VLAN_HAS_TAG)
 		skb_new =3D vlan_insert_tag(skb_new, htons(ETH_P_8021Q),
 					  vid & VLAN_VID_MASK);
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index d7fafc1..07c7f21 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -678,7 +678,7 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, u=
nsigned int *header_len,
 	if (!pskb_may_pull(skb, *header_len + ETH_HLEN))
 		return BATADV_DHCP_NO;
=20
-	ethhdr =3D (struct ethhdr *)skb->data;
+	ethhdr =3D eth_hdr(skb);
 	proto =3D ethhdr->h_proto;
 	*header_len +=3D ETH_HLEN;
=20
@@ -687,7 +687,7 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, u=
nsigned int *header_len,
 		if (!pskb_may_pull(skb, *header_len + VLAN_HLEN))
 			return BATADV_DHCP_NO;
=20
-		vhdr =3D (struct vlan_ethhdr *)skb->data;
+		vhdr =3D vlan_eth_hdr(skb);
 		proto =3D vhdr->h_vlan_encapsulated_proto;
 		*header_len +=3D VLAN_HLEN;
 	}
@@ -726,7 +726,7 @@ batadv_gw_dhcp_recipient_get(struct sk_buff *skb, u=
nsigned int *header_len,
 		return BATADV_DHCP_NO;
=20
 	/* skb->data might have been reallocated by pskb_may_pull() */
-	ethhdr =3D (struct ethhdr *)skb->data;
+	ethhdr =3D eth_hdr(skb);
 	if (ntohs(ethhdr->h_proto) =3D=3D ETH_P_8021Q)
 		ethhdr =3D (struct ethhdr *)(skb->data + VLAN_HLEN);
=20
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 843febd..1703a2e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -256,7 +256,7 @@ static int batadv_send_skb_unicast(struct batadv_pr=
iv *bat_priv,
 {
 	struct ethhdr *ethhdr;
 	struct batadv_unicast_packet *unicast_packet;
-	int ret =3D NET_XMIT_DROP, hdr_size;
+	int ret =3D NET_XMIT_DROP;
=20
 	if (!orig_node)
 		goto out;
@@ -265,16 +265,12 @@ static int batadv_send_skb_unicast(struct batadv_=
priv *bat_priv,
 	case BATADV_UNICAST:
 		if (!batadv_send_skb_prepare_unicast(skb, orig_node))
 			goto out;
-
-		hdr_size =3D sizeof(*unicast_packet);
 		break;
 	case BATADV_UNICAST_4ADDR:
 		if (!batadv_send_skb_prepare_unicast_4addr(bat_priv, skb,
 							   orig_node,
 							   packet_subtype))
 			goto out;
-
-		hdr_size =3D sizeof(struct batadv_unicast_4addr_packet);
 		break;
 	default:
 		/* this function supports UNICAST and UNICAST_4ADDR only. It
@@ -283,7 +279,10 @@ static int batadv_send_skb_unicast(struct batadv_p=
riv *bat_priv,
 		goto out;
 	}
=20
-	ethhdr =3D (struct ethhdr *)(skb->data + hdr_size);
+	/* skb->data might have been reallocated by
+	 * batadv_send_skb_prepare_unicast{,_4addr}()
+	 */
+	ethhdr =3D eth_hdr(skb);
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
=20
 	/* inform the destination node that we are still missing a correct ro=
ute
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index f82c267..c4392fc 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -176,11 +176,11 @@ static int batadv_interface_tx(struct sk_buff *sk=
b,
=20
 	soft_iface->trans_start =3D jiffies;
 	vid =3D batadv_get_vid(skb, 0);
-	ethhdr =3D (struct ethhdr *)skb->data;
+	ethhdr =3D eth_hdr(skb);
=20
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_8021Q:
-		vhdr =3D (struct vlan_ethhdr *)skb->data;
+		vhdr =3D vlan_eth_hdr(skb);
=20
 		if (vhdr->h_vlan_encapsulated_proto !=3D ethertype)
 			break;
@@ -194,7 +194,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		goto dropped;
=20
 	/* skb->data might have been reallocated by batadv_bla_tx() */
-	ethhdr =3D (struct ethhdr *)skb->data;
+	ethhdr =3D eth_hdr(skb);
=20
 	/* Register the client MAC in the transtable */
 	if (!is_multicast_ether_addr(ethhdr->h_source)) {
@@ -230,7 +230,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		/* skb->data may have been modified by
 		 * batadv_gw_dhcp_recipient_get()
 		 */
-		ethhdr =3D (struct ethhdr *)skb->data;
+		ethhdr =3D eth_hdr(skb);
 		/* if gw_mode is on, broadcast any non-DHCP message.
 		 * All the DHCP packets are going to be sent as unicast
 		 */
--=20
1.8.3.2
