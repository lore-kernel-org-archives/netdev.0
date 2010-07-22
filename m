From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with
 per-vhost kthread
Date: Thu, 22 Jul 2010 18:58:40 +0300
Message-ID: <20100722155840.GA1743@redhat.com>
References: <4BFEE216.2070807@kernel.org>
 <20100528150830.GB21880@redhat.com>
 <4BFFE742.2060205@kernel.org>
 <20100530112925.GB27611@redhat.com>
 <4C02C961.9050606@kernel.org>
 <20100531152221.GB2987@redhat.com>
 <4C03D983.9010905@kernel.org>
 <20100531160020.GC3067@redhat.com>
 <4C04D41B.4050704@kernel.org>
 <4C06A580.9060300@kernel.org>
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
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C06A580.9060300@kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 02, 2010 at 08:40:00PM +0200, Tejun Heo wrote:
> Replace vhost_workqueue with per-vhost kthread.  Other than callback
> argument change from struct work_struct * to struct vhost_work *,
> there's no visible change to vhost_poll_*() interface.
> 
> This conversion is to make each vhost use a dedicated kthread so that
> resource control via cgroup can be applied.
> 
> Partially based on Sridhar Samudrala's patch.
> 
> * Updated to use sub structure vhost_work instead of directly using
>   vhost_poll at Michael's suggestion.
> 
> * Added flusher wake_up() optimization at Michael's suggestion.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>

All the tricky barrier pairing made me uncomfortable.  So I came up with
this on top (untested): if we do all operations under the spinlock, we
can get by without barriers and atomics.  And since we need the lock for
list operations anyway, this should have no paerformance impact.

What do you think?


diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 0c6b533..7730a30 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -73,7 +73,7 @@ void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
 	INIT_LIST_HEAD(&work->node);
 	work->fn = fn;
 	init_waitqueue_head(&work->done);
-	atomic_set(&work->flushing, 0);
+	work->flushing = 0;
 	work->queue_seq = work->done_seq = 0;
 }
 
@@ -99,13 +99,23 @@ void vhost_poll_stop(struct vhost_poll *poll)
 void vhost_poll_flush(struct vhost_poll *poll)
 {
 	struct vhost_work *work = &poll->work;
-	int seq = work->queue_seq;
+	unsigned seq, left;
+	int flushing;
 
-	atomic_inc(&work->flushing);
-	smp_mb__after_atomic_inc();	/* mb flush-b0 paired with worker-b1 */
-	wait_event(work->done, seq - work->done_seq <= 0);
-	atomic_dec(&work->flushing);
-	smp_mb__after_atomic_dec();	/* rmb flush-b1 paired with worker-b0 */
+	spin_lock_irq(&dev->work_lock);
+	seq = work->queue_seq;
+	work->flushing++;
+	spin_unlock_irq(&dev->work_lock);
+	wait_event(work->done, {
+		   spin_lock_irq(&dev->work_lock);
+		   left = work->done_seq - seq;
+		   spin_unlock_irq(&dev->work_lock);
+		   left < UINT_MAX / 2;
+	});
+	spin_lock_irq(&dev->work_lock);
+	flushing = --work->flushing;
+	spin_unlock_irq(&dev->work_lock);
+	BUG_ON(flushing < 0);
 }
 
 void vhost_poll_queue(struct vhost_poll *poll)
@@ -151,37 +161,37 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 static int vhost_worker(void *data)
 {
 	struct vhost_dev *dev = data;
-	struct vhost_work *work;
+	struct vhost_work *work = NULL;
 
-repeat:
-	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
 
-	if (kthread_should_stop()) {
-		__set_current_state(TASK_RUNNING);
-		return 0;
-	}
+		if (kthread_should_stop()) {
+			__set_current_state(TASK_RUNNING);
+			return 0;
+		}
 
-	work = NULL;
-	spin_lock_irq(&dev->work_lock);
-	if (!list_empty(&dev->work_list)) {
-		work = list_first_entry(&dev->work_list,
-					struct vhost_work, node);
-		list_del_init(&work->node);
-	}
-	spin_unlock_irq(&dev->work_lock);
+		spin_lock_irq(&dev->work_lock);
+		if (work) {
+			work->done_seq = work->queue_seq;
+			if (work->flushing)
+				wake_up_all(&work->done);
+		}
+		if (!list_empty(&dev->work_list)) {
+			work = list_first_entry(&dev->work_list,
+						struct vhost_work, node);
+			list_del_init(&work->node);
+		} else
+			work = NULL;
+		spin_unlock_irq(&dev->work_lock);
+
+		if (work) {
+			__set_current_state(TASK_RUNNING);
+			work->fn(work);
+		} else
+			schedule();
 
-	if (work) {
-		__set_current_state(TASK_RUNNING);
-		work->fn(work);
-		smp_wmb();	/* wmb worker-b0 paired with flush-b1 */
-		work->done_seq = work->queue_seq;
-		smp_mb();	/* mb worker-b1 paired with flush-b0 */
-		if (atomic_read(&work->flushing))
-			wake_up_all(&work->done);
-	} else
-		schedule();
-
-	goto repeat;
+	}
 }
 
 long vhost_dev_init(struct vhost_dev *dev,
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 0e63091..3693327 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -27,9 +27,9 @@ struct vhost_work {
 	struct list_head	  node;
 	vhost_work_fn_t		  fn;
 	wait_queue_head_t	  done;
-	atomic_t		  flushing;
-	int			  queue_seq;
-	int			  done_seq;
+	int			  flushing;
+	unsigned		  queue_seq;
+	unsigned		  done_seq;
 };
 
 /* Poll a file (eventfd or socket) */
