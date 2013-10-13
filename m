From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/16] batman-adv: remove useless find_router look up
Date: Sun, 13 Oct 2013 13:22:58 +0200
Message-ID: <1381663381-626-14-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:37982 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3JMLwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:52:47 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

This is not used anymore with the new fragmentation, and it might
actually mess up the bonding code because find_router() assumes it
is only called once per packet.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/send.c | 29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 4bbcf51..82588e4 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -250,30 +250,19 @@ int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *neigh_node;
 	int ret = NET_RX_DROP;
 
 	/* get routing information */
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+	if (is_multicast_ether_addr(ethhdr->h_dest))
 		orig_node = batadv_gw_get_selected_orig(bat_priv);
-		if (orig_node)
-			goto find_router;
-	}
+	else
+		/* check for tt host - increases orig_node refcount.
+		 * returns NULL in case of AP isolation
+		 */
+		orig_node = batadv_transtable_search(bat_priv, ethhdr->h_source,
+						     ethhdr->h_dest);
 
-	/* check for tt host - increases orig_node refcount.
-	 * returns NULL in case of AP isolation
-	 */
-	orig_node = batadv_transtable_search(bat_priv, ethhdr->h_source,
-					     ethhdr->h_dest);
-
-find_router:
-	/* find_router():
-	 *  - if orig_node is NULL it returns NULL
-	 *  - increases neigh_nodes refcount if found.
-	 */
-	neigh_node = batadv_find_router(bat_priv, orig_node, NULL);
-
-	if (!neigh_node)
+	if (!orig_node)
 		goto out;
 
 	switch (packet_type) {
@@ -305,8 +294,6 @@ find_router:
 		ret = 0;
 
 out:
-	if (neigh_node)
-		batadv_neigh_node_free_ref(neigh_node);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
 	if (ret == NET_RX_DROP)
-- 
1.8.3.2
