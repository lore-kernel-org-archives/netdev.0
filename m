From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/4] batman-adv: fix speedy join for DAT cache replies
Date: Mon,  7 Dec 2015 23:12:12 +0800
Message-ID: <1449501135-30438-2-git-send-email-antonio@meshcoding.com>
References: <1449501135-30438-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:18373 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933041AbbLGPOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 10:14:11 -0500
In-Reply-To: <1449501135-30438-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

DAT Cache replies are answered on behalf of other clients which are not
connected to the answering originator. Therefore, we shouldn't add these
clients to the answering originators TT table through speed join to
avoid bogus entries.

Reported-by: Alessandro Bolletta <alessandro@mediaspot.net>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/routing.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 8d990b0..3207667 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -836,6 +836,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	u8 *orig_addr;
 	struct batadv_orig_node *orig_node = NULL;
 	int check, hdr_size = sizeof(*unicast_packet);
+	enum batadv_subtype subtype;
 	bool is4addr;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
@@ -863,10 +864,20 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	/* packet for me */
 	if (batadv_is_my_mac(bat_priv, unicast_packet->dest)) {
 		if (is4addr) {
-			batadv_dat_inc_counter(bat_priv,
-					       unicast_4addr_packet->subtype);
-			orig_addr = unicast_4addr_packet->src;
-			orig_node = batadv_orig_hash_find(bat_priv, orig_addr);
+			subtype = unicast_4addr_packet->subtype;
+			batadv_dat_inc_counter(bat_priv, subtype);
+
+			/* Only payload data should be considered for speedy
+			 * join. For example, DAT also uses unicast 4addr
+			 * types, but those packets should not be considered
+			 * for speedy join, since the clients do not actually
+			 * reside at the sending originator.
+			 */
+			if (subtype == BATADV_P_DATA) {
+				orig_addr = unicast_4addr_packet->src;
+				orig_node = batadv_orig_hash_find(bat_priv,
+								  orig_addr);
+			}
 		}
 
 		if (batadv_dat_snoop_incoming_arp_request(bat_priv, skb,
-- 
2.6.3
