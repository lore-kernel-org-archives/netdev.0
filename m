From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 02/45] percpu_rwlock: Introduce per-CPU variables for the
 reader and the writer
Date: Tue, 22 Jan 2013 13:03:32 +0530
Message-ID: <20130122073327.13822.96745.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Per-CPU rwlocks ought to give better performance than global rwlocks.
That is where the "per-CPU" component comes in. So introduce the necessary
per-CPU variables that would be necessary at the reader and the writer sides,
and add the support for dynamically initializing per-CPU rwlocks.
These per-CPU variables will be used subsequently to implement the core
algorithm behind per-CPU rwlocks.

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/percpu-rwlock.h |    4 ++++
 lib/percpu-rwlock.c           |   21 +++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/linux/percpu-rwlock.h b/include/linux/percpu-rwlock.h
index 45620d0..cd5eab5 100644
--- a/include/linux/percpu-rwlock.h
+++ b/include/linux/percpu-rwlock.h
@@ -29,6 +29,8 @@
 #include <linux/spinlock.h>
 
 struct percpu_rwlock {
+	unsigned long __percpu	*reader_refcnt;
+	bool __percpu		*writer_signal;
 	rwlock_t		global_rwlock;
 };
 
@@ -41,6 +43,8 @@ extern void percpu_write_unlock(struct percpu_rwlock *);
 extern int __percpu_init_rwlock(struct percpu_rwlock *,
 				const char *, struct lock_class_key *);
 
+extern void percpu_free_rwlock(struct percpu_rwlock *);
+
 #define percpu_init_rwlock(pcpu_rwlock)					\
 ({	static struct lock_class_key rwlock_key;			\
 	__percpu_init_rwlock(pcpu_rwlock, #pcpu_rwlock, &rwlock_key);	\
diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index af0c714..80dad93 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -31,6 +31,17 @@
 int __percpu_init_rwlock(struct percpu_rwlock *pcpu_rwlock,
 			 const char *name, struct lock_class_key *rwlock_key)
 {
+	pcpu_rwlock->reader_refcnt = alloc_percpu(unsigned long);
+	if (unlikely(!pcpu_rwlock->reader_refcnt))
+		return -ENOMEM;
+
+	pcpu_rwlock->writer_signal = alloc_percpu(bool);
+	if (unlikely(!pcpu_rwlock->writer_signal)) {
+		free_percpu(pcpu_rwlock->reader_refcnt);
+		pcpu_rwlock->reader_refcnt = NULL;
+		return -ENOMEM;
+	}
+
 	/* ->global_rwlock represents the whole percpu_rwlock for lockdep */
 #ifdef CONFIG_DEBUG_SPINLOCK
 	__rwlock_init(&pcpu_rwlock->global_rwlock, name, rwlock_key);
@@ -41,6 +52,16 @@ int __percpu_init_rwlock(struct percpu_rwlock *pcpu_rwlock,
 	return 0;
 }
 
+void percpu_free_rwlock(struct percpu_rwlock *pcpu_rwlock)
+{
+	free_percpu(pcpu_rwlock->reader_refcnt);
+	free_percpu(pcpu_rwlock->writer_signal);
+
+	/* Catch use-after-free bugs */
+	pcpu_rwlock->reader_refcnt = NULL;
+	pcpu_rwlock->writer_signal = NULL;
+}
+
 void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
 {
 	read_lock(&pcpu_rwlock->global_rwlock);
