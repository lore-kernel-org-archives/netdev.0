From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 1/3] net: sched: remove tcf_proto from ematch
 calls
Date: Sun, 05 Oct 2014 21:27:53 -0700
Message-ID: <20141006042751.6010.86647.stgit@nitbit.x32>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:48464 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbaJFE2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:28:13 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so3370707obc.29
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 21:28:13 -0700 (PDT)
In-Reply-To: <20141006042335.6010.27000.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the tcf_proto argument from the ematch code paths that
only need it to reference the net namespace. This allows simplifying
qdisc code paths especially when we need to tear down the ematch
from an RCU callback. In this case we can not guarentee that the
tcf_proto structure is still valid.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_cls.h  |   10 +++++-----
 net/sched/cls_basic.c  |    2 +-
 net/sched/cls_cgroup.c |    4 ++--
 net/sched/cls_flow.c   |    4 ++--
 net/sched/em_canid.c   |    4 ++--
 net/sched/em_ipset.c   |    7 +++----
 net/sched/em_meta.c    |    4 ++--
 net/sched/em_nbyte.c   |    2 +-
 net/sched/em_text.c    |    4 ++--
 net/sched/ematch.c     |   10 ++++++----
 10 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index ef44ad9..bc49967 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -166,6 +166,7 @@ struct tcf_ematch {
 	unsigned int		datalen;
 	u16			matchid;
 	u16			flags;
+	struct net		*net;
 };
 
 static inline int tcf_em_is_container(struct tcf_ematch *em)
@@ -229,12 +230,11 @@ struct tcf_ematch_tree {
 struct tcf_ematch_ops {
 	int			kind;
 	int			datalen;
-	int			(*change)(struct tcf_proto *, void *,
+	int			(*change)(struct net *net, void *,
 					  int, struct tcf_ematch *);
 	int			(*match)(struct sk_buff *, struct tcf_ematch *,
 					 struct tcf_pkt_info *);
-	void			(*destroy)(struct tcf_proto *,
-					   struct tcf_ematch *);
+	void			(*destroy)(struct tcf_ematch *);
 	int			(*dump)(struct sk_buff *, struct tcf_ematch *);
 	struct module		*owner;
 	struct list_head	link;
@@ -244,7 +244,7 @@ int tcf_em_register(struct tcf_ematch_ops *);
 void tcf_em_unregister(struct tcf_ematch_ops *);
 int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
 			 struct tcf_ematch_tree *);
-void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
+void tcf_em_tree_destroy(struct tcf_ematch_tree *);
 int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
 int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
 			struct tcf_pkt_info *);
@@ -301,7 +301,7 @@ struct tcf_ematch_tree {
 };
 
 #define tcf_em_tree_validate(tp, tb, t) ((void)(t), 0)
-#define tcf_em_tree_destroy(tp, t) do { (void)(t); } while(0)
+#define tcf_em_tree_destroy(t) do { (void)(t); } while(0)
 #define tcf_em_tree_dump(skb, t, tlv) (0)
 #define tcf_em_tree_change(tp, dst, src) do { } while(0)
 #define tcf_em_tree_match(skb, t, info) ((void)(info), 1)
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index fe20826..90647a8 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -95,7 +95,7 @@ static void basic_delete_filter(struct rcu_head *head)
 
 	tcf_unbind_filter(tp, &f->res);
 	tcf_exts_destroy(&f->exts);
-	tcf_em_tree_destroy(tp, &f->ematches);
+	tcf_em_tree_destroy(&f->ematches);
 	kfree(f);
 }
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3409f16..2f77a89 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -87,7 +87,7 @@ static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 						    rcu);
 
 	tcf_exts_destroy(&head->exts);
-	tcf_em_tree_destroy(head->tp, &head->ematches);
+	tcf_em_tree_destroy(&head->ematches);
 	kfree(head);
 }
 
@@ -157,7 +157,7 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 
 	if (head) {
 		tcf_exts_destroy(&head->exts);
-		tcf_em_tree_destroy(tp, &head->ematches);
+		tcf_em_tree_destroy(&head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
 		kfree_rcu(head, rcu);
 	}
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f18d27f7..a5d2b20 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -355,7 +355,7 @@ static void flow_destroy_filter(struct rcu_head *head)
 
 	del_timer_sync(&f->perturb_timer);
 	tcf_exts_destroy(&f->exts);
-	tcf_em_tree_destroy(f->tp, &f->ematches);
+	tcf_em_tree_destroy(&f->ematches);
 	kfree(f);
 }
 
@@ -530,7 +530,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 err2:
-	tcf_em_tree_destroy(tp, &t);
+	tcf_em_tree_destroy(&t);
 	kfree(fnew);
 err1:
 	tcf_exts_destroy(&e);
diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
index 7c292d4..ddd883c 100644
--- a/net/sched/em_canid.c
+++ b/net/sched/em_canid.c
@@ -120,7 +120,7 @@ static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
 	return match;
 }
 
-static int em_canid_change(struct tcf_proto *tp, void *data, int len,
+static int em_canid_change(struct net *net, void *data, int len,
 			  struct tcf_ematch *m)
 {
 	struct can_filter *conf = data; /* Array with rules */
@@ -183,7 +183,7 @@ static int em_canid_change(struct tcf_proto *tp, void *data, int len,
 	return 0;
 }
 
-static void em_canid_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
+static void em_canid_destroy(struct tcf_ematch *m)
 {
 	struct canid_match *cm = em_canid_priv(m);
 
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 527aeb7..5b4a4ef 100644
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
+static void em_ipset_destroy(struct tcf_ematch *em)
 {
 	const struct xt_set_info *set = (const void *) em->data;
 	if (set) {
-		ip_set_nfnl_put(dev_net(qdisc_dev(p->q)), set->index);
+		ip_set_nfnl_put(em->net, set->index);
 		kfree((void *) em->data);
 	}
 }
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 9b8c0b0..c8f8c39 100644
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
+static void em_meta_destroy(struct tcf_ematch *m)
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
index 15d353d..f03c3de 100644
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
+static void em_text_destroy(struct tcf_ematch *m)
 {
 	if (EM_TEXT_PRIV(m) && EM_TEXT_PRIV(m)->config)
 		textsearch_destroy(EM_TEXT_PRIV(m)->config);
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index ad57f44..8250c36 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -178,6 +178,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 	struct tcf_ematch_hdr *em_hdr = nla_data(nla);
 	int data_len = nla_len(nla) - sizeof(*em_hdr);
 	void *data = (void *) em_hdr + sizeof(*em_hdr);
+	struct net *net = dev_net(qdisc_dev(tp->q));
 
 	if (!TCF_EM_REL_VALID(em_hdr->flags))
 		goto errout;
@@ -240,7 +241,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 			goto errout;
 
 		if (em->ops->change) {
-			err = em->ops->change(tp, data, data_len, em);
+			err = em->ops->change(net, data, data_len, em);
 			if (err < 0)
 				goto errout;
 		} else if (data_len > 0) {
@@ -271,6 +272,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 	em->matchid = em_hdr->matchid;
 	em->flags = em_hdr->flags;
 	em->datalen = data_len;
+	em->net = net;
 
 	err = 0;
 errout:
@@ -378,7 +380,7 @@ errout:
 	return err;
 
 errout_abort:
-	tcf_em_tree_destroy(tp, tree);
+	tcf_em_tree_destroy(tree);
 	return err;
 }
 EXPORT_SYMBOL(tcf_em_tree_validate);
@@ -393,7 +395,7 @@ EXPORT_SYMBOL(tcf_em_tree_validate);
  * tcf_em_tree_validate()/tcf_em_tree_change(). You must ensure that
  * the ematch tree is not in use before calling this function.
  */
-void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
+void tcf_em_tree_destroy(struct tcf_ematch_tree *tree)
 {
 	int i;
 
@@ -405,7 +407,7 @@ void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
 
 		if (em->ops) {
 			if (em->ops->destroy)
-				em->ops->destroy(tp, em);
+				em->ops->destroy(em);
 			else if (!tcf_em_is_simple(em))
 				kfree((void *) em->data);
 			module_put(em->ops->owner);
