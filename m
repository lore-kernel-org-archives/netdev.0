From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 02/10] net: sched: qdisc_qlen for per cpu logic
Date: Wed, 13 Jul 2016 23:20:20 -0700
Message-ID: <20160714062019.8270.432.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35014 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcGNGUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:20:43 -0400
Received: by mail-pa0-f66.google.com with SMTP id dx3so4148652pab.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:20:42 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a bit interesting because it means sch_direct_xmit will
return a positive value which causes the dequeue/xmit cycle to
continue only when a specific cpu has a qlen > 0.

However checking each cpu for qlen will break performance so
its important to note that qdiscs that set the no lock bit need
to have some sort of per cpu enqueue/dequeue data structure that
maps to the per cpu qlen value.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3de6a8c..354951d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -247,8 +247,16 @@ static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
 	BUILD_BUG_ON(sizeof(qcb->data) < sz);
 }
 
+static inline int qdisc_qlen_cpu(const struct Qdisc *q)
+{
+	return this_cpu_ptr(q->cpu_qstats)->qlen;
+}
+
 static inline int qdisc_qlen(const struct Qdisc *q)
 {
+	if (q->flags & TCQ_F_NOLOCK)
+		return qdisc_qlen_cpu(q);
+
 	return q->q.qlen;
 }
 
