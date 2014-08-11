From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: don't use mutex_lock_interruptible()
Date: Mon, 11 Aug 2014 19:06:18 +0200
Message-ID: <1407776779-9113-4-git-send-email-pablo@netfilter.org>
References: <1407776779-9113-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1407776779-9113-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet reports that getsockopt() or setsockopt() sometimes
returns -EINTR instead of -ENOPROTOOPT, causing headaches to
application developers.

This patch replaces all the mutex_lock_interruptible() by mutex_lock()
in the netfilter tree, as there is no reason we should sleep for a
long time there.

Reported-by: Eric Dumazet <edumazet@google.com>
Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/bridge/netfilter/ebtables.c |   10 ++-------
 net/netfilter/core.c            |   11 ++-------
 net/netfilter/ipvs/ip_vs_ctl.c  |   19 ++++------------
 net/netfilter/nf_sockopt.c      |    8 ++-----
 net/netfilter/x_tables.c        |   47 ++++++++++-----------------------------
 5 files changed, 22 insertions(+), 73 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 1059ed3..6d69631 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -327,10 +327,7 @@ find_inlist_lock_noload(struct list_head *head, const char *name, int *error,
 		char name[EBT_FUNCTION_MAXNAMELEN];
 	} *e;
 
-	*error = mutex_lock_interruptible(mutex);
-	if (*error != 0)
-		return NULL;
-
+	mutex_lock(mutex);
 	list_for_each_entry(e, head, list) {
 		if (strcmp(e->name, name) == 0)
 			return e;
@@ -1203,10 +1200,7 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 
 	table->private = newinfo;
 	rwlock_init(&table->lock);
-	ret = mutex_lock_interruptible(&ebt_mutex);
-	if (ret != 0)
-		goto free_chainstack;
-
+	mutex_lock(&ebt_mutex);
 	list_for_each_entry(t, &net->xt.tables[NFPROTO_BRIDGE], list) {
 		if (strcmp(t->name, table->name) == 0) {
 			ret = -EEXIST;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 1fbab0c..a93c97f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -35,11 +35,7 @@ EXPORT_SYMBOL_GPL(nf_ipv6_ops);
 
 int nf_register_afinfo(const struct nf_afinfo *afinfo)
 {
-	int err;
-
-	err = mutex_lock_interruptible(&afinfo_mutex);
-	if (err < 0)
-		return err;
+	mutex_lock(&afinfo_mutex);
 	RCU_INIT_POINTER(nf_afinfo[afinfo->family], afinfo);
 	mutex_unlock(&afinfo_mutex);
 	return 0;
@@ -68,11 +64,8 @@ static DEFINE_MUTEX(nf_hook_mutex);
 int nf_register_hook(struct nf_hook_ops *reg)
 {
 	struct nf_hook_ops *elem;
-	int err;
 
-	err = mutex_lock_interruptible(&nf_hook_mutex);
-	if (err < 0)
-		return err;
+	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
 		if (reg->priority < elem->priority)
 			break;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8416307..fd3f444 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2271,10 +2271,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	    cmd == IP_VS_SO_SET_STOPDAEMON) {
 		struct ip_vs_daemon_user *dm = (struct ip_vs_daemon_user *)arg;
 
-		if (mutex_lock_interruptible(&ipvs->sync_mutex)) {
-			ret = -ERESTARTSYS;
-			goto out_dec;
-		}
+		mutex_lock(&ipvs->sync_mutex);
 		if (cmd == IP_VS_SO_SET_STARTDAEMON)
 			ret = start_sync_thread(net, dm->state, dm->mcast_ifn,
 						dm->syncid);
@@ -2284,11 +2281,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		goto out_dec;
 	}
 
-	if (mutex_lock_interruptible(&__ip_vs_mutex)) {
-		ret = -ERESTARTSYS;
-		goto out_dec;
-	}
-
+	mutex_lock(&__ip_vs_mutex);
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
 		ret = ip_vs_flush(net, false);
@@ -2573,9 +2566,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		struct ip_vs_daemon_user d[2];
 
 		memset(&d, 0, sizeof(d));
-		if (mutex_lock_interruptible(&ipvs->sync_mutex))
-			return -ERESTARTSYS;
-
+		mutex_lock(&ipvs->sync_mutex);
 		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
 			d[0].state = IP_VS_STATE_MASTER;
 			strlcpy(d[0].mcast_ifn, ipvs->master_mcast_ifn,
@@ -2594,9 +2585,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		return ret;
 	}
 
-	if (mutex_lock_interruptible(&__ip_vs_mutex))
-		return -ERESTARTSYS;
-
+	mutex_lock(&__ip_vs_mutex);
 	switch (cmd) {
 	case IP_VS_SO_GET_VERSION:
 	{
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index f042ae5..c68c1e5 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -26,9 +26,7 @@ int nf_register_sockopt(struct nf_sockopt_ops *reg)
 	struct nf_sockopt_ops *ops;
 	int ret = 0;
 
-	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
-		return -EINTR;
-
+	mutex_lock(&nf_sockopt_mutex);
 	list_for_each_entry(ops, &nf_sockopts, list) {
 		if (ops->pf == reg->pf
 		    && (overlap(ops->set_optmin, ops->set_optmax,
@@ -65,9 +63,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, u_int8_t pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
-		return ERR_PTR(-EINTR);
-
+	mutex_lock(&nf_sockopt_mutex);
 	list_for_each_entry(ops, &nf_sockopts, list) {
 		if (ops->pf == pf) {
 			if (!try_module_get(ops->owner))
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 47b978b..272ae4d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -71,18 +71,14 @@ static const char *const xt_prefix[NFPROTO_NUMPROTO] = {
 static const unsigned int xt_jumpstack_multiplier = 2;
 
 /* Registration hooks for targets. */
-int
-xt_register_target(struct xt_target *target)
+int xt_register_target(struct xt_target *target)
 {
 	u_int8_t af = target->family;
-	int ret;
 
-	ret = mutex_lock_interruptible(&xt[af].mutex);
-	if (ret != 0)
-		return ret;
+	mutex_lock(&xt[af].mutex);
 	list_add(&target->list, &xt[af].target);
 	mutex_unlock(&xt[af].mutex);
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL(xt_register_target);
 
@@ -125,20 +121,14 @@ xt_unregister_targets(struct xt_target *target, unsigned int n)
 }
 EXPORT_SYMBOL(xt_unregister_targets);
 
-int
-xt_register_match(struct xt_match *match)
+int xt_register_match(struct xt_match *match)
 {
 	u_int8_t af = match->family;
-	int ret;
-
-	ret = mutex_lock_interruptible(&xt[af].mutex);
-	if (ret != 0)
-		return ret;
 
+	mutex_lock(&xt[af].mutex);
 	list_add(&match->list, &xt[af].match);
 	mutex_unlock(&xt[af].mutex);
-
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL(xt_register_match);
 
@@ -194,9 +184,7 @@ struct xt_match *xt_find_match(u8 af, const char *name, u8 revision)
 	struct xt_match *m;
 	int err = -ENOENT;
 
-	if (mutex_lock_interruptible(&xt[af].mutex) != 0)
-		return ERR_PTR(-EINTR);
-
+	mutex_lock(&xt[af].mutex);
 	list_for_each_entry(m, &xt[af].match, list) {
 		if (strcmp(m->name, name) == 0) {
 			if (m->revision == revision) {
@@ -239,9 +227,7 @@ struct xt_target *xt_find_target(u8 af, const char *name, u8 revision)
 	struct xt_target *t;
 	int err = -ENOENT;
 
-	if (mutex_lock_interruptible(&xt[af].mutex) != 0)
-		return ERR_PTR(-EINTR);
-
+	mutex_lock(&xt[af].mutex);
 	list_for_each_entry(t, &xt[af].target, list) {
 		if (strcmp(t->name, name) == 0) {
 			if (t->revision == revision) {
@@ -323,10 +309,7 @@ int xt_find_revision(u8 af, const char *name, u8 revision, int target,
 {
 	int have_rev, best = -1;
 
-	if (mutex_lock_interruptible(&xt[af].mutex) != 0) {
-		*err = -EINTR;
-		return 1;
-	}
+	mutex_lock(&xt[af].mutex);
 	if (target == 1)
 		have_rev = target_revfn(af, name, revision, &best);
 	else
@@ -732,9 +715,7 @@ struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
 {
 	struct xt_table *t;
 
-	if (mutex_lock_interruptible(&xt[af].mutex) != 0)
-		return ERR_PTR(-EINTR);
-
+	mutex_lock(&xt[af].mutex);
 	list_for_each_entry(t, &net->xt.tables[af], list)
 		if (strcmp(t->name, name) == 0 && try_module_get(t->me))
 			return t;
@@ -883,10 +864,7 @@ struct xt_table *xt_register_table(struct net *net,
 		goto out;
 	}
 
-	ret = mutex_lock_interruptible(&xt[table->af].mutex);
-	if (ret != 0)
-		goto out_free;
-
+	mutex_lock(&xt[table->af].mutex);
 	/* Don't autoload: we'd eat our tail... */
 	list_for_each_entry(t, &net->xt.tables[table->af], list) {
 		if (strcmp(t->name, table->name) == 0) {
@@ -911,9 +889,8 @@ struct xt_table *xt_register_table(struct net *net,
 	mutex_unlock(&xt[table->af].mutex);
 	return table;
 
- unlock:
+unlock:
 	mutex_unlock(&xt[table->af].mutex);
-out_free:
 	kfree(table);
 out:
 	return ERR_PTR(ret);
-- 
1.7.10.4

