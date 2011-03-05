From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 11/28] batman-adv: Correct rcu refcounting
	for neigh_node
Date: Sat,  5 Mar 2011 13:28:25 +0100
Message-ID: <1299328122-21468-12-git-send-email-sven@narfation.org>
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

It might be possible that 2 threads access the same data in the same
rcu grace period. The first thread calls call_rcu() to decrement the
refcount and free the data while the second thread increases the
refcount to use the data. To avoid this race condition all refcount
operations have to be atomic.

Reported-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/icmp_socket.c |   27 +++-
 net/batman-adv/originator.c  |   26 +---
 net/batman-adv/originator.h  |    3 +-
 net/batman-adv/routing.c     |  338 +++++++++++++++++++++++++++--------------
 net/batman-adv/types.h       |    3 +-
 net/batman-adv/unicast.c     |   57 +++++---
 net/batman-adv/vis.c         |   33 ++++-
 7 files changed, 313 insertions(+), 174 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 8e0cd8a..7fa5bb8 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -156,7 +156,8 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	struct sk_buff *skb;
 	struct icmp_packet_rr *icmp_packet;
 
-	struct orig_node *orig_node;
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
 	struct batman_if *batman_if;
 	size_t packet_len = sizeof(struct icmp_packet);
 	uint8_t dstaddr[ETH_ALEN];
@@ -224,17 +225,25 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   icmp_packet->dst));
-	rcu_read_unlock();
 
 	if (!orig_node)
 		goto unlock;
 
-	if (!orig_node->router)
+	kref_get(&orig_node->refcount);
+	neigh_node = orig_node->router;
+
+	if (!neigh_node)
+		goto unlock;
+
+	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+		neigh_node = NULL;
 		goto unlock;
+	}
+
+	rcu_read_unlock();
 
 	batman_if = orig_node->router->if_incoming;
 	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	if (!batman_if)
@@ -247,14 +256,14 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
 
 	if (packet_len == sizeof(struct icmp_packet_rr))
-		memcpy(icmp_packet->rr, batman_if->net_dev->dev_addr, ETH_ALEN);
-
+		memcpy(icmp_packet->rr,
+		       batman_if->net_dev->dev_addr, ETH_ALEN);
 
 	send_skb_packet(skb, batman_if, dstaddr);
-
 	goto out;
 
 unlock:
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 dst_unreach:
 	icmp_packet->msg_type = DESTINATION_UNREACHABLE;
@@ -262,6 +271,10 @@ dst_unreach:
 free_skb:
 	kfree_skb(skb);
 out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
 	return len;
 }
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a85eadc..61299da 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -59,28 +59,18 @@ err:
 	return 0;
 }
 
-void neigh_node_free_ref(struct kref *refcount)
-{
-	struct neigh_node *neigh_node;
-
-	neigh_node = container_of(refcount, struct neigh_node, refcount);
-	kfree(neigh_node);
-}
-
 static void neigh_node_free_rcu(struct rcu_head *rcu)
 {
 	struct neigh_node *neigh_node;
 
 	neigh_node = container_of(rcu, struct neigh_node, rcu);
-	kref_put(&neigh_node->refcount, neigh_node_free_ref);
+	kfree(neigh_node);
 }
 
-void neigh_node_free_rcu_bond(struct rcu_head *rcu)
+void neigh_node_free_ref(struct neigh_node *neigh_node)
 {
-	struct neigh_node *neigh_node;
-
-	neigh_node = container_of(rcu, struct neigh_node, rcu_bond);
-	kref_put(&neigh_node->refcount, neigh_node_free_ref);
+	if (atomic_dec_and_test(&neigh_node->refcount))
+		call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
 }
 
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
@@ -104,7 +94,7 @@ struct neigh_node *create_neighbor(struct orig_node *orig_node,
 	memcpy(neigh_node->addr, neigh, ETH_ALEN);
 	neigh_node->orig_node = orig_neigh_node;
 	neigh_node->if_incoming = if_incoming;
-	kref_init(&neigh_node->refcount);
+	atomic_set(&neigh_node->refcount, 1);
 
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
@@ -126,14 +116,14 @@ void orig_node_free_ref(struct kref *refcount)
 	list_for_each_entry_safe(neigh_node, tmp_neigh_node,
 				 &orig_node->bond_list, bonding_list) {
 		list_del_rcu(&neigh_node->bonding_list);
-		call_rcu(&neigh_node->rcu_bond, neigh_node_free_rcu_bond);
+		neigh_node_free_ref(neigh_node);
 	}
 
 	/* for all neighbors towards this originator ... */
 	hlist_for_each_entry_safe(neigh_node, node, node_tmp,
 				  &orig_node->neigh_list, list) {
 		hlist_del_rcu(&neigh_node->list);
-		call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
+		neigh_node_free_ref(neigh_node);
 	}
 
 	spin_unlock_bh(&orig_node->neigh_list_lock);
@@ -315,7 +305,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 
 			hlist_del_rcu(&neigh_node->list);
 			bonding_candidate_del(orig_node, neigh_node);
-			call_rcu(&neigh_node->rcu, neigh_node_free_rcu);
+			neigh_node_free_ref(neigh_node);
 		} else {
 			if ((!*best_neigh_node) ||
 			    (neigh_node->tq_avg > (*best_neigh_node)->tq_avg))
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 360dfd1..84d96e2 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -26,13 +26,12 @@ int originator_init(struct bat_priv *bat_priv);
 void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
 void orig_node_free_ref(struct kref *refcount);
-void neigh_node_free_rcu_bond(struct rcu_head *rcu);
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
 				   struct batman_if *if_incoming);
-void neigh_node_free_ref(struct kref *refcount);
+void neigh_node_free_ref(struct neigh_node *neigh_node);
 int orig_seq_print_text(struct seq_file *seq, void *offset);
 int orig_hash_add_if(struct batman_if *batman_if, int max_if_num);
 int orig_hash_del_if(struct batman_if *batman_if, int max_if_num);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1ad14da..9185666 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -121,12 +121,12 @@ static void update_route(struct bat_priv *bat_priv,
 			orig_node->router->addr);
 	}
 
-	if (neigh_node)
-		kref_get(&neigh_node->refcount);
+	if (neigh_node && !atomic_inc_not_zero(&neigh_node->refcount))
+		neigh_node = NULL;
 	neigh_node_tmp = orig_node->router;
 	orig_node->router = neigh_node;
 	if (neigh_node_tmp)
-		kref_put(&neigh_node_tmp->refcount, neigh_node_free_ref);
+		neigh_node_free_ref(neigh_node_tmp);
 }
 
 
@@ -177,7 +177,11 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		if (!neigh_node)
 			goto unlock;
 
-		kref_get(&neigh_node->refcount);
+		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+			neigh_node = NULL;
+			goto unlock;
+		}
+
 		rcu_read_unlock();
 
 		neigh_node->last_valid = jiffies;
@@ -202,7 +206,11 @@ static int is_bidirectional_neigh(struct orig_node *orig_node,
 		if (!neigh_node)
 			goto unlock;
 
-		kref_get(&neigh_node->refcount);
+		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+			neigh_node = NULL;
+			goto unlock;
+		}
+
 		rcu_read_unlock();
 	}
 
@@ -267,7 +275,7 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (neigh_node)
-		kref_put(&neigh_node->refcount, neigh_node_free_ref);
+		neigh_node_free_ref(neigh_node);
 	return ret;
 }
 
@@ -280,8 +288,8 @@ void bonding_candidate_del(struct orig_node *orig_node,
 		goto out;
 
 	list_del_rcu(&neigh_node->bonding_list);
-	call_rcu(&neigh_node->rcu_bond, neigh_node_free_rcu_bond);
 	INIT_LIST_HEAD(&neigh_node->bonding_list);
+	neigh_node_free_ref(neigh_node);
 	atomic_dec(&orig_node->bond_candidates);
 
 out:
@@ -342,8 +350,10 @@ static void bonding_candidate_add(struct orig_node *orig_node,
 	if (!list_empty(&neigh_node->bonding_list))
 		goto out;
 
+	if (!atomic_inc_not_zero(&neigh_node->refcount))
+		goto out;
+
 	list_add_rcu(&neigh_node->bonding_list, &orig_node->bond_list);
-	kref_get(&neigh_node->refcount);
 	atomic_inc(&orig_node->bond_candidates);
 	goto out;
 
@@ -387,7 +397,10 @@ static void update_orig(struct bat_priv *bat_priv,
 	hlist_for_each_entry_rcu(tmp_neigh_node, node,
 				 &orig_node->neigh_list, list) {
 		if (compare_orig(tmp_neigh_node->addr, ethhdr->h_source) &&
-		    (tmp_neigh_node->if_incoming == if_incoming)) {
+		    (tmp_neigh_node->if_incoming == if_incoming) &&
+		     atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
+			if (neigh_node)
+				neigh_node_free_ref(neigh_node);
 			neigh_node = tmp_neigh_node;
 			continue;
 		}
@@ -414,11 +427,15 @@ static void update_orig(struct bat_priv *bat_priv,
 		kref_put(&orig_tmp->refcount, orig_node_free_ref);
 		if (!neigh_node)
 			goto unlock;
+
+		if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+			neigh_node = NULL;
+			goto unlock;
+		}
 	} else
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Updating existing last-hop neighbor of originator\n");
 
-	kref_get(&neigh_node->refcount);
 	rcu_read_unlock();
 
 	orig_node->flags = batman_packet->flags;
@@ -495,7 +512,7 @@ unlock:
 	rcu_read_unlock();
 out:
 	if (neigh_node)
-		kref_put(&neigh_node->refcount, neigh_node_free_ref);
+		neigh_node_free_ref(neigh_node);
 }
 
 /* checks whether the host restarted and is in the protection time.
@@ -870,22 +887,23 @@ int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
 static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 			       struct sk_buff *skb, size_t icmp_len)
 {
-	struct orig_node *orig_node;
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
 	struct icmp_packet_rr *icmp_packet;
 	struct batman_if *batman_if;
-	int ret;
 	uint8_t dstaddr[ETH_ALEN];
+	int ret = NET_RX_DROP;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
 
 	/* add data to device queue */
 	if (icmp_packet->msg_type != ECHO_REQUEST) {
 		bat_socket_receive_packet(icmp_packet, icmp_len);
-		return NET_RX_DROP;
+		goto out;
 	}
 
 	if (!bat_priv->primary_if)
-		return NET_RX_DROP;
+		goto out;
 
 	/* answer echo request (ping) */
 	/* get routing information */
@@ -894,46 +912,65 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   icmp_packet->orig));
-	rcu_read_unlock();
-	ret = NET_RX_DROP;
 
-	if ((orig_node) && (orig_node->router)) {
+	if (!orig_node)
+		goto unlock;
 
-		/* don't lock while sending the packets ... we therefore
-		 * copy the required data before sending */
-		batman_if = orig_node->router->if_incoming;
-		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	kref_get(&orig_node->refcount);
+	neigh_node = orig_node->router;
 
-		/* create a copy of the skb, if needed, to modify it. */
-		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
-			return NET_RX_DROP;
+	if (!neigh_node)
+		goto unlock;
 
-		icmp_packet = (struct icmp_packet_rr *)skb->data;
+	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+		neigh_node = NULL;
+		goto unlock;
+	}
 
-		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
-		memcpy(icmp_packet->orig,
-		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
-		icmp_packet->msg_type = ECHO_REPLY;
-		icmp_packet->ttl = TTL;
+	rcu_read_unlock();
 
-		send_skb_packet(skb, batman_if, dstaddr);
-		ret = NET_RX_SUCCESS;
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if = orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
-	} else
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+		goto out;
 
+	icmp_packet = (struct icmp_packet_rr *)skb->data;
+
+	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+	memcpy(icmp_packet->orig,
+		bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	icmp_packet->msg_type = ECHO_REPLY;
+	icmp_packet->ttl = TTL;
+
+	send_skb_packet(skb, batman_if, dstaddr);
+	ret = NET_RX_SUCCESS;
+	goto out;
+
+unlock:
+	rcu_read_unlock();
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
 	return ret;
 }
 
 static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 				  struct sk_buff *skb)
 {
-	struct orig_node *orig_node;
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
 	struct icmp_packet *icmp_packet;
 	struct batman_if *batman_if;
-	int ret;
 	uint8_t dstaddr[ETH_ALEN];
+	int ret = NET_RX_DROP;
 
 	icmp_packet = (struct icmp_packet *)skb->data;
 
@@ -942,11 +979,11 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		pr_debug("Warning - can't forward icmp packet from %pM to "
 			 "%pM: ttl exceeded\n", icmp_packet->orig,
 			 icmp_packet->dst);
-		return NET_RX_DROP;
+		goto out;
 	}
 
 	if (!bat_priv->primary_if)
-		return NET_RX_DROP;
+		goto out;
 
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
@@ -954,35 +991,53 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       icmp_packet->orig));
-	rcu_read_unlock();
-	ret = NET_RX_DROP;
 
-	if ((orig_node) && (orig_node->router)) {
+	if (!orig_node)
+		goto unlock;
 
-		/* don't lock while sending the packets ... we therefore
-		 * copy the required data before sending */
-		batman_if = orig_node->router->if_incoming;
-		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	kref_get(&orig_node->refcount);
+	neigh_node = orig_node->router;
 
-		/* create a copy of the skb, if needed, to modify it. */
-		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
-			return NET_RX_DROP;
+	if (!neigh_node)
+		goto unlock;
+
+	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+		neigh_node = NULL;
+		goto unlock;
+	}
 
-		icmp_packet = (struct icmp_packet *) skb->data;
+	rcu_read_unlock();
 
-		memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
-		memcpy(icmp_packet->orig,
-		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
-		icmp_packet->msg_type = TTL_EXCEEDED;
-		icmp_packet->ttl = TTL;
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if = orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
-		send_skb_packet(skb, batman_if, dstaddr);
-		ret = NET_RX_SUCCESS;
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+		goto out;
 
-	} else
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	icmp_packet = (struct icmp_packet *)skb->data;
+
+	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
+	memcpy(icmp_packet->orig,
+		bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	icmp_packet->msg_type = TTL_EXCEEDED;
+	icmp_packet->ttl = TTL;
+
+	send_skb_packet(skb, batman_if, dstaddr);
+	ret = NET_RX_SUCCESS;
+	goto out;
 
+unlock:
+	rcu_read_unlock();
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
 	return ret;
 }
 
@@ -992,11 +1047,12 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct icmp_packet_rr *icmp_packet;
 	struct ethhdr *ethhdr;
-	struct orig_node *orig_node;
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
 	struct batman_if *batman_if;
 	int hdr_size = sizeof(struct icmp_packet);
-	int ret;
 	uint8_t dstaddr[ETH_ALEN];
+	int ret = NET_RX_DROP;
 
 	/**
 	 * we truncate all incoming icmp packets if they don't match our size
@@ -1006,21 +1062,21 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 	/* drop packet if it has not necessary minimum size */
 	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		return NET_RX_DROP;
+		goto out;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with unicast indication but broadcast recipient */
 	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		return NET_RX_DROP;
+		goto out;
 
 	/* packet with broadcast sender address */
 	if (is_broadcast_ether_addr(ethhdr->h_source))
-		return NET_RX_DROP;
+		goto out;
 
 	/* not for me */
 	if (!is_my_mac(ethhdr->h_dest))
-		return NET_RX_DROP;
+		goto out;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
 
@@ -1040,40 +1096,56 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	if (icmp_packet->ttl < 2)
 		return recv_icmp_ttl_exceeded(bat_priv, skb);
 
-	ret = NET_RX_DROP;
-
 	/* get routing information */
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       icmp_packet->dst));
-	rcu_read_unlock();
+	if (!orig_node)
+		goto unlock;
 
-	if ((orig_node) && (orig_node->router)) {
+	kref_get(&orig_node->refcount);
+	neigh_node = orig_node->router;
 
-		/* don't lock while sending the packets ... we therefore
-		 * copy the required data before sending */
-		batman_if = orig_node->router->if_incoming;
-		memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	if (!neigh_node)
+		goto unlock;
 
-		/* create a copy of the skb, if needed, to modify it. */
-		if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
-			return NET_RX_DROP;
+	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+		neigh_node = NULL;
+		goto unlock;
+	}
+
+	rcu_read_unlock();
 
-		icmp_packet = (struct icmp_packet_rr *)skb->data;
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if = orig_node->router->if_incoming;
+	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
-		/* decrement ttl */
-		icmp_packet->ttl--;
+	/* create a copy of the skb, if needed, to modify it. */
+	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
+		goto out;
 
-		/* route it */
-		send_skb_packet(skb, batman_if, dstaddr);
-		ret = NET_RX_SUCCESS;
+	icmp_packet = (struct icmp_packet_rr *)skb->data;
 
-	} else
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	/* decrement ttl */
+	icmp_packet->ttl--;
 
+	/* route it */
+	send_skb_packet(skb, batman_if, dstaddr);
+	ret = NET_RX_SUCCESS;
+	goto out;
+
+unlock:
+	rcu_read_unlock();
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
 	return ret;
 }
 
@@ -1104,12 +1176,11 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	/* select default router to output */
 	router = orig_node->router;
 	router_orig = orig_node->router->orig_node;
-	if (!router_orig) {
+	if (!router_orig || !atomic_inc_not_zero(&router->refcount)) {
 		rcu_read_unlock();
 		return NULL;
 	}
 
-
 	if ((!recv_if) && (!bonding_enabled))
 		goto return_router;
 
@@ -1142,6 +1213,7 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 	 * is is not on the interface where the packet came
 	 * in. */
 
+	neigh_node_free_ref(router);
 	first_candidate = NULL;
 	router = NULL;
 
@@ -1154,16 +1226,23 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 			if (!first_candidate)
 				first_candidate = tmp_neigh_node;
 			/* recv_if == NULL on the first node. */
-			if (tmp_neigh_node->if_incoming != recv_if) {
+			if (tmp_neigh_node->if_incoming != recv_if &&
+			    atomic_inc_not_zero(&tmp_neigh_node->refcount)) {
 				router = tmp_neigh_node;
 				break;
 			}
 		}
 
 		/* use the first candidate if nothing was found. */
-		if (!router)
+		if (!router && first_candidate &&
+		    atomic_inc_not_zero(&first_candidate->refcount))
 			router = first_candidate;
 
+		if (!router) {
+			rcu_read_unlock();
+			return NULL;
+		}
+
 		/* selected should point to the next element
 		 * after the current router */
 		spin_lock_bh(&primary_orig_node->neigh_list_lock);
@@ -1184,21 +1263,34 @@ struct neigh_node *find_router(struct bat_priv *bat_priv,
 				first_candidate = tmp_neigh_node;
 
 			/* recv_if == NULL on the first node. */
-			if (tmp_neigh_node->if_incoming != recv_if)
-				/* if we don't have a router yet
-				 * or this one is better, choose it. */
-				if ((!router) ||
-				(tmp_neigh_node->tq_avg > router->tq_avg)) {
-					router = tmp_neigh_node;
-				}
+			if (tmp_neigh_node->if_incoming == recv_if)
+				continue;
+
+			if (!atomic_inc_not_zero(&tmp_neigh_node->refcount))
+				continue;
+
+			/* if we don't have a router yet
+			 * or this one is better, choose it. */
+			if ((!router) ||
+			    (tmp_neigh_node->tq_avg > router->tq_avg)) {
+				/* decrement refcount of
+				 * previously selected router */
+				if (router)
+					neigh_node_free_ref(router);
+
+				router = tmp_neigh_node;
+				atomic_inc_not_zero(&router->refcount);
+			}
+
+			neigh_node_free_ref(tmp_neigh_node);
 		}
 
 		/* use the first candidate if nothing was found. */
-		if (!router)
+		if (!router && first_candidate &&
+		    atomic_inc_not_zero(&first_candidate->refcount))
 			router = first_candidate;
 	}
 return_router:
-	kref_get(&router->refcount);
 	rcu_read_unlock();
 	return router;
 }
@@ -1232,13 +1324,13 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 			 int hdr_size)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	struct orig_node *orig_node;
-	struct neigh_node *router;
+	struct orig_node *orig_node = NULL;
+	struct neigh_node *neigh_node = NULL;
 	struct batman_if *batman_if;
 	uint8_t dstaddr[ETH_ALEN];
 	struct unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
-	int ret;
+	int ret = NET_RX_DROP;
 	struct sk_buff *new_skb;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
@@ -1248,7 +1340,7 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 		pr_debug("Warning - can't forward unicast packet from %pM to "
 			 "%pM: ttl exceeded\n", ethhdr->h_source,
 			 unicast_packet->dest);
-		return NET_RX_DROP;
+		goto out;
 	}
 
 	/* get routing information */
@@ -1257,27 +1349,29 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	orig_node = ((struct orig_node *)
 		     hash_find(bat_priv->orig_hash, compare_orig, choose_orig,
 			       unicast_packet->dest));
+	if (!orig_node)
+		goto unlock;
+
+	kref_get(&orig_node->refcount);
 	rcu_read_unlock();
 
 	/* find_router() increases neigh_nodes refcount if found. */
-	router = find_router(bat_priv, orig_node, recv_if);
+	neigh_node = find_router(bat_priv, orig_node, recv_if);
 
-	if (!router) {
+	if (!neigh_node) {
 		spin_unlock_bh(&bat_priv->orig_hash_lock);
-		return NET_RX_DROP;
+		goto out;
 	}
 
 	/* don't lock while sending the packets ... we therefore
 	 * copy the required data before sending */
-
-	batman_if = router->if_incoming;
-	memcpy(dstaddr, router->addr, ETH_ALEN);
-
+	batman_if = neigh_node->if_incoming;
+	memcpy(dstaddr, neigh_node->addr, ETH_ALEN);
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
-		return NET_RX_DROP;
+		goto out;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
@@ -1293,11 +1387,13 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
 
 		if (ret == NET_RX_DROP)
-			return NET_RX_DROP;
+			goto out;
 
 		/* packet was buffered for late merge */
-		if (!new_skb)
-			return NET_RX_SUCCESS;
+		if (!new_skb) {
+			ret = NET_RX_SUCCESS;
+			goto out;
+		}
 
 		skb = new_skb;
 		unicast_packet = (struct unicast_packet *)skb->data;
@@ -1308,8 +1404,18 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 
 	/* route it */
 	send_skb_packet(skb, batman_if, dstaddr);
+	ret = NET_RX_SUCCESS;
+	goto out;
 
-	return NET_RX_SUCCESS;
+unlock:
+	rcu_read_unlock();
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
+	return ret;
 }
 
 int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1f833f0..084604a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -117,9 +117,8 @@ struct neigh_node {
 	struct list_head bonding_list;
 	unsigned long last_valid;
 	unsigned long real_bits[NUM_WORDS];
-	struct kref refcount;
+	atomic_t refcount;
 	struct rcu_head rcu;
-	struct rcu_head rcu_bond;
 	struct orig_node *orig_node;
 	struct batman_if *if_incoming;
 };
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 00bfeaf..7ca994c 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -285,38 +285,42 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 	struct unicast_packet *unicast_packet;
 	struct orig_node *orig_node = NULL;
 	struct batman_if *batman_if;
-	struct neigh_node *router;
+	struct neigh_node *neigh_node;
 	int data_len = skb->len;
 	uint8_t dstaddr[6];
+	int ret = 1;
 
 	spin_lock_bh(&bat_priv->orig_hash_lock);
 
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest))
 		orig_node = (struct orig_node *)gw_get_selected(bat_priv);
+		if (orig_node) {
+			kref_get(&orig_node->refcount);
+			goto find_router;
+	}
 
-	/* check for hna host */
-	if (!orig_node)
-		orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+	/* check for hna host - increases orig_node refcount */
+	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 
+find_router:
 	/* find_router() increases neigh_nodes refcount if found. */
-	router = find_router(bat_priv, orig_node, NULL);
+	neigh_node = find_router(bat_priv, orig_node, NULL);
 
-	if (!router)
+	if (!neigh_node)
 		goto unlock;
 
-	/* don't lock while sending the packets ... we therefore
-		* copy the required data before sending */
-	batman_if = router->if_incoming;
-	memcpy(dstaddr, router->addr, ETH_ALEN);
-
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
-	if (batman_if->if_status != IF_ACTIVE)
-		goto dropped;
+	if (neigh_node->if_incoming->if_status != IF_ACTIVE)
+		goto unlock;
 
 	if (my_skb_head_push(skb, sizeof(struct unicast_packet)) < 0)
-		goto dropped;
+		goto unlock;
+
+	/* don't lock while sending the packets ... we therefore
+	 * copy the required data before sending */
+	batman_if = neigh_node->if_incoming;
+	memcpy(dstaddr, neigh_node->addr, ETH_ALEN);
+	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
@@ -330,18 +334,25 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 
 	if (atomic_read(&bat_priv->fragmentation) &&
 	    data_len + sizeof(struct unicast_packet) >
-	    batman_if->net_dev->mtu) {
+						batman_if->net_dev->mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->ttl++;
-		return frag_send_skb(skb, bat_priv, batman_if,
-				     dstaddr);
+		ret = frag_send_skb(skb, bat_priv, batman_if, dstaddr);
+		goto out;
 	}
+
 	send_skb_packet(skb, batman_if, dstaddr);
-	return 0;
+	ret = 0;
+	goto out;
 
 unlock:
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
-dropped:
-	kfree_skb(skb);
-	return 1;
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
+	if (ret == 1)
+		kfree_skb(skb);
+	return ret;
 }
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 8092ead..9832d8f 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -764,21 +764,35 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 			       struct vis_info *info)
 {
 	struct orig_node *orig_node;
+	struct neigh_node *neigh_node = NULL;
 	struct sk_buff *skb;
 	struct vis_packet *packet;
 	struct batman_if *batman_if;
 	uint8_t dstaddr[ETH_ALEN];
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	packet = (struct vis_packet *)info->skb_packet->data;
+
+	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = ((struct orig_node *)hash_find(bat_priv->orig_hash,
 						   compare_orig, choose_orig,
 						   packet->target_orig));
-	rcu_read_unlock();
 
-	if ((!orig_node) || (!orig_node->router))
-		goto out;
+	if (!orig_node)
+		goto unlock;
+
+	kref_get(&orig_node->refcount);
+	neigh_node = orig_node->router;
+
+	if (!neigh_node)
+		goto unlock;
+
+	if (!atomic_inc_not_zero(&neigh_node->refcount)) {
+		neigh_node = NULL;
+		goto unlock;
+	}
+
+	rcu_read_unlock();
 
 	/* don't lock while sending the packets ... we therefore
 	 * copy the required data before sending */
@@ -790,10 +804,17 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 	if (skb)
 		send_skb_packet(skb, batman_if, dstaddr);
 
-	return;
+	goto out;
 
-out:
+unlock:
+	rcu_read_unlock();
 	spin_unlock_bh(&bat_priv->orig_hash_lock);
+out:
+	if (neigh_node)
+		neigh_node_free_ref(neigh_node);
+	if (orig_node)
+		kref_put(&orig_node->refcount, orig_node_free_ref);
+	return;
 }
 
 /* only send one vis packet. called from send_vis_packets() */
-- 
1.7.2.3
