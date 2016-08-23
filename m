From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 11/15] net: sched: helper to sum qlen
Date: Tue, 23 Aug 2016 13:27:22 -0700
Message-ID: <20160823202722.14368.9949.stgit@john-Precision-Tower-5810>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36824 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755846AbcHWU1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:27:40 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so8794476pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:27:40 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
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
index 1e8e0ad..12df73d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -271,6 +271,21 @@ static inline int qdisc_qlen(const struct Qdisc *q)
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
