From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/7] net_sched: act: clean up notification functions
Date: Thu,  9 Jan 2014 16:14:00 -0800
Message-ID: <1389312845-10304-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:52713 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbaAJAOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:38 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so3814082pdj.22
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:38 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor tcf_add_notify() and factor out tcf_del_notify().

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 95 ++++++++++++++++++++++-------------------------------
 1 file changed, 40 insertions(+), 55 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 74ae3ff..178bf2e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -789,6 +789,33 @@ noflush_out:
 }
 
 static int
+tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
+	       u32 portid)
+{
+	int ret;
+	struct sk_buff *skb;
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, RTM_DELACTION,
+			 0, 1) <= 0) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	/* now do the delete */
+	tcf_action_destroy(actions, 0);
+
+	ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+			     n->nlmsg_flags & NLM_F_ECHO);
+	if (ret > 0)
+		return 0;
+	return ret;
+}
+
+static int
 tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	      u32 portid, int event)
 {
@@ -821,27 +848,9 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	if (event == RTM_GETACTION)
 		ret = act_get_notify(net, portid, n, &actions, event);
 	else { /* delete */
-		struct sk_buff *skb;
-
-		skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-		if (!skb) {
-			ret = -ENOBUFS;
-			goto err;
-		}
-
-		if (tca_get_fill(skb, &actions, portid, n->nlmsg_seq, 0, event,
-				 0, 1) <= 0) {
-			kfree_skb(skb);
-			ret = -EINVAL;
+		ret = tcf_del_notify(net, n, &actions, portid);
+		if (ret)
 			goto err;
-		}
-
-		/* now do the delete */
-		tcf_action_destroy(&actions, 0);
-		ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
-				     n->nlmsg_flags & NLM_F_ECHO);
-		if (ret > 0)
-			return 0;
 		return ret;
 	}
 err:
@@ -849,60 +858,36 @@ err:
 	return ret;
 }
 
-static int tcf_add_notify(struct net *net, struct list_head *actions,
-			  u32 portid, u32 seq, int event, u16 flags)
+static int
+tcf_add_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
+	       u32 portid)
 {
-	struct tcamsg *t;
-	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	struct nlattr *nest;
-	unsigned char *b;
 	int err = 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
 
-	b = skb_tail_pointer(skb);
-
-	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*t), flags);
-	if (!nlh)
-		goto out_kfree_skb;
-	t = nlmsg_data(nlh);
-	t->tca_family = AF_UNSPEC;
-	t->tca__pad1 = 0;
-	t->tca__pad2 = 0;
-
-	nest = nla_nest_start(skb, TCA_ACT_TAB);
-	if (nest == NULL)
-		goto out_kfree_skb;
-
-	if (tcf_action_dump(skb, actions, 0, 0) < 0)
-		goto out_kfree_skb;
-
-	nla_nest_end(skb, nest);
-
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
+	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, n->nlmsg_flags,
+			 RTM_NEWACTION, 0, 0) <= 0) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
 
-	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC, flags & NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+			     n->nlmsg_flags & NLM_F_ECHO);
 	if (err > 0)
 		err = 0;
 	return err;
-
-out_kfree_skb:
-	kfree_skb(skb);
-	return -1;
 }
 
-
 static int
 tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	       u32 portid, int ovr)
 {
 	int ret = 0;
 	LIST_HEAD(actions);
-	u32 seq = n->nlmsg_seq;
 
 	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
 	if (ret)
@@ -911,7 +896,7 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
 	 */
-	ret = tcf_add_notify(net, &actions, portid, seq, RTM_NEWACTION, n->nlmsg_flags);
+	ret = tcf_add_notify(net, n, &actions, portid);
 	cleanup_a(&actions);
 done:
 	return ret;
-- 
1.8.3.1
