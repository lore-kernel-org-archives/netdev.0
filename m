From: kaber@trash.net
Subject: [PATCH 84/84] netfilter: use rcu_dereference_protected()
Date: Mon, 10 May 2010 22:18:55 +0200
Message-ID: <1273522735-24672-85-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Restore the rcu_dereference() calls in conntrack/expectation notifier
and logger registration/unregistration, but use the _protected variant,
which will be required by the upcoming __rcu annotations.

Based on patch by Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_ecache.c |   22 ++++++++++++++++++----
 net/netfilter/nf_log.c              |   10 ++++++++--
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index a94ac3a..cdcc764 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -82,9 +82,12 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 int nf_conntrack_register_notifier(struct nf_ct_event_notifier *new)
 {
 	int ret = 0;
+	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	if (nf_conntrack_event_cb != NULL) {
+	notify = rcu_dereference_protected(nf_conntrack_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	if (notify != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -100,8 +103,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_register_notifier);
 
 void nf_conntrack_unregister_notifier(struct nf_ct_event_notifier *new)
 {
+	struct nf_ct_event_notifier *notify;
+
 	mutex_lock(&nf_ct_ecache_mutex);
-	BUG_ON(nf_conntrack_event_cb != new);
+	notify = rcu_dereference_protected(nf_conntrack_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	BUG_ON(notify != new);
 	rcu_assign_pointer(nf_conntrack_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
@@ -110,9 +117,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 int nf_ct_expect_register_notifier(struct nf_exp_event_notifier *new)
 {
 	int ret = 0;
+	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	if (nf_expect_event_cb != NULL) {
+	notify = rcu_dereference_protected(nf_expect_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	if (notify != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -128,8 +138,12 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_register_notifier);
 
 void nf_ct_expect_unregister_notifier(struct nf_exp_event_notifier *new)
 {
+	struct nf_exp_event_notifier *notify;
+
 	mutex_lock(&nf_ct_ecache_mutex);
-	BUG_ON(nf_expect_event_cb != new);
+	notify = rcu_dereference_protected(nf_expect_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	BUG_ON(notify != new);
 	rcu_assign_pointer(nf_expect_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 908f599..7df37fd 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -35,6 +35,7 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 /* return EEXIST if the same logger is registred, 0 on success. */
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
+	const struct nf_logger *llog;
 	int i;
 
 	if (pf >= ARRAY_SIZE(nf_loggers))
@@ -51,7 +52,9 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	} else {
 		/* register at end of list to honor first register win */
 		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
-		if (nf_loggers[pf] == NULL)
+		llog = rcu_dereference_protected(nf_loggers[pf],
+						 lockdep_is_held(&nf_log_mutex));
+		if (llog == NULL)
 			rcu_assign_pointer(nf_loggers[pf], logger);
 	}
 
@@ -63,11 +66,14 @@ EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister(struct nf_logger *logger)
 {
+	const struct nf_logger *c_logger;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		if (nf_loggers[i] == logger)
+		c_logger = rcu_dereference_protected(nf_loggers[i],
+						     lockdep_is_held(&nf_log_mutex));
+		if (c_logger == logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
 		list_del(&logger->list[i]);
 	}
-- 
1.7.0.4

