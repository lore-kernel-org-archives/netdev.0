From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 11/14] batman-adv: protect tt request from double deletion
Date: Tue,  4 Aug 2015 18:35:31 +0200
Message-ID: <1438706134-3492-12-git-send-email-antonio__8340.54429219595$1438707295$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:13216 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbHDQyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:54:49 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
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
index cb2a2d1..db06de2 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2213,7 +2213,7 @@ static void batadv_tt_req_list_free(struct batadv_priv *bat_priv)
 	spin_lock_bh(&bat_priv->tt.req_list_lock);
 
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
-		list_del(&node->list);
+		list_del_init(&node->list);
 		kfree(node);
 	}
 
@@ -2249,7 +2249,7 @@ static void batadv_tt_req_purge(struct batadv_priv *bat_priv)
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (batadv_has_timed_out(node->issued_at,
 					 BATADV_TT_REQUEST_TIMEOUT)) {
-			list_del(&node->list);
+			list_del_init(&node->list);
 			kfree(node);
 		}
 	}
@@ -2531,7 +2531,8 @@ out:
 		batadv_hardif_free_ref(primary_if);
 	if (ret && tt_req_node) {
 		spin_lock_bh(&bat_priv->tt.req_list_lock);
-		list_del(&tt_req_node->list);
+		/* list_del_init() verifies tt_req_node still is in the list */
+		list_del_init(&tt_req_node->list);
 		spin_unlock_bh(&bat_priv->tt.req_list_lock);
 		kfree(tt_req_node);
 	}
@@ -2968,7 +2969,7 @@ static void batadv_handle_tt_response(struct batadv_priv *bat_priv,
 	list_for_each_entry_safe(node, safe, &bat_priv->tt.req_list, list) {
 		if (!batadv_compare_eth(node->addr, resp_src))
 			continue;
-		list_del(&node->list);
+		list_del_init(&node->list);
 		kfree(node);
 	}
 
-- 
2.5.0
