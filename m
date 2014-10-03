From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH v1 2/2] net: sched: replace ematch calls to use struct net
Date: Thu, 02 Oct 2014 22:46:25 -0700
Message-ID: <20141003054624.20925.28150.stgit@nitbit.x32>
References: <20141003054558.20925.67091.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:64896 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaJCFqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 01:46:45 -0400
Received: by mail-ob0-f179.google.com with SMTP id wp4so353394obc.24
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 22:46:44 -0700 (PDT)
In-Reply-To: <20141003054558.20925.67091.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can not use tcf_proto tp in all cases from RCU callbacks
so this patch simplifies the ematch code paths to take a
'struct net' and then use it directly in em_ipset the only
user.

Previously, em_ipset took the 'net' attribute from the
qdisc embedded in the tcp_proto struct.

This resolves casis where tcf_em_destroy() was being used
in callbacks and referencing the possibly invalid tcf_proto
field.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_cls.h  |   13 ++++++-------
 net/sched/cls_basic.c  |    9 ++++-----
 net/sched/cls_cgroup.c |   10 +++++-----
 net/sched/cls_flow.c   |   12 ++++++------
 net/sched/em_canid.c   |    6 +++---
 net/sched/em_ipset.c   |    7 +++----
 net/sched/em_meta.c    |    4 ++--
 net/sched/em_nbyte.c   |    2 +-
 net/sched/em_text.c    |    4 ++--
 net/sched/ematch.c     |   18 +++++++++---------
 10 files changed, 41 insertions(+), 44 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index ef44ad9..f6ebcf3 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -229,12 +229,11 @@ struct tcf_ematch_tree {
 struct tcf_ematch_ops {
 	int			kind;
 	int			datalen;
-	int			(*change)(struct tcf_proto *, void *,
+	int			(*change)(struct net *, void *,
 					  int, struct tcf_ematch *);
 	int			(*match)(struct sk_buff *, struct tcf_ematch *,
 					 struct tcf_pkt_info *);
-	void			(*destroy)(struct tcf_proto *,
-					   struct tcf_ematch *);
+	void			(*destroy)(struct net *, struct tcf_ematch *);
 	int			(*dump)(struct sk_buff *, struct tcf_ematch *);
 	struct module		*owner;
 	struct list_head	link;
@@ -242,9 +241,9 @@ struct tcf_ematch_ops {
 
 int tcf_em_register(struct tcf_ematch_ops *);
 void tcf_em_unregister(struct tcf_ematch_ops *);
-int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
+int tcf_em_tree_validate(struct net *, struct nlattr *,
 			 struct tcf_ematch_tree *);
-void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
+void tcf_em_tree_destroy(struct net *, struct tcf_ematch_tree *);
 int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
 int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
 			struct tcf_pkt_info *);
@@ -300,8 +299,8 @@ static inline int tcf_em_tree_match(struct sk_buff *skb,
 struct tcf_ematch_tree {
 };
 
-#define tcf_em_tree_validate(tp, tb, t) ((void)(t), 0)
-#define tcf_em_tree_destroy(tp, t) do { (void)(t); } while(0)
+#define tcf_em_tree_validate(net, tb, t) ((void)(t), 0)
+#define tcf_em_tree_destroy(net, t) do { (void)(t); } while(0)
 #define tcf_em_tree_dump(skb, t, tlv) (0)
 #define tcf_em_tree_change(tp, dst, src) do { } while(0)
 #define tcf_em_tree_match(skb, t, info) ((void)(info), 1)
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 81ddfa6..f37e4fb 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -32,7 +32,7 @@ struct basic_filter {
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_result	res;
-	struct tcf_proto	*tp;
+	struct net		*net;
 	struct list_head	link;
 	struct rcu_head		rcu;
 };
@@ -91,10 +91,9 @@ static int basic_init(struct tcf_proto *tp)
 static void basic_delete_filter(struct rcu_head *head)
 {
 	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
-	struct tcf_proto *tp = f->tp;
 
 	tcf_exts_destroy(&f->exts);
-	tcf_em_tree_destroy(tp, &f->ematches);
+	tcf_em_tree_destroy(f->net, &f->ematches);
 	kfree(f);
 }
 
@@ -147,7 +146,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	if (err < 0)
 		return err;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &t);
+	err = tcf_em_tree_validate(net, tb[TCA_BASIC_EMATCHES], &t);
 	if (err < 0)
 		goto errout;
 
@@ -158,7 +157,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 
 	tcf_exts_change(tp, &f->exts, &e);
 	tcf_em_tree_change(tp, &f->ematches, &t);
-	f->tp = tp;
+	f->net = net;
 
 	return 0;
 errout:
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3409f16..d4fef3a 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -22,7 +22,7 @@ struct cls_cgroup_head {
 	u32			handle;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
-	struct tcf_proto	*tp;
+	struct net		*net;
 	struct rcu_head		rcu;
 };
 
@@ -87,7 +87,7 @@ static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 						    rcu);
 
 	tcf_exts_destroy(&head->exts);
-	tcf_em_tree_destroy(head->tp, &head->ematches);
+	tcf_em_tree_destroy(head->net, &head->ematches);
 	kfree(head);
 }
 
@@ -122,7 +122,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	else
 		new->handle = handle;
 
-	new->tp = tp;
+	new->net = net;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
 			       cgroup_policy);
 	if (err < 0)
@@ -133,7 +133,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
+	err = tcf_em_tree_validate(net, tb[TCA_CGROUP_EMATCHES], &t);
 	if (err < 0) {
 		tcf_exts_destroy(&e);
 		goto errout;
@@ -157,7 +157,7 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 
 	if (head) {
 		tcf_exts_destroy(&head->exts);
-		tcf_em_tree_destroy(tp, &head->ematches);
+		tcf_em_tree_destroy(head->net, &head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
 		kfree_rcu(head, rcu);
 	}
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f18d27f7..5413810 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -41,7 +41,7 @@ struct flow_filter {
 	struct list_head	list;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
-	struct tcf_proto	*tp;
+	struct net		*net;
 	struct timer_list	perturb_timer;
 	u32			perturb_period;
 	u32			handle;
@@ -355,7 +355,7 @@ static void flow_destroy_filter(struct rcu_head *head)
 
 	del_timer_sync(&f->perturb_timer);
 	tcf_exts_destroy(&f->exts);
-	tcf_em_tree_destroy(f->tp, &f->ematches);
+	tcf_em_tree_destroy(f->net, &f->ematches);
 	kfree(f);
 }
 
@@ -410,7 +410,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &t);
+	err = tcf_em_tree_validate(net, tb[TCA_FLOW_EMATCHES], &t);
 	if (err < 0)
 		goto err1;
 
@@ -428,7 +428,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		/* Copy fold into fnew */
 		fnew->handle = fold->handle;
 		fnew->keymask = fold->keymask;
-		fnew->tp = fold->tp;
+		fnew->net = fold->net;
 
 		fnew->handle = fold->handle;
 		fnew->nkeys = fold->nkeys;
@@ -481,7 +481,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 
 		fnew->handle = handle;
 		fnew->mask  = ~0U;
-		fnew->tp = tp;
+		fnew->net = net;
 		get_random_bytes(&fnew->hashrnd, 4);
 		tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 	}
@@ -530,7 +530,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 err2:
-	tcf_em_tree_destroy(tp, &t);
+	tcf_em_tree_destroy(net, &t);
 	kfree(fnew);
 err1:
 	tcf_exts_destroy(&e);
diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
index 7c292d4..65570b3 100644
--- a/net/sched/em_canid.c
+++ b/net/sched/em_canid.c
@@ -120,8 +120,8 @@ static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
 	return match;
 }
 
-static int em_canid_change(struct tcf_proto *tp, void *data, int len,
-			  struct tcf_ematch *m)
+static int em_canid_change(struct net *net, void *data, int len,
+			   struct tcf_ematch *m)
 {
 	struct can_filter *conf = data; /* Array with rules */
 	struct canid_match *cm;
@@ -183,7 +183,7 @@ static int em_canid_change(struct tcf_proto *tp, void *data, int len,
 	return 0;
 }
 
-static void em_canid_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+static void em_canid_destroy(struct net *net, struct tcf_ematch *m)
 {
 	struct canid_match *cm = em_canid_priv(m);
 
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 527aeb7..10f31df 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -19,12 +19,11 @@
 #include <net/ip.h>
 #include <net/pkt_cls.h>
 
-static int em_ipset_change(struct tcf_proto *tp, void *data, int data_len,
+static int em_ipset_change(struct net *net, void *data, int data_len,
 			   struct tcf_ematch *em)
 {
 	struct xt_set_info *set = data;
 	ip_set_id_t index;
-	struct net *net = dev_net(qdisc_dev(tp->q));
 
 	if (data_len != sizeof(*set))
 		return -EINVAL;
@@ -42,11 +41,11 @@ static int em_ipset_change(struct tcf_proto *tp, void *data, int data_len,
 	return -ENOMEM;
 }
 
-static void em_ipset_destroy(struct tcf_proto *p, struct tcf_ematch *em)
+static void em_ipset_destroy(struct net *net, struct tcf_ematch *em)
 {
 	const struct xt_set_info *set = (const void *) em->data;
 	if (set) {
-		ip_set_nfnl_put(dev_net(qdisc_dev(p->q)), set->index);
+		ip_set_nfnl_put(net, set->index);
 		kfree((void *) em->data);
 	}
 }
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 9b8c0b0..7ce92a2 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -856,7 +856,7 @@ static const struct nla_policy meta_policy[TCA_EM_META_MAX + 1] = {
 	[TCA_EM_META_HDR]	= { .len = sizeof(struct tcf_meta_hdr) },
 };
 
-static int em_meta_change(struct tcf_proto *tp, void *data, int len,
+static int em_meta_change(struct net *net, void *data, int len,
 			  struct tcf_ematch *m)
 {
 	int err;
@@ -908,7 +908,7 @@ errout:
 	return err;
 }
 
-static void em_meta_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+static void em_meta_destroy(struct net *net, struct tcf_ematch *m)
 {
 	if (m)
 		meta_delete((struct meta_match *) m->data);
diff --git a/net/sched/em_nbyte.c b/net/sched/em_nbyte.c
index a3bed07..df3110d 100644
--- a/net/sched/em_nbyte.c
+++ b/net/sched/em_nbyte.c
@@ -23,7 +23,7 @@ struct nbyte_data {
 	char			pattern[0];
 };
 
-static int em_nbyte_change(struct tcf_proto *tp, void *data, int data_len,
+static int em_nbyte_change(struct net *net, void *data, int data_len,
 			   struct tcf_ematch *em)
 {
 	struct tcf_em_nbyte *nbyte = data;
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index 15d353d..45d53d5 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -45,7 +45,7 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 	return skb_find_text(skb, from, to, tm->config, &state) != UINT_MAX;
 }
 
-static int em_text_change(struct tcf_proto *tp, void *data, int len,
+static int em_text_change(struct net *net, void *data, int len,
 			  struct tcf_ematch *m)
 {
 	struct text_match *tm;
@@ -100,7 +100,7 @@ retry:
 	return 0;
 }
 
-static void em_text_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+static void em_text_destroy(struct net *net, struct tcf_ematch *m)
 {
 	if (EM_TEXT_PRIV(m) && EM_TEXT_PRIV(m)->config)
 		textsearch_destroy(EM_TEXT_PRIV(m)->config);
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 3a633de..b3b90ef 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -170,7 +170,7 @@ static inline struct tcf_ematch *tcf_em_get_match(struct tcf_ematch_tree *tree,
 }
 
 
-static int tcf_em_validate(struct tcf_proto *tp,
+static int tcf_em_validate(struct net *net,
 			   struct tcf_ematch_tree_hdr *tree_hdr,
 			   struct tcf_ematch *em, struct nlattr *nla, int idx)
 {
@@ -240,7 +240,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 			goto errout;
 
 		if (em->ops->change) {
-			err = em->ops->change(tp, data, data_len, em);
+			err = em->ops->change(net, data, data_len, em);
 			if (err < 0)
 				goto errout;
 		} else if (data_len > 0) {
@@ -285,7 +285,7 @@ static const struct nla_policy em_policy[TCA_EMATCH_TREE_MAX + 1] = {
 /**
  * tcf_em_tree_validate - validate ematch config TLV and build ematch tree
  *
- * @tp: classifier kind handle
+ * @net: callers net reference
  * @nla: ematch tree configuration TLV
  * @tree: destination ematch tree variable to store the resulting
  *        ematch tree.
@@ -298,7 +298,7 @@ static const struct nla_policy em_policy[TCA_EMATCH_TREE_MAX + 1] = {
  *
  * Returns a negative error code if the configuration TLV contains errors.
  */
-int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
+int tcf_em_tree_validate(struct net *net, struct nlattr *nla,
 			 struct tcf_ematch_tree *tree)
 {
 	int idx, list_len, matches_len, err;
@@ -356,7 +356,7 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 
 		em = tcf_em_get_match(tree, idx);
 
-		err = tcf_em_validate(tp, tree_hdr, em, rt_match, idx);
+		err = tcf_em_validate(net, tree_hdr, em, rt_match, idx);
 		if (err < 0)
 			goto errout_abort;
 
@@ -378,7 +378,7 @@ errout:
 	return err;
 
 errout_abort:
-	tcf_em_tree_destroy(tp, tree);
+	tcf_em_tree_destroy(net, tree);
 	return err;
 }
 EXPORT_SYMBOL(tcf_em_tree_validate);
@@ -386,14 +386,14 @@ EXPORT_SYMBOL(tcf_em_tree_validate);
 /**
  * tcf_em_tree_destroy - destroy an ematch tree
  *
- * @tp: classifier kind handle
+ * @net: callers net reference
  * @tree: ematch tree to be deleted
  *
  * This functions destroys an ematch tree previously created by
  * tcf_em_tree_validate()/tcf_em_tree_change(). You must ensure that
  * the ematch tree is not in use before calling this function.
  */
-void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
+void tcf_em_tree_destroy(struct net *net, struct tcf_ematch_tree *tree)
 {
 	int i;
 
@@ -405,7 +405,7 @@ void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
 
 		if (em->ops) {
 			if (em->ops->destroy)
-				em->ops->destroy(tp, em);
+				em->ops->destroy(net, em);
 			else if (!tcf_em_is_simple(em))
 				kfree((void *) em->data);
 			module_put(em->ops->owner);
