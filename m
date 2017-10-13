From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 9/9] net: sched: propagate q and parent from caller down to tcf_fill_node
Date: Fri, 13 Oct 2017 14:01:05 +0200
Message-ID: <20171013120105.23358-10-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37683 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758070AbdJMMBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:16 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so5588327wmr.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:16 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The callers have this info, they will pass it down to tcf_fill_node.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 55 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 856003c..2e8e87f 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -420,8 +420,8 @@ static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
 }
 
 static int tcf_fill_node(struct net *net, struct sk_buff *skb,
-			 struct tcf_proto *tp, void *fh, u32 portid,
-			 u32 seq, u16 flags, int event)
+			 struct tcf_proto *tp, struct Qdisc *q, u32 parent,
+			 void *fh, u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -434,8 +434,8 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad2 = 0;
-	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
-	tcm->tcm_parent = tp->classid;
+	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
+	tcm->tcm_parent = parent;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
 	if (nla_put_string(skb, TCA_KIND, tp->ops->kind))
 		goto nla_put_failure;
@@ -458,6 +458,7 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
+			  struct Qdisc *q, u32 parent,
 			  void *fh, int event, bool unicast)
 {
 	struct sk_buff *skb;
@@ -467,7 +468,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+	if (tcf_fill_node(net, skb, tp, q, parent, fh, portid, n->nlmsg_seq,
 			  n->nlmsg_flags, event) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -482,6 +483,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 
 static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 			      struct nlmsghdr *n, struct tcf_proto *tp,
+			      struct Qdisc *q, u32 parent,
 			      void *fh, bool unicast, bool *last)
 {
 	struct sk_buff *skb;
@@ -492,7 +494,7 @@ static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+	if (tcf_fill_node(net, skb, tp, q, parent, fh, portid, n->nlmsg_seq,
 			  n->nlmsg_flags, RTM_DELTFILTER) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -512,6 +514,7 @@ static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 }
 
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
+				 struct Qdisc *q, u32 parent,
 				 struct nlmsghdr *n,
 				 struct tcf_chain *chain, int event)
 {
@@ -519,7 +522,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 
 	for (tp = rtnl_dereference(chain->filter_chain);
 	     tp; tp = rtnl_dereference(tp->next))
-		tfilter_notify(net, oskb, n, tp, 0, event, false);
+		tfilter_notify(net, oskb, n, tp, q, parent, 0, event, false);
 }
 
 /* Add/change/delete/get a filter node */
@@ -638,7 +641,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	}
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
-		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
+		tfilter_notify_chain(net, skb, q, parent, n,
+				     chain, RTM_DELTFILTER);
 		tcf_chain_flush(chain);
 		err = 0;
 		goto errout;
@@ -685,7 +689,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (!fh) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
 			tcf_chain_tp_remove(chain, &chain_info, tp);
-			tfilter_notify(net, skb, n, tp, fh,
+			tfilter_notify(net, skb, n, tp, q, parent, fh,
 				       RTM_DELTFILTER, false);
 			tcf_proto_destroy(tp);
 			err = 0;
@@ -710,8 +714,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			}
 			break;
 		case RTM_DELTFILTER:
-			err = tfilter_del_notify(net, skb, n, tp, fh, false,
-						 &last);
+			err = tfilter_del_notify(net, skb, n, tp, q, parent,
+						 fh, false, &last);
 			if (err)
 				goto errout;
 			if (last) {
@@ -720,7 +724,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			}
 			goto errout;
 		case RTM_GETTFILTER:
-			err = tfilter_notify(net, skb, n, tp, fh,
+			err = tfilter_notify(net, skb, n, tp, q, parent, fh,
 					     RTM_NEWTFILTER, true);
 			goto errout;
 		default:
@@ -734,7 +738,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (err == 0) {
 		if (tp_created)
 			tcf_chain_tp_insert(chain, &chain_info, tp);
-		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
+		tfilter_notify(net, skb, n, tp, q, parent, fh,
+			       RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
 			tcf_proto_destroy(tp);
@@ -753,6 +758,8 @@ struct tcf_dump_args {
 	struct tcf_walker w;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
+	struct Qdisc *q;
+	u32 parent;
 };
 
 static int tcf_node_dump(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
@@ -760,13 +767,14 @@ static int tcf_node_dump(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
 	struct tcf_dump_args *a = (void *)arg;
 	struct net *net = sock_net(a->skb->sk);
 
-	return tcf_fill_node(net, a->skb, tp, n, NETLINK_CB(a->cb->skb).portid,
+	return tcf_fill_node(net, a->skb, tp, a->q, a->parent,
+			     n, NETLINK_CB(a->cb->skb).portid,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI,
 			     RTM_NEWTFILTER);
 }
 
-static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
-			   struct netlink_callback *cb,
+static bool tcf_chain_dump(struct tcf_chain *chain, struct Qdisc *q, u32 parent,
+			   struct sk_buff *skb, struct netlink_callback *cb,
 			   long index_start, long *p_index)
 {
 	struct net *net = sock_net(skb->sk);
@@ -788,7 +796,7 @@ static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 			memset(&cb->args[1], 0,
 			       sizeof(cb->args) - sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
-			if (tcf_fill_node(net, skb, tp, 0,
+			if (tcf_fill_node(net, skb, tp, q, parent, 0,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
@@ -801,6 +809,8 @@ static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 		arg.w.fn = tcf_node_dump;
 		arg.skb = skb;
 		arg.cb = cb;
+		arg.q = q;
+		arg.parent = parent;
 		arg.w.stop = 0;
 		arg.w.skip = cb->args[1] - 1;
 		arg.w.count = 0;
@@ -826,6 +836,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	long index_start;
 	long index;
+	u32 parent;
 	int err;
 
 	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
@@ -839,10 +850,13 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if (!dev)
 		return skb->len;
 
-	if (!tcm->tcm_parent)
+	parent = tcm->tcm_parent;
+	if (!parent) {
 		q = dev->qdisc;
-	else
+		parent = q->handle;
+	} else {
 		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
+	}
 	if (!q)
 		goto out;
 	cops = q->ops->cl_ops;
@@ -866,7 +880,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		if (tca[TCA_CHAIN] &&
 		    nla_get_u32(tca[TCA_CHAIN]) != chain->index)
 			continue;
-		if (!tcf_chain_dump(chain, skb, cb, index_start, &index))
+		if (!tcf_chain_dump(chain, q, parent, skb, cb,
+				    index_start, &index))
 			break;
 	}
 
-- 
2.9.5
