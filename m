From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 12/17] batman-adv: Use rcu_dereference_protected by update-side
Date: Mon, 30 May 2011 09:22:57 +0200
Message-ID: <1306740182-2665-13-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60280 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288Ab1E3HXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:22 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually rcu_dereference isn't necessary in situations were the
RCU-protected data structure cannot change, but sparse and lockdep still
need a similar functionality for analysis. rcu_dereference_protected
implements the reduced version which should be used to support the
dynamic and static analysis.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/gateway_client.c |    2 +-
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/soft-interface.c |    3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a44dff3..ab597c4 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -86,7 +86,7 @@ static void gw_select(struct bat_priv *bat_priv, struct gw_node *new_gw_node)
 	if (new_gw_node && !atomic_inc_not_zero(&new_gw_node->refcount))
 		new_gw_node = NULL;
 
-	curr_gw_node = bat_priv->curr_gw;
+	curr_gw_node = rcu_dereference_protected(bat_priv->curr_gw, 1);
 	rcu_assign_pointer(bat_priv->curr_gw, new_gw_node);
 
 	if (curr_gw_node)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index e0052cf..a3fbfb5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -138,7 +138,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	if (new_hard_iface && !atomic_inc_not_zero(&new_hard_iface->refcount))
 		new_hard_iface = NULL;
 
-	curr_hard_iface = bat_priv->primary_if;
+	curr_hard_iface = rcu_dereference_protected(bat_priv->primary_if, 1);
 	rcu_assign_pointer(bat_priv->primary_if, new_hard_iface);
 
 	if (curr_hard_iface)
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index cead606..b8d3f248 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -241,7 +241,8 @@ static void softif_neigh_vid_select(struct bat_priv *bat_priv,
 	if (new_neigh && !atomic_inc_not_zero(&new_neigh->refcount))
 		new_neigh = NULL;
 
-	curr_neigh = softif_neigh_vid->softif_neigh;
+	curr_neigh = rcu_dereference_protected(softif_neigh_vid->softif_neigh,
+					       1);
 	rcu_assign_pointer(softif_neigh_vid->softif_neigh, new_neigh);
 
 	if ((curr_neigh) && (!new_neigh))
-- 
1.7.5.3

