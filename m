From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/2] net_sched: refactor notification code for RTM_DELTFILTER
Date: Fri,  4 Aug 2017 21:31:42 -0700
Message-ID: <20170805043143.13680-2-xiyou.wangcong@gmail.com>
References: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, jiri@resnulli.us,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37321 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdHEEby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 00:31:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id p13so3553164pfd.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 21:31:53 -0700 (PDT)
In-Reply-To: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is confusing to use 'unsigned long fh' as both a handle
and a pointer, especially commit 9ee7837449b3
("net sched filters: fix notification of filter delete with proper handle").

This patch introduces tfilter_del_notify() so that we can
pass it as a pointer as before, and we don't need to check
RTM_DELTFILTER in tcf_fill_node() any more.

This prepares for the next patch.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 44 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 39 insertions(+), 5 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e655221c654e..afd099727aea 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -104,6 +104,10 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
 			  unsigned long fh, int event, bool unicast);
 
+static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
+			      struct nlmsghdr *n, struct tcf_proto *tp,
+			      unsigned long fh, bool unicast, bool *last);
+
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 				 struct nlmsghdr *n,
 				 struct tcf_chain *chain, int event)
@@ -595,11 +599,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
 			}
 			break;
 		case RTM_DELTFILTER:
-			err = tp->ops->delete(tp, fh, &last);
+			err = tfilter_del_notify(net, skb, n, tp, fh, false,
+						 &last);
 			if (err)
 				goto errout;
-			tfilter_notify(net, skb, n, tp, t->tcm_handle,
-				       RTM_DELTFILTER, false);
 			if (last) {
 				tcf_chain_tp_remove(chain, &chain_info, tp);
 				tcf_proto_destroy(tp);
@@ -659,9 +662,9 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
 		goto nla_put_failure;
 	if (nla_put_u32(skb, TCA_CHAIN, tp->chain->index))
 		goto nla_put_failure;
-	tcm->tcm_handle = fh;
-	if (RTM_DELTFILTER != event) {
+	if (!fh) {
 		tcm->tcm_handle = 0;
+	} else {
 		if (tp->ops->dump && tp->ops->dump(net, tp, fh, skb, tcm) < 0)
 			goto nla_put_failure;
 	}
@@ -698,6 +701,37 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
+static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
+			      struct nlmsghdr *n, struct tcf_proto *tp,
+			      unsigned long fh, bool unicast, bool *last)
+{
+	struct sk_buff *skb;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
+	int err;
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	if (tcf_fill_node(net, skb, tp, fh, portid, n->nlmsg_seq,
+			  n->nlmsg_flags, RTM_DELTFILTER) <= 0) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	err = tp->ops->delete(tp, fh, last);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	if (unicast)
+		return netlink_unicast(net->rtnl, skb, portid, MSG_DONTWAIT);
+
+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+			      n->nlmsg_flags & NLM_F_ECHO);
+}
+
 struct tcf_dump_args {
 	struct tcf_walker w;
 	struct sk_buff *skb;
-- 
2.13.0
