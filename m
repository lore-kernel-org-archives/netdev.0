From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 1/4] batman-adv: orig_hash_find() manages
	rcu_lock/unlock internally
Date: Sun,  1 May 2011 23:10:31 +0200
Message-ID: <1304284234-27338-2-git-send-email-sven@narfation.org>
References: <1304284234-27338-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304284234-27338-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

orig_hash_find() manages rcu_lock/unlock internally and doesn't need to
be surrounded by rcu_read_lock() / rcu_read_unlock() anymore

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Acked-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/routing.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f6c6422..2d77bd3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1310,13 +1310,10 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	}
 
 	/* get routing information */
-	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
 
 	if (!orig_node)
-		goto unlock;
-
-	rcu_read_unlock();
+		goto out;
 
 	/* find_router() increases neigh_nodes refcount if found. */
 	neigh_node = find_router(bat_priv, orig_node, recv_if);
@@ -1362,10 +1359,7 @@ int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	/* route it */
 	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
-	goto out;
 
-unlock:
-	rcu_read_unlock();
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -1464,13 +1458,10 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	if (bcast_packet->ttl < 2)
 		goto out;
 
-	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, bcast_packet->orig);
 
 	if (!orig_node)
-		goto rcu_unlock;
-
-	rcu_read_unlock();
+		goto out;
 
 	spin_lock_bh(&orig_node->bcast_seqno_lock);
 
@@ -1501,9 +1492,6 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	ret = NET_RX_SUCCESS;
 	goto out;
 
-rcu_unlock:
-	rcu_read_unlock();
-	goto out;
 spin_unlock:
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
 out:
-- 
1.7.4.4
