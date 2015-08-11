From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/10] batman-adv: protect tt request from double deletion
Date: Tue, 11 Aug 2015 18:35:46 +0200
Message-ID: <1439310948-32426-9-git-send-email-antonio@meshcoding.com>
References: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:27895 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965323AbbHKQhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 12:37:08 -0400
In-Reply-To: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The list_del() calls were changed to list_del_init() to prevent
an accidental double deletion in batadv_tt_req_node_new().

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1573489..cd35bb8 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2196,7 +2196,7 @@ static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
 
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
-		list_del(&node->list);
+		list_del_init(&node->list);
 		kfree(node);
 	}
 
@@ -2232,7 +2232,7 @@ static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (batadv_has_timed_out(node->issued_at,
 					 BATADV_TT_REQUEST_TIMEOUT)) {
-			list_del(&node->list);
+			list_del_init(&node->list);
 			kfree(node);
 		}
 	}
@@ -2514,7 +2514,8 @@ out:
 		batadv_hardif_free_ref(primary_if);
 	if (ret && tt_req_node) {
 		spin_lock_bh(&bat_priv->tt.req_list_lock);
-		list_del(&tt_req_node->list);
+		/* list_del_init() verifies tt_req_node still is in the list */
+		list_del_init(&tt_req_node->list);
 		spin_unlock_bh(&bat_priv->tt.req_list_lock);
 		kfree(tt_req_node);
 	}
@@ -2951,7 +2952,7 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (!batadv_compare_eth(node->addr, resp_src))
 			continue;
-		list_del(&node->list);
+		list_del_init(&node->list);
 		kfree(node);
 	}
 
-- 
2.5.0
