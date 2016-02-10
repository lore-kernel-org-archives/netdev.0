From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/21] batman-adv: Convert batadv_dat_entry to kref
Date: Wed, 10 Feb 2016 23:57:17 +0800
Message-ID: <1455119847-5862-12-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:38655 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752935AbcBJQST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:19 -0500
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
 net/batman-adv/distributed-arp-table.c | 27 +++++++++++++++++++++------
 net/batman-adv/types.h                 |  2 +-
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 017fffe9a5b8..921e25255cab 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -30,6 +30,7 @@
 #include <linux/in.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
@@ -62,14 +63,27 @@ static void batadv_dat_start_timer(struct batadv_priv *bat_priv)
 }
 
 /**
+ * batadv_dat_entry_release - release dat_entry from lists and queue for free
+ *  after rcu grace period
+ * @ref: kref pointer of the dat_entry
+ */
+static void batadv_dat_entry_release(struct kref *ref)
+{
+	struct batadv_dat_entry *dat_entry;
+
+	dat_entry = container_of(ref, struct batadv_dat_entry, refcount);
+
+	kfree_rcu(dat_entry, rcu);
+}
+
+/**
  * batadv_dat_entry_free_ref - decrement the dat_entry refcounter and possibly
- * free it
- * @dat_entry: the entry to free
+ *  release it
+ * @dat_entry: dat_entry to be free'd
  */
 static void batadv_dat_entry_free_ref(struct batadv_dat_entry *dat_entry)
 {
-	if (atomic_dec_and_test(&dat_entry->refcount))
-		kfree_rcu(dat_entry, rcu);
+	kref_put(&dat_entry->refcount, batadv_dat_entry_release);
 }
 
 /**
@@ -281,7 +295,7 @@ batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip,
 		if (dat_entry->ip != ip)
 			continue;
 
-		if (!atomic_inc_not_zero(&dat_entry->refcount))
+		if (!kref_get_unless_zero(&dat_entry->refcount))
 			continue;
 
 		dat_entry_tmp = dat_entry;
@@ -326,7 +340,8 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 	dat_entry->vid = vid;
 	ether_addr_copy(dat_entry->mac_addr, mac_addr);
 	dat_entry->last_update = jiffies;
-	atomic_set(&dat_entry->refcount, 2);
+	kref_init(&dat_entry->refcount);
+	kref_get(&dat_entry->refcount);
 
 	hash_added = batadv_hash_add(bat_priv->dat.hash, batadv_compare_dat,
 				     batadv_hash_dat, dat_entry,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b3d9b5b566a2..9df8f39e4785 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1230,7 +1230,7 @@ struct batadv_dat_entry {
 	unsigned short vid;
 	unsigned long last_update;
 	struct hlist_node hash_entry;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
