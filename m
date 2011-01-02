From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] net_sched: mark packet staying on queue too long
Date: Sun, 02 Jan 2011 22:27:11 +0100
Message-ID: <1294003631.2535.253.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca, Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62581 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab1ABV1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 16:27:20 -0500
Received: by wyb28 with SMTP id 28so12900696wyb.19
        for <netdev@vger.kernel.org>; Sun, 02 Jan 2011 13:27:19 -0800 (PST)
In-Reply-To: <1293111333.11306.170.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing with SFQ and other AQM, I was bothered to see how easy it
was for a single tcp flow to 'fill the pipe' and consume lot of memory
buffers in queues. I know Jesper use more than 50.000 SFQ on his
routers, and with GRO packets this can consume a lot of memory.

I played a bit adding ECN in SFQ, first by marking packets for a
particular flow if this flow qlen was above a given threshold, and later
using another trick : ECN mark packet if it stayed longer than a given
delay in the queue. This of course could be done on other modules, what
do you think ?

The idea is to take into account the time packet stayed in the queue,
regardless of other class parameters.

Following quick and dirty patch to show the idea. Of course, the delay
should be configured on each SFQ/RED/XXXX class, so it would need an
iproute2 patch, and the delay unit should be "ms" (or even "us"), not
ticks, but as I said this is a quick and dirty patch (net-next-2.6
based)

Using jiffies allows only delays above 3 or 4 ticks...

Or maybe ECN is just a dream :(

 include/net/sch_generic.h |    1 +
 net/sched/sch_sfq.c       |   11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0af57eb..1a7ac68 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -198,6 +198,7 @@ struct tcf_proto {
 };
 
 struct qdisc_skb_cb {
+	unsigned long		timestamp;
 	unsigned int		pkt_len;
 	char			data[];
 };
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d54ac94..baf9465 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -24,6 +24,8 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <linux/moduleparam.h>
 
 
 /*	Stochastic Fairness Queuing algorithm.
@@ -86,6 +88,10 @@
 /* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
 typedef unsigned char sfq_index;
 
+static int ecn_delay; /* default : no ECN handling */
+module_param(ecn_delay, int, 0);
+MODULE_PARM_DESC(ecn_delay, "mark packets if they stay in queue longer than ecn_delay ticks");
+
 /*
  * We dont use pointers to save space.
  * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] array
@@ -391,6 +397,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	sch->qstats.backlog += qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
+	qdisc_skb_cb(skb)->timestamp = jiffies;
 	sfq_inc(q, x);
 	if (slot->qlen == 1) {		/* The flow is new */
 		if (q->tail == NULL) {	/* It is the first flow */
@@ -460,6 +467,10 @@ next_slot:
 		q->tail->next = next_a;
 	} else {
 		slot->allot -= SFQ_ALLOT_SIZE(qdisc_pkt_len(skb));
+		if (ecn_delay &&
+		    time_after(jiffies, qdisc_skb_cb(skb)->timestamp + ecn_delay) &&
+		    INET_ECN_set_ce(skb))
+			sch->qstats.overlimits++;
 	}
 	return skb;
 }


