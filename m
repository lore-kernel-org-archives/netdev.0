From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 5/8] batman-adv: Fix refcount imbalance in
	find_router
Date: Sun,  8 May 2011 17:24:41 +0200
Message-ID: <1304868284-9364-6-git-send-email-sven@narfation.org>
References: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304868284-9364-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 49f5715..d8cde2b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1213,7 +1213,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 
 	router = orig_node_get_router(orig_node);
 	if (!router)
-		return NULL;
+		goto err;
 
 	/* without bonding, the first node should
 	 * always choose the default router. */
@@ -1222,10 +1222,8 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	rcu_read_lock();
 	/* select default router to output */
 	router_orig = router->orig_node;
-	if (!router_orig) {
-		rcu_read_unlock();
-		return NULL;
-	}
+	if (!router_orig)
+		goto err_unlock;
 
 	if ((!recv_if) && (!bonding_enabled))
 		goto return_router;
@@ -1268,6 +1266,12 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 return_router:
 	rcu_read_unlock();
 	return router;
+err_unlock:
+	rcu_read_unlock();
+err:
+	if (router)
+		neigh_node_free_ref(router);
+	return NULL;
 }
 
 static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
-- 
1.7.5.1
