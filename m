From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] sched: rename tcf_destroy to tcf_destroy_proto
Date: Thu,  9 Feb 2017 14:38:55 +0100
Message-ID: <1486647540-14656-2-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35752 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdBINr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:47:58 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so12011229wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:46:59 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This function destroys TC filter protocol, not TC filter. So name it
accordingly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/sch_generic.h | 2 +-
 net/sched/cls_api.c       | 8 ++++----
 net/sched/sch_api.c       | 4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e2f426f..4533506 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -405,7 +405,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
-bool tcf_destroy(struct tcf_proto *tp, bool force);
+bool tcf_proto_destroy(struct tcf_proto *tp, bool force);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 int skb_do_redirect(struct sk_buff *);
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 1ecdf80..90536eb 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -323,7 +323,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 			tfilter_notify(net, skb, n, tp, fh,
 				       RTM_DELTFILTER, false);
-			tcf_destroy(tp, true);
+			tcf_proto_destroy(tp, true);
 			err = 0;
 			goto errout;
 		}
@@ -338,7 +338,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			err = -EEXIST;
 			if (n->nlmsg_flags & NLM_F_EXCL) {
 				if (tp_created)
-					tcf_destroy(tp, true);
+					tcf_proto_destroy(tp, true);
 				goto errout;
 			}
 			break;
@@ -350,7 +350,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 				tfilter_notify(net, skb, n, tp,
 					       t->tcm_handle,
 					       RTM_DELTFILTER, false);
-				if (tcf_destroy(tp, false))
+				if (tcf_proto_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
 			}
 			goto errout;
@@ -374,7 +374,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
-			tcf_destroy(tp, true);
+			tcf_proto_destroy(tp, true);
 	}
 
 errout:
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ef53ede..f30b517 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1900,7 +1900,7 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 }
 EXPORT_SYMBOL(tc_classify);
 
-bool tcf_destroy(struct tcf_proto *tp, bool force)
+bool tcf_proto_destroy(struct tcf_proto *tp, bool force)
 {
 	if (tp->ops->destroy(tp, force)) {
 		module_put(tp->ops->owner);
@@ -1917,7 +1917,7 @@ void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 
 	while ((tp = rtnl_dereference(*fl)) != NULL) {
 		RCU_INIT_POINTER(*fl, tp->next);
-		tcf_destroy(tp, true);
+		tcf_proto_destroy(tp, true);
 	}
 }
 EXPORT_SYMBOL(tcf_destroy_chain);
-- 
2.7.4
