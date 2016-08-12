From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 19/19] batman-adv: Fix consistency of update route messages
Date: Fri, 12 Aug 2016 10:56:55 +0200
Message-ID: <1470992215-11009-20-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:34982 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbcHLI5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:39 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The debug messages of _batadv_update_route were printed before the actual
route change is done. At this point it is not really known which
curr_router will be replaced. Thus the messages could print the wrong
operation.

Printing the debug messages after the operation was done avoids this
problem.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/routing.c | 43 +++++++++++++++++--------------------------
 1 file changed, 17 insertions(+), 26 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7602c00..610f2c4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -74,11 +74,23 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 	if (!orig_ifinfo)
 		return;
 
-	rcu_read_lock();
-	curr_router = rcu_dereference(orig_ifinfo->router);
-	if (curr_router && !kref_get_unless_zero(&curr_router->refcount))
-		curr_router = NULL;
-	rcu_read_unlock();
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	/* curr_router used earlier may not be the current orig_ifinfo->router
+	 * anymore because it was dereferenced outside of the neigh_list_lock
+	 * protected region. After the new best neighbor has replace the current
+	 * best neighbor the reference counter needs to decrease. Consequently,
+	 * the code needs to ensure the curr_router variable contains a pointer
+	 * to the replaced best neighbor.
+	 */
+	curr_router = rcu_dereference_protected(orig_ifinfo->router, true);
+
+	/* increase refcount of new best neighbor */
+	if (neigh_node)
+		kref_get(&neigh_node->refcount);
+
+	rcu_assign_pointer(orig_ifinfo->router, neigh_node);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+	batadv_orig_ifinfo_put(orig_ifinfo);
 
 	/* route deleted */
 	if ((curr_router) && (!neigh_node)) {
@@ -100,27 +112,6 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 			   curr_router->addr);
 	}
 
-	if (curr_router)
-		batadv_neigh_node_put(curr_router);
-
-	spin_lock_bh(&orig_node->neigh_list_lock);
-	/* curr_router used earlier may not be the current orig_ifinfo->router
-	 * anymore because it was dereferenced outside of the neigh_list_lock
-	 * protected region. After the new best neighbor has replace the current
-	 * best neighbor the reference counter needs to decrease. Consequently,
-	 * the code needs to ensure the curr_router variable contains a pointer
-	 * to the replaced best neighbor.
-	 */
-	curr_router = rcu_dereference_protected(orig_ifinfo->router, true);
-
-	/* increase refcount of new best neighbor */
-	if (neigh_node)
-		kref_get(&neigh_node->refcount);
-
-	rcu_assign_pointer(orig_ifinfo->router, neigh_node);
-	spin_unlock_bh(&orig_node->neigh_list_lock);
-	batadv_orig_ifinfo_put(orig_ifinfo);
-
 	/* decrease refcount of previous best neighbor */
 	if (curr_router)
 		batadv_neigh_node_put(curr_router);
-- 
2.8.1
