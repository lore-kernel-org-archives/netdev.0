From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/14]: pkt_sched: Make classifier filter dumping
 multiqueue aware.
Date: Mon, 14 Jul 2008 16:00:26 -0700 (PDT)
Message-ID: <20080714.160026.75040785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758548AbYGNXA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:26 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DADEFC8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/cls_api.c |   77 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d50c3b6..e2d8be4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -557,50 +557,41 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
 }
 
-static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
+static int tc_dump_filter_queue(struct sk_buff *skb, struct netlink_callback *cb,
+				struct tcmsg *tcm, struct netdev_queue *dev_queue,
+				int t)
 {
-	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
-	int t;
-	int s_t;
-	struct net_device *dev;
-	struct Qdisc *q;
-	struct tcf_proto *tp, **chain;
-	struct tcmsg *tcm = (struct tcmsg *)NLMSG_DATA(cb->nlh);
-	unsigned long cl = 0;
 	const struct Qdisc_class_ops *cops;
+	struct tcf_proto *tp, **chain;
 	struct tcf_dump_args arg;
+	unsigned long cl = 0;
+	struct Qdisc *q;
+	int s_t;
 
-	if (net != &init_net)
-		return 0;
-
-	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
-		return skb->len;
-	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
-		return skb->len;
-
-	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (!tcm->tcm_parent)
 		q = dev_queue->qdisc_sleeping;
 	else
 		q = qdisc_lookup(dev_queue, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
-		goto out;
-	if ((cops = q->ops->cl_ops) == NULL)
-		goto errout;
+		return t;
+
+	cops = q->ops->cl_ops;
+	if (!cops)
+		return t;
+
 	if (TC_H_MIN(tcm->tcm_parent)) {
 		cl = cops->get(q, tcm->tcm_parent);
-		if (cl == 0)
-			goto errout;
+		if (!cl)
+			return t;
 	}
 	chain = cops->tcf_chain(q, cl);
 	if (chain == NULL)
-		goto errout;
+		goto out_put_cl;
 
 	s_t = cb->args[0];
-
-	for (tp=*chain, t=0; tp; tp = tp->next, t++) {
-		if (t < s_t) continue;
+	for (tp = *chain; tp; tp = tp->next, t++) {
+		if (t < s_t)
+			continue;
 		if (TC_H_MAJ(tcm->tcm_info) &&
 		    TC_H_MAJ(tcm->tcm_info) != tp->prio)
 			continue;
@@ -633,10 +624,36 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	cb->args[0] = t;
 
-errout:
+out_put_cl:
 	if (cl)
 		cops->put(q, cl);
-out:
+
+	return t;
+}
+
+static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct tcmsg *tcm = NLMSG_DATA(cb->nlh);
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	unsigned int i;
+	int t;
+
+	if (net != &init_net)
+		return 0;
+
+	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
+		return skb->len;
+	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+		return skb->len;
+
+	t = 0;
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, i);
+
+		t = tc_dump_filter_queue(skb, cb, tcm, dev_queue, t);
+	}
+
 	dev_put(dev);
 	return skb->len;
 }
-- 
1.5.6.2.255.gbed62

