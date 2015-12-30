From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/12] net: sched: provide per cpu qstat helpers
Date: Wed, 30 Dec 2015 09:52:27 -0800
Message-ID: <20151230175227.26257.577.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32898 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbbL3Rwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:52:44 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so108819343pfb.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:52:44 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The per cpu qstats support was added with per cpu bstat support
which is currently used by the ingress qdisc. This patch adds
a set of helpers needed to make other qdiscs that use qstats
per cpu as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c8d42c3..9966c17 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -545,12 +545,43 @@ static inline void qdisc_qstats_backlog_dec(struct Qdisc *sch,
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
@@ -726,6 +757,14 @@ static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_DROP;
 }
 
+static inline int qdisc_drop_cpu(struct sk_buff *skb, struct Qdisc *sch)
+{
+	kfree_skb(skb);
+	qdisc_qstats_cpu_drop(sch);
+
+	return NET_XMIT_DROP;
+}
+
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_qstats_drop(sch);
