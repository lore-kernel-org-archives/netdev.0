From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 06/12] net: sched: fw use RCU
Date: Fri, 10 Jan 2014 01:39:57 -0800
Message-ID: <20140110093955.7193.42323.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:48640 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbaAJJl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:41:29 -0500
Received: by mail-ob0-f173.google.com with SMTP id gq1so4521067obb.4
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:41:29 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU'ify fw classifier.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_fw.c |  112 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 77 insertions(+), 35 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 3f9cece..6f7680f 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -32,18 +32,21 @@
 #define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
 
 struct fw_head {
-	struct fw_filter *ht[HTSIZE];
+	struct rcu_head	rcu;
+	struct fw_filter __rcu *ht[HTSIZE];
 	u32 mask;
 };
 
 struct fw_filter {
-	struct fw_filter	*next;
+	struct fw_filter __rcu	*next;
+	struct rcu_head		rcu;
 	u32			id;
 	struct tcf_result	res;
 #ifdef CONFIG_NET_CLS_IND
 	char			indev[IFNAMSIZ];
 #endif /* CONFIG_NET_CLS_IND */
 	struct tcf_exts		exts;
+	struct tcf_proto	*tp;
 };
 
 static inline int fw_hash(u32 handle)
@@ -75,14 +78,16 @@ static inline int fw_hash(u32 handle)
 static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rcu_dereference_bh(tp->root);
 	struct fw_filter *f;
 	int r;
 	u32 id = skb->mark;
 
 	if (head != NULL) {
 		id &= head->mask;
-		for (f = head->ht[fw_hash(id)]; f; f = f->next) {
+
+		for (f = rcu_dereference_bh(head->ht[fw_hash(id)]); f;
+		     f = rcu_dereference_bh(f->next)) {
 			if (f->id == id) {
 				*res = f->res;
 #ifdef CONFIG_NET_CLS_IND
@@ -111,13 +116,14 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
 	struct fw_filter *f;
 
 	if (head == NULL)
 		return 0;
 
-	for (f = head->ht[fw_hash(handle)]; f; f = f->next) {
+	f = rtnl_dereference(head->ht[fw_hash(handle)]);
+	for (; f; f = rtnl_dereference(f->next)) {
 		if (f->id == handle)
 			return (unsigned long)f;
 	}
@@ -133,8 +139,11 @@ static int fw_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
+static void fw_delete_filter(struct rcu_head *head)
 {
+	struct fw_filter *f = container_of(head, struct fw_filter, rcu);
+	struct tcf_proto *tp = f->tp;
+
 	tcf_unbind_filter(tp, &f->res);
 	tcf_exts_destroy(tp, &f->exts);
 	kfree(f);
@@ -142,7 +151,7 @@ static void fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
 
 static void fw_destroy(struct tcf_proto *tp)
 {
-	struct fw_head *head = tp->root;
+	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f;
 	int h;
 
@@ -150,29 +159,32 @@ static void fw_destroy(struct tcf_proto *tp)
 		return;
 
 	for (h = 0; h < HTSIZE; h++) {
-		while ((f = head->ht[h]) != NULL) {
-			head->ht[h] = f->next;
-			fw_delete_filter(tp, f);
+		while ((f = rtnl_dereference(head->ht[h])) != NULL) {
+			rcu_assign_pointer(head->ht[h],
+					   rtnl_dereference(f->next));
+			call_rcu(&f->rcu, fw_delete_filter);
 		}
 	}
-	kfree(head);
+	rcu_assign_pointer(tp->root, NULL);
+	kfree_rcu(head, rcu);
 }
 
 static int fw_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
-	struct fw_filter *f = (struct fw_filter *)arg;
-	struct fw_filter **fp;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
+	struct fw_filter *pfp, *f = (struct fw_filter *)arg;
+	struct fw_filter __rcu **fp;
 
 	if (head == NULL || f == NULL)
 		goto out;
 
-	for (fp = &head->ht[fw_hash(f->id)]; *fp; fp = &(*fp)->next) {
-		if (*fp == f) {
-			tcf_tree_lock(tp);
-			*fp = f->next;
-			tcf_tree_unlock(tp);
-			fw_delete_filter(tp, f);
+	fp = &head->ht[fw_hash(f->id)];
+
+	for (pfp = rtnl_dereference(*fp); pfp;
+	     fp = &pfp->next, pfp = rtnl_dereference(*fp)) {
+		if (pfp == f) {
+			rcu_assign_pointer(*fp, rtnl_dereference(f->next));
+			call_rcu(&f->rcu, fw_delete_filter);
 			return 0;
 		}
 	}
@@ -190,7 +202,7 @@ static int
 fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	struct nlattr **tb, struct nlattr **tca, unsigned long base)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
 	struct tcf_exts e;
 	u32 mask;
 	int err;
@@ -235,7 +247,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 		     struct nlattr **tca,
 		     unsigned long *arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
 	struct fw_filter *f = (struct fw_filter *) *arg;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FW_MAX + 1];
@@ -248,10 +260,42 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	if (f != NULL) {
+	if (f) {
+		struct fw_filter *pfp, *fnew;
+		struct fw_filter __rcu **fp;
+
 		if (f->id != handle && handle)
 			return -EINVAL;
-		return fw_change_attrs(net, tp, f, tb, tca, base);
+
+		fnew = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
+		if (!fnew)
+			return -ENOBUFS;
+
+		fnew->id = f->id;
+		fnew->res = f->res;
+#ifdef CONFIG_NET_CLS_IND
+		strcpy(fnew->indev, f->indev);
+#endif /* CONFIG_NET_CLS_IND */
+		fnew->tp = f->tp;
+
+		err = fw_change_attrs(net, tp, fnew, tb, tca, base);
+		if (err < 0) {
+			kfree(fnew);
+			return err;
+		}
+
+		fp = &head->ht[fw_hash(fnew->id)];
+		for (pfp = rtnl_dereference(*fp); pfp;
+		     fp = &pfp->next, pfp = rtnl_dereference(*fp))
+			if (pfp == f)
+				break;
+
+		rcu_assign_pointer(fnew->next, rtnl_dereference(pfp->next));
+		rcu_assign_pointer(*fp, fnew);
+		call_rcu(&f->rcu, fw_delete_filter);
+
+		*arg = (unsigned long)fnew;
+		return err;
 	}
 
 	if (!handle)
@@ -267,9 +311,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 			return -ENOBUFS;
 		head->mask = mask;
 
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
+		rcu_assign_pointer(tp->root, head);
 	}
 
 	f = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
@@ -278,15 +320,14 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 
 	tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
 	f->id = handle;
+	f->tp = tp;
 
 	err = fw_change_attrs(net, tp, f, tb, tca, base);
 	if (err < 0)
 		goto errout;
 
-	f->next = head->ht[fw_hash(handle)];
-	tcf_tree_lock(tp);
-	head->ht[fw_hash(handle)] = f;
-	tcf_tree_unlock(tp);
+	rcu_assign_pointer(f->next, head->ht[fw_hash(handle)]);
+	rcu_assign_pointer(head->ht[fw_hash(handle)], f);
 
 	*arg = (unsigned long)f;
 	return 0;
@@ -298,7 +339,7 @@ errout:
 
 static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
 	int h;
 
 	if (head == NULL)
@@ -310,7 +351,8 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	for (h = 0; h < HTSIZE; h++) {
 		struct fw_filter *f;
 
-		for (f = head->ht[h]; f; f = f->next) {
+		for (f = rtnl_dereference(head->ht[h]); f;
+		     f = rtnl_dereference(f->next)) {
 			if (arg->count < arg->skip) {
 				arg->count++;
 				continue;
@@ -327,7 +369,7 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
-	struct fw_head *head = (struct fw_head *)tp->root;
+	struct fw_head *head = (struct fw_head *)rtnl_dereference(tp->root);
 	struct fw_filter *f = (struct fw_filter *)fh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
