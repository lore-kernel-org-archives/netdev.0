From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 02/20] net: sched: remove unneeded tcf_em_tree_change
Date: Fri,  4 Aug 2017 14:28:57 +0200
Message-ID: <20170804122915.15177-3-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32771 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdHDM3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:21 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so2903659wrd.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:20 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since tcf_em_tree_validate could be always called on a newly created
filter, there is no need for this change function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h  | 21 ---------------------
 net/sched/cls_basic.c  |  4 +---
 net/sched/cls_cgroup.c |  4 +---
 net/sched/cls_flow.c   | 12 +++++-------
 4 files changed, 7 insertions(+), 34 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 537d0a0..f4462ec 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -333,26 +333,6 @@ int __tcf_em_tree_match(struct sk_buff *, struct tcf_ematch_tree *,
 			struct tcf_pkt_info *);
 
 /**
- * tcf_em_tree_change - replace ematch tree of a running classifier
- *
- * @tp: classifier kind handle
- * @dst: destination ematch tree variable
- * @src: source ematch tree (temporary tree from tcf_em_tree_validate)
- *
- * This functions replaces the ematch tree in @dst with the ematch
- * tree in @src. The classifier in charge of the ematch tree may be
- * running.
- */
-static inline void tcf_em_tree_change(struct tcf_proto *tp,
-				      struct tcf_ematch_tree *dst,
-				      struct tcf_ematch_tree *src)
-{
-	tcf_tree_lock(tp);
-	memcpy(dst, src, sizeof(*dst));
-	tcf_tree_unlock(tp);
-}
-
-/**
  * tcf_em_tree_match - evaulate an ematch tree
  *
  * @skb: socket buffer of the packet in question
@@ -386,7 +366,6 @@ struct tcf_ematch_tree {
 #define tcf_em_tree_validate(tp, tb, t) ((void)(t), 0)
 #define tcf_em_tree_destroy(t) do { (void)(t); } while(0)
 #define tcf_em_tree_dump(skb, t, tlv) (0)
-#define tcf_em_tree_change(tp, dst, src) do { } while(0)
 #define tcf_em_tree_match(skb, t, info) ((void)(info), 1)
 
 #endif /* CONFIG_NET_EMATCH */
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index c4fd63a..979cd26 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -130,7 +130,6 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 {
 	int err;
 	struct tcf_exts e;
-	struct tcf_ematch_tree t;
 
 	err = tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	if (err < 0)
@@ -139,7 +138,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	if (err < 0)
 		goto errout;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &t);
+	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &f->ematches);
 	if (err < 0)
 		goto errout;
 
@@ -149,7 +148,6 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	}
 
 	tcf_exts_change(tp, &f->exts, &e);
-	tcf_em_tree_change(tp, &f->ematches, &t);
 	f->tp = tp;
 
 	return 0;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 12ce547..ce7d38b 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -76,7 +76,6 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *tb[TCA_CGROUP_MAX + 1];
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 	struct cls_cgroup_head *new;
-	struct tcf_ematch_tree t;
 	struct tcf_exts e;
 	int err;
 
@@ -112,14 +111,13 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 	}
 
-	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
+	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &new->ematches);
 	if (err < 0) {
 		tcf_exts_destroy(&e);
 		goto errout;
 	}
 
 	tcf_exts_change(tp, &new->exts, &e);
-	tcf_em_tree_change(tp, &new->ematches, &t);
 
 	rcu_assign_pointer(tp->root, new);
 	if (head)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 3065752..71fd1af 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -389,7 +389,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FLOW_MAX + 1];
 	struct tcf_exts e;
-	struct tcf_ematch_tree t;
 	unsigned int nkeys = 0;
 	unsigned int perturb_period = 0;
 	u32 baseclass = 0;
@@ -432,13 +431,13 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto err1;
 
-	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &t);
-	if (err < 0)
-		goto err1;
-
 	err = -ENOBUFS;
 	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
 	if (!fnew)
+		goto err1;
+
+	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &fnew->ematches);
+	if (err < 0)
 		goto err2;
 
 	err = tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
@@ -512,7 +511,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			       (unsigned long)fnew);
 
 	tcf_exts_change(tp, &fnew->exts, &e);
-	tcf_em_tree_change(tp, &fnew->ematches, &t);
 
 	netif_keep_dst(qdisc_dev(tp->q));
 
@@ -554,8 +552,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 
 err3:
 	tcf_exts_destroy(&fnew->exts);
+	tcf_em_tree_destroy(&fnew->ematches);
 err2:
-	tcf_em_tree_destroy(&t);
 	kfree(fnew);
 err1:
 	tcf_exts_destroy(&e);
-- 
2.9.3
