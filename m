From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 10/19] batman-adv: drop unicast packets from other backbone gw
Date: Thu,  6 Apr 2017 16:07:32 +0200
Message-ID: <20170406140741.30745-11-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Andreas Pape <APape@phoenixcontact.com>,
        Andreas Pape <apape@phoenixcontact.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32966 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935047AbdDFOHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:50 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Pape <APape@phoenixcontact.com>

Additional dropping of unicast packets received from another backbone gw if
the same backbone network before being forwarded to the same backbone again
is necessary. It was observed in a test setup that in rare cases these
frames lead to looping unicast traffic backbone->mesh->backbone.

Signed-off-by: Andreas Pape <apape@phoenixcontact.com>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7fd740b6e36d..c85dc3102519 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -941,15 +941,17 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
-	u8 *orig_addr;
-	struct batadv_orig_node *orig_node = NULL;
+	u8 *orig_addr, *orig_addr_gw;
+	struct batadv_orig_node *orig_node = NULL, *orig_node_gw = NULL;
 	int check, hdr_size = sizeof(*unicast_packet);
 	enum batadv_subtype subtype;
-	bool is4addr;
+	struct ethhdr *ethhdr;
 	int ret = NET_RX_DROP;
+	bool is4addr, is_gw;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
+	ethhdr = eth_hdr(skb);
 
 	is4addr = unicast_packet->packet_type == BATADV_UNICAST_4ADDR;
 	/* the caller function should have already pulled 2 bytes */
@@ -972,6 +974,23 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 
 	/* packet for me */
 	if (batadv_is_my_mac(bat_priv, unicast_packet->dest)) {
+		/* If this is a unicast packet from another backgone gw,
+		 * drop it.
+		 */
+		orig_addr_gw = ethhdr->h_source;
+		orig_node_gw = batadv_orig_hash_find(bat_priv, orig_addr_gw);
+		if (orig_node_gw) {
+			is_gw = batadv_bla_is_backbone_gw(skb, orig_node_gw,
+							  hdr_size);
+			batadv_orig_node_put(orig_node_gw);
+			if (is_gw) {
+				batadv_dbg(BATADV_DBG_BLA, bat_priv,
+					   "Dropped unicast pkt received from another backbone gw %pM.\n",
+					   orig_addr_gw);
+				return NET_RX_DROP;
+			}
+		}
+
 		if (is4addr) {
 			subtype = unicast_4addr_packet->subtype;
 			batadv_dat_inc_counter(bat_priv, subtype);
-- 
2.11.0
