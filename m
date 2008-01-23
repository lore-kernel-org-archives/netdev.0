From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 07/15]: Use nla_nest_start/nla_nest_end
Date: Wed, 23 Jan 2008 17:36:45 +0100 (MET)
Message-ID: <20080123163604.6459.5104.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49733 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669AbYAWQgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:48 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use nla_nest_start/nla_nest_end

Use nla_nest_start/nla_nest_end for dumping nested attributes.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit bdd38a3b14cfa340da580f6e825d7f1142925926
tree 36dc82b63837c96b0f5e1b5c508f789abe7414e8
parent f9b5ab497909e836983bc31e5e7ad5065ccba6bc
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:54 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:54 +0100

 net/sched/act_api.c     |   84 ++++++++++++++++++++++++++---------------------
 net/sched/act_police.c  |   13 ++++---
 net/sched/cls_api.c     |   14 +++++---
 net/sched/cls_basic.c   |   12 +++----
 net/sched/cls_fw.c      |    9 +++--
 net/sched/cls_route.c   |    9 +++--
 net/sched/cls_rsvp.h    |   10 +++---
 net/sched/cls_tcindex.c |   13 ++++---
 net/sched/cls_u32.c     |   13 ++++---
 net/sched/ematch.c      |   16 ++++++---
 net/sched/sch_atm.c     |   15 +++++---
 net/sched/sch_cbq.c     |   24 +++++++------
 net/sched/sch_hfsc.c    |   11 +++---
 net/sched/sch_htb.c     |   32 +++++++++++-------
 net/sched/sch_ingress.c |   12 +++----
 net/sched/sch_tbf.c     |   12 +++----
 16 files changed, 166 insertions(+), 133 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 87818d7..3602260 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -69,7 +69,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 {
 	struct tcf_common *p;
 	int err = 0, index = -1,i = 0, s_i = 0, n_i = 0;
-	struct nlattr *r ;
+	struct nlattr *nest;
 
 	read_lock_bh(hinfo->lock);
 
@@ -84,15 +84,17 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 				continue;
 			a->priv = p;
 			a->order = n_i;
-			r = (struct nlattr *)skb_tail_pointer(skb);
-			NLA_PUT(skb, a->order, 0, NULL);
+
+			nest = nla_nest_start(skb, a->order);
+			if (nest == NULL)
+				goto nla_put_failure;
 			err = tcf_action_dump_1(skb, a, 0, 0);
 			if (err < 0) {
 				index--;
-				nlmsg_trim(skb, r);
+				nlmsg_trim(skb, nest);
 				goto done;
 			}
-			r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
+			nla_nest_end(skb, nest);
 			n_i++;
 			if (n_i >= TCA_ACT_MAX_PRIO)
 				goto done;
@@ -105,7 +107,7 @@ done:
 	return n_i;
 
 nla_put_failure:
-	nlmsg_trim(skb, r);
+	nla_nest_cancel(skb, nest);
 	goto done;
 }
 
@@ -113,11 +115,12 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			  struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p, *s_p;
-	struct nlattr *r ;
+	struct nlattr *nest;
 	int i= 0, n_i = 0;
 
-	r = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, a->order, 0, NULL);
+	nest = nla_nest_start(skb, a->order);
+	if (nest == NULL)
+		goto nla_put_failure;
 	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
@@ -131,11 +134,11 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 		}
 	}
 	NLA_PUT(skb, TCA_FCNT, 4, &n_i);
-	r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
+	nla_nest_end(skb, nest);
 
 	return n_i;
 nla_put_failure:
-	nlmsg_trim(skb, r);
+	nla_nest_cancel(skb, nest);
 	return -EINVAL;
 }
 
@@ -415,7 +418,7 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *r;
+	struct nlattr *nest;
 
 	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
@@ -423,10 +426,11 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
 	if (tcf_action_copy_stats(skb, a, 0))
 		goto nla_put_failure;
-	r = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 	if ((err = tcf_action_dump_old(skb, a, bind, ref)) > 0) {
-		r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
+		nla_nest_end(skb, nest);
 		return err;
 	}
 
@@ -441,17 +445,17 @@ tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
 {
 	struct tc_action *a;
 	int err = -EINVAL;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *r ;
+	struct nlattr *nest;
 
 	while ((a = act) != NULL) {
-		r = (struct nlattr *)skb_tail_pointer(skb);
 		act = a->next;
-		NLA_PUT(skb, a->order, 0, NULL);
+		nest = nla_nest_start(skb, a->order);
+		if (nest == NULL)
+			goto nla_put_failure;
 		err = tcf_action_dump_1(skb, a, bind, ref);
 		if (err < 0)
 			goto errout;
-		r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
+		nla_nest_end(skb, nest);
 	}
 
 	return 0;
@@ -459,7 +463,7 @@ tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
 nla_put_failure:
 	err = -EINVAL;
 errout:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return err;
 }
 
@@ -627,7 +631,7 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *x;
+	struct nlattr *nest;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
 
@@ -636,13 +640,14 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	nest = nla_nest_start(skb, TCA_ACT_TAB);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (tcf_action_dump(skb, a, bind, ref) < 0)
 		goto nla_put_failure;
 
-	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
+	nla_nest_end(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
@@ -743,7 +748,7 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	struct nlmsghdr *nlh;
 	struct tcamsg *t;
 	struct netlink_callback dcb;
-	struct nlattr *x;
+	struct nlattr *nest;
 	struct nlattr *tb[TCA_ACT_MAX+1];
 	struct nlattr *kind;
 	struct tc_action *a = create_a(0);
@@ -779,14 +784,15 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	nest = nla_nest_start(skb, TCA_ACT_TAB);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
 	if (err < 0)
 		goto nla_put_failure;
 
-	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
+	nla_nest_end(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	nlh->nlmsg_flags |= NLM_F_ROOT;
@@ -875,7 +881,7 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	struct nlattr *x;
+	struct nlattr *nest;
 	unsigned char *b;
 	int err = 0;
 
@@ -891,13 +897,14 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	nest = nla_nest_start(skb, TCA_ACT_TAB);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (tcf_action_dump(skb, a, 0, 0) < 0)
 		goto nla_put_failure;
 
-	x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
+	nla_nest_end(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
@@ -1025,7 +1032,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = skb->sk->sk_net;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *x;
+	struct nlattr *nest;
 	struct tc_action_ops *a_o;
 	struct tc_action a;
 	int ret = 0;
@@ -1060,18 +1067,19 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
-	x = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_ACT_TAB, 0, NULL);
+	nest = nla_nest_start(skb, TCA_ACT_TAB);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
 	if (ret < 0)
 		goto nla_put_failure;
 
 	if (ret > 0) {
-		x->nla_len = skb_tail_pointer(skb) - (u8 *)x;
+		nla_nest_end(skb, nest);
 		ret = skb->len;
 	} else
-		nlmsg_trim(skb, x);
+		nla_nest_cancel(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	if (NETLINK_CB(cb->skb).pid && ret)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index c0fce9b..ee2f1b6 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -54,7 +54,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 {
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
-	struct nlattr *r;
+	struct nlattr *nest;
 
 	read_lock_bh(&police_lock);
 
@@ -69,18 +69,19 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 				continue;
 			a->priv = p;
 			a->order = index;
-			r = (struct nlattr *)skb_tail_pointer(skb);
-			NLA_PUT(skb, a->order, 0, NULL);
+			nest = nla_nest_start(skb, a->order);
+			if (nest == NULL)
+				goto nla_put_failure;
 			if (type == RTM_DELACTION)
 				err = tcf_action_dump_1(skb, a, 0, 1);
 			else
 				err = tcf_action_dump_1(skb, a, 0, 0);
 			if (err < 0) {
 				index--;
-				nlmsg_trim(skb, r);
+				nla_nest_cancel(skb, nest);
 				goto done;
 			}
-			r->nla_len = skb_tail_pointer(skb) - (u8 *)r;
+			nla_nest_end(skb, nest);
 			n_i++;
 		}
 	}
@@ -91,7 +92,7 @@ done:
 	return n_i;
 
 nla_put_failure:
-	nlmsg_trim(skb, r);
+	nla_nest_cancel(skb, nest);
 	goto done;
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 92fa155..5584e7c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -544,18 +544,22 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
-		struct nlattr *p_rta = (struct nlattr *)skb_tail_pointer(skb);
+		struct nlattr *nest;
 
 		if (exts->action->type != TCA_OLD_COMPAT) {
-			NLA_PUT(skb, map->action, 0, NULL);
+			nest = nla_nest_start(skb, map->action);
+			if (nest == NULL)
+				goto nla_put_failure;
 			if (tcf_action_dump(skb, exts->action, 0, 0) < 0)
 				goto nla_put_failure;
-			p_rta->nla_len = skb_tail_pointer(skb) - (u8 *)p_rta;
+			nla_nest_end(skb, nest);
 		} else if (map->police) {
-			NLA_PUT(skb, map->police, 0, NULL);
+			nest = nla_nest_start(skb, map->police);
+			if (nest == NULL)
+				goto nla_put_failure;
 			if (tcf_action_dump_old(skb, exts->action, 0, 0) < 0)
 				goto nla_put_failure;
-			p_rta->nla_len = skb_tail_pointer(skb) - (u8 *)p_rta;
+			nla_nest_end(skb, nest);
 		}
 	}
 #endif
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 524b788..6d08b42 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -246,16 +246,16 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 		      struct sk_buff *skb, struct tcmsg *t)
 {
 	struct basic_filter *f = (struct basic_filter *) fh;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	if (f == NULL)
 		return skb->len;
 
 	t->tcm_handle = f->handle;
 
-	nla = (struct nlattr *) b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (f->res.classid)
 		NLA_PUT(skb, TCA_BASIC_CLASSID, sizeof(u32), &f->res.classid);
@@ -264,11 +264,11 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
 		goto nla_put_failure;
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a1a9f4d..e3dfbb3 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -334,7 +334,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f = (struct fw_filter*)fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	if (f == NULL)
 		return skb->len;
@@ -344,8 +344,9 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	if (!f->res.classid && !tcf_exts_is_available(&f->exts))
 		return skb->len;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (f->res.classid)
 		NLA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
@@ -359,7 +360,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
 		goto nla_put_failure;
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 3aa8109..1ce1f36 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -551,7 +551,7 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 {
 	struct route4_filter *f = (struct route4_filter*)fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 	u32 id;
 
 	if (f == NULL)
@@ -559,8 +559,9 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 
 	t->tcm_handle = f->handle;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (!(f->handle&0x8000)) {
 		id = f->id&0xFF;
@@ -579,7 +580,7 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
 		goto nla_put_failure;
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 5747408..77097e0 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -595,7 +595,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	struct rsvp_filter *f = (struct rsvp_filter*)fh;
 	struct rsvp_session *s;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 	struct tc_rsvp_pinfo pinfo;
 
 	if (f == NULL)
@@ -604,9 +604,9 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 
 	t->tcm_handle = f->handle;
 
-
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	NLA_PUT(skb, TCA_RSVP_DST, sizeof(s->dst), &s->dst);
 	pinfo.dpi = s->dpi;
@@ -624,7 +624,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
 		goto nla_put_failure;
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 
 	if (tcf_exts_dump_stats(skb, &f->exts, &rsvp_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 6b84d27..cd350d3 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -437,13 +437,16 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	pr_debug("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p,b %p\n",
 		 tp, fh, skb, t, p, r, b);
 	pr_debug("p->perfect %p p->h %p\n", p->perfect, p->h);
-	nla = (struct nlattr *) b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
 	if (!fh) {
 		t->tcm_handle = ~0; /* whatever ... */
 		NLA_PUT(skb, TCA_TCINDEX_HASH, sizeof(p->hash), &p->hash);
@@ -451,7 +454,7 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 		NLA_PUT(skb, TCA_TCINDEX_SHIFT, sizeof(p->shift), &p->shift);
 		NLA_PUT(skb, TCA_TCINDEX_FALL_THROUGH, sizeof(p->fall_through),
 		    &p->fall_through);
-		nla->nla_len = skb_tail_pointer(skb) - b;
+		nla_nest_end(skb, nest);
 	} else {
 		if (p->perfect) {
 			t->tcm_handle = r-p->perfect;
@@ -474,7 +477,7 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 
 		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
 			goto nla_put_failure;
-		nla->nla_len = skb_tail_pointer(skb) - b;
+		nla_nest_end(skb, nest);
 
 		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
 			goto nla_put_failure;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 3228cc4..b51c2c3 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -694,16 +694,16 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tc_u_knode *n = (struct tc_u_knode*)fh;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	if (n == NULL)
 		return skb->len;
 
 	t->tcm_handle = n->handle;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	if (TC_U32_KEY(n->handle) == 0) {
 		struct tc_u_hnode *ht = (struct tc_u_hnode*)fh;
@@ -741,14 +741,15 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 #endif
 	}
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
+
 	if (TC_U32_KEY(n->handle))
 		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
 			goto nla_put_failure;
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index d2b480f..daa9c4e 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -436,14 +436,18 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 {
 	int i;
 	u8 *tail;
-	struct nlattr *top_start = (struct nlattr *)skb_tail_pointer(skb);
+	struct nlattr *top_start;
 	struct nlattr *list_start;
 
-	NLA_PUT(skb, tlv, 0, NULL);
+	top_start = nla_nest_start(skb, tlv);
+	if (top_start == NULL)
+		goto nla_put_failure;
+
 	NLA_PUT(skb, TCA_EMATCH_TREE_HDR, sizeof(tree->hdr), &tree->hdr);
 
-	list_start = (struct nlattr *)skb_tail_pointer(skb);
-	NLA_PUT(skb, TCA_EMATCH_TREE_LIST, 0, NULL);
+	list_start = nla_nest_start(skb, TCA_EMATCH_TREE_LIST);
+	if (list_start == NULL)
+		goto nla_put_failure;
 
 	tail = skb_tail_pointer(skb);
 	for (i = 0; i < tree->hdr.nmatches; i++) {
@@ -470,8 +474,8 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 		match_start->nla_len = tail - (u8 *)match_start;
 	}
 
-	list_start->nla_len = tail - (u8 *)list_start;
-	top_start->nla_len = tail - (u8 *)top_start;
+	nla_nest_end(skb, list_start);
+	nla_nest_end(skb, top_start);
 
 	return 0;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index aaa32a2..19c0007 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -605,8 +605,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	pr_debug("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
 		sch, p, flow, skb, tcm);
@@ -614,8 +613,11 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		return -EINVAL;
 	tcm->tcm_handle = flow->classid;
 	tcm->tcm_info = flow->q->handle;
-	nla = (struct nlattr *)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
 	NLA_PUT(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr);
 	if (flow->vcc) {
 		struct sockaddr_atmpvc pvc;
@@ -636,11 +638,12 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 
 		NLA_PUT(skb, TCA_ATM_EXCESS, sizeof(zero), &zero);
 	}
-	nla->nla_len = skb_tail_pointer(skb) - b;
+
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 static int
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 585f8a6..da0f6c0 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1565,18 +1565,18 @@ static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 	if (cbq_dump_attr(skb, &q->link) < 0)
 		goto nla_put_failure;
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
@@ -1594,8 +1594,7 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct cbq_class *cl = (struct cbq_class*)arg;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
 	if (cl->tparent)
 		tcm->tcm_parent = cl->tparent->classid;
@@ -1604,15 +1603,16 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	tcm->tcm_handle = cl->classid;
 	tcm->tcm_info = cl->q->handle;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 	if (cbq_dump_attr(skb, cl) < 0)
 		goto nla_put_failure;
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fcb4826..54c3e90 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1343,22 +1343,23 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		struct tcmsg *tcm)
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla = (struct nlattr *)b;
+	struct nlattr *nest;
 
 	tcm->tcm_parent = cl->cl_parent ? cl->cl_parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
 	if (cl->level == 0)
 		tcm->tcm_info = cl->qdisc->handle;
 
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto nla_put_failure;
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
 	return skb->len;
 
  nla_put_failure:
-	nlmsg_trim(skb, b);
+ 	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 512df9a..69fac32 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1043,25 +1043,29 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 	struct tc_htb_glob gopt;
+
 	spin_lock_bh(&sch->dev->queue_lock);
-	gopt.direct_pkts = q->direct_pkts;
 
+	gopt.direct_pkts = q->direct_pkts;
 	gopt.version = HTB_VER;
 	gopt.rate2quantum = q->rate2quantum;
 	gopt.defcls = q->defcls;
 	gopt.debug = 0;
-	nla = (struct nlattr *)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nla_nest_end(skb, nest);
+
 	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
+
 nla_put_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
-	nlmsg_trim(skb, skb_tail_pointer(skb));
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
@@ -1069,8 +1073,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
 	spin_lock_bh(&sch->dev->queue_lock);
@@ -1079,8 +1082,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	if (!cl->level && cl->un.leaf.q)
 		tcm->tcm_info = cl->un.leaf.q->handle;
 
-	nla = (struct nlattr *)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	memset(&opt, 0, sizeof(opt));
 
@@ -1092,12 +1096,14 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	opt.prio = cl->un.leaf.prio;
 	opt.level = cl->level;
 	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
-	nla->nla_len = skb_tail_pointer(skb) - b;
+
+	nla_nest_end(skb, nest);
 	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
+
 nla_put_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index f6decbb..3f72d52 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -183,16 +183,16 @@ static void ingress_destroy(struct Qdisc *sch)
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 
-	nla = (struct nlattr *)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index f9b1543..b7a185d 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -375,12 +375,12 @@ static void tbf_destroy(struct Qdisc *sch)
 static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla;
+	struct nlattr *nest;
 	struct tc_tbf_qopt opt;
 
-	nla = (struct nlattr*)b;
-	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
 
 	opt.limit = q->limit;
 	opt.rate = q->R_tab->rate;
@@ -391,12 +391,12 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.mtu = q->mtu;
 	opt.buffer = q->buffer;
 	NLA_PUT(skb, TCA_TBF_PARMS, sizeof(opt), &opt);
-	nla->nla_len = skb_tail_pointer(skb) - b;
 
+	nla_nest_end(skb, nest);
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
