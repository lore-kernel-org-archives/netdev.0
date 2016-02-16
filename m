From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 1/3] batman-adv: Only put gw_node list reference when removed
Date: Tue, 16 Feb 2016 23:01:26 +0800
Message-ID: <1455634888-29400-2-git-send-email-a@unstable.cc>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:46049 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932930AbcBPPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:03:57 -0500
In-Reply-To: <1455634888-29400-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batadv_gw_node reference counter in batadv_gw_node_update can only be
reduced when the list entry was actually removed. Otherwise the reference
counter may reach zero when batadv_gw_node_update is called from two
different contexts for the same gw_node but only one context is actually
removing the entry from the list.

The release function for this gw_node is not called inside the list_lock
spinlock protected region because the function batadv_gw_node_update still
holds a gw_node reference for the object pointer on the stack. Thus the
actual release function (when required) will be called only at the end of
the function.

Fixes: bd3524c14bd0 ("batman-adv: remove obsolete deleted attribute for gateway node")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/gateway_client.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index e6c8382c79ba..ccf70bed0d0c 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -527,11 +527,12 @@ void batadv_gw_node_update(struct batadv_priv *bat_priv,
 		 * gets dereferenced.
 		 */
 		spin_lock_bh(&bat_priv->gw.list_lock);
-		hlist_del_init_rcu(&gw_node->list);
+		if (!hlist_unhashed(&gw_node->list)) {
+			hlist_del_init_rcu(&gw_node->list);
+			batadv_gw_node_free_ref(gw_node);
+		}
 		spin_unlock_bh(&bat_priv->gw.list_lock);
 
-		batadv_gw_node_free_ref(gw_node);
-
 		curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 		if (gw_node == curr_gw)
 			batadv_gw_reselect(bat_priv);
-- 
2.7.1
