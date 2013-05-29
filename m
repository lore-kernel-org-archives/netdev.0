From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/21] batman-adv: refactor batadv_tt_local_event()
Date: Wed, 29 May 2013 02:59:38 +0200
Message-ID: <1369789186-3600-14-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43871 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934301Ab3E2BBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:54 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Instead of passing a generic combination of flags as
argument, it is easier to pass the entire tt_common
structure (containing the flags already set) plus a
bitfield of event flags that will be unified with
the already existing ones before inserting the client
in the event queue.
In this way invocations of the modified function can be
simplified.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 9e87485..d35b739 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -163,10 +163,19 @@ batadv_tt_orig_list_entry_free_ref(struct batadv_tt_orig_list_entry *orig_entry)
 	call_rcu(&orig_entry->rcu, batadv_tt_orig_list_entry_free_rcu);
 }
 
+/**
+ * batadv_tt_local_event - store a local TT event (ADD/DEL)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tt_local_entry: the TT entry involved in the event
+ * @event_flags: flags to store in the event structure
+ */
 static void batadv_tt_local_event(struct batadv_priv *bat_priv,
-				  const uint8_t *addr, uint8_t flags)
+				  struct batadv_tt_local_entry *tt_local_entry,
+				  uint8_t event_flags)
 {
 	struct batadv_tt_change_node *tt_change_node, *entry, *safe;
+	struct batadv_tt_common_entry *common = &tt_local_entry->common;
+	uint8_t flags = common->flags | event_flags;
 	bool event_removed = false;
 	bool del_op_requested, del_op_entry;
 
@@ -176,7 +185,7 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 		return;
 
 	tt_change_node->change.flags = flags;
-	memcpy(tt_change_node->change.addr, addr, ETH_ALEN);
+	memcpy(tt_change_node->change.addr, common->addr, ETH_ALEN);
 
 	del_op_requested = flags & BATADV_TT_CLIENT_DEL;
 
@@ -184,7 +193,7 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 	spin_lock_bh(&bat_priv->tt.changes_list_lock);
 	list_for_each_entry_safe(entry, safe, &bat_priv->tt.changes_list,
 				 list) {
-		if (!batadv_compare_eth(entry->change.addr, addr))
+		if (!batadv_compare_eth(entry->change.addr, common->addr))
 			continue;
 
 		/* DEL+ADD in the same orig interval have no effect and can be
@@ -332,7 +341,7 @@ void batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	}
 
 add_event:
-	batadv_tt_local_event(bat_priv, addr, tt_local->common.flags);
+	batadv_tt_local_event(bat_priv, tt_local, BATADV_NO_FLAGS);
 
 check_roaming:
 	/* Check whether it is a roaming, but don't do anything if the roaming
@@ -529,8 +538,7 @@ batadv_tt_local_set_pending(struct batadv_priv *bat_priv,
 			    struct batadv_tt_local_entry *tt_local_entry,
 			    uint16_t flags, const char *message)
 {
-	batadv_tt_local_event(bat_priv, tt_local_entry->common.addr,
-			      tt_local_entry->common.flags | flags);
+	batadv_tt_local_event(bat_priv, tt_local_entry, flags);
 
 	/* The local client has to be marked as "pending to be removed" but has
 	 * to be kept in the table in order to send it in a full table
@@ -584,8 +592,7 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 	/* if this client has been added right now, it is possible to
 	 * immediately purge it
 	 */
-	batadv_tt_local_event(bat_priv, tt_local_entry->common.addr,
-			      curr_flags | BATADV_TT_CLIENT_DEL);
+	batadv_tt_local_event(bat_priv, tt_local_entry, BATADV_TT_CLIENT_DEL);
 	hlist_del_rcu(&tt_local_entry->common.hash_entry);
 	batadv_tt_local_entry_free_ref(tt_local_entry);
 
-- 
1.8.1.5
