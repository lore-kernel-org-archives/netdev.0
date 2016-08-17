From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 02/13] net: sched: qdisc_qlen for per cpu logic
Date: Wed, 17 Aug 2016 12:34:16 -0700
Message-ID: <20160817193416.27032.62729.stgit@john-Precision-Tower-5810>
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
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34080 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbcHQTep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:34:45 -0400
Received: by mail-oi0-f67.google.com with SMTP id t127so12986370oie.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:34:33 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
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
 
