From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] qdisc: add tracepoint qdisc:qdisc_dequeue for dequeued SKBs
Date: Tue, 15 Aug 2017 21:11:03 +0200
Message-ID: <150282426296.20350.8045788556432194444.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pstaszewski@itcare.pl, Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752457AbdHOTLI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 15:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main purpose of this tracepoint is to monitor bulk dequeue
in the network qdisc layer, as it cannot be deducted from the
existing qdisc stats.

The txq_state can be used for determining the reason for zero packet
dequeues, see enum netdev_queue_state_t.

Notice all packets doesn't necessary activate this tracepoint. As
qdiscs with flag TCQ_F_CAN_BYPASS, can directly invoke
sch_direct_xmit() when qdisc_qlen is zero.

Remember that perf record supports filters like:

 perf record -e qdisc:qdisc_dequeue \
  --filter 'ifindex == 4 && (packets > 1 || txq_state > 0)'

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/qdisc.h |   50 ++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c        |    1 +
 net/sched/sch_generic.c      |    8 +++++--
 3 files changed, 57 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/events/qdisc.h

diff --git a/include/trace/events/qdisc.h b/include/trace/events/qdisc.h
new file mode 100644
index 000000000000..60d0d8bd336d
--- /dev/null
+++ b/include/trace/events/qdisc.h
@@ -0,0 +1,50 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM qdisc
+
+#if !defined(_TRACE_QDISC_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_QDISC_H_
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/tracepoint.h>
+#include <linux/ftrace.h>
+
+TRACE_EVENT(qdisc_dequeue,
+
+	TP_PROTO(struct Qdisc *qdisc, const struct netdev_queue *txq,
+		 int packets, struct sk_buff *skb),
+
+	TP_ARGS(qdisc, txq, packets, skb),
+
+	TP_STRUCT__entry(
+		__field(	struct Qdisc *,		qdisc	)
+		__field(const	struct netdev_queue *,	txq	)
+		__field(	int,			packets	)
+		__field(	void *,			skbaddr	)
+		__field(	int,			ifindex	)
+		__field(	u32,			handle	)
+		__field(	u32,			parent	)
+		__field(	unsigned long,		txq_state)
+	),
+
+	/* skb==NULL indicate packets dequeued was 0, even when packets==1 */
+	TP_fast_assign(
+		__entry->qdisc		= qdisc;
+		__entry->txq		= txq;
+		__entry->packets	= skb ? packets : 0;
+		__entry->skbaddr	= skb;
+		__entry->ifindex	= txq->dev ? txq->dev->ifindex : 0;
+		__entry->handle		= qdisc->handle;
+		__entry->parent		= qdisc->parent;
+		__entry->txq_state	= txq->state;
+	),
+
+	TP_printk("dequeue ifindex=%d qdisc handle=0x%X parent=0x%X txq_state=0x%lX packets=%d skbaddr=%p",
+		  __entry->ifindex, __entry->handle, __entry->parent,
+		  __entry->txq_state, __entry->packets, __entry->skbaddr )
+);
+
+#endif /* _TRACE_QDISC_H_ */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index 92da5e4ceb4f..4f1468ccd056 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -32,6 +32,7 @@
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
 #include <trace/events/fib.h>
+#include <trace/events/qdisc.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <trace/events/fib6.h>
 EXPORT_TRACEPOINT_SYMBOL_GPL(fib6_table_lookup);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 57ba406f1437..c6b89a34e8d2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -29,6 +29,7 @@
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
+#include <trace/events/qdisc.h>
 
 /* Qdisc to use by default */
 const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
@@ -126,7 +127,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 			q->q.qlen--;
 		} else
 			skb = NULL;
-		return skb;
+		goto trace;
 	}
 	*validate = true;
 	skb = q->skb_bad_txq;
@@ -139,7 +140,8 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 			q->q.qlen--;
 			goto bulk;
 		}
-		return NULL;
+		skb = NULL;
+		goto trace;
 	}
 	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
 	    !netif_xmit_frozen_or_stopped(txq))
@@ -151,6 +153,8 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		else
 			try_bulk_dequeue_skb_slow(q, skb, packets);
 	}
+trace:
+	trace_qdisc_dequeue(q, txq, *packets, skb);
 	return skb;
 }
 
