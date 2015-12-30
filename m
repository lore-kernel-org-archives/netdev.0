From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 10/12] net: sched: helper to sum qlen
Date: Wed, 30 Dec 2015 09:54:44 -0800
Message-ID: <20151230175444.26257.92434.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35557 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135AbbL3RzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:55:03 -0500
Received: by mail-pa0-f46.google.com with SMTP id do7so123537pab.2
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:55:03 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting qlen when qlen is per cpu requires aggregating the per
cpu counters. This adds a helper routine for this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 30f4c60..2c57278 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -286,6 +286,21 @@ static inline int qdisc_qlen(const struct Qdisc *q)
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
