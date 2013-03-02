From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH V2] lglock: add read-preference local-global rwlock
Date: Sat, 02 Mar 2013 21:14:52 +0800
Message-ID: <5131FB4C.7070408@cn.fujitsu.com>
References: <512BBAD8.8010006@linux.vnet.ibm.com>	<CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>	<512C7A38.8060906@linux.vnet.ibm.com>	<CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com>	<512CC509.1050000@linux.vnet.ibm.com>	<CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>	<512D0D67.9010609@linux.vnet.ibm.com>	<CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>	<512E7879.20109@linux.vnet.ibm.com>	<5130E8E2.50206@cn.fujitsu.com>	<20130301182854.GA3631@redhat.com>
 <CANN689HEW=b5S93J27p+rBX-5m7jkW4FER=eHDCp7OgMaTWLPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
 peterz@infradead.org, fweisbec@gmail.com, linux-kernel@vger.kernel.org,
 mingo@kernel.org, linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
 xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
 paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
 linux-pm@vger.kernel.org, rusty@rustcorp.com.au, rostedt@goodmis.org,
 rjw@sisk.pl, namhyung@kernel.org, tglx@linutronix.de,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 Oleg Nesterov <oleg@redhat.com>, vincent.guittot@linaro.org, sbw@mit.edu,
 tj@kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Michel Lespinasse <walken@google.com>,
 "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <CANN689HEW=b5S93J27p+rBX-5m7jkW4FER=eHDCp7OgMaTWLPw@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

>From 345a7a75c314ff567be48983e0892bc69c4452e7 Mon Sep 17 00:00:00 2001
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Sat, 2 Mar 2013 20:33:14 +0800
Subject: [PATCH] lglock: add read-preference local-global rwlock

Current lglock is not read-preference, so it can't be used on some cases
which read-preference rwlock can do. Example, get_cpu_online_atomic().

Although we can use rwlock for these cases which needs read-preference.
but it leads to unnecessary cache-line bouncing even when there are no
writers present, which can slow down the system needlessly. It will be
worse when we have a lot of CPUs, it is not scale.

So we look forward to lglock. lglock is read-write-lock based on percpu locks,
but it is not read-preference due to its underlining percpu locks.

But what if we convert the percpu locks of lglock to use percpu rwlocks:

         CPU 0                                CPU 1
         ------                               ------
1.    spin_lock(&random_lock);             read_lock(my_rwlock of CPU 1);
2.    read_lock(my_rwlock of CPU 0);       spin_lock(&random_lock);

Writer:
         CPU 2:
         ------
      for_each_online_cpu(cpu)
        write_lock(my_rwlock of 'cpu');


Consider what happens if the writer begins his operation in between steps 1
and 2 at the reader side. It becomes evident that we end up in a (previously
non-existent) deadlock due to a circular locking dependency between the 3
entities, like this:


(holds              Waiting for
 random_lock) CPU 0 -------------> CPU 2  (holds my_rwlock of CPU 0
                                               for write)
               ^                   |
               |                   |
        Waiting|                   | Waiting
          for  |                   |  for
               |                   V
                ------ CPU 1 <------

                (holds my_rwlock of
                 CPU 1 for read)


So obviously this "straight-forward" way of implementing percpu rwlocks is
deadlock-prone. So we can't implement read-preference local-global rwlock
like this.


The implement of this patch reuse current lglock as frontend to achieve
local-read-lock, and reuse global fallback rwlock as backend to achieve
read-preference, and use percpu reader counter to indicate 1) the depth
of the nested reader lockes and 2) whether the outmost lock is percpu lock
or fallback rwlock.

The algorithm is simple, in the read site:
If it is nested reader, just increase the counter
If it is the outmost reader,
	1) try to lock its cpu's lock of the frontend lglock.
	   (reader count +=1 if success)
	2) if the above step fails, read_lock(&fallback_rwlock).
	   (reader count += FALLBACK_BASE + 1)

Write site:
Do the lg_global_lock() of the frontend lglock.
And then write_lock(&fallback_rwlock).


Prof:
1) reader-writer exclusive:
write-site must requires all percpu locks and fallback_rwlock.
outmost read-site must requires one of these locks.

2) read-preference:
before write site lock finished acquired, read site at least
wins at read_lock(&fallback_rwlock) due to rwlock is read-preference.

3) read site functions are irqsafe(reentrance-safe)
   (read site functions is not protected by disabled irq, but they are irqsafe)
	If read site function is interrupted at any point and reenters read site
again, reentranced read site will not be mislead by the first read site if the
reader counter > 0, in this case, it means currently frontend(this cpu lock of
lglock) or backend(fallback rwlock) lock is held, it is safe to act as
nested reader.
	if the reader counter=0, eentranced reader considers it is the
outmost read site, and it always successes after the write side release the lock.
(even the interrupted read-site has already hold the cpu lock of lglock
or the fallback_rwlock).
	And reentranced read site only calls arch_spin_trylock(), read_lock()
and __this_cpu_op(), arch_spin_trylock(), read_lock() is already reentrance-safe.
Although __this_cpu_op() is not reentrance-safe, but the value of the counter
will be restored after the interrupted finished, so read site functions
are still reentrance-safe.


Performance:
We only focus on the performance of the read site. this read site's fast path
is just preempt_disable() + __this_cpu_read/inc() + arch_spin_trylock(),
It has only one heavy memory operation. it will be expected fast.

We test three locks.
1) traditional rwlock WITHOUT remote competition nor cache-bouncing.(opt-rwlock)
2) this lock(lgrwlock)
3) V6 percpu-rwlock by "Srivatsa S. Bhat". (percpu-rwlock)
   (https://lkml.org/lkml/2013/2/18/186)

		nested=1(no nested)	nested=2	nested=4
opt-rwlock	 517181			1009200		2010027
lgrwlock	 452897			 700026		1201415
percpu-rwlock	1192955			1451343		1951757

The value is the time(nano-second) of 10000 times of the operations
{
	read-lock
	[nested read-lock]...
	[nested read-unlock]...
	read-unlock
}
If the way of this test is wrong nor bad, please correct me,
the code of test is here: https://gist.github.com/laijs/5066159
(i5 760, 64bit)

Changed from V1
 fix a reentrance-bug which is cought by Oleg
 don't touch lockdep for nested reader(needed by below change)
 add two special APIs for cpuhotplug.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/lglock.h |   38 ++++++++++++++++++++++++++
 kernel/lglock.c        |   68 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/include/linux/lglock.h b/include/linux/lglock.h
index 0d24e93..90bfe79 100644
--- a/include/linux/lglock.h
+++ b/include/linux/lglock.h
@@ -67,4 +67,42 @@ void lg_local_unlock_cpu(struct lglock *lg, int cpu);
 void lg_global_lock(struct lglock *lg);
 void lg_global_unlock(struct lglock *lg);
 
+/* read-preference read-write-lock like rwlock but provides local-read-lock */
+struct lgrwlock {
+	unsigned long __percpu *reader_refcnt;
+	struct lglock lglock;
+	rwlock_t fallback_rwlock;
+};
+
+#define __DEFINE_LGRWLOCK_PERCPU_DATA(name)				\
+	static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)		\
+	= __ARCH_SPIN_LOCK_UNLOCKED;					\
+	static DEFINE_PER_CPU(unsigned long, name ## _refcnt);
+
+#define __LGRWLOCK_INIT(name)						\
+	{								\
+		.reader_refcnt = &name ## _refcnt,			\
+		.lglock = { .lock = &name ## _lock },			\
+		.fallback_rwlock = __RW_LOCK_UNLOCKED(name.fallback_rwlock)\
+	}
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
+void lg_rwlock_local_read_lock(struct lgrwlock *lgrw);
+void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw);
+void lg_rwlock_global_write_lock(struct lgrwlock *lgrw);
+void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw);
+void __lg_rwlock_global_read_write_lock(struct lgrwlock *lgrw);
+void __lg_rwlock_global_read_write_unlock(struct lgrwlock *lgrw);
 #endif
diff --git a/kernel/lglock.c b/kernel/lglock.c
index 6535a66..52e9b2c 100644
--- a/kernel/lglock.c
+++ b/kernel/lglock.c
@@ -87,3 +87,71 @@ void lg_global_unlock(struct lglock *lg)
 	preempt_enable();
 }
 EXPORT_SYMBOL(lg_global_unlock);
+
+#define FALLBACK_BASE	(1UL << 30)
+
+void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
+{
+	struct lglock *lg = &lgrw->lglock;
+
+	preempt_disable();
+	if (likely(!__this_cpu_read(*lgrw->reader_refcnt))) {
+		rwlock_acquire_read(&lg->lock_dep_map, 0, 0, _RET_IP_);
+		if (unlikely(!arch_spin_trylock(this_cpu_ptr(lg->lock)))) {
+			read_lock(&lgrw->fallback_rwlock);
+			__this_cpu_write(*lgrw->reader_refcnt, FALLBACK_BASE);
+			return;
+		}
+	}
+
+	__this_cpu_inc(*lgrw->reader_refcnt);
+}
+EXPORT_SYMBOL(lg_rwlock_local_read_lock);
+
+void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
+{
+	switch (__this_cpu_read(*lgrw->reader_refcnt)) {
+	case 1:
+		__this_cpu_write(*lgrw->reader_refcnt, 0);
+		lg_local_unlock(&lgrw->lglock);
+		return;
+	case FALLBACK_BASE:
+		__this_cpu_write(*lgrw->reader_refcnt, 0);
+		read_unlock(&lgrw->fallback_rwlock);
+		rwlock_release(&lg->lock_dep_map, 1, _RET_IP_);
+		break;
+	default:
+		__this_cpu_dec(*lgrw->reader_refcnt);
+		break;
+	}
+
+	preempt_enable();
+}
+EXPORT_SYMBOL(lg_rwlock_local_read_unlock);
+
+void lg_rwlock_global_write_lock(struct lgrwlock *lgrw)
+{
+	lg_global_lock(&lgrw->lglock);
+	write_lock(&lgrw->fallback_rwlock);
+}
+EXPORT_SYMBOL(lg_rwlock_global_write_lock);
+
+void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw)
+{
+	write_unlock(&lgrw->fallback_rwlock);
+	lg_global_unlock(&lgrw->lglock);
+}
+EXPORT_SYMBOL(lg_rwlock_global_write_unlock);
+
+/* special write-site APIs allolw nested reader in such write-site */
+void __lg_rwlock_global_read_write_lock(struct lgrwlock *lgrw)
+{
+	lg_rwlock_global_write_lock(lgrw);
+	__this_cpu_write(*lgrw->reader_refcnt, 1);
+}
+
+void __lg_rwlock_global_read_write_unlock(struct lgrwlock *lgrw)
+{
+	__this_cpu_write(*lgrw->reader_refcnt, 0);
+	lg_rwlock_global_write_unlock(lgrw);
+}
-- 
1.7.7.6
