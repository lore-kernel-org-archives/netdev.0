From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: pfifo_head_drop problem
Date: Wed, 05 Jan 2011 21:35:02 +0100
Message-ID: <1294259702.2723.22.camel@edumazet-laptop>
References: <1294246850.2775.244.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39930 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab1AEUfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 15:35:48 -0500
Received: by wyb28 with SMTP id 28so15736978wyb.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 12:35:46 -0800 (PST)
In-Reply-To: <1294246850.2775.244.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 57dbb2d83d100ea (sched: add head drop fifo queue)
introduced pfifo_head_drop, and broke the invariant that
sch->bstats.bytes and sch->bstats.packets are COUNTER (increasing
counters only)

This can break estimators because est_timer() handles unsigned deltas
only. A decreasing counter can then give a huge unsigned delta.

My mid term suggestion would be to change things so that
sch->bstats.bytes and sch->bstats.packets are incremented in dequeue()
only, not at enqueue() time. We also could add drop_bytes/drop_packets
and provide estimations of drop rates.

It would be more sensible anyway for very low speeds, and big bursts.
Right now, if we drop packets, they still are accounted in byte/packets
abolute counters and rate estimators.

Before this mid term change, this patch makes pfifo_head_drop behavior
similar to other qdiscs in case of drops :
Dont decrement sch->bstats.bytes and sch->bstats.packets

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_fifo.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 4dfecb0..aa4d633 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -54,8 +54,6 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	/* queue full, remove one skb to fulfill the limit */
 	skb_head = qdisc_dequeue_head(sch);
-	sch->bstats.bytes -= qdisc_pkt_len(skb_head);
-	sch->bstats.packets--;
 	sch->qstats.drops++;
 	kfree_skb(skb_head);
 


