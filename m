From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 08/15] batman-adv: keep track of when unicast packets are sent
Date: Mon, 29 Feb 2016 19:06:01 +0800
Message-ID: <1456743968-17562-9-git-send-email-a@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:43136 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754044AbcB2LIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:54 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

To enable ELP to send probing packets over wireless links
only if needed, batman-adv must keep track of the last time
it sent a unicast packet towards every neighbour.

For this purpose a 2 main changes are introduced:
1) a new member of the elp_neigh_node structure stores the
   last time a unicast packet was sent towards this neighbour;
2) a wrapper function for sending unicast packets is
   implemented. This function will simply update the member
   describe din point 1) and then forward the packet to the
   real sending routine.

Point 2) implies that any code-path leading to a unicast
sending now has to use the new wrapper.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c            |  2 +-
 net/batman-adv/bat_v_elp.c             |  2 +-
 net/batman-adv/bat_v_ogm.c             |  2 +-
 net/batman-adv/distributed-arp-table.c |  4 +--
 net/batman-adv/fragmentation.c         |  8 ++---
 net/batman-adv/icmp_socket.c           |  2 +-
 net/batman-adv/network-coding.c        | 22 +++++++-------
 net/batman-adv/send.c                  | 55 +++++++++++++++++++++++++++++-----
 net/batman-adv/send.h                  | 10 +++++--
 net/batman-adv/types.h                 |  2 ++
 10 files changed, 75 insertions(+), 34 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5651e33ca6bd..cb2d1b9b0340 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -478,7 +478,7 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 		batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_TX);
 		batadv_add_counter(bat_priv, BATADV_CNT_MGMT_TX_BYTES,
 				   skb->len + ETH_HLEN);
-		batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
+		batadv_send_broadcast_skb(skb, hard_iface);
 	}
 }
 
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index fac5aee7ce05..1e4d13cc267f 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -104,7 +104,7 @@ static void batadv_v_elp_periodic_work(struct work_struct *work)
 		   hard_iface->net_dev->name,
 		   atomic_read(&hard_iface->bat_v.elp_seqno));
 
-	batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
+	batadv_send_broadcast_skb(skb, hard_iface);
 
 	atomic_inc(&hard_iface->bat_v.elp_seqno);
 
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 22dda0e079a5..c8000962a266 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -120,7 +120,7 @@ static void batadv_v_ogm_send_to_if(struct sk_buff *skb,
 	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_TX_BYTES,
 			   skb->len + ETH_HLEN);
 
-	batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
+	batadv_send_broadcast_skb(skb, hard_iface);
 }
 
 /**
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 4c9b69d465a6..e96d7c745b4a 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -654,9 +654,7 @@ static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
 			goto free_neigh;
 		}
 
-		send_status = batadv_send_skb_packet(tmp_skb,
-						     neigh_node->if_incoming,
-						     neigh_node->addr);
+		send_status = batadv_send_unicast_skb(tmp_skb, neigh_node);
 		if (send_status == NET_XMIT_SUCCESS) {
 			/* count the sent packet */
 			switch (packet_subtype) {
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index adb9c3989add..e6956d0746a2 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -378,8 +378,7 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
 				   skb->len + ETH_HLEN);
 
 		packet->ttl--;
-		batadv_send_skb_packet(skb, neigh_node->if_incoming,
-				       neigh_node->addr);
+		batadv_send_unicast_skb(skb, neigh_node);
 		ret = true;
 	}
 
@@ -486,8 +485,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 		batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
 		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 				   skb_fragment->len + ETH_HLEN);
-		batadv_send_skb_packet(skb_fragment, neigh_node->if_incoming,
-				       neigh_node->addr);
+		batadv_send_unicast_skb(skb_fragment, neigh_node);
 		frag_header.no++;
 
 		/* The initial check in this function should cover this case */
@@ -506,7 +504,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_TX);
 	batadv_add_counter(bat_priv, BATADV_CNT_FRAG_TX_BYTES,
 			   skb->len + ETH_HLEN);
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_unicast_skb(skb, neigh_node);
 
 	ret = true;
 
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 6268f08b7154..14d0013b387e 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -278,7 +278,7 @@ static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
 
 	ether_addr_copy(icmp_header->orig, primary_if->net_dev->dev_addr);
 
-	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr);
+	batadv_send_unicast_skb(skb, neigh_node);
 	goto out;
 
 dst_unreach:
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index d253bb23e2ac..b41719b6487a 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -575,9 +575,7 @@ batadv_nc_hash_find(struct batadv_hashtable *hash,
  */
 static void batadv_nc_send_packet(struct batadv_nc_packet *nc_packet)
 {
-	batadv_send_skb_packet(nc_packet->skb,
-			       nc_packet->neigh_node->if_incoming,
-			       nc_packet->nc_path->next_hop);
+	batadv_send_unicast_skb(nc_packet->skb, nc_packet->neigh_node);
 	nc_packet->skb = NULL;
 	batadv_nc_packet_free(nc_packet);
 }
@@ -1067,11 +1065,11 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	struct batadv_unicast_packet *packet1;
 	struct batadv_unicast_packet *packet2;
 	struct batadv_coded_packet *coded_packet;
-	struct batadv_neigh_node *neigh_tmp, *router_neigh;
-	struct batadv_neigh_node *router_coding = NULL;
+	struct batadv_neigh_node *neigh_tmp, *router_neigh, *first_dest;
+	struct batadv_neigh_node *router_coding = NULL, *second_dest;
 	struct batadv_neigh_ifinfo *router_neigh_ifinfo = NULL;
 	struct batadv_neigh_ifinfo *router_coding_ifinfo = NULL;
-	u8 *first_source, *first_dest, *second_source, *second_dest;
+	u8 *first_source, *second_source;
 	__be32 packet_id1, packet_id2;
 	size_t count;
 	bool res = false;
@@ -1114,9 +1112,9 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	 */
 	if (tq_weighted_neigh >= tq_weighted_coding) {
 		/* Destination from nc_packet is selected for MAC-header */
-		first_dest = nc_packet->nc_path->next_hop;
+		first_dest = nc_packet->neigh_node;
 		first_source = nc_packet->nc_path->prev_hop;
-		second_dest = neigh_node->addr;
+		second_dest = neigh_node;
 		second_source = ethhdr->h_source;
 		packet1 = (struct batadv_unicast_packet *)nc_packet->skb->data;
 		packet2 = (struct batadv_unicast_packet *)skb->data;
@@ -1125,9 +1123,9 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 					      skb->data + sizeof(*packet2));
 	} else {
 		/* Destination for skb is selected for MAC-header */
-		first_dest = neigh_node->addr;
+		first_dest = neigh_node;
 		first_source = ethhdr->h_source;
-		second_dest = nc_packet->nc_path->next_hop;
+		second_dest = nc_packet->neigh_node;
 		second_source = nc_packet->nc_path->prev_hop;
 		packet1 = (struct batadv_unicast_packet *)skb->data;
 		packet2 = (struct batadv_unicast_packet *)nc_packet->skb->data;
@@ -1169,7 +1167,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	coded_packet->first_ttvn = packet1->ttvn;
 
 	/* Info about second unicast packet */
-	ether_addr_copy(coded_packet->second_dest, second_dest);
+	ether_addr_copy(coded_packet->second_dest, second_dest->addr);
 	ether_addr_copy(coded_packet->second_source, second_source);
 	ether_addr_copy(coded_packet->second_orig_dest, packet2->dest);
 	coded_packet->second_crc = packet_id2;
@@ -1224,7 +1222,7 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	batadv_nc_packet_free(nc_packet);
 
 	/* Send the coded packet and return true */
-	batadv_send_skb_packet(skb_dest, neigh_node->if_incoming, first_dest);
+	batadv_send_unicast_skb(skb_dest, first_dest);
 	res = true;
 out:
 	if (router_neigh)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index caff32cf6fe7..3ce06e0a91b1 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -49,16 +49,30 @@
 
 static void batadv_send_outstanding_bcast_packet(struct work_struct *work);
 
-/* send out an already prepared packet to the given address via the
- * specified batman interface
+/**
+ * batadv_send_skb_packet - send an already prepared packet
+ * @skb: the packet to send
+ * @hard_iface: the interface to use to send the broadcast packet
+ * @dst_addr: the payload destination
+ *
+ * Send out an already prepared packet to the given neighbor or broadcast it
+ * using the specified interface. Either hard_iface or neigh_node must be not
+ * NULL.
+ * If neigh_node is NULL, then the packet is broadcasted using hard_iface,
+ * otherwise it is sent as unicast to the given neighbor.
+ *
+ * Return: NET_TX_DROP in case of error or the result of dev_queue_xmit(skb)
+ * otherwise
  */
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
 			   const u8 *dst_addr)
 {
-	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct batadv_priv *bat_priv;
 	struct ethhdr *ethhdr;
 
+	bat_priv = netdev_priv(hard_iface->soft_iface);
+
 	if (hard_iface->if_status != BATADV_IF_ACTIVE)
 		goto send_skb_err;
 
@@ -100,6 +114,35 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
 
+int batadv_send_broadcast_skb(struct sk_buff *skb,
+			      struct batadv_hard_iface *hard_iface)
+{
+	return batadv_send_skb_packet(skb, hard_iface, batadv_broadcast_addr);
+}
+
+int batadv_send_unicast_skb(struct sk_buff *skb,
+			    struct batadv_neigh_node *neigh)
+{
+#ifdef CONFIG_BATMAN_ADV_BATMAN_V
+	struct batadv_hardif_neigh_node *hardif_neigh;
+#endif
+	int ret;
+
+	ret = batadv_send_skb_packet(skb, neigh->if_incoming, neigh->addr);
+
+#ifdef CONFIG_BATMAN_ADV_BATMAN_V
+	hardif_neigh = batadv_hardif_neigh_get(neigh->if_incoming, neigh->addr);
+
+	if ((hardif_neigh) && (ret != NET_XMIT_DROP))
+		hardif_neigh->bat_v.last_unicast_tx = jiffies;
+
+	if (hardif_neigh)
+		batadv_hardif_neigh_put(hardif_neigh);
+#endif
+
+	return ret;
+}
+
 /**
  * batadv_send_skb_to_orig - Lookup next-hop and transmit skb.
  * @skb: Packet to be transmitted.
@@ -146,8 +189,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	if (recv_if && batadv_nc_skb_forward(skb, neigh_node)) {
 		ret = NET_XMIT_POLICED;
 	} else {
-		batadv_send_skb_packet(skb, neigh_node->if_incoming,
-				       neigh_node->addr);
+		batadv_send_unicast_skb(skb, neigh_node);
 		ret = NET_XMIT_SUCCESS;
 	}
 
@@ -538,8 +580,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 		/* send a copy of the saved skb */
 		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
 		if (skb1)
-			batadv_send_skb_packet(skb1, hard_iface,
-					       batadv_broadcast_addr);
+			batadv_send_broadcast_skb(skb1, hard_iface);
 	}
 	rcu_read_unlock();
 
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 7ff95cada2e7..6fd7270d8ce6 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -28,12 +28,16 @@
 struct sk_buff;
 struct work_struct;
 
-int batadv_send_skb_packet(struct sk_buff *skb,
-			   struct batadv_hard_iface *hard_iface,
-			   const u8 *dst_addr);
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
 			    struct batadv_hard_iface *recv_if);
+int batadv_send_skb_packet(struct sk_buff *skb,
+			   struct batadv_hard_iface *hard_iface,
+			   const u8 *dst_addr);
+int batadv_send_broadcast_skb(struct sk_buff *skb,
+			      struct batadv_hard_iface *hard_iface);
+int batadv_send_unicast_skb(struct sk_buff *skb,
+			    struct batadv_neigh_node *neigh_node);
 void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface);
 int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				    const struct sk_buff *skb,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index a6f0952d2840..c56bb8835e60 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -377,11 +377,13 @@ DECLARE_EWMA(throughput, 1024, 8)
  * @throughput: ewma link throughput towards this neighbor
  * @elp_interval: time interval between two ELP transmissions
  * @elp_latest_seqno: latest and best known ELP sequence number
+ * @last_unicast_tx: when the last unicast packet has been sent to this neighbor
  */
 struct batadv_hardif_neigh_node_bat_v {
 	struct ewma_throughput throughput;
 	u32 elp_interval;
 	u32 elp_latest_seqno;
+	unsigned long last_unicast_tx;
 };
 
 /**
-- 
2.7.2
