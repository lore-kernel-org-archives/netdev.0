From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] sched: move err set right before goto errout in tc_ctl_tfilter
Date: Thu,  9 Feb 2017 14:38:58 +0100
Message-ID: <1486647540-14656-5-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35820 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdBINr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:47:58 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so12011910wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:47:13 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This makes the reader to know right away what is the error value.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d378a0b..f44378c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -293,9 +293,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 	/* And the last stroke */
 	chain = cops->tcf_chain(q, cl);
-	err = -EINVAL;
-	if (chain == NULL)
+	if (chain == NULL) {
+		err = -EINVAL;
 		goto errout;
+	}
 	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
 		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
 		tcf_destroy_chain(chain);
@@ -310,8 +311,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		if (tp->prio >= prio) {
 			if (tp->prio == prio) {
 				if (!nprio ||
-				    (tp->protocol != protocol && protocol))
+				    (tp->protocol != protocol && protocol)) {
+					err = -EINVAL;
 					goto errout;
+				}
 			} else
 				tp = NULL;
 			break;
@@ -321,13 +324,16 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 	if (tp == NULL) {
 		/* Proto-tcf does not exist, create new one */
 
-		if (tca[TCA_KIND] == NULL || !protocol)
+		if (tca[TCA_KIND] == NULL || !protocol) {
+			err = -EINVAL;
 			goto errout;
+		}
 
-		err = -ENOENT;
 		if (n->nlmsg_type != RTM_NEWTFILTER ||
-		    !(n->nlmsg_flags & NLM_F_CREATE))
+		    !(n->nlmsg_flags & NLM_F_CREATE)) {
+			err = -ENOENT;
 			goto errout;
+		}
 
 		if (!nprio)
 			nprio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
@@ -339,8 +345,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			goto errout;
 		}
 		tp_created = 1;
-	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
+	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind)) {
+		err = -EINVAL;
 		goto errout;
+	}
 
 	fh = tp->ops->get(tp, t->tcm_handle);
 
@@ -357,17 +365,18 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			goto errout;
 		}
 
-		err = -ENOENT;
 		if (n->nlmsg_type != RTM_NEWTFILTER ||
-		    !(n->nlmsg_flags & NLM_F_CREATE))
+		    !(n->nlmsg_flags & NLM_F_CREATE)) {
+			err = -ENOENT;
 			goto errout;
+		}
 	} else {
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
-			err = -EEXIST;
 			if (n->nlmsg_flags & NLM_F_EXCL) {
 				if (tp_created)
 					tcf_proto_destroy(tp, true);
+				err = -EEXIST;
 				goto errout;
 			}
 			break;
-- 
2.7.4
