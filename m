From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 05/45] percpu_rwlock: Make percpu-rwlocks IRQ-safe,
 optimally
Date: Tue, 22 Jan 2013 13:04:11 +0530
Message-ID: <20130122073400.13822.52336.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If interrupt handlers can also be readers, then one of the ways to make
per-CPU rwlocks safe, is to disable interrupts at the reader side before
trying to acquire the per-CPU rwlock and keep it disabled throughout the
duration of the read-side critical section.

The goal is to avoid cases such as:

  1. writer is active and it holds the global rwlock for write

  2. a regular reader comes in and marks itself as present (by incrementing
     its per-CPU refcount) before checking whether writer is active.

  3. an interrupt hits the reader;
     [If it had not hit, the reader would have noticed that the writer is
      active and would have decremented its refcount and would have tried
      to acquire the global rwlock for read].
     Since the interrupt handler also happens to be a reader, it notices
     the non-zero refcount (which was due to the reader who got interrupted)
     and thinks that this is a nested read-side critical section and
     proceeds to take the fastpath, which is wrong. The interrupt handler
     should have noticed that the writer is active and taken the rwlock
     for read.

So, disabling interrupts can help avoid this problem (at the cost of keeping
the interrupts disabled for quite long).

But Oleg had a brilliant idea by which we can do much better than that:
we can manage with disabling interrupts _just_ during the updates (writes to
per-CPU refcounts) to safe-guard against races with interrupt handlers.
Beyond that, we can keep the interrupts enabled and still be safe w.r.t
interrupt handlers that can act as readers.

Basically the idea is that we differentiate between the *part* of the
per-CPU refcount that we use for reference counting vs the part that we use
merely to make the writer wait for us to switch over to the right
synchronization scheme.

The scheme involves splitting the per-CPU refcounts into 2 parts:
eg: the lower 16 bits are used to track the nesting depth of the reader
(a "nested-counter"), and the remaining (upper) bits are used to merely mark
the presence of the reader.

As long as the overall reader_refcnt is non-zero, the writer waits for the
reader (assuming that the reader is still actively using per-CPU refcounts for
synchronization).

The reader first sets one of the higher bits to mark its presence, and then
uses the lower 16 bits to manage the nesting depth. So, an interrupt handler
coming in as illustrated above will be able to distinguish between "this is
a nested read-side critical section" vs "we have merely marked our presence
to make the writer wait for us to switch" by looking at the same refcount.
Thus, it makes it unnecessary to keep interrupts disabled throughout the
read-side critical section, despite having the possibility of interrupt
handlers being readers themselves.


Implement this logic and rename the locking functions appropriately, to
reflect what they do.

Based-on-idea-by: Oleg Nesterov <oleg@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/percpu-rwlock.h |   15 ++++++++++-----
 lib/percpu-rwlock.c           |   41 +++++++++++++++++++++++++++--------------
 2 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/include/linux/percpu-rwlock.h b/include/linux/percpu-rwlock.h
index 6819bb8..856ba6b 100644
--- a/include/linux/percpu-rwlock.h
+++ b/include/linux/percpu-rwlock.h
@@ -34,11 +34,13 @@ struct percpu_rwlock {
 	rwlock_t		global_rwlock;
 };
 
-extern void percpu_read_lock(struct percpu_rwlock *);
-extern void percpu_read_unlock(struct percpu_rwlock *);
+extern void percpu_read_lock_irqsafe(struct percpu_rwlock *);
+extern void percpu_read_unlock_irqsafe(struct percpu_rwlock *);
 
-extern void percpu_write_lock(struct percpu_rwlock *);
-extern void percpu_write_unlock(struct percpu_rwlock *);
+extern void percpu_write_lock_irqsave(struct percpu_rwlock *,
+				      unsigned long *flags);
+extern void percpu_write_unlock_irqrestore(struct percpu_rwlock *,
+					   unsigned long *flags);
 
 extern int __percpu_init_rwlock(struct percpu_rwlock *,
 				const char *, struct lock_class_key *);
@@ -68,11 +70,14 @@ extern void percpu_free_rwlock(struct percpu_rwlock *);
 	__percpu_init_rwlock(pcpu_rwlock, #pcpu_rwlock, &rwlock_key);	\
 })
 
+#define READER_PRESENT		(1UL << 16)
+#define READER_REFCNT_MASK	(READER_PRESENT - 1)
+
 #define reader_uses_percpu_refcnt(pcpu_rwlock, cpu)			\
 		(ACCESS_ONCE(per_cpu(*((pcpu_rwlock)->reader_refcnt), cpu)))
 
 #define reader_nested_percpu(pcpu_rwlock)				\
-			(__this_cpu_read(*((pcpu_rwlock)->reader_refcnt)) > 1)
+	(__this_cpu_read(*((pcpu_rwlock)->reader_refcnt)) & READER_REFCNT_MASK)
 
 #define writer_active(pcpu_rwlock)					\
 			(__this_cpu_read(*((pcpu_rwlock)->writer_signal)))
diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index 992da5c..a8d177a 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -62,19 +62,19 @@ void percpu_free_rwlock(struct percpu_rwlock *pcpu_rwlock)
 	pcpu_rwlock->writer_signal = NULL;
 }
 
-void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
+void percpu_read_lock_irqsafe(struct percpu_rwlock *pcpu_rwlock)
 {
 	preempt_disable();
 
 	/* First and foremost, let the writer know that a reader is active */
-	this_cpu_inc(*pcpu_rwlock->reader_refcnt);
+	this_cpu_add(*pcpu_rwlock->reader_refcnt, READER_PRESENT);
 
 	/*
 	 * If we are already using per-cpu refcounts, it is not safe to switch
 	 * the synchronization scheme. So continue using the refcounts.
 	 */
 	if (reader_nested_percpu(pcpu_rwlock)) {
-		goto out;
+		this_cpu_inc(*pcpu_rwlock->reader_refcnt);
 	} else {
 		/*
 		 * The write to 'reader_refcnt' must be visible before we
@@ -83,9 +83,19 @@ void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
 		smp_mb(); /* Paired with smp_rmb() in sync_reader() */
 
 		if (likely(!writer_active(pcpu_rwlock))) {
-			goto out;
+			this_cpu_inc(*pcpu_rwlock->reader_refcnt);
 		} else {
 			/* Writer is active, so switch to global rwlock. */
+
+			/*
+			 * While we are spinning on ->global_rwlock, an
+			 * interrupt can hit us, and the interrupt handler
+			 * might call this function. The distinction between
+			 * READER_PRESENT and the refcnt helps ensure that the
+			 * interrupt handler also takes this branch and spins
+			 * on the ->global_rwlock, as long as the writer is
+			 * active.
+			 */
 			read_lock(&pcpu_rwlock->global_rwlock);
 
 			/*
@@ -95,26 +105,27 @@ void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
 			 * back to per-cpu refcounts. (This also helps avoid
 			 * heterogeneous nesting of readers).
 			 */
-			if (writer_active(pcpu_rwlock))
-				this_cpu_dec(*pcpu_rwlock->reader_refcnt);
-			else
+			if (!writer_active(pcpu_rwlock)) {
+				this_cpu_inc(*pcpu_rwlock->reader_refcnt);
 				read_unlock(&pcpu_rwlock->global_rwlock);
+			}
 		}
 	}
 
-out:
+	this_cpu_sub(*pcpu_rwlock->reader_refcnt, READER_PRESENT);
+
 	/* Prevent reordering of any subsequent reads */
 	smp_rmb();
 }
 
-void percpu_read_unlock(struct percpu_rwlock *pcpu_rwlock)
+void percpu_read_unlock_irqsafe(struct percpu_rwlock *pcpu_rwlock)
 {
 	/*
 	 * We never allow heterogeneous nesting of readers. So it is trivial
 	 * to find out the kind of reader we are, and undo the operation
 	 * done by our corresponding percpu_read_lock().
 	 */
-	if (__this_cpu_read(*pcpu_rwlock->reader_refcnt)) {
+	if (reader_nested_percpu(pcpu_rwlock)) {
 		this_cpu_dec(*pcpu_rwlock->reader_refcnt);
 		smp_wmb(); /* Paired with smp_rmb() in sync_reader() */
 	} else {
@@ -184,7 +195,8 @@ static void sync_all_readers(struct percpu_rwlock *pcpu_rwlock)
 		sync_reader(pcpu_rwlock, cpu);
 }
 
-void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
+void percpu_write_lock_irqsave(struct percpu_rwlock *pcpu_rwlock,
+			       unsigned long *flags)
 {
 	/*
 	 * Tell all readers that a writer is becoming active, so that they
@@ -192,10 +204,11 @@ void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
 	 */
 	announce_writer_active(pcpu_rwlock);
 	sync_all_readers(pcpu_rwlock);
-	write_lock(&pcpu_rwlock->global_rwlock);
+	write_lock_irqsave(&pcpu_rwlock->global_rwlock, *flags);
 }
 
-void percpu_write_unlock(struct percpu_rwlock *pcpu_rwlock)
+void percpu_write_unlock_irqrestore(struct percpu_rwlock *pcpu_rwlock,
+			 unsigned long *flags)
 {
 	/*
 	 * Inform all readers that we are done, so that they can switch back
@@ -203,6 +216,6 @@ void percpu_write_unlock(struct percpu_rwlock *pcpu_rwlock)
 	 * see it).
 	 */
 	announce_writer_inactive(pcpu_rwlock);
-	write_unlock(&pcpu_rwlock->global_rwlock);
+	write_unlock_irqrestore(&pcpu_rwlock->global_rwlock, *flags);
 }
 
