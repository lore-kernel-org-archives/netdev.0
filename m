From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/21] batman-adv: move batadv_slide_own_bcast_window to bat_iv_ogm.c
Date: Wed, 29 May 2013 10:10:42 +0200
Message-ID: <1369815051-708-13-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39989 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965066Ab3E2INC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:02 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

batadv_slide_own_bcast_window() is used only in bat_iv_ogm.c
and it is currently touching only batman_iv specific
attributes.

Move it into bat_iv_ogm.c and make it static.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c | 37 ++++++++++++++++++++++++++++++++++++-
 net/batman-adv/routing.c    | 29 -----------------------------
 net/batman-adv/routing.h    |  1 -
 3 files changed, 36 insertions(+), 31 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 31c2891..42b7a94 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -630,6 +630,41 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
 
+/**
+ * batadv_iv_ogm_slide_own_bcast_window - bitshift own OGM broadcast windows for
+ * the given interface
+ * @hard_iface: the interface for which the windows have to be shifted
+ */
+static void
+batadv_iv_ogm_slide_own_bcast_window(struct batadv_hard_iface *hard_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct batadv_hashtable *hash = bat_priv->orig_hash;
+	struct hlist_head *head;
+	struct batadv_orig_node *orig_node;
+	unsigned long *word;
+	uint32_t i;
+	size_t word_index;
+	uint8_t *w;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+			spin_lock_bh(&orig_node->ogm_cnt_lock);
+			word_index = hard_iface->if_num * BATADV_NUM_WORDS;
+			word = &(orig_node->bcast_own[word_index]);
+
+			batadv_bit_get_packet(bat_priv, word, 1, 0);
+			w = &orig_node->bcast_own_sum[hard_iface->if_num];
+			*w = bitmap_weight(word, BATADV_TQ_LOCAL_WINDOW_SIZE);
+			spin_unlock_bh(&orig_node->ogm_cnt_lock);
+		}
+		rcu_read_unlock();
+	}
+}
+
 static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
@@ -674,7 +709,7 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 		batadv_ogm_packet->gw_flags = BATADV_NO_FLAGS;
 	}
 
-	batadv_slide_own_bcast_window(hard_iface);
+	batadv_iv_ogm_slide_own_bcast_window(hard_iface);
 	batadv_iv_ogm_queue_add(bat_priv, hard_iface->bat_iv.ogm_buff,
 				hard_iface->bat_iv.ogm_buff_len, hard_iface, 1,
 				batadv_iv_ogm_emit_send_time(bat_priv));
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index beeab2e..fad0846 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -34,35 +34,6 @@
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
 
-void batadv_slide_own_bcast_window(struct batadv_hard_iface *hard_iface)
-{
-	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	struct batadv_hashtable *hash = bat_priv->orig_hash;
-	struct hlist_head *head;
-	struct batadv_orig_node *orig_node;
-	unsigned long *word;
-	uint32_t i;
-	size_t word_index;
-	uint8_t *w;
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			spin_lock_bh(&orig_node->ogm_cnt_lock);
-			word_index = hard_iface->if_num * BATADV_NUM_WORDS;
-			word = &(orig_node->bcast_own[word_index]);
-
-			batadv_bit_get_packet(bat_priv, word, 1, 0);
-			w = &orig_node->bcast_own_sum[hard_iface->if_num];
-			*w = bitmap_weight(word, BATADV_TQ_LOCAL_WINDOW_SIZE);
-			spin_unlock_bh(&orig_node->ogm_cnt_lock);
-		}
-		rcu_read_unlock();
-	}
-}
-
 static void _batadv_update_route(struct batadv_priv *bat_priv,
 				 struct batadv_orig_node *orig_node,
 				 struct batadv_neigh_node *neigh_node)
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 99eeafa..72a29bd 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -20,7 +20,6 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
 
-void batadv_slide_own_bcast_window(struct batadv_hard_iface *hard_iface);
 bool batadv_check_management_packet(struct sk_buff *skb,
 				    struct batadv_hard_iface *hard_iface,
 				    int header_len);
-- 
1.8.1.5
