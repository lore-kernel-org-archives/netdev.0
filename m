From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/19] batman-adv: Initialize lockdep class keys for hashes
Date: Mon, 18 Jun 2012 22:39:07 +0200
Message-ID: <1340051963-14836-4-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41426 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304Ab2FRUjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:07 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The hash for claim and backbone hash in the bridge loop avoidance code receive
the same key because they are getting initialized by hash_new with the same
key. Lockdep will create a backtrace when they are used recursively. This can
be avoided by reinitializing the key directly after the hash_new.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |   13 +++++++++++++
 net/batman-adv/hash.c                  |    9 +++++++++
 net/batman-adv/hash.h                  |    4 ++++
 3 files changed, 26 insertions(+)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 8bf9751..5c1ac55 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1127,6 +1127,14 @@ out:
 	bla_start_timer(bat_priv);
 }
 
+/* The hash for claim and backbone hash receive the same key because they
+ * are getting initialized by hash_new with the same key. Reinitializing
+ * them with to different keys to allow nested locking without generating
+ * lockdep warnings
+ */
+static struct lock_class_key claim_hash_lock_class_key;
+static struct lock_class_key backbone_hash_lock_class_key;
+
 /* initialize all bla structures */
 int bla_init(struct bat_priv *bat_priv)
 {
@@ -1164,6 +1172,11 @@ int bla_init(struct bat_priv *bat_priv)
 	if (!bat_priv->claim_hash || !bat_priv->backbone_hash)
 		return -1;
 
+	batadv_hash_set_lock_class(bat_priv->claim_hash,
+				   &claim_hash_lock_class_key);
+	batadv_hash_set_lock_class(bat_priv->backbone_hash,
+				   &backbone_hash_lock_class_key);
+
 	bat_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
 
 	bla_start_timer(bat_priv);
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 117687b..5b2eabe 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -69,3 +69,12 @@ free_hash:
 	kfree(hash);
 	return NULL;
 }
+
+void batadv_hash_set_lock_class(struct hashtable_t *hash,
+				struct lock_class_key *key)
+{
+	uint32_t i;
+
+	for (i = 0; i < hash->size; i++)
+		lockdep_set_class(&hash->list_locks[i], key);
+}
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index d4bd786..93b3c71 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -45,6 +45,10 @@ struct hashtable_t {
 /* allocates and clears the hash */
 struct hashtable_t *hash_new(uint32_t size);
 
+/* set class key for all locks */
+void batadv_hash_set_lock_class(struct hashtable_t *hash,
+				struct lock_class_key *key);
+
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash);
 
-- 
1.7.9.4
