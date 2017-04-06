From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/19] batman-adv: privatize forw_packet skb assignment
Date: Thu,  6 Apr 2017 16:07:35 +0200
Message-ID: <20170406140741.30745-14-sw@simonwunderlich.de>
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
Received: from packetmixer.de ([79.140.42.25]:32940 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935049AbdDFOHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:52 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

An skb is assigned to a forw_packet only once, shortly after the
forw_packet allocation.

With this patch the assignment is moved into the this allocation
function.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c | 17 +++++++++--------
 net/batman-adv/send.c       | 21 ++++++++++++---------
 net/batman-adv/send.h       |  3 ++-
 3 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7c3d994e90d8..f665ff3ede53 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -679,15 +679,11 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_forw_packet *forw_packet_aggr;
+	struct sk_buff *skb;
 	unsigned char *skb_buff;
 	unsigned int skb_size;
 	atomic_t *queue_left = own_packet ? NULL : &bat_priv->batman_queue_left;
 
-	forw_packet_aggr = batadv_forw_packet_alloc(if_incoming, if_outgoing,
-						    queue_left, bat_priv);
-	if (!forw_packet_aggr)
-		return;
-
 	if (atomic_read(&bat_priv->aggregated_ogms) &&
 	    packet_len < BATADV_MAX_AGGREGATION_BYTES)
 		skb_size = BATADV_MAX_AGGREGATION_BYTES;
@@ -696,9 +692,14 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	skb_size += ETH_HLEN;
 
-	forw_packet_aggr->skb = netdev_alloc_skb_ip_align(NULL, skb_size);
-	if (!forw_packet_aggr->skb) {
-		batadv_forw_packet_free(forw_packet_aggr, true);
+	skb = netdev_alloc_skb_ip_align(NULL, skb_size);
+	if (!skb)
+		return;
+
+	forw_packet_aggr = batadv_forw_packet_alloc(if_incoming, if_outgoing,
+						    queue_left, bat_priv, skb);
+	if (!forw_packet_aggr) {
+		kfree_skb(skb);
 		return;
 	}
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 1489ec27daff..7bf470204e10 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -482,6 +482,7 @@ void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet,
  * @if_outgoing: The (optional) if_outgoing to be grabbed
  * @queue_left: The (optional) queue counter to decrease
  * @bat_priv: The bat_priv for the mesh of this forw_packet
+ * @skb: The raw packet this forwarding packet shall contain
  *
  * Allocates a forwarding packet and tries to get a reference to the
  * (optional) if_incoming, if_outgoing and queue_left. If queue_left
@@ -493,7 +494,8 @@ struct batadv_forw_packet *
 batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 			 struct batadv_hard_iface *if_outgoing,
 			 atomic_t *queue_left,
-			 struct batadv_priv *bat_priv)
+			 struct batadv_priv *bat_priv,
+			 struct sk_buff *skb)
 {
 	struct batadv_forw_packet *forw_packet;
 	const char *qname;
@@ -525,7 +527,7 @@ batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 
 	INIT_HLIST_NODE(&forw_packet->list);
 	INIT_HLIST_NODE(&forw_packet->cleanup_list);
-	forw_packet->skb = NULL;
+	forw_packet->skb = skb;
 	forw_packet->queue_left = queue_left;
 	forw_packet->if_incoming = if_incoming;
 	forw_packet->if_outgoing = if_outgoing;
@@ -756,22 +758,23 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	if (!primary_if)
 		goto err;
 
+	newskb = skb_copy(skb, GFP_ATOMIC);
+	if (!newskb) {
+		batadv_hardif_put(primary_if);
+		goto err;
+	}
+
 	forw_packet = batadv_forw_packet_alloc(primary_if, NULL,
 					       &bat_priv->bcast_queue_left,
-					       bat_priv);
+					       bat_priv, newskb);
 	batadv_hardif_put(primary_if);
 	if (!forw_packet)
-		goto err;
-
-	newskb = skb_copy(skb, GFP_ATOMIC);
-	if (!newskb)
 		goto err_packet_free;
 
 	/* as we have a copy now, it is safe to decrease the TTL */
 	bcast_packet = (struct batadv_bcast_packet *)newskb->data;
 	bcast_packet->ttl--;
 
-	forw_packet->skb = newskb;
 	forw_packet->own = own_packet;
 
 	INIT_DELAYED_WORK(&forw_packet->delayed_work,
@@ -781,7 +784,7 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	return NETDEV_TX_OK;
 
 err_packet_free:
-	batadv_forw_packet_free(forw_packet, true);
+	kfree_skb(newskb);
 err:
 	return NETDEV_TX_BUSY;
 }
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index f21166d10323..8e75890406d2 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -34,7 +34,8 @@ struct batadv_forw_packet *
 batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 			 struct batadv_hard_iface *if_outgoing,
 			 atomic_t *queue_left,
-			 struct batadv_priv *bat_priv);
+			 struct batadv_priv *bat_priv,
+			 struct sk_buff *skb);
 bool batadv_forw_packet_steal(struct batadv_forw_packet *packet, spinlock_t *l);
 void batadv_forw_packet_ogmv1_queue(struct batadv_priv *bat_priv,
 				    struct batadv_forw_packet *forw_packet,
-- 
2.11.0
