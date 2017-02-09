From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] sched: check negative err value to safe one level of indent
Date: Thu,  9 Feb 2017 14:39:00 +0100
Message-ID: <1486647540-14656-7-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35838 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdBINr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:47:58 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so12012071wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:47:16 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As it is more common, check err for !0. That allows to safe one level of
indentation and makes the code easier to read. Also, make 'next' variable
global in function as it is used twice.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 48864ad..abe1fe1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -214,6 +214,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 	struct Qdisc  *q;
 	struct tcf_proto __rcu **back;
 	struct tcf_proto __rcu **chain;
+	struct tcf_proto *next;
 	struct tcf_proto *tp;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
@@ -355,10 +356,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			struct tcf_proto *next = rtnl_dereference(tp->next);
-
+			next = rtnl_dereference(tp->next);
 			RCU_INIT_POINTER(*back, next);
-
 			tfilter_notify(net, skb, n, tp, fh,
 				       RTM_DELTFILTER, false);
 			tcf_proto_destroy(tp, true);
@@ -383,16 +382,13 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			break;
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
-			if (err == 0) {
-				struct tcf_proto *next = rtnl_dereference(tp->next);
-
-				tfilter_notify(net, skb, n, tp,
-					       t->tcm_handle,
-					       RTM_DELTFILTER, false);
-				if (tcf_proto_destroy(tp, false))
-					RCU_INIT_POINTER(*back, next);
-			}
-			goto errout;
+			if (err)
+				goto errout;
+			next = rtnl_dereference(tp->next);
+			tfilter_notify(net, skb, n, tp, t->tcm_handle,
+				       RTM_DELTFILTER, false);
+			if (tcf_proto_destroy(tp, false))
+				RCU_INIT_POINTER(*back, next);
 		case RTM_GETTFILTER:
 			err = tfilter_notify(net, skb, n, tp, fh,
 					     RTM_NEWTFILTER, true);
-- 
2.7.4
