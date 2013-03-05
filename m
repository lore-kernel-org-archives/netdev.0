From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH V2] lglock: add read-preference local-global rwlock
Date: Tue, 5 Mar 2013 08:19:12 -0800
Message-ID: <20130305161912.GA30756@google.com>
References: <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
 <512D0D67.9010609@linux.vnet.ibm.com>
 <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>
 <512E7879.20109@linux.vnet.ibm.com>
 <5130E8E2.50206@cn.fujitsu.com>
 <20130301182854.GA3631@redhat.com>
 <CANN689HEW=b5S93J27p+rBX-5m7jkW4FER=eHDCp7OgMaTWLPw@mail.gmail.com>
 <5131FB4C.7070408@cn.fujitsu.com>
 <20130302172003.GC29769@redhat.com>
 <51360ED1.3030104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	sbw@mit.edu, tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51360ED1.3030104@cn.fujitsu.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Lai,

Just a few comments about your v2 proposal. Hopefully you'll catch
these before you send out v3 :)

- I would prefer reader_refcnt to be unsigned int instead of unsigned long
- I would like some comment to indicate that lgrwlocks don't have
  reader-writer fairness and are thus somewhat discouraged
  (people could use plain lglock if they don't need reader preference,
  though even that use (as brlock) is discouraged already :)
- I don't think FALLBACK_BASE is necessary (you already mentioned you'd
  drop it)
- I prefer using the fallback_rwlock's dep_map for lockdep tracking.
  I feel this is more natural since we want the lgrwlock to behave as
  the rwlock, not as the lglock.
- I prefer to avoid return statements in the middle of functions when
  it's easyto do so.

Attached is my current version (based on an earlier version of your code).
You don't have to take it as is but I feel it makes for a more concrete
suggestion :)

Thanks,

----------------------------8<-------------------------------------------
lglock: add read-preference lgrwlock

Current lglock may be used as a fair rwlock; however sometimes a
read-preference rwlock is preferred. One such use case recently came
up for get_cpu_online_atomic().

This change adds a new lgrwlock with the following properties:
- high performance read side, using only cpu-local structures when there
  is no write side to contend with;
- correctness guarantees similar to rwlock_t: recursive readers are allowed
  and the lock's read side is not ordered vs other locks;
- low performance write side (comparable to lglocks' global side).

The implementation relies on the following principles:
- reader_refcnt is a local lock count; it indicates how many recursive
  read locks are taken using the local lglock;
- lglock is used by readers for local locking; it must be acquired
  before reader_refcnt becomes nonzero and released after reader_refcnt
  goes back to zero;
- fallback_rwlock is used by readers for global locking; it is acquired
  when fallback_reader_refcnt is zero and the trylock fails on lglock.
- writers take both the lglock write side and the fallback_rwlock, thus
  making sure to exclude both local and global readers.

Thanks to Srivatsa S. Bhat for proposing a lock with these requirements
and Lai Jiangshan for proposing this algorithm as an lglock extension.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/lglock.h | 46 +++++++++++++++++++++++++++++++++++++++
 kernel/lglock.c        | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+)

diff --git a/include/linux/lglock.h b/include/linux/lglock.h
index 0d24e932db0b..8b59084935d5 100644
--- a/include/linux/lglock.h
+++ b/include/linux/lglock.h
@@ -67,4 +67,50 @@ void lg_local_unlock_cpu(struct lglock *lg, int cpu);
 void lg_global_lock(struct lglock *lg);
 void lg_global_unlock(struct lglock *lg);
 
+/*
+ * lglock may be used as a read write spinlock if desired (though this is
+ * not encouraged as the write side scales badly on high CPU count machines).
+ * It has reader/writer fairness when used that way.
+ *
+ * However, sometimes it is desired to have an unfair rwlock instead, with
+ * reentrant readers that don't need to be ordered vs other locks, comparable
+ * to rwlock_t. lgrwlock implements such semantics.
+ */
+struct lgrwlock {
+	unsigned int __percpu *reader_refcnt;
+	struct lglock lglock;
+	rwlock_t fallback_rwlock;
+};
+
+#define __DEFINE_LGRWLOCK_PERCPU_DATA(name)				\
+	static DEFINE_PER_CPU(unsigned int, name ## _refcnt);		\
+	static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)		\
+	= __ARCH_SPIN_LOCK_UNLOCKED;
+
+#define __LGRWLOCK_INIT(name) {						\
+	.reader_refcnt = &name ## _refcnt,				\
+	.lglock = { .lock = &name ## _lock },				\
+	.fallback_rwlock = __RW_LOCK_UNLOCKED(name.fallback_rwlock)	\
+}
+
+#define DEFINE_LGRWLOCK(name)						\
+	__DEFINE_LGRWLOCK_PERCPU_DATA(name)				\
+	struct lgrwlock name = __LGRWLOCK_INIT(name)
+
+#define DEFINE_STATIC_LGRWLOCK(name)					\
+	__DEFINE_LGRWLOCK_PERCPU_DATA(name)				\
+	static struct lgrwlock name = __LGRWLOCK_INIT(name)
+
+static inline void lg_rwlock_init(struct lgrwlock *lgrw, char *name)
+{
+	lg_lock_init(&lgrw->lglock, name);
+}
+
+void lg_read_lock(struct lgrwlock *lgrw);
+void lg_read_unlock(struct lgrwlock *lgrw);
+void lg_write_lock(struct lgrwlock *lgrw);
+void lg_write_unlock(struct lgrwlock *lgrw);
+void __lg_read_write_lock(struct lgrwlock *lgrw);
+void __lg_read_write_unlock(struct lgrwlock *lgrw);
+
 #endif
diff --git a/kernel/lglock.c b/kernel/lglock.c
index 86ae2aebf004..e78a7c95dbfd 100644
--- a/kernel/lglock.c
+++ b/kernel/lglock.c
@@ -87,3 +87,61 @@ void lg_global_unlock(struct lglock *lg)
 	preempt_enable();
 }
 EXPORT_SYMBOL(lg_global_unlock);
+
+void lg_read_lock(struct lgrwlock *lgrw)
+{
+	preempt_disable();
+
+	if (__this_cpu_read(*lgrw->reader_refcnt) ||
+	    arch_spin_trylock(this_cpu_ptr(lgrw->lglock.lock))) {
+		__this_cpu_inc(*lgrw->reader_refcnt);
+		rwlock_acquire_read(&lgrw->fallback_rwlock.dep_map,
+				    0, 0, _RET_IP_);
+	} else {
+		read_lock(&lgrw->fallback_rwlock);
+	}
+}
+EXPORT_SYMBOL(lg_read_lock);
+
+void lg_read_unlock(struct lgrwlock *lgrw)
+{
+	if (likely(__this_cpu_read(*lgrw->reader_refcnt))) {
+		rwlock_release(&lgrw->fallback_rwlock.dep_map,
+			       1, _RET_IP_);
+		if (!__this_cpu_dec_return(*lgrw->reader_refcnt))
+			arch_spin_unlock(this_cpu_ptr(lgrw->lglock.lock));
+	} else {
+		read_unlock(&lgrw->fallback_rwlock);
+	}
+
+	preempt_enable();
+}
+EXPORT_SYMBOL(lg_read_unlock);
+
+void lg_write_lock(struct lgrwlock *lgrw)
+{
+	lg_global_lock(&lgrw->lglock);
+	write_lock(&lgrw->fallback_rwlock);
+}
+EXPORT_SYMBOL(lg_write_lock);
+
+void lg_write_unlock(struct lgrwlock *lgrw)
+{
+	write_unlock(&lgrw->fallback_rwlock);
+	lg_global_unlock(&lgrw->lglock);
+}
+EXPORT_SYMBOL(lg_write_unlock);
+
+void __lg_read_write_lock(struct lgrwlock *lgrw)
+{
+	lg_write_lock(lgrw);
+	__this_cpu_write(*lgrw->reader_refcnt, 1);
+}
+EXPORT_SYMBOL(__lg_read_write_lock);
+
+void __lg_read_write_unlock(struct lgrwlock *lgrw)
+{
+	__this_cpu_write(*lgrw->reader_refcnt, 0);
+	lg_write_unlock(lgrw);
+}
+EXPORT_SYMBOL(__lg_read_write_unlock);

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
