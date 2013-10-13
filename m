From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/16] batman-adv: use htons when possible
Date: Sun, 13 Oct 2013 13:22:55 +0200
Message-ID: <1381663381-626-11-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:15034 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380Ab3JMLwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:52:53 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

When comparing a network ordered value with a constant, it
is better to convert the constant at compile time by means
of htons() instead of converting the value at runtime using
ntohs().

This refactoring may slightly improve the code performance.

Moreover substitute __constant_htons() with htons() since
the latter increase readability and it is smart enough to be
as efficient as the former

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 12 ++++++------
 net/batman-adv/gateway_client.c        |  4 ++--
 net/batman-adv/hard-interface.c        |  2 +-
 net/batman-adv/send.c                  |  4 ++--
 net/batman-adv/soft-interface.c        |  4 ++--
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 70da18a..5bb58d7 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -863,25 +863,25 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	struct arphdr *arphdr;
 	uint8_t *hw_src, *hw_dst;
 	struct batadv_bla_claim_dst *bla_dst;
-	uint16_t proto;
+	__be16 proto;
 	int headlen;
 	unsigned short vid = BATADV_NO_FLAGS;
 	int ret;
 
 	ethhdr = eth_hdr(skb);
 
-	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
+	if (ethhdr->h_proto == htons(ETH_P_8021Q)) {
 		vhdr = (struct vlan_ethhdr *)ethhdr;
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
 		vid |= BATADV_VLAN_HAS_TAG;
-		proto = ntohs(vhdr->h_vlan_encapsulated_proto);
+		proto = vhdr->h_vlan_encapsulated_proto;
 		headlen = sizeof(*vhdr);
 	} else {
-		proto = ntohs(ethhdr->h_proto);
+		proto = ethhdr->h_proto;
 		headlen = ETH_HLEN;
 	}
 
-	if (proto != ETH_P_ARP)
+	if (proto != htons(ETH_P_ARP))
 		return 0; /* not a claim frame */
 
 	/* this must be a ARP frame. check if it is a claim. */
@@ -1379,7 +1379,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 
 	ethhdr = (struct ethhdr *)(((uint8_t *)skb->data) + hdr_size);
 
-	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
+	if (ethhdr->h_proto == htons(ETH_P_8021Q)) {
 		if (!pskb_may_pull(skb, hdr_size + VLAN_ETH_HLEN))
 			return 0;
 
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index ac97ca7..053bb31 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -716,11 +716,11 @@ bool batadv_gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 
 	/* check for bootp port */
 	if ((proto == htons(ETH_P_IP)) &&
-	    (ntohs(udphdr->dest) != 67))
+	    (udphdr->dest != htons(67)))
 		return false;
 
 	if ((proto == htons(ETH_P_IPV6)) &&
-	    (ntohs(udphdr->dest) != 547))
+	    (udphdr->dest != htons(547)))
 		return false;
 
 	return true;
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 0c8602e..004017c 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -379,7 +379,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 {
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface, *master;
-	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
+	__be16 ethertype = htons(ETH_P_BATMAN);
 	int ret;
 
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 1a1aa59..4bbcf51 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -63,10 +63,10 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	ethhdr = eth_hdr(skb);
 	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
-	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
+	ethhdr->h_proto = htons(ETH_P_BATMAN);
 
 	skb_set_network_header(skb, ETH_HLEN);
-	skb->protocol = __constant_htons(ETH_P_BATMAN);
+	skb->protocol = htons(ETH_P_BATMAN);
 
 	skb->dev = hard_iface->net_dev;
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 18b1fd9..87e7e4e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -145,7 +145,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
-	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
+	__be16 ethertype = htons(ETH_P_BATMAN);
 	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
 						   0x00, 0x00};
 	static const uint8_t ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
@@ -312,7 +312,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	struct vlan_ethhdr *vhdr;
 	struct batadv_header *batadv_header = (struct batadv_header *)skb->data;
 	unsigned short vid __maybe_unused = BATADV_NO_FLAGS;
-	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
+	__be16 ethertype = htons(ETH_P_BATMAN);
 	bool is_bcast;
 
 	is_bcast = (batadv_header->packet_type == BATADV_BCAST);
-- 
1.8.3.2
