From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Wed, 27 Feb 2013 19:11:34 +0800
Message-ID: <CANN689FuuEb9wpV43DkTtgv6syvBYL-LQxByWznyAq8dkrhzBw@mail.gmail.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
	<20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com>
	<CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
	<5122551E.1080703@linux.vnet.ibm.com>
	<51226B46.9080707@linux.vnet.ibm.com>
	<CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com>
	<51226F91.7000108@linux.vnet.ibm.com>
	<CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com>
	<512BBAD8.8010006@linux.vnet.ibm.com>
	<CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>
	<512C7A38.8060906@linux.vnet.ibm.com>
	<CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com>
	<512CC509.1050000@linux.vnet.ibm.com>
	<CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
	<512D0D67.9010609@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <512D0D67.9010609@linux.vnet.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Srivatsa,

I think there is some elegance in Lai's proposal of using a local
trylock for the reader uncontended case and global rwlock to deal with
the contended case without deadlocks. He apparently didn't realize
initially that nested read locks are common, and he seems to have
confused you because of that, but I think his proposal could be
changed easily to account for that and result in short, easily
understood code. What about the following:

- local_refcnt is a local lock count; it indicates how many recursive
locks are taken using the local lglock
- lglock is used by readers for local locking; it must be acquired
before local_refcnt becomes nonzero and released after local_refcnt
goes back to zero.
- fallback_rwlock is used by readers for global locking; it is
acquired when fallback_reader_refcnt is zero and the trylock fails on
lglock

+void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
+{
+       preempt_disable();
+
+       if (__this_cpu_read(*lgrw->local_refcnt) ||
+           arch_spin_trylock(this_cpu_ptr(lgrw->lglock->lock))) {
+               __this_cpu_inc(*lgrw->local_refcnt);
+
rwlock_acquire_read(&lgrw->fallback_rwlock->lock_dep_map, 0, 0,
_RET_IP_);
+       } else {
+               read_lock(&lgrw->fallback_rwlock);
+       }
+}
+EXPORT_SYMBOL(lg_rwlock_local_read_lock);
+
+void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
+{
+       if (likely(__this_cpu_read(*lgrw->local_refcnt))) {
+               rwlock_release(&lgrw->fallback_rwlock->lock_dep_map,
1, _RET_IP_);
+               if (!__this_cpu_dec_return(*lgrw->local_refcnt))
+                       arch_spin_unlock(this_cpu_ptr(lgrw->lglock->lock));
+       } else {
+               read_unlock(&lgrw->fallback_rwlock);
+       }
+
+       preempt_enable();
+}
+EXPORT_SYMBOL(lg_rwlock_local_read_unlock);
+
+void lg_rwlock_global_write_lock(struct lgrwlock *lgrw)
+{
+       int i;
+
+       preempt_disable();
+
+       for_each_possible_cpu(i)
+               arch_spin_lock(per_cpu_ptr(lgrw->lglock->lock, i));
+       write_lock(&lgrw->fallback_rwlock);
+}
+EXPORT_SYMBOL(lg_rwlock_global_write_lock);
+
+void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw)
+{
+       int i;
+
+       write_unlock(&lgrw->fallback_rwlock);
+       for_each_possible_cpu(i)
+               arch_spin_unlock(per_cpu_ptr(lgrw->lglock->lock, i));
+
+       preempt_enable();
+}
+EXPORT_SYMBOL(lg_rwlock_global_write_unlock);

This is to me relatively easier to understand than Srivatsa's
proposal. Now I'm not sure who wins efficiency wise, but I think it
should be relatively close as readers at least don't touch shared
state in the uncontended case (even with some recursion going on).

There is an interesting case where lg_rwlock_local_read_lock could be
interrupted after getting the local lglock but before incrementing
local_refcnt to 1; if that happens any nested readers within that
interrupt will have to take the global rwlock read side. I think this
is perfectly acceptable as this should not be a common case though
(and thus the global rwlock cache line probably wouldn't even bounce
between cpus then).

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
