From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/10] batman-adv: Replace gw_reselect divisor with simple shift
Date: Tue, 11 Aug 2015 18:35:39 +0200
Message-ID: <1439310948-32426-2-git-send-email-antonio__19540.7134168365$1439311022$gmane$org@meshcoding.com>
References: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:45792 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965202AbbHKQgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 12:36:55 -0400
In-Reply-To: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The gw_factor is divided by BATADV_TQ_LOCAL_WINDOW_SIZE ** 2 * 64. But the
rest of the calculation has nothing to do with the tq window size and
therefore the calculation is just (tmp_gw_factor / (64 ** 3)).

Replace it with a simple shift to avoid a costly 64-bit divide when the
max_gw_factor is changed from u32 to u64. This type change is necessary
to avoid an overflow bug.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_client.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index bb015862..e1e1f31 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -154,14 +154,10 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	struct batadv_neigh_ifinfo *router_ifinfo;
 	struct batadv_gw_node *gw_node, *curr_gw = NULL;
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
-	uint32_t gw_divisor;
 	uint8_t max_tq = 0;
 	uint8_t tq_avg;
 	struct batadv_orig_node *orig_node;
 
-	gw_divisor = BATADV_TQ_LOCAL_WINDOW_SIZE * BATADV_TQ_LOCAL_WINDOW_SIZE;
-	gw_divisor *= 64;
-
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
 		if (gw_node->deleted)
@@ -187,7 +183,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 			tmp_gw_factor = tq_avg * tq_avg;
 			tmp_gw_factor *= gw_node->bandwidth_down;
 			tmp_gw_factor *= 100 * 100;
-			tmp_gw_factor /= gw_divisor;
+			tmp_gw_factor >>= 18;
 
 			if ((tmp_gw_factor > max_gw_factor) ||
 			    ((tmp_gw_factor == max_gw_factor) &&
-- 
2.5.0
