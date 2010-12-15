From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 15:03:03 +0100
Message-ID: <1292421783.3427.232.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:42622 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab0LOODI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 09:03:08 -0500
Received: by bwz16 with SMTP id 16so2306326bwz.4
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 06:03:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When deploying SFQ/IFB here at work, I found the allot management was
pretty wrong in sfq, even changing allot from short to int...

We should init allot for each new flow turn, not using a previous value,
or else small packets can easily make allot overflow.

Before patch, I saw burst of several packets per flow, apparently
denying the "allot 1514" limit I had on my SFQ class.

class sfq 11:1 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 7p requeues 0 
 allot 11546 

class sfq 11:46 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot -23873 

class sfq 11:78 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 5p requeues 0 
 allot 11393 

After patch, better fairness among each flow, allot limit being
respected.

class sfq 11:52 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 4p requeues 0 
 allot 1514 

class sfq 11:60 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot -586 

class sfq 11:6b parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot -586 

class sfq 11:71 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 1514 


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..8c8a190 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -270,7 +270,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. */
 		d = q->next[q->tail];
 		q->next[q->tail] = q->next[d];
-		q->allot[q->next[d]] += q->quantum;
+		q->allot[q->next[d]] = q->quantum;
 		skb = q->qs[d].prev;
 		len = qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
@@ -321,14 +321,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
 		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
-			q->tail = x;
 			q->next[x] = x;
-			q->allot[x] = q->quantum;
 		} else {
 			q->next[x] = q->next[q->tail];
 			q->next[q->tail] = x;
-			q->tail = x;
 		}
+		q->tail = x;
+		q->allot[x] = q->quantum;
 	}
 	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -382,11 +381,11 @@ sfq_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 		q->next[q->tail] = a;
-		q->allot[a] += q->quantum;
+		q->allot[a] = q->quantum;
 	} else if ((q->allot[a] -= qdisc_pkt_len(skb)) <= 0) {
 		q->tail = a;
 		a = q->next[a];
-		q->allot[a] += q->quantum;
+		q->allot[a] = q->quantum;
 	}
 	return skb;
 }


