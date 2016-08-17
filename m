From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 09/13] net: sched: helper to sum qlen
Date: Wed, 17 Aug 2016 12:37:14 -0700
Message-ID: <20160817193714.27032.47575.stgit@john-Precision-Tower-5810>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32826 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582AbcHQThc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:37:32 -0400
Received: by mail-oi0-f65.google.com with SMTP id s207so13013425oie.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:37:32 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
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
index d465fb9..cc28af0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -280,6 +280,21 @@ static inline int qdisc_qlen(const struct Qdisc *q)
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
index b90a23a..6c5bf13 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1370,7 +1370,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
-	qlen = q->q.qlen;
+
+	qlen = qdisc_qlen_sum(q);
 
 	stab = rtnl_dereference(q->stab);
 	if (stab && qdisc_dump_stab(skb, stab) < 0)
