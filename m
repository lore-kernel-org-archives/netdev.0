From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 11:53:44 +0530
Message-ID: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:48529 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZH3GXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 02:23:42 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7U6MYt4031146
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 11:52:35 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7U6NgfE2224178
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 11:53:42 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7U6NgaM023098
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:23:42 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

pfifo_fast_enqueue has this check:
        if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {

which allows each band to enqueue upto tx_queue_len skbs for a
total of 3*tx_queue_len skbs. I am not sure if this was the
intention of limiting in qdisc.

Patch compiled and 32 simultaneous netperf testing ran fine. Also:
# tc -s qdisc show dev eth2
qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 16835026752 bytes 373116 pkt (dropped 0, overlimits 0 requeues 25) 
 rate 0bit 0pps backlog 0b 0p requeues 25 

(I am taking next week off, so sorry for any delay in responding)

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 net/sched/sch_generic.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-08-30 11:18:23.000000000 +0530
+++ new/net/sched/sch_generic.c	2009-08-30 11:21:50.000000000 +0530
@@ -432,11 +432,11 @@ static inline struct sk_buff_head *band2
 
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
-	int band = prio2band[skb->priority & TC_PRIO_MAX];
-	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	struct sk_buff_head *list = band2list(priv, band);
+	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
+		int band = prio2band[skb->priority & TC_PRIO_MAX];
+		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+		struct sk_buff_head *list = band2list(priv, band);
 
-	if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
 		priv->bitmap |= (1 << band);
 		qdisc->q.qlen++;
 		return __qdisc_enqueue_tail(skb, qdisc, list);
