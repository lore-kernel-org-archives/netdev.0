From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/06]: Convert classifiers from rtnetlink to new netlink API
Date: Tue, 22 Jan 2008 15:56:15 +0100 (MET)
Message-ID: <20080122145549.6862.82986.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50751 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbYAVO4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:17 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Convert classifiers from rtnetlink to new netlink API

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7798bc7f67ba5ffcfc542f5c88762b6db705992e
tree 4a6d67ac7a5f1c667ed025a56264ecb35486118e
parent 07a5a2c72eb790323d3e11bb2e1131f8fd43ae1d
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:41 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:41 +0100

 include/net/pkt_cls.h     |   10 +++---
 include/net/sch_generic.h |    2 +
 net/sched/cls_api.c       |   65 ++++++++++++++++++++------------------
 net/sched/cls_basic.c     |   40 ++++++++++++-----------
 net/sched/cls_fw.c        |   54 ++++++++++++++++---------------
 net/sched/cls_route.c     |   70 ++++++++++++++++++++--------------------
 net/sched/cls_rsvp.h      |   48 ++++++++++++++--------------
 net/sched/cls_tcindex.c   |   66 +++++++++++++++++++-------------------
 net/sched/cls_u32.c       |   78 +++++++++++++++++++++++----------------------
 net/sched/em_meta.c       |   56 ++++++++++++++++----------------
 net/sched/em_text.c       |    9 +++--
 net/sched/ematch.c        |   74 +++++++++++++++++++++----------------------
 12 files changed, 290 insertions(+), 282 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2eaf204..8716eb7 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -129,8 +129,8 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
-extern int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
-	                     struct rtattr *rate_tlv, struct tcf_exts *exts,
+extern int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
+	                     struct nlattr *rate_tlv, struct tcf_exts *exts,
 	                     struct tcf_ext_map *map);
 extern void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
 extern void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
@@ -247,7 +247,7 @@ struct tcf_ematch_ops
 
 extern int tcf_em_register(struct tcf_ematch_ops *);
 extern int tcf_em_unregister(struct tcf_ematch_ops *);
-extern int tcf_em_tree_validate(struct tcf_proto *, struct rtattr *,
+extern int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
 				struct tcf_ematch_tree *);
 extern void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
 extern int tcf_em_tree_dump(struct sk_buff *, struct tcf_ematch_tree *, int);
@@ -338,9 +338,9 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 #include <net/net_namespace.h>
 
 static inline int
-tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
+tcf_change_indev(struct tcf_proto *tp, char *indev, struct nlattr *indev_tlv)
 {
-	if (rtattr_strlcpy(indev, indev_tlv, IFNAMSIZ) >= IFNAMSIZ)
+	if (nla_strlcpy(indev, indev_tlv, IFNAMSIZ) >= IFNAMSIZ)
 		return -EINVAL;
 	return 0;
 }
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 8cacdff..ab502ec 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -126,7 +126,7 @@ struct tcf_proto_ops
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
 	void			(*put)(struct tcf_proto*, unsigned long);
 	int			(*change)(struct tcf_proto*, unsigned long,
-					u32 handle, struct rtattr **,
+					u32 handle, struct nlattr **,
 					unsigned long *);
 	int			(*delete)(struct tcf_proto*, unsigned long);
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9eeb3c6..87be2b2 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -38,14 +38,14 @@ static DEFINE_RWLOCK(cls_mod_lock);
 
 /* Find classifier type by string name */
 
-static struct tcf_proto_ops *tcf_proto_lookup_ops(struct rtattr *kind)
+static struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 {
 	struct tcf_proto_ops *t = NULL;
 
 	if (kind) {
 		read_lock(&cls_mod_lock);
 		for (t = tcf_proto_base; t; t = t->next) {
-			if (rtattr_strcmp(kind, t->kind) == 0) {
+			if (nla_strcmp(kind, t->kind) == 0) {
 				if (!try_module_get(t->owner))
 					t = NULL;
 				break;
@@ -118,7 +118,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = skb->sk->sk_net;
-	struct rtattr **tca;
+	struct nlattr *tca[TCA_MAX + 1];
 	struct tcmsg *t;
 	u32 protocol;
 	u32 prio;
@@ -138,7 +138,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		return -EINVAL;
 
 replay:
-	tca = arg;
 	t = NLMSG_DATA(n);
 	protocol = TC_H_MIN(t->tcm_info);
 	prio = TC_H_MAJ(t->tcm_info);
@@ -160,6 +159,10 @@ replay:
 	if (dev == NULL)
 		return -ENODEV;
 
+	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	/* Find qdisc */
 	if (!parent) {
 		q = dev->qdisc_sleeping;
@@ -202,7 +205,7 @@ replay:
 	if (tp == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
-		if (tca[TCA_KIND-1] == NULL || !protocol)
+		if (tca[TCA_KIND] == NULL || !protocol)
 			goto errout;
 
 		err = -ENOENT;
@@ -217,14 +220,14 @@ replay:
 		if (tp == NULL)
 			goto errout;
 		err = -EINVAL;
-		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND-1]);
+		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
 #ifdef CONFIG_KMOD
-			struct rtattr *kind = tca[TCA_KIND-1];
+			struct nlattr *kind = tca[TCA_KIND];
 			char name[IFNAMSIZ];
 
 			if (kind != NULL &&
-			    rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+			    nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
 				rtnl_unlock();
 				request_module("cls_%s", name);
 				rtnl_lock();
@@ -263,7 +266,7 @@ replay:
 		*back = tp;
 		qdisc_unlock_tree(dev);
 
-	} else if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], tp->ops->kind))
+	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
 
 	fh = tp->ops->get(tp, t->tcm_handle);
@@ -333,18 +336,18 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm_ifindex = tp->q->dev->ifindex;
 	tcm->tcm_parent = tp->classid;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, tp->ops->kind);
+	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, tp->ops->kind);
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
 		if (tp->ops->dump && tp->ops->dump(tp, fh, skb, tcm) < 0)
-			goto rtattr_failure;
+			goto nla_put_failure;
 	}
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
 nlmsg_failure:
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -476,8 +479,8 @@ void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
 
-int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
-		  struct rtattr *rate_tlv, struct tcf_exts *exts,
+int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
+		  struct nlattr *rate_tlv, struct tcf_exts *exts,
 		  struct tcf_ext_map *map)
 {
 	memset(exts, 0, sizeof(*exts));
@@ -487,8 +490,9 @@ int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
 		int err;
 		struct tc_action *act;
 
-		if (map->police && tb[map->police-1]) {
-			act = tcf_action_init_1(tb[map->police-1], rate_tlv,
+		if (map->police && tb[map->police]) {
+			act = tcf_action_init_1((struct rtattr *)tb[map->police],
+						(struct rtattr *)rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
 						TCA_ACT_BIND, &err);
 			if (act == NULL)
@@ -496,8 +500,9 @@ int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
 
 			act->type = TCA_OLD_COMPAT;
 			exts->action = act;
-		} else if (map->action && tb[map->action-1]) {
-			act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
+		} else if (map->action && tb[map->action]) {
+			act = tcf_action_init((struct rtattr *)tb[map->action],
+					      (struct rtattr *)rate_tlv, NULL,
 				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
 			if (act == NULL)
 				return err;
@@ -506,8 +511,8 @@ int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
 		}
 	}
 #else
-	if ((map->action && tb[map->action-1]) ||
-	    (map->police && tb[map->police-1]))
+	if ((map->action && tb[map->action]) ||
+	    (map->police && tb[map->police]))
 		return -EOPNOTSUPP;
 #endif
 
@@ -541,23 +546,23 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
-		struct rtattr *p_rta = (struct rtattr *)skb_tail_pointer(skb);
+		struct nlattr *p_rta = (struct nlattr *)skb_tail_pointer(skb);
 
 		if (exts->action->type != TCA_OLD_COMPAT) {
-			RTA_PUT(skb, map->action, 0, NULL);
+			NLA_PUT(skb, map->action, 0, NULL);
 			if (tcf_action_dump(skb, exts->action, 0, 0) < 0)
-				goto rtattr_failure;
-			p_rta->rta_len = skb_tail_pointer(skb) - (u8 *)p_rta;
+				goto nla_put_failure;
+			p_rta->nla_len = skb_tail_pointer(skb) - (u8 *)p_rta;
 		} else if (map->police) {
-			RTA_PUT(skb, map->police, 0, NULL);
+			NLA_PUT(skb, map->police, 0, NULL);
 			if (tcf_action_dump_old(skb, exts->action, 0, 0) < 0)
-				goto rtattr_failure;
-			p_rta->rta_len = skb_tail_pointer(skb) - (u8 *)p_rta;
+				goto nla_put_failure;
+			p_rta->nla_len = skb_tail_pointer(skb) - (u8 *)p_rta;
 		}
 	}
 #endif
 	return 0;
-rtattr_failure: __attribute__ ((unused))
+nla_put_failure: __attribute__ ((unused))
 	return -1;
 }
 EXPORT_SYMBOL(tcf_exts_dump);
@@ -569,10 +574,10 @@ int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action)
 		if (tcf_action_copy_stats(skb, exts->action, 1) < 0)
-			goto rtattr_failure;
+			goto nla_put_failure;
 #endif
 	return 0;
-rtattr_failure: __attribute__ ((unused))
+nla_put_failure: __attribute__ ((unused))
 	return -1;
 }
 EXPORT_SYMBOL(tcf_exts_dump_stats);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index b31f9f9..3953da3 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -130,27 +130,27 @@ static int basic_delete(struct tcf_proto *tp, unsigned long arg)
 }
 
 static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
-				  unsigned long base, struct rtattr **tb,
-				  struct rtattr *est)
+				  unsigned long base, struct nlattr **tb,
+				  struct nlattr *est)
 {
 	int err = -EINVAL;
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
-	if (tb[TCA_BASIC_CLASSID-1])
-		if (RTA_PAYLOAD(tb[TCA_BASIC_CLASSID-1]) < sizeof(u32))
+	if (tb[TCA_BASIC_CLASSID])
+		if (nla_len(tb[TCA_BASIC_CLASSID]) < sizeof(u32))
 			return err;
 
 	err = tcf_exts_validate(tp, tb, est, &e, &basic_ext_map);
 	if (err < 0)
 		return err;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES-1], &t);
+	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &t);
 	if (err < 0)
 		goto errout;
 
-	if (tb[TCA_BASIC_CLASSID-1]) {
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_BASIC_CLASSID-1]);
+	if (tb[TCA_BASIC_CLASSID]) {
+		f->res.classid = *(u32*)nla_data(tb[TCA_BASIC_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
@@ -164,23 +164,23 @@ errout:
 }
 
 static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-			struct rtattr **tca, unsigned long *arg)
+			struct nlattr **tca, unsigned long *arg)
 {
 	int err = -EINVAL;
 	struct basic_head *head = (struct basic_head *) tp->root;
-	struct rtattr *tb[TCA_BASIC_MAX];
+	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *f = (struct basic_filter *) *arg;
 
-	if (tca[TCA_OPTIONS-1] == NULL)
+	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
 
-	if (rtattr_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS-1]) < 0)
+	if (nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS], NULL) < 0)
 		return -EINVAL;
 
 	if (f != NULL) {
 		if (handle && f->handle != handle)
 			return -EINVAL;
-		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE-1]);
+		return basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
 	}
 
 	err = -ENOBUFS;
@@ -206,7 +206,7 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		f->handle = head->hgenerator;
 	}
 
-	err = basic_set_parms(tp, f, base, tb, tca[TCA_RATE-1]);
+	err = basic_set_parms(tp, f, base, tb, tca[TCA_RATE]);
 	if (err < 0)
 		goto errout;
 
@@ -246,27 +246,27 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 {
 	struct basic_filter *f = (struct basic_filter *) fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	if (f == NULL)
 		return skb->len;
 
 	t->tcm_handle = f->handle;
 
-	rta = (struct rtattr *) b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr *) b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	if (f->res.classid)
-		RTA_PUT(skb, TCA_BASIC_CLASSID, sizeof(u32), &f->res.classid);
+		NLA_PUT(skb, TCA_BASIC_CLASSID, sizeof(u32), &f->res.classid);
 
 	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index b450387..db6e90a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -188,37 +188,37 @@ out:
 
 static int
 fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
-	struct rtattr **tb, struct rtattr **tca, unsigned long base)
+	struct nlattr **tb, struct nlattr **tca, unsigned long base)
 {
 	struct fw_head *head = (struct fw_head *)tp->root;
 	struct tcf_exts e;
 	u32 mask;
 	int err;
 
-	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &fw_ext_map);
+	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &fw_ext_map);
 	if (err < 0)
 		return err;
 
 	err = -EINVAL;
-	if (tb[TCA_FW_CLASSID-1]) {
-		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != sizeof(u32))
+	if (tb[TCA_FW_CLASSID]) {
+		if (nla_len(tb[TCA_FW_CLASSID]) != sizeof(u32))
 			goto errout;
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_FW_CLASSID-1]);
+		f->res.classid = *(u32*)nla_data(tb[TCA_FW_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
 #ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_FW_INDEV-1]) {
-		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
+	if (tb[TCA_FW_INDEV]) {
+		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV]);
 		if (err < 0)
 			goto errout;
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
-	if (tb[TCA_FW_MASK-1]) {
-		if (RTA_PAYLOAD(tb[TCA_FW_MASK-1]) != sizeof(u32))
+	if (tb[TCA_FW_MASK]) {
+		if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
 			goto errout;
-		mask = *(u32*)RTA_DATA(tb[TCA_FW_MASK-1]);
+		mask = *(u32*)nla_data(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
 			goto errout;
 	} else if (head->mask != 0xFFFFFFFF)
@@ -234,19 +234,19 @@ errout:
 
 static int fw_change(struct tcf_proto *tp, unsigned long base,
 		     u32 handle,
-		     struct rtattr **tca,
+		     struct nlattr **tca,
 		     unsigned long *arg)
 {
 	struct fw_head *head = (struct fw_head*)tp->root;
 	struct fw_filter *f = (struct fw_filter *) *arg;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_FW_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_FW_MAX + 1];
 	int err;
 
 	if (!opt)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse_nested(tb, TCA_FW_MAX, opt) < 0)
+	if (nla_parse_nested(tb, TCA_FW_MAX, opt, NULL) < 0)
 		return -EINVAL;
 
 	if (f != NULL) {
@@ -260,10 +260,10 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 
 	if (head == NULL) {
 		u32 mask = 0xFFFFFFFF;
-		if (tb[TCA_FW_MASK-1]) {
-			if (RTA_PAYLOAD(tb[TCA_FW_MASK-1]) != sizeof(u32))
+		if (tb[TCA_FW_MASK]) {
+			if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
 				return -EINVAL;
-			mask = *(u32*)RTA_DATA(tb[TCA_FW_MASK-1]);
+			mask = *(u32*)nla_data(tb[TCA_FW_MASK]);
 		}
 
 		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
@@ -333,7 +333,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f = (struct fw_filter*)fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	if (f == NULL)
 		return skb->len;
@@ -343,29 +343,29 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	if (!f->res.classid && !tcf_exts_is_available(&f->exts))
 		return skb->len;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	if (f->res.classid)
-		RTA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
+		NLA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
 #ifdef CONFIG_NET_CLS_IND
 	if (strlen(f->indev))
-		RTA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
+		NLA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
 	if (head->mask != 0xFFFFFFFF)
-		RTA_PUT(skb, TCA_FW_MASK, 4, &head->mask);
+		NLA_PUT(skb, TCA_FW_MASK, 4, &head->mask);
 
 	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index e70edd0..b1aae84 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -325,7 +325,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 
 static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	struct route4_filter *f, u32 handle, struct route4_head *head,
-	struct rtattr **tb, struct rtattr *est, int new)
+	struct nlattr **tb, struct nlattr *est, int new)
 {
 	int err;
 	u32 id = 0, to = 0, nhandle = 0x8000;
@@ -339,34 +339,34 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 		return err;
 
 	err = -EINVAL;
-	if (tb[TCA_ROUTE4_CLASSID-1])
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_CLASSID-1]) < sizeof(u32))
+	if (tb[TCA_ROUTE4_CLASSID])
+		if (nla_len(tb[TCA_ROUTE4_CLASSID]) < sizeof(u32))
 			goto errout;
 
-	if (tb[TCA_ROUTE4_TO-1]) {
+	if (tb[TCA_ROUTE4_TO]) {
 		if (new && handle & 0x8000)
 			goto errout;
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_TO-1]) < sizeof(u32))
+		if (nla_len(tb[TCA_ROUTE4_TO]) < sizeof(u32))
 			goto errout;
-		to = *(u32*)RTA_DATA(tb[TCA_ROUTE4_TO-1]);
+		to = *(u32*)nla_data(tb[TCA_ROUTE4_TO]);
 		if (to > 0xFF)
 			goto errout;
 		nhandle = to;
 	}
 
-	if (tb[TCA_ROUTE4_FROM-1]) {
-		if (tb[TCA_ROUTE4_IIF-1])
+	if (tb[TCA_ROUTE4_FROM]) {
+		if (tb[TCA_ROUTE4_IIF])
 			goto errout;
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_FROM-1]) < sizeof(u32))
+		if (nla_len(tb[TCA_ROUTE4_FROM]) < sizeof(u32))
 			goto errout;
-		id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_FROM-1]);
+		id = *(u32*)nla_data(tb[TCA_ROUTE4_FROM]);
 		if (id > 0xFF)
 			goto errout;
 		nhandle |= id << 16;
-	} else if (tb[TCA_ROUTE4_IIF-1]) {
-		if (RTA_PAYLOAD(tb[TCA_ROUTE4_IIF-1]) < sizeof(u32))
+	} else if (tb[TCA_ROUTE4_IIF]) {
+		if (nla_len(tb[TCA_ROUTE4_IIF]) < sizeof(u32))
 			goto errout;
-		id = *(u32*)RTA_DATA(tb[TCA_ROUTE4_IIF-1]);
+		id = *(u32*)nla_data(tb[TCA_ROUTE4_IIF]);
 		if (id > 0x7FFF)
 			goto errout;
 		nhandle |= (id | 0x8000) << 16;
@@ -398,20 +398,20 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	}
 
 	tcf_tree_lock(tp);
-	if (tb[TCA_ROUTE4_TO-1])
+	if (tb[TCA_ROUTE4_TO])
 		f->id = to;
 
-	if (tb[TCA_ROUTE4_FROM-1])
+	if (tb[TCA_ROUTE4_FROM])
 		f->id = to | id<<16;
-	else if (tb[TCA_ROUTE4_IIF-1])
+	else if (tb[TCA_ROUTE4_IIF])
 		f->iif = id;
 
 	f->handle = nhandle;
 	f->bkt = b;
 	tcf_tree_unlock(tp);
 
-	if (tb[TCA_ROUTE4_CLASSID-1]) {
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_ROUTE4_CLASSID-1]);
+	if (tb[TCA_ROUTE4_CLASSID]) {
+		f->res.classid = *(u32*)nla_data(tb[TCA_ROUTE4_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
@@ -425,14 +425,14 @@ errout:
 
 static int route4_change(struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
-		       struct rtattr **tca,
+		       struct nlattr **tca,
 		       unsigned long *arg)
 {
 	struct route4_head *head = tp->root;
 	struct route4_filter *f, *f1, **fp;
 	struct route4_bucket *b;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_ROUTE4_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_ROUTE4_MAX + 1];
 	unsigned int h, th;
 	u32 old_handle = 0;
 	int err;
@@ -440,7 +440,7 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse_nested(tb, TCA_ROUTE4_MAX, opt) < 0)
+	if (nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, NULL) < 0)
 		return -EINVAL;
 
 	if ((f = (struct route4_filter*)*arg) != NULL) {
@@ -451,7 +451,7 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 			old_handle = f->handle;
 
 		err = route4_set_parms(tp, base, f, handle, head, tb,
-			tca[TCA_RATE-1], 0);
+			tca[TCA_RATE], 0);
 		if (err < 0)
 			return err;
 
@@ -474,7 +474,7 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 		goto errout;
 
 	err = route4_set_parms(tp, base, f, handle, head, tb,
-		tca[TCA_RATE-1], 1);
+		tca[TCA_RATE], 1);
 	if (err < 0)
 		goto errout;
 
@@ -550,7 +550,7 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 {
 	struct route4_filter *f = (struct route4_filter*)fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 	u32 id;
 
 	if (f == NULL)
@@ -558,34 +558,34 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 
 	t->tcm_handle = f->handle;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	if (!(f->handle&0x8000)) {
 		id = f->id&0xFF;
-		RTA_PUT(skb, TCA_ROUTE4_TO, sizeof(id), &id);
+		NLA_PUT(skb, TCA_ROUTE4_TO, sizeof(id), &id);
 	}
 	if (f->handle&0x80000000) {
 		if ((f->handle>>16) != 0xFFFF)
-			RTA_PUT(skb, TCA_ROUTE4_IIF, sizeof(f->iif), &f->iif);
+			NLA_PUT(skb, TCA_ROUTE4_IIF, sizeof(f->iif), &f->iif);
 	} else {
 		id = f->id>>16;
-		RTA_PUT(skb, TCA_ROUTE4_FROM, sizeof(id), &id);
+		NLA_PUT(skb, TCA_ROUTE4_FROM, sizeof(id), &id);
 	}
 	if (f->res.classid)
-		RTA_PUT(skb, TCA_ROUTE4_CLASSID, 4, &f->res.classid);
+		NLA_PUT(skb, TCA_ROUTE4_CLASSID, 4, &f->res.classid);
 
 	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 22f9ede..2364c79 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -399,15 +399,15 @@ static u32 gen_tunnel(struct rsvp_head *data)
 
 static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
-		       struct rtattr **tca,
+		       struct nlattr **tca,
 		       unsigned long *arg)
 {
 	struct rsvp_head *data = tp->root;
 	struct rsvp_filter *f, **fp;
 	struct rsvp_session *s, **sp;
 	struct tc_rsvp_pinfo *pinfo = NULL;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_RSVP_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS-1];
+	struct nlattr *tb[TCA_RSVP_MAX + 1];
 	struct tcf_exts e;
 	unsigned h1, h2;
 	__be32 *dst;
@@ -416,7 +416,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse_nested(tb, TCA_RSVP_MAX, opt) < 0)
+	if (nla_parse_nested(tb, TCA_RSVP_MAX, opt, NULL) < 0)
 		return -EINVAL;
 
 	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &rsvp_ext_map);
@@ -429,7 +429,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		if (f->handle != handle && handle)
 			goto errout2;
 		if (tb[TCA_RSVP_CLASSID-1]) {
-			f->res.classid = *(u32*)RTA_DATA(tb[TCA_RSVP_CLASSID-1]);
+			f->res.classid = *(u32*)nla_data(tb[TCA_RSVP_CLASSID-1]);
 			tcf_bind_filter(tp, &f->res, base);
 		}
 
@@ -452,30 +452,30 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC-1]) {
 		err = -EINVAL;
-		if (RTA_PAYLOAD(tb[TCA_RSVP_SRC-1]) != sizeof(f->src))
+		if (nla_len(tb[TCA_RSVP_SRC-1]) != sizeof(f->src))
 			goto errout;
-		memcpy(f->src, RTA_DATA(tb[TCA_RSVP_SRC-1]), sizeof(f->src));
+		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC-1]), sizeof(f->src));
 		h2 = hash_src(f->src);
 	}
 	if (tb[TCA_RSVP_PINFO-1]) {
 		err = -EINVAL;
-		if (RTA_PAYLOAD(tb[TCA_RSVP_PINFO-1]) < sizeof(struct tc_rsvp_pinfo))
+		if (nla_len(tb[TCA_RSVP_PINFO-1]) < sizeof(struct tc_rsvp_pinfo))
 			goto errout;
-		pinfo = RTA_DATA(tb[TCA_RSVP_PINFO-1]);
+		pinfo = nla_data(tb[TCA_RSVP_PINFO-1]);
 		f->spi = pinfo->spi;
 		f->tunnelhdr = pinfo->tunnelhdr;
 	}
 	if (tb[TCA_RSVP_CLASSID-1]) {
 		err = -EINVAL;
-		if (RTA_PAYLOAD(tb[TCA_RSVP_CLASSID-1]) != 4)
+		if (nla_len(tb[TCA_RSVP_CLASSID-1]) != 4)
 			goto errout;
-		f->res.classid = *(u32*)RTA_DATA(tb[TCA_RSVP_CLASSID-1]);
+		f->res.classid = *(u32*)nla_data(tb[TCA_RSVP_CLASSID-1]);
 	}
 
 	err = -EINVAL;
-	if (RTA_PAYLOAD(tb[TCA_RSVP_DST-1]) != sizeof(f->src))
+	if (nla_len(tb[TCA_RSVP_DST-1]) != sizeof(f->src))
 		goto errout;
-	dst = RTA_DATA(tb[TCA_RSVP_DST-1]);
+	dst = nla_data(tb[TCA_RSVP_DST-1]);
 	h1 = hash_dst(dst, pinfo ? pinfo->protocol : 0, pinfo ? pinfo->tunnelid : 0);
 
 	err = -ENOMEM;
@@ -594,7 +594,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	struct rsvp_filter *f = (struct rsvp_filter*)fh;
 	struct rsvp_session *s;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 	struct tc_rsvp_pinfo pinfo;
 
 	if (f == NULL)
@@ -604,32 +604,32 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	t->tcm_handle = f->handle;
 
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
-	RTA_PUT(skb, TCA_RSVP_DST, sizeof(s->dst), &s->dst);
+	NLA_PUT(skb, TCA_RSVP_DST, sizeof(s->dst), &s->dst);
 	pinfo.dpi = s->dpi;
 	pinfo.spi = f->spi;
 	pinfo.protocol = s->protocol;
 	pinfo.tunnelid = s->tunnelid;
 	pinfo.tunnelhdr = f->tunnelhdr;
 	pinfo.pad = 0;
-	RTA_PUT(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo);
+	NLA_PUT(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo);
 	if (f->res.classid)
-		RTA_PUT(skb, TCA_RSVP_CLASSID, 4, &f->res.classid);
+		NLA_PUT(skb, TCA_RSVP_CLASSID, 4, &f->res.classid);
 	if (((f->handle>>8)&0xFF) != 16)
-		RTA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
+		NLA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
 
 	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &rsvp_ext_map) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index e36977b..ed80239 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -196,7 +196,7 @@ valid_perfect_hash(struct tcindex_data *p)
 static int
 tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		  struct tcindex_data *p, struct tcindex_filter_result *r,
-		  struct rtattr **tb, struct rtattr *est)
+		  struct nlattr **tb, struct nlattr *est)
 {
 	int err, balloc = 0;
 	struct tcindex_filter_result new_filter_result, *old_r = r;
@@ -218,22 +218,22 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		memset(&cr, 0, sizeof(cr));
 
 	err = -EINVAL;
-	if (tb[TCA_TCINDEX_HASH-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_HASH-1]) < sizeof(u32))
+	if (tb[TCA_TCINDEX_HASH]) {
+		if (nla_len(tb[TCA_TCINDEX_HASH]) < sizeof(u32))
 			goto errout;
-		cp.hash = *(u32 *) RTA_DATA(tb[TCA_TCINDEX_HASH-1]);
+		cp.hash = *(u32 *) nla_data(tb[TCA_TCINDEX_HASH]);
 	}
 
-	if (tb[TCA_TCINDEX_MASK-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_MASK-1]) < sizeof(u16))
+	if (tb[TCA_TCINDEX_MASK]) {
+		if (nla_len(tb[TCA_TCINDEX_MASK]) < sizeof(u16))
 			goto errout;
-		cp.mask = *(u16 *) RTA_DATA(tb[TCA_TCINDEX_MASK-1]);
+		cp.mask = *(u16 *) nla_data(tb[TCA_TCINDEX_MASK]);
 	}
 
-	if (tb[TCA_TCINDEX_SHIFT-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_SHIFT-1]) < sizeof(int))
+	if (tb[TCA_TCINDEX_SHIFT]) {
+		if (nla_len(tb[TCA_TCINDEX_SHIFT]) < sizeof(int))
 			goto errout;
-		cp.shift = *(int *) RTA_DATA(tb[TCA_TCINDEX_SHIFT-1]);
+		cp.shift = *(int *) nla_data(tb[TCA_TCINDEX_SHIFT]);
 	}
 
 	err = -EBUSY;
@@ -248,11 +248,11 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		goto errout;
 
 	err = -EINVAL;
-	if (tb[TCA_TCINDEX_FALL_THROUGH-1]) {
-		if (RTA_PAYLOAD(tb[TCA_TCINDEX_FALL_THROUGH-1]) < sizeof(u32))
+	if (tb[TCA_TCINDEX_FALL_THROUGH]) {
+		if (nla_len(tb[TCA_TCINDEX_FALL_THROUGH]) < sizeof(u32))
 			goto errout;
 		cp.fall_through =
-			*(u32 *) RTA_DATA(tb[TCA_TCINDEX_FALL_THROUGH-1]);
+			*(u32 *) nla_data(tb[TCA_TCINDEX_FALL_THROUGH]);
 	}
 
 	if (!cp.hash) {
@@ -304,8 +304,8 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 			goto errout_alloc;
 	}
 
-	if (tb[TCA_TCINDEX_CLASSID-1]) {
-		cr.res.classid = *(u32 *) RTA_DATA(tb[TCA_TCINDEX_CLASSID-1]);
+	if (tb[TCA_TCINDEX_CLASSID]) {
+		cr.res.classid = *(u32 *) nla_data(tb[TCA_TCINDEX_CLASSID]);
 		tcf_bind_filter(tp, &cr.res, base);
 	}
 
@@ -344,10 +344,10 @@ errout:
 
 static int
 tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-	       struct rtattr **tca, unsigned long *arg)
+	       struct nlattr **tca, unsigned long *arg)
 {
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_TCINDEX_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
 
@@ -358,10 +358,10 @@ tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (!opt)
 		return 0;
 
-	if (rtattr_parse_nested(tb, TCA_TCINDEX_MAX, opt) < 0)
+	if (nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, NULL) < 0)
 		return -EINVAL;
 
-	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE-1]);
+	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE]);
 }
 
 
@@ -435,21 +435,21 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	pr_debug("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p,b %p\n",
 		 tp, fh, skb, t, p, r, b);
 	pr_debug("p->perfect %p p->h %p\n", p->perfect, p->h);
-	rta = (struct rtattr *) b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr *) b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if (!fh) {
 		t->tcm_handle = ~0; /* whatever ... */
-		RTA_PUT(skb, TCA_TCINDEX_HASH, sizeof(p->hash), &p->hash);
-		RTA_PUT(skb, TCA_TCINDEX_MASK, sizeof(p->mask), &p->mask);
-		RTA_PUT(skb, TCA_TCINDEX_SHIFT, sizeof(p->shift), &p->shift);
-		RTA_PUT(skb, TCA_TCINDEX_FALL_THROUGH, sizeof(p->fall_through),
+		NLA_PUT(skb, TCA_TCINDEX_HASH, sizeof(p->hash), &p->hash);
+		NLA_PUT(skb, TCA_TCINDEX_MASK, sizeof(p->mask), &p->mask);
+		NLA_PUT(skb, TCA_TCINDEX_SHIFT, sizeof(p->shift), &p->shift);
+		NLA_PUT(skb, TCA_TCINDEX_FALL_THROUGH, sizeof(p->fall_through),
 		    &p->fall_through);
-		rta->rta_len = skb_tail_pointer(skb) - b;
+		nla->nla_len = skb_tail_pointer(skb) - b;
 	} else {
 		if (p->perfect) {
 			t->tcm_handle = r-p->perfect;
@@ -468,19 +468,19 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 		}
 		pr_debug("handle = %d\n", t->tcm_handle);
 		if (r->res.class)
-			RTA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
+			NLA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
 
 		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
-			goto rtattr_failure;
-		rta->rta_len = skb_tail_pointer(skb) - b;
+			goto nla_put_failure;
+		nla->nla_len = skb_tail_pointer(skb) - b;
 
 		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
-			goto rtattr_failure;
+			goto nla_put_failure;
 	}
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 7bf3cd4..aaf5049 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -462,8 +462,8 @@ static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 
 static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 			 struct tc_u_hnode *ht,
-			 struct tc_u_knode *n, struct rtattr **tb,
-			 struct rtattr *est)
+			 struct tc_u_knode *n, struct nlattr **tb,
+			 struct nlattr *est)
 {
 	int err;
 	struct tcf_exts e;
@@ -473,8 +473,8 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 		return err;
 
 	err = -EINVAL;
-	if (tb[TCA_U32_LINK-1]) {
-		u32 handle = *(u32*)RTA_DATA(tb[TCA_U32_LINK-1]);
+	if (tb[TCA_U32_LINK]) {
+		u32 handle = *(u32*)nla_data(tb[TCA_U32_LINK]);
 		struct tc_u_hnode *ht_down = NULL;
 
 		if (TC_U32_KEY(handle))
@@ -495,14 +495,14 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 		if (ht_down)
 			ht_down->refcnt--;
 	}
-	if (tb[TCA_U32_CLASSID-1]) {
-		n->res.classid = *(u32*)RTA_DATA(tb[TCA_U32_CLASSID-1]);
+	if (tb[TCA_U32_CLASSID]) {
+		n->res.classid = *(u32*)nla_data(tb[TCA_U32_CLASSID]);
 		tcf_bind_filter(tp, &n->res, base);
 	}
 
 #ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_U32_INDEV-1]) {
-		err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
+	if (tb[TCA_U32_INDEV]) {
+		err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV]);
 		if (err < 0)
 			goto errout;
 	}
@@ -516,33 +516,33 @@ errout:
 }
 
 static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
-		      struct rtattr **tca,
+		      struct nlattr **tca,
 		      unsigned long *arg)
 {
 	struct tc_u_common *tp_c = tp->data;
 	struct tc_u_hnode *ht;
 	struct tc_u_knode *n;
 	struct tc_u32_sel *s;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_U32_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_U32_MAX + 1];
 	u32 htid;
 	int err;
 
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (rtattr_parse_nested(tb, TCA_U32_MAX, opt) < 0)
+	if (nla_parse_nested(tb, TCA_U32_MAX, opt, NULL) < 0)
 		return -EINVAL;
 
 	if ((n = (struct tc_u_knode*)*arg) != NULL) {
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
-		return u32_set_parms(tp, base, n->ht_up, n, tb, tca[TCA_RATE-1]);
+		return u32_set_parms(tp, base, n->ht_up, n, tb, tca[TCA_RATE]);
 	}
 
-	if (tb[TCA_U32_DIVISOR-1]) {
-		unsigned divisor = *(unsigned*)RTA_DATA(tb[TCA_U32_DIVISOR-1]);
+	if (tb[TCA_U32_DIVISOR]) {
+		unsigned divisor = *(unsigned*)nla_data(tb[TCA_U32_DIVISOR]);
 
 		if (--divisor > 0x100)
 			return -EINVAL;
@@ -567,8 +567,8 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		return 0;
 	}
 
-	if (tb[TCA_U32_HASH-1]) {
-		htid = *(unsigned*)RTA_DATA(tb[TCA_U32_HASH-1]);
+	if (tb[TCA_U32_HASH]) {
+		htid = *(unsigned*)nla_data(tb[TCA_U32_HASH]);
 		if (TC_U32_HTID(htid) == TC_U32_ROOT) {
 			ht = tp->root;
 			htid = ht->handle;
@@ -592,11 +592,11 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	} else
 		handle = gen_new_kid(ht, htid);
 
-	if (tb[TCA_U32_SEL-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_U32_SEL-1]) < sizeof(struct tc_u32_sel))
+	if (tb[TCA_U32_SEL] == NULL ||
+	    nla_len(tb[TCA_U32_SEL]) < sizeof(struct tc_u32_sel))
 		return -EINVAL;
 
-	s = RTA_DATA(tb[TCA_U32_SEL-1]);
+	s = nla_data(tb[TCA_U32_SEL]);
 
 	n = kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL);
 	if (n == NULL)
@@ -616,23 +616,23 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 
 #ifdef CONFIG_CLS_U32_MARK
-	if (tb[TCA_U32_MARK-1]) {
+	if (tb[TCA_U32_MARK]) {
 		struct tc_u32_mark *mark;
 
-		if (RTA_PAYLOAD(tb[TCA_U32_MARK-1]) < sizeof(struct tc_u32_mark)) {
+		if (nla_len(tb[TCA_U32_MARK]) < sizeof(struct tc_u32_mark)) {
 #ifdef CONFIG_CLS_U32_PERF
 			kfree(n->pf);
 #endif
 			kfree(n);
 			return -EINVAL;
 		}
-		mark = RTA_DATA(tb[TCA_U32_MARK-1]);
+		mark = nla_data(tb[TCA_U32_MARK]);
 		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
 		n->mark.success = 0;
 	}
 #endif
 
-	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE-1]);
+	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE]);
 	if (err == 0) {
 		struct tc_u_knode **ins;
 		for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next)
@@ -694,59 +694,59 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 {
 	struct tc_u_knode *n = (struct tc_u_knode*)fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	if (n == NULL)
 		return skb->len;
 
 	t->tcm_handle = n->handle;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	if (TC_U32_KEY(n->handle) == 0) {
 		struct tc_u_hnode *ht = (struct tc_u_hnode*)fh;
 		u32 divisor = ht->divisor+1;
-		RTA_PUT(skb, TCA_U32_DIVISOR, 4, &divisor);
+		NLA_PUT(skb, TCA_U32_DIVISOR, 4, &divisor);
 	} else {
-		RTA_PUT(skb, TCA_U32_SEL,
+		NLA_PUT(skb, TCA_U32_SEL,
 			sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
 			&n->sel);
 		if (n->ht_up) {
 			u32 htid = n->handle & 0xFFFFF000;
-			RTA_PUT(skb, TCA_U32_HASH, 4, &htid);
+			NLA_PUT(skb, TCA_U32_HASH, 4, &htid);
 		}
 		if (n->res.classid)
-			RTA_PUT(skb, TCA_U32_CLASSID, 4, &n->res.classid);
+			NLA_PUT(skb, TCA_U32_CLASSID, 4, &n->res.classid);
 		if (n->ht_down)
-			RTA_PUT(skb, TCA_U32_LINK, 4, &n->ht_down->handle);
+			NLA_PUT(skb, TCA_U32_LINK, 4, &n->ht_down->handle);
 
 #ifdef CONFIG_CLS_U32_MARK
 		if (n->mark.val || n->mark.mask)
-			RTA_PUT(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark);
+			NLA_PUT(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark);
 #endif
 
 		if (tcf_exts_dump(skb, &n->exts, &u32_ext_map) < 0)
-			goto rtattr_failure;
+			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
 		if(strlen(n->indev))
-			RTA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
+			NLA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-		RTA_PUT(skb, TCA_U32_PCNT,
+		NLA_PUT(skb, TCA_U32_PCNT,
 		sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
 			n->pf);
 #endif
 	}
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	if (TC_U32_KEY(n->handle))
 		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
-			goto rtattr_failure;
+			goto nla_put_failure;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index ceda889..92b6863 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -542,11 +542,11 @@ static int meta_var_compare(struct meta_obj *a, struct meta_obj *b)
 	return r;
 }
 
-static int meta_var_change(struct meta_value *dst, struct rtattr *rta)
+static int meta_var_change(struct meta_value *dst, struct nlattr *nla)
 {
-	int len = RTA_PAYLOAD(rta);
+	int len = nla_len(nla);
 
-	dst->val = (unsigned long)kmemdup(RTA_DATA(rta), len, GFP_KERNEL);
+	dst->val = (unsigned long)kmemdup(nla_data(nla), len, GFP_KERNEL);
 	if (dst->val == 0UL)
 		return -ENOMEM;
 	dst->len = len;
@@ -570,10 +570,10 @@ static void meta_var_apply_extras(struct meta_value *v,
 static int meta_var_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 {
 	if (v->val && v->len)
-		RTA_PUT(skb, tlv, v->len, (void *) v->val);
+		NLA_PUT(skb, tlv, v->len, (void *) v->val);
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
@@ -594,13 +594,13 @@ static int meta_int_compare(struct meta_obj *a, struct meta_obj *b)
 		return 1;
 }
 
-static int meta_int_change(struct meta_value *dst, struct rtattr *rta)
+static int meta_int_change(struct meta_value *dst, struct nlattr *nla)
 {
-	if (RTA_PAYLOAD(rta) >= sizeof(unsigned long)) {
-		dst->val = *(unsigned long *) RTA_DATA(rta);
+	if (nla_len(nla) >= sizeof(unsigned long)) {
+		dst->val = *(unsigned long *) nla_data(nla);
 		dst->len = sizeof(unsigned long);
-	} else if (RTA_PAYLOAD(rta) == sizeof(u32)) {
-		dst->val = *(u32 *) RTA_DATA(rta);
+	} else if (nla_len(nla) == sizeof(u32)) {
+		dst->val = *(u32 *) nla_data(nla);
 		dst->len = sizeof(u32);
 	} else
 		return -EINVAL;
@@ -621,15 +621,15 @@ static void meta_int_apply_extras(struct meta_value *v,
 static int meta_int_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 {
 	if (v->len == sizeof(unsigned long))
-		RTA_PUT(skb, tlv, sizeof(unsigned long), &v->val);
+		NLA_PUT(skb, tlv, sizeof(unsigned long), &v->val);
 	else if (v->len == sizeof(u32)) {
 		u32 d = v->val;
-		RTA_PUT(skb, tlv, sizeof(d), &d);
+		NLA_PUT(skb, tlv, sizeof(d), &d);
 	}
 
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
@@ -641,7 +641,7 @@ struct meta_type_ops
 {
 	void	(*destroy)(struct meta_value *);
 	int	(*compare)(struct meta_obj *, struct meta_obj *);
-	int	(*change)(struct meta_value *, struct rtattr *);
+	int	(*change)(struct meta_value *, struct nlattr *);
 	void	(*apply_extras)(struct meta_value *, struct meta_obj *);
 	int	(*dump)(struct sk_buff *, struct meta_value *, int);
 };
@@ -729,13 +729,13 @@ static inline void meta_delete(struct meta_match *meta)
 	kfree(meta);
 }
 
-static inline int meta_change_data(struct meta_value *dst, struct rtattr *rta)
+static inline int meta_change_data(struct meta_value *dst, struct nlattr *nla)
 {
-	if (rta) {
-		if (RTA_PAYLOAD(rta) == 0)
+	if (nla) {
+		if (nla_len(nla) == 0)
 			return -EINVAL;
 
-		return meta_type_ops(dst)->change(dst, rta);
+		return meta_type_ops(dst)->change(dst, nla);
 	}
 
 	return 0;
@@ -750,17 +750,17 @@ static int em_meta_change(struct tcf_proto *tp, void *data, int len,
 			  struct tcf_ematch *m)
 {
 	int err = -EINVAL;
-	struct rtattr *tb[TCA_EM_META_MAX];
+	struct nlattr *tb[TCA_EM_META_MAX + 1];
 	struct tcf_meta_hdr *hdr;
 	struct meta_match *meta = NULL;
 
-	if (rtattr_parse(tb, TCA_EM_META_MAX, data, len) < 0)
+	if (nla_parse(tb, TCA_EM_META_MAX, data, len, NULL) < 0)
 		goto errout;
 
-	if (tb[TCA_EM_META_HDR-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_EM_META_HDR-1]) < sizeof(*hdr))
+	if (tb[TCA_EM_META_HDR] == NULL ||
+	    nla_len(tb[TCA_EM_META_HDR]) < sizeof(*hdr))
 		goto errout;
-	hdr = RTA_DATA(tb[TCA_EM_META_HDR-1]);
+	hdr = nla_data(tb[TCA_EM_META_HDR]);
 
 	if (TCF_META_TYPE(hdr->left.kind) != TCF_META_TYPE(hdr->right.kind) ||
 	    TCF_META_TYPE(hdr->left.kind) > TCF_META_TYPE_MAX ||
@@ -781,8 +781,8 @@ static int em_meta_change(struct tcf_proto *tp, void *data, int len,
 		goto errout;
 	}
 
-	if (meta_change_data(&meta->lvalue, tb[TCA_EM_META_LVALUE-1]) < 0 ||
-	    meta_change_data(&meta->rvalue, tb[TCA_EM_META_RVALUE-1]) < 0)
+	if (meta_change_data(&meta->lvalue, tb[TCA_EM_META_LVALUE]) < 0 ||
+	    meta_change_data(&meta->rvalue, tb[TCA_EM_META_RVALUE]) < 0)
 		goto errout;
 
 	m->datalen = sizeof(*meta);
@@ -811,16 +811,16 @@ static int em_meta_dump(struct sk_buff *skb, struct tcf_ematch *em)
 	memcpy(&hdr.left, &meta->lvalue.hdr, sizeof(hdr.left));
 	memcpy(&hdr.right, &meta->rvalue.hdr, sizeof(hdr.right));
 
-	RTA_PUT(skb, TCA_EM_META_HDR, sizeof(hdr), &hdr);
+	NLA_PUT(skb, TCA_EM_META_HDR, sizeof(hdr), &hdr);
 
 	ops = meta_type_ops(&meta->lvalue);
 	if (ops->dump(skb, &meta->lvalue, TCA_EM_META_LVALUE) < 0 ||
 	    ops->dump(skb, &meta->rvalue, TCA_EM_META_RVALUE) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index d5cd86e..853c5ea 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -118,11 +118,14 @@ static int em_text_dump(struct sk_buff *skb, struct tcf_ematch *m)
 	conf.pattern_len = textsearch_get_pattern_len(tm->config);
 	conf.pad = 0;
 
-	RTA_PUT_NOHDR(skb, sizeof(conf), &conf);
-	RTA_APPEND(skb, conf.pattern_len, textsearch_get_pattern(tm->config));
+	if (nla_put_nohdr(skb, sizeof(conf), &conf) < 0)
+		goto nla_put_failure;
+	if (nla_append(skb, conf.pattern_len,
+		       textsearch_get_pattern(tm->config)) < 0)
+		goto nla_put_failure;
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 27941cf..72d9b27 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -183,11 +183,11 @@ static inline struct tcf_ematch * tcf_em_get_match(struct tcf_ematch_tree *tree,
 
 static int tcf_em_validate(struct tcf_proto *tp,
 			   struct tcf_ematch_tree_hdr *tree_hdr,
-			   struct tcf_ematch *em, struct rtattr *rta, int idx)
+			   struct tcf_ematch *em, struct nlattr *nla, int idx)
 {
 	int err = -EINVAL;
-	struct tcf_ematch_hdr *em_hdr = RTA_DATA(rta);
-	int data_len = RTA_PAYLOAD(rta) - sizeof(*em_hdr);
+	struct tcf_ematch_hdr *em_hdr = nla_data(nla);
+	int data_len = nla_len(nla) - sizeof(*em_hdr);
 	void *data = (void *) em_hdr + sizeof(*em_hdr);
 
 	if (!TCF_EM_REL_VALID(em_hdr->flags))
@@ -286,11 +286,11 @@ errout:
  * tcf_em_tree_validate - validate ematch config TLV and build ematch tree
  *
  * @tp: classifier kind handle
- * @rta: ematch tree configuration TLV
+ * @nla: ematch tree configuration TLV
  * @tree: destination ematch tree variable to store the resulting
  *        ematch tree.
  *
- * This function validates the given configuration TLV @rta and builds an
+ * This function validates the given configuration TLV @nla and builds an
  * ematch tree in @tree. The resulting tree must later be copied into
  * the private classifier data using tcf_em_tree_change(). You MUST NOT
  * provide the ematch tree variable of the private classifier data directly,
@@ -298,45 +298,45 @@ errout:
  *
  * Returns a negative error code if the configuration TLV contains errors.
  */
-int tcf_em_tree_validate(struct tcf_proto *tp, struct rtattr *rta,
+int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 			 struct tcf_ematch_tree *tree)
 {
 	int idx, list_len, matches_len, err = -EINVAL;
-	struct rtattr *tb[TCA_EMATCH_TREE_MAX];
-	struct rtattr *rt_match, *rt_hdr, *rt_list;
+	struct nlattr *tb[TCA_EMATCH_TREE_MAX + 1];
+	struct nlattr *rt_match, *rt_hdr, *rt_list;
 	struct tcf_ematch_tree_hdr *tree_hdr;
 	struct tcf_ematch *em;
 
-	if (!rta) {
+	if (!nla) {
 		memset(tree, 0, sizeof(*tree));
 		return 0;
 	}
 
-	if (rtattr_parse_nested(tb, TCA_EMATCH_TREE_MAX, rta) < 0)
+	if (nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, NULL) < 0)
 		goto errout;
 
-	rt_hdr = tb[TCA_EMATCH_TREE_HDR-1];
-	rt_list = tb[TCA_EMATCH_TREE_LIST-1];
+	rt_hdr = tb[TCA_EMATCH_TREE_HDR];
+	rt_list = tb[TCA_EMATCH_TREE_LIST];
 
 	if (rt_hdr == NULL || rt_list == NULL)
 		goto errout;
 
-	if (RTA_PAYLOAD(rt_hdr) < sizeof(*tree_hdr) ||
-	    RTA_PAYLOAD(rt_list) < sizeof(*rt_match))
+	if (nla_len(rt_hdr) < sizeof(*tree_hdr) ||
+	    nla_len(rt_list) < sizeof(*rt_match))
 		goto errout;
 
-	tree_hdr = RTA_DATA(rt_hdr);
+	tree_hdr = nla_data(rt_hdr);
 	memcpy(&tree->hdr, tree_hdr, sizeof(*tree_hdr));
 
-	rt_match = RTA_DATA(rt_list);
-	list_len = RTA_PAYLOAD(rt_list);
+	rt_match = nla_data(rt_list);
+	list_len = nla_len(rt_list);
 	matches_len = tree_hdr->nmatches * sizeof(*em);
 
 	tree->matches = kzalloc(matches_len, GFP_KERNEL);
 	if (tree->matches == NULL)
 		goto errout;
 
-	/* We do not use rtattr_parse_nested here because the maximum
+	/* We do not use nla_parse_nested here because the maximum
 	 * number of attributes is unknown. This saves us the allocation
 	 * for a tb buffer which would serve no purpose at all.
 	 *
@@ -344,16 +344,16 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct rtattr *rta,
 	 * provided, their type must be incremental from 1 to n. Even
 	 * if it does not serve any real purpose, a failure of sticking
 	 * to this policy will result in parsing failure. */
-	for (idx = 0; RTA_OK(rt_match, list_len); idx++) {
+	for (idx = 0; nla_ok(rt_match, list_len); idx++) {
 		err = -EINVAL;
 
-		if (rt_match->rta_type != (idx + 1))
+		if (rt_match->nla_type != (idx + 1))
 			goto errout_abort;
 
 		if (idx >= tree_hdr->nmatches)
 			goto errout_abort;
 
-		if (RTA_PAYLOAD(rt_match) < sizeof(struct tcf_ematch_hdr))
+		if (nla_len(rt_match) < sizeof(struct tcf_ematch_hdr))
 			goto errout_abort;
 
 		em = tcf_em_get_match(tree, idx);
@@ -362,7 +362,7 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct rtattr *rta,
 		if (err < 0)
 			goto errout_abort;
 
-		rt_match = RTA_NEXT(rt_match, list_len);
+		rt_match = nla_next(rt_match, &list_len);
 	}
 
 	/* Check if the number of matches provided by userspace actually
@@ -434,18 +434,18 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 {
 	int i;
 	u8 *tail;
-	struct rtattr *top_start = (struct rtattr *)skb_tail_pointer(skb);
-	struct rtattr *list_start;
+	struct nlattr *top_start = (struct nlattr *)skb_tail_pointer(skb);
+	struct nlattr *list_start;
 
-	RTA_PUT(skb, tlv, 0, NULL);
-	RTA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr);
+	NLA_PUT(skb, tlv, 0, NULL);
+	NLA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr);
 
-	list_start = (struct rtattr *)skb_tail_pointer(skb);
-	RTA_PUT(skb, TCA_EMATCH_TREE_LIST, 0, NULL);
+	list_start = (struct nlattr *)skb_tail_pointer(skb);
+	NLA_PUT(skb, TCA_EMATCH_TREE_LIST, 0, NULL);
 
 	tail = skb_tail_pointer(skb);
 	for (i = 0; i < tree->hdr.nmatches; i++) {
-		struct rtattr *match_start = (struct rtattr *)tail;
+		struct nlattr *match_start = (struct nlattr *)tail;
 		struct tcf_ematch *em = tcf_em_get_match(tree, i);
 		struct tcf_ematch_hdr em_hdr = {
 			.kind = em->ops ? em->ops->kind : TCF_EM_CONTAINER,
@@ -453,27 +453,27 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 			.flags = em->flags
 		};
 
-		RTA_PUT(skb, i+1, sizeof(em_hdr), &em_hdr);
+		NLA_PUT(skb, i+1, sizeof(em_hdr), &em_hdr);
 
 		if (em->ops && em->ops->dump) {
 			if (em->ops->dump(skb, em) < 0)
-				goto rtattr_failure;
+				goto nla_put_failure;
 		} else if (tcf_em_is_container(em) || tcf_em_is_simple(em)) {
 			u32 u = em->data;
-			RTA_PUT_NOHDR(skb, sizeof(u), &u);
+			nla_put_nohdr(skb, sizeof(u), &u);
 		} else if (em->datalen > 0)
-			RTA_PUT_NOHDR(skb, em->datalen, (void *) em->data);
+			nla_put_nohdr(skb, em->datalen, (void *) em->data);
 
 		tail = skb_tail_pointer(skb);
-		match_start->rta_len = tail - (u8 *)match_start;
+		match_start->nla_len = tail - (u8 *)match_start;
 	}
 
-	list_start->rta_len = tail - (u8 *)list_start;
-	top_start->rta_len = tail - (u8 *)top_start;
+	list_start->nla_len = tail - (u8 *)list_start;
+	top_start->nla_len = tail - (u8 *)top_start;
 
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 EXPORT_SYMBOL(tcf_em_tree_dump);
