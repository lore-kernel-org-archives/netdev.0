From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 11/17] net: sched: helper to sum qlen
Date: Tue, 02 May 2017 08:39:37 -0700
Message-ID: <20170502153937.9304.35438.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36667 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdEBPjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:39:49 -0400
Received: by mail-pg0-f66.google.com with SMTP id v1so23024090pgv.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:39:49 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting qlen when qlen is per cpu requires aggregating the per
cpu counters. This adds a helper routine for this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   15 +++++++++++++++
 net/sched/sch_api.c       |    3 ++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4c446fe..5ae07dd 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -270,6 +270,21 @@ static inline int qdisc_qlen(const struct Qdisc *q)
 	return q->q.qlen;
 }
 
+static inline int qdisc_qlen_sum(const struct Qdisc *q)
+{
+	__u32 qlen = 0;
+	int i;
+
+	if (q->flags & TCQ_F_NOLOCK) {
+		for_each_possible_cpu(i)
+			qlen += per_cpu_ptr(q->cpu_qstats, i)->qlen;
+	} else {
+		qlen = q->q.qlen;
+	}
+
+	return qlen;
+}
+
 static inline struct qdisc_skb_cb *qdisc_skb_cb(const struct sk_buff *skb)
 {
 	return (struct qdisc_skb_cb *)skb->cb;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bbe57d5..1bb9c89 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1378,7 +1378,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
-	qlen = q->q.qlen;
+
+	qlen = qdisc_qlen_sum(q);
 
 	stab = rtnl_dereference(q->stab);
 	if (stab && qdisc_dump_stab(skb, stab) < 0)
