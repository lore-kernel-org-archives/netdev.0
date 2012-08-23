From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/18] batman-adv: detect not yet announced clients
Date: Thu, 23 Aug 2012 15:10:25 +0200
Message-ID: <1345727427-20805-17-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28957 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933724Ab2HWNLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:05 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the current TT mechanism a new client joining the network is not
immediately able to communicate with other hosts because its MAC address has not
been announced yet. This situation holds until the first OGM containing its
joining event will be spread over the mesh network.

This behaviour can be acceptable in networks where the originator interval is a
small value (e.g. 1sec) but if that value is set to an higher time (e.g. 5secs)
the client could suffer from several malfunctions like DHCP client timeouts,
etc.

This patch adds an early detection mechanism that makes nodes in the network
able to recognise "not yet announced clients" by means of the broadcast packets
they emitted on connection (e.g. ARP or DHCP request). The added client will
then be confirmed upon receiving the OGM claiming it or purged if such OGM
is not received within a fixed amount of time.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h              |    1 +
 net/batman-adv/packet.h            |    1 +
 net/batman-adv/translation-table.c |  127 +++++++++++++++++++++++++++---------
 net/batman-adv/translation-table.h |    4 +-
 net/batman-adv/types.h             |    1 +
 5 files changed, 101 insertions(+), 33 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 574fca1..61a0cfd 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -43,6 +43,7 @@
 #define BATADV_PURGE_TIMEOUT 200000 /* 200 seconds */
 #define BATADV_TT_LOCAL_TIMEOUT 3600000 /* in milliseconds */
 #define BATADV_TT_CLIENT_ROAM_TIMEOUT 600000 /* in milliseconds */
+#define BATADV_TT_CLIENT_TEMP_TIMEOUT 600000 /* in milliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size)
  */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index eb45934..2d23a14 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -85,6 +85,7 @@ enum batadv_tt_client_flags {
 	BATADV_TT_CLIENT_DEL     = BIT(0),
 	BATADV_TT_CLIENT_ROAM    = BIT(1),
 	BATADV_TT_CLIENT_WIFI    = BIT(2),
+	BATADV_TT_CLIENT_TEMP	 = BIT(3),
 	BATADV_TT_CLIENT_NOPURGE = BIT(8),
 	BATADV_TT_CLIENT_NEW     = BIT(9),
 	BATADV_TT_CLIENT_PENDING = BIT(10),
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cb429d1..112edd3 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -34,6 +34,10 @@ static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t *client,
 static void batadv_tt_purge(struct work_struct *work);
 static void
 batadv_tt_global_del_orig_list(struct batadv_tt_global_entry *tt_global_entry);
+static void batadv_tt_global_del(struct batadv_priv *bat_priv,
+				 struct batadv_orig_node *orig_node,
+				 const unsigned char *addr,
+				 const char *message, bool roaming);
 
 /* returns 1 if they are the same mac addr */
 static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
@@ -268,6 +272,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		tt_local_entry->common.flags |= BATADV_TT_CLIENT_WIFI;
 	atomic_set(&tt_local_entry->common.refcount, 2);
 	tt_local_entry->last_seen = jiffies;
+	tt_local_entry->common.added_at = tt_local_entry->last_seen;
 
 	/* the batman interface mac address should never be purged */
 	if (batadv_compare_eth(addr, soft_iface->dev_addr))
@@ -682,8 +687,13 @@ batadv_tt_global_orig_entry_add(struct batadv_tt_global_entry *tt_global,
 	struct batadv_tt_orig_list_entry *orig_entry;
 
 	orig_entry = batadv_tt_global_orig_entry_find(tt_global, orig_node);
-	if (orig_entry)
+	if (orig_entry) {
+		/* refresh the ttvn: the current value could be a bogus one that
+		 * was added during a "temporary client detection"
+		 */
+		orig_entry->ttvn = ttvn;
 		goto out;
+	}
 
 	orig_entry = kzalloc(sizeof(*orig_entry), GFP_ATOMIC);
 	if (!orig_entry)
@@ -729,6 +739,7 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 		common->flags = flags;
 		tt_global_entry->roam_at = 0;
 		atomic_set(&common->refcount, 2);
+		common->added_at = jiffies;
 
 		INIT_HLIST_HEAD(&tt_global_entry->orig_list);
 		spin_lock_init(&tt_global_entry->list_lock);
@@ -744,7 +755,19 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			goto out_remove;
 		}
 	} else {
-		/* there is already a global entry, use this one. */
+		/* If there is already a global entry, we can use this one for
+		 * our processing.
+		 * But if we are trying to add a temporary client we can exit
+		 * directly because the temporary information should never
+		 * override any already known client state (whatever it is)
+		 */
+		if (flags & BATADV_TT_CLIENT_TEMP)
+			goto out;
+
+		/* if the client was temporary added before receiving the first
+		 * OGM announcing it, we have to clear the TEMP flag
+		 */
+		tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_TEMP;
 
 		/* If there is the BATADV_TT_CLIENT_ROAM flag set, there is only
 		 * one originator left in the list and we previously received a
@@ -758,9 +781,8 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_ROAM;
 			tt_global_entry->roam_at = 0;
 		}
-
 	}
-	/* add the new orig_entry (if needed) */
+	/* add the new orig_entry (if needed) or update it */
 	batadv_tt_global_orig_entry_add(tt_global_entry, orig_node, ttvn);
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
@@ -800,11 +822,12 @@ batadv_tt_global_print_entry(struct batadv_tt_global_entry *tt_global_entry,
 	hlist_for_each_entry_rcu(orig_entry, node, head, list) {
 		flags = tt_common_entry->flags;
 		last_ttvn = atomic_read(&orig_entry->orig_node->last_ttvn);
-		seq_printf(seq, " * %pM  (%3u) via %pM     (%3u)   [%c%c]\n",
+		seq_printf(seq,	" * %pM  (%3u) via %pM     (%3u)   [%c%c%c]\n",
 			   tt_global_entry->common.addr, orig_entry->ttvn,
 			   orig_entry->orig_node->orig, last_ttvn,
 			   (flags & BATADV_TT_CLIENT_ROAM ? 'R' : '.'),
-			   (flags & BATADV_TT_CLIENT_WIFI ? 'W' : '.'));
+			   (flags & BATADV_TT_CLIENT_WIFI ? 'W' : '.'),
+			   (flags & BATADV_TT_CLIENT_TEMP ? 'T' : '.'));
 	}
 }
 
@@ -1059,49 +1082,63 @@ void batadv_tt_global_del_orig(struct batadv_priv *bat_priv,
 	orig_node->tt_initialised = false;
 }
 
-static void batadv_tt_global_roam_purge_list(struct batadv_priv *bat_priv,
-					     struct hlist_head *head)
+static bool batadv_tt_global_to_purge(struct batadv_tt_global_entry *tt_global,
+				      char **msg)
 {
-	struct batadv_tt_common_entry *tt_common_entry;
-	struct batadv_tt_global_entry *tt_global_entry;
-	struct hlist_node *node, *node_tmp;
+	bool purge = false;
+	unsigned long roam_timeout = BATADV_TT_CLIENT_ROAM_TIMEOUT;
+	unsigned long temp_timeout = BATADV_TT_CLIENT_TEMP_TIMEOUT;
 
-	hlist_for_each_entry_safe(tt_common_entry, node, node_tmp, head,
-				  hash_entry) {
-		tt_global_entry = container_of(tt_common_entry,
-					       struct batadv_tt_global_entry,
-					       common);
-		if (!(tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM))
-			continue;
-		if (!batadv_has_timed_out(tt_global_entry->roam_at,
-					  BATADV_TT_CLIENT_ROAM_TIMEOUT))
-			continue;
-
-		batadv_dbg(BATADV_DBG_TT, bat_priv,
-			   "Deleting global tt entry (%pM): Roaming timeout\n",
-			   tt_global_entry->common.addr);
+	if ((tt_global->common.flags & BATADV_TT_CLIENT_ROAM) &&
+	    batadv_has_timed_out(tt_global->roam_at, roam_timeout)) {
+		purge = true;
+		*msg = "Roaming timeout\n";
+	}
 
-		hlist_del_rcu(node);
-		batadv_tt_global_entry_free_ref(tt_global_entry);
+	if ((tt_global->common.flags & BATADV_TT_CLIENT_TEMP) &&
+	    batadv_has_timed_out(tt_global->common.added_at, temp_timeout)) {
+		purge = true;
+		*msg = "Temporary client timeout\n";
 	}
+
+	return purge;
 }
 
-static void batadv_tt_global_roam_purge(struct batadv_priv *bat_priv)
+static void batadv_tt_global_purge(struct batadv_priv *bat_priv)
 {
 	struct batadv_hashtable *hash = bat_priv->tt.global_hash;
 	struct hlist_head *head;
+	struct hlist_node *node, *node_tmp;
 	spinlock_t *list_lock; /* protects write access to the hash lists */
 	uint32_t i;
+	char *msg = NULL;
+	struct batadv_tt_common_entry *tt_common;
+	struct batadv_tt_global_entry *tt_global;
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
 		list_lock = &hash->list_locks[i];
 
 		spin_lock_bh(list_lock);
-		batadv_tt_global_roam_purge_list(bat_priv, head);
+		hlist_for_each_entry_safe(tt_common, node, node_tmp, head,
+					  hash_entry) {
+			tt_global = container_of(tt_common,
+						 struct batadv_tt_global_entry,
+						 common);
+
+			if (!batadv_tt_global_to_purge(tt_global, &msg))
+				continue;
+
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
+				   "Deleting global tt entry (%pM): %s\n",
+				   tt_global->common.addr, msg);
+
+			hlist_del_rcu(node);
+
+			batadv_tt_global_entry_free_ref(tt_global);
+		}
 		spin_unlock_bh(list_lock);
 	}
-
 }
 
 static void batadv_tt_global_table_free(struct batadv_priv *bat_priv)
@@ -1239,6 +1276,12 @@ static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
 			 */
 			if (tt_common->flags & BATADV_TT_CLIENT_ROAM)
 				continue;
+			/* Temporary clients have not been announced yet, so
+			 * they have to be skipped while computing the global
+			 * crc
+			 */
+			if (tt_common->flags & BATADV_TT_CLIENT_TEMP)
+				continue;
 
 			/* find out if this global entry is announced by this
 			 * originator
@@ -1392,7 +1435,8 @@ static int batadv_tt_global_valid(const void *entry_ptr,
 	const struct batadv_tt_global_entry *tt_global_entry;
 	const struct batadv_orig_node *orig_node = data_ptr;
 
-	if (tt_common_entry->flags & BATADV_TT_CLIENT_ROAM)
+	if (tt_common_entry->flags & BATADV_TT_CLIENT_ROAM ||
+	    tt_common_entry->flags & BATADV_TT_CLIENT_TEMP)
 		return 0;
 
 	tt_global_entry = container_of(tt_common_entry,
@@ -2125,7 +2169,7 @@ static void batadv_tt_purge(struct work_struct *work)
 	bat_priv = container_of(priv_tt, struct batadv_priv, tt);
 
 	batadv_tt_local_purge(bat_priv);
-	batadv_tt_global_roam_purge(bat_priv);
+	batadv_tt_global_purge(bat_priv);
 	batadv_tt_req_purge(bat_priv);
 	batadv_tt_roam_purge(bat_priv);
 
@@ -2399,3 +2443,22 @@ bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 out:
 	return ret;
 }
+
+bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig_node,
+					  const unsigned char *addr)
+{
+	bool ret = false;
+
+	if (!batadv_tt_global_add(bat_priv, orig_node, addr,
+				  BATADV_TT_CLIENT_TEMP,
+				  atomic_read(&orig_node->last_ttvn)))
+		goto out;
+
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
+		   "Added temporary global client (addr: %pM orig: %pM)\n",
+		   addr, orig_node->orig);
+	ret = true;
+out:
+	return ret;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index ffa8735..811fffd 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -59,6 +59,8 @@ int batadv_tt_append_diff(struct batadv_priv *bat_priv,
 			  int packet_min_len);
 bool batadv_tt_global_client_is_roaming(struct batadv_priv *bat_priv,
 					uint8_t *addr);
-
+bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig_node,
+					  const unsigned char *addr);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 97c4978..2ed82ca 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -284,6 +284,7 @@ struct batadv_tt_common_entry {
 	uint8_t addr[ETH_ALEN];
 	struct hlist_node hash_entry;
 	uint16_t flags;
+	unsigned long added_at;
 	atomic_t refcount;
 	struct rcu_head rcu;
 };
-- 
1.7.9.4
