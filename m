From: "Razya Ladelsky" <razya@il.ibm.com>
Subject: [PATCH] vhost: Add polling mode
Date: Sun, 10 Aug 2014 11:30:35 +0300 (IDT)
Message-ID: <20140810083035.0CF58380729@moren.haifa.ibm.com>
References: <1407659404-razya@il.ibm.com>
Cc: GLIKSON@il.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: ERANRA@il.ibm.com
Cc: YOSSIKU@il.ibm.com
Cc: JOELN@il.ibm.com
Cc: abel.gordon@gmail.com
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org
To: mst@redhat.com
To: kvm@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Razya Ladelsky <razya@il.ibm.com>
Date: Thu, 31 Jul 2014 09:47:20 +0300
Subject: [PATCH] vhost: Add polling mode

When vhost is waiting for buffers from the guest driver (e.g., more packets to
send in vhost-net's transmit queue), it normally goes to sleep and waits for the
guest to "kick" it. This kick involves a PIO in the guest, and therefore an exit
(and possibly userspace involvement in translating this PIO exit into a file
descriptor event), all of which hurts performance.

If the system is under-utilized (has cpu time to spare), vhost can continuously
poll the virtqueues for new buffers, and avoid asking the guest to kick us.
This patch adds an optional polling mode to vhost, that can be enabled via a
kernel module parameter, "poll_start_rate".

When polling is active for a virtqueue, the guest is asked to disable
notification (kicks), and the worker thread continuously checks for new buffers.
When it does discover new buffers, it simulates a "kick" by invoking the
underlying backend driver (such as vhost-net), which thinks it got a real kick
from the guest, and acts accordingly. If the underlying driver asks not to be
kicked, we disable polling on this virtqueue.

We start polling on a virtqueue when we notice it has work to do. Polling on
this virtqueue is later disabled after 3 seconds of polling turning up no new
work, as in this case we are better off returning to the exit-based notification
mechanism. The default timeout of 3 seconds can be changed with the
"poll_stop_idle" kernel module parameter.

This polling approach makes lot of sense for new HW with posted-interrupts for
which we have exitless host-to-guest notifications. But even with support for
posted interrupts, guest-to-host communication still causes exits. Polling adds
the missing part.

When systems are overloaded, there won't be enough cpu time for the various
vhost threads to poll their guests' devices. For these scenarios, we plan to add
support for vhost threads that can be shared by multiple devices, even of
multiple vms.
Our ultimate goal is to implement the I/O acceleration features described in:
KVM Forum 2013: Efficient and Scalable Virtio (by Abel Gordon)
https://www.youtube.com/watch?v=9EyweibHfEs
and
https://www.mail-archive.com/kvm@vger.kernel.org/msg98179.html

I ran some experiments with TCP stream netperf and filebench (having 2 threads
performing random reads) benchmarks on an IBM System x3650 M4.
I have two machines, A and B. A hosts the vms, B runs the netserver.
The vms (on A) run netperf, its destination server is running on B.
All runs loaded the guests in a way that they were (cpu) saturated. For example,
I ran netperf with 64B messages, which is heavily loading the vm (which is why
its throughput is low).
The idea was to get it 100% loaded, so we can see that the polling is getting it
to produce higher throughput.

The system had two cores per guest, as to allow for both the vcpu and the vhost
thread to run concurrently for maximum throughput (but I didn't pin the threads
to specific cores).
My experiments were fair in a sense that for both cases, with or without
polling, I run both threads, vcpu and vhost, on 2 cores (set their affinity that
way). The only difference was whether polling was enabled/disabled.

Results:

Netperf, 1 vm:
The polling patch improved throughput by ~33% (1516 MB/sec -> 2046 MB/sec).
Number of exits/sec decreased 6x.
The same improvement was shown when I tested with 3 vms running netperf
(4086 MB/sec -> 5545 MB/sec).

filebench, 1 vm:
ops/sec improved by 13% with the polling patch. Number of exits was reduced by
31%.
The same experiment with 3 vms running filebench showed similar numbers.

Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
---
 drivers/vhost/net.c   |    6 +-
 drivers/vhost/scsi.c  |    6 +-
 drivers/vhost/vhost.c |  245 +++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/vhost/vhost.h |   38 +++++++-
 4 files changed, 277 insertions(+), 18 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 971a760..558aecb 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -742,8 +742,10 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	}
 	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
 
-	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
-	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT,
+			vqs[VHOST_NET_VQ_TX]);
+	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN,
+			vqs[VHOST_NET_VQ_RX]);
 
 	f->private_data = n;
 
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index 4f4ffa4..665eeeb 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1528,9 +1528,9 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 	if (!vqs)
 		goto err_vqs;
 
-	vhost_work_init(&vs->vs_completion_work, vhost_scsi_complete_cmd_work);
-	vhost_work_init(&vs->vs_event_work, tcm_vhost_evt_work);
-
+	vhost_work_init(&vs->vs_completion_work, NULL,
+						vhost_scsi_complete_cmd_work);
+	vhost_work_init(&vs->vs_event_work, NULL, tcm_vhost_evt_work);
 	vs->vs_events_nr = 0;
 	vs->vs_events_missed = false;
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c90f437..fbe8174 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -24,9 +24,17 @@
 #include <linux/slab.h>
 #include <linux/kthread.h>
 #include <linux/cgroup.h>
+#include <linux/jiffies.h>
 #include <linux/module.h>
 
 #include "vhost.h"
+static int poll_start_rate = 0;
+module_param(poll_start_rate, int, S_IRUGO|S_IWUSR);
+MODULE_PARM_DESC(poll_start_rate, "Start continuous polling of virtqueue when rate of events is at least this number per jiffy. If 0, never start polling.");
+
+static int poll_stop_idle = 3*HZ; /* 3 seconds */
+module_param(poll_stop_idle, int, S_IRUGO|S_IWUSR);
+MODULE_PARM_DESC(poll_stop_idle, "Stop continuous polling of virtqueue after this many jiffies of no work.");
 
 enum {
 	VHOST_MEMORY_MAX_NREGIONS = 64,
@@ -58,27 +66,28 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
 	return 0;
 }
 
-void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn)
+void vhost_work_init(struct vhost_work *work, struct vhost_virtqueue *vq,
+							vhost_work_fn_t fn)
 {
 	INIT_LIST_HEAD(&work->node);
 	work->fn = fn;
 	init_waitqueue_head(&work->done);
 	work->flushing = 0;
 	work->queue_seq = work->done_seq = 0;
+	work->vq = vq;
 }
 EXPORT_SYMBOL_GPL(vhost_work_init);
 
 /* Init poll structure */
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev)
+		     unsigned long mask, struct vhost_virtqueue *vq)
 {
 	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
 	init_poll_funcptr(&poll->table, vhost_poll_func);
 	poll->mask = mask;
-	poll->dev = dev;
+	poll->dev = vq->dev;
 	poll->wqh = NULL;
-
-	vhost_work_init(&poll->work, fn);
+	vhost_work_init(&poll->work, vq, fn);
 }
 EXPORT_SYMBOL_GPL(vhost_poll_init);
 
@@ -174,6 +183,86 @@ void vhost_poll_queue(struct vhost_poll *poll)
 }
 EXPORT_SYMBOL_GPL(vhost_poll_queue);
 
+/* Enable or disable virtqueue polling (vqpoll.enabled) for a virtqueue.
+ *
+ * Enabling this mode it tells the guest not to notify ("kick") us when its
+ * has made more work available on this virtqueue; Rather, we will continuously
+ * poll this virtqueue in the worker thread. If multiple virtqueues are polled,
+ * the worker thread polls them all, e.g., in a round-robin fashion.
+ * Note that vqpoll.enabled doesn't always mean that this virtqueue is
+ * actually being polled: The backend (e.g., net.c) may temporarily disable it
+ * using vhost_disable/enable_notify(), while vqpoll.enabled is unchanged.
+ *
+ * It is assumed that these functions are called relatively rarely, when vhost
+ * notices that this virtqueue's usage pattern significantly changed in a way
+ * that makes polling more efficient than notification, or vice versa.
+ * Also, we assume that vhost_vq_disable_vqpoll() is always called on vq
+ * cleanup, so any allocations done by vhost_vq_enable_vqpoll() can be
+ * reclaimed.
+ */
+static void vhost_vq_enable_vqpoll(struct vhost_virtqueue *vq)
+{
+	if (vq->vqpoll.enabled)
+		return; /* already enabled, nothing to do */
+	if (!vq->handle_kick)
+		return; /* polling will be a waste of time if no callback! */
+	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY)) {
+		/* vq has guest notifications enabled. Disable them,
+		   and instead add vq to the polling list */
+		vhost_disable_notify(vq->dev, vq);
+		list_add_tail(&vq->vqpoll.link, &vq->dev->vqpoll_list);
+	}
+	vq->vqpoll.jiffies_last_kick = jiffies;
+	__get_user(vq->avail_idx, &vq->avail->idx);
+	vq->vqpoll.enabled = true;
+
+	/* Map userspace's vq->avail to the kernel's memory space. */
+	if (get_user_pages_fast((unsigned long)vq->avail, 1, 0,
+		&vq->vqpoll.avail_page) != 1) {
+		/* TODO: can this happen, as we check access
+		to vq->avail in advance? */
+		BUG();
+	}
+	vq->vqpoll.avail_mapped = (struct vring_avail *) (
+		(unsigned long)kmap(vq->vqpoll.avail_page) |
+		((unsigned long)vq->avail & ~PAGE_MASK));
+}
+
+/*
+ * This function doesn't always succeed in changing the mode. Sometimes
+ * a temporary race condition prevents turning on guest notifications, so
+ * vq should be polled next time again.
+ */
+static void vhost_vq_disable_vqpoll(struct vhost_virtqueue *vq)
+{
+	if (!vq->vqpoll.enabled)
+		return; /* already disabled, nothing to do */
+
+	vq->vqpoll.enabled = false;
+
+	if (!list_empty(&vq->vqpoll.link)) {
+		/* vq is on the polling list, remove it from this list and
+		 * instead enable guest notifications. */
+		list_del_init(&vq->vqpoll.link);
+		if (unlikely(vhost_enable_notify(vq->dev, vq))
+			&& !vq->vqpoll.shutdown) {
+			/* Race condition: guest wrote before we enabled
+			 * notification, so we'll never get a notification for
+			 * this work - so continue polling mode for a while. */
+			vhost_disable_notify(vq->dev, vq);
+			vq->vqpoll.enabled = true;
+			vhost_enable_notify(vq->dev, vq);
+			return;
+		}
+	}
+
+	if (vq->vqpoll.avail_mapped) {
+		kunmap(vq->vqpoll.avail_page);
+		put_page(vq->vqpoll.avail_page);
+		vq->vqpoll.avail_mapped = 0;
+	}
+}
+
 static void vhost_vq_reset(struct vhost_dev *dev,
 			   struct vhost_virtqueue *vq)
 {
@@ -199,6 +288,48 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call = NULL;
 	vq->log_ctx = NULL;
 	vq->memory = NULL;
+	INIT_LIST_HEAD(&vq->vqpoll.link);
+	vq->vqpoll.enabled = false;
+	vq->vqpoll.shutdown = false;
+	vq->vqpoll.avail_mapped = NULL;
+}
+
+/* roundrobin_poll() takes worker->vqpoll_list, and returns one of the
+ * virtqueues which the caller should kick, or NULL in case none should be
+ * kicked. roundrobin_poll() also disables polling on a virtqueue which has
+ * been polled for too long without success.
+ *
+ * This current implementation (the "round-robin" implementation) only
+ * polls the first vq in the list, returning it or NULL as appropriate, and
+ * moves this vq to the end of the list, so next time a different one is
+ * polled.
+ */
+static struct vhost_virtqueue *roundrobin_poll(struct list_head *list)
+{
+	struct vhost_virtqueue *vq;
+	u16 avail_idx;
+
+	if (list_empty(list))
+		return NULL;
+
+	vq = list_first_entry(list, struct vhost_virtqueue, vqpoll.link);
+	WARN_ON(!vq->vqpoll.enabled);
+	list_move_tail(&vq->vqpoll.link, list);
+
+	/* See if there is any new work available from the guest. */
+	/* TODO: can check the optional idx feature, and if we haven't
+	* reached that idx yet, don't kick... */
+	avail_idx = vq->vqpoll.avail_mapped->idx;
+	if (avail_idx != vq->last_avail_idx)
+		return vq;
+
+	if (jiffies > vq->vqpoll.jiffies_last_kick + poll_stop_idle) {
+		/* We've been polling this virtqueue for a long time with no
+		* results, so switch back to guest notification
+		*/
+		vhost_vq_disable_vqpoll(vq);
+	}
+	return NULL;
 }
 
 static int vhost_worker(void *data)
@@ -237,12 +368,62 @@ static int vhost_worker(void *data)
 		spin_unlock_irq(&dev->work_lock);
 
 		if (work) {
+			struct vhost_virtqueue *vq = work->vq;
 			__set_current_state(TASK_RUNNING);
 			work->fn(work);
+			/* Keep track of the work rate, for deciding when to
+			 * enable polling */
+			if (vq) {
+				if (vq->vqpoll.jiffies_last_work != jiffies) {
+					vq->vqpoll.jiffies_last_work = jiffies;
+					vq->vqpoll.work_this_jiffy = 0;
+				}
+				vq->vqpoll.work_this_jiffy++;
+			}
+			/* If vq is in the round-robin list of virtqueues being
+			 * constantly checked by this thread, move vq the end
+			 * of the queue, because it had its fair chance now.
+			 */
+			if (vq && !list_empty(&vq->vqpoll.link)) {
+				list_move_tail(&vq->vqpoll.link,
+					&dev->vqpoll_list);
+			}
+			/* Otherwise, if this vq is looking for notifications
+			 * but vq polling is not enabled for it, do it now.
+			 */
+			else if (poll_start_rate && vq && vq->handle_kick &&
+				!vq->vqpoll.enabled &&
+				!vq->vqpoll.shutdown &&
+				!(vq->used_flags & VRING_USED_F_NO_NOTIFY) &&
+				vq->vqpoll.work_this_jiffy >=
+					poll_start_rate) {
+				vhost_vq_enable_vqpoll(vq);
+			}
+		}
+		/* Check one virtqueue from the round-robin list */
+		if (!list_empty(&dev->vqpoll_list)) {
+			struct vhost_virtqueue *vq;
+
+			vq = roundrobin_poll(&dev->vqpoll_list);
+
+			if (vq) {
+				vq->handle_kick(&vq->poll.work);
+				vq->vqpoll.jiffies_last_kick = jiffies;
+			}
+
+			/* If our polling list isn't empty, ask to continue
+			 * running this thread, don't yield.
+			 */
+			__set_current_state(TASK_RUNNING);
 			if (need_resched())
 				schedule();
-		} else
-			schedule();
+		} else {
+			if (work) {
+				if (need_resched())
+					schedule();
+			} else
+				schedule();
+		}
 
 	}
 	unuse_mm(dev->mm);
@@ -306,6 +487,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 	dev->mm = NULL;
 	spin_lock_init(&dev->work_lock);
 	INIT_LIST_HEAD(&dev->work_list);
+	INIT_LIST_HEAD(&dev->vqpoll_list);
 	dev->worker = NULL;
 
 	for (i = 0; i < dev->nvqs; ++i) {
@@ -318,7 +500,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 		vhost_vq_reset(dev, vq);
 		if (vq->handle_kick)
 			vhost_poll_init(&vq->poll, vq->handle_kick,
-					POLLIN, dev);
+					POLLIN, vq);
 	}
 }
 EXPORT_SYMBOL_GPL(vhost_dev_init);
@@ -350,7 +532,7 @@ static int vhost_attach_cgroups(struct vhost_dev *dev)
 	struct vhost_attach_cgroups_struct attach;
 
 	attach.owner = current;
-	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
+	vhost_work_init(&attach.work, NULL, vhost_attach_cgroups_work);
 	vhost_work_queue(dev, &attach.work);
 	vhost_work_flush(dev, &attach.work);
 	return attach.ret;
@@ -444,6 +626,26 @@ void vhost_dev_stop(struct vhost_dev *dev)
 }
 EXPORT_SYMBOL_GPL(vhost_dev_stop);
 
+/* shutdown_vqpoll() asks the worker thread to shut down virtqueue polling
+ * mode for a given virtqueue which is itself being shut down. We ask the
+ * worker thread to do this rather than doing it directly, so that we don't
+ * race with the worker thread's use of the queue.
+ */
+static void shutdown_vqpoll_work(struct vhost_work *work)
+{
+	work->vq->vqpoll.shutdown = true;
+	vhost_vq_disable_vqpoll(work->vq);
+	WARN_ON(work->vq->vqpoll.avail_mapped);
+}
+
+static void shutdown_vqpoll(struct vhost_virtqueue *vq)
+{
+	struct vhost_work work;
+
+	vhost_work_init(&work, vq, shutdown_vqpoll_work);
+	vhost_work_queue(vq->dev, &work);
+	vhost_work_flush(vq->dev, &work);
+}
 /* Caller should have device mutex if and only if locked is set */
 void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 {
@@ -460,6 +662,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 			eventfd_ctx_put(dev->vqs[i]->call_ctx);
 		if (dev->vqs[i]->call)
 			fput(dev->vqs[i]->call);
+		shutdown_vqpoll(dev->vqs[i]);
 		vhost_vq_reset(dev, dev->vqs[i]);
 	}
 	vhost_dev_free_iovecs(dev);
@@ -1491,6 +1694,19 @@ bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	u16 avail_idx;
 	int r;
 
+	/* In polling mode, when the backend (e.g., net.c) asks to enable
+	 * notifications, we don't enable guest notifications. Instead, start
+	 * polling on this vq by adding it to the round-robin list.
+	 */
+	if (vq->vqpoll.enabled) {
+		if (list_empty(&vq->vqpoll.link)) {
+			list_add_tail(&vq->vqpoll.link,
+				&vq->dev->vqpoll_list);
+			vq->vqpoll.jiffies_last_kick = jiffies;
+		}
+		return false;
+	}
+
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
@@ -1528,6 +1744,17 @@ void vhost_disable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	int r;
 
+	/* If this virtqueue is vqpoll.enabled, and on the polling list, it
+	 * will generate notifications even if the guest is asked not to send
+	 * them. So we must remove it from the round-robin polling list.
+	 * Note that vqpoll.enabled remains set.
+	 */
+	if (vq->vqpoll.enabled) {
+		if (!list_empty(&vq->vqpoll.link))
+			list_del_init(&vq->vqpoll.link);
+		return;
+	}
+
 	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
 		return;
 	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 3eda654..11aaaf4 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -24,6 +24,7 @@ struct vhost_work {
 	int			  flushing;
 	unsigned		  queue_seq;
 	unsigned		  done_seq;
+	struct vhost_virtqueue    *vq;
 };
 
 /* Poll a file (eventfd or socket) */
@@ -37,11 +38,12 @@ struct vhost_poll {
 	struct vhost_dev	 *dev;
 };
 
-void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn);
+void vhost_work_init(struct vhost_work *work, struct vhost_virtqueue *vq,
+							vhost_work_fn_t fn);
 void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
 
 void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
-		     unsigned long mask, struct vhost_dev *dev);
+		     unsigned long mask, struct vhost_virtqueue  *vq);
 int vhost_poll_start(struct vhost_poll *poll, struct file *file);
 void vhost_poll_stop(struct vhost_poll *poll);
 void vhost_poll_flush(struct vhost_poll *poll);
@@ -54,8 +56,6 @@ struct vhost_log {
 	u64 len;
 };
 
-struct vhost_virtqueue;
-
 /* The virtqueue structure describes a queue attached to a device. */
 struct vhost_virtqueue {
 	struct vhost_dev *dev;
@@ -110,6 +110,35 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	struct {
+      /* When a virtqueue is in vqpoll.enabled mode, it declares
+       * that instead of using guest notifications (kicks) to
+       * discover new work, we prefer to continuously poll this
+       * virtqueue in the worker thread.
+       * If !enabled, the rest of the fields below are undefined.
+       */
+		bool enabled;
+      /* vqpoll.enabled doesn't always mean that this virtqueue is
+       * actually being polled: The backend (e.g., net.c) may
+       * temporarily disable it using vhost_disable/enable_notify().
+       * vqpoll.link is used to maintain the thread's round-robin
+       * list of virtqueues that actually need to be polled.
+       * Note list_empty(link) means this virtqueue isn't polled.
+       */
+		struct list_head link;
+      /* If this flag is true, the virtqueue is being shut down,
+       * so vqpoll should not be re-enabled.
+       */
+		bool shutdown;
+      /* Various counters used to decide when to enter polling mode
+       * or leave it and return to notification mode.
+       */
+		unsigned long jiffies_last_kick;
+		unsigned long jiffies_last_work;
+		int work_this_jiffy;
+		struct page *avail_page;
+		volatile struct vring_avail *avail_mapped;
+	} vqpoll;
 };
 
 struct vhost_dev {
@@ -123,6 +152,7 @@ struct vhost_dev {
 	spinlock_t work_lock;
 	struct list_head work_list;
 	struct task_struct *worker;
+	struct list_head vqpoll_list;
 };
 
 void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
-- 
1.7.9.5
