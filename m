From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/5] bpf: cpumap add tracepoints
Date: Thu, 28 Sep 2017 14:57:23 +0200
Message-ID: <150660344318.2808.10264798458378115347.stgit@firesoul>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40104 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753116AbdI1M5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 08:57:25 -0400
In-Reply-To: <150660339205.2808.7084136789768233829.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds two tracepoint to the cpumap.  One for the enqueue side
trace_xdp_cpumap_enqueue() and one for the kthread dequeue side
trace_xdp_cpumap_kthread().

To mitigate the tracepoint overhead, these are invoked during the
enqueue/dequeue bulking phases, thus amortizing the cost.

The obvious use-cases are for debugging and monitoring.  The
non-intuitive use-case is using these as a feedback loop to know the
system load.  One can imagine auto-scaling by reducing, adding or
activating more worker CPUs on demand.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/trace/events/xdp.h |   70 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/cpumap.c        |   18 +++++++++--
 2 files changed, 85 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/xdp.h b/include/trace/events/xdp.h
index eb2ece96c1a2..bc48c13892c4 100644
--- a/include/trace/events/xdp.h
+++ b/include/trace/events/xdp.h
@@ -150,6 +150,76 @@ DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map_err,
 	 trace_xdp_redirect_map_err(dev, xdp, devmap_ifindex(fwd, map),	\
 				    err, map, idx)
 
+TRACE_EVENT(xdp_cpumap_kthread,
+
+	TP_PROTO(int map_id, unsigned int processed,  unsigned int drops,
+		 int time_limit),
+
+	TP_ARGS(map_id, processed, drops, time_limit),
+
+	TP_STRUCT__entry(
+		__field(int, map_id)
+		__field(u32, act)
+		__field(int, cpu)
+		__field(unsigned int, drops)
+		__field(unsigned int, processed)
+		__field(int, time_limit)
+	),
+
+	TP_fast_assign(
+		__entry->map_id		= map_id;
+		__entry->act		= XDP_REDIRECT;
+		__entry->cpu		= smp_processor_id();
+		__entry->drops		= drops;
+		__entry->processed	= processed;
+		__entry->time_limit	= time_limit;
+	),
+
+	TP_printk("kthread"
+		  " cpu=%d map_id=%d action=%s"
+		  " processed=%u drops=%u"
+		  " time_limit=%d",
+		  __entry->cpu, __entry->map_id,
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->processed, __entry->drops,
+		  __entry->time_limit)
+);
+
+TRACE_EVENT(xdp_cpumap_enqueue,
+
+	TP_PROTO(int map_id, unsigned int processed,  unsigned int drops,
+		 int to_cpu),
+
+	TP_ARGS(map_id, processed, drops, to_cpu),
+
+	TP_STRUCT__entry(
+		__field(int, map_id)
+		__field(u32, act)
+		__field(int, cpu)
+		__field(unsigned int, drops)
+		__field(unsigned int, processed)
+		__field(int, to_cpu)
+	),
+
+	TP_fast_assign(
+		__entry->map_id		= map_id;
+		__entry->act		= XDP_REDIRECT;
+		__entry->cpu		= smp_processor_id();
+		__entry->drops		= drops;
+		__entry->processed	= processed;
+		__entry->to_cpu		= to_cpu;
+	),
+
+	TP_printk("enqueue"
+		  " cpu=%d map_id=%d action=%s"
+		  " processed=%u drops=%u"
+		  " to_cpu=%d",
+		  __entry->cpu, __entry->map_id,
+		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
+		  __entry->processed, __entry->drops,
+		  __entry->to_cpu)
+);
+
 #endif /* _TRACE_XDP_H */
 
 #include <trace/define_trace.h>
diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
index 352cc071c9cc..3b0288e4e998 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -23,6 +23,7 @@
 #include <linux/sched.h>
 #include <linux/workqueue.h>
 #include <linux/kthread.h>
+#include <trace/events/xdp.h>
 
 #include <linux/netdevice.h>   /* netif_receive_skb */
 #include <linux/etherdevice.h> /* eth_type_trans */
@@ -294,6 +295,9 @@ static int cpu_map_kthread_run(void *data)
 			if (++processed == 8)
 				break;
 		}
+		/* Feedback loop via tracepoint */
+		trace_xdp_cpumap_kthread(rcpu->map_id, processed, drops,
+					 time_after_eq(jiffies, time_limit));
 		local_bh_enable();
 
 		__set_current_state(TASK_INTERRUPTIBLE);
@@ -331,7 +335,10 @@ struct bpf_cpu_map_entry *__cpu_map_entry_alloc(u32 qsize, u32 cpu, int map_id)
 	err = ptr_ring_init(rcpu->queue, qsize, gfp);
 	if (err)
 		goto fail;
-	rcpu->qsize = qsize;
+
+	rcpu->cpu    = cpu;
+	rcpu->map_id = map_id;
+	rcpu->qsize  = qsize;
 
 	/* Setup kthread */
 	rcpu->kthread = kthread_create_on_node(cpu_map_kthread_run, rcpu, numa,
@@ -555,6 +562,8 @@ const struct bpf_map_ops cpu_map_ops = {
 static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
 			     struct xdp_bulk_queue *bq)
 {
+	unsigned int processed = 0, drops = 0;
+	const int to_cpu = rcpu->cpu;
 	struct ptr_ring *q;
 	int i;
 
@@ -570,13 +579,16 @@ static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
 
 		err = __ptr_ring_produce(q, xdp_pkt);
 		if (err) {
-			/* Free xdp_pkt */
-			page_frag_free(xdp_pkt);
+			drops++;
+			page_frag_free(xdp_pkt); /* Free xdp_pkt */
 		}
+		processed++;
 	}
 	bq->count = 0;
 	spin_unlock(&q->producer_lock);
 
+	/* Feedback loop via tracepoints */
+	trace_xdp_cpumap_enqueue(rcpu->map_id, processed, drops, to_cpu);
 	return 0;
 }
 
