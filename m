From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Tue, 21 Apr 2015 10:59:37 +0200
Message-ID: <3755355.Xf0HbltZXg@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <1429509459-17068-5-git-send-email-baolin.wang@linaro.org> <alpine.DEB.2.11.1504202131500.13914@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Baolin Wang <baolin.wang@linaro.org>, pang.xunlei@linaro.org,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, paulus@samba.org, cl@linux.com,
	heenasirwani@gmail.com, linux-arch@vger.kernel.org,
	linux-s390@vger.kernel.org, mpe@ellerman.id.au,
	rafael.j.wysocki@intel.com, ahh@google.com, fweisbec@gmail.com,
	pjt@google.com, riel@redhat.com, richardcochran@gmail.com,
	schwidefsky@de.ibm.com, john.stultz@linaro.org, rth@twiddle.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
	linuxppc-dev@lists.ozlabs.org
To: y2038@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1504202131500.13914@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 20 April 2015 22:40:57 Thomas Gleixner wrote:
> On Mon, 20 Apr 2015, Baolin Wang wrote:
> > @@ -771,6 +771,7 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
> >  		struct itimerspec __user *, setting)
> >  {
> >  	struct itimerspec cur_setting;
> > +	struct itimerspec64 cur_setting64;
> >  	struct k_itimer *timr;
> >  	struct k_clock *kc;
> >  	unsigned long flags;
> > @@ -781,10 +782,16 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
> >  		return -EINVAL;
> >  
> >  	kc = clockid_to_kclock(timr->it_clock);
> > -	if (WARN_ON_ONCE(!kc || !kc->timer_get))
> > +	if (WARN_ON_ONCE(!kc || (!kc->timer_get && !kc->timer_get64))) {
> >  		ret = -EINVAL;
> > -	else
> > -		kc->timer_get(timr, &cur_setting);
> > +	} else {
> > +		if (kc->timer_get64) {
> > +			kc->timer_get64(timr, &cur_setting64);
> > +			cur_setting = itimerspec64_to_itimerspec(cur_setting64);
> > +		} else {
> > +			kc->timer_get(timr, &cur_setting);
> > +		}
> > +	}
> 
> This is really horrible. You add a metric ton of conditionals to every
> syscall just to remove them later again. I have not yet checked the
> end result, but this approach is error prone as hell and just
> introduces completely useless code churn.
> 
> It's useless because you do not factor out the guts of the syscall
> functions so we can reuse the very same logic for the future 2038 safe
> syscalls which we need to introduce for 32bit machines.

Hi Thomas,

I should probably go ahead and introduce all the new syscalls in a
separate patch series. I have my own ideas about how to get there,
in a slightly different way from what you propose:

> Take a look at the compat syscalls. They do the right thing.
> 
> COMPAT_SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
>                        struct compat_itimerspec __user *, setting)
> {
>         long err;
>         mm_segment_t oldfs;
>         struct itimerspec ts;
> 
>         oldfs = get_fs();
>         set_fs(KERNEL_DS);
>         err = sys_timer_gettime(timer_id,
>                                 (struct itimerspec __user *) &ts);
>         set_fs(oldfs);
>         if (!err && put_compat_itimerspec(setting, &ts))
>                 return -EFAULT;
>         return err;
> }

As a side note, I want to kill off the get_fs()/set_fs() calls in
the process. These always make me dizzy when I try to work out whether
there is a potential security hole (there is not in this case), and
they can be slow on some architectures.

> So we can be clever and do the following:
> 
> 1) Preparatory work in posix-timer.c (Patch #1)
>
> 2) Do the 64bit infrastructure work in posix-timer.c (Patch #2)
> 
> The result is two simple to review patches with minimal code churn.

This all sounds great, good idea.

> The nice thing is that once we introduce new syscalls for 32bit
> machines, e.g. sys_timer_gettime64(), all we need to do is:
> 
> /* Get the time remaining on a POSIX.1b interval timer. */
> SYSCALL_DEFINE2(timer_gettime64, timer_t, timer_id,
> 		struct itimerspec64 __user *, setting)
> {
> 	struct itimerspec64 cur_setting64;
> 	int ret = __timer_gettime(timer_id, &cur_setting64);
> 
> 	if (!ret && copy_to_user(setting, &cur_setting, sizeof (cur_setting)))
> 		return -EFAULT;
> 
> 	return ret;
> }
> 
> And on 64bit timer_gettime64() and timer_gettime() are the same, so we
> just need to do a clever mapping of timer_gettime() to
> timer_gettime64(). Not rocket science....
> 
> For 32 bit we provide the old timer_gettime() for non converted
> applications:
> 
> #ifdef CONFIG_32BIT_OLD_TIMESPEC_SYSCALLS
> /* Get the time remaining on a POSIX.1b interval timer in the old timespec format. */
> SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
> 		struct itimerspec __user *, setting)
> {
> 	struct itimerspec64 cur_setting64;
> 	struct itimerspec cur_setting;
> 	int ret = __timer_gettime(timer_id, &cur_setting64);
> 
> 	if (!ret) {
> 		cur_setting = itimerspec64_to_itimerspec(&cur_setting64);
> 
> 		if (copy_to_user(setting, &cur_setting, sizeof (cur_setting)))
> 		   	return -EFAULT;
> 	}
> 	return ret;
> }
> #endif
> 
> Simple, isn't it? No useless churn. Proper refactoring for the next
> step. No useless copying for 64 bit.

My preferred solution is one where we end up with the same syscalls for
both 32-bit and 64-bit, and basically use the compat_sys_timer_gettime()
implementation (or a simplified version) for the existing , something like this:

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index ef8187f9d28d..71e74a47a2cf 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -267,7 +267,7 @@
 258	i386	set_tid_address		sys_set_tid_address
 259	i386	timer_create		sys_timer_create		compat_sys_timer_create
 260	i386	timer_settime		sys_timer_settime		compat_sys_timer_settime
-261	i386	timer_gettime		sys_timer_gettime		compat_sys_timer_gettime
+261	i386	timer_gettime		compat_sys_timer_gettime
 262	i386	timer_getoverrun	sys_timer_getoverrun
 263	i386	timer_delete		sys_timer_delete
 264	i386	clock_settime		sys_clock_settime		compat_sys_clock_settime
@@ -365,3 +365,4 @@
 356	i386	memfd_create		sys_memfd_create
 357	i386	bpf			sys_bpf
 358	i386	execveat		sys_execveat			stub32_execveat
+359	i386	timer_gettime64		sys_timer_gettime
diff --git a/kernel/compat.c b/kernel/compat.c
index 24f00610c575..15d4f5abb492 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -723,18 +723,14 @@ COMPAT_SYSCALL_DEFINE4(timer_settime, timer_t, timer_id, int, flags,
 COMPAT_SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		       struct compat_itimerspec __user *, setting)
 {
-	long err;
-	mm_segment_t oldfs;
-	struct itimerspec ts;
+	struct itimerspec64 ts;
+	long ret;
 
-	oldfs = get_fs();
-	set_fs(KERNEL_DS);
-	err = sys_timer_gettime(timer_id,
-				(struct itimerspec __user *) &ts);
-	set_fs(oldfs);
-	if (!err && put_compat_itimerspec(setting, &ts))
-		return -EFAULT;
-	return err;
+	ret = __timer_gettime(timer_id, &ts);
+	if (ret)
+		return ret;
+
+	return put_compat_itimerspec(setting, &ts);
 }
 
 COMPAT_SYSCALL_DEFINE2(clock_settime, clockid_t, which_clock,
diff --git a/kernel/time/posix-timers.c b/kernel/time/posix-timers.c
index 31ea01f42e1f..c601f1969f5a 100644
--- a/kernel/time/posix-timers.c
+++ b/kernel/time/posix-timers.c
@@ -766,32 +766,27 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
 		cur_setting->it_value = ktime_to_timespec(remaining);
 }
 
+static int put_compat_itimerspec(struct __kernel_itimerspec64 __user *dst,
+				 const struct itimerspec64 *src)
+{
+	if (__put_timespec64(&src->it_interval, &dst->it_interval) ||
+	    __put_timespec64(&src->it_value, &dst->it_value))
+		return -EFAULT;
+        return 0;
+}
+
 /* Get the time remaining on a POSIX.1b interval timer. */
 SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
-		struct itimerspec __user *, setting)
+		struct __kernel_itimerspec64 __user *, setting)
 {
-	struct itimerspec cur_setting;
-	struct k_itimer *timr;
-	struct k_clock *kc;
-	unsigned long flags;
-	int ret = 0;
-
-	timr = lock_timer(timer_id, &flags);
-	if (!timr)
-		return -EINVAL;
+	struct itimerspec64 cur_setting;
+	int ret;
 
-	kc = clockid_to_kclock(timr->it_clock);
-	if (WARN_ON_ONCE(!kc || !kc->timer_get))
-		ret = -EINVAL;
-	else
-		kc->timer_get(timr, &cur_setting);
+	ret = __timer_gettime(timer_id, &cur_setting);
+	if (ret)
+		return ret;
 
-	unlock_timer(timr, flags);
-
-	if (!ret && copy_to_user(setting, &cur_setting, sizeof (cur_setting)))
-		return -EFAULT;
-
-	return ret;
+	return put_itimerspec(setting, &cur_setting);
 }
 
 /*


Note the use of a separate __kernel_itimerspec64 for the user interface
here, which I think will be needed to hide the differences between the
normal itimerspec on 64-bit machines, and the new itimerspec on 32-bit
platforms that will be defined differently (using 'long long').

My plan for migration here is to temporarily #define __kernel_itimerspec64
as itimerspec on 32-bit architectures (which may be a bit confusing),
and then introduce a new CONFIG_COMPAT_TIME option that is set by
each architecture that has been converted over to use the new syscalls.
This way we can do one syscall at a time at first, followed by one
architecture at a time.

Unless you have serious objections to that plan, I'd like to work
on a first version of this myself and send that out for clarifications.

I would also prefer not too many people to work on the syscalls, and
would rather have Baolin not touch any of the syscall prototypes for
the moment.

	Arnd
