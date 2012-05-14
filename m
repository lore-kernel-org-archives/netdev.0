From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 3/8] batman-adv: prepare lq_update_lock to be shared among different protocols
Date: Mon, 14 May 2012 09:17:33 +0200
Message-ID: <1336979858-13928-4-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51725 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569Ab2ENHRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:10 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    9 ++++-----
 net/batman-adv/originator.c |    1 +
 net/batman-adv/types.h      |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index abd10c4..dc53798 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -43,7 +43,6 @@ static struct neigh_node *bat_iv_ogm_neigh_new(struct hard_iface *hard_iface,
 		goto out;
 
 	INIT_LIST_HEAD(&neigh_node->bonding_list);
-	spin_lock_init(&neigh_node->tq_lock);
 
 	neigh_node->orig_node = orig_neigh;
 	neigh_node->if_incoming = hard_iface;
@@ -637,12 +636,12 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 		if (is_duplicate)
 			continue;
 
-		spin_lock_bh(&tmp_neigh_node->tq_lock);
+		spin_lock_bh(&tmp_neigh_node->lq_update_lock);
 		ring_buffer_set(tmp_neigh_node->tq_recv,
 				&tmp_neigh_node->tq_index, 0);
 		tmp_neigh_node->tq_avg =
 			ring_buffer_avg(tmp_neigh_node->tq_recv);
-		spin_unlock_bh(&tmp_neigh_node->tq_lock);
+		spin_unlock_bh(&tmp_neigh_node->lq_update_lock);
 	}
 
 	if (!neigh_node) {
@@ -668,12 +667,12 @@ static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
 	orig_node->flags = batman_ogm_packet->flags;
 	neigh_node->last_seen = jiffies;
 
-	spin_lock_bh(&neigh_node->tq_lock);
+	spin_lock_bh(&neigh_node->lq_update_lock);
 	ring_buffer_set(neigh_node->tq_recv,
 			&neigh_node->tq_index,
 			batman_ogm_packet->tq);
 	neigh_node->tq_avg = ring_buffer_avg(neigh_node->tq_recv);
-	spin_unlock_bh(&neigh_node->tq_lock);
+	spin_unlock_bh(&neigh_node->lq_update_lock);
 
 	if (!is_duplicate) {
 		orig_node->last_ttl = batman_ogm_packet->header.ttl;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f4b6201..41147942 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -99,6 +99,7 @@ struct neigh_node *batadv_neigh_node_new(struct hard_iface *hard_iface,
 	INIT_HLIST_NODE(&neigh_node->list);
 
 	memcpy(neigh_node->addr, neigh_addr, ETH_ALEN);
+	spin_lock_init(&neigh_node->lq_update_lock);
 
 	/* extra reference for return */
 	atomic_set(&neigh_node->refcount, 2);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 66a3750..61308e8 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -137,7 +137,7 @@ struct neigh_node {
 	struct rcu_head rcu;
 	struct orig_node *orig_node;
 	struct hard_iface *if_incoming;
-	spinlock_t tq_lock;	/* protects: tq_recv, tq_index */
+	spinlock_t lq_update_lock;	/* protects: tq_recv, tq_index */
 };
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-- 
1.7.9.4
