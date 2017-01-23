From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net] net/sched: matchall: Fix configuration race
Date: Mon, 23 Jan 2017 10:54:27 +0200
Message-ID: <1485161667-13929-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: mlxsw@mellanox.com, jiri@mellanox.com, eladr@mellanox.com,
        daniel@iogearbox.net, jhs@mojatatu.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58702 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750703AbdAWIwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 03:52:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current version, the matchall internal state is split into two
structs: cls_matchall_head and cls_matchall_filter. This makes little
sense, as matchall instance supports only one filter, and there is no
situation where one exists and the other does not. In addition, that led
to some races when filter was deleted while packet was processed.

Unify that two structs into one, thus simplifying the process of matchall
creation and deletion. As a result, the new, delete and get callbacks have
a dummy implementation where all the work is done in destroy and change
callbacks, as was done in cls_cgroup.

Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 129 +++++++++++++++++------------------------------
 1 file changed, 46 insertions(+), 83 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index fcecf5a..f2141cb 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -16,16 +16,11 @@
 #include <net/sch_generic.h>
 #include <net/pkt_cls.h>
 
-struct cls_mall_filter {
+struct cls_mall_head {
 	struct tcf_exts exts;
 	struct tcf_result res;
 	u32 handle;
-	struct rcu_head	rcu;
 	u32 flags;
-};
-
-struct cls_mall_head {
-	struct cls_mall_filter *filter;
 	struct rcu_head	rcu;
 };
 
@@ -33,38 +28,29 @@ static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
 	struct cls_mall_head *head = rcu_dereference_bh(tp->root);
-	struct cls_mall_filter *f = head->filter;
 
-	if (tc_skip_sw(f->flags))
+	if (tc_skip_sw(head->flags))
 		return -1;
 
-	return tcf_exts_exec(skb, &f->exts, res);
+	return tcf_exts_exec(skb, &head->exts, res);
 }
 
 static int mall_init(struct tcf_proto *tp)
 {
-	struct cls_mall_head *head;
-
-	head = kzalloc(sizeof(*head), GFP_KERNEL);
-	if (!head)
-		return -ENOBUFS;
-
-	rcu_assign_pointer(tp->root, head);
-
 	return 0;
 }
 
-static void mall_destroy_filter(struct rcu_head *head)
+static void mall_destroy_rcu(struct rcu_head *rcu)
 {
-	struct cls_mall_filter *f = container_of(head, struct cls_mall_filter, rcu);
+	struct cls_mall_head *head = container_of(rcu, struct cls_mall_head,
+						  rcu);
 
-	tcf_exts_destroy(&f->exts);
-
-	kfree(f);
+	tcf_exts_destroy(&head->exts);
+	kfree(head);
 }
 
 static int mall_replace_hw_filter(struct tcf_proto *tp,
-				  struct cls_mall_filter *f,
+				  struct cls_mall_head *head,
 				  unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
@@ -74,7 +60,7 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	offload.type = TC_SETUP_MATCHALL;
 	offload.cls_mall = &mall_offload;
 	offload.cls_mall->command = TC_CLSMATCHALL_REPLACE;
-	offload.cls_mall->exts = &f->exts;
+	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
 	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
@@ -82,7 +68,7 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 }
 
 static void mall_destroy_hw_filter(struct tcf_proto *tp,
-				   struct cls_mall_filter *f,
+				   struct cls_mall_head *head,
 				   unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
@@ -103,29 +89,20 @@ static bool mall_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct cls_mall_filter *f = head->filter;
 
-	if (!force && f)
-		return false;
+	if (!head)
+		return true;
 
-	if (f) {
-		if (tc_should_offload(dev, tp, f->flags))
-			mall_destroy_hw_filter(tp, f, (unsigned long) f);
+	if (tc_should_offload(dev, tp, head->flags))
+		mall_destroy_hw_filter(tp, head, (unsigned long) head);
 
-		call_rcu(&f->rcu, mall_destroy_filter);
-	}
-	kfree_rcu(head, rcu);
+	call_rcu(&head->rcu, mall_destroy_rcu);
 	return true;
 }
 
 static unsigned long mall_get(struct tcf_proto *tp, u32 handle)
 {
-	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct cls_mall_filter *f = head->filter;
-
-	if (f && f->handle == handle)
-		return (unsigned long) f;
-	return 0;
+	return 0UL;
 }
 
 static const struct nla_policy mall_policy[TCA_MATCHALL_MAX + 1] = {
@@ -134,7 +111,7 @@ static const struct nla_policy mall_policy[TCA_MATCHALL_MAX + 1] = {
 };
 
 static int mall_set_parms(struct net *net, struct tcf_proto *tp,
-			  struct cls_mall_filter *f,
+			  struct cls_mall_head *head,
 			  unsigned long base, struct nlattr **tb,
 			  struct nlattr *est, bool ovr)
 {
@@ -149,11 +126,11 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 		goto errout;
 
 	if (tb[TCA_MATCHALL_CLASSID]) {
-		f->res.classid = nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
-		tcf_bind_filter(tp, &f->res, base);
+		head->res.classid = nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
+		tcf_bind_filter(tp, &head->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(tp, &head->exts, &e);
 
 	return 0;
 errout:
@@ -167,21 +144,17 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 		       unsigned long *arg, bool ovr)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct cls_mall_filter *fold = (struct cls_mall_filter *) *arg;
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct cls_mall_filter *f;
 	struct nlattr *tb[TCA_MATCHALL_MAX + 1];
+	struct cls_mall_head *new;
 	u32 flags = 0;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
-	if (head->filter)
-		return -EBUSY;
-
-	if (fold)
-		return -EINVAL;
+	if (head)
+		return -EEXIST;
 
 	err = nla_parse_nested(tb, TCA_MATCHALL_MAX,
 			       tca[TCA_OPTIONS], mall_policy);
@@ -194,25 +167,25 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 			return -EINVAL;
 	}
 
-	f = kzalloc(sizeof(*f), GFP_KERNEL);
-	if (!f)
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
 		return -ENOBUFS;
 
-	err = tcf_exts_init(&f->exts, TCA_MATCHALL_ACT, 0);
+	err = tcf_exts_init(&new->exts, TCA_MATCHALL_ACT, 0);
 	if (err)
 		goto err_exts_init;
 
 	if (!handle)
 		handle = 1;
-	f->handle = handle;
-	f->flags = flags;
+	new->handle = handle;
+	new->flags = flags;
 
-	err = mall_set_parms(net, tp, f, base, tb, tca[TCA_RATE], ovr);
+	err = mall_set_parms(net, tp, new, base, tb, tca[TCA_RATE], ovr);
 	if (err)
 		goto err_set_parms;
 
 	if (tc_should_offload(dev, tp, flags)) {
-		err = mall_replace_hw_filter(tp, f, (unsigned long) f);
+		err = mall_replace_hw_filter(tp, new, (unsigned long) new);
 		if (err) {
 			if (tc_skip_sw(flags))
 				goto err_replace_hw_filter;
@@ -221,42 +194,32 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 		}
 	}
 
-	*arg = (unsigned long) f;
-	rcu_assign_pointer(head->filter, f);
-
+	*arg = (unsigned long) head;
+	rcu_assign_pointer(tp->root, new);
+	if (head)
+		call_rcu(&head->rcu, mall_destroy_rcu);
 	return 0;
 
 err_replace_hw_filter:
 err_set_parms:
-	tcf_exts_destroy(&f->exts);
+	tcf_exts_destroy(&new->exts);
 err_exts_init:
-	kfree(f);
+	kfree(new);
 	return err;
 }
 
 static int mall_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct cls_mall_filter *f = (struct cls_mall_filter *) arg;
-	struct net_device *dev = tp->q->dev_queue->dev;
-
-	if (tc_should_offload(dev, tp, f->flags))
-		mall_destroy_hw_filter(tp, f, (unsigned long) f);
-
-	RCU_INIT_POINTER(head->filter, NULL);
-	tcf_unbind_filter(tp, &f->res);
-	call_rcu(&f->rcu, mall_destroy_filter);
-	return 0;
+	return -EOPNOTSUPP;
 }
 
 static void mall_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct cls_mall_filter *f = head->filter;
 
 	if (arg->count < arg->skip)
 		goto skip;
-	if (arg->fn(tp, (unsigned long) f, arg) < 0)
+	if (arg->fn(tp, (unsigned long) head, arg) < 0)
 		arg->stop = 1;
 skip:
 	arg->count++;
@@ -265,28 +228,28 @@ static void mall_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
-	struct cls_mall_filter *f = (struct cls_mall_filter *) fh;
+	struct cls_mall_head *head = (struct cls_mall_head *) fh;
 	struct nlattr *nest;
 
-	if (!f)
+	if (!head)
 		return skb->len;
 
-	t->tcm_handle = f->handle;
+	t->tcm_handle = head->handle;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (!nest)
 		goto nla_put_failure;
 
-	if (f->res.classid &&
-	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, f->res.classid))
+	if (head->res.classid &&
+	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts))
+	if (tcf_exts_dump(skb, &head->exts))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_exts_dump_stats(skb, &head->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
-- 
2.4.11
