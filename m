From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 04/15] net: sched: provide per cpu qstat helpers
Date: Tue, 23 Aug 2016 13:24:12 -0700
Message-ID: <20160823202412.14368.48361.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36799 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755611AbcHWUYj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:24:39 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so10423579pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:24:39 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
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
index 3de6a8c..f1b8268 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -565,12 +565,43 @@ static inline void qdisc_qstats_backlog_dec(struct Qdisc *sch,
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
@@ -743,6 +774,14 @@ static inline void rtnl_qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
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
