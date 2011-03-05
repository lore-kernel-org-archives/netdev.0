From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 06/28] batman-adv: protect neigh_nodes used
	outside of rcu_locks with refcounting
Date: Sat,  5 Mar 2011 13:28:20 +0100
Message-ID: <1299328122-21468-7-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1299328122-21468-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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
---
 net/batman-adv/routing.c |   40 +++++++++++++++++++++++++++++++---------
 1 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 97f3216..c15e6c1 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -151,6 +151,7 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct hlist_node *node;
 	unsigned char total_count;
+	int ret = 0;
 
 	if (orig_node == orig_neigh_node) {
 		rcu_read_lock();
@@ -162,7 +163,6 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
-		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_node,
@@ -171,7 +171,10 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 						     if_incoming);
 		/* create_neighbor failed, return 0 */
 		if (!neigh_node)
-			return 0;
+			goto unlock;
+
+		kref_get(&neigh_node->refcount);
+		rcu_read_unlock();
 
 		neigh_node->last_valid = jiffies;
 	} else {
@@ -185,7 +188,6 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 			    (tmp_neigh_node->if_incoming == if_incoming))
 				neigh_node = tmp_neigh_node;
 		}
-		rcu_read_unlock();
 
 		if (!neigh_node)
 			neigh_node = create_neighbor(orig_neigh_node,
@@ -194,7 +196,10 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 						     if_incoming);
 		/* create_neighbor failed, return 0 */
 		if (!neigh_node)
-			return 0;
+			goto unlock;
+
+		kref_get(&neigh_node->refcount);
+		rcu_read_unlock();
 	}
 
 	orig_node->last_valid = jiffies;
@@ -250,9 +255,16 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	/* if link has the minimum required transmission quality
 	 * consider it bidirectional */
 	if (batman_packet->tq >= TQ_TOTAL_BIDRECT_LIMIT)
-		return 1;
+		ret = 1;
 
-	return 0;
+	goto out;
+
+unlock:
+	rcu_read_unlock();
+out:
+	if (neigh_node)
+		kref_put(&neigh_node->refcount, neigh_node_free_ref);
+	return ret;
 }
 
 static void update_orig(struct bat_priv *bat_priv,
@@ -287,23 +299,25 @@ static void update_orig(struct bat_priv *bat_priv,
 		tmp_neigh_node->tq_avg =
 			ring_buffer_avg(tmp_neigh_node->tq_recv);
 	}
-	rcu_read_unlock();
 
 	if (!neigh_node) {
 		struct orig_node *orig_tmp;
 
 		orig_tmp = get_orig_node(bat_priv, ethhdr->h_source);
 		if (!orig_tmp)
-			return;
+			goto unlock;
 
 		neigh_node = create_neighbor(orig_node, orig_tmp,
 					     ethhdr->h_source, if_incoming);
 		if (!neigh_node)
-			return;
+			goto unlock;
 	} else
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Updating existing last-hop neighbor of originator\n");
 
+	kref_get(&neigh_node->refcount);
+	rcu_read_unlock();
+
 	orig_node->flags = batman_packet->flags;
 	neigh_node->last_valid = jiffies;
 
@@ -357,6 +371,14 @@ update_gw:
 	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_CLIENT) &&
 	    (atomic_read(&bat_priv->gw_sel_class) > 2))
 		gw_check_election(bat_priv, orig_node);
+
+	goto out;
+
+unlock:
+	rcu_read_unlock();
+out:
+	if (neigh_node)
+		kref_put(&neigh_node->refcount, neigh_node_free_ref);
 }
 
 /* checks whether the host restarted and is in the protection time.
-- 
1.7.2.3
