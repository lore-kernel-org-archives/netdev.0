From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: fix pfifo_head_drop behavior vs backlog
Date: Sun, 12 Jun 2016 20:01:25 -0700
Message-ID: <1465786885.7945.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33338 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933130AbcFMDBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 23:01:30 -0400
Received: by mail-it0-f67.google.com with SMTP id i6so5710575ith.0
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 20:01:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When the qdisc is full, we drop a packet at the head of the queue,
queue the current skb and return NET_XMIT_CN

Now we track backlog on upper qdiscs, we need to call
qdisc_tree_reduce_backlog(), even if the qlen did not change.

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_fifo.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2177eac0a61e..2e4bd2c0a50c 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -37,14 +37,18 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
+	unsigned int prev_backlog;
+
 	if (likely(skb_queue_len(&sch->q) < sch->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
+	prev_backlog = sch->qstats.backlog;
 	/* queue full, remove one skb to fulfill the limit */
 	__qdisc_queue_drop_head(sch, &sch->q);
 	qdisc_qstats_drop(sch);
 	qdisc_enqueue_tail(skb, sch);
 
+	qdisc_tree_reduce_backlog(sch, 0, prev_backlog - sch->qstats.backlog);
 	return NET_XMIT_CN;
 }
 
