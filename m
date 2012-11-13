From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/11] batman-adv: roaming handling mechanism redesign
Date: Tue, 13 Nov 2012 10:15:38 +0100
Message-ID: <1352798139-19458-11-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52775 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685Ab2KMJQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:37 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows clients to roam multiple times within the same
originator-interval.

To enable this new feature two key aspects that have been introduced:
1) packets are always directed to the node that was originally
serving the roamed client which will then re-route the data
to the correct destination at any point in time;
2) the client flags handling mechanism has been properly modified
in order to allow multiple roamings withinin the same orig-int.
Therefore flags are now set properly even in this scenario.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c | 157 ++++++++++++++++++++++++++++---------
 1 file changed, 118 insertions(+), 39 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index cb8433a..dd2c254 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -238,6 +238,20 @@ static int batadv_tt_local_init(struct batadv_priv *bat_priv)
 	return 0;
 }
 
+static void batadv_tt_global_free(struct batadv_priv *bat_priv,
+				  struct batadv_tt_global_entry *tt_global,
+				  const char *message)
+{
+	batadv_dbg(BATADV_DBG_TT, bat_priv,
+		   "Deleting global tt entry %pM: %s\n",
+		   tt_global->common.addr, message);
+
+	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
+			   batadv_choose_orig, tt_global->common.addr);
+	batadv_tt_global_entry_free_ref(tt_global);
+
+}
+
 void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 int ifindex)
 {
@@ -248,14 +262,38 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct hlist_node *node;
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added;
+	bool roamed_back = false;
 
 	tt_local = batadv_tt_local_hash_find(bat_priv, addr);
+	tt_global = batadv_tt_global_hash_find(bat_priv, addr);
 
 	if (tt_local) {
 		tt_local->last_seen = jiffies;
-		/* possibly unset the BATADV_TT_CLIENT_PENDING flag */
-		tt_local->common.flags &= ~BATADV_TT_CLIENT_PENDING;
-		goto out;
+		if (tt_local->common.flags & BATADV_TT_CLIENT_PENDING) {
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
+				   "Re-adding pending client %pM\n", addr);
+			/* whatever the reason why the PENDING flag was set,
+			 * this is a client which was enqueued to be removed in
+			 * this orig_interval. Since it popped up again, the
+			 * flag can be reset like it was never enqueued
+			 */
+			tt_local->common.flags &= ~BATADV_TT_CLIENT_PENDING;
+			goto add_event;
+		}
+
+		if (tt_local->common.flags & BATADV_TT_CLIENT_ROAM) {
+			batadv_dbg(BATADV_DBG_TT, bat_priv,
+				   "Roaming client %pM came back to its original location\n",
+				   addr);
+			/* the ROAM flag is set because this client roamed away
+			 * and the node got a roaming_advertisement message. Now
+			 * that the client popped up again at its original
+			 * location such flag can be unset
+			 */
+			tt_local->common.flags &= ~BATADV_TT_CLIENT_ROAM;
+			roamed_back = true;
+		}
+		goto check_roaming;
 	}
 
 	tt_local = kmalloc(sizeof(*tt_local), GFP_ATOMIC);
@@ -294,13 +332,14 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 		goto out;
 	}
 
+add_event:
 	batadv_tt_local_event(bat_priv, addr, tt_local->common.flags);
 
-	/* remove address from global hash if present */
-	tt_global = batadv_tt_global_hash_find(bat_priv, addr);
-
-	/* Check whether it is a roaming! */
-	if (tt_global) {
+check_roaming:
+	/* Check whether it is a roaming, but don't do anything if the roaming
+	 * process has already been handled
+	 */
+	if (tt_global && !(tt_global->common.flags & BATADV_TT_CLIENT_ROAM)) {
 		/* These node are probably going to update their tt table */
 		head = &tt_global->orig_list;
 		rcu_read_lock();
@@ -309,12 +348,19 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 					     orig_entry->orig_node);
 		}
 		rcu_read_unlock();
-		/* The global entry has to be marked as ROAMING and
-		 * has to be kept for consistency purpose
-		 */
-		tt_global->common.flags |= BATADV_TT_CLIENT_ROAM;
-		tt_global->roam_at = jiffies;
+		if (roamed_back) {
+			batadv_tt_global_free(bat_priv, tt_global,
+					      "Roaming canceled");
+			tt_global = NULL;
+		} else {
+			/* The global entry has to be marked as ROAMING and
+			 * has to be kept for consistency purpose
+			 */
+			tt_global->common.flags |= BATADV_TT_CLIENT_ROAM;
+			tt_global->roam_at = jiffies;
+		}
 	}
+
 out:
 	if (tt_local)
 		batadv_tt_local_entry_free_ref(tt_local);
@@ -508,13 +554,28 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 	curr_flags = tt_local_entry->common.flags;
 
 	flags = BATADV_TT_CLIENT_DEL;
+	/* if this global entry addition is due to a roaming, the node has to
+	 * mark the local entry as "roamed" in order to correctly reroute
+	 * packets later
+	 */
 	if (roaming) {
 		flags |= BATADV_TT_CLIENT_ROAM;
 		/* mark the local client as ROAMed */
 		tt_local_entry->common.flags |= BATADV_TT_CLIENT_ROAM;
 	}
 
-	batadv_tt_local_set_pending(bat_priv, tt_local_entry, flags, message);
+	if (!(tt_local_entry->common.flags & BATADV_TT_CLIENT_NEW)) {
+		batadv_tt_local_set_pending(bat_priv, tt_local_entry, flags,
+					    message);
+		goto out;
+	}
+	/* if this client has been added right now, it is possible to
+	 * immediately purge it
+	 */
+	batadv_tt_local_event(bat_priv, tt_local_entry->common.addr,
+			      curr_flags | BATADV_TT_CLIENT_DEL);
+	hlist_del_rcu(&tt_local_entry->common.hash_entry);
+	batadv_tt_local_entry_free_ref(tt_local_entry);
 
 out:
 	if (tt_local_entry)
@@ -724,12 +785,22 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			 uint8_t ttvn)
 {
 	struct batadv_tt_global_entry *tt_global_entry = NULL;
+	struct batadv_tt_local_entry *tt_local_entry = NULL;
 	int ret = 0;
 	int hash_added;
 	struct batadv_tt_common_entry *common;
 	uint16_t local_flags;
 
 	tt_global_entry = batadv_tt_global_hash_find(bat_priv, tt_addr);
+	tt_local_entry = batadv_tt_local_hash_find(bat_priv, tt_addr);
+
+	/* if the node already has a local client for this entry, it has to wait
+	 * for a roaming advertisement instead of manually messing up the global
+	 * table
+	 */
+	if ((flags & BATADV_TT_CLIENT_TEMP) && tt_local_entry &&
+	    !(tt_local_entry->common.flags & BATADV_TT_CLIENT_NEW))
+		goto out;
 
 	if (!tt_global_entry) {
 		tt_global_entry = kzalloc(sizeof(*tt_global_entry), GFP_ATOMIC);
@@ -764,19 +835,31 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 			goto out_remove;
 		}
 	} else {
+		common = &tt_global_entry->common;
 		/* If there is already a global entry, we can use this one for
 		 * our processing.
-		 * But if we are trying to add a temporary client we can exit
-		 * directly because the temporary information should never
-		 * override any already known client state (whatever it is)
+		 * But if we are trying to add a temporary client then here are
+		 * two options at this point:
+		 * 1) the global client is not a temporary client: the global
+		 *    client has to be left as it is, temporary information
+		 *    should never override any already known client state
+		 * 2) the global client is a temporary client: purge the
+		 *    originator list and add the new one orig_entry
 		 */
-		if (flags & BATADV_TT_CLIENT_TEMP)
-			goto out;
+		if (flags & BATADV_TT_CLIENT_TEMP) {
+			if (!(common->flags & BATADV_TT_CLIENT_TEMP))
+				goto out;
+			if (batadv_tt_global_entry_has_orig(tt_global_entry,
+							    orig_node))
+				goto out_remove;
+			batadv_tt_global_del_orig_list(tt_global_entry);
+			goto add_orig_entry;
+		}
 
 		/* if the client was temporary added before receiving the first
 		 * OGM announcing it, we have to clear the TEMP flag
 		 */
-		tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_TEMP;
+		common->flags &= ~BATADV_TT_CLIENT_TEMP;
 
 		/* If there is the BATADV_TT_CLIENT_ROAM flag set, there is only
 		 * one originator left in the list and we previously received a
@@ -785,18 +868,19 @@ int batadv_tt_global_add(struct batadv_priv *bat_priv,
 		 * We should first delete the old originator before adding the
 		 * new one.
 		 */
-		if (tt_global_entry->common.flags & BATADV_TT_CLIENT_ROAM) {
+		if (common->flags & BATADV_TT_CLIENT_ROAM) {
 			batadv_tt_global_del_orig_list(tt_global_entry);
-			tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_ROAM;
+			common->flags &= ~BATADV_TT_CLIENT_ROAM;
 			tt_global_entry->roam_at = 0;
 		}
 	}
+add_orig_entry:
 	/* add the new orig_entry (if needed) or update it */
 	batadv_tt_global_orig_entry_add(tt_global_entry, orig_node, ttvn);
 
 	batadv_dbg(BATADV_DBG_TT, bat_priv,
 		   "Creating new global tt entry: %pM (via %pM)\n",
-		   tt_global_entry->common.addr, orig_node->orig);
+		   common->addr, orig_node->orig);
 	ret = 1;
 
 out_remove:
@@ -804,12 +888,20 @@ out_remove:
 	/* remove address from local hash if present */
 	local_flags = batadv_tt_local_remove(bat_priv, tt_addr,
 					     "global tt received",
-					     flags & BATADV_TT_CLIENT_ROAM);
+					     !!(flags & BATADV_TT_CLIENT_ROAM));
 	tt_global_entry->common.flags |= local_flags & BATADV_TT_CLIENT_WIFI;
 
+	if (!(flags & BATADV_TT_CLIENT_ROAM))
+		/* this is a normal global add. Therefore the client is not in a
+		 * roaming state anymore.
+		 */
+		tt_global_entry->common.flags &= ~BATADV_TT_CLIENT_ROAM;
+
 out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
+	if (tt_local_entry)
+		batadv_tt_local_entry_free_ref(tt_local_entry);
 	return ret;
 }
 
@@ -927,20 +1019,6 @@ batadv_tt_global_del_orig_entry(struct batadv_priv *bat_priv,
 	spin_unlock_bh(&tt_global_entry->list_lock);
 }
 
-static void batadv_tt_global_free(struct batadv_priv *bat_priv,
-				  struct batadv_tt_global_entry *tt_global,
-				  const char *message)
-{
-	batadv_dbg(BATADV_DBG_TT, bat_priv,
-		   "Deleting global tt entry %pM: %s\n",
-		   tt_global->common.addr, message);
-
-	batadv_hash_remove(bat_priv->tt.global_hash, batadv_compare_tt,
-			   batadv_choose_orig, tt_global->common.addr);
-	batadv_tt_global_entry_free_ref(tt_global);
-
-}
-
 /* If the client is to be deleted, we check if it is the last origantor entry
  * within tt_global entry. If yes, we set the BATADV_TT_CLIENT_ROAM flag and the
  * timer, otherwise we simply remove the originator scheduled for deletion.
@@ -1204,7 +1282,8 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 
 	if (src && atomic_read(&bat_priv->ap_isolation)) {
 		tt_local_entry = batadv_tt_local_hash_find(bat_priv, src);
-		if (!tt_local_entry)
+		if (!tt_local_entry ||
+		    (tt_local_entry->common.flags & BATADV_TT_CLIENT_PENDING))
 			goto out;
 	}
 
-- 
1.8.0
