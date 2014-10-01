From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V6 2/2] qdisc: dequeue bulking also pickup GSO/TSO
	packets
Date: Wed, 01 Oct 2014 22:36:09 +0200
Message-ID: <20141001203604.3321.91746.stgit@dragon>
References: <20141001203345.3321.99675.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbaJAUgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 16:36:21 -0400
In-Reply-To: <20141001203345.3321.99675.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TSO and GSO segmented packets already benefit from bulking
on their own.

The TSO packets have always taken advantage of the only updating
the tailptr once for a large packet.

The GSO segmented packets have recently taken advantage of
bulking xmit_more API, via merge commit 53fda7f7f9e8 ("Merge
branch 'xmit_list'"), specifically via commit 7f2e870f2a4 ("net:
Move main gso loop out of dev_hard_start_xmit() into helper.")
allowing qdisc requeue of remaining list.  And via commit
ce93718fb7cd ("net: Don't keep around original SKB when we
software segment GSO frames.").

This patch allow further bulking of TSO/GSO packets together,
when dequeueing from the qdisc.

Testing:
 Measuring HoL (Head-of-Line) blocking for TSO and GSO, with
netperf-wrapper. Bulking several TSO show no performance regressions
(requeues were in the area 32 requeues/sec).

Bulking several GSOs does show small regression or very small
improvement (requeues were in the area 8000 requeues/sec).

 Using ixgbe 10Gbit/s with GSO bulking, we can measure some additional
latency. Base-case, which is "normal" GSO bulking, sees varying
high-prio queue delay between 0.38ms to 0.47ms.  Bulking several GSOs
together, result in a stable high-prio queue delay of 0.50ms.

 Using igb at 100Mbit/s with GSO bulking, shows an improvement.
Base-case sees varying high-prio queue delay between 2.23ms to 2.35ms
diff of 0.12ms corrosponding to 1500 bytes at 100Mbit/s. Bulking
several GSOs together, result in a stable high-prio queue delay of
2.23ms.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---

 net/sched/sch_generic.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c2e87e6..797ebef 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -63,10 +63,6 @@ static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
 	struct sk_buff *skb, *tail_skb = head_skb;
 
 	while (bytelimit > 0) {
-		/* For now, don't bulk dequeue GSO (or GSO segmented) pkts */
-		if (tail_skb->next || skb_is_gso(tail_skb))
-			break;
-
 		skb = q->dequeue(q);
 		if (!skb)
 			break;
@@ -76,11 +72,9 @@ static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
 		if (!skb)
 			break;
 
-		/* "skb" can be a skb list after validate call above
-		 * (GSO segmented), but it is okay to append it to
-		 * current tail_skb->next, because next round will exit
-		 * in-case "tail_skb->next" is a skb list.
-		 */
+		while (tail_skb->next) /* GSO list goto tail */
+			tail_skb = tail_skb->next;
+
 		tail_skb->next = skb;
 		tail_skb = skb;
 	}
