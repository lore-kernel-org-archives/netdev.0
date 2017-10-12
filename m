From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/34] net: core: use dev->ingress_queue instead of tp->q
Date: Thu, 12 Oct 2017 19:17:55 +0200
Message-ID: <20171012171823.1431-7-jiri@resnulli.us>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33668 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753194AbdJLRSb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so4372645wmu.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:31 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In sch_handle_egress and sch_handle_ingress, don't use tp->q and use
dev->ingress_queue which stores the same pointer instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/dev.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fcddccb..cb9e5e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3273,14 +3273,18 @@ EXPORT_SYMBOL(dev_loopback_xmit);
 static struct sk_buff *
 sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 {
+	struct netdev_queue *netdev_queue =
+				rcu_dereference_bh(dev->ingress_queue);
 	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
 	struct tcf_result cl_res;
+	struct Qdisc *q;
 
-	if (!cl)
+	if (!cl || !netdev_queue)
 		return skb;
+	q = netdev_queue->qdisc;
 
 	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
-	qdisc_bstats_cpu_update(cl->q, skb);
+	qdisc_bstats_cpu_update(q, skb);
 
 	switch (tcf_classify(skb, cl, &cl_res, false)) {
 	case TC_ACT_OK:
@@ -3288,7 +3292,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		qdisc_qstats_cpu_drop(q);
 		*ret = NET_XMIT_DROP;
 		kfree_skb(skb);
 		return NULL;
@@ -4188,16 +4192,21 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		   struct net_device *orig_dev)
 {
 #ifdef CONFIG_NET_CLS_ACT
+	struct netdev_queue *netdev_queue =
+				rcu_dereference_bh(skb->dev->ingress_queue);
 	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
 	struct tcf_result cl_res;
+	struct Qdisc *q;
 
 	/* If there's at least one ingress present somewhere (so
 	 * we get here via enabled static key), remaining devices
 	 * that are not configured with an ingress qdisc will bail
 	 * out here.
 	 */
-	if (!cl)
+	if (!cl || !netdev_queue)
 		return skb;
+	q = netdev_queue->qdisc;
+
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
@@ -4205,7 +4214,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	skb->tc_at_ingress = 1;
-	qdisc_bstats_cpu_update(cl->q, skb);
+	qdisc_bstats_cpu_update(q, skb);
 
 	switch (tcf_classify(skb, cl, &cl_res, false)) {
 	case TC_ACT_OK:
@@ -4213,7 +4222,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		skb->tc_index = TC_H_MIN(cl_res.classid);
 		break;
 	case TC_ACT_SHOT:
-		qdisc_qstats_cpu_drop(cl->q);
+		qdisc_qstats_cpu_drop(q);
 		kfree_skb(skb);
 		return NULL;
 	case TC_ACT_STOLEN:
-- 
2.9.5
