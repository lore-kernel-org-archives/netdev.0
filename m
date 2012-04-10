From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] vhost: basic tracepoints
Date: Tue, 10 Apr 2012 10:58:19 +0800
Message-ID: <20120410025819.49693.32870.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

To help for the performance optimizations and debugging, this patch tracepoints
for vhost. Pay attention that the tracepoints are only for vhost, net code are
not touched.

Two kinds of activities were traced: virtio and vhost work.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/trace.h |  153 +++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.c |   17 +++++
 2 files changed, 168 insertions(+), 2 deletions(-)
 create mode 100644 drivers/vhost/trace.h

diff --git a/drivers/vhost/trace.h b/drivers/vhost/trace.h
new file mode 100644
index 0000000..0423899
--- /dev/null
+++ b/drivers/vhost/trace.h
@@ -0,0 +1,153 @@
+#if !defined(_TRACE_VHOST_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_VHOST_H
+
+#include <linux/tracepoint.h>
+#include "vhost.h"
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM vhost
+
+/*
+ * Tracepoint for updating used flag.
+ */
+TRACE_EVENT(vhost_virtio_update_used_flags,
+	TP_PROTO(struct vhost_virtqueue *vq),
+	TP_ARGS(vq),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_virtqueue *, vq)
+		__field(u16, used_flags)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->used_flags = vq->used_flags;
+	),
+
+	TP_printk("vhost update used flag %x to vq %p notify %s",
+		__entry->used_flags, __entry->vq,
+		(__entry->used_flags & VRING_USED_F_NO_NOTIFY) ?
+		"disabled" : "enabled")
+);
+
+/*
+ * Tracepoint for updating avail event.
+ */
+TRACE_EVENT(vhost_virtio_update_avail_event,
+	TP_PROTO(struct vhost_virtqueue *vq),
+	TP_ARGS(vq),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_virtqueue *, vq)
+		__field(u16, avail_idx)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->avail_idx = vq->avail_idx;
+	),
+
+	TP_printk("vhost update avail idx %u(%u) for vq %p",
+		  __entry->avail_idx, __entry->avail_idx %
+		  __entry->vq->num, __entry->vq)
+);
+
+/*
+ * Tracepoint for processing descriptor.
+ */
+TRACE_EVENT(vhost_virtio_get_vq_desc,
+	TP_PROTO(struct vhost_virtqueue *vq, unsigned int index,
+		 unsigned out, unsigned int in),
+	TP_ARGS(vq, index, out, in),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_virtqueue *, vq)
+		__field(unsigned int, head)
+		__field(unsigned int, out)
+		__field(unsigned int, in)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->head = index;
+		__entry->out = out;
+		__entry->in = in;
+	),
+
+	TP_printk("vhost get vq %p head %u out %u in %u",
+		  __entry->vq, __entry->head, __entry->out, __entry->in)
+
+);
+
+/*
+ * Tracepoint for signal guest.
+ */
+TRACE_EVENT(vhost_virtio_signal,
+	TP_PROTO(struct vhost_virtqueue *vq),
+	TP_ARGS(vq),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_virtqueue *, vq)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+	),
+
+	TP_printk("vhost signal vq %p",	__entry->vq)
+);
+
+DECLARE_EVENT_CLASS(vhost_work_template,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_dev *, dev)
+		__field(struct vhost_work *, work)
+		__field(void *, function)
+	),
+
+	TP_fast_assign(
+		__entry->dev = dev;
+		__entry->work = work;
+		__entry->function = work->fn;
+	),
+
+	TP_printk("%pf for work %p dev %p",
+		__entry->function, __entry->work, __entry->dev)
+);
+
+DEFINE_EVENT(vhost_work_template, vhost_work_queue_wakeup,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+DEFINE_EVENT(vhost_work_template, vhost_work_queue_coalesce,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+DEFINE_EVENT(vhost_work_template, vhost_poll_start,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+DEFINE_EVENT(vhost_work_template, vhost_poll_stop,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+DEFINE_EVENT(vhost_work_template, vhost_work_execute_start,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+DEFINE_EVENT(vhost_work_template, vhost_work_execute_end,
+	TP_PROTO(struct vhost_dev *dev, struct vhost_work *work),
+	TP_ARGS(dev, work));
+
+#endif /* _TRACE_VHOST_H */
+
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH ../../drivers/vhost
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_FILE trace
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c14c42b..23f8d85 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -31,6 +31,8 @@
 #include <linux/if_arp.h>
 
 #include "vhost.h"
+#define CREATE_TRACE_POINTS
+#include "trace.h"
 
 enum {
 	VHOST_MEMORY_MAX_NREGIONS = 64,
@@ -50,6 +52,7 @@ static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 	poll = container_of(pt, struct vhost_poll, table);
 	poll->wqh = wqh;
 	add_wait_queue(wqh, &poll->wait);
+	trace_vhost_poll_start(NULL, &poll->work);
 }
 
 static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
@@ -101,6 +104,7 @@ void vhost_poll_start(struct vhost_poll *poll, struct file *file)
 void vhost_poll_stop(struct vhost_poll *poll)
 {
 	remove_wait_queue(poll->wqh, &poll->wait);
+	trace_vhost_poll_stop(NULL, &poll->work);
 }
 
 static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work *work,
@@ -147,7 +151,9 @@ static inline void vhost_work_queue(struct vhost_dev *dev,
 		list_add_tail(&work->node, &dev->work_list);
 		work->queue_seq++;
 		wake_up_process(dev->worker);
-	}
+		trace_vhost_work_queue_wakeup(dev, work);
+	} else
+		trace_vhost_work_queue_coalesce(dev, work);
 	spin_unlock_irqrestore(&dev->work_lock, flags);
 }
 
@@ -221,7 +227,9 @@ static int vhost_worker(void *data)
 
 		if (work) {
 			__set_current_state(TASK_RUNNING);
+			trace_vhost_work_execute_start(dev, work);
 			work->fn(work);
+			trace_vhost_work_execute_end(dev, work);
 		} else
 			schedule();
 
@@ -1011,6 +1019,7 @@ static int vhost_update_used_flags(struct vhost_virtqueue *vq)
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+	trace_vhost_virtio_update_used_flags(vq);
 	return 0;
 }
 
@@ -1030,6 +1039,7 @@ static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+	trace_vhost_virtio_update_avail_event(vq);
 	return 0;
 }
 
@@ -1319,6 +1329,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 	/* Assume notifications from guest are disabled at this point,
 	 * if they aren't we would need to update avail_event index. */
 	BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
+	trace_vhost_virtio_get_vq_desc(vq, head, *out_num, *in_num);
 	return head;
 }
 
@@ -1485,8 +1496,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
 		eventfd_signal(vq->call_ctx, 1);
+		trace_vhost_virtio_signal(vq);
+	}
 }
 
 /* And here's the combo meal deal.  Supersize me! */
