From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 09/17] batman-adv: use consume_skb for non-dropped packets
Date: Tue,  8 Nov 2016 17:45:18 +0100
Message-ID: <20161108164526.7518-10-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:48899 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753930AbcKHQqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 11:46:00 -0500
In-Reply-To: <20161108164526.7518-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

kfree_skb assumes that an skb is dropped after an failure and notes that.
consume_skb should be used in non-failure situations. Such information is
important for dropmonitor netlink which tells how many packets were dropped
and where this drop happened.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c     | 13 ++++++++-----
 net/batman-adv/fragmentation.c  | 20 ++++++++++++++------
 net/batman-adv/network-coding.c | 24 +++++++++++++++---------
 net/batman-adv/send.c           | 27 +++++++++++++++++++--------
 net/batman-adv/send.h           |  3 ++-
 net/batman-adv/soft-interface.c |  2 +-
 6 files changed, 59 insertions(+), 30 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0b9be62..310f391 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -698,7 +698,7 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 
 	forw_packet_aggr->skb = netdev_alloc_skb_ip_align(NULL, skb_size);
 	if (!forw_packet_aggr->skb) {
-		batadv_forw_packet_free(forw_packet_aggr);
+		batadv_forw_packet_free(forw_packet_aggr, true);
 		return;
 	}
 
@@ -1611,7 +1611,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 	if (hardif_neigh)
 		batadv_hardif_neigh_put(hardif_neigh);
 
-	kfree_skb(skb_priv);
+	consume_skb(skb_priv);
 }
 
 /**
@@ -1783,6 +1783,7 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 	struct delayed_work *delayed_work;
 	struct batadv_forw_packet *forw_packet;
 	struct batadv_priv *bat_priv;
+	bool dropped = false;
 
 	delayed_work = to_delayed_work(work);
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
@@ -1792,8 +1793,10 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 	hlist_del(&forw_packet->list);
 	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 
-	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
+	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING) {
+		dropped = true;
 		goto out;
+	}
 
 	batadv_iv_ogm_emit(forw_packet);
 
@@ -1810,7 +1813,7 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 		batadv_iv_ogm_schedule(forw_packet->if_incoming);
 
 out:
-	batadv_forw_packet_free(forw_packet);
+	batadv_forw_packet_free(forw_packet, dropped);
 }
 
 static int batadv_iv_ogm_receive(struct sk_buff *skb,
@@ -1851,7 +1854,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 		ogm_packet = (struct batadv_ogm_packet *)packet_pos;
 	}
 
-	kfree_skb(skb);
+	consume_skb(skb);
 	return NET_RX_SUCCESS;
 }
 
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 2b967a3..a2e28a1 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -42,17 +42,23 @@
 /**
  * batadv_frag_clear_chain - delete entries in the fragment buffer chain
  * @head: head of chain with entries.
+ * @dropped: whether the chain is cleared because all fragments are dropped
  *
  * Free fragments in the passed hlist. Should be called with appropriate lock.
  */
-static void batadv_frag_clear_chain(struct hlist_head *head)
+static void batadv_frag_clear_chain(struct hlist_head *head, bool dropped)
 {
 	struct batadv_frag_list_entry *entry;
 	struct hlist_node *node;
 
 	hlist_for_each_entry_safe(entry, node, head, list) {
 		hlist_del(&entry->list);
-		kfree_skb(entry->skb);
+
+		if (dropped)
+			kfree_skb(entry->skb);
+		else
+			consume_skb(entry->skb);
+
 		kfree(entry);
 	}
 }
@@ -73,7 +79,7 @@ void batadv_frag_purge_orig(struct batadv_orig_node *orig_node,
 		spin_lock_bh(&chain->lock);
 
 		if (!check_cb || check_cb(chain)) {
-			batadv_frag_clear_chain(&chain->fragment_list);
+			batadv_frag_clear_chain(&chain->fragment_list, true);
 			chain->size = 0;
 		}
 
@@ -118,7 +124,7 @@ static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
 		return false;
 
 	if (!hlist_empty(&chain->fragment_list))
-		batadv_frag_clear_chain(&chain->fragment_list);
+		batadv_frag_clear_chain(&chain->fragment_list, true);
 
 	chain->size = 0;
 	chain->seqno = seqno;
@@ -220,7 +226,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 		 * exceeds the maximum size of one merged packet. Don't allow
 		 * packets to have different total_size.
 		 */
-		batadv_frag_clear_chain(&chain->fragment_list);
+		batadv_frag_clear_chain(&chain->fragment_list, true);
 		chain->size = 0;
 	} else if (ntohs(frag_packet->total_size) == chain->size) {
 		/* All fragments received. Hand over chain to caller. */
@@ -254,6 +260,7 @@ batadv_frag_merge_packets(struct hlist_head *chain)
 	struct batadv_frag_list_entry *entry;
 	struct sk_buff *skb_out;
 	int size, hdr_size = sizeof(struct batadv_frag_packet);
+	bool dropped = false;
 
 	/* Remove first entry, as this is the destination for the rest of the
 	 * fragments.
@@ -270,6 +277,7 @@ batadv_frag_merge_packets(struct hlist_head *chain)
 	if (pskb_expand_head(skb_out, 0, size - skb_out->len, GFP_ATOMIC) < 0) {
 		kfree_skb(skb_out);
 		skb_out = NULL;
+		dropped = true;
 		goto free;
 	}
 
@@ -291,7 +299,7 @@ batadv_frag_merge_packets(struct hlist_head *chain)
 
 free:
 	/* Locking is not needed, because 'chain' is not part of any orig. */
-	batadv_frag_clear_chain(chain);
+	batadv_frag_clear_chain(chain, dropped);
 	return skb_out;
 }
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index c213dde..3af66d3 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -260,10 +260,16 @@ static void batadv_nc_path_put(struct batadv_nc_path *nc_path)
 /**
  * batadv_nc_packet_free - frees nc packet
  * @nc_packet: the nc packet to free
+ * @dropped: whether the packet is freed because is is dropped
  */
-static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet)
+static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet,
+				  bool dropped)
 {
-	kfree_skb(nc_packet->skb);
+	if (dropped)
+		kfree_skb(nc_packet->skb);
+	else
+		consume_skb(nc_packet->skb);
+
 	batadv_nc_path_put(nc_packet->nc_path);
 	kfree(nc_packet);
 }
@@ -576,7 +582,7 @@ static void batadv_nc_send_packet(struct batadv_nc_packet *nc_packet)
 {
 	batadv_send_unicast_skb(nc_packet->skb, nc_packet->neigh_node);
 	nc_packet->skb = NULL;
-	batadv_nc_packet_free(nc_packet);
+	batadv_nc_packet_free(nc_packet, false);
 }
 
 /**
@@ -610,7 +616,7 @@ static bool batadv_nc_sniffed_purge(struct batadv_priv *bat_priv,
 
 	/* purge nc packet */
 	list_del(&nc_packet->list);
-	batadv_nc_packet_free(nc_packet);
+	batadv_nc_packet_free(nc_packet, true);
 
 	res = true;
 
@@ -1208,11 +1214,11 @@ static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
 	}
 
 	/* skb_src is now coded into skb_dest, so free it */
-	kfree_skb(skb_src);
+	consume_skb(skb_src);
 
 	/* avoid duplicate free of skb from nc_packet */
 	nc_packet->skb = NULL;
-	batadv_nc_packet_free(nc_packet);
+	batadv_nc_packet_free(nc_packet, false);
 
 	/* Send the coded packet and return true */
 	batadv_send_unicast_skb(skb_dest, first_dest);
@@ -1399,7 +1405,7 @@ static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_priv,
 	/* batadv_nc_skb_store_for_decoding() clones the skb, so we must free
 	 * our ref
 	 */
-	kfree_skb(skb);
+	consume_skb(skb);
 }
 
 /**
@@ -1723,7 +1729,7 @@ batadv_nc_skb_decode_packet(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	ether_addr_copy(unicast_packet->dest, orig_dest);
 	unicast_packet->ttvn = ttvn;
 
-	batadv_nc_packet_free(nc_packet);
+	batadv_nc_packet_free(nc_packet, false);
 	return unicast_packet;
 }
 
@@ -1860,7 +1866,7 @@ static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
 	return batadv_recv_unicast_packet(skb, recv_if);
 
 free_nc_packet:
-	batadv_nc_packet_free(nc_packet);
+	batadv_nc_packet_free(nc_packet, true);
 	return NET_RX_DROP;
 }
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index d9bbb00..0f86293 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -451,13 +451,19 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 /**
  * batadv_forw_packet_free - free a forwarding packet
  * @forw_packet: The packet to free
+ * @dropped: whether the packet is freed because is is dropped
  *
  * This frees a forwarding packet and releases any resources it might
  * have claimed.
  */
-void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
+void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet,
+			     bool dropped)
 {
-	kfree_skb(forw_packet->skb);
+	if (dropped)
+		kfree_skb(forw_packet->skb);
+	else
+		consume_skb(forw_packet->skb);
+
 	if (forw_packet->if_incoming)
 		batadv_hardif_put(forw_packet->if_incoming);
 	if (forw_packet->if_outgoing)
@@ -598,7 +604,7 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	return NETDEV_TX_OK;
 
 err_packet_free:
-	batadv_forw_packet_free(forw_packet);
+	batadv_forw_packet_free(forw_packet, true);
 err:
 	return NETDEV_TX_BUSY;
 }
@@ -613,6 +619,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	struct sk_buff *skb1;
 	struct net_device *soft_iface;
 	struct batadv_priv *bat_priv;
+	bool dropped = false;
 	u8 *neigh_addr;
 	u8 *orig_neigh;
 	int ret = 0;
@@ -627,11 +634,15 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	hlist_del(&forw_packet->list);
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
 
-	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
+	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING) {
+		dropped = true;
 		goto out;
+	}
 
-	if (batadv_dat_drop_broadcast_packet(bat_priv, forw_packet))
+	if (batadv_dat_drop_broadcast_packet(bat_priv, forw_packet)) {
+		dropped = true;
 		goto out;
+	}
 
 	bcast_packet = (struct batadv_bcast_packet *)forw_packet->skb->data;
 
@@ -709,7 +720,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	}
 
 out:
-	batadv_forw_packet_free(forw_packet);
+	batadv_forw_packet_free(forw_packet, dropped);
 }
 
 void
@@ -750,7 +761,7 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 
 		if (pending) {
 			hlist_del(&forw_packet->list);
-			batadv_forw_packet_free(forw_packet);
+			batadv_forw_packet_free(forw_packet, true);
 		}
 	}
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
@@ -777,7 +788,7 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 
 		if (pending) {
 			hlist_del(&forw_packet->list);
-			batadv_forw_packet_free(forw_packet);
+			batadv_forw_packet_free(forw_packet, true);
 		}
 	}
 	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 86009b5..c580194 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -27,7 +27,8 @@
 
 struct sk_buff;
 
-void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet);
+void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet,
+			     bool dropped);
 struct batadv_forw_packet *
 batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 			 struct batadv_hard_iface *if_outgoing,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 109f53b..2f0304e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -362,7 +362,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		/* a copy is stored in the bcast list, therefore removing
 		 * the original skb.
 		 */
-		kfree_skb(skb);
+		consume_skb(skb);
 
 	/* unicast packet */
 	} else {
-- 
2.10.1
