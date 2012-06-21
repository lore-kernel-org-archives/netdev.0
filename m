From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 14/20] batman-adv: Prefix send non-static
	functions with batadv_
Date: Thu, 21 Jun 2012 18:57:50 +0200
Message-ID: <1340297876-29923-15-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c        |    9 +++++----
 net/batman-adv/hard-interface.c    |    4 ++--
 net/batman-adv/icmp_socket.c       |    2 +-
 net/batman-adv/main.c              |    2 +-
 net/batman-adv/routing.c           |   10 +++++-----
 net/batman-adv/send.c              |   22 ++++++++++++----------
 net/batman-adv/send.h              |   17 +++++++++--------
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/translation-table.c |    8 ++++----
 net/batman-adv/unicast.c           |    6 +++---
 net/batman-adv/vis.c               |    5 +++--
 11 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f48467f..1566eac 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -201,7 +201,7 @@ static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
 		batadv_inc_counter(bat_priv, BAT_CNT_MGMT_TX);
 		batadv_add_counter(bat_priv, BAT_CNT_MGMT_TX_BYTES,
 				   skb->len + ETH_HLEN);
-		send_skb_packet(skb, hard_iface, broadcast_addr);
+		batadv_send_skb_packet(skb, hard_iface, broadcast_addr);
 	}
 }
 
@@ -250,8 +250,9 @@ static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 			forw_packet->if_incoming->net_dev->dev_addr);
 
 		/* skb is only used once and than forw_packet is free'd */
-		send_skb_packet(forw_packet->skb, forw_packet->if_incoming,
-				broadcast_addr);
+		batadv_send_skb_packet(forw_packet->skb,
+				       forw_packet->if_incoming,
+				       broadcast_addr);
 		forw_packet->skb = NULL;
 
 		goto out;
@@ -420,7 +421,7 @@ static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	/* start timer for this packet */
 	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
-			  send_outstanding_bat_ogm_packet);
+			  batadv_send_outstanding_bat_ogm_packet);
 	queue_delayed_work(bat_event_workqueue,
 			   &forw_packet_aggr->delayed_work,
 			   send_time - jiffies);
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 1f126cb..7392ae2 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -345,7 +345,7 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 			hard_iface->net_dev->name);
 
 	/* begin scheduling originator messages on that interface */
-	schedule_bat_ogm(hard_iface);
+	batadv_schedule_bat_ogm(hard_iface);
 
 out:
 	return 0;
@@ -391,7 +391,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 
 	/* delete all references to this hard_iface */
 	batadv_purge_orig_ref(bat_priv);
-	purge_outstanding_packets(bat_priv, hard_iface);
+	batadv_purge_outstanding_packets(bat_priv, hard_iface);
 	dev_put(hard_iface->soft_iface);
 
 	/* nobody uses this interface anymore */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 44cbee5..21c0010 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -236,7 +236,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		memcpy(icmp_packet->rr,
 		       neigh_node->if_incoming->net_dev->dev_addr, ETH_ALEN);
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	goto out;
 
 dst_unreach:
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 92f39b5..b9531a1 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -145,7 +145,7 @@ void mesh_free(struct net_device *soft_iface)
 
 	atomic_set(&bat_priv->mesh_state, MESH_DEACTIVATING);
 
-	purge_outstanding_packets(bat_priv, NULL);
+	batadv_purge_outstanding_packets(bat_priv, NULL);
 
 	vis_quit(bat_priv);
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 631b40b..d7d05b2 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -319,7 +319,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	icmp_packet->msg_type = ECHO_REPLY;
 	icmp_packet->header.ttl = TTL;
 
-	send_skb_packet(skb, router->if_incoming, router->addr);
+	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
 	ret = NET_RX_SUCCESS;
 
 out:
@@ -374,7 +374,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	icmp_packet->msg_type = TTL_EXCEEDED;
 	icmp_packet->header.ttl = TTL;
 
-	send_skb_packet(skb, router->if_incoming, router->addr);
+	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
 	ret = NET_RX_SUCCESS;
 
 out:
@@ -459,7 +459,7 @@ int batadv_recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	icmp_packet->header.ttl--;
 
 	/* route it */
-	send_skb_packet(skb, router->if_incoming, router->addr);
+	batadv_send_skb_packet(skb, router->if_incoming, router->addr);
 	ret = NET_RX_SUCCESS;
 
 out:
@@ -881,7 +881,7 @@ static int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 			   skb->len + ETH_HLEN);
 
 	/* route it */
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = NET_RX_SUCCESS;
 
 out:
@@ -1095,7 +1095,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* rebroadcast packet */
-	add_bcast_packet_to_list(bat_priv, skb, 1);
+	batadv_add_bcast_packet_to_list(bat_priv, skb, 1);
 
 	/* don't hand the broadcast up if it is from an originator
 	 * from the same backbone.
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 79f8973..bceb3d7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -33,8 +33,8 @@ static void send_outstanding_bcast_packet(struct work_struct *work);
 
 /* send out an already prepared packet to the given address via the
  * specified batman interface */
-int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
-		    const uint8_t *dst_addr)
+int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
+			   const uint8_t *dst_addr)
 {
 	struct ethhdr *ethhdr;
 
@@ -77,7 +77,7 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
 
-void schedule_bat_ogm(struct hard_iface *hard_iface)
+void batadv_schedule_bat_ogm(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 
@@ -133,8 +133,9 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
  *
  * The skb is not consumed, so the caller should make sure that the
  * skb is freed. */
-int add_bcast_packet_to_list(struct bat_priv *bat_priv,
-			     const struct sk_buff *skb, unsigned long delay)
+int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
+				    const struct sk_buff *skb,
+				    unsigned long delay)
 {
 	struct hard_iface *primary_if = NULL;
 	struct forw_packet *forw_packet;
@@ -211,7 +212,8 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 		/* send a copy of the saved skb */
 		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
 		if (skb1)
-			send_skb_packet(skb1, hard_iface, broadcast_addr);
+			batadv_send_skb_packet(skb1, hard_iface,
+					       broadcast_addr);
 	}
 	rcu_read_unlock();
 
@@ -229,7 +231,7 @@ out:
 	atomic_inc(&bat_priv->bcast_queue_left);
 }
 
-void send_outstanding_bat_ogm_packet(struct work_struct *work)
+void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
@@ -253,7 +255,7 @@ void send_outstanding_bat_ogm_packet(struct work_struct *work)
 	 * shutting down
 	 */
 	if (forw_packet->own)
-		schedule_bat_ogm(forw_packet->if_incoming);
+		batadv_schedule_bat_ogm(forw_packet->if_incoming);
 
 out:
 	/* don't count own packet */
@@ -263,8 +265,8 @@ out:
 	forw_packet_free(forw_packet);
 }
 
-void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       const struct hard_iface *hard_iface)
+void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
+				      const struct hard_iface *hard_iface)
 {
 	struct forw_packet *forw_packet;
 	struct hlist_node *tmp_node, *safe_tmp_node;
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 824ef06..452e8df 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -22,13 +22,14 @@
 #ifndef _NET_BATMAN_ADV_SEND_H_
 #define _NET_BATMAN_ADV_SEND_H_
 
-int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
-		    const uint8_t *dst_addr);
-void schedule_bat_ogm(struct hard_iface *hard_iface);
-int add_bcast_packet_to_list(struct bat_priv *bat_priv,
-			     const struct sk_buff *skb, unsigned long delay);
-void send_outstanding_bat_ogm_packet(struct work_struct *work);
-void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       const struct hard_iface *hard_iface);
+int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
+			   const uint8_t *dst_addr);
+void batadv_schedule_bat_ogm(struct hard_iface *hard_iface);
+int batadv_add_bcast_packet_to_list(struct bat_priv *bat_priv,
+				    const struct sk_buff *skb,
+				    unsigned long delay);
+void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work);
+void batadv_purge_outstanding_packets(struct bat_priv *bat_priv,
+				      const struct hard_iface *hard_iface);
 
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5bf9a73..e15d474 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -223,7 +223,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		bcast_packet->seqno =
 			htonl(atomic_inc_return(&bat_priv->bcast_seqno));
 
-		add_bcast_packet_to_list(bat_priv, skb, 1);
+		batadv_add_bcast_packet_to_list(bat_priv, skb, 1);
 
 		/* a copy is stored in the bcast list, therefore removing
 		 * the original skb. */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 3d2c3b1..445dc25 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1406,7 +1406,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_REQUEST_TX);
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = 0;
 
 out:
@@ -1532,7 +1532,7 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_RESPONSE_TX);
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = true;
 	goto out;
 
@@ -1650,7 +1650,7 @@ static bool send_my_tt_response(struct bat_priv *bat_priv,
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_RESPONSE_TX);
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = true;
 	goto out;
 
@@ -1957,7 +1957,7 @@ static void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 
 	batadv_inc_counter(bat_priv, BAT_CNT_TT_ROAM_ADV_TX);
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = 0;
 
 out:
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 894c6a4..6bb3bb9 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -268,8 +268,8 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	frag1->seqno = htons(seqno - 1);
 	frag2->seqno = htons(seqno);
 
-	send_skb_packet(skb, hard_iface, dstaddr);
-	send_skb_packet(frag_skb, hard_iface, dstaddr);
+	batadv_send_skb_packet(skb, hard_iface, dstaddr);
+	batadv_send_skb_packet(frag_skb, hard_iface, dstaddr);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
@@ -348,7 +348,7 @@ find_router:
 		goto out;
 	}
 
-	send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
 	ret = 0;
 	goto out;
 
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 1972a11..c56737c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -777,7 +777,8 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 
 			skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 			if (skb)
-				send_skb_packet(skb, hard_iface, dstaddr);
+				batadv_send_skb_packet(skb, hard_iface,
+						       dstaddr);
 
 		}
 		rcu_read_unlock();
@@ -804,7 +805,7 @@ static void unicast_vis_packet(struct bat_priv *bat_priv,
 
 	skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 	if (skb)
-		send_skb_packet(skb, router->if_incoming, router->addr);
+		batadv_send_skb_packet(skb, router->if_incoming, router->addr);
 
 out:
 	if (router)
-- 
1.7.9.4
