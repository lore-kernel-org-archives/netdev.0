From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/34] net: sched: propagate q and parent from caller down to tcf_fill_node
Date: Thu, 12 Oct 2017 19:18:00 +0200
Message-ID: <20171012171823.1431-12-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37749 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753560AbdJLRSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id r68so4346532wmr.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:35 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The callers have this info, they will pass it down to tcf_fill_node.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 55 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index b1bcc8b..908b38a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -585,8 +585,8 @@ static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
 }
 
 static int tcf_fill_node(struct net *net, struct sk_buff *skb,
-			 struct tcf_proto *tp, void *fh, u32 portid,
-			 u32 seq, u16 flags, int event)
+			 struct tcf_proto *tp, struct Qdisc *q, u32 parent,
+			 void *fh, u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -599,8 +599,8 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
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
@@ -623,6 +623,7 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
+			  struct Qdisc *q, u32 parent,
 			  void *fh, int event, bool unicast)
 {
 	struct sk_buff *skb;
@@ -632,7 +633,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+	if (tcf_fill_node(net, skb, tp, q, parent, fh, portid, n->nlmsg_seq,
 			  n->nlmsg_flags, event) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -647,6 +648,7 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 
 static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 			      struct nlmsghdr *n, struct tcf_proto *tp,
+			      struct Qdisc *q, u32 parent,
 			      void *fh, bool unicast, bool *last)
 {
 	struct sk_buff *skb;
@@ -657,7 +659,7 @@ static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+	if (tcf_fill_node(net, skb, tp, q, parent, fh, portid, n->nlmsg_seq,
 			  n->nlmsg_flags, RTM_DELTFILTER) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -677,6 +679,7 @@ static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
 }
 
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
+				 struct Qdisc *q, u32 parent,
 				 struct nlmsghdr *n,
 				 struct tcf_chain *chain, int event)
 {
@@ -684,7 +687,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 
 	for (tp = rtnl_dereference(chain->filter_chain);
 	     tp; tp = rtnl_dereference(tp->next))
-		tfilter_notify(net, oskb, n, tp, 0, event, false);
+		tfilter_notify(net, oskb, n, tp, q, parent, 0, event, false);
 }
 
 /* Add/change/delete/get a filter node */
@@ -803,7 +806,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	}
 
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
-		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
+		tfilter_notify_chain(net, skb, q, parent, n,
+				     chain, RTM_DELTFILTER);
 		tcf_chain_flush(chain);
 		err = 0;
 		goto errout;
@@ -850,7 +854,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (!fh) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
 			tcf_chain_tp_remove(chain, &chain_info, tp);
-			tfilter_notify(net, skb, n, tp, fh,
+			tfilter_notify(net, skb, n, tp, q, parent, fh,
 				       RTM_DELTFILTER, false);
 			tcf_proto_destroy(tp);
 			err = 0;
@@ -875,8 +879,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
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
@@ -885,7 +889,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			}
 			goto errout;
 		case RTM_GETTFILTER:
-			err = tfilter_notify(net, skb, n, tp, fh,
+			err = tfilter_notify(net, skb, n, tp, q, parent, fh,
 					     RTM_NEWTFILTER, true);
 			goto errout;
 		default:
@@ -899,7 +903,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 	if (err == 0) {
 		if (tp_created)
 			tcf_chain_tp_insert(chain, &chain_info, tp);
-		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
+		tfilter_notify(net, skb, n, tp, q, parent, fh,
+			       RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
 			tcf_proto_destroy(tp);
@@ -918,6 +923,8 @@ struct tcf_dump_args {
 	struct tcf_walker w;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
+	struct Qdisc *q;
+	u32 parent;
 };
 
 static int tcf_node_dump(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
@@ -925,13 +932,14 @@ static int tcf_node_dump(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
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
@@ -953,7 +961,7 @@ static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 			memset(&cb->args[1], 0,
 			       sizeof(cb->args) - sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
-			if (tcf_fill_node(net, skb, tp, 0,
+			if (tcf_fill_node(net, skb, tp, q, parent, 0,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
@@ -966,6 +974,8 @@ static bool tcf_chain_dump(struct tcf_chain *chain, struct sk_buff *skb,
 		arg.w.fn = tcf_node_dump;
 		arg.skb = skb;
 		arg.cb = cb;
+		arg.q = q;
+		arg.parent = parent;
 		arg.w.stop = 0;
 		arg.w.skip = cb->args[1] - 1;
 		arg.w.count = 0;
@@ -991,6 +1001,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	long index_start;
 	long index;
+	u32 parent;
 	int err;
 
 	if (nlmsg_len(cb->nlh) < sizeof(*tcm))
@@ -1004,10 +1015,13 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
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
@@ -1031,7 +1045,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
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
