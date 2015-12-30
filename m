From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 07/12] net: sched: qdisc_qlen for per cpu logic
Date: Wed, 30 Dec 2015 09:53:35 -0800
Message-ID: <20151230175335.26257.34457.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36042 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbbL3Rxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:53:52 -0500
Received: by mail-pa0-f43.google.com with SMTP id yy13so48727028pab.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:53:52 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
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
index aa39dd4..30f4c60 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -273,8 +273,16 @@ static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
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
 
