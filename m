From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/19] batman-adv: Introduce forward packet creation helper
Date: Fri, 12 Aug 2016 10:56:51 +0200
Message-ID: <1470992215-11009-16-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:35015 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbcHLI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:31 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

This patch abstracts the forward packet creation into the new function
batadv_forw_packet_alloc().

The queue counting and interface reference counters are now handled
internally within batadv_forw_packet_alloc() and its
batadv_forw_packet_free() counterpart. This should reduce the risk of
having reference/queue counting bugs again and should increase
code readibility.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c |  38 ++++-----------
 net/batman-adv/send.c       | 111 ++++++++++++++++++++++++++++++++------------
 net/batman-adv/send.h       |   6 +++
 net/batman-adv/types.h      |   2 +
 4 files changed, 98 insertions(+), 59 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 57e0af9..a40cdf2 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -675,19 +675,12 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	struct batadv_forw_packet *forw_packet_aggr;
 	unsigned char *skb_buff;
 	unsigned int skb_size;
+	atomic_t *queue_left = own_packet ? NULL : &bat_priv->batman_queue_left;
 
-	/* own packet should always be scheduled */
-	if (!own_packet) {
-		if (!batadv_atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
-			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-				   "batman packet queue full\n");
-			return;
-		}
-	}
-
-	forw_packet_aggr = kmalloc(sizeof(*forw_packet_aggr), GFP_ATOMIC);
+	forw_packet_aggr = batadv_forw_packet_alloc(if_incoming, if_outgoing,
+						    queue_left, bat_priv);
 	if (!forw_packet_aggr)
-		goto out_nomem;
+		return;
 
 	if (atomic_read(&bat_priv->aggregated_ogms) &&
 	    packet_len < BATADV_MAX_AGGREGATION_BYTES)
@@ -698,8 +691,11 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	skb_size += ETH_HLEN;
 
 	forw_packet_aggr->skb = netdev_alloc_skb_ip_align(NULL, skb_size);
-	if (!forw_packet_aggr->skb)
-		goto out_free_forw_packet;
+	if (!forw_packet_aggr->skb) {
+		batadv_forw_packet_free(forw_packet_aggr);
+		return;
+	}
+
 	forw_packet_aggr->skb->priority = TC_PRIO_CONTROL;
 	skb_reserve(forw_packet_aggr->skb, ETH_HLEN);
 
@@ -707,12 +703,7 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	forw_packet_aggr->packet_len = packet_len;
 	memcpy(skb_buff, packet_buff, packet_len);
 
-	kref_get(&if_incoming->refcount);
-	kref_get(&if_outgoing->refcount);
 	forw_packet_aggr->own = own_packet;
-	forw_packet_aggr->if_incoming = if_incoming;
-	forw_packet_aggr->if_outgoing = if_outgoing;
-	forw_packet_aggr->num_packets = 0;
 	forw_packet_aggr->direct_link_flags = BATADV_NO_FLAGS;
 	forw_packet_aggr->send_time = send_time;
 
@@ -731,13 +722,6 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	queue_delayed_work(batadv_event_workqueue,
 			   &forw_packet_aggr->delayed_work,
 			   send_time - jiffies);
-
-	return;
-out_free_forw_packet:
-	kfree(forw_packet_aggr);
-out_nomem:
-	if (!own_packet)
-		atomic_inc(&bat_priv->batman_queue_left);
 }
 
 /* aggregate a new packet into the existing ogm packet */
@@ -1820,10 +1804,6 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 		batadv_iv_ogm_schedule(forw_packet->if_incoming);
 
 out:
-	/* don't count own packet */
-	if (!forw_packet->own)
-		atomic_inc(&bat_priv->batman_queue_left);
-
 	batadv_forw_packet_free(forw_packet);
 }
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 6191159..33d8bd1 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -439,6 +439,13 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 				       BATADV_P_DATA, orig_node, vid);
 }
 
+/**
+ * batadv_forw_packet_free - free a forwarding packet
+ * @forw_packet: The packet to free
+ *
+ * This frees a forwarding packet and releases any resources it might
+ * have claimed.
+ */
 void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 {
 	kfree_skb(forw_packet->skb);
@@ -446,9 +453,73 @@ void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 		batadv_hardif_put(forw_packet->if_incoming);
 	if (forw_packet->if_outgoing)
 		batadv_hardif_put(forw_packet->if_outgoing);
+	if (forw_packet->queue_left)
+		atomic_inc(forw_packet->queue_left);
 	kfree(forw_packet);
 }
 
+/**
+ * batadv_forw_packet_alloc - allocate a forwarding packet
+ * @if_incoming: The (optional) if_incoming to be grabbed
+ * @if_outgoing: The (optional) if_outgoing to be grabbed
+ * @queue_left: The (optional) queue counter to decrease
+ * @bat_priv: The bat_priv for the mesh of this forw_packet
+ *
+ * Allocates a forwarding packet and tries to get a reference to the
+ * (optional) if_incoming, if_outgoing and queue_left. If queue_left
+ * is NULL then bat_priv is optional, too.
+ *
+ * Return: An allocated forwarding packet on success, NULL otherwise.
+ */
+struct batadv_forw_packet *
+batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
+			 struct batadv_hard_iface *if_outgoing,
+			 atomic_t *queue_left,
+			 struct batadv_priv *bat_priv)
+{
+	struct batadv_forw_packet *forw_packet;
+	const char *qname;
+
+	if (queue_left && !batadv_atomic_dec_not_zero(queue_left)) {
+		qname = "unknown";
+
+		if (queue_left == &bat_priv->bcast_queue_left)
+			qname = "bcast";
+
+		if (queue_left == &bat_priv->batman_queue_left)
+			qname = "batman";
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "%s queue is full\n", qname);
+
+		return NULL;
+	}
+
+	forw_packet = kmalloc(sizeof(*forw_packet), GFP_ATOMIC);
+	if (!forw_packet)
+		goto err;
+
+	if (if_incoming)
+		kref_get(&if_incoming->refcount);
+
+	if (if_outgoing)
+		kref_get(&if_outgoing->refcount);
+
+	forw_packet->skb = NULL;
+	forw_packet->queue_left = queue_left;
+	forw_packet->if_incoming = if_incoming;
+	forw_packet->if_outgoing = if_outgoing;
+	forw_packet->num_packets = 0;
+
+	return forw_packet;
+
+err:
+	if (queue_left)
+		atomic_inc(queue_left);
+
+	return NULL;
+}
+
 static void
 _batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 				 struct batadv_forw_packet *forw_packet,
@@ -487,24 +558,20 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	struct batadv_bcast_packet *bcast_packet;
 	struct sk_buff *newskb;
 
-	if (!batadv_atomic_dec_not_zero(&bat_priv->bcast_queue_left)) {
-		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "bcast packet queue full\n");
-		goto out;
-	}
-
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		goto out_and_inc;
-
-	forw_packet = kmalloc(sizeof(*forw_packet), GFP_ATOMIC);
+		goto err;
 
+	forw_packet = batadv_forw_packet_alloc(primary_if, NULL,
+					       &bat_priv->bcast_queue_left,
+					       bat_priv);
+	batadv_hardif_put(primary_if);
 	if (!forw_packet)
-		goto out_and_inc;
+		goto err;
 
 	newskb = skb_copy(skb, GFP_ATOMIC);
 	if (!newskb)
-		goto packet_free;
+		goto err_packet_free;
 
 	/* as we have a copy now, it is safe to decrease the TTL */
 	bcast_packet = (struct batadv_bcast_packet *)newskb->data;
@@ -513,11 +580,6 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	skb_reset_mac_header(newskb);
 
 	forw_packet->skb = newskb;
-	forw_packet->if_incoming = primary_if;
-	forw_packet->if_outgoing = NULL;
-
-	/* how often did we send the bcast packet ? */
-	forw_packet->num_packets = 0;
 
 	INIT_DELAYED_WORK(&forw_packet->delayed_work,
 			  batadv_send_outstanding_bcast_packet);
@@ -525,13 +587,9 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	_batadv_add_bcast_packet_to_list(bat_priv, forw_packet, delay);
 	return NETDEV_TX_OK;
 
-packet_free:
-	kfree(forw_packet);
-out_and_inc:
-	atomic_inc(&bat_priv->bcast_queue_left);
-out:
-	if (primary_if)
-		batadv_hardif_put(primary_if);
+err_packet_free:
+	batadv_forw_packet_free(forw_packet);
+err:
 	return NETDEV_TX_BUSY;
 }
 
@@ -592,7 +650,6 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 
 out:
 	batadv_forw_packet_free(forw_packet);
-	atomic_inc(&bat_priv->bcast_queue_left);
 }
 
 void
@@ -633,9 +690,6 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 
 		if (pending) {
 			hlist_del(&forw_packet->list);
-			if (!forw_packet->own)
-				atomic_inc(&bat_priv->bcast_queue_left);
-
 			batadv_forw_packet_free(forw_packet);
 		}
 	}
@@ -663,9 +717,6 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 
 		if (pending) {
 			hlist_del(&forw_packet->list);
-			if (!forw_packet->own)
-				atomic_inc(&bat_priv->batman_queue_left);
-
 			batadv_forw_packet_free(forw_packet);
 		}
 	}
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 7cecb75..999f786 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -28,6 +28,12 @@
 struct sk_buff;
 
 void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet);
+struct batadv_forw_packet *
+batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
+			 struct batadv_hard_iface *if_outgoing,
+			 atomic_t *queue_left,
+			 struct batadv_priv *bat_priv);
+
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
 			    struct batadv_hard_iface *recv_if);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 54710c7..72806a3 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1375,6 +1375,7 @@ struct batadv_skb_cb {
  *  locally generated packet
  * @if_outgoing: packet where the packet should be sent to, or NULL if
  *  unspecified
+ * @queue_left: The queue (counter) this packet was applied to
  */
 struct batadv_forw_packet {
 	struct hlist_node list;
@@ -1387,6 +1388,7 @@ struct batadv_forw_packet {
 	struct delayed_work delayed_work;
 	struct batadv_hard_iface *if_incoming;
 	struct batadv_hard_iface *if_outgoing;
+	atomic_t *queue_left;
 };
 
 /**
-- 
2.8.1
