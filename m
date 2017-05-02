From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/17] net: sched: provide per cpu qstat helpers
Date: Tue, 02 May 2017 08:26:06 -0700
Message-ID: <20170502152606.8871.69610.stgit@john-Precision-Tower-5810>
References: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36121 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdEBP0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:26:21 -0400
Received: by mail-pf0-f194.google.com with SMTP id v14so33723925pfd.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:26:21 -0700 (PDT)
In-Reply-To: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The per cpu qstats support was added with per cpu bstat support which
is currently used by the ingress qdisc. This patch adds a set of
helpers needed to make other qdiscs that use qstats per cpu as well.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f5c8613..9531b81 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -590,12 +590,39 @@ static inline void qdisc_qstats_backlog_dec(struct Qdisc *sch,
 	sch->qstats.backlog -= qdisc_pkt_len(skb);
 }
 
+static inline void qdisc_qstats_cpu_backlog_dec(struct Qdisc *sch,
+						const struct sk_buff *skb)
+{
+	this_cpu_sub(sch->cpu_qstats->backlog, qdisc_pkt_len(skb));
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
+	this_cpu_add(sch->cpu_qstats->backlog, qdisc_pkt_len(skb));
+}
+
+static inline void qdisc_qstats_cpu_qlen_inc(struct Qdisc *sch)
+{
+	this_cpu_inc(sch->cpu_qstats->qlen);
+}
+
+static inline void qdisc_qstats_cpu_qlen_dec(struct Qdisc *sch)
+{
+	this_cpu_dec(sch->cpu_qstats->qlen);
+}
+
+static inline void qdisc_qstats_cpu_requeues_inc(struct Qdisc *sch)
+{
+	this_cpu_inc(sch->cpu_qstats->requeues);
+}
+
 static inline void __qdisc_qstats_drop(struct Qdisc *sch, int count)
 {
 	sch->qstats.drops += count;
@@ -800,6 +827,14 @@ static inline void rtnl_qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
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
