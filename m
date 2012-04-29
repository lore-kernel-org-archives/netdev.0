From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/15] batman-adv: split neigh_new function into generic and batman iv specific parts
Date: Sun, 29 Apr 2012 10:57:47 +0200
Message-ID: <1335689867-8017-16-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:57909 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802Ab2D2I5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:57:01 -0400
In-Reply-To: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   40 ++++++++++++++++++++++++++++++++++------
 net/batman-adv/originator.c |   27 ++++++++++-----------------
 net/batman-adv/originator.h |    6 ++----
 3 files changed, 46 insertions(+), 27 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 8652a75..4baabf9 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -30,6 +30,32 @@
 #include "send.h"
 #include "bat_algo.h"
 
+static struct neigh_node *bat_iv_ogm_neigh_new(struct hard_iface *hard_iface,
+					       const uint8_t *neigh_addr,
+					       struct orig_node *orig_node,
+					       struct orig_node *orig_neigh,
+					       uint32_t seqno)
+{
+	struct neigh_node *neigh_node;
+
+	neigh_node = neigh_node_new(hard_iface, neigh_addr, seqno);
+	if (!neigh_node)
+		goto out;
+
+	INIT_LIST_HEAD(&neigh_node->bonding_list);
+	spin_lock_init(&neigh_node->tq_lock);
+
+	neigh_node->orig_node = orig_neigh;
+	neigh_node->if_incoming = hard_iface;
+
+	spin_lock_bh(&orig_node->neigh_list_lock);
+	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
+	spin_unlock_bh(&orig_node->neigh_list_lock);
+
+out:
+	return neigh_node;
+}
+
 static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -638,8 +664,9 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		if (!orig_tmp)
 			goto unlock;
 
-		neigh_node = create_neighbor(orig_node, orig_tmp,
-					     ethhdr->h_source, if_incoming);
+		neigh_node = bat_iv_ogm_neigh_new(if_incoming, ethhdr->h_source,
+						  orig_node, orig_tmp,
+						  batman_ogm_packet->seqno);
 
 		orig_node_free_ref(orig_tmp);
 		if (!neigh_node)
@@ -764,10 +791,11 @@ static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
 	rcu_read_unlock();
 
 	if (!neigh_node)
-		neigh_node = create_neighbor(orig_neigh_node,
-					     orig_neigh_node,
-					     orig_neigh_node->orig,
-					     if_incoming);
+		neigh_node = bat_iv_ogm_neigh_new(if_incoming,
+						  orig_neigh_node->orig,
+						  orig_neigh_node,
+						  orig_neigh_node,
+						  batman_ogm_packet->seqno);
 
 	if (!neigh_node)
 		goto out;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a64536c..4432d64 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -86,35 +86,28 @@ struct neigh_node *orig_node_get_router(struct orig_node *orig_node)
 	return router;
 }
 
-struct neigh_node *create_neighbor(struct orig_node *orig_node,
-				   struct orig_node *orig_neigh_node,
-				   const uint8_t *neigh,
-				   struct hard_iface *if_incoming)
+struct neigh_node *neigh_node_new(struct hard_iface *hard_iface,
+				  const uint8_t *neigh_addr, uint32_t seqno)
 {
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct neigh_node *neigh_node;
 
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Creating new last-hop neighbor of originator\n");
-
 	neigh_node = kzalloc(sizeof(*neigh_node), GFP_ATOMIC);
 	if (!neigh_node)
-		return NULL;
+		goto out;
 
 	INIT_HLIST_NODE(&neigh_node->list);
-	INIT_LIST_HEAD(&neigh_node->bonding_list);
-	spin_lock_init(&neigh_node->tq_lock);
 
-	memcpy(neigh_node->addr, neigh, ETH_ALEN);
-	neigh_node->orig_node = orig_neigh_node;
-	neigh_node->if_incoming = if_incoming;
+	memcpy(neigh_node->addr, neigh_addr, ETH_ALEN);
 
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
 
-	spin_lock_bh(&orig_node->neigh_list_lock);
-	hlist_add_head_rcu(&neigh_node->list, &orig_node->neigh_list);
-	spin_unlock_bh(&orig_node->neigh_list_lock);
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Creating new neighbor %pM, initial seqno %d\n",
+		neigh_addr, seqno);
+
+out:
 	return neigh_node;
 }
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 3fe2eda..64c5d94 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -29,10 +29,8 @@ void originator_free(struct bat_priv *bat_priv);
 void purge_orig_ref(struct bat_priv *bat_priv);
 void orig_node_free_ref(struct orig_node *orig_node);
 struct orig_node *get_orig_node(struct bat_priv *bat_priv, const uint8_t *addr);
-struct neigh_node *create_neighbor(struct orig_node *orig_node,
-				   struct orig_node *orig_neigh_node,
-				   const uint8_t *neigh,
-				   struct hard_iface *if_incoming);
+struct neigh_node *neigh_node_new(struct hard_iface *hard_iface,
+				  const uint8_t *neigh_addr, uint32_t seqno);
 void neigh_node_free_ref(struct neigh_node *neigh_node);
 struct neigh_node *orig_node_get_router(struct orig_node *orig_node);
 int orig_seq_print_text(struct seq_file *seq, void *offset);
-- 
1.7.9.4
