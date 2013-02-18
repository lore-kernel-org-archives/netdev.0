From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 02/46] percpu_rwlock: Introduce per-CPU variables for the
 reader and the writer
Date: Mon, 18 Feb 2013 18:08:45 +0530
Message-ID: <20130218123845.26245.58287.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
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

 include/linux/percpu-rwlock.h |    8 ++++++++
 lib/percpu-rwlock.c           |   12 ++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/percpu-rwlock.h b/include/linux/percpu-rwlock.h
index 0caf81f..74eaf4d 100644
--- a/include/linux/percpu-rwlock.h
+++ b/include/linux/percpu-rwlock.h
@@ -28,7 +28,13 @@
 #include <linux/lockdep.h>
 #include <linux/spinlock.h>
 
+struct rw_state {
+	unsigned long	reader_refcnt;
+	bool		writer_signal;
+};
+
 struct percpu_rwlock {
+	struct rw_state __percpu	*rw_state;
 	rwlock_t			global_rwlock;
 };
 
@@ -41,6 +47,8 @@ extern void percpu_write_unlock(struct percpu_rwlock *);
 extern int __percpu_init_rwlock(struct percpu_rwlock *,
 				const char *, struct lock_class_key *);
 
+extern void percpu_free_rwlock(struct percpu_rwlock *);
+
 #define percpu_init_rwlock(pcpu_rwlock)					\
 ({	static struct lock_class_key rwlock_key;			\
 	__percpu_init_rwlock(pcpu_rwlock, #pcpu_rwlock, &rwlock_key);	\
diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index 111a238..f938096 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -31,6 +31,10 @@
 int __percpu_init_rwlock(struct percpu_rwlock *pcpu_rwlock,
 			 const char *name, struct lock_class_key *rwlock_key)
 {
+	pcpu_rwlock->rw_state = alloc_percpu(struct rw_state);
+	if (unlikely(!pcpu_rwlock->rw_state))
+		return -ENOMEM;
+
 	/* ->global_rwlock represents the whole percpu_rwlock for lockdep */
 #ifdef CONFIG_DEBUG_SPINLOCK
 	__rwlock_init(&pcpu_rwlock->global_rwlock, name, rwlock_key);
@@ -41,6 +45,14 @@ int __percpu_init_rwlock(struct percpu_rwlock *pcpu_rwlock,
 	return 0;
 }
 
+void percpu_free_rwlock(struct percpu_rwlock *pcpu_rwlock)
+{
+	free_percpu(pcpu_rwlock->rw_state);
+
+	/* Catch use-after-free bugs */
+	pcpu_rwlock->rw_state = NULL;
+}
+
 void percpu_read_lock(struct percpu_rwlock *pcpu_rwlock)
 {
 	read_lock(&pcpu_rwlock->global_rwlock);
