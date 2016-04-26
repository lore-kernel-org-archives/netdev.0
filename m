From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 4/5] batman-adv: Reduce refcnt of removed router when updating route
Date: Tue, 26 Apr 2016 11:27:18 +0800
Message-ID: <1461641239-7097-5-git-send-email-a@unstable.cc>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:37590 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbcDZD2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:28:12 -0400
In-Reply-To: <1461641239-7097-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

_batadv_update_route rcu_derefences orig_ifinfo->router outside of a
spinlock protected region to print some information messages to the debug
log. But this pointer is not checked again when the new pointer is assigned
in the spinlock protected region. Thus is can happen that the value of
orig_ifinfo->router changed in the meantime and thus the reference counter
of the wrong router gets reduced after the spinlock protected region.

Just rcu_dereferencing the value of orig_ifinfo->router inside the spinlock
protected region (which also set the new pointer) is enough to get the
correct old router object.

Fixes: e1a5382f978b ("batman-adv: Make orig_node->router an rcu protected pointer")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/routing.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 4dd646a52f1a..b781bf753250 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -105,6 +105,15 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 		neigh_node = NULL;
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
+	/* curr_router used earlier may not be the current orig_ifinfo->router
+	 * anymore because it was dereferenced outside of the neigh_list_lock
+	 * protected region. After the new best neighbor has replace the current
+	 * best neighbor the reference counter needs to decrease. Consequently,
+	 * the code needs to ensure the curr_router variable contains a pointer
+	 * to the replaced best neighbor.
+	 */
+	curr_router = rcu_dereference_protected(orig_ifinfo->router, true);
+
 	rcu_assign_pointer(orig_ifinfo->router, neigh_node);
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 	batadv_orig_ifinfo_put(orig_ifinfo);
-- 
2.8.1
