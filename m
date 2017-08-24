From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 1/4] net_sched: get rid of more forward declarations
Date: Thu, 24 Aug 2017 16:51:27 -0700
Message-ID: <20170824235130.28503-2-xiyou.wangcong@gmail.com>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36211 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbdHXXvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:51:54 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so1345913pgb.3
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:51:54 -0700 (PDT)
In-Reply-To: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not needed if we move them up properly.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c | 348 +++++++++++++++++++++++++---------------------------
 1 file changed, 169 insertions(+), 179 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index aaf552b8e120..330ffaea9974 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -36,13 +36,6 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
-static int qdisc_notify(struct net *net, struct sk_buff *oskb,
-			struct nlmsghdr *n, u32 clid,
-			struct Qdisc *old, struct Qdisc *new);
-static int tclass_notify(struct net *net, struct sk_buff *oskb,
-			 struct nlmsghdr *n, struct Qdisc *q,
-			 unsigned long cl, int event);
-
 /*
 
    Short review.
@@ -775,6 +768,111 @@ void qdisc_tree_reduce_backlog(struct Qdisc *sch, unsigned int n,
 }
 EXPORT_SYMBOL(qdisc_tree_reduce_backlog);
 
+static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
+			 u32 portid, u32 seq, u16 flags, int event)
+{
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
+	struct gnet_stats_queue __percpu *cpu_qstats = NULL;
+	struct tcmsg *tcm;
+	struct nlmsghdr  *nlh;
+	unsigned char *b = skb_tail_pointer(skb);
+	struct gnet_dump d;
+	struct qdisc_size_table *stab;
+	__u32 qlen;
+
+	cond_resched();
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	tcm = nlmsg_data(nlh);
+	tcm->tcm_family = AF_UNSPEC;
+	tcm->tcm__pad1 = 0;
+	tcm->tcm__pad2 = 0;
+	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
+	tcm->tcm_parent = clid;
+	tcm->tcm_handle = q->handle;
+	tcm->tcm_info = refcount_read(&q->refcnt);
+	if (nla_put_string(skb, TCA_KIND, q->ops->id))
+		goto nla_put_failure;
+	if (q->ops->dump && q->ops->dump(q, skb) < 0)
+		goto nla_put_failure;
+	qlen = q->q.qlen;
+
+	stab = rtnl_dereference(q->stab);
+	if (stab && qdisc_dump_stab(skb, stab) < 0)
+		goto nla_put_failure;
+
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
+					 NULL, &d, TCA_PAD) < 0)
+		goto nla_put_failure;
+
+	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
+		goto nla_put_failure;
+
+	if (qdisc_is_percpu_stats(q)) {
+		cpu_bstats = q->cpu_bstats;
+		cpu_qstats = q->cpu_qstats;
+	}
+
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(q),
+				  &d, cpu_bstats, &q->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
+	    gnet_stats_copy_queue(&d, cpu_qstats, &q->qstats, qlen) < 0)
+		goto nla_put_failure;
+
+	if (gnet_stats_finish_copy(&d) < 0)
+		goto nla_put_failure;
+
+	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	return skb->len;
+
+out_nlmsg_trim:
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static bool tc_qdisc_dump_ignore(struct Qdisc *q, bool dump_invisible)
+{
+	if (q->flags & TCQ_F_BUILTIN)
+		return true;
+	if ((q->flags & TCQ_F_INVISIBLE) && !dump_invisible)
+		return true;
+
+	return false;
+}
+
+static int qdisc_notify(struct net *net, struct sk_buff *oskb,
+			struct nlmsghdr *n, u32 clid,
+			struct Qdisc *old, struct Qdisc *new)
+{
+	struct sk_buff *skb;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	if (old && !tc_qdisc_dump_ignore(old, false)) {
+		if (tc_fill_qdisc(skb, old, clid, portid, n->nlmsg_seq,
+				  0, RTM_DELQDISC) < 0)
+			goto err_out;
+	}
+	if (new && !tc_qdisc_dump_ignore(new, false)) {
+		if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
+				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
+			goto err_out;
+	}
+
+	if (skb->len)
+		return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+				      n->nlmsg_flags & NLM_F_ECHO);
+
+err_out:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 static void notify_and_destroy(struct net *net, struct sk_buff *skb,
 			       struct nlmsghdr *n, u32 clid,
 			       struct Qdisc *old, struct Qdisc *new)
@@ -1342,111 +1440,6 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n,
 	return 0;
 }
 
-static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
-			 u32 portid, u32 seq, u16 flags, int event)
-{
-	struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
-	struct gnet_stats_queue __percpu *cpu_qstats = NULL;
-	struct tcmsg *tcm;
-	struct nlmsghdr  *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct gnet_dump d;
-	struct qdisc_size_table *stab;
-	__u32 qlen;
-
-	cond_resched();
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
-	if (!nlh)
-		goto out_nlmsg_trim;
-	tcm = nlmsg_data(nlh);
-	tcm->tcm_family = AF_UNSPEC;
-	tcm->tcm__pad1 = 0;
-	tcm->tcm__pad2 = 0;
-	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
-	tcm->tcm_parent = clid;
-	tcm->tcm_handle = q->handle;
-	tcm->tcm_info = refcount_read(&q->refcnt);
-	if (nla_put_string(skb, TCA_KIND, q->ops->id))
-		goto nla_put_failure;
-	if (q->ops->dump && q->ops->dump(q, skb) < 0)
-		goto nla_put_failure;
-	qlen = q->q.qlen;
-
-	stab = rtnl_dereference(q->stab);
-	if (stab && qdisc_dump_stab(skb, stab) < 0)
-		goto nla_put_failure;
-
-	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 NULL, &d, TCA_PAD) < 0)
-		goto nla_put_failure;
-
-	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
-		goto nla_put_failure;
-
-	if (qdisc_is_percpu_stats(q)) {
-		cpu_bstats = q->cpu_bstats;
-		cpu_qstats = q->cpu_qstats;
-	}
-
-	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(q),
-				  &d, cpu_bstats, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, cpu_qstats, &q->qstats, qlen) < 0)
-		goto nla_put_failure;
-
-	if (gnet_stats_finish_copy(&d) < 0)
-		goto nla_put_failure;
-
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
-
-out_nlmsg_trim:
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
-static bool tc_qdisc_dump_ignore(struct Qdisc *q, bool dump_invisible)
-{
-	if (q->flags & TCQ_F_BUILTIN)
-		return true;
-	if ((q->flags & TCQ_F_INVISIBLE) && !dump_invisible)
-		return true;
-
-	return false;
-}
-
-static int qdisc_notify(struct net *net, struct sk_buff *oskb,
-			struct nlmsghdr *n, u32 clid,
-			struct Qdisc *old, struct Qdisc *new)
-{
-	struct sk_buff *skb;
-	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
-
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb)
-		return -ENOBUFS;
-
-	if (old && !tc_qdisc_dump_ignore(old, false)) {
-		if (tc_fill_qdisc(skb, old, clid, portid, n->nlmsg_seq,
-				  0, RTM_DELQDISC) < 0)
-			goto err_out;
-	}
-	if (new && !tc_qdisc_dump_ignore(new, false)) {
-		if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
-				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
-			goto err_out;
-	}
-
-	if (skb->len)
-		return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
-				      n->nlmsg_flags & NLM_F_ECHO);
-
-err_out:
-	kfree_skb(skb);
-	return -EINVAL;
-}
-
 static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			      struct netlink_callback *cb,
 			      int *q_idx_p, int s_q_idx, bool recur,
@@ -1559,7 +1552,71 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
  *	Traffic classes manipulation.		*
  ************************************************/
 
+static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
+			  unsigned long cl,
+			  u32 portid, u32 seq, u16 flags, int event)
+{
+	struct tcmsg *tcm;
+	struct nlmsghdr  *nlh;
+	unsigned char *b = skb_tail_pointer(skb);
+	struct gnet_dump d;
+	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
+	cond_resched();
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	tcm = nlmsg_data(nlh);
+	tcm->tcm_family = AF_UNSPEC;
+	tcm->tcm__pad1 = 0;
+	tcm->tcm__pad2 = 0;
+	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
+	tcm->tcm_parent = q->handle;
+	tcm->tcm_handle = q->handle;
+	tcm->tcm_info = 0;
+	if (nla_put_string(skb, TCA_KIND, q->ops->id))
+		goto nla_put_failure;
+	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
+		goto nla_put_failure;
+
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
+					 NULL, &d, TCA_PAD) < 0)
+		goto nla_put_failure;
+
+	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
+		goto nla_put_failure;
+
+	if (gnet_stats_finish_copy(&d) < 0)
+		goto nla_put_failure;
+
+	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	return skb->len;
+
+out_nlmsg_trim:
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int tclass_notify(struct net *net, struct sk_buff *oskb,
+			 struct nlmsghdr *n, struct Qdisc *q,
+			 unsigned long cl, int event)
+{
+	struct sk_buff *skb;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	if (tc_fill_tclass(skb, q, cl, portid, n->nlmsg_seq, 0, event) < 0) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+			      n->nlmsg_flags & NLM_F_ECHO);
+}
 
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
@@ -1695,73 +1752,6 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 	return err;
 }
 
-
-static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
-			  unsigned long cl,
-			  u32 portid, u32 seq, u16 flags, int event)
-{
-	struct tcmsg *tcm;
-	struct nlmsghdr  *nlh;
-	unsigned char *b = skb_tail_pointer(skb);
-	struct gnet_dump d;
-	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
-
-	cond_resched();
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
-	if (!nlh)
-		goto out_nlmsg_trim;
-	tcm = nlmsg_data(nlh);
-	tcm->tcm_family = AF_UNSPEC;
-	tcm->tcm__pad1 = 0;
-	tcm->tcm__pad2 = 0;
-	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
-	tcm->tcm_parent = q->handle;
-	tcm->tcm_handle = q->handle;
-	tcm->tcm_info = 0;
-	if (nla_put_string(skb, TCA_KIND, q->ops->id))
-		goto nla_put_failure;
-	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
-		goto nla_put_failure;
-
-	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 NULL, &d, TCA_PAD) < 0)
-		goto nla_put_failure;
-
-	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
-		goto nla_put_failure;
-
-	if (gnet_stats_finish_copy(&d) < 0)
-		goto nla_put_failure;
-
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	return skb->len;
-
-out_nlmsg_trim:
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-
-static int tclass_notify(struct net *net, struct sk_buff *oskb,
-			 struct nlmsghdr *n, struct Qdisc *q,
-			 unsigned long cl, int event)
-{
-	struct sk_buff *skb;
-	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
-
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb)
-		return -ENOBUFS;
-
-	if (tc_fill_tclass(skb, q, cl, portid, n->nlmsg_seq, 0, event) < 0) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-
-	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
-			      n->nlmsg_flags & NLM_F_ECHO);
-}
-
 struct qdisc_dump_args {
 	struct qdisc_walker	w;
 	struct sk_buff		*skb;
-- 
2.13.0
