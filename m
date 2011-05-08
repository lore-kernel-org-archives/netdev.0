From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 8/8] batman-adv: remove duplicate code from
	function is_bidirectional_neigh()
Date: Sun,  8 May 2011 17:24:44 +0200
Message-ID: <1304868284-9364-9-git-send-email-sven@narfation.org>
References: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
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

From: Daniele Furlan <daniele.furlan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

In function is_bidirectional_neigh the code that find out the one hop
neighbor is duplicated.

Signed-off-by: Daniele Furlan <daniele.furlan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |   74 +++++++++++++++------------------------------
 1 files changed, 25 insertions(+), 49 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7648b92..bb1c3ec 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -169,65 +169,41 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 	uint8_t orig_eq_count, neigh_rq_count, tq_own;
 	int tq_asym_penalty, ret = 0;
 
-	if (orig_node == orig_neigh_node) {
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(tmp_neigh_node, node,
-					 &orig_node->neigh_list, list) {
+	/* find corresponding one hop neighbor */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tmp_neigh_node, node,
+				 &orig_neigh_node->neigh_list, list) {
 
-			if (!compare_eth(tmp_neigh_node->addr,
-					 orig_neigh_node->orig))
-				continue;
+		if (!compare_eth(tmp_neigh_node->addr, orig_neigh_node->orig))
+			continue;
 
-			if (tmp_neigh_node->if_incoming != if_incoming)
-				continue;
+		if (tmp_neigh_node->if_incoming != if_incoming)
+			continue;
 
-			if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
-				continue;
+		if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+			continue;
 
-			neigh_node = tmp_neigh_node;
-		}
-		rcu_read_unlock();
+		neigh_node = tmp_neigh_node;
+		break;
+	}
+	rcu_read_unlock();
 
-		if (!neigh_node)
-			neigh_node = create_neighbor(orig_node,
-						     orig_neigh_node,
-						     orig_neigh_node->orig,
-						     if_incoming);
-		if (!neigh_node)
-			goto out;
+	if (!neigh_node)
+		neigh_node = create_neighbor(orig_neigh_node,
+					     orig_neigh_node,
+					     orig_neigh_node->orig,
+					     if_incoming);
 
+	if (!neigh_node)
+		goto out;
+
+	/* if orig_node is direct neighbour update neigh_node last_valid */
+	if (orig_node == orig_neigh_node)
 		neigh_node->last_valid = jiffies;
-	} else {
-		/* find packet count of corresponding one hop neighbor */
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(tmp_neigh_node, node,
-					 &orig_neigh_node->neigh_list, list) {
-
-			if (!compare_eth(tmp_neigh_node->addr,
-					 orig_neigh_node->orig))
-				continue;
-
-			if (tmp_neigh_node->if_incoming != if_incoming)
-				continue;
-
-			if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
-				continue;
-
-			neigh_node = tmp_neigh_node;
-		}
-		rcu_read_unlock();
-
-		if (!neigh_node)
-			neigh_node = create_neighbor(orig_neigh_node,
-						     orig_neigh_node,
-						     orig_neigh_node->orig,
-						     if_incoming);
-		if (!neigh_node)
-			goto out;
-	}
 
 	orig_node->last_valid = jiffies;
 
+	/* find packet count of corresponding one hop neighbor */
 	spin_lock_bh(&orig_node->ogm_cnt_lock);
 	orig_eq_count = orig_neigh_node->bcast_own_sum[if_incoming->if_num];
 	neigh_rq_count = neigh_node->real_packet_count;
-- 
1.7.5.1
