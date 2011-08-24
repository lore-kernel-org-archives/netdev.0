From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 3/8] batman-adv: detect clients connected through a 802.11 device
Date: Wed, 24 Aug 2011 15:00:33 +0200
Message-ID: <1314190838-2273-4-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm14.bullet.mail.ukl.yahoo.com ([217.146.183.188]:23658 "HELO
	nm14.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752226Ab1HXNAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:00:55 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Clients connected through a 802.11 device are now marked with the
TT_CLIENT_WIFI flag. This flag is also advertised with the tt
announcement.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c    |   30 ++++++++++++++++++++++++++++++
 net/batman-adv/hard-interface.h    |    1 +
 net/batman-adv/main.c              |    2 +-
 net/batman-adv/main.h              |    2 ++
 net/batman-adv/packet.h            |    1 +
 net/batman-adv/routing.c           |    2 +-
 net/batman-adv/soft-interface.c    |    4 ++--
 net/batman-adv/translation-table.c |   15 ++++++++++++---
 net/batman-adv/translation-table.h |    9 +++++----
 9 files changed, 55 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 0d73e1e..bf91e4d 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -681,6 +681,36 @@ err_out:
 	return NET_RX_DROP;
 }
 
+/* This function returns true if the interface represented by ifindex is a
+ * 802.11 wireless device */
+bool is_wifi_iface(int ifindex)
+{
+	struct net_device *net_device = NULL;
+	bool ret = false;
+
+	if (ifindex == NULL_IFINDEX)
+		goto out;
+
+	net_device = dev_get_by_index(&init_net, ifindex);
+	if (!net_device)
+		goto out;
+
+#ifdef CONFIG_WIRELESS_EXT
+	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
+	 * check for wireless_handlers != NULL */
+	if (net_device->wireless_handlers)
+		ret = true;
+	else
+#endif
+		/* cfg80211 drivers have to set ieee80211_ptr */
+		if (net_device->ieee80211_ptr)
+			ret = true;
+out:
+	if (net_device)
+		dev_put(net_device);
+	return ret;
+}
+
 struct notifier_block hard_if_notifier = {
 	.notifier_call = hard_if_event,
 };
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 442eacb..67f78d1 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -42,6 +42,7 @@ void hardif_remove_interfaces(void);
 int hardif_min_mtu(struct net_device *soft_iface);
 void update_min_mtu(struct net_device *soft_iface);
 void hardif_free_rcu(struct rcu_head *rcu);
+bool is_wifi_iface(int ifindex);
 
 static inline void hardif_free_ref(struct hard_iface *hard_iface)
 {
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index b0f9068..79b9ae5 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -107,7 +107,7 @@ int mesh_init(struct net_device *soft_iface)
 	if (tt_init(bat_priv) < 1)
 		goto err;
 
-	tt_local_add(soft_iface, soft_iface->dev_addr);
+	tt_local_add(soft_iface, soft_iface->dev_addr, NULL_IFINDEX);
 
 	if (vis_init(bat_priv) < 1)
 		goto err;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 3daa9b6..60b3696 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -62,6 +62,8 @@
 
 #define NO_FLAGS 0
 
+#define NULL_IFINDEX 0 /* dummy ifindex used to avoid iface checks */
+
 #define NUM_WORDS (TQ_LOCAL_WINDOW_SIZE / WORD_BIT_SIZE)
 
 #define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index b76b4be..8802eab 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -84,6 +84,7 @@ enum tt_query_flags {
 enum tt_client_flags {
 	TT_CLIENT_DEL     = 1 << 0,
 	TT_CLIENT_ROAM    = 1 << 1,
+	TT_CLIENT_WIFI    = 1 << 2,
 	TT_CLIENT_NOPURGE = 1 << 8,
 	TT_CLIENT_NEW     = 1 << 9,
 	TT_CLIENT_PENDING = 1 << 10
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index ec23f9f..13444e9 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1299,7 +1299,7 @@ int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if)
 		roam_adv_packet->client);
 
 	tt_global_add(bat_priv, orig_node, roam_adv_packet->client,
-		      atomic_read(&orig_node->last_ttvn) + 1, true);
+		      atomic_read(&orig_node->last_ttvn) + 1, true, false);
 
 	/* Roaming phase starts: I have new information but the ttvn has not
 	 * been incremented yet. This flag will make me check all the incoming
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 6ba35a2..6deed44 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -536,7 +536,7 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	if (atomic_read(&bat_priv->mesh_state) == MESH_ACTIVE) {
 		tt_local_remove(bat_priv, dev->dev_addr,
 				"mac address changed", false);
-		tt_local_add(dev, addr->sa_data);
+		tt_local_add(dev, addr->sa_data, NULL_IFINDEX);
 	}
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -595,7 +595,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		goto dropped;
 
 	/* Register the client MAC in the transtable */
-	tt_local_add(soft_iface, ethhdr->h_source);
+	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
 
 	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
 	if (is_multicast_ether_addr(ethhdr->h_dest) ||
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 6004cd8..d630564 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -183,7 +183,8 @@ static int tt_local_init(struct bat_priv *bat_priv)
 	return 1;
 }
 
-void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
+void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
+		  int ifindex)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct tt_local_entry *tt_local_entry = NULL;
@@ -207,6 +208,8 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr)
 	memcpy(tt_local_entry->addr, addr, ETH_ALEN);
 	tt_local_entry->last_seen = jiffies;
 	tt_local_entry->flags = NO_FLAGS;
+	if (is_wifi_iface(ifindex))
+		tt_local_entry->flags |= TT_CLIENT_WIFI;
 	atomic_set(&tt_local_entry->refcount, 2);
 
 	/* the batman interface mac address should never be purged */
@@ -495,7 +498,8 @@ static void tt_changes_list_free(struct bat_priv *bat_priv)
 
 /* caller must hold orig_node refcount */
 int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
-		  const unsigned char *tt_addr, uint8_t ttvn, bool roaming)
+		  const unsigned char *tt_addr, uint8_t ttvn, bool roaming,
+		  bool wifi)
 {
 	struct tt_global_entry *tt_global_entry;
 	struct orig_node *orig_node_tmp;
@@ -537,6 +541,9 @@ int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		tt_global_entry->roam_at = 0;
 	}
 
+	if (wifi)
+		tt_global_entry->flags |= TT_CLIENT_WIFI;
+
 	bat_dbg(DBG_TT, bat_priv,
 		"Creating new global tt entry: %pM (via %pM)\n",
 		tt_global_entry->addr, orig_node->orig);
@@ -1363,7 +1370,9 @@ static void _tt_update_changes(struct bat_priv *bat_priv,
 				      (tt_change + i)->flags & TT_CLIENT_ROAM);
 		else
 			if (!tt_global_add(bat_priv, orig_node,
-					   (tt_change + i)->addr, ttvn, false))
+					   (tt_change + i)->addr, ttvn, false,
+					   (tt_change + i)->flags &
+							TT_CLIENT_WIFI))
 				/* In case of problem while storing a
 				 * global_entry, we stop the updating
 				 * procedure without committing the
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index e6b564d..4d1ca35 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -26,15 +26,16 @@ int tt_len(int changes_num);
 int tt_changes_fill_buffer(struct bat_priv *bat_priv,
 			   unsigned char *buff, int buff_len);
 int tt_init(struct bat_priv *bat_priv);
-void tt_local_add(struct net_device *soft_iface, const uint8_t *addr);
+void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
+		  int ifindex);
 void tt_local_remove(struct bat_priv *bat_priv,
 		     const uint8_t *addr, const char *message, bool roaming);
 int tt_local_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_add_orig(struct bat_priv *bat_priv, struct orig_node *orig_node,
 			const unsigned char *tt_buff, int tt_buff_len);
-int tt_global_add(struct bat_priv *bat_priv,
-		  struct orig_node *orig_node, const unsigned char *addr,
-		  uint8_t ttvn, bool roaming);
+int tt_global_add(struct bat_priv *bat_priv, struct orig_node *orig_node,
+		  const unsigned char *addr, uint8_t ttvn, bool roaming,
+		  bool wifi);
 int tt_global_seq_print_text(struct seq_file *seq, void *offset);
 void tt_global_del_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node, const char *message);
-- 
1.7.5.3
