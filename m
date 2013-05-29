From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/21] batman-adv: use eth_hdr() when it makes sense
Date: Wed, 29 May 2013 10:10:40 +0200
Message-ID: <1369815051-708-11-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39956 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965056Ab3E2INA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:00 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of casting the result of skb_mac_header() to
"struct ethhdr *" every time, the eth_hdr inline function
can be use to beautify the code and improve its readability.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c            |  2 +-
 net/batman-adv/bridge_loop_avoidance.c |  8 ++++----
 net/batman-adv/network-coding.c        | 10 +++++-----
 net/batman-adv/routing.c               | 12 ++++++------
 net/batman-adv/send.c                  |  2 +-
 net/batman-adv/soft-interface.c        |  2 +-
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index bd50e0d..ef41be4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1268,7 +1268,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 			   skb->len + ETH_HLEN);
 
 	packet_len = skb_headlen(skb);
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 	packet_buff = skb->data;
 	batadv_ogm_packet = (struct batadv_ogm_packet *)packet_buff;
 
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 379061c..082189e 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -864,7 +864,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	short vid = -1;
 	int ret;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
 		vhdr = (struct vlan_ethhdr *)ethhdr;
@@ -885,7 +885,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 		return 0;
 
 	/* pskb_may_pull() may have modified the pointers, get ethhdr again */
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 	arphdr = (struct arphdr *)((uint8_t *)ethhdr + headlen);
 
 	/* Check whether the ARP frame carries a valid
@@ -1432,7 +1432,7 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
 	struct batadv_hard_iface *primary_if;
 	int ret;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -1539,7 +1539,7 @@ int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid)
 	if (batadv_bla_process_claim(bat_priv, primary_if, skb))
 		goto handled;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index e84629e..0787a34 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1245,7 +1245,7 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 		return;
 
 	/* Set the mac header as if we actually sent the packet uncoded */
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 	memcpy(ethhdr->h_source, ethhdr->h_dest, ETH_ALEN);
 	memcpy(ethhdr->h_dest, eth_dst_new, ETH_ALEN);
 
@@ -1423,7 +1423,7 @@ void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
 {
 	struct batadv_unicast_packet *packet;
 	struct batadv_nc_path *nc_path;
-	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	struct ethhdr *ethhdr = eth_hdr(skb);
 	__be32 packet_id;
 	u8 *payload;
 
@@ -1482,7 +1482,7 @@ out:
 void batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
 					 struct sk_buff *skb)
 {
-	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	struct ethhdr *ethhdr = eth_hdr(skb);
 
 	if (batadv_is_my_mac(bat_priv, ethhdr->h_dest))
 		return;
@@ -1533,7 +1533,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	skb_reset_network_header(skb);
 
 	/* Reconstruct original mac header */
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 	memcpy(ethhdr, &ethhdr_tmp, sizeof(*ethhdr));
 
 	/* Select the correct unicast header information based on the location
@@ -1677,7 +1677,7 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 		return NET_RX_DROP;
 
 	coded_packet = (struct batadv_coded_packet *)skb->data;
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* Verify frame is destined for us */
 	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest) &&
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b27a4d7..beeab2e 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -256,7 +256,7 @@ bool batadv_check_management_packet(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, header_len)))
 		return false;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* packet with broadcast indication but unicast recipient */
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
@@ -392,7 +392,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
 		goto out;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* packet with unicast indication but broadcast recipient */
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
@@ -569,7 +569,7 @@ static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
 		return -ENODATA;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* packet with unicast indication but broadcast recipient */
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
@@ -803,7 +803,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 	struct batadv_orig_node *orig_node = NULL;
 	struct batadv_neigh_node *neigh_node = NULL;
 	struct batadv_unicast_packet *unicast_packet;
-	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	struct ethhdr *ethhdr = eth_hdr(skb);
 	int ret = NET_RX_DROP;
 	struct sk_buff *new_skb;
 
@@ -1165,7 +1165,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
 		goto out;
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* packet with broadcast indication but unicast recipient */
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
@@ -1265,7 +1265,7 @@ int batadv_recv_vis_packet(struct sk_buff *skb,
 		return NET_RX_DROP;
 
 	vis_packet = (struct batadv_vis_packet *)skb->data;
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	/* not for me */
 	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest))
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index eb16b04..ed7072a 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -61,7 +61,7 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 
 	skb_reset_mac_header(skb);
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
 	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 819dfb0..b26a6cd 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -316,7 +316,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	skb_pull_rcsum(skb, hdr_size);
 	skb_reset_mac_header(skb);
 
-	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	ethhdr = eth_hdr(skb);
 
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_8021Q:
-- 
1.8.1.5
