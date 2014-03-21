From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC V2 2/4] vhost: basic tracepoints
Date: Fri, 21 Mar 2014 17:41:51 +0800
Message-ID: <1395394913-19548-3-git-send-email-jasowang@redhat.com>
References: <1395394913-19548-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <virtio-dev-return-468-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <1395394913-19548-1-git-send-email-jasowang@redhat.com>
List-Id: netdev.vger.kernel.org

To help for the performance optimizations and debugging, this patch tracepoints
for vhost. Two kinds of activities were traced: virtio and vhost work
queuing/wakeup.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   |   1 +
 drivers/vhost/trace.h | 175 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.c |  14 +++-
 3 files changed, 189 insertions(+), 1 deletion(-)
 create mode 100644 drivers/vhost/trace.h

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 85d666c..7353204 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -1,3 +1,4 @@
+
 /* Copyright (C) 2009 Red Hat, Inc.
  * Author: Michael S. Tsirkin <mst@redhat.com>
  *
diff --git a/drivers/vhost/trace.h b/drivers/vhost/trace.h
new file mode 100644
index 0000000..e380942
--- /dev/null
+++ b/drivers/vhost/trace.h
@@ -0,0 +1,175 @@
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
+                __field(u16, queue_index)
+		__field(u16, used_flags)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+                __entry->queue_index = vq->queue_index;
+		__entry->used_flags = vq->used_flags;
+	),
+
+	TP_printk("vhost update used flag %x to vq %d notify %s",
+		  __entry->used_flags, __entry->queue_index,
+		  (__entry->used_flags & VRING_USED_F_NO_NOTIFY) ?
+		  "disabled" : "enabled")
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
+		__field(u16, queue_index)
+		__field(u16, avail_idx)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->queue_index = vq->queue_index;
+		__entry->avail_idx = vq->avail_idx;
+	),
+
+	TP_printk("vhost update avail event %u(%u) for vq %d",
+		  __entry->avail_idx, __entry->avail_idx %
+		  __entry->vq->num, __entry->queue_index)
+);
+
+/*
+ * Tracepoint for updating used index.
+ */
+TRACE_EVENT(vhost_virtio_update_used_idx,
+	TP_PROTO(struct vhost_virtqueue *vq),
+	TP_ARGS(vq),
+
+	TP_STRUCT__entry(
+		__field(struct vhost_virtqueue *, vq)
+		__field(u16, queue_index)
+		__field(u16, used_idx)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->queue_index = vq->queue_index;
+		__entry->used_idx = vq->last_used_idx;
+	),
+
+	TP_printk("vhost update used index %u(%u) for vq %d",
+		  __entry->used_idx, __entry->used_idx %
+		  __entry->vq->num, __entry->queue_index)
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
+		__field(u16, queue_index)
+		__field(unsigned int, head)
+		__field(unsigned int, out)
+		__field(unsigned int, in)
+                __field(u16, last_avail_idx)
+	),
+
+	TP_fast_assign(
+		__entry->vq = vq;
+		__entry->queue_index = vq->queue_index;
+		__entry->head = index;
+		__entry->out = out;
+		__entry->in = in;
+                __entry->last_avail_idx = vq->last_avail_idx;
+	),
+
+	TP_printk("vhost get vq %d desc last avail index %u(%u), "
+                  "head %u out %u in %u",
+		  __entry->queue_index,
+		  __entry->last_avail_idx,
+                  __entry->last_avail_idx % __entry->vq->num,
+                  __entry->head, __entry->out, __entry->in)
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
+		__field(u16, queue_index)
+	),
+
+	TP_fast_assign(
+		__entry->queue_index = vq->queue_index;
+	),
+
+	TP_printk("vhost signal vq %d", __entry->queue_index)
+);
+
+DECLARE_EVENT_CLASS(vhost_work_template,
+	TP_PROTO(struct vhost_work *work),
+	TP_ARGS(work),
+
+	TP_STRUCT__entry(
+		__field(void *, function)
+	),
+
+	TP_fast_assign(
+		__entry->function = work->fn;
+	),
+
+        TP_printk("%pf", __entry->function)
+);
+
+DEFINE_EVENT(vhost_work_template, vhost_work_queue_wakeup,
+	TP_PROTO(struct vhost_work *work),
+	TP_ARGS(work));
+
+DEFINE_EVENT(vhost_work_template, vhost_work_queue_coalesce,
+	TP_PROTO(struct vhost_work *work),
+	TP_ARGS(work));
+
+DEFINE_EVENT(vhost_work_template, vhost_poll_start,
+	TP_PROTO(struct vhost_work *work),
+	TP_ARGS(work));
+
+DEFINE_EVENT(vhost_work_template, vhost_poll_stop,
+	TP_PROTO(struct vhost_work *work),
+	TP_ARGS(work));
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
index 78987e4..7cf3d6e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -28,6 +28,8 @@
 #include <linux/module.h>
 
 #include "vhost.h"
+#define CREATE_TRACE_POINTS
+#include "trace.h"
 
 enum {
 	VHOST_MEMORY_MAX_NREGIONS = 64,
@@ -45,6 +47,7 @@ static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
 	poll = container_of(pt, struct vhost_poll, table);
 	poll->wqh = wqh;
 	add_wait_queue(wqh, &poll->wait);
+	trace_vhost_poll_start(&poll->work);
 }
 
 static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
@@ -114,6 +117,7 @@ void vhost_poll_stop(struct vhost_poll *poll)
 		remove_wait_queue(poll->wqh, &poll->wait);
 		poll->wqh = NULL;
 	}
+	trace_vhost_poll_stop(&poll->work);
 }
 EXPORT_SYMBOL_GPL(vhost_poll_stop);
 
@@ -163,8 +167,10 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
 		work->queue_seq++;
 		spin_unlock_irqrestore(&dev->work_lock, flags);
 		wake_up_process(dev->worker);
+		trace_vhost_work_queue_wakeup(work);
 	} else {
 		spin_unlock_irqrestore(&dev->work_lock, flags);
+		trace_vhost_work_queue_coalesce(work);
 	}
 }
 EXPORT_SYMBOL_GPL(vhost_work_queue);
@@ -1008,6 +1014,7 @@ static int vhost_update_used_flags(struct vhost_virtqueue *vq)
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+	trace_vhost_virtio_update_used_flags(vq);
 	return 0;
 }
 
@@ -1027,6 +1034,7 @@ static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 avail_event)
 		if (vq->log_ctx)
 			eventfd_signal(vq->log_ctx, 1);
 	}
+	trace_vhost_virtio_update_avail_event(vq);
 	return 0;
 }
 
@@ -1311,6 +1319,7 @@ int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
 		}
 	} while ((i = next_desc(&desc)) != -1);
 
+	trace_vhost_virtio_get_vq_desc(vq, head, *out_num, *in_num);
 	/* On success, increment avail index. */
 	vq->last_avail_idx++;
 
@@ -1405,6 +1414,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 		vq_err(vq, "Failed to increment used idx");
 		return -EFAULT;
 	}
+	trace_vhost_virtio_update_used_idx(vq);
 	if (unlikely(vq->log_used)) {
 		/* Log used index update. */
 		log_write(vq->log_base,
@@ -1457,8 +1467,10 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	/* Signal the Guest tell them we used something up. */
-	if (vq->call_ctx && vhost_notify(dev, vq))
+	if (vq->call_ctx && vhost_notify(dev, vq)) {
 		eventfd_signal(vq->call_ctx, 1);
+		trace_vhost_virtio_signal(vq);
+	}
 }
 EXPORT_SYMBOL_GPL(vhost_signal);
 
-- 
1.8.3.2
