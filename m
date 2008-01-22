From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/06]: Convert actions from rtnetlink to new netlink API
Date: Tue, 22 Jan 2008 15:56:17 +0100 (MET)
Message-ID: <20080122145551.6862.9933.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbYAVO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:18 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Convert actions from rtnetlink to new netlink API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9d8b9cf5c729a718df7861276e6f4c4868a89bd2
tree 64eca29283578c622c492013ec6562bd95f7a7cd
parent 7798bc7f67ba5ffcfc542f5c88762b6db705992e
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:42 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:42 +0100

 include/net/act_api.h  |    8 +-
 net/sched/act_api.c    |  214 ++++++++++++++++++++++++------------------------
 net/sched/act_gact.c   |   28 +++---
 net/sched/act_ipt.c    |   46 +++++-----
 net/sched/act_mirred.c |   18 ++--
 net/sched/act_nat.c    |   18 ++--
 net/sched/act_pedit.c  |   20 ++--
 net/sched/act_police.c |   52 ++++++------
 net/sched/act_simple.c |   24 +++--
 net/sched/cls_api.c    |    6 -
 10 files changed, 218 insertions(+), 216 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 68b4eaf..c5ac61a 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -89,7 +89,7 @@ struct tc_action_ops {
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	int     (*cleanup)(struct tc_action *, int bind);
 	int     (*lookup)(struct tc_action *, u32);
-	int     (*init)(struct rtattr *, struct rtattr *, struct tc_action *, int , int);
+	int     (*init)(struct nlattr *, struct nlattr *, struct tc_action *, int , int);
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
 };
 
@@ -104,7 +104,7 @@ extern u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
 extern int tcf_hash_search(struct tc_action *a, u32 index);
 extern struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
 					 int bind, struct tcf_hashinfo *hinfo);
-extern struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est,
+extern struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 					  struct tc_action *a, int size,
 					  int bind, u32 *idx_gen,
 					  struct tcf_hashinfo *hinfo);
@@ -114,8 +114,8 @@ extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
 extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
-extern struct tc_action *tcf_action_init(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
-extern struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
+extern struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind, int *err);
+extern struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind, int *err);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 11f3097..ebd21d2 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -68,7 +68,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 {
 	struct tcf_common *p;
 	int err = 0, index = -1,i = 0, s_i = 0, n_i = 0;
-	struct rtattr *r ;
+	struct nlattr *r ;
 
 	read_lock_bh(hinfo->lock);
 
@@ -83,15 +83,15 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 				continue;
 			a->priv = p;
 			a->order = n_i;
-			r = (struct rtattr *)skb_tail_pointer(skb);
-			RTA_PUT(skb, a->order, 0, NULL);
+			r = (struct nlattr *)skb_tail_pointer(skb);
+			NLA_PUT(skb, a->order, 0, NULL);
 			err = tcf_action_dump_1(skb, a, 0, 0);
 			if (err < 0) {
 				index--;
 				nlmsg_trim(skb, r);
 				goto done;
 			}
-			r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
+			r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
 			n_i++;
 			if (n_i >= TCA_ACT_MAX_PRIO)
 				goto done;
@@ -103,7 +103,7 @@ done:
 		cb->args[0] += n_i;
 	return n_i;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, r);
 	goto done;
 }
@@ -112,12 +112,12 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			  struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p, *s_p;
-	struct rtattr *r ;
+	struct nlattr *r ;
 	int i= 0, n_i = 0;
 
-	r = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, a->order, 0, NULL);
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	r = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, a->order, 0, NULL);
+	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
@@ -129,11 +129,11 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			p = s_p;
 		}
 	}
-	RTA_PUT(skb, TCA_FCNT, 4, &n_i);
-	r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
+	NLA_PUT(skb, TCA_FCNT, 4, &n_i);
+	r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
 
 	return n_i;
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, r);
 	return -EINVAL;
 }
@@ -211,7 +211,7 @@ struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind,
 }
 EXPORT_SYMBOL(tcf_hash_check);
 
-struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_action *a, int size, int bind, u32 *idx_gen, struct tcf_hashinfo *hinfo)
+struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a, int size, int bind, u32 *idx_gen, struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
@@ -227,7 +227,7 @@ struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_acti
 	p->tcfc_tm.lastuse = jiffies;
 	if (est)
 		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
-				  &p->tcfc_lock, (struct nlattr *)est);
+				  &p->tcfc_lock, est);
 	a->priv = (void *) p;
 	return p;
 }
@@ -305,15 +305,15 @@ static struct tc_action_ops *tc_lookup_action_n(char *kind)
 	return a;
 }
 
-/* lookup by rtattr */
-static struct tc_action_ops *tc_lookup_action(struct rtattr *kind)
+/* lookup by nlattr */
+static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 {
 	struct tc_action_ops *a = NULL;
 
 	if (kind) {
 		read_lock(&act_mod_lock);
 		for (a = act_base; a; a = a->next) {
-			if (rtattr_strcmp(kind, a->kind) == 0) {
+			if (nla_strcmp(kind, a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
 					return NULL;
@@ -414,22 +414,22 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *r;
+	struct nlattr *r;
 
 	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
 	if (tcf_action_copy_stats(skb, a, 0))
-		goto rtattr_failure;
-	r = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+		goto nla_put_failure;
+	r = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if ((err = tcf_action_dump_old(skb, a, bind, ref)) > 0) {
-		r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
+		r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
 		return err;
 	}
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -441,45 +441,45 @@ tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
 	struct tc_action *a;
 	int err = -EINVAL;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *r ;
+	struct nlattr *r ;
 
 	while ((a = act) != NULL) {
-		r = (struct rtattr *)skb_tail_pointer(skb);
+		r = (struct nlattr *)skb_tail_pointer(skb);
 		act = a->next;
-		RTA_PUT(skb, a->order, 0, NULL);
+		NLA_PUT(skb, a->order, 0, NULL);
 		err = tcf_action_dump_1(skb, a, bind, ref);
 		if (err < 0)
 			goto errout;
-		r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
+		r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
 	}
 
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	err = -EINVAL;
 errout:
 	nlmsg_trim(skb, b);
 	return err;
 }
 
-struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
+struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 				    char *name, int ovr, int bind, int *err)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
 	char act_name[IFNAMSIZ];
-	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind;
+	struct nlattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *kind;
 
 	*err = -EINVAL;
 
 	if (name == NULL) {
-		if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
+		if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
 			goto err_out;
-		kind = tb[TCA_ACT_KIND-1];
+		kind = tb[TCA_ACT_KIND];
 		if (kind == NULL)
 			goto err_out;
-		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
+		if (nla_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
 	} else {
 		if (strlcpy(act_name, name, IFNAMSIZ) >= IFNAMSIZ)
@@ -517,9 +517,9 @@ struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
 
 	/* backward compatibility for policer */
 	if (name == NULL)
-		*err = a_o->init(tb[TCA_ACT_OPTIONS-1], est, a, ovr, bind);
+		*err = a_o->init(tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
 	else
-		*err = a_o->init(rta, est, a, ovr, bind);
+		*err = a_o->init(nla, est, a, ovr, bind);
 	if (*err < 0)
 		goto err_free;
 
@@ -542,23 +542,23 @@ err_out:
 	return NULL;
 }
 
-struct tc_action *tcf_action_init(struct rtattr *rta, struct rtattr *est,
+struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
 				  char *name, int ovr, int bind, int *err)
 {
-	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
+	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 	int i;
 
-	if (rtattr_parse_nested(tb, TCA_ACT_MAX_PRIO, rta) < 0) {
+	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0) {
 		*err = -EINVAL;
 		return head;
 	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO && tb[i]; i++) {
+	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
 		if (act == NULL)
 			goto err;
-		act->order = i+1;
+		act->order = i;
 
 		if (head == NULL)
 			head = act;
@@ -625,7 +625,7 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *x;
+	struct nlattr *x;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
 
@@ -634,18 +634,18 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	x = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	if (tcf_action_dump(skb, a, bind, ref) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	x->rta_len = skb_tail_pointer(skb) - (u8 *)x;
+	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 nlmsg_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -668,20 +668,20 @@ act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 }
 
 static struct tc_action *
-tcf_action_get_1(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int *err)
+tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int *err)
 {
-	struct rtattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *tb[TCA_ACT_MAX+1];
 	struct tc_action *a;
 	int index;
 
 	*err = -EINVAL;
-	if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
+	if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
 		return NULL;
 
-	if (tb[TCA_ACT_INDEX - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_ACT_INDEX - 1]) < sizeof(index))
+	if (tb[TCA_ACT_INDEX] == NULL ||
+	    nla_len(tb[TCA_ACT_INDEX]) < sizeof(index))
 		return NULL;
-	index = *(int *)RTA_DATA(tb[TCA_ACT_INDEX - 1]);
+	index = *(int *)nla_data(tb[TCA_ACT_INDEX]);
 
 	*err = -ENOMEM;
 	a = kzalloc(sizeof(struct tc_action), GFP_KERNEL);
@@ -689,7 +689,7 @@ tcf_action_get_1(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int *err)
 		return NULL;
 
 	*err = -EINVAL;
-	a->ops = tc_lookup_action(tb[TCA_ACT_KIND - 1]);
+	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
 	if (a->ops == NULL)
 		goto err_free;
 	if (a->ops->lookup == NULL)
@@ -731,16 +731,16 @@ static struct tc_action *create_a(int i)
 	return act;
 }
 
-static int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
+static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 {
 	struct sk_buff *skb;
 	unsigned char *b;
 	struct nlmsghdr *nlh;
 	struct tcamsg *t;
 	struct netlink_callback dcb;
-	struct rtattr *x;
-	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind;
+	struct nlattr *x;
+	struct nlattr *tb[TCA_ACT_MAX+1];
+	struct nlattr *kind;
 	struct tc_action *a = create_a(0);
 	int err = -EINVAL;
 
@@ -758,10 +758,10 @@ static int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
 
 	b = skb_tail_pointer(skb);
 
-	if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
+	if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
 		goto err_out;
 
-	kind = tb[TCA_ACT_KIND-1];
+	kind = tb[TCA_ACT_KIND];
 	a->ops = tc_lookup_action(kind);
 	if (a->ops == NULL)
 		goto err_out;
@@ -772,14 +772,14 @@ static int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	x = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
 	if (err < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	x->rta_len = skb_tail_pointer(skb) - (u8 *)x;
+	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	nlh->nlmsg_flags |= NLM_F_ROOT;
@@ -791,7 +791,7 @@ static int tca_action_flush(struct rtattr *rta, struct nlmsghdr *n, u32 pid)
 
 	return err;
 
-rtattr_failure:
+nla_put_failure:
 nlmsg_failure:
 	module_put(a->ops->owner);
 err_out:
@@ -801,13 +801,13 @@ err_out:
 }
 
 static int
-tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event)
+tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 {
 	int i, ret = 0;
-	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
+	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 
-	if (rtattr_parse_nested(tb, TCA_ACT_MAX_PRIO, rta) < 0)
+	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0)
 		return -EINVAL;
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
@@ -815,11 +815,11 @@ tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event)
 			return tca_action_flush(tb[0], n, pid);
 	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO && tb[i]; i++) {
+	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_get_1(tb[i], n, pid, &ret);
 		if (act == NULL)
 			goto err;
-		act->order = i+1;
+		act->order = i;
 
 		if (head == NULL)
 			head = act;
@@ -865,7 +865,7 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	struct rtattr *x;
+	struct nlattr *x;
 	unsigned char *b;
 	int err = 0;
 
@@ -881,13 +881,13 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	x = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	if (tcf_action_dump(skb, a, 0, 0) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	x->rta_len = skb_tail_pointer(skb) - (u8 *)x;
+	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
@@ -897,7 +897,7 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 		err = 0;
 	return err;
 
-rtattr_failure:
+nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 	return -1;
@@ -905,14 +905,14 @@ nlmsg_failure:
 
 
 static int
-tcf_action_add(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int ovr)
+tcf_action_add(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int ovr)
 {
 	int ret = 0;
 	struct tc_action *act;
 	struct tc_action *a;
 	u32 seq = n->nlmsg_seq;
 
-	act = tcf_action_init(rta, NULL, NULL, ovr, 0, &ret);
+	act = tcf_action_init(nla, NULL, NULL, ovr, 0, &ret);
 	if (act == NULL)
 		goto done;
 
@@ -931,14 +931,18 @@ done:
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = skb->sk->sk_net;
-	struct rtattr **tca = arg;
+	struct nlattr *tca[TCA_ACT_MAX + 1];
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = 0, ovr = 0;
 
 	if (net != &init_net)
 		return -EINVAL;
 
-	if (tca[TCA_ACT_TAB-1] == NULL) {
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
+	if (ret < 0)
+		return ret;
+
+	if (tca[TCA_ACT_TAB] == NULL) {
 		printk("tc_ctl_action: received NO action attribs\n");
 		return -EINVAL;
 	}
@@ -956,15 +960,15 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if (n->nlmsg_flags&NLM_F_REPLACE)
 			ovr = 1;
 replay:
-		ret = tcf_action_add(tca[TCA_ACT_TAB-1], n, pid, ovr);
+		ret = tcf_action_add(tca[TCA_ACT_TAB], n, pid, ovr);
 		if (ret == -EAGAIN)
 			goto replay;
 		break;
 	case RTM_DELACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_DELACTION);
+		ret = tca_action_gd(tca[TCA_ACT_TAB], n, pid, RTM_DELACTION);
 		break;
 	case RTM_GETACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_GETACTION);
+		ret = tca_action_gd(tca[TCA_ACT_TAB], n, pid, RTM_GETACTION);
 		break;
 	default:
 		BUG();
@@ -973,33 +977,33 @@ replay:
 	return ret;
 }
 
-static struct rtattr *
+static struct nlattr *
 find_dump_kind(struct nlmsghdr *n)
 {
-	struct rtattr *tb1, *tb2[TCA_ACT_MAX+1];
-	struct rtattr *tb[TCA_ACT_MAX_PRIO + 1];
-	struct rtattr *rta[TCAA_MAX + 1];
-	struct rtattr *kind;
+	struct nlattr *tb1, *tb2[TCA_ACT_MAX+1];
+	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
+	struct nlattr *nla[TCAA_MAX + 1];
+	struct nlattr *kind;
 	int min_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 	int attrlen = n->nlmsg_len - NLMSG_ALIGN(min_len);
-	struct rtattr *attr = (void *) n + NLMSG_ALIGN(min_len);
+	struct nlattr *attr = (void *) n + NLMSG_ALIGN(min_len);
 
-	if (rtattr_parse(rta, TCAA_MAX, attr, attrlen) < 0)
+	if (nla_parse(nla, TCAA_MAX, attr, attrlen, NULL) < 0)
 		return NULL;
-	tb1 = rta[TCA_ACT_TAB - 1];
+	tb1 = nla[TCA_ACT_TAB];
 	if (tb1 == NULL)
 		return NULL;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(tb1),
-			 NLMSG_ALIGN(RTA_PAYLOAD(tb1))) < 0)
+	if (nla_parse(tb, TCA_ACT_MAX_PRIO, nla_data(tb1),
+		      NLMSG_ALIGN(nla_len(tb1)), NULL) < 0)
 		return NULL;
 	if (tb[0] == NULL)
 		return NULL;
 
-	if (rtattr_parse(tb2, TCA_ACT_MAX, RTA_DATA(tb[0]),
-			 RTA_PAYLOAD(tb[0])) < 0)
+	if (nla_parse(tb2, TCA_ACT_MAX, nla_data(tb[0]),
+		      nla_len(tb[0]), NULL) < 0)
 		return NULL;
-	kind = tb2[TCA_ACT_KIND-1];
+	kind = tb2[TCA_ACT_KIND];
 
 	return kind;
 }
@@ -1010,12 +1014,12 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = skb->sk->sk_net;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *x;
+	struct nlattr *x;
 	struct tc_action_ops *a_o;
 	struct tc_action a;
 	int ret = 0;
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
-	struct rtattr *kind = find_dump_kind(cb->nlh);
+	struct nlattr *kind = find_dump_kind(cb->nlh);
 
 	if (net != &init_net)
 		return 0;
@@ -1035,7 +1039,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (a_o->walk == NULL) {
 		printk("tc_dump_action: %s !capable of dumping table\n", a_o->kind);
-		goto rtattr_failure;
+		goto nla_put_failure;
 	}
 
 	nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
@@ -1045,15 +1049,15 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	x = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
 
 	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
 	if (ret < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (ret > 0) {
-		x->rta_len = skb_tail_pointer(skb) - (u8 *)x;
+		x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
 		ret = skb->len;
 	} else
 		nlmsg_trim(skb, x);
@@ -1064,7 +1068,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	module_put(a_o->owner);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 nlmsg_failure:
 	module_put(a_o->owner);
 	nlmsg_trim(skb, b);
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index a9631e4..5402cf8 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -53,26 +53,26 @@ typedef int (*g_rand)(struct tcf_gact *gact);
 static g_rand gact_rand[MAX_RAND]= { NULL, gact_net_rand, gact_determ };
 #endif /* CONFIG_GACT_PROB */
 
-static int tcf_gact_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 			 struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_GACT_MAX];
+	struct nlattr *tb[TCA_GACT_MAX + 1];
 	struct tc_gact *parm;
 	struct tcf_gact *gact;
 	struct tcf_common *pc;
 	int ret = 0;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_GACT_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_GACT_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_GACT_PARMS - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_GACT_PARMS - 1]) < sizeof(*parm))
+	if (tb[TCA_GACT_PARMS] == NULL ||
+	    nla_len(tb[TCA_GACT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
-	parm = RTA_DATA(tb[TCA_GACT_PARMS - 1]);
+	parm = nla_data(tb[TCA_GACT_PARMS]);
 
-	if (tb[TCA_GACT_PROB-1] != NULL)
+	if (tb[TCA_GACT_PROB] != NULL)
 #ifdef CONFIG_GACT_PROB
-		if (RTA_PAYLOAD(tb[TCA_GACT_PROB-1]) < sizeof(struct tc_gact_p))
+		if (nla_len(tb[TCA_GACT_PROB]) < sizeof(struct tc_gact_p))
 			return -EINVAL;
 #else
 		return -EOPNOTSUPP;
@@ -97,8 +97,8 @@ static int tcf_gact_init(struct rtattr *rta, struct rtattr *est,
 	spin_lock_bh(&gact->tcf_lock);
 	gact->tcf_action = parm->action;
 #ifdef CONFIG_GACT_PROB
-	if (tb[TCA_GACT_PROB-1] != NULL) {
-		struct tc_gact_p *p_parm = RTA_DATA(tb[TCA_GACT_PROB-1]);
+	if (tb[TCA_GACT_PROB] != NULL) {
+		struct tc_gact_p *p_parm = nla_data(tb[TCA_GACT_PROB]);
 		gact->tcfg_paction = p_parm->paction;
 		gact->tcfg_pval    = p_parm->pval;
 		gact->tcfg_ptype   = p_parm->ptype;
@@ -154,23 +154,23 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	opt.refcnt = gact->tcf_refcnt - ref;
 	opt.bindcnt = gact->tcf_bindcnt - bind;
 	opt.action = gact->tcf_action;
-	RTA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_GACT_PARMS, sizeof(opt), &opt);
 #ifdef CONFIG_GACT_PROB
 	if (gact->tcfg_ptype) {
 		struct tc_gact_p p_opt;
 		p_opt.paction = gact->tcfg_paction;
 		p_opt.pval = gact->tcfg_pval;
 		p_opt.ptype = gact->tcfg_ptype;
-		RTA_PUT(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt);
+		NLA_PUT(skb, TCA_GACT_PROB, sizeof(p_opt), &p_opt);
 	}
 #endif
 	t.install = jiffies_to_clock_t(jiffies - gact->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(gact->tcf_tm.expires);
-	RTA_PUT(skb, TCA_GACT_TM, sizeof(t), &t);
+	NLA_PUT(skb, TCA_GACT_TM, sizeof(t), &t);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index fa006e0..fee5282 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -92,10 +92,10 @@ static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
 	return ret;
 }
 
-static int tcf_ipt_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_IPT_MAX];
+	struct nlattr *tb[TCA_IPT_MAX + 1];
 	struct tcf_ipt *ipt;
 	struct tcf_common *pc;
 	struct ipt_entry_target *td, *t;
@@ -104,22 +104,22 @@ static int tcf_ipt_init(struct rtattr *rta, struct rtattr *est,
 	u32 hook = 0;
 	u32 index = 0;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_IPT_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_IPT_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_IPT_HOOK-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_IPT_HOOK-1]) < sizeof(u32))
+	if (tb[TCA_IPT_HOOK] == NULL ||
+	    nla_len(tb[TCA_IPT_HOOK]) < sizeof(u32))
 		return -EINVAL;
-	if (tb[TCA_IPT_TARG-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_IPT_TARG-1]) < sizeof(*t))
+	if (tb[TCA_IPT_TARG] == NULL ||
+	    nla_len(tb[TCA_IPT_TARG]) < sizeof(*t))
 		return -EINVAL;
-	td = (struct ipt_entry_target *)RTA_DATA(tb[TCA_IPT_TARG-1]);
-	if (RTA_PAYLOAD(tb[TCA_IPT_TARG-1]) < td->u.target_size)
+	td = (struct ipt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
+	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
 		return -EINVAL;
 
-	if (tb[TCA_IPT_INDEX-1] != NULL &&
-	    RTA_PAYLOAD(tb[TCA_IPT_INDEX-1]) >= sizeof(u32))
-		index = *(u32 *)RTA_DATA(tb[TCA_IPT_INDEX-1]);
+	if (tb[TCA_IPT_INDEX] != NULL &&
+	    nla_len(tb[TCA_IPT_INDEX]) >= sizeof(u32))
+		index = *(u32 *)nla_data(tb[TCA_IPT_INDEX]);
 
 	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
 	if (!pc) {
@@ -136,14 +136,14 @@ static int tcf_ipt_init(struct rtattr *rta, struct rtattr *est,
 	}
 	ipt = to_ipt(pc);
 
-	hook = *(u32 *)RTA_DATA(tb[TCA_IPT_HOOK-1]);
+	hook = *(u32 *)nla_data(tb[TCA_IPT_HOOK]);
 
 	err = -ENOMEM;
 	tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
 	if (unlikely(!tname))
 		goto err1;
-	if (tb[TCA_IPT_TABLE - 1] == NULL ||
-	    rtattr_strlcpy(tname, tb[TCA_IPT_TABLE-1], IFNAMSIZ) >= IFNAMSIZ)
+	if (tb[TCA_IPT_TABLE] == NULL ||
+	    nla_strlcpy(tname, tb[TCA_IPT_TABLE], IFNAMSIZ) >= IFNAMSIZ)
 		strcpy(tname, "mangle");
 
 	t = kmemdup(td, td->u.target_size, GFP_KERNEL);
@@ -243,25 +243,25 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 
 	t = kmemdup(ipt->tcfi_t, ipt->tcfi_t->u.user.target_size, GFP_ATOMIC);
 	if (unlikely(!t))
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	c.bindcnt = ipt->tcf_bindcnt - bind;
 	c.refcnt = ipt->tcf_refcnt - ref;
 	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
 
-	RTA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
-	RTA_PUT(skb, TCA_IPT_INDEX, 4, &ipt->tcf_index);
-	RTA_PUT(skb, TCA_IPT_HOOK, 4, &ipt->tcfi_hook);
-	RTA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
-	RTA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, ipt->tcfi_tname);
+	NLA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
+	NLA_PUT(skb, TCA_IPT_INDEX, 4, &ipt->tcf_index);
+	NLA_PUT(skb, TCA_IPT_HOOK, 4, &ipt->tcfi_hook);
+	NLA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
+	NLA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, ipt->tcfi_tname);
 	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
 	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
 	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
-	RTA_PUT(skb, TCA_IPT_TM, sizeof (tm), &tm);
+	NLA_PUT(skb, TCA_IPT_TM, sizeof (tm), &tm);
 	kfree(t);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	kfree(t);
 	return -1;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index c3fde91..db943a8 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -54,10 +54,10 @@ static inline int tcf_mirred_release(struct tcf_mirred *m, int bind)
 	return 0;
 }
 
-static int tcf_mirred_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 			   struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_MIRRED_MAX];
+	struct nlattr *tb[TCA_MIRRED_MAX + 1];
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct tcf_common *pc;
@@ -65,13 +65,13 @@ static int tcf_mirred_init(struct rtattr *rta, struct rtattr *est,
 	int ret = 0;
 	int ok_push = 0;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_MIRRED_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_MIRRED_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_MIRRED_PARMS-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_MIRRED_PARMS-1]) < sizeof(*parm))
+	if (tb[TCA_MIRRED_PARMS] == NULL ||
+	    nla_len(tb[TCA_MIRRED_PARMS]) < sizeof(*parm))
 		return -EINVAL;
-	parm = RTA_DATA(tb[TCA_MIRRED_PARMS-1]);
+	parm = nla_data(tb[TCA_MIRRED_PARMS]);
 
 	if (parm->ifindex) {
 		dev = __dev_get_by_index(&init_net, parm->ifindex);
@@ -207,14 +207,14 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	opt.bindcnt = m->tcf_bindcnt - bind;
 	opt.eaction = m->tcfm_eaction;
 	opt.ifindex = m->tcfm_ifindex;
-	RTA_PUT(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt);
 	t.install = jiffies_to_clock_t(jiffies - m->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - m->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(m->tcf_tm.expires);
-	RTA_PUT(skb, TCA_MIRRED_TM, sizeof(t), &t);
+	NLA_PUT(skb, TCA_MIRRED_TM, sizeof(t), &t);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index da5c1ea..be007bb 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -40,22 +40,22 @@ static struct tcf_hashinfo nat_hash_info = {
 	.lock	=	&nat_lock,
 };
 
-static int tcf_nat_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_NAT_MAX];
+	struct nlattr *tb[TCA_NAT_MAX + 1];
 	struct tc_nat *parm;
 	int ret = 0;
 	struct tcf_nat *p;
 	struct tcf_common *pc;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_NAT_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_NAT_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_NAT_PARMS - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_NAT_PARMS - 1]) < sizeof(*parm))
+	if (tb[TCA_NAT_PARMS] == NULL ||
+	    nla_len(tb[TCA_NAT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
-	parm = RTA_DATA(tb[TCA_NAT_PARMS - 1]);
+	parm = nla_data(tb[TCA_NAT_PARMS]);
 
 	pc = tcf_hash_check(parm->index, a, bind, &nat_hash_info);
 	if (!pc) {
@@ -275,17 +275,17 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 	opt->refcnt = p->tcf_refcnt - ref;
 	opt->bindcnt = p->tcf_bindcnt - bind;
 
-	RTA_PUT(skb, TCA_NAT_PARMS, s, opt);
+	NLA_PUT(skb, TCA_NAT_PARMS, s, opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
-	RTA_PUT(skb, TCA_NAT_TM, sizeof(t), &t);
+	NLA_PUT(skb, TCA_NAT_TM, sizeof(t), &t);
 
 	kfree(opt);
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	kfree(opt);
 	return -1;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index b46fab5..88d8a15 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -33,10 +33,10 @@ static struct tcf_hashinfo pedit_hash_info = {
 	.lock	=	&pedit_lock,
 };
 
-static int tcf_pedit_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 			  struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_PEDIT_MAX];
+	struct nlattr *tb[TCA_PEDIT_MAX + 1];
 	struct tc_pedit *parm;
 	int ret = 0;
 	struct tcf_pedit *p;
@@ -44,15 +44,15 @@ static int tcf_pedit_init(struct rtattr *rta, struct rtattr *est,
 	struct tc_pedit_key *keys = NULL;
 	int ksize;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_PEDIT_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_PEDIT_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_PEDIT_PARMS - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_PEDIT_PARMS-1]) < sizeof(*parm))
+	if (tb[TCA_PEDIT_PARMS] == NULL ||
+	    nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
-	parm = RTA_DATA(tb[TCA_PEDIT_PARMS-1]);
+	parm = nla_data(tb[TCA_PEDIT_PARMS]);
 	ksize = parm->nkeys * sizeof(struct tc_pedit_key);
-	if (RTA_PAYLOAD(tb[TCA_PEDIT_PARMS-1]) < sizeof(*parm) + ksize)
+	if (nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
 	pc = tcf_hash_check(parm->index, a, bind, &pedit_hash_info);
@@ -206,15 +206,15 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	opt->refcnt = p->tcf_refcnt - ref;
 	opt->bindcnt = p->tcf_bindcnt - bind;
 
-	RTA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
+	NLA_PUT(skb, TCA_PEDIT_PARMS, s, opt);
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
-	RTA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
+	NLA_PUT(skb, TCA_PEDIT_TM, sizeof(t), &t);
 	kfree(opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	kfree(opt);
 	return -1;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 07ffdf9..3af5759 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -54,7 +54,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 {
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
-	struct rtattr *r;
+	struct nlattr *r;
 
 	read_lock_bh(&police_lock);
 
@@ -69,8 +69,8 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 				continue;
 			a->priv = p;
 			a->order = index;
-			r = (struct rtattr *)skb_tail_pointer(skb);
-			RTA_PUT(skb, a->order, 0, NULL);
+			r = (struct nlattr *)skb_tail_pointer(skb);
+			NLA_PUT(skb, a->order, 0, NULL);
 			if (type == RTM_DELACTION)
 				err = tcf_action_dump_1(skb, a, 0, 1);
 			else
@@ -80,7 +80,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 				nlmsg_trim(skb, r);
 				goto done;
 			}
-			r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
+			r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
 			n_i++;
 		}
 	}
@@ -90,7 +90,7 @@ done:
 		cb->args[0] += n_i;
 	return n_i;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, r);
 	goto done;
 }
@@ -118,32 +118,32 @@ static void tcf_police_destroy(struct tcf_police *p)
 	BUG_TRAP(0);
 }
 
-static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
+static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 				 struct tc_action *a, int ovr, int bind)
 {
 	unsigned h;
 	int ret = 0, err;
-	struct rtattr *tb[TCA_POLICE_MAX];
+	struct nlattr *tb[TCA_POLICE_MAX + 1];
 	struct tc_police *parm;
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 	int size;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_POLICE_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_POLICE_TBF-1] == NULL)
+	if (tb[TCA_POLICE_TBF] == NULL)
 		return -EINVAL;
-	size = RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]);
+	size = nla_len(tb[TCA_POLICE_TBF]);
 	if (size != sizeof(*parm) && size != sizeof(struct tc_police_compat))
 		return -EINVAL;
-	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
+	parm = nla_data(tb[TCA_POLICE_TBF]);
 
-	if (tb[TCA_POLICE_RESULT-1] != NULL &&
-	    RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+	if (tb[TCA_POLICE_RESULT] != NULL &&
+	    nla_len(tb[TCA_POLICE_RESULT]) != sizeof(u32))
 		return -EINVAL;
-	if (tb[TCA_POLICE_RESULT-1] != NULL &&
-	    RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+	if (tb[TCA_POLICE_RESULT] != NULL &&
+	    nla_len(tb[TCA_POLICE_RESULT]) != sizeof(u32))
 		return -EINVAL;
 
 	if (parm->index) {
@@ -174,12 +174,12 @@ static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
 override:
 	if (parm->rate.rate) {
 		err = -ENOMEM;
-		R_tab = qdisc_get_rtab(&parm->rate, (struct nlattr *)tb[TCA_POLICE_RATE-1]);
+		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
 		if (R_tab == NULL)
 			goto failure;
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
-					       (struct nlattr *)tb[TCA_POLICE_PEAKRATE-1]);
+					       tb[TCA_POLICE_PEAKRATE]);
 			if (P_tab == NULL) {
 				qdisc_put_rtab(R_tab);
 				goto failure;
@@ -197,8 +197,8 @@ override:
 		police->tcfp_P_tab = P_tab;
 	}
 
-	if (tb[TCA_POLICE_RESULT-1])
-		police->tcfp_result = *(u32*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+	if (tb[TCA_POLICE_RESULT])
+		police->tcfp_result = *(u32*)nla_data(tb[TCA_POLICE_RESULT]);
 	police->tcfp_toks = police->tcfp_burst = parm->burst;
 	police->tcfp_mtu = parm->mtu;
 	if (police->tcfp_mtu == 0) {
@@ -210,13 +210,13 @@ override:
 		police->tcfp_ptoks = L2T_P(police, police->tcfp_mtu);
 	police->tcf_action = parm->action;
 
-	if (tb[TCA_POLICE_AVRATE-1])
+	if (tb[TCA_POLICE_AVRATE])
 		police->tcfp_ewma_rate =
-			*(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+			*(u32*)nla_data(tb[TCA_POLICE_AVRATE]);
 	if (est)
 		gen_replace_estimator(&police->tcf_bstats,
 				      &police->tcf_rate_est,
-				      &police->tcf_lock, (struct nlattr *)est);
+				      &police->tcf_lock, est);
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
@@ -332,15 +332,15 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 		opt.peakrate = police->tcfp_P_tab->rate;
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
-	RTA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
 	if (police->tcfp_result)
-		RTA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
+		NLA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
 			&police->tcfp_result);
 	if (police->tcfp_ewma_rate)
-		RTA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
+		NLA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index fb84ef3..d3226e2 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -84,10 +84,10 @@ static int realloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
 	return alloc_defdata(d, datalen, defdata);
 }
 
-static int tcf_simp_init(struct rtattr *rta, struct rtattr *est,
+static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			 struct tc_action *a, int ovr, int bind)
 {
-	struct rtattr *tb[TCA_DEF_MAX];
+	struct nlattr *tb[TCA_DEF_MAX + 1];
 	struct tc_defact *parm;
 	struct tcf_defact *d;
 	struct tcf_common *pc;
@@ -95,19 +95,19 @@ static int tcf_simp_init(struct rtattr *rta, struct rtattr *est,
 	u32 datalen = 0;
 	int ret = 0;
 
-	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
+	if (nla == NULL || nla_parse_nested(tb, TCA_DEF_MAX, nla, NULL) < 0)
 		return -EINVAL;
 
-	if (tb[TCA_DEF_PARMS - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_DEF_PARMS - 1]) < sizeof(*parm))
+	if (tb[TCA_DEF_PARMS] == NULL ||
+	    nla_len(tb[TCA_DEF_PARMS]) < sizeof(*parm))
 		return -EINVAL;
 
-	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
-	defdata = RTA_DATA(tb[TCA_DEF_DATA - 1]);
+	parm = nla_data(tb[TCA_DEF_PARMS]);
+	defdata = nla_data(tb[TCA_DEF_DATA]);
 	if (defdata == NULL)
 		return -EINVAL;
 
-	datalen = RTA_PAYLOAD(tb[TCA_DEF_DATA - 1]);
+	datalen = nla_len(tb[TCA_DEF_DATA]);
 	if (datalen <= 0)
 		return -EINVAL;
 
@@ -164,15 +164,15 @@ static inline int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	opt.refcnt = d->tcf_refcnt - ref;
 	opt.bindcnt = d->tcf_bindcnt - bind;
 	opt.action = d->tcf_action;
-	RTA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
-	RTA_PUT(skb, TCA_DEF_DATA, d->tcfd_datalen, d->tcfd_defdata);
+	NLA_PUT(skb, TCA_DEF_PARMS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_DEF_DATA, d->tcfd_datalen, d->tcfd_defdata);
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-	RTA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
+	NLA_PUT(skb, TCA_DEF_TM, sizeof(t), &t);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 87be2b2..d870478 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -491,8 +491,7 @@ int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 		struct tc_action *act;
 
 		if (map->police && tb[map->police]) {
-			act = tcf_action_init_1((struct rtattr *)tb[map->police],
-						(struct rtattr *)rate_tlv,
+			act = tcf_action_init_1(tb[map->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
 						TCA_ACT_BIND, &err);
 			if (act == NULL)
@@ -501,8 +500,7 @@ int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 			act->type = TCA_OLD_COMPAT;
 			exts->action = act;
 		} else if (map->action && tb[map->action]) {
-			act = tcf_action_init((struct rtattr *)tb[map->action],
-					      (struct rtattr *)rate_tlv, NULL,
+			act = tcf_action_init(tb[map->action], rate_tlv, NULL,
 				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 			if (act == NULL)
 				return err;
