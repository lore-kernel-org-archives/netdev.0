From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 10/17] net: sched: qdisc_qlen for per cpu logic
Date: Tue, 02 May 2017 08:27:57 -0700
Message-ID: <20170502152757.8871.6543.stgit@john-Precision-Tower-5810>
References: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36504 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdEBP2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:28:12 -0400
Received: by mail-pf0-f193.google.com with SMTP id v14so33731405pfd.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:28:12 -0700 (PDT)
In-Reply-To: <20170502151445.8871.43089.stgit@john-Precision-Tower-5810>
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
 
