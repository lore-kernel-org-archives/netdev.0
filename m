From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/17] batman-adv: Use kref_get for batadv_gw_select
Date: Wed, 11 May 2016 03:29:59 +0800
Message-ID: <1462908605-27412-12-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:34911 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935AbcEJTjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:39:04 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_gw_select requires that the caller already has a valid reference for
new_gw_node. It is therefore not possible that it has an reference counter
of 0 and was still given to this function

The kref_get function instead WARNs (with debug information) when the
reference counter would still be 0. This makes a bug in batman-adv better
visible because kref_get_unless_zero would have ignored this problem.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/gateway_client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index c59aff5ccac8..bb1c4f37716e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -135,8 +135,8 @@ static void batadv_gw_select(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->gw.list_lock);
 
-	if (new_gw_node && !kref_get_unless_zero(&new_gw_node->refcount))
-		new_gw_node = NULL;
+	if (new_gw_node)
+		kref_get(&new_gw_node->refcount);
 
 	curr_gw_node = rcu_dereference_protected(bat_priv->gw.curr_gw, 1);
 	rcu_assign_pointer(bat_priv->gw.curr_gw, new_gw_node);
-- 
2.8.2
