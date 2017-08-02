From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 1/1] constify tcp congestion
Date: Tue,  1 Aug 2017 19:49:43 -0700
Message-ID: <20170802024943.7517-2-sthemmin@microsoft.com>
References: <20170802024943.7517-1-sthemmin@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36403 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdHBCts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 22:49:48 -0400
Received: by mail-pf0-f178.google.com with SMTP id z129so15310646pfb.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 19:49:48 -0700 (PDT)
In-Reply-To: <20170802024943.7517-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the TCP congestion ops structure into const and mutable portions.
Put the list pointers, key and a copy of the flags in new tcp_congestion_entry
structure.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

---
 include/net/tcp.h        |  10 ++-
 net/ipv4/tcp.c           |   2 -
 net/ipv4/tcp_bbr.c       |   2 +-
 net/ipv4/tcp_bic.c       |   2 +-
 net/ipv4/tcp_cdg.c       |   2 +-
 net/ipv4/tcp_cong.c      | 162 +++++++++++++++++++++++++++++------------------
 net/ipv4/tcp_cubic.c     |   2 +-
 net/ipv4/tcp_dctcp.c     |   6 +-
 net/ipv4/tcp_highspeed.c |   2 +-
 net/ipv4/tcp_htcp.c      |   2 +-
 net/ipv4/tcp_hybla.c     |   2 +-
 net/ipv4/tcp_illinois.c  |   2 +-
 net/ipv4/tcp_lp.c        |   2 +-
 net/ipv4/tcp_nv.c        |   2 +-
 net/ipv4/tcp_scalable.c  |   2 +-
 net/ipv4/tcp_vegas.c     |   2 +-
 net/ipv4/tcp_veno.c      |   2 +-
 net/ipv4/tcp_westwood.c  |   2 +-
 net/ipv4/tcp_yeah.c      |   2 +-
 19 files changed, 124 insertions(+), 86 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb1881b4ce48..725395a7c6d1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -931,8 +931,6 @@ struct rate_sample {
 };
 
 struct tcp_congestion_ops {
-	struct list_head	list;
-	u32 key;
 	u32 flags;
 
 	/* initialize private data (optional) */
@@ -970,8 +968,8 @@ struct tcp_congestion_ops {
 	struct module 	*owner;
 };
 
-int tcp_register_congestion_control(struct tcp_congestion_ops *type);
-void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
+int tcp_register_congestion_control(const struct tcp_congestion_ops *type);
+void tcp_unregister_congestion_control(const struct tcp_congestion_ops *type);
 
 void tcp_assign_congestion_control(struct sock *sk);
 void tcp_init_congestion_control(struct sock *sk);
@@ -990,9 +988,9 @@ void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
 u32 tcp_reno_ssthresh(struct sock *sk);
 u32 tcp_reno_undo_cwnd(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
-extern struct tcp_congestion_ops tcp_reno;
+extern const struct tcp_congestion_ops tcp_reno;
 
-struct tcp_congestion_ops *tcp_ca_find_key(u32 key);
+const struct tcp_congestion_ops *tcp_ca_find_key(u32 key);
 u32 tcp_ca_get_key_by_name(const char *name, bool *ecn_ca);
 #ifdef CONFIG_INET
 char *tcp_ca_get_name_by_key(u32 key, char *buffer);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9dd6f4dba9b1..b26eeff90cff 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3344,8 +3344,6 @@ int tcp_abort(struct sock *sk, int err)
 }
 EXPORT_SYMBOL_GPL(tcp_abort);
 
-extern struct tcp_congestion_ops tcp_reno;
-
 static __initdata unsigned long thash_entries;
 static int __init set_thash_entries(char *str)
 {
diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 69ee877574d0..353574dd1eb8 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -917,7 +917,7 @@ static void bbr_set_state(struct sock *sk, u8 new_state)
 	}
 }
 
-static struct tcp_congestion_ops tcp_bbr_cong_ops __read_mostly = {
+static const struct tcp_congestion_ops tcp_bbr_cong_ops = {
 	.flags		= TCP_CONG_NON_RESTRICTED,
 	.name		= "bbr",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 609965f0e298..8a8a3a6bde1a 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -209,7 +209,7 @@ static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
 	}
 }
 
-static struct tcp_congestion_ops bictcp __read_mostly = {
+static const struct tcp_congestion_ops bictcp = {
 	.init		= bictcp_init,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 50a0f3e51d5b..32e8631dd128 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -399,7 +399,7 @@ static void tcp_cdg_release(struct sock *sk)
 	kfree(ca->gradients);
 }
 
-struct tcp_congestion_ops tcp_cdg __read_mostly = {
+static const struct tcp_congestion_ops tcp_cdg = {
 	.cong_avoid = tcp_cdg_cong_avoid,
 	.cwnd_event = tcp_cdg_cwnd_event,
 	.pkts_acked = tcp_cdg_acked,
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index fde983f6376b..0d43eef045f4 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -19,13 +19,21 @@
 static DEFINE_SPINLOCK(tcp_cong_list_lock);
 static LIST_HEAD(tcp_cong_list);
 
+struct tcp_congestion_entry {
+	struct list_head	list;
+	u32 key;
+	u32 flags;
+	const struct tcp_congestion_ops *ops;
+	struct rcu_head rcu;
+};
+
 /* Simple linear search, don't expect many entries! */
-static struct tcp_congestion_ops *tcp_ca_find(const char *name)
+static struct tcp_congestion_entry *tcp_ca_find(const char *name)
 {
-	struct tcp_congestion_ops *e;
+	struct tcp_congestion_entry *e;
 
 	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
-		if (strcmp(e->name, name) == 0)
+		if (strcmp(e->ops->name, name) == 0)
 			return e;
 	}
 
@@ -33,28 +41,30 @@ static struct tcp_congestion_ops *tcp_ca_find(const char *name)
 }
 
 /* Must be called with rcu lock held */
-static const struct tcp_congestion_ops *__tcp_ca_find_autoload(const char *name)
+static const struct tcp_congestion_entry *tcp_ca_find_autoload(const char *name)
 {
-	const struct tcp_congestion_ops *ca = tcp_ca_find(name);
+	const struct tcp_congestion_entry *e;
+
+	e = tcp_ca_find(name);
 #ifdef CONFIG_MODULES
-	if (!ca && capable(CAP_NET_ADMIN)) {
+	if (!e && capable(CAP_NET_ADMIN)) {
 		rcu_read_unlock();
 		request_module("tcp_%s", name);
 		rcu_read_lock();
-		ca = tcp_ca_find(name);
+		e = tcp_ca_find(name);
 	}
 #endif
-	return ca;
+	return e;
 }
 
 /* Simple linear search, not much in here. */
-struct tcp_congestion_ops *tcp_ca_find_key(u32 key)
+const struct tcp_congestion_ops *tcp_ca_find_key(u32 key)
 {
-	struct tcp_congestion_ops *e;
+	struct tcp_congestion_entry *e;
 
 	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
 		if (e->key == key)
-			return e;
+			return e->ops;
 	}
 
 	return NULL;
@@ -64,8 +74,9 @@ struct tcp_congestion_ops *tcp_ca_find_key(u32 key)
  * Attach new congestion control algorithm to the list
  * of available options.
  */
-int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
+int tcp_register_congestion_control(const struct tcp_congestion_ops *ca)
 {
+	struct tcp_congestion_entry *e;
 	int ret = 0;
 
 	/* all algorithms must implement these */
@@ -75,15 +86,21 @@ int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
 		return -EINVAL;
 	}
 
-	ca->key = jhash(ca->name, sizeof(ca->name), strlen(ca->name));
+	e = kmalloc(sizeof(*e), GFP_KERNEL);
+	if (!e)
+		return -ENOMEM;
+
+	e->key = jhash(ca->name, sizeof(ca->name), strlen(ca->name));
+	e->ops = ca;
+	e->flags = ca->flags;
 
 	spin_lock(&tcp_cong_list_lock);
-	if (ca->key == TCP_CA_UNSPEC || tcp_ca_find_key(ca->key)) {
+	if (e->key == TCP_CA_UNSPEC || tcp_ca_find_key(e->key)) {
 		pr_notice("%s already registered or non-unique key\n",
 			  ca->name);
 		ret = -EEXIST;
 	} else {
-		list_add_tail_rcu(&ca->list, &tcp_cong_list);
+		list_add_tail_rcu(&e->list, &tcp_cong_list);
 		pr_debug("%s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
@@ -98,10 +115,18 @@ EXPORT_SYMBOL_GPL(tcp_register_congestion_control);
  * to ensure that this can't be done till all sockets using
  * that method are closed.
  */
-void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
+void tcp_unregister_congestion_control(const struct tcp_congestion_ops *ca)
 {
+	struct tcp_congestion_entry *e;
+
 	spin_lock(&tcp_cong_list_lock);
-	list_del_rcu(&ca->list);
+	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
+		if (e->ops == ca) {
+			list_del_rcu(&e->list);
+			kfree_rcu(e, rcu);
+			break;
+		}
+	}
 	spin_unlock(&tcp_cong_list_lock);
 
 	/* Wait for outstanding readers to complete before the
@@ -117,17 +142,19 @@ EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
 
 u32 tcp_ca_get_key_by_name(const char *name, bool *ecn_ca)
 {
-	const struct tcp_congestion_ops *ca;
+	const struct tcp_congestion_entry *e;
 	u32 key = TCP_CA_UNSPEC;
 
 	might_sleep();
 
 	rcu_read_lock();
-	ca = __tcp_ca_find_autoload(name);
-	if (ca) {
-		key = ca->key;
-		*ecn_ca = ca->flags & TCP_CONG_NEEDS_ECN;
+
+	e = tcp_ca_find_autoload(name);
+	if (e) {
+		key = e->key;
+		*ecn_ca = e->flags & TCP_CONG_NEEDS_ECN;
 	}
+
 	rcu_read_unlock();
 
 	return key;
@@ -154,10 +181,12 @@ EXPORT_SYMBOL_GPL(tcp_ca_get_name_by_key);
 void tcp_assign_congestion_control(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
+		const struct tcp_congestion_ops *ca = e->ops;
+
 		if (likely(try_module_get(ca->owner))) {
 			icsk->icsk_ca_ops = ca;
 			goto out;
@@ -166,14 +195,15 @@ void tcp_assign_congestion_control(struct sock *sk)
 		 * guaranteed fallback is Reno from this list.
 		 */
 	}
-out:
-	rcu_read_unlock();
-	memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 
-	if (ca->flags & TCP_CONG_NEEDS_ECN)
+out:
+	if (e->flags & TCP_CONG_NEEDS_ECN)
 		INET_ECN_xmit(sk);
 	else
 		INET_ECN_dontxmit(sk);
+
+	rcu_read_unlock();
+	memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 }
 
 void tcp_init_congestion_control(struct sock *sk)
@@ -216,24 +246,24 @@ void tcp_cleanup_congestion_control(struct sock *sk)
 /* Used by sysctl to change default congestion control */
 int tcp_set_default_congestion_control(const char *name)
 {
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 	int ret = -ENOENT;
 
 	spin_lock(&tcp_cong_list_lock);
-	ca = tcp_ca_find(name);
+	e = tcp_ca_find(name);
 #ifdef CONFIG_MODULES
-	if (!ca && capable(CAP_NET_ADMIN)) {
+	if (!e && capable(CAP_NET_ADMIN)) {
 		spin_unlock(&tcp_cong_list_lock);
 
 		request_module("tcp_%s", name);
 		spin_lock(&tcp_cong_list_lock);
-		ca = tcp_ca_find(name);
+		e = tcp_ca_find(name);
 	}
 #endif
 
-	if (ca) {
-		ca->flags |= TCP_CONG_NON_RESTRICTED;	/* default is always allowed */
-		list_move(&ca->list, &tcp_cong_list);
+	if (e) {
+		e->flags |= TCP_CONG_NON_RESTRICTED;	/* default is always allowed */
+		list_move(&e->list, &tcp_cong_list);
 		ret = 0;
 	}
 	spin_unlock(&tcp_cong_list_lock);
@@ -251,14 +281,16 @@ late_initcall(tcp_congestion_default);
 /* Build string with list of available congestion control values */
 void tcp_get_available_congestion_control(char *buf, size_t maxlen)
 {
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 	size_t offs = 0;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
+		const char *name = e->ops->name;
+
 		offs += snprintf(buf + offs, maxlen - offs,
 				 "%s%s",
-				 offs == 0 ? "" : " ", ca->name);
+				 offs == 0 ? "" : " ", name);
 	}
 	rcu_read_unlock();
 }
@@ -266,30 +298,33 @@ void tcp_get_available_congestion_control(char *buf, size_t maxlen)
 /* Get current default congestion control */
 void tcp_get_default_congestion_control(char *name)
 {
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 	/* We will always have reno... */
 	BUG_ON(list_empty(&tcp_cong_list));
 
 	rcu_read_lock();
-	ca = list_entry(tcp_cong_list.next, struct tcp_congestion_ops, list);
-	strncpy(name, ca->name, TCP_CA_NAME_MAX);
+	e = list_first_entry(&tcp_cong_list, struct tcp_congestion_entry, list);
+	strncpy(name, e->ops->name, TCP_CA_NAME_MAX);
 	rcu_read_unlock();
 }
 
 /* Built list of non-restricted congestion control values */
 void tcp_get_allowed_congestion_control(char *buf, size_t maxlen)
 {
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 	size_t offs = 0;
 
 	*buf = '\0';
 	rcu_read_lock();
-	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
-		if (!(ca->flags & TCP_CONG_NON_RESTRICTED))
+	list_for_each_entry_rcu(e, &tcp_cong_list, list) {
+		const char *name = e->ops->name;
+
+		if (!(e->flags & TCP_CONG_NON_RESTRICTED))
 			continue;
+
 		offs += snprintf(buf + offs, maxlen - offs,
 				 "%s%s",
-				 offs == 0 ? "" : " ", ca->name);
+				 offs == 0 ? "" : " ", name);
 	}
 	rcu_read_unlock();
 }
@@ -297,7 +332,7 @@ void tcp_get_allowed_congestion_control(char *buf, size_t maxlen)
 /* Change list of non-restricted congestion control */
 int tcp_set_allowed_congestion_control(char *val)
 {
-	struct tcp_congestion_ops *ca;
+	struct tcp_congestion_entry *e;
 	char *saved_clone, *clone, *name;
 	int ret = 0;
 
@@ -308,23 +343,23 @@ int tcp_set_allowed_congestion_control(char *val)
 	spin_lock(&tcp_cong_list_lock);
 	/* pass 1 check for bad entries */
 	while ((name = strsep(&clone, " ")) && *name) {
-		ca = tcp_ca_find(name);
-		if (!ca) {
+		e = tcp_ca_find(name);
+		if (!e) {
 			ret = -ENOENT;
 			goto out;
 		}
 	}
 
 	/* pass 2 clear old values */
-	list_for_each_entry_rcu(ca, &tcp_cong_list, list)
-		ca->flags &= ~TCP_CONG_NON_RESTRICTED;
+	list_for_each_entry_rcu(e, &tcp_cong_list, list)
+		e->flags &= ~TCP_CONG_NON_RESTRICTED;
 
 	/* pass 3 mark as allowed */
 	while ((name = strsep(&val, " ")) && *name) {
-		ca = tcp_ca_find(name);
-		WARN_ON(!ca);
-		if (ca)
-			ca->flags |= TCP_CONG_NON_RESTRICTED;
+		e = tcp_ca_find(name);
+		WARN_ON(!e);
+		if (e)
+			e->flags |= TCP_CONG_NON_RESTRICTED;
 	}
 out:
 	spin_unlock(&tcp_cong_list_lock);
@@ -341,6 +376,7 @@ int tcp_set_allowed_congestion_control(char *val)
 int tcp_set_congestion_control(struct sock *sk, const char *name, bool load)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcp_congestion_entry *e;
 	const struct tcp_congestion_ops *ca;
 	int err = 0;
 
@@ -349,17 +385,23 @@ int tcp_set_congestion_control(struct sock *sk, const char *name, bool load)
 
 	rcu_read_lock();
 	if (!load)
-		ca = tcp_ca_find(name);
+		e = tcp_ca_find(name);
 	else
-		ca = __tcp_ca_find_autoload(name);
+		e = tcp_ca_find_autoload(name);
+
+	if (!e) {
+		err = -ENOENT;
+		goto out;
+	}
+
 	/* No change asking for existing value */
+	ca = e->ops;
 	if (ca == icsk->icsk_ca_ops) {
 		icsk->icsk_ca_setsockopt = 1;
 		goto out;
 	}
-	if (!ca) {
-		err = -ENOENT;
-	} else if (!load) {
+
+	if (!load) {
 		icsk->icsk_ca_ops = ca;
 		if (!try_module_get(ca->owner))
 			err = -EBUSY;
@@ -460,7 +502,7 @@ u32 tcp_reno_undo_cwnd(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_reno_undo_cwnd);
 
-struct tcp_congestion_ops tcp_reno = {
+const struct tcp_congestion_ops tcp_reno = {
 	.flags		= TCP_CONG_NON_RESTRICTED,
 	.name		= "reno",
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 57ae5b5ae643..6a358d8408c4 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -465,7 +465,7 @@ static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
 		hystart_update(sk, delay);
 }
 
-static struct tcp_congestion_ops cubictcp __read_mostly = {
+static const struct tcp_congestion_ops cubictcp = {
 	.init		= bictcp_init,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 5f5e5936760e..7c608527c581 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -72,7 +72,7 @@ module_param(dctcp_clamp_alpha_on_loss, uint, 0644);
 MODULE_PARM_DESC(dctcp_clamp_alpha_on_loss,
 		 "parameter for clamping alpha on loss");
 
-static struct tcp_congestion_ops dctcp_reno;
+static const struct tcp_congestion_ops dctcp_reno;
 
 static void dctcp_reset(const struct tcp_sock *tp, struct dctcp *ca)
 {
@@ -318,7 +318,7 @@ static u32 dctcp_cwnd_undo(struct sock *sk)
 	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
 }
 
-static struct tcp_congestion_ops dctcp __read_mostly = {
+static const struct tcp_congestion_ops dctcp = {
 	.init		= dctcp_init,
 	.in_ack_event   = dctcp_update_alpha,
 	.cwnd_event	= dctcp_cwnd_event,
@@ -332,7 +332,7 @@ static struct tcp_congestion_ops dctcp __read_mostly = {
 	.name		= "dctcp",
 };
 
-static struct tcp_congestion_ops dctcp_reno __read_mostly = {
+static const struct tcp_congestion_ops dctcp_reno = {
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
 	.undo_cwnd	= tcp_reno_undo_cwnd,
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index 6d9879e93648..0faf9f952cf4 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -165,7 +165,7 @@ static u32 hstcp_cwnd_undo(struct sock *sk)
 	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
 }
 
-static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
+static const struct tcp_congestion_ops tcp_highspeed = {
 	.init		= hstcp_init,
 	.ssthresh	= hstcp_ssthresh,
 	.undo_cwnd	= hstcp_cwnd_undo,
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 3eb78cde6ff0..74a5992f0323 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -286,7 +286,7 @@ static void htcp_state(struct sock *sk, u8 new_state)
 	}
 }
 
-static struct tcp_congestion_ops htcp __read_mostly = {
+static const struct tcp_congestion_ops htcp = {
 	.init		= htcp_init,
 	.ssthresh	= htcp_recalc_ssthresh,
 	.cong_avoid	= htcp_cong_avoid,
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 0f7175c3338e..4705a65cd23a 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -163,7 +163,7 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
 }
 
-static struct tcp_congestion_ops tcp_hybla __read_mostly = {
+static const struct tcp_congestion_ops tcp_hybla = {
 	.init		= hybla_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.undo_cwnd	= tcp_reno_undo_cwnd,
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 60352ff4f5a8..f0ea215a66fd 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -333,7 +333,7 @@ static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 	return 0;
 }
 
-static struct tcp_congestion_ops tcp_illinois __read_mostly = {
+static const struct tcp_congestion_ops tcp_illinois = {
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
 	.undo_cwnd	= tcp_illinois_cwnd_undo,
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index ae10ed64fe13..9960add64363 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -316,7 +316,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
 	lp->last_drop = now;
 }
 
-static struct tcp_congestion_ops tcp_lp __read_mostly = {
+static const struct tcp_congestion_ops tcp_lp = {
 	.init = tcp_lp_init,
 	.ssthresh = tcp_reno_ssthresh,
 	.undo_cwnd = tcp_reno_undo_cwnd,
diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
index 6d650ed3cb59..fcfc2329953d 100644
--- a/net/ipv4/tcp_nv.c
+++ b/net/ipv4/tcp_nv.c
@@ -441,7 +441,7 @@ static size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
 	return 0;
 }
 
-static struct tcp_congestion_ops tcpnv __read_mostly = {
+static const struct tcp_congestion_ops tcpnv = {
 	.init		= tcpnv_init,
 	.ssthresh	= tcpnv_recalc_ssthresh,
 	.cong_avoid	= tcpnv_cong_avoid,
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index f2123075ce6e..18c98f8e5f6c 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -50,7 +50,7 @@ static u32 tcp_scalable_cwnd_undo(struct sock *sk)
 	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
 }
 
-static struct tcp_congestion_ops tcp_scalable __read_mostly = {
+static const struct tcp_congestion_ops tcp_scalable = {
 	.ssthresh	= tcp_scalable_ssthresh,
 	.undo_cwnd	= tcp_scalable_cwnd_undo,
 	.cong_avoid	= tcp_scalable_cong_avoid,
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 218cfcc77650..c9d7000f00b0 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -304,7 +304,7 @@ size_t tcp_vegas_get_info(struct sock *sk, u32 ext, int *attr,
 }
 EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 
-static struct tcp_congestion_ops tcp_vegas __read_mostly = {
+static const struct tcp_congestion_ops tcp_vegas = {
 	.init		= tcp_vegas_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.undo_cwnd	= tcp_reno_undo_cwnd,
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 76005d4b8dfc..0d9e33d7d7c5 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -210,7 +210,7 @@ static u32 tcp_veno_cwnd_undo(struct sock *sk)
 	return max(tcp_sk(sk)->snd_cwnd, veno->loss_cwnd);
 }
 
-static struct tcp_congestion_ops tcp_veno __read_mostly = {
+static const struct tcp_congestion_ops tcp_veno = {
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
 	.undo_cwnd	= tcp_veno_cwnd_undo,
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index e5de84310949..4c9b8711f4fe 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -251,7 +251,7 @@ static size_t tcp_westwood_info(struct sock *sk, u32 ext, int *attr,
 	return 0;
 }
 
-static struct tcp_congestion_ops tcp_westwood __read_mostly = {
+static const struct tcp_congestion_ops tcp_westwood = {
 	.init		= tcp_westwood_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index e6ff99c4bd3b..507e4b2cb55f 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -232,7 +232,7 @@ static u32 tcp_yeah_cwnd_undo(struct sock *sk)
 	return max(tcp_sk(sk)->snd_cwnd, yeah->loss_cwnd);
 }
 
-static struct tcp_congestion_ops tcp_yeah __read_mostly = {
+static const struct tcp_congestion_ops tcp_yeah = {
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
 	.undo_cwnd      = tcp_yeah_cwnd_undo,
-- 
2.11.0
