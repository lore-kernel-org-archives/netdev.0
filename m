From: kaber@trash.net
Subject: [PATCH 16/17] netfilter: CLUSTERIP: RCU conversion
Date: Tue, 15 Jun 2010 17:38:42 +0200
Message-ID: <1276616323-20880-17-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42173 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283Ab0FOP35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:57 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

- clusterip_lock becomes a spinlock
- lockless lookups
- kfree() deferred after RCU grace period
- rcu_barrier_bh() inserted in clusterip_tg_exit()

v2)
- As Patrick pointed out, we use atomic_inc_not_zero() in
clusterip_config_find_get().
- list_add_rcu() and list_del_rcu() variants are used.
- atomic_dec_and_lock() used in clusterip_config_entry_put()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   48 +++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index f91c94b..64d0875 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -53,12 +53,13 @@ struct clusterip_config {
 #endif
 	enum clusterip_hashmode hash_mode;	/* which hashing mode */
 	u_int32_t hash_initval;			/* hash initialization */
+	struct rcu_head rcu;
 };
 
 static LIST_HEAD(clusterip_configs);
 
 /* clusterip_lock protects the clusterip_configs list */
-static DEFINE_RWLOCK(clusterip_lock);
+static DEFINE_SPINLOCK(clusterip_lock);
 
 #ifdef CONFIG_PROC_FS
 static const struct file_operations clusterip_proc_fops;
@@ -71,11 +72,17 @@ clusterip_config_get(struct clusterip_config *c)
 	atomic_inc(&c->refcount);
 }
 
+
+static void clusterip_config_rcu_free(struct rcu_head *head)
+{
+	kfree(container_of(head, struct clusterip_config, rcu));
+}
+
 static inline void
 clusterip_config_put(struct clusterip_config *c)
 {
 	if (atomic_dec_and_test(&c->refcount))
-		kfree(c);
+		call_rcu_bh(&c->rcu, clusterip_config_rcu_free);
 }
 
 /* decrease the count of entries using/referencing this config.  If last
@@ -84,10 +91,11 @@ clusterip_config_put(struct clusterip_config *c)
 static inline void
 clusterip_config_entry_put(struct clusterip_config *c)
 {
-	write_lock_bh(&clusterip_lock);
-	if (atomic_dec_and_test(&c->entries)) {
-		list_del(&c->list);
-		write_unlock_bh(&clusterip_lock);
+	local_bh_disable();
+	if (atomic_dec_and_lock(&c->entries, &clusterip_lock)) {
+		list_del_rcu(&c->list);
+		spin_unlock(&clusterip_lock);
+		local_bh_enable();
 
 		dev_mc_del(c->dev, c->clustermac);
 		dev_put(c->dev);
@@ -100,7 +108,7 @@ clusterip_config_entry_put(struct clusterip_config *c)
 #endif
 		return;
 	}
-	write_unlock_bh(&clusterip_lock);
+	local_bh_enable();
 }
 
 static struct clusterip_config *
@@ -108,7 +116,7 @@ __clusterip_config_find(__be32 clusterip)
 {
 	struct clusterip_config *c;
 
-	list_for_each_entry(c, &clusterip_configs, list) {
+	list_for_each_entry_rcu(c, &clusterip_configs, list) {
 		if (c->clusterip == clusterip)
 			return c;
 	}
@@ -121,16 +129,15 @@ clusterip_config_find_get(__be32 clusterip, int entry)
 {
 	struct clusterip_config *c;
 
-	read_lock_bh(&clusterip_lock);
+	rcu_read_lock_bh();
 	c = __clusterip_config_find(clusterip);
-	if (!c) {
-		read_unlock_bh(&clusterip_lock);
-		return NULL;
+	if (c) {
+		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
+			c = NULL;
+		else if (entry)
+			atomic_inc(&c->entries);
 	}
-	atomic_inc(&c->refcount);
-	if (entry)
-		atomic_inc(&c->entries);
-	read_unlock_bh(&clusterip_lock);
+	rcu_read_unlock_bh();
 
 	return c;
 }
@@ -181,9 +188,9 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 	}
 #endif
 
-	write_lock_bh(&clusterip_lock);
-	list_add(&c->list, &clusterip_configs);
-	write_unlock_bh(&clusterip_lock);
+	spin_lock_bh(&clusterip_lock);
+	list_add_rcu(&c->list, &clusterip_configs);
+	spin_unlock_bh(&clusterip_lock);
 
 	return c;
 }
@@ -733,6 +740,9 @@ static void __exit clusterip_tg_exit(void)
 #endif
 	nf_unregister_hook(&cip_arp_ops);
 	xt_unregister_target(&clusterip_tg_reg);
+
+	/* Wait for completion of call_rcu_bh()'s (clusterip_config_rcu_free) */
+	rcu_barrier_bh();
 }
 
 module_init(clusterip_tg_init);
-- 
1.7.0.4

