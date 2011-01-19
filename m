From: kaber@trash.net
Subject: [PATCH 10/79] netfilter: add __rcu annotations
Date: Wed, 19 Jan 2011 20:14:10 +0100
Message-ID: <1295464519-21763-11-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Add some __rcu annotations and use helpers to reduce number of sparse
warnings (CONFIG_SPARSE_RCU_POINTER=y)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h                    |    6 +++---
 include/net/netfilter/nf_conntrack_ecache.h  |    4 ++--
 include/net/netfilter/nf_conntrack_l3proto.h |    2 +-
 net/netfilter/core.c                         |    4 ++--
 net/netfilter/nf_conntrack_expect.c          |    6 +++---
 net/netfilter/nf_conntrack_proto.c           |   20 +++++++++++++++-----
 net/netfilter/nf_conntrack_standalone.c      |    9 ++++++---
 net/netfilter/nf_log.c                       |    6 ++++--
 net/netfilter/nf_queue.c                     |   18 ++++++++++++++----
 net/netfilter/nfnetlink_log.c                |    6 +++---
 10 files changed, 53 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 89341c3..928a35e 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -265,7 +265,7 @@ struct nf_afinfo {
 	int		route_key_size;
 };
 
-extern const struct nf_afinfo *nf_afinfo[NFPROTO_NUMPROTO];
+extern const struct nf_afinfo __rcu *nf_afinfo[NFPROTO_NUMPROTO];
 static inline const struct nf_afinfo *nf_get_afinfo(unsigned short family)
 {
 	return rcu_dereference(nf_afinfo[family]);
@@ -355,9 +355,9 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 #endif /*CONFIG_NETFILTER*/
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-extern void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *);
+extern void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *) __rcu;
 extern void nf_ct_attach(struct sk_buff *, struct sk_buff *);
-extern void (*nf_ct_destroy)(struct nf_conntrack *);
+extern void (*nf_ct_destroy)(struct nf_conntrack *) __rcu;
 #else
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index f596b60..8fdb04b 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -67,7 +67,7 @@ struct nf_ct_event_notifier {
 	int (*fcn)(unsigned int events, struct nf_ct_event *item);
 };
 
-extern struct nf_ct_event_notifier *nf_conntrack_event_cb;
+extern struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
 extern int nf_conntrack_register_notifier(struct nf_ct_event_notifier *nb);
 extern void nf_conntrack_unregister_notifier(struct nf_ct_event_notifier *nb);
 
@@ -167,7 +167,7 @@ struct nf_exp_event_notifier {
 	int (*fcn)(unsigned int events, struct nf_exp_event *item);
 };
 
-extern struct nf_exp_event_notifier *nf_expect_event_cb;
+extern struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
 extern int nf_ct_expect_register_notifier(struct nf_exp_event_notifier *nb);
 extern void nf_ct_expect_unregister_notifier(struct nf_exp_event_notifier *nb);
 
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index a754761..e8010f4 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -73,7 +73,7 @@ struct nf_conntrack_l3proto {
 	struct module *me;
 };
 
-extern struct nf_conntrack_l3proto *nf_ct_l3protos[AF_MAX];
+extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
 
 /* Protocol registration. */
 extern int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto);
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 85dabb8..5faec4f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -212,7 +212,7 @@ EXPORT_SYMBOL(skb_make_writable);
 /* This does not belong here, but locally generated errors need it if connection
    tracking in use: without this, connection may not be in hash table, and hence
    manufactured ICMP or RST packets will not be associated with it. */
-void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *);
+void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *) __rcu __read_mostly;
 EXPORT_SYMBOL(ip_ct_attach);
 
 void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb)
@@ -229,7 +229,7 @@ void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(nf_ct_attach);
 
-void (*nf_ct_destroy)(struct nf_conntrack *);
+void (*nf_ct_destroy)(struct nf_conntrack *) __rcu __read_mostly;
 EXPORT_SYMBOL(nf_ct_destroy);
 
 void nf_conntrack_destroy(struct nf_conntrack *nfct)
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 46e8966..cab196c 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -482,7 +482,7 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(net->ct.expect_hash[st->bucket].first);
+		n = rcu_dereference(hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
 		if (n)
 			return n;
 	}
@@ -495,11 +495,11 @@ static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 
-	head = rcu_dereference(head->next);
+	head = rcu_dereference(hlist_next_rcu(head));
 	while (head == NULL) {
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
-		head = rcu_dereference(net->ct.expect_hash[st->bucket].first);
+		head = rcu_dereference(hlist_first_rcu(&net->ct.expect_hash[st->bucket]));
 	}
 	return head;
 }
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index dc7bb74..03b56a0 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -166,6 +166,7 @@ static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3proto *l3proto
 int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
+	struct nf_conntrack_l3proto *old;
 
 	if (proto->l3proto >= AF_MAX)
 		return -EBUSY;
@@ -174,7 +175,9 @@ int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 		return -EINVAL;
 
 	mutex_lock(&nf_ct_proto_mutex);
-	if (nf_ct_l3protos[proto->l3proto] != &nf_conntrack_l3proto_generic) {
+	old = rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
+					lockdep_is_held(&nf_ct_proto_mutex));
+	if (old != &nf_conntrack_l3proto_generic) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -201,7 +204,9 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	BUG_ON(proto->l3proto >= AF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
-	BUG_ON(nf_ct_l3protos[proto->l3proto] != proto);
+	BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
+					 lockdep_is_held(&nf_ct_proto_mutex)
+					 ) != proto);
 	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
 			   &nf_conntrack_l3proto_generic);
 	nf_ct_l3proto_unregister_sysctl(proto);
@@ -299,8 +304,10 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 		smp_wmb();
 
 		nf_ct_protos[l4proto->l3proto] = proto_array;
-	} else if (nf_ct_protos[l4proto->l3proto][l4proto->l4proto] !=
-					&nf_conntrack_l4proto_generic) {
+	} else if (rcu_dereference_protected(
+			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+			lockdep_is_held(&nf_ct_proto_mutex)
+			) != &nf_conntrack_l4proto_generic) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -331,7 +338,10 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
-	BUG_ON(nf_ct_protos[l4proto->l3proto][l4proto->l4proto] != l4proto);
+	BUG_ON(rcu_dereference_protected(
+			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+			lockdep_is_held(&nf_ct_proto_mutex)
+			) != l4proto);
 	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
 			   &nf_conntrack_l4proto_generic);
 	nf_ct_l4proto_unregister_sysctl(l4proto);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0fb6570..328f1d2 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_zones.h>
+#include <linux/rculist_nulls.h>
 
 MODULE_LICENSE("GPL");
 
@@ -56,7 +57,7 @@ static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
 	for (st->bucket = 0;
 	     st->bucket < net->ct.htable_size;
 	     st->bucket++) {
-		n = rcu_dereference(net->ct.hash[st->bucket].first);
+		n = rcu_dereference(hlist_nulls_first_rcu(&net->ct.hash[st->bucket]));
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -69,13 +70,15 @@ static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
-	head = rcu_dereference(head->next);
+	head = rcu_dereference(hlist_nulls_next_rcu(head));
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) == st->bucket)) {
 			if (++st->bucket >= net->ct.htable_size)
 				return NULL;
 		}
-		head = rcu_dereference(net->ct.hash[st->bucket].first);
+		head = rcu_dereference(
+				hlist_nulls_first_rcu(
+					&net->ct.hash[st->bucket]));
 	}
 	return head;
 }
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index b07393e..20c775c 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -161,7 +161,8 @@ static int seq_show(struct seq_file *s, void *v)
 	struct nf_logger *t;
 	int ret;
 
-	logger = nf_loggers[*pos];
+	logger = rcu_dereference_protected(nf_loggers[*pos],
+					   lockdep_is_held(&nf_log_mutex));
 
 	if (!logger)
 		ret = seq_printf(s, "%2lld NONE (", *pos);
@@ -249,7 +250,8 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 		mutex_unlock(&nf_log_mutex);
 	} else {
 		mutex_lock(&nf_log_mutex);
-		logger = nf_loggers[tindex];
+		logger = rcu_dereference_protected(nf_loggers[tindex],
+						   lockdep_is_held(&nf_log_mutex));
 		if (!logger)
 			table->data = "NONE";
 		else
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 74aebed..1876f74 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -27,14 +27,17 @@ static DEFINE_MUTEX(queue_handler_mutex);
 int nf_register_queue_handler(u_int8_t pf, const struct nf_queue_handler *qh)
 {
 	int ret;
+	const struct nf_queue_handler *old;
 
 	if (pf >= ARRAY_SIZE(queue_handler))
 		return -EINVAL;
 
 	mutex_lock(&queue_handler_mutex);
-	if (queue_handler[pf] == qh)
+	old = rcu_dereference_protected(queue_handler[pf],
+					lockdep_is_held(&queue_handler_mutex));
+	if (old == qh)
 		ret = -EEXIST;
-	else if (queue_handler[pf])
+	else if (old)
 		ret = -EBUSY;
 	else {
 		rcu_assign_pointer(queue_handler[pf], qh);
@@ -49,11 +52,15 @@ EXPORT_SYMBOL(nf_register_queue_handler);
 /* The caller must flush their queue before this */
 int nf_unregister_queue_handler(u_int8_t pf, const struct nf_queue_handler *qh)
 {
+	const struct nf_queue_handler *old;
+
 	if (pf >= ARRAY_SIZE(queue_handler))
 		return -EINVAL;
 
 	mutex_lock(&queue_handler_mutex);
-	if (queue_handler[pf] && queue_handler[pf] != qh) {
+	old = rcu_dereference_protected(queue_handler[pf],
+					lockdep_is_held(&queue_handler_mutex));
+	if (old && old != qh) {
 		mutex_unlock(&queue_handler_mutex);
 		return -EINVAL;
 	}
@@ -73,7 +80,10 @@ void nf_unregister_queue_handlers(const struct nf_queue_handler *qh)
 
 	mutex_lock(&queue_handler_mutex);
 	for (pf = 0; pf < ARRAY_SIZE(queue_handler); pf++)  {
-		if (queue_handler[pf] == qh)
+		if (rcu_dereference_protected(
+				queue_handler[pf],
+				lockdep_is_held(&queue_handler_mutex)
+				) == qh)
 			rcu_assign_pointer(queue_handler[pf], NULL);
 	}
 	mutex_unlock(&queue_handler_mutex);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 6a1572b..91592da 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -874,19 +874,19 @@ static struct hlist_node *get_first(struct iter_state *st)
 
 	for (st->bucket = 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
 		if (!hlist_empty(&instance_table[st->bucket]))
-			return rcu_dereference_bh(instance_table[st->bucket].first);
+			return rcu_dereference_bh(hlist_first_rcu(&instance_table[st->bucket]));
 	}
 	return NULL;
 }
 
 static struct hlist_node *get_next(struct iter_state *st, struct hlist_node *h)
 {
-	h = rcu_dereference_bh(h->next);
+	h = rcu_dereference_bh(hlist_next_rcu(h));
 	while (!h) {
 		if (++st->bucket >= INSTANCE_BUCKETS)
 			return NULL;
 
-		h = rcu_dereference_bh(instance_table[st->bucket].first);
+		h = rcu_dereference_bh(hlist_first_rcu(&instance_table[st->bucket]));
 	}
 	return h;
 }
-- 
1.7.2.3

