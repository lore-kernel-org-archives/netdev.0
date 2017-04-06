From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 14/19] batman-adv: restructure rebroadcast counter into forw_packet API
Date: Thu,  6 Apr 2017 16:07:36 +0200
Message-ID: <20170406140741.30745-15-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32992 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934966AbdDFOHx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:53 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

This patch refactors the num_packets counter of a forw_packet in the
following three ways:

1) Removed dual-use of forw_packet::num_packets:
   -> now for aggregation purposes only
2) Using forw_packet::skb::cb::num_bcasts instead:
   -> for easier access in aggregation code later
3) make access to num_bcasts private to batadv_forw_packet_*()

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
[sven@narfation.org: Change num_bcasts to unsigned]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/main.c                  |  3 ++
 net/batman-adv/send.c                  | 55 ++++++++++++++++++++++++++++++++--
 net/batman-adv/send.h                  |  1 +
 net/batman-adv/soft-interface.c        |  3 ++
 net/batman-adv/types.h                 |  4 ++-
 6 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 77ede40ff529..0608fcf99e7b 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1303,7 +1303,7 @@ bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 	/* If this packet is an ARP_REQUEST and the node already has the
 	 * information that it is going to ask, then the packet can be dropped
 	 */
-	if (forw_packet->num_packets)
+	if (batadv_forw_packet_is_rebroadcast(forw_packet))
 		goto out;
 
 	vid = batadv_dat_get_vid(forw_packet->skb, &hdr_size);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5000c540614d..fb381fb26a66 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -516,6 +516,9 @@ static void batadv_recv_handler_init(void)
 	BUILD_BUG_ON(sizeof(struct batadv_tvlv_tt_change) != 12);
 	BUILD_BUG_ON(sizeof(struct batadv_tvlv_roam_adv) != 8);
 
+	i = FIELD_SIZEOF(struct sk_buff, cb);
+	BUILD_BUG_ON(sizeof(struct batadv_skb_cb) > i);
+
 	/* broadcast packet */
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 7bf470204e10..403df596a73d 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -789,6 +789,55 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	return NETDEV_TX_BUSY;
 }
 
+/**
+ * batadv_forw_packet_bcasts_left - check if a retransmission is necessary
+ * @forw_packet: the forwarding packet to check
+ * @hard_iface: the interface to check on
+ *
+ * Checks whether a given packet has any (re)transmissions left on the provided
+ * interface.
+ *
+ * hard_iface may be NULL: In that case the number of transmissions this skb had
+ * so far is compared with the maximum amount of retransmissions independent of
+ * any interface instead.
+ *
+ * Return: True if (re)transmissions are left, false otherwise.
+ */
+static bool
+batadv_forw_packet_bcasts_left(struct batadv_forw_packet *forw_packet,
+			       struct batadv_hard_iface *hard_iface)
+{
+	unsigned int max;
+
+	if (hard_iface)
+		max = hard_iface->num_bcasts;
+	else
+		max = BATADV_NUM_BCASTS_MAX;
+
+	return BATADV_SKB_CB(forw_packet->skb)->num_bcasts < max;
+}
+
+/**
+ * batadv_forw_packet_bcasts_inc - increment retransmission counter of a packet
+ * @forw_packet: the packet to increase the counter for
+ */
+static void
+batadv_forw_packet_bcasts_inc(struct batadv_forw_packet *forw_packet)
+{
+	BATADV_SKB_CB(forw_packet->skb)->num_bcasts++;
+}
+
+/**
+ * batadv_forw_packet_is_rebroadcast - check packet for previous transmissions
+ * @forw_packet: the packet to check
+ *
+ * Return: True if this packet was transmitted before, false otherwise.
+ */
+bool batadv_forw_packet_is_rebroadcast(struct batadv_forw_packet *forw_packet)
+{
+	return BATADV_SKB_CB(forw_packet->skb)->num_bcasts > 0;
+}
+
 static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 {
 	struct batadv_hard_iface *hard_iface;
@@ -829,7 +878,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		if (forw_packet->num_packets >= hard_iface->num_bcasts)
+		if (!batadv_forw_packet_bcasts_left(forw_packet, hard_iface))
 			continue;
 
 		if (forw_packet->own) {
@@ -887,10 +936,10 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	}
 	rcu_read_unlock();
 
-	forw_packet->num_packets++;
+	batadv_forw_packet_bcasts_inc(forw_packet);
 
 	/* if we still have some more bcasts to send */
-	if (forw_packet->num_packets < BATADV_NUM_BCASTS_MAX) {
+	if (batadv_forw_packet_bcasts_left(forw_packet, NULL)) {
 		batadv_forw_packet_bcast_queue(bat_priv, forw_packet,
 					       send_time);
 		return;
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 8e75890406d2..a16b34f473ef 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -40,6 +40,7 @@ bool batadv_forw_packet_steal(struct batadv_forw_packet *packet, spinlock_t *l);
 void batadv_forw_packet_ogmv1_queue(struct batadv_priv *bat_priv,
 				    struct batadv_forw_packet *forw_packet,
 				    unsigned long send_time);
+bool batadv_forw_packet_is_rebroadcast(struct batadv_forw_packet *forw_packet);
 
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 8226495c6664..a9dbcc1590bd 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -230,6 +230,9 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
 		goto dropped;
 
+	/* reset control block to avoid left overs from previous users */
+	memset(skb->cb, 0, sizeof(struct batadv_skb_cb));
+
 	netif_trans_update(soft_iface);
 	vid = batadv_get_vid(skb, 0);
 	ethhdr = eth_hdr(skb);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 66b25e410a41..74b5af7dcd86 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1377,9 +1377,11 @@ struct batadv_nc_packet {
  *  relevant to batman-adv in the skb->cb buffer in skbs.
  * @decoded: Marks a skb as decoded, which is checked when searching for coding
  *  opportunities in network-coding.c
+ * @num_bcasts: Counter for broadcast packet retransmissions
  */
 struct batadv_skb_cb {
 	bool decoded;
+	unsigned int num_bcasts;
 };
 
 /**
@@ -1392,7 +1394,7 @@ struct batadv_skb_cb {
  * @skb: bcast packet's skb buffer
  * @packet_len: size of aggregated OGM packet inside the skb buffer
  * @direct_link_flags: direct link flags for aggregated OGM packets
- * @num_packets: counter for bcast packet retransmission
+ * @num_packets: counter for aggregated OGMv1 packets
  * @delayed_work: work queue callback item for packet sending
  * @if_incoming: pointer to incoming hard-iface or primary iface if
  *  locally generated packet
-- 
2.11.0
