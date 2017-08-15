From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched/sfq: update hierarchical backlog when drop packet
Date: Tue, 15 Aug 2017 16:37:04 +0300
Message-ID: <150280422406.717624.15125218636935056461.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:39137 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752038AbdHONnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:43:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sfq_enqueue() drops head packet or packet from another queue it
have to update backlog at upper qdiscs too.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
---
 net/sched/sch_sfq.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f80ea2cc5f1f..82469ef9655e 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -437,6 +437,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 		qdisc_drop(head, sch, to_free);
 
 		slot_queue_add(slot, skb);
+		qdisc_tree_reduce_backlog(sch, 0, delta);
 		return NET_XMIT_CN;
 	}
 
@@ -468,8 +469,10 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
 	/* Return Congestion Notification only if we dropped a packet
 	 * from this flow.
 	 */
-	if (qlen != slot->qlen)
+	if (qlen != slot->qlen) {
+		qdisc_tree_reduce_backlog(sch, 0, dropped - qdisc_pkt_len(skb));
 		return NET_XMIT_CN;
+	}
 
 	/* As we dropped a packet, better let upper stack know this */
 	qdisc_tree_reduce_backlog(sch, 1, dropped);
