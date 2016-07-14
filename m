From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 09/10] net: sched: helper to sum qlen
Date: Wed, 13 Jul 2016 23:23:38 -0700
Message-ID: <20160714062338.8270.69636.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36250 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbcGNGXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:23:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so722721pab.3
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:23:54 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting qlen when qlen is per cpu requires aggregating the per
cpu counters. This adds a helper routine for this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 149f079..d370fee 100644
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
