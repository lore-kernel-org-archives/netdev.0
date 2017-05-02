From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 10/17] net: sched: qdisc_qlen for per cpu logic
Date: Tue, 02 May 2017 08:39:20 -0700
Message-ID: <20170502153920.9304.23941.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33788 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbdEBPjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:39:32 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so11391094pgc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:39:32 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add qdisc qlen helper routines for lockless qdiscs to use.

The qdisc qlen is no longer used in the hotpath but it is reported
via stats query on the qdisc so it still needs to be tracked. This
adds the per cpu operations needed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4288222..4c446fe 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -257,8 +257,16 @@ static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
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
 
