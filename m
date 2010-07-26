From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with
 per-vhost kthread
Date: Mon, 26 Jul 2010 19:57:24 +0300
Message-ID: <20100726165724.GB27353@redhat.com>
References: <4C06A580.9060300@kernel.org>
 <20100722155840.GA1743@redhat.com>
 <4C48B664.9000109@kernel.org>
 <20100724191447.GA4972@redhat.com>
 <4C4BEAA2.6040301@kernel.org>
 <20100726152510.GA26223@redhat.com>
 <4C4DAB14.5050809@kernel.org>
 <20100726155014.GA26412@redhat.com>
 <4C4DB247.9060709@kernel.org>
 <4C4DB466.6000409@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C4DB466.6000409@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's an untested patch forward-ported from vhost
(works fine for vhost).

kthread_worker: replace barriers+atomics with a lock

We can save some cycles and make code simpler by
reusing worker lock for flush, instead of atomics.
flush_kthread_work needs to get worker pointer for
this to work.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 685ea65..19ae9f2 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -58,7 +58,7 @@ struct kthread_work {
 	struct list_head	node;
 	kthread_work_func_t	func;
 	wait_queue_head_t	done;
-	atomic_t		flushing;
+	int			flushing;
 	int			queue_seq;
 	int			done_seq;
 };
@@ -72,7 +72,7 @@ struct kthread_work {
 	.node = LIST_HEAD_INIT((work).node),				\
 	.func = (fn),							\
 	.done = __WAIT_QUEUE_HEAD_INITIALIZER((work).done),		\
-	.flushing = ATOMIC_INIT(0),					\
+	.flushing = 0,							\
 	}
 
 #define DEFINE_KTHREAD_WORKER(worker)					\
@@ -96,7 +96,8 @@ int kthread_worker_fn(void *worker_ptr);
 
 bool queue_kthread_work(struct kthread_worker *worker,
 			struct kthread_work *work);
-void flush_kthread_work(struct kthread_work *work);
+void flush_kthread_work(struct kthread_worker *worker,
+			struct kthread_work *work);
 void flush_kthread_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 2dc3786..461f58d 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -283,10 +283,12 @@ int kthreadd(void *unused)
 int kthread_worker_fn(void *worker_ptr)
 {
 	struct kthread_worker *worker = worker_ptr;
-	struct kthread_work *work;
+	struct kthread_work *work = NULL;
 
+	spin_lock_irq(&worker->lock);
 	WARN_ON(worker->task);
 	worker->task = current;
+	spin_unlock_irq(&worker->lock);
 repeat:
 	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
@@ -298,23 +300,23 @@ repeat:
 		return 0;
 	}
 
-	work = NULL;
 	spin_lock_irq(&worker->lock);
+	if (work) {
+		work->done_seq = work->queue_seq;
+		if (work->flushing)
+			wake_up_all(&work->done);
+	}
 	if (!list_empty(&worker->work_list)) {
 		work = list_first_entry(&worker->work_list,
 					struct kthread_work, node);
 		list_del_init(&work->node);
-	}
+	} else
+		work = NULL;
 	spin_unlock_irq(&worker->lock);
 
 	if (work) {
 		__set_current_state(TASK_RUNNING);
 		work->func(work);
-		smp_wmb();	/* wmb worker-b0 paired with flush-b1 */
-		work->done_seq = work->queue_seq;
-		smp_mb();	/* mb worker-b1 paired with flush-b0 */
-		if (atomic_read(&work->flushing))
-			wake_up_all(&work->done);
 	} else if (!freezing(current))
 		schedule();
 
@@ -353,31 +355,33 @@ EXPORT_SYMBOL_GPL(queue_kthread_work);
 
 /**
  * flush_kthread_work - flush a kthread_work
+ * @worker: where work might be running
  * @work: work to flush
  *
  * If @work is queued or executing, wait for it to finish execution.
  */
-void flush_kthread_work(struct kthread_work *work)
+void flush_kthread_work(struct kthread_worker *worker,
+			struct kthread_work *work)
 {
-	int seq = work->queue_seq;
+	int seq
 
-	atomic_inc(&work->flushing);
-
-	/*
-	 * mb flush-b0 paired with worker-b1, to make sure either
-	 * worker sees the above increment or we see done_seq update.
-	 */
-	smp_mb__after_atomic_inc();
+	spin_lock_irq(&worker->lock);
+	seq = work->queue_seq;
+	++work->flushing;
+	spin_unlock_irq(&worker->lock);
 
 	/* A - B <= 0 tests whether B is in front of A regardless of overflow */
-	wait_event(work->done, seq - work->done_seq <= 0);
-	atomic_dec(&work->flushing);
-
-	/*
-	 * rmb flush-b1 paired with worker-b0, to make sure our caller
-	 * sees every change made by work->func().
-	 */
-	smp_mb__after_atomic_dec();
+	wait_event(work->done,
+		   ({
+			int done;
+			spin_lock_irq(&worker->lock);
+		    	delta = seq - work->done_seq <= 0;
+			spin_unlock_irq(&worker->lock);
+			done;
+		   });
+	spin_lock_irq(&worker->lock);
+	--work->flushing;
+	spin_unlock_irq(&worker->lock);
 }
 EXPORT_SYMBOL_GPL(flush_kthread_work);
 
