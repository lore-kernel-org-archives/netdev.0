From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 16/21] batman-adv: Convert batadv_orig_ifinfo to kref
Date: Wed, 10 Feb 2016 23:57:22 +0800
Message-ID: <1455119847-5862-17-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:8457 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752878AbcBJQRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:17:53 -0500
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
 net/batman-adv/originator.c | 15 +++++++++------
 net/batman-adv/routing.c    |  5 +++--
 net/batman-adv/types.h      |  2 +-
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 1c50abe52c6d..428983a2036f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -326,7 +326,7 @@ batadv_orig_ifinfo_get(struct batadv_orig_node *orig_node,
 		if (tmp->if_outgoing != if_outgoing)
 			continue;
 
-		if (!atomic_inc_not_zero(&tmp->refcount))
+		if (!kref_get_unless_zero(&tmp->refcount))
 			continue;
 
 		orig_ifinfo = tmp;
@@ -377,7 +377,8 @@ batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 	orig_ifinfo->batman_seqno_reset = reset_time;
 	orig_ifinfo->if_outgoing = if_outgoing;
 	INIT_HLIST_NODE(&orig_ifinfo->list);
-	atomic_set(&orig_ifinfo->refcount, 2);
+	kref_init(&orig_ifinfo->refcount);
+	kref_get(&orig_ifinfo->refcount);
 	hlist_add_head_rcu(&orig_ifinfo->list,
 			   &orig_node->ifinfo_list);
 out:
@@ -704,12 +705,15 @@ int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 /**
  * batadv_orig_ifinfo_release - release orig_ifinfo from lists and queue for
  *  free after rcu grace period
- * @orig_ifinfo: the orig_ifinfo object to release
+ * @ref: kref pointer of the orig_ifinfo
  */
-static void batadv_orig_ifinfo_release(struct batadv_orig_ifinfo *orig_ifinfo)
+static void batadv_orig_ifinfo_release(struct kref *ref)
 {
+	struct batadv_orig_ifinfo *orig_ifinfo;
 	struct batadv_neigh_node *router;
 
+	orig_ifinfo = container_of(ref, struct batadv_orig_ifinfo, refcount);
+
 	if (orig_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
 		batadv_hardif_free_ref(orig_ifinfo->if_outgoing);
 
@@ -728,8 +732,7 @@ static void batadv_orig_ifinfo_release(struct batadv_orig_ifinfo *orig_ifinfo)
  */
 void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo)
 {
-	if (atomic_dec_and_test(&orig_ifinfo->refcount))
-		batadv_orig_ifinfo_release(orig_ifinfo);
+	kref_put(&orig_ifinfo->refcount, batadv_orig_ifinfo_release);
 }
 
 /**
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1c8b35df50cf..4a5cd8bf2661 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -25,6 +25,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/jiffies.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/printk.h>
 #include <linux/rculist.h>
@@ -497,7 +498,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 
 	hlist_for_each_entry_rcu(cand, &orig_node->ifinfo_list, list) {
 		/* acquire some structures and references ... */
-		if (!atomic_inc_not_zero(&cand->refcount))
+		if (!kref_get_unless_zero(&cand->refcount))
 			continue;
 
 		cand_router = rcu_dereference(cand->router);
@@ -524,7 +525,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 		/* mark the first possible candidate */
 		if (!first_candidate) {
 			atomic_inc(&cand_router->refcount);
-			atomic_inc(&cand->refcount);
+			kref_get(&cand->refcount);
 			first_candidate = cand;
 			first_candidate_router = cand_router;
 		}
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 81d9f8d6c54b..6193c01b47d2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -141,7 +141,7 @@ struct batadv_orig_ifinfo {
 	u32 last_real_seqno;
 	u8 last_ttl;
 	unsigned long batman_seqno_reset;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
