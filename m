From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 03/10] net: sched: provide per cpu qstat helpers
Date: Wed, 13 Jul 2016 23:20:49 -0700
Message-ID: <20160714062049.8270.67051.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34274 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbcGNGVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:21:12 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so4129853pac.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:21:12 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The per cpu qstats support was added with per cpu bstat support which
is currently used by the ingress qdisc. This patch adds a set of
helpers needed to make other qdiscs that use qstats per cpu as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 354951d..f69da4b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -573,12 +573,43 @@ static inline void qdisc_qstats_backlog_dec(struct Qdisc *sch,
 	sch->qstats.backlog -= qdisc_pkt_len(skb);
 }
 
+static inline void qdisc_qstats_cpu_backlog_dec(struct Qdisc *sch,
+						const struct sk_buff *skb)
+{
+	struct gnet_stats_queue *q = this_cpu_ptr(sch->cpu_qstats);
+
+	q->backlog -= qdisc_pkt_len(skb);
+}
+
 static inline void qdisc_qstats_backlog_inc(struct Qdisc *sch,
 					    const struct sk_buff *skb)
 {
 	sch->qstats.backlog += qdisc_pkt_len(skb);
 }
 
+static inline void qdisc_qstats_cpu_backlog_inc(struct Qdisc *sch,
+						const struct sk_buff *skb)
+{
+	struct gnet_stats_queue *q = this_cpu_ptr(sch->cpu_qstats);
+
+	q->backlog += qdisc_pkt_len(skb);
+}
+
+static inline void qdisc_qstats_cpu_qlen_inc(struct Qdisc *sch)
+{
+	this_cpu_ptr(sch->cpu_qstats)->qlen++;
+}
+
+static inline void qdisc_qstats_cpu_qlen_dec(struct Qdisc *sch)
+{
+	this_cpu_ptr(sch->cpu_qstats)->qlen--;
+}
+
+static inline void qdisc_qstats_cpu_requeues_inc(struct Qdisc *sch)
+{
+	this_cpu_ptr(sch->cpu_qstats)->requeues++;
+}
+
 static inline void __qdisc_qstats_drop(struct Qdisc *sch, int count)
 {
 	sch->qstats.drops += count;
@@ -751,6 +782,14 @@ static inline void rtnl_qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 	qdisc_qstats_drop(sch);
 }
 
+static inline int qdisc_drop_cpu(struct sk_buff *skb, struct Qdisc *sch,
+				 struct sk_buff **to_free)
+{
+	__qdisc_drop(skb, to_free);
+	qdisc_qstats_cpu_drop(sch);
+
+	return NET_XMIT_DROP;
+}
 
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch,
 			     struct sk_buff **to_free)
