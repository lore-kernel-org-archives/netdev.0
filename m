From: "Beshay, Joseph" <jdb109120@utdallas.edu>
Subject: [PATCH] netem:  Fixes byte backlog accounting for the first of two
 chained netem instances
Date: Fri, 3 Apr 2015 21:52:01 +0000
Message-ID: <DM2PR01MB511AE74EFA517D7A30CD41DD1F10@DM2PR01MB511.prod.exchangelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netem@lists.linux-foundation.org" <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing.utdallas.edu ([129.110.182.14]:19263 "EHLO
	ip-relay-051.utdallas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbDCWC4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 18:02:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes byte backlog accounting for the first of two chained netem instances.
Bytes backlog reported now corresponds to the number of queued packets.

When two netem instances are chained, for instance to apply rate and queue
limitation followed by packet delay, the number of backlogged bytes reported
by the first netem instance is wrong. It reports the sum of bytes in the queues
of the first and second netem. The first netem reports the correct number of
backlogged packets but not bytes. This is shown in the example below.

Consider a chain of two netem schedulers created using the following commands:

$ tc -s qdisc replace dev veth2 root handle 1:0 netem rate 10000kbit limit 100
$ tc -s qdisc add dev veth2 parent 1:0 handle 2: netem delay 50ms

Start an iperf session to send packets out on the specified interface and
monitor the backlog using tc:

$ tc -s qdisc show dev veth2

Output using unpatched netem:
	qdisc netem 1: root refcnt 2 limit 100 rate 10000Kbit
	 Sent 98422639 bytes 65434 pkt (dropped 123, overlimits 0 requeues 0)
	 backlog 172694b 73p requeues 0
	qdisc netem 2: parent 1: limit 1000 delay 50.0ms
	 Sent 98422639 bytes 65434 pkt (dropped 0, overlimits 0 requeues 0)
	 backlog 63588b 42p requeues 0
	 
The interface used to produce this output has an MTU of 1500. The output for
backlogged bytes behind netem 1 is 172694b. This value is not correct. Consider
the total number of sent bytes and packets. By dividing the number of sent
bytes by the number of sent packets, we get an average packet size of ~=1504.
If we divide the number of backlogged bytes by packets, we get ~=2365. This is
due to the first netem incorrectly counting the 63588b which are in netem 2's
queue as being in its own queue. To verify this is the case, we subtract them
from the reported value and divide by the number of packets as follows: 
	172694 - 63588 = 109106 bytes actualled backlogged in netem 1
	109106 / 73 packets ~= 1494 bytes (which matches our MTU)
	
The root cause is that the byte accounting is not done at the
same time with packet accounting. The solution is to update the backlog value
every time the packet queue is updated.

Signed-off-by: Joseph D Beshay <joseph.beshay@utdallas.edu>
---
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 179f1c8..3a5e883 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -560,8 +560,9 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 tfifo_dequeue:
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
+		/* jbeshay: update byte backlog */
+		qdisc_qstats_backlog_dec(sch, skb);
 deliver:
-		qdisc_qstats_backlog_dec(sch, skb);
 		qdisc_unthrottled(sch);
 		qdisc_bstats_update(sch, skb);
 		return skb;
@@ -578,6 +579,8 @@ deliver:
 			rb_erase(p, &q->t_root);
 
 			sch->q.qlen--;
+			/* jbeshay: update byte backlog */
+			qdisc_qstats_backlog_dec(sch, skb);
 			skb->next = NULL;
 			skb->prev = NULL;
 			skb->tstamp = netem_skb_cb(skb)->tstamp_save;

Signed-off-by: Joseph D Beshay <joseph.beshay@utdallas.edu>
