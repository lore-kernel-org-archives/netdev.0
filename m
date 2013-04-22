From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: use the proper header len when checking the TTVN
Date: Mon, 22 Apr 2013 10:38:14 +0200
Message-ID: <1366619894-16857-2-git-send-email-ordex@autistici.org>
References: <1366619894-16857-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56397 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986Ab3DVIj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:39:58 -0400
In-Reply-To: <1366619894-16857-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Unicast packet might be of type either UNICAST or
UNICAST4ADDR.
In the two cases the header size is different, but the
mechanism checking the TTVN field was assuming it to be
always of the same type (UNICAST), so failing to access the
inner Ethernet header in case of UNICAST4ADDR.

Fix this by passing the real header length as argument.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 319f290..7de0336 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -924,7 +924,7 @@ out:
 }
 
 static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
-				     struct sk_buff *skb) {
+				     struct sk_buff *skb, int hdr_len) {
 	uint8_t curr_ttvn, old_ttvn;
 	struct batadv_orig_node *orig_node;
 	struct ethhdr *ethhdr;
@@ -933,7 +933,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	int is_old_ttvn;
 
 	/* check if there is enough data before accessing it */
-	if (pskb_may_pull(skb, sizeof(*unicast_packet) + ETH_HLEN) < 0)
+	if (pskb_may_pull(skb, hdr_len + ETH_HLEN) < 0)
 		return 0;
 
 	/* create a copy of the skb (in case of for re-routing) to modify it. */
@@ -941,7 +941,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		return 0;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-	ethhdr = (struct ethhdr *)(skb->data + sizeof(*unicast_packet));
+	ethhdr = (struct ethhdr *)(skb->data + hdr_len);
 
 	/* check if the destination client was served by this node and it is now
 	 * roaming. In this case, it means that the node has got a ROAM_ADV
@@ -1048,8 +1048,7 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 
 	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
 		return NET_RX_DROP;
-
-	if (!batadv_check_unicast_ttvn(bat_priv, skb))
+	if (!batadv_check_unicast_ttvn(bat_priv, skb, hdr_size))
 		return NET_RX_DROP;
 
 	/* packet for me */
@@ -1093,7 +1092,7 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
 		return NET_RX_DROP;
 
-	if (!batadv_check_unicast_ttvn(bat_priv, skb))
+	if (!batadv_check_unicast_ttvn(bat_priv, skb, hdr_size))
 		return NET_RX_DROP;
 
 	unicast_packet = (struct batadv_unicast_frag_packet *)skb->data;
-- 
1.8.1.5
