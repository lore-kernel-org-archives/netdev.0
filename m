From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 04/13] net: sched: provide atomic qlen helpers for
 bypass case
Date: Wed, 17 Aug 2016 12:35:03 -0700
Message-ID: <20160817193503.27032.61305.stgit@john-Precision-Tower-5810>
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
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36206 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbcHQTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:35:45 -0400
Received: by mail-oi0-f66.google.com with SMTP id b22so12987571oii.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:35:20 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qlen is used by the core/dev.c to determine if a packet
can skip the qdisc on qdiscs with bypass enabled. In these
cases a per cpu qlen value can cause one cpu to bypass a
qdisc that has packets in it.

To avoid this case use the simplest solution I could come
up with for now and add an atomic qlen value to the qdisc
to use in these cases.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f69da4b..193cf8c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -78,6 +78,7 @@ struct Qdisc {
 	 */
 	struct sk_buff		*gso_skb ____cacheline_aligned_in_smp;
 	struct sk_buff_head	q;
+	atomic_t		qlen_atomic;
 	struct gnet_stats_basic_packed bstats;
 	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
@@ -247,6 +248,11 @@ static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
 	BUILD_BUG_ON(sizeof(qcb->data) < sz);
 }
 
+static inline int qdisc_qlen_atomic(const struct Qdisc *q)
+{
+	return atomic_read(&q->qlen_atomic);
+}
+
 static inline int qdisc_qlen_cpu(const struct Qdisc *q)
 {
 	return this_cpu_ptr(q->cpu_qstats)->qlen;
@@ -254,8 +260,11 @@ static inline int qdisc_qlen_cpu(const struct Qdisc *q)
 
 static inline int qdisc_qlen(const struct Qdisc *q)
 {
+	/* current default is to use atomic ops for qdisc qlen when
+	 * running with TCQ_F_NOLOCK.
+	 */
 	if (q->flags & TCQ_F_NOLOCK)
-		return qdisc_qlen_cpu(q);
+		return qdisc_qlen_atomic(q);
 
 	return q->q.qlen;
 }
@@ -595,6 +604,16 @@ static inline void qdisc_qstats_cpu_backlog_inc(struct Qdisc *sch,
 	q->backlog += qdisc_pkt_len(skb);
 }
 
+static inline void qdisc_qstats_atomic_qlen_inc(struct Qdisc *sch)
+{
+	atomic_inc(&sch->qlen_atomic);
+}
+
+static inline void qdisc_qstats_atomic_qlen_dec(struct Qdisc *sch)
+{
+	atomic_dec(&sch->qlen_atomic);
+}
+
 static inline void qdisc_qstats_cpu_qlen_inc(struct Qdisc *sch)
 {
 	this_cpu_ptr(sch->cpu_qstats)->qlen++;
