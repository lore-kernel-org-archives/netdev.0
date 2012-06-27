From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/18] pkt_sched: cls_api: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:51 -0700 (PDT)
Message-ID: <20120626.220251.1940322678100637602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:52 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8BD1E584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too, as well as remove
a useless cast.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/cls_api.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index f452f69..6dd1131 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -140,7 +140,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	int tp_created = 0;
 
 replay:
-	t = NLMSG_DATA(n);
+	t = nlmsg_data(n);
 	protocol = TC_H_MIN(t->tcm_info);
 	prio = TC_H_MAJ(t->tcm_info);
 	nprio = prio;
@@ -349,8 +349,10 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
-	tcm = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	tcm = nlmsg_data(nlh);
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad2 = 0;
@@ -368,7 +370,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nlmsg_failure:
+out_nlmsg_trim:
 nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
@@ -418,7 +420,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	struct Qdisc *q;
 	struct tcf_proto *tp, **chain;
-	struct tcmsg *tcm = (struct tcmsg *)NLMSG_DATA(cb->nlh);
+	struct tcmsg *tcm = nlmsg_data(cb->nlh);
 	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
-- 
1.7.10.2
