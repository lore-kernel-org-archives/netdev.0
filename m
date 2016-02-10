From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 20/21] batman-adv: Convert batadv_orig_node to kref
Date: Wed, 10 Feb 2016 23:57:26 +0800
Message-ID: <1455119847-5862-21-git-send-email-a__40568.6198304922$1455121073$gmane$org@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:12554 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752144AbcBJQRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:17:38 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/gateway_client.c        |  4 ++--
 net/batman-adv/multicast.c             |  7 ++++---
 net/batman-adv/network-coding.c        |  2 +-
 net/batman-adv/originator.c            | 14 +++++++++-----
 net/batman-adv/originator.h            |  4 ++--
 net/batman-adv/translation-table.c     |  4 ++--
 net/batman-adv/types.h                 |  2 +-
 8 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 921e25255cab..e3261118130a 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -542,7 +542,7 @@ static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
 							  max_orig_node))
 				continue;
 
-			if (!atomic_inc_not_zero(&orig_node->refcount))
+			if (!kref_get_unless_zero(&orig_node->refcount))
 				continue;
 
 			max = tmp_max;
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 1f3847c61db8..261866e38502 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -118,7 +118,7 @@ batadv_gw_get_selected_orig(struct batadv_priv *bat_priv)
 	if (!orig_node)
 		goto unlock;
 
-	if (!atomic_inc_not_zero(&orig_node->refcount))
+	if (!kref_get_unless_zero(&orig_node->refcount))
 		orig_node = NULL;
 
 unlock:
@@ -441,7 +441,7 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 	if (gateway->bandwidth_down == 0)
 		return;
 
-	if (!atomic_inc_not_zero(&orig_node->refcount))
+	if (!kref_get_unless_zero(&orig_node->refcount))
 		return;
 
 	gw_node = kzalloc(sizeof(*gw_node), GFP_ATOMIC);
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 155565e0fecc..8caa2c72efa3 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -30,6 +30,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
@@ -447,7 +448,7 @@ batadv_mcast_forw_ipv4_node_get(struct batadv_priv *bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_ipv4_list,
 				 mcast_want_all_ipv4_node) {
-		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
+		if (!kref_get_unless_zero(&tmp_orig_node->refcount))
 			continue;
 
 		orig_node = tmp_orig_node;
@@ -474,7 +475,7 @@ batadv_mcast_forw_ipv6_node_get(struct batadv_priv *bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_ipv6_list,
 				 mcast_want_all_ipv6_node) {
-		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
+		if (!kref_get_unless_zero(&tmp_orig_node->refcount))
 			continue;
 
 		orig_node = tmp_orig_node;
@@ -525,7 +526,7 @@ batadv_mcast_forw_unsnoop_node_get(struct batadv_priv *bat_priv)
 	hlist_for_each_entry_rcu(tmp_orig_node,
 				 &bat_priv->mcast.want_all_unsnoopables_list,
 				 mcast_want_all_unsnoopables_node) {
-		if (!atomic_inc_not_zero(&tmp_orig_node->refcount))
+		if (!kref_get_unless_zero(&tmp_orig_node->refcount))
 			continue;
 
 		orig_node = tmp_orig_node;
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 371fc6bbf9d6..a4eb8ee4abb1 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -858,7 +858,7 @@ static struct batadv_nc_node
 	if (!nc_node)
 		return NULL;
 
-	if (!atomic_inc_not_zero(&orig_neigh_node->refcount))
+	if (!kref_get_unless_zero(&orig_neigh_node->refcount))
 		goto free;
 
 	/* Initialize nc_node */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8b2ef8de93e9..eacd0e5a0238 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -18,6 +18,7 @@
 #include "originator.h"
 #include "main.h"
 
+#include <linux/atomic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
@@ -775,14 +776,17 @@ static void batadv_orig_node_free_rcu(struct rcu_head *rcu)
 /**
  * batadv_orig_node_release - release orig_node from lists and queue for
  *  free after rcu grace period
- * @orig_node: the orig node to free
+ * @ref: kref pointer of the orig_node
  */
-static void batadv_orig_node_release(struct batadv_orig_node *orig_node)
+static void batadv_orig_node_release(struct kref *ref)
 {
 	struct hlist_node *node_tmp;
 	struct batadv_neigh_node *neigh_node;
+	struct batadv_orig_node *orig_node;
 	struct batadv_orig_ifinfo *orig_ifinfo;
 
+	orig_node = container_of(ref, struct batadv_orig_node, refcount);
+
 	spin_lock_bh(&orig_node->neigh_list_lock);
 
 	/* for all neighbors towards this originator ... */
@@ -812,8 +816,7 @@ static void batadv_orig_node_release(struct batadv_orig_node *orig_node)
  */
 void batadv_orig_node_free_ref(struct batadv_orig_node *orig_node)
 {
-	if (atomic_dec_and_test(&orig_node->refcount))
-		batadv_orig_node_release(orig_node);
+	kref_put(&orig_node->refcount, batadv_orig_node_release);
 }
 
 void batadv_originator_free(struct batadv_priv *bat_priv)
@@ -885,7 +888,8 @@ struct batadv_orig_node *batadv_orig_node_new(struct batadv_priv *bat_priv,
 	batadv_nc_init_orig(orig_node);
 
 	/* extra reference for return */
-	atomic_set(&orig_node->refcount, 2);
+	kref_init(&orig_node->refcount);
+	kref_get(&orig_node->refcount);
 
 	orig_node->bat_priv = bat_priv;
 	ether_addr_copy(orig_node->orig, addr);
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 745b4e4fcdc4..99507408f4cf 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -20,10 +20,10 @@
 
 #include "main.h"
 
-#include <linux/atomic.h>
 #include <linux/compiler.h>
 #include <linux/if_ether.h>
 #include <linux/jhash.h>
+#include <linux/kref.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/stddef.h>
@@ -115,7 +115,7 @@ batadv_orig_hash_find(struct batadv_priv *bat_priv, const void *data)
 		if (!batadv_compare_eth(orig_node, data))
 			continue;
 
-		if (!atomic_inc_not_zero(&orig_node->refcount))
+		if (!kref_get_unless_zero(&orig_node->refcount))
 			continue;
 
 		orig_node_tmp = orig_node;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 68494a10848c..96b1571213bd 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1334,7 +1334,7 @@ batadv_tt_global_orig_entry_add(struct batadv_tt_global_entry *tt_global,
 		goto out;
 
 	INIT_HLIST_NODE(&orig_entry->list);
-	atomic_inc(&orig_node->refcount);
+	kref_get(&orig_node->refcount);
 	batadv_tt_global_size_inc(orig_node, tt_global->common.vid);
 	orig_entry->orig_node = orig_node;
 	orig_entry->ttvn = ttvn;
@@ -2097,7 +2097,7 @@ struct batadv_orig_node *batadv_transtable_search(struct batadv_priv *bat_priv,
 	/* found anything? */
 	if (best_entry)
 		orig_node = best_entry->orig_node;
-	if (orig_node && !atomic_inc_not_zero(&orig_node->refcount))
+	if (orig_node && !kref_get_unless_zero(&orig_node->refcount))
 		orig_node = NULL;
 	rcu_read_unlock();
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 504f3dbdbcc1..aea82a121c02 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -299,7 +299,7 @@ struct batadv_orig_node {
 	struct batadv_priv *bat_priv;
 	/* bcast_seqno_lock protects: bcast_bits & last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 #ifdef CONFIG_BATMAN_ADV_NC
 	struct list_head in_coding_list;
-- 
2.7.1
