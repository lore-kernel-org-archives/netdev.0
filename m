From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_hfsc: report backlog information
Date: Fri, 23 Dec 2011 16:19:20 +0100
Message-ID: <1324653560.2223.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49456 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab1LWPTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 10:19:24 -0500
Received: by wibhm6 with SMTP id hm6so3224769wib.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 07:19:22 -0800 (PST)
In-Reply-To: <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add backlog (byte count) information in hfsc classes and qdisc, so that
"tc -s" can report it to user, instead of 0 values :

qdisc hfsc 1: root refcnt 6 default 20 
 Sent 45141660 bytes 30545 pkt (dropped 0, overlimits 91751 requeues 0) 
 rate 1492Kbit 126pps backlog 103226b 74p requeues 0 
...
class hfsc 1:20 parent 1:1 leaf 1201: rt m1 0bit d 0us m2 400000bit ls m1 0bit d 0us m2 200000bit 
 Sent 49534912 bytes 33519 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 81822b 56p requeues 0 
 period 23 work 49451576 bytes rtwork 13277552 bytes level 0 
...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: John A. Sullivan III <jsullivan@opensourcedevel.com>
---
 net/sched/sch_hfsc.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6488e64..9bdca2e 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1368,6 +1368,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct tc_hfsc_stats xstats;
 
 	cl->qstats.qlen = cl->qdisc->q.qlen;
+	cl->qstats.backlog = cl->qdisc->qstats.backlog;
 	xstats.level   = cl->level;
 	xstats.period  = cl->cl_vtperiod;
 	xstats.work    = cl->cl_total;
@@ -1561,6 +1562,15 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	struct hfsc_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_hfsc_qopt qopt;
+	struct hfsc_class *cl;
+	struct hlist_node *n;
+	unsigned int i;
+
+	sch->qstats.backlog = 0;
+	for (i = 0; i < q->clhash.hashsize; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash.hash[i], cl_common.hnode)
+			sch->qstats.backlog += cl->qdisc->qstats.backlog;
+	}
 
 	qopt.defcls = q->defcls;
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
