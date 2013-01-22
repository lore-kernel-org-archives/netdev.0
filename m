From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 04/45] percpu_rwlock: Implement the core design of Per-CPU
 Reader-Writer Locks
Date: Tue, 22 Jan 2013 13:03:53 +0530
Message-ID: <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:58448 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887Ab3AVHf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 02:35:58 -0500
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 13:04:39 +0530
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using global rwlocks as the backend for per-CPU rwlocks helps us avoid many
lock-ordering related problems (unlike per-cpu locks). However, global
rwlocks lead to unnecessary cache-line bouncing even when there are no
writers present, which can slow down the system needlessly.

Per-cpu counters can help solve the cache-line bouncing problem. So we
actually use the best of both: per-cpu counters (no-waiting) at the reader
side in the fast-path, and global rwlocks in the slowpath.

[ Fastpath = no writer is active; Slowpath = a writer is active ]

IOW, the readers just increment/decrement their per-cpu refcounts (disabling
interrupts during the updates, if necessary) when no writer is active.
When a writer becomes active, he signals all readers to switch to global
rwlocks for the duration of his activity. The readers switch over when it
is safe for them (ie., when they are about to start a fresh, non-nested
read-side critical section) and start using (holding) the global rwlock for
read in their subsequent critical sections.

The writer waits for every existing reader to switch, and then acquires the
global rwlock for write and enters his critical section. Later, the writer
signals all readers that he is done, and that they can go back to using their
per-cpu refcounts again.

Note that the lock-safety (despite the per-cpu scheme) comes from the fact
that the readers can *choose* _when_ to switch to rwlocks upon the writer's
signal. And the readers don't wait on anybody based on the per-cpu counters.
The only true synchronization that involves waiting at the reader-side in this
scheme, is the one arising from the global rwlock, which is safe from circular
locking dependency issues.

Reader-writer locks and per-cpu counters are recursive, so they can be
used in a nested fashion in the reader-path, which makes per-CPU rwlocks also
recursive. Also, this design of switching the synchronization scheme ensures
that you can safely nest and use these locks in a very flexible manner.

I'm indebted to Michael Wang and Xiao Guangrong for their numerous thoughtful
suggestions and ideas, which inspired and influenced many of the decisions in
this as well as previous designs. Thanks a lot Michael and Xiao!

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/percpu-rwlock.h |   10 +++
 lib/percpu-rwlock.c           |  128 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 136 insertions(+), 2 deletions(-)

diff --git a/include/linux/percpu-rwlock.h b/include/linux/percpu-rwlock.h
index 8dec8fe..6819bb8 100644
--- a/include/linux/percpu-rwlock.h
+++ b/include/linux/percpu-rwlock.h
@@ -68,4 +68,14 @@ extern void percpu_free_rwlock(struct percpu_rwlock *);
 	__percpu_init_rwlock(pcpu_rwlock, #pcpu_rwlock, &rwlock_key);	\
 })
 
+#define reader_uses_percpu_refcnt(pcpu_rwlock, cpu)			\
+		(ACCESS_ONCE(per_cpu(*((pcpu_rwlock)->reader_refcnt), cpu)))
+
+#define reader_nested_percpu(pcpu_rwlock)				\
+			(__this_cpu_read(*((pcpu_rwlock)->reader_refcnt)) > 1)
+
+#define writer_active(pcpu_rwlock)					\
+			(__this_cpu_read(*((pcpu_rwlock)->writer_signal)))
+
 #endif
+
diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index 80dad93..992da5c 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -64,21 +64,145 @@ void percpu_free_rwlock(struct percpu_rwlock *pcpu_rwlock)
 
 void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
 {
-	read_lock(&pcpu_rwlock->global_rwlock);
+	preempt_disable();
+
+	/* First and foremost, let the writer know that a reader is active */
+	this_cpu_inc(*pcpu_rwlock->reader_refcnt);
+
+	/*
+	 * If we are already using per-cpu refcounts, it is not safe to switch
+	 * the synchronization scheme. So continue using the refcounts.
+	 */
+	if (reader_nested_percpu(pcpu_rwlock)) {
+		goto out;
+	} else {
+		/*
+		 * The write to 'reader_refcnt' must be visible before we
+		 * read 'writer_signal'.
+		 */
+		smp_mb(); /* Paired with smp_rmb() in sync_reader() */
+
+		if (likely(!writer_active(pcpu_rwlock))) {
+			goto out;
+		} else {
+			/* Writer is active, so switch to global rwlock. */
+			read_lock(&pcpu_rwlock->global_rwlock);
+
+			/*
+			 * We might have raced with a writer going inactive
+			 * before we took the read-lock. So re-evaluate whether
+			 * we still need to hold the rwlock or if we can switch
+			 * back to per-cpu refcounts. (This also helps avoid
+			 * heterogeneous nesting of readers).
+			 */
+			if (writer_active(pcpu_rwlock))
+				this_cpu_dec(*pcpu_rwlock->reader_refcnt);
+			else
+				read_unlock(&pcpu_rwlock->global_rwlock);
+		}
+	}
+
+out:
+	/* Prevent reordering of any subsequent reads */
+	smp_rmb();
 }
 
 void percpu_read_unlock(struct percpu_rwlock *pcpu_rwlock)
 {
-	read_unlock(&pcpu_rwlock->global_rwlock);
+	/*
+	 * We never allow heterogeneous nesting of readers. So it is trivial
+	 * to find out the kind of reader we are, and undo the operation
+	 * done by our corresponding percpu_read_lock().
+	 */
+	if (__this_cpu_read(*pcpu_rwlock->reader_refcnt)) {
+		this_cpu_dec(*pcpu_rwlock->reader_refcnt);
+		smp_wmb(); /* Paired with smp_rmb() in sync_reader() */
+	} else {
+		read_unlock(&pcpu_rwlock->global_rwlock);
+	}
+
+	preempt_enable();
+}
+
+static inline void raise_writer_signal(struct percpu_rwlock *pcpu_rwlock,
+				       unsigned int cpu)
+{
+	per_cpu(*pcpu_rwlock->writer_signal, cpu) = true;
+}
+
+static inline void drop_writer_signal(struct percpu_rwlock *pcpu_rwlock,
+				      unsigned int cpu)
+{
+	per_cpu(*pcpu_rwlock->writer_signal, cpu) = false;
+}
+
+static void announce_writer_active(struct percpu_rwlock *pcpu_rwlock)
+{
+	unsigned int cpu;
+
+	for_each_online_cpu(cpu)
+		raise_writer_signal(pcpu_rwlock, cpu);
+
+	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
+}
+
+static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
+{
+	unsigned int cpu;
+
+	drop_writer_signal(pcpu_rwlock, smp_processor_id());
+
+	for_each_online_cpu(cpu)
+		drop_writer_signal(pcpu_rwlock, cpu);
+
+	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
+}
+
+/*
+ * Wait for the reader to see the writer's signal and switch from percpu
+ * refcounts to global rwlock.
+ *
+ * If the reader is still using percpu refcounts, wait for him to switch.
+ * Else, we can safely go ahead, because either the reader has already
+ * switched over, or the next reader that comes along on that CPU will
+ * notice the writer's signal and will switch over to the rwlock.
+ */
+static inline void sync_reader(struct percpu_rwlock *pcpu_rwlock,
+			       unsigned int cpu)
+{
+	smp_rmb(); /* Paired with smp_[w]mb() in percpu_read_[un]lock() */
+
+	while (reader_uses_percpu_refcnt(pcpu_rwlock, cpu))
+		cpu_relax();
+}
+
+static void sync_all_readers(struct percpu_rwlock *pcpu_rwlock)
+{
+	unsigned int cpu;
+
+	for_each_online_cpu(cpu)
+		sync_reader(pcpu_rwlock, cpu);
 }
 
 void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
 {
+	/*
+	 * Tell all readers that a writer is becoming active, so that they
+	 * start switching over to the global rwlock.
+	 */
+	announce_writer_active(pcpu_rwlock);
+	sync_all_readers(pcpu_rwlock);
 	write_lock(&pcpu_rwlock->global_rwlock);
 }
 
 void percpu_write_unlock(struct percpu_rwlock *pcpu_rwlock)
 {
+	/*
+	 * Inform all readers that we are done, so that they can switch back
+	 * to their per-cpu refcounts. (We don't need to wait for them to
+	 * see it).
+	 */
+	announce_writer_inactive(pcpu_rwlock);
 	write_unlock(&pcpu_rwlock->global_rwlock);
 }
 
