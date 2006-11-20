From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 07/06]: Fix endless loops (part 5): netem/tbf/hfsc ->requeue
 failures
Date: Mon, 20 Nov 2006 16:01:03 +0100
Message-ID: <4561C32F.7000702@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000203050906090108060206"
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60550 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S934216AbWKTPBI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 10:01:08 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000203050906090108060206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

I forgot to fix one (AFAICT purely theoretical) case ..


--------------000203050906090108060206
Content-Type: text/plain;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

[NET_SCHED]: Fix endless loops (part 5): netem/tbf/hfsc ->requeue failures

When peeking at the next packet in a child qdisc by calling dequeue/requeue,
the upper qdisc qlen counter may get out of sync in case the requeue fails.
The qdisc and the child qdisc both have their counter decremented, but since
no packet is given to the upper qdisc it won't decrement its counter itself.

requeue should not fail, so this is mostly for "correctness".

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 929cc41d7993cf356bcf1693c924e016df55a6a9
tree 8d0017e51e6285b4d584864e564e4d4512463b99
parent cc6f4de81d666f76192bee629473ff6fbd66286c
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 15:59:14 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 15:59:14 +0100

 net/sched/sch_hfsc.c  |    1 +
 net/sched/sch_netem.c |    5 +----
 net/sched/sch_tbf.c   |    2 +-
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 2d43744..6eefa69 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -946,6 +946,7 @@ qdisc_peek_len(struct Qdisc *sch)
 	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: failed to requeue\n");
+		qdisc_tree_decrease_qlen(sch, 1);
 		return 0;
 	}
 	return len;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 672c354..79542af 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -287,13 +287,10 @@ static struct sk_buff *netem_dequeue(str
 			psched_tdiff_t delay = PSCHED_TDIFF(cb->time_to_send, now);
 
 			if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+				qdisc_tree_decrease_qlen(q->qdisc, 1);
 				sch->qstats.drops++;
-
-				/* After this qlen is confused */
 				printk(KERN_ERR "netem: queue discpline %s could not requeue\n",
 				       q->qdisc->ops->id);
-
-				sch->q.qlen--;
 			}
 
 			mod_timer(&q->timer, jiffies + PSCHED_US2JIFFIE(delay));
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 23b7624..ed9b6d9 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -250,7 +250,7 @@ static struct sk_buff *tbf_dequeue(struc
 
 		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
 			/* When requeue fails skb is dropped */
-			sch->q.qlen--;
+			qdisc_tree_decrease_qlen(q->qdisc, 1);
 			sch->qstats.drops++;
 		}
 

--------------000203050906090108060206--
