From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/18] pkt_sched: sch_api: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:54 -0700 (PDT)
Message-ID: <20120626.220254.2153171862575376971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5B073584194
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too, as well as remove
a useless cast.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 085ce53..a08b4ab 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -973,7 +973,7 @@ check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w)
 static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-	struct tcmsg *tcm = NLMSG_DATA(n);
+	struct tcmsg *tcm = nlmsg_data(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	u32 clid = tcm->tcm_parent;
@@ -1046,7 +1046,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 replay:
 	/* Reinit, just in case something touches this. */
-	tcm = NLMSG_DATA(n);
+	tcm = nlmsg_data(n);
 	clid = tcm->tcm_parent;
 	q = p = NULL;
 
@@ -1193,8 +1193,10 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
-	tcm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	tcm = nlmsg_data(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad2 = 0;
@@ -1230,7 +1232,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
+out_nlmsg_trim:
 nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -1366,7 +1368,7 @@ done:
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-	struct tcmsg *tcm = NLMSG_DATA(n);
+	struct tcmsg *tcm = nlmsg_data(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	struct Qdisc *q = NULL;
@@ -1498,8 +1500,10 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	struct gnet_dump d;
 	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
-	tcm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	tcm = nlmsg_data(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad2 = 0;
@@ -1525,7 +1529,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
+out_nlmsg_trim:
 nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -1616,7 +1620,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct tcmsg *tcm = (struct tcmsg *)NLMSG_DATA(cb->nlh);
+	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	struct net *net = sock_net(skb->sk);
 	struct netdev_queue *dev_queue;
 	struct net_device *dev;
-- 
1.7.10.2
