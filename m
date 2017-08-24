From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 2/4] net_sched: introduce tclass_del_notify()
Date: Thu, 24 Aug 2017 16:51:28 -0700
Message-ID: <20170824235130.28503-3-xiyou.wangcong@gmail.com>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35635 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbdHXXv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:51:56 -0400
Received: by mail-pg0-f68.google.com with SMTP id r133so1356248pgr.2
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 16:51:55 -0700 (PDT)
In-Reply-To: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like for TC actions, ->delete() is a special case,
we have to prepare and fill the notification before delete
otherwise would get use-after-free after we remove the
reference count.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c | 39 +++++++++++++++++++++++++++++++++------
 1 file changed, 33 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 330ffaea9974..3ef4eb578739 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1618,6 +1618,38 @@ static int tclass_notify(struct net *net, struct sk_buff *oskb,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
+static int tclass_del_notify(struct net *net,
+			     const struct Qdisc_class_ops *cops,
+			     struct sk_buff *oskb, struct nlmsghdr *n,
+			     struct Qdisc *q, unsigned long cl)
+{
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
+	struct sk_buff *skb;
+	int err = 0;
+
+	if (!cops->delete)
+		return -EOPNOTSUPP;
+
+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb)
+		return -ENOBUFS;
+
+	if (tc_fill_tclass(skb, q, cl, portid, n->nlmsg_seq, 0,
+			   RTM_DELTCLASS) < 0) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
+	err = cops->delete(q, cl);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
+			      n->nlmsg_flags & NLM_F_ECHO);
+}
+
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 			 struct netlink_ext_ack *extack)
 {
@@ -1722,12 +1754,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
 				goto out;
 			break;
 		case RTM_DELTCLASS:
-			err = -EOPNOTSUPP;
-			if (cops->delete)
-				err = cops->delete(q, cl);
-			if (err == 0)
-				tclass_notify(net, skb, n, q, cl,
-					      RTM_DELTCLASS);
+			err = tclass_del_notify(net, cops, skb, n, q, cl);
 			goto out;
 		case RTM_GETTCLASS:
 			err = tclass_notify(net, skb, n, q, cl, RTM_NEWTCLASS);
-- 
2.13.0
