From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/7] net_sched: add struct net pointer to tcf_proto_ops->dump
Date: Thu,  9 Jan 2014 16:14:01 -0800
Message-ID: <1389312845-10304-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:52248 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbaAJAOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:40 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so3703799pbc.38
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:39 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be needed by the next patch.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  2 +-
 net/sched/cls_api.c       | 11 ++++++-----
 net/sched/cls_basic.c     |  2 +-
 net/sched/cls_bpf.c       |  2 +-
 net/sched/cls_cgroup.c    |  2 +-
 net/sched/cls_flow.c      |  2 +-
 net/sched/cls_fw.c        |  2 +-
 net/sched/cls_route.c     |  2 +-
 net/sched/cls_rsvp.h      |  2 +-
 net/sched/cls_tcindex.c   |  2 +-
 net/sched/cls_u32.c       |  2 +-
 11 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 013d96d..d062f81 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -204,7 +204,7 @@ struct tcf_proto_ops {
 	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
 
 	/* rtnetlink specific */
-	int			(*dump)(struct tcf_proto*, unsigned long,
+	int			(*dump)(struct net*, struct tcf_proto*, unsigned long,
 					struct sk_buff *skb, struct tcmsg*);
 
 	struct module		*owner;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d8c42b1..29a30a1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -340,7 +340,7 @@ errout:
 	return err;
 }
 
-static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
+static int tcf_fill_node(struct net *net, struct sk_buff *skb, struct tcf_proto *tp,
 			 unsigned long fh, u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
@@ -362,7 +362,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
-		if (tp->ops->dump && tp->ops->dump(tp, fh, skb, tcm) < 0)
+		if (tp->ops->dump && tp->ops->dump(net, tp, fh, skb, tcm) < 0)
 			goto nla_put_failure;
 	}
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
@@ -385,7 +385,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(skb, tp, fh, portid, n->nlmsg_seq, 0, event) <= 0) {
+	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq, 0, event) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -404,8 +404,9 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 			 struct tcf_walker *arg)
 {
 	struct tcf_dump_args *a = (void *)arg;
+	struct net *net = sock_net(a->skb->sk);
 
-	return tcf_fill_node(a->skb, tp, n, NETLINK_CB(a->cb->skb).portid,
+	return tcf_fill_node(net, a->skb, tp, n, NETLINK_CB(a->cb->skb).portid,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
 }
 
@@ -463,7 +464,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
-			if (tcf_fill_node(skb, tp, 0, NETLINK_CB(cb->skb).portid,
+			if (tcf_fill_node(net, skb, tp, 0, NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
 				break;
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index b655203..af6bea1 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -241,7 +241,7 @@ skip:
 	}
 }
 
-static int basic_dump(struct tcf_proto *tp, unsigned long fh,
+static int basic_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		      struct sk_buff *skb, struct tcmsg *t)
 {
 	struct basic_filter *f = (struct basic_filter *) fh;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 00a5a58..8e3cf49 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -295,7 +295,7 @@ errout:
 	return ret;
 }
 
-static int cls_bpf_dump(struct tcf_proto *tp, unsigned long fh,
+static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			struct sk_buff *skb, struct tcmsg *tm)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8349fcd..8e2158a 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -164,7 +164,7 @@ skip:
 	arg->count++;
 }
 
-static int cls_cgroup_dump(struct tcf_proto *tp, unsigned long fh,
+static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct cls_cgroup_head *head = tp->root;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index dfd18a5..257029c 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -563,7 +563,7 @@ static void flow_put(struct tcf_proto *tp, unsigned long f)
 {
 }
 
-static int flow_dump(struct tcf_proto *tp, unsigned long fh,
+static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct flow_filter *f = (struct flow_filter *)fh;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 3f9cece..d605285 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -324,7 +324,7 @@ static void fw_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int fw_dump(struct tcf_proto *tp, unsigned long fh,
+static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct fw_head *head = (struct fw_head *)tp->root;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 2473953..c913613 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -551,7 +551,7 @@ static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int route4_dump(struct tcf_proto *tp, unsigned long fh,
+static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		       struct sk_buff *skb, struct tcmsg *t)
 {
 	struct route4_filter *f = (struct route4_filter *)fh;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 4f25c2a..19f8e5d 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -594,7 +594,7 @@ static void rsvp_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
+static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct rsvp_filter *f = (struct rsvp_filter *)fh;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index ffad187..f575353 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -422,7 +422,7 @@ static void tcindex_destroy(struct tcf_proto *tp)
 }
 
 
-static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
+static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tcindex_data *p = PRIV(tp);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 20f2fb7..e25411a 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -712,7 +712,7 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	}
 }
 
-static int u32_dump(struct tcf_proto *tp, unsigned long fh,
+static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tc_u_knode *n = (struct tc_u_knode *)fh;
-- 
1.8.3.1
