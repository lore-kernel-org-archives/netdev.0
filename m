From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/18] batman-adv: clear ADD+DEL (and viceversa) events in the same orig-interval
Date: Thu, 28 Jun 2012 11:34:15 +0200
Message-ID: <1340876067-28333-7-git-send-email-ordex@autistici.org>
References: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:30235 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932739Ab2F1Jea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 05:34:30 -0400
In-Reply-To: <1340876067-28333-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During an OGM-interval (time between two different OGM sendings) the same client
could roam away and then roam back to us. In this case the node would add two
events to the events list (that is going to be sent appended to the next OGM). A
DEL one and an ADD one. Obviously they will only increase the overhead (either in
the air and on the receiver side) and eventually trigger wrong states/events
without producing any real effect.

For this reason we can safely delete any ADD event with its related DEL one.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/translation-table.c |   40 +++++++++++++++++++++++++++++++++---
 1 file changed, 37 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 074936f..d82766b 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -157,7 +157,9 @@ batadv_tt_orig_list_entry_free_ref(struct tt_orig_list_entry *orig_entry)
 static void batadv_tt_local_event(struct bat_priv *bat_priv,
 				  const uint8_t *addr, uint8_t flags)
 {
-	struct tt_change_node *tt_change_node;
+	struct tt_change_node *tt_change_node, *entry, *safe;
+	bool event_removed = false;
+	bool del_op_requested, del_op_entry;
 
 	tt_change_node = kmalloc(sizeof(*tt_change_node), GFP_ATOMIC);
 
@@ -167,13 +169,45 @@ static void batadv_tt_local_event(struct bat_priv *bat_priv,
 	tt_change_node->change.flags = flags;
 	memcpy(tt_change_node->change.addr, addr, ETH_ALEN);
 
+	del_op_requested = flags & TT_CLIENT_DEL;
+
+	/* check for ADD+DEL or DEL+ADD events */
 	spin_lock_bh(&bat_priv->tt_changes_list_lock);
+	list_for_each_entry_safe(entry, safe, &bat_priv->tt_changes_list,
+				 list) {
+		if (!batadv_compare_eth(entry->change.addr, addr))
+			continue;
+
+		/* DEL+ADD in the same orig interval have no effect and can be
+		 * removed to avoid silly behaviour on the receiver side. The
+		 * other way around (ADD+DEL) can happen in case of roaming of
+		 * a client still in the NEW state. Roaming of NEW clients is
+		 * now possible due to automatically recognition of "temporary"
+		 * clients
+		 */
+		del_op_entry = entry->change.flags & TT_CLIENT_DEL;
+		if (!del_op_requested && del_op_entry)
+			goto del;
+		if (del_op_requested && !del_op_entry)
+			goto del;
+		continue;
+del:
+		list_del(&entry->list);
+		kfree(entry);
+		event_removed = true;
+		goto unlock;
+	}
+
 	/* track the change in the OGMinterval list */
 	list_add_tail(&tt_change_node->list, &bat_priv->tt_changes_list);
-	atomic_inc(&bat_priv->tt_local_changes);
+
+unlock:
 	spin_unlock_bh(&bat_priv->tt_changes_list_lock);
 
-	atomic_set(&bat_priv->tt_ogm_append_cnt, 0);
+	if (event_removed)
+		atomic_dec(&bat_priv->tt_local_changes);
+	else
+		atomic_inc(&bat_priv->tt_local_changes);
 }
 
 int batadv_tt_len(int changes_num)
-- 
1.7.9.4
