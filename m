From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/04]: sch_sfq: make internal queues visible as classes
Date: Thu, 31 Jan 2008 18:58:06 +0100 (MET)
Message-ID: <20080131175802.25151.33423.sendpatchset@localhost.localdomain>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55150 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760029AbYAaR6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:58:07 -0500
In-Reply-To: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: sch_sfq: make internal queues visible as classes

Add support for dumping statistics and make internal queues visible
as classes.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7a281f8ef334a35d699682315e9f80a3e006376c
tree 0a2cbd55e22f1913e9cf0cc28da2956952110243
parent 6049892cc4acca9af393e134e4cdaf6b3e1ccad9
author Patrick McHardy <kaber@trash.net> Wed, 30 Jan 2008 21:59:29 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 18:52:56 +0100

 include/linux/pkt_sched.h |    5 +++++
 net/sched/sch_sfq.c       |   41 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 3276135..dbb7ac3 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -150,6 +150,11 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+struct tc_sfq_xstats
+{
+	__s32		allot;
+};
+
 /*
  *  NOTE: limit, divisor and flows are hardwired to code at the moment.
  *
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d818d19..a20e2ef 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -566,15 +566,54 @@ static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
 	return &q->filter_list;
 }
 
+static int sfq_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	return 0;
+}
+
+static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+				struct gnet_dump *d)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_index idx = q->ht[cl-1];
+	struct gnet_stats_queue qs = { .qlen = q->qs[idx].qlen };
+	struct tc_sfq_xstats xstats = { .allot = q->allot[idx] };
+
+	if (gnet_stats_copy_queue(d, &qs) < 0)
+		return -1;
+	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
+}
+
 static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	return;
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	unsigned int i;
+
+	if (arg->stop)
+		return;
+
+	for (i = 0; i < SFQ_HASH_DIVISOR; i++) {
+		if (q->ht[i] == SFQ_DEPTH ||
+		    arg->count < arg->skip) {
+			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, i + 1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
 }
 
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
 	.change		=	sfq_change_class,
 	.tcf_chain	=	sfq_find_tcf,
+	.dump		=	sfq_dump_class,
+	.dump_stats	=	sfq_dump_class_stats,
 	.walk		=	sfq_walk,
 };
 
