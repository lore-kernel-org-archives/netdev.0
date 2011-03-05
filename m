From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 24/28] batman-adv: remove orig_hash spinlock
Date: Sat,  5 Mar 2011 13:28:38 +0100
Message-ID: <1299328122-21468-25-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36351 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753374Ab1CEMaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:20 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/icmp_socket.c |   16 ++-------
 net/batman-adv/main.c        |    1 -
 net/batman-adv/originator.c  |   21 ------------
 net/batman-adv/routing.c     |   75 +++++++-----------------------------------
 net/batman-adv/types.h       |    1 -
 net/batman-adv/unicast.c     |   36 +++++++-------------
 net/batman-adv/vis.c         |   36 +++++---------------
 7 files changed, 38 insertions(+), 148 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index a0a35b1..34ce56c 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -158,9 +158,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
-	struct batman_if *batman_if;
 	size_t packet_len = sizeof(struct icmp_packet);
-	uint8_t dstaddr[ETH_ALEN];
 
 	if (len < sizeof(struct icmp_packet)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -220,7 +218,6 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
 		goto dst_unreach;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
 
@@ -239,14 +236,10 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	rcu_read_unlock();
 
-	batman_if = orig_node->router->if_incoming;
-	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
-	if (!batman_if)
+	if (!neigh_node->if_incoming)
 		goto dst_unreach;
 
-	if (batman_if->if_status != IF_ACTIVE)
+	if (neigh_node->if_incoming->if_status != IF_ACTIVE)
 		goto dst_unreach;
 
 	memcpy(icmp_packet->orig,
@@ -254,14 +247,13 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 	if (packet_len == sizeof(struct icmp_packet_rr))
 		memcpy(icmp_packet->rr,
-		       batman_if->net_dev->dev_addr, ETH_ALEN);
+		       neigh_node->if_incoming->net_dev->dev_addr, ETH_ALEN);
 
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 dst_unreach:
 	icmp_packet->msg_type = DESTINATION_UNREACHABLE;
 	bat_socket_add_packet(socket_client, icmp_packet, packet_len);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 3f977ea..09c21f2 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -79,7 +79,6 @@ int mesh_init(struct net_device *soft_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 
-	spin_lock_init(&bat_priv->orig_hash_lock);
 	spin_lock_init(&bat_priv->forw_bat_list_lock);
 	spin_lock_init(&bat_priv->forw_bcast_list_lock);
 	spin_lock_init(&bat_priv->hna_lhash_lock);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 69e27a24..a8d0262 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -44,18 +44,15 @@ int originator_init(struct bat_priv *bat_priv)
 	if (bat_priv->orig_hash)
 		return 1;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	bat_priv->orig_hash = hash_new(1024);
 
 	if (!bat_priv->orig_hash)
 		goto err;
 
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	start_purge_timer(bat_priv);
 	return 1;
 
 err:
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return 0;
 }
 
@@ -159,7 +156,6 @@ void originator_free(struct bat_priv *bat_priv)
 
 	cancel_delayed_work_sync(&bat_priv->orig_work);
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	bat_priv->orig_hash = NULL;
 
 	for (i = 0; i < hash->size; i++) {
@@ -177,7 +173,6 @@ void originator_free(struct bat_priv *bat_priv)
 	}
 
 	hash_destroy(hash);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 }
 
 /* this function finds or creates an originator entry for the given
@@ -342,8 +337,6 @@ static void _purge_orig(struct bat_priv *bat_priv)
 	if (!hash)
 		return;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	/* for all origins... */
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -367,8 +360,6 @@ static void _purge_orig(struct bat_priv *bat_priv)
 		spin_unlock_bh(list_lock);
 	}
 
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	gw_node_purge(bat_priv);
 	gw_election(bat_priv);
 
@@ -425,8 +416,6 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 		   "Originator", "last-seen", "#", TQ_MAX_VALUE, "Nexthop",
 		   "outgoingIF", "Potential nexthops");
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -462,8 +451,6 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	if ((batman_count == 0))
 		seq_printf(seq, "No batman nodes in range ...\n");
 
@@ -511,8 +498,6 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
 	 * if_num */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -528,12 +513,10 @@ int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return 0;
 
 err:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return -ENOMEM;
 }
 
@@ -601,8 +584,6 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 
 	/* resize all orig nodes because orig_node->bcast_own(_sum) depend on
 	 * if_num */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -637,11 +618,9 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 	rcu_read_unlock();
 
 	batman_if->if_num = -1;
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return 0;
 
 err:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	return -ENOMEM;
 }
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c4b7ae9..3cfa2c7 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -46,8 +46,6 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 	int i;
 	size_t word_index;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 
@@ -64,8 +62,6 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 		}
 		rcu_read_unlock();
 	}
-
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 }
 
 static void update_HNA(struct bat_priv *bat_priv, struct orig_node *orig_node,
@@ -771,7 +767,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 			   orig_node :
 			   get_orig_node(bat_priv, ethhdr->h_source));
 	if (!orig_neigh_node)
-		goto out_neigh;
+		goto out;
 
 	/* drop packet if sender is not a direct neighbor and if we
 	 * don't route towards it */
@@ -834,7 +830,6 @@ out:
 
 int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
@@ -861,12 +856,10 @@ int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	receive_aggr_bat_packet(ethhdr,
 				skb->data,
 				skb_headlen(skb),
 				batman_if);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
@@ -878,8 +871,6 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
 	struct icmp_packet_rr *icmp_packet;
-	struct batman_if *batman_if;
-	uint8_t dstaddr[ETH_ALEN];
 	int ret = NET_RX_DROP;
 
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
@@ -895,7 +886,6 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 
 	/* answer echo request (ping) */
 	/* get routing information */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
 
@@ -914,12 +904,6 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 
 	rcu_read_unlock();
 
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = orig_node->router->if_incoming;
-	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
 		goto out;
@@ -932,13 +916,12 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	icmp_packet->msg_type = ECHO_REPLY;
 	icmp_packet->ttl = TTL;
 
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -953,8 +936,6 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
 	struct icmp_packet *icmp_packet;
-	struct batman_if *batman_if;
-	uint8_t dstaddr[ETH_ALEN];
 	int ret = NET_RX_DROP;
 
 	icmp_packet = (struct icmp_packet *)skb->data;
@@ -971,7 +952,6 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		goto out;
 
 	/* get routing information */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, icmp_packet->orig);
 
@@ -990,12 +970,6 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 
 	rcu_read_unlock();
 
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = orig_node->router->if_incoming;
-	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
 		goto out;
@@ -1008,13 +982,12 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	icmp_packet->msg_type = TTL_EXCEEDED;
 	icmp_packet->ttl = TTL;
 
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -1031,9 +1004,7 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	struct ethhdr *ethhdr;
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
-	struct batman_if *batman_if;
 	int hdr_size = sizeof(struct icmp_packet);
-	uint8_t dstaddr[ETH_ALEN];
 	int ret = NET_RX_DROP;
 
 	/**
@@ -1079,7 +1050,6 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 		return recv_icmp_ttl_exceeded(bat_priv, skb);
 
 	/* get routing information */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, icmp_packet->dst);
 
@@ -1098,12 +1068,6 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 	rcu_read_unlock();
 
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = orig_node->router->if_incoming;
-	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
 		goto out;
@@ -1114,13 +1078,12 @@ int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	icmp_packet->ttl--;
 
 	/* route it */
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -1306,8 +1269,6 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *neigh_node = NULL;
-	struct batman_if *batman_if;
-	uint8_t dstaddr[ETH_ALEN];
 	struct unicast_packet *unicast_packet;
 	struct ethhdr *ethhdr = (struct ethhdr *)skb_mac_header(skb);
 	int ret = NET_RX_DROP;
@@ -1324,7 +1285,6 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	}
 
 	/* get routing information */
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, unicast_packet->dest);
 
@@ -1336,16 +1296,8 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	/* find_router() increases neigh_nodes refcount if found. */
 	neigh_node = find_router(bat_priv, orig_node, recv_if);
 
-	if (!neigh_node) {
-		spin_unlock_bh(&bat_priv->orig_hash_lock);
+	if (!neigh_node)
 		goto out;
-	}
-
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = neigh_node->if_incoming;
-	memcpy(dstaddr, neigh_node->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, sizeof(struct ethhdr)) < 0)
@@ -1355,12 +1307,14 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 
 	if (unicast_packet->packet_type == BAT_UNICAST &&
 	    atomic_read(&bat_priv->fragmentation) &&
-	    skb->len > batman_if->net_dev->mtu)
-		return frag_send_skb(skb, bat_priv, batman_if,
-				     dstaddr);
+	    skb->len > neigh_node->if_incoming->net_dev->mtu) {
+		ret = frag_send_skb(skb, bat_priv,
+				    neigh_node->if_incoming, neigh_node->addr);
+		goto out;
+	}
 
 	if (unicast_packet->packet_type == BAT_UNICAST_FRAG &&
-	    frag_can_reassemble(skb, batman_if->net_dev->mtu)) {
+	    frag_can_reassemble(skb, neigh_node->if_incoming->net_dev->mtu)) {
 
 		ret = frag_reassemble_skb(skb, bat_priv, &new_skb);
 
@@ -1381,13 +1335,12 @@ int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
 	unicast_packet->ttl--;
 
 	/* route it */
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
@@ -1486,7 +1439,6 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	if (bcast_packet->ttl < 2)
 		goto out;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, bcast_packet->orig);
 
@@ -1515,7 +1467,6 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 		orig_node->last_bcast_seqno = ntohl(bcast_packet->seqno);
 
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 	/* rebroadcast packet */
 	add_bcast_packet_to_list(bat_priv, skb);
@@ -1527,11 +1478,9 @@ int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 
 rcu_unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 	goto out;
 spin_unlock:
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (orig_node)
 		orig_node_free_ref(orig_node);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1be76fe..a9bf186 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -159,7 +159,6 @@ struct bat_priv {
 	struct hashtable_t *hna_local_hash;
 	struct hashtable_t *hna_global_hash;
 	struct hashtable_t *vis_hash;
-	spinlock_t orig_hash_lock; /* protects orig_hash */
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t hna_lhash_lock; /* protects hna_local_hash */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 2ab8198..b411438 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -179,10 +179,9 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 	*new_skb = NULL;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	orig_node = orig_hash_find(bat_priv, unicast_packet->orig);
 	if (!orig_node)
-		goto unlock;
+		goto out;
 
 	orig_node->last_frag_packet = jiffies;
 
@@ -207,8 +206,6 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	if (*new_skb)
 		ret = NET_RX_SUCCESS;
 
-unlock:
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (orig_node)
 		orig_node_free_ref(orig_node);
@@ -281,14 +278,10 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct unicast_packet *unicast_packet;
 	struct orig_node *orig_node;
-	struct batman_if *batman_if;
 	struct neigh_node *neigh_node;
 	int data_len = skb->len;
-	uint8_t dstaddr[6];
 	int ret = 1;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
-
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		orig_node = (struct orig_node *)gw_get_selected(bat_priv);
@@ -300,23 +293,21 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 
 find_router:
-	/* find_router() increases neigh_nodes refcount if found. */
+	/**
+	 * find_router():
+	 *  - if orig_node is NULL it returns NULL
+	 *  - increases neigh_nodes refcount if found.
+	 */
 	neigh_node = find_router(bat_priv, orig_node, NULL);
 
 	if (!neigh_node)
-		goto unlock;
+		goto out;
 
 	if (neigh_node->if_incoming->if_status != IF_ACTIVE)
-		goto unlock;
+		goto out;
 
 	if (my_skb_head_push(skb, sizeof(struct unicast_packet)) < 0)
-		goto unlock;
-
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = neigh_node->if_incoming;
-	memcpy(dstaddr, neigh_node->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
+		goto out;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
 
@@ -330,19 +321,18 @@ find_router:
 
 	if (atomic_read(&bat_priv->fragmentation) &&
 	    data_len + sizeof(struct unicast_packet) >
-						batman_if->net_dev->mtu) {
+				neigh_node->if_incoming->net_dev->mtu) {
 		/* send frag skb decreases ttl */
 		unicast_packet->ttl++;
-		ret = frag_send_skb(skb, bat_priv, batman_if, dstaddr);
+		ret = frag_send_skb(skb, bat_priv,
+				    neigh_node->if_incoming, neigh_node->addr);
 		goto out;
 	}
 
-	send_skb_packet(skb, batman_if, dstaddr);
+	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = 0;
 	goto out;
 
-unlock:
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 8972242..e8911cb 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -614,7 +614,6 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	info->first_seen = jiffies;
 	packet->vis_type = atomic_read(&bat_priv->vis_mode);
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	memcpy(packet->target_orig, broadcast_addr, ETH_ALEN);
 	packet->ttl = TTL;
 	packet->seqno = htonl(ntohl(packet->seqno) + 1);
@@ -624,10 +623,8 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	if (packet->vis_type == VIS_TYPE_CLIENT_UPDATE) {
 		best_tq = find_best_vis_server(bat_priv, info);
 
-		if (best_tq < 0) {
-			spin_unlock_bh(&bat_priv->orig_hash_lock);
+		if (best_tq < 0)
 			return -1;
-		}
 	}
 
 	for (i = 0; i < hash->size; i++) {
@@ -659,17 +656,12 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 			entry->quality = neigh_node->tq_avg;
 			packet->entries++;
 
-			if (vis_packet_full(info)) {
-				rcu_read_unlock();
-				spin_unlock_bh(&bat_priv->orig_hash_lock);
-				return 0;
-			}
+			if (vis_packet_full(info))
+				goto unlock;
 		}
 		rcu_read_unlock();
 	}
 
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	hash = bat_priv->hna_local_hash;
 
 	spin_lock_bh(&bat_priv->hna_lhash_lock);
@@ -694,6 +686,10 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 
 	spin_unlock_bh(&bat_priv->hna_lhash_lock);
 	return 0;
+
+unlock:
+	rcu_read_unlock();
+	return 0;
 }
 
 /* free old vis packets. Must be called with this vis_hash_lock
@@ -739,7 +735,6 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 	int i;
 
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	packet = (struct vis_packet *)info->skb_packet->data;
 
 	/* send to all routers in range. */
@@ -762,18 +757,14 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
 			batman_if = orig_node->router->if_incoming;
 			memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-			spin_unlock_bh(&bat_priv->orig_hash_lock);
 
 			skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 			if (skb)
 				send_skb_packet(skb, batman_if, dstaddr);
 
-			spin_lock_bh(&bat_priv->orig_hash_lock);
 		}
 		rcu_read_unlock();
 	}
-
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 }
 
 static void unicast_vis_packet(struct bat_priv *bat_priv,
@@ -783,12 +774,9 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 	struct neigh_node *neigh_node = NULL;
 	struct sk_buff *skb;
 	struct vis_packet *packet;
-	struct batman_if *batman_if;
-	uint8_t dstaddr[ETH_ALEN];
 
 	packet = (struct vis_packet *)info->skb_packet->data;
 
-	spin_lock_bh(&bat_priv->orig_hash_lock);
 	rcu_read_lock();
 	orig_node = orig_hash_find(bat_priv, packet->target_orig);
 
@@ -807,21 +795,15 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 	rcu_read_unlock();
 
-	/* don't lock while sending the packets ... we therefore
-	 * copy the required data before sending */
-	batman_if = orig_node->router->if_incoming;
-	memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
-
 	skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 	if (skb)
-		send_skb_packet(skb, batman_if, dstaddr);
+		send_skb_packet(skb, neigh_node->if_incoming,
+				neigh_node->addr);
 
 	goto out;
 
 unlock:
 	rcu_read_unlock();
-	spin_unlock_bh(&bat_priv->orig_hash_lock);
 out:
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
-- 
1.7.2.3

