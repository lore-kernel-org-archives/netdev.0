From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Mon, 6 Jul 2009 05:53:51 +0100
Message-ID: <a5d9929e0907052153x2db851bcj26f1433c716c8a90@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <20090704151855.GA21896@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:58531 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbZGFEyJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 00:54:09 -0400
In-Reply-To: <20090704151855.GA21896@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

System freezes immediatly after grub, no init processing at all, after
applying those patches on top of vanilla 2.6.30 on my box.

Also, 2nd patch, this piece:

+#ifdef CONFIG_SCHED_DEBUG
+static inline unsigned int get_sysctl_timer_migration(void)
+{
+       return sysctl_timer_migration;
+}
+#else
+static inline unsigned int get_sysctl_timer_migration(void)
+{
+       return 1;
+}
+#endif

doesnt work on top of 2.6.30. It complains, while compiling, that
sysctl_timer_migration is not defined. So i just replaced that call
with return 1, like on the not debug case. Hope this doesnt defeat
your test case, but it wouldnt compile otherwise. Probably that was
just introduced after 2.6.30?

(Have also tried latest .31-rc2, original bug still exists.)

Thank you for your time,
Joao Correia
Centro de Informatica
Universidade da Beira Interior
Portugal


On Sat, Jul 4, 2009 at 4:18 PM, Jarek Poplawski<jarkao2@gmail.com> wrot=
e:
> Andres Freund wrote, On 07/03/2009 01:26 PM:
>
>> On Friday 03 July 2009 08:12:13 Jarek Poplawski wrote:
>>> On Fri, Jul 03, 2009 at 03:31:31AM +0200, Andres Freund wrote:
>>> ...
>>>
>>>> Ok. I finally see the light. I bisected the issue down to
>>>> eea08f32adb3f97553d49a4f79a119833036000a : =A0timers: Logic to mov=
e non
>>>> pinned timers
>>>>
>>>> Disabling timer migration like provided in the earlier commit stop=
s the
>>>> issue from occuring.
>>>>
>>>> That it is related to timers is sensible in the light of my findin=
gs,
>>>> that I could trigger the issue only when using delay in netem - th=
at is
>>>> the codepath using qdisc_watchdog...
>>> Andres, thanks for your work and time. It saved me a lot of searchi=
ng,
>>> because I wasn't able to trigger this on my old box.
>> Thanks. It allowed me to go through some of my remaining paperwork ;=
-)
>>
>> Does anybody of you have an idea where the problem actually resides?
>> qdisc_watchdog_schedule looks innocent enough for my uneducated eyes=
 - and the
>> patch/infrastructure from Arun goes over my head...
>> I will happily test some ideas/patches.
>
> Since there are still no 100% proofs nor suspects, here are some
> suggestions of additional checking. This bisected commit could
> probably be additionally verified by applying to 2.6.30 with a
> preceding one; I attach both of them below.
>
> Another suggestion is to try this without lockdep e.g. by setting
> /sys/module/lockdep/parameters/lock_stat and prove_locking to 0.
>
> Thanks,
> Jarek P.
>
> --------------->
> commit 597d0275736dad9c3bda6f0a00a1c477dc0f37b1
> Author: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
> Date: =A0 Thu Apr 16 12:13:26 2009 +0530
>
> =A0 =A0timers: Framework for identifying pinned timers
>
> =A0 =A0* Arun R Bharadwaj <arun@linux.vnet.ibm.com> [2009-04-16 12:11=
:36]:
>
> =A0 =A0This patch creates a new framework for identifying cpu-pinned =
timers
> =A0 =A0and hrtimers.
>
> =A0 =A0This framework is needed because pinned timers are expected to=
 fire on
> =A0 =A0the same CPU on which they are queued. So it is essential to i=
dentify
> =A0 =A0these and not migrate them, in case there are any.
>
> =A0 =A0For regular timers, the currently existing add_timer_on() can =
be used
> =A0 =A0queue pinned timers and subsequently mod_timer_pinned() can be=
 used
> =A0 =A0to modify the 'expires' field.
>
> =A0 =A0For hrtimers, new modes HRTIMER_ABS_PINNED and HRTIMER_REL_PIN=
NED are
> =A0 =A0added to queue cpu-pinned hrtimer.
>
> =A0 =A0[ tglx: use .._PINNED mode argument instead of creating tons o=
f new
> =A0 =A0functions ]
>
> =A0 =A0Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
> =A0 =A0Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>
> diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
> index 0d2f7c8..7400900 100644
> --- a/include/linux/hrtimer.h
> +++ b/include/linux/hrtimer.h
> @@ -30,8 +30,11 @@ struct hrtimer_cpu_base;
> =A0* Mode arguments of xxx_hrtimer functions:
> =A0*/
> =A0enum hrtimer_mode {
> - =A0 =A0 =A0 HRTIMER_MODE_ABS, =A0 =A0 =A0 /* Time value is absolute=
 */
> - =A0 =A0 =A0 HRTIMER_MODE_REL, =A0 =A0 =A0 /* Time value is relative=
 to now */
> + =A0 =A0 =A0 HRTIMER_MODE_ABS =3D 0x0, =A0 =A0 =A0 =A0 /* Time value=
 is absolute */
> + =A0 =A0 =A0 HRTIMER_MODE_REL =3D 0x1, =A0 =A0 =A0 =A0 /* Time value=
 is relative to now */
> + =A0 =A0 =A0 HRTIMER_MODE_PINNED =3D 0x02, =A0 =A0 /* Timer is bound=
 to CPU */
> + =A0 =A0 =A0 HRTIMER_MODE_ABS_PINNED =3D 0x02,
> + =A0 =A0 =A0 HRTIMER_MODE_REL_PINNED =3D 0x03,
> =A0};
>
> =A0/*
> diff --git a/include/linux/timer.h b/include/linux/timer.h
> index 6cdb6f3..ccf882e 100644
> --- a/include/linux/timer.h
> +++ b/include/linux/timer.h
> @@ -163,7 +163,10 @@ extern void add_timer_on(struct timer_list *time=
r, int cpu);
> =A0extern int del_timer(struct timer_list * timer);
> =A0extern int mod_timer(struct timer_list *timer, unsigned long expir=
es);
> =A0extern int mod_timer_pending(struct timer_list *timer, unsigned lo=
ng expires);
> +extern int mod_timer_pinned(struct timer_list *timer, unsigned long =
expires);
>
> +#define TIMER_NOT_PINNED =A0 =A0 =A0 0
> +#define TIMER_PINNED =A0 =A0 =A0 =A0 =A0 1
> =A0/*
> =A0* The jiffies value which is added to now, when there is no timer
> =A0* in the timer wheel:
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index cb8a15c..c71bcd5 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -193,7 +193,8 @@ struct hrtimer_clock_base *lock_hrtimer_base(cons=
t struct hrtimer *timer,
> =A0* Switch the timer base to the current CPU when possible.
> =A0*/
> =A0static inline struct hrtimer_clock_base *
> -switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base=
 *base)
> +switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base=
 *base,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int pinned)
> =A0{
> =A0 =A0 =A0 =A0struct hrtimer_clock_base *new_base;
> =A0 =A0 =A0 =A0struct hrtimer_cpu_base *new_cpu_base;
> @@ -907,9 +908,9 @@ int __hrtimer_start_range_ns(struct hrtimer *time=
r, ktime_t tim,
> =A0 =A0 =A0 =A0ret =3D remove_hrtimer(timer, base);
>
> =A0 =A0 =A0 =A0/* Switch the timer base, if necessary: */
> - =A0 =A0 =A0 new_base =3D switch_hrtimer_base(timer, base);
> + =A0 =A0 =A0 new_base =3D switch_hrtimer_base(timer, base, mode & HR=
TIMER_MODE_PINNED);
>
> - =A0 =A0 =A0 if (mode =3D=3D HRTIMER_MODE_REL) {
> + =A0 =A0 =A0 if (mode & HRTIMER_MODE_REL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tim =3D ktime_add_safe(tim, new_base->=
get_time());
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * CONFIG_TIME_LOW_RES is a temporary =
way for architectures
> diff --git a/kernel/timer.c b/kernel/timer.c
> index 5c1e84b..3424dfd 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -604,7 +604,8 @@ static struct tvec_base *lock_timer_base(struct t=
imer_list *timer,
> =A0}
>
> =A0static inline int
> -__mod_timer(struct timer_list *timer, unsigned long expires, bool pe=
nding_only)
> +__mod_timer(struct timer_list *timer, unsigned long expires,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 bool pending_only, int pinned)
> =A0{
> =A0 =A0 =A0 =A0struct tvec_base *base, *new_base;
> =A0 =A0 =A0 =A0unsigned long flags;
> @@ -668,7 +669,7 @@ out_unlock:
> =A0*/
> =A0int mod_timer_pending(struct timer_list *timer, unsigned long expi=
res)
> =A0{
> - =A0 =A0 =A0 return __mod_timer(timer, expires, true);
> + =A0 =A0 =A0 return __mod_timer(timer, expires, true, TIMER_NOT_PINN=
ED);
> =A0}
> =A0EXPORT_SYMBOL(mod_timer_pending);
>
> @@ -702,11 +703,33 @@ int mod_timer(struct timer_list *timer, unsigne=
d long expires)
> =A0 =A0 =A0 =A0if (timer->expires =3D=3D expires && timer_pending(tim=
er))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>
> - =A0 =A0 =A0 return __mod_timer(timer, expires, false);
> + =A0 =A0 =A0 return __mod_timer(timer, expires, false, TIMER_NOT_PIN=
NED);
> =A0}
> =A0EXPORT_SYMBOL(mod_timer);
>
> =A0/**
> + * mod_timer_pinned - modify a timer's timeout
> + * @timer: the timer to be modified
> + * @expires: new timeout in jiffies
> + *
> + * mod_timer_pinned() is a way to update the expire field of an
> + * active timer (if the timer is inactive it will be activated)
> + * and not allow the timer to be migrated to a different CPU.
> + *
> + * mod_timer_pinned(timer, expires) is equivalent to:
> + *
> + * =A0 =A0 del_timer(timer); timer->expires =3D expires; add_timer(t=
imer);
> + */
> +int mod_timer_pinned(struct timer_list *timer, unsigned long expires=
)
> +{
> + =A0 =A0 =A0 if (timer->expires =3D=3D expires && timer_pending(time=
r))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 return __mod_timer(timer, expires, false, TIMER_PINNED)=
;
> +}
> +EXPORT_SYMBOL(mod_timer_pinned);
> +
> +/**
> =A0* add_timer - start a timer
> =A0* @timer: the timer to be added
> =A0*
> @@ -1356,7 +1379,7 @@ signed long __sched schedule_timeout(signed lon=
g timeout)
> =A0 =A0 =A0 =A0expire =3D timeout + jiffies;
>
> =A0 =A0 =A0 =A0setup_timer_on_stack(&timer, process_timeout, (unsigne=
d long)current);
> - =A0 =A0 =A0 __mod_timer(&timer, expire, false);
> + =A0 =A0 =A0 __mod_timer(&timer, expire, false, TIMER_NOT_PINNED);
> =A0 =A0 =A0 =A0schedule();
> =A0 =A0 =A0 =A0del_singleshot_timer_sync(&timer);
>
>
> commit eea08f32adb3f97553d49a4f79a119833036000a
> Author: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
> Date: =A0 Thu Apr 16 12:16:41 2009 +0530
>
> =A0 =A0timers: Logic to move non pinned timers
>
> =A0 =A0* Arun R Bharadwaj <arun@linux.vnet.ibm.com> [2009-04-16 12:11=
:36]:
>
> =A0 =A0This patch migrates all non pinned timers and hrtimers to the =
current
> =A0 =A0idle load balancer, from all the idle CPUs. Timers firing on b=
usy CPUs
> =A0 =A0are not migrated.
>
> =A0 =A0While migrating hrtimers, care should be taken to check if mig=
rating
> =A0 =A0a hrtimer would result in a latency or not. So we compare the =
expiry of the
> =A0 =A0hrtimer with the next timer interrupt on the target cpu and mi=
grate the
> =A0 =A0hrtimer only if it expires *after* the next interrupt on the t=
arget cpu.
> =A0 =A0So, added a clockevents_get_next_event() helper function to re=
turn the
> =A0 =A0next_event on the target cpu's clock_event_device.
>
> =A0 =A0[ tglx: cleanups and simplifications ]
>
> =A0 =A0Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
> =A0 =A0Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>
> diff --git a/include/linux/clockchips.h b/include/linux/clockchips.h
> index 3a1dbba..20a100f 100644
> --- a/include/linux/clockchips.h
> +++ b/include/linux/clockchips.h
> @@ -143,3 +143,12 @@ extern void clockevents_notify(unsigned long rea=
son, void *arg);
> =A0#endif
>
> =A0#endif
> +
> +#ifdef CONFIG_GENERIC_CLOCKEVENTS
> +extern ktime_t clockevents_get_next_event(int cpu);
> +#else
> +static inline ktime_t clockevents_get_next_event(int cpu)
> +{
> + =A0 =A0 =A0 return (ktime_t) { .tv64 =3D KTIME_MAX };
> +}
> +#endif
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 6185040..311dec1 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -257,6 +257,7 @@ extern void task_rq_unlock_wait(struct task_struc=
t *p);
> =A0extern cpumask_var_t nohz_cpu_mask;
> =A0#if defined(CONFIG_SMP) && defined(CONFIG_NO_HZ)
> =A0extern int select_nohz_load_balancer(int cpu);
> +extern int get_nohz_load_balancer(void);
> =A0#else
> =A0static inline int select_nohz_load_balancer(int cpu)
> =A0{
> @@ -1772,6 +1773,17 @@ int sched_nr_latency_handler(struct ctl_table =
*table, int write,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct file *file, void __user *buffer=
, size_t *length,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t *ppos);
> =A0#endif
> +#ifdef CONFIG_SCHED_DEBUG
> +static inline unsigned int get_sysctl_timer_migration(void)
> +{
> + =A0 =A0 =A0 return sysctl_timer_migration;
> +}
> +#else
> +static inline unsigned int get_sysctl_timer_migration(void)
> +{
> + =A0 =A0 =A0 return 1;
> +}
> +#endif
> =A0extern unsigned int sysctl_sched_rt_period;
> =A0extern int sysctl_sched_rt_runtime;
>
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index c71bcd5..b675a67 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -43,6 +43,8 @@
> =A0#include <linux/seq_file.h>
> =A0#include <linux/err.h>
> =A0#include <linux/debugobjects.h>
> +#include <linux/sched.h>
> +#include <linux/timer.h>
>
> =A0#include <asm/uaccess.h>
>
> @@ -198,8 +200,19 @@ switch_hrtimer_base(struct hrtimer *timer, struc=
t hrtimer_clock_base *base,
> =A0{
> =A0 =A0 =A0 =A0struct hrtimer_clock_base *new_base;
> =A0 =A0 =A0 =A0struct hrtimer_cpu_base *new_cpu_base;
> + =A0 =A0 =A0 int cpu, preferred_cpu =3D -1;
> +
> + =A0 =A0 =A0 cpu =3D smp_processor_id();
> +#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
> + =A0 =A0 =A0 if (!pinned && get_sysctl_timer_migration() && idle_cpu=
(cpu)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 preferred_cpu =3D get_nohz_load_balance=
r();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (preferred_cpu >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D preferred_cpu;
> + =A0 =A0 =A0 }
> +#endif
>
> - =A0 =A0 =A0 new_cpu_base =3D &__get_cpu_var(hrtimer_bases);
> +again:
> + =A0 =A0 =A0 new_cpu_base =3D &per_cpu(hrtimer_bases, cpu);
> =A0 =A0 =A0 =A0new_base =3D &new_cpu_base->clock_base[base->index];
>
> =A0 =A0 =A0 =A0if (base !=3D new_base) {
> @@ -219,6 +232,40 @@ switch_hrtimer_base(struct hrtimer *timer, struc=
t hrtimer_clock_base *base,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timer->base =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&base->cpu_base->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&new_base->cpu_base->lock);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Optimized away for NOHZ=3Dn SMP=3Dn =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu =3D=3D preferred_cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Calculate clock mono=
tonic expiry time */
> +#ifdef CONFIG_HIGH_RES_TIMERS
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_t expires =3D kti=
me_sub(hrtimer_get_expires(timer),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_base->offset);
> +#else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_t expires =3D hrt=
imer_get_expires(timer);
> +#endif
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Get the next event=
 on target cpu from the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* clock events layer=
=2E
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This covers the hi=
ghres=3Doff nohz=3Don case as well.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_t next =3D clocke=
vents_get_next_event(cpu);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_t delta =3D ktime=
_sub(expires, next);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We do not migrate =
the timer when it is expiring
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* before the next ev=
ent on the target cpu because
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we cannot reprogra=
m the target cpu hardware and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we would cause it =
to fire late.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (delta.tv64 < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D=
 smp_processor_id();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_un=
lock(&new_base->cpu_base->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lo=
ck(&base->cpu_base->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer->=
base =3D base;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ag=
ain;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0timer->base =3D new_base;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return new_base;
> @@ -236,7 +283,7 @@ lock_hrtimer_base(const struct hrtimer *timer, un=
signed long *flags)
> =A0 =A0 =A0 =A0return base;
> =A0}
>
> -# define switch_hrtimer_base(t, b) =A0 =A0 (b)
> +# define switch_hrtimer_base(t, b, p) =A0(b)
>
> =A0#endif /* !CONFIG_SMP */
>
> diff --git a/kernel/sched.c b/kernel/sched.c
> index 7f1dd56..9fe3774 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -4244,6 +4244,11 @@ static struct {
> =A0 =A0 =A0 =A0.load_balancer =3D ATOMIC_INIT(-1),
> =A0};
>
> +int get_nohz_load_balancer(void)
> +{
> + =A0 =A0 =A0 return atomic_read(&nohz.load_balancer);
> +}
> +
> =A0/*
> =A0* This routine will try to nominate the ilb (idle load balancing)
> =A0* owner among the cpus whose ticks are stopped. ilb owner will do =
the idle
> diff --git a/kernel/time/clockevents.c b/kernel/time/clockevents.c
> index d13be21..ab20ded 100644
> --- a/kernel/time/clockevents.c
> +++ b/kernel/time/clockevents.c
> @@ -18,6 +18,7 @@
> =A0#include <linux/notifier.h>
> =A0#include <linux/smp.h>
> =A0#include <linux/sysdev.h>
> +#include <linux/tick.h>
>
> =A0/* The registered clock event devices */
> =A0static LIST_HEAD(clockevent_devices);
> @@ -251,4 +252,15 @@ void clockevents_notify(unsigned long reason, vo=
id *arg)
> =A0 =A0 =A0 =A0spin_unlock(&clockevents_lock);
> =A0}
> =A0EXPORT_SYMBOL_GPL(clockevents_notify);
> +
> +ktime_t clockevents_get_next_event(int cpu)
> +{
> + =A0 =A0 =A0 struct tick_device *td;
> + =A0 =A0 =A0 struct clock_event_device *dev;
> +
> + =A0 =A0 =A0 td =3D &per_cpu(tick_cpu_device, cpu);
> + =A0 =A0 =A0 dev =3D td->evtdev;
> +
> + =A0 =A0 =A0 return dev->next_event;
> +}
> =A0#endif
> diff --git a/kernel/timer.c b/kernel/timer.c
> index 3424dfd..3f841db 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -37,6 +37,7 @@
> =A0#include <linux/delay.h>
> =A0#include <linux/tick.h>
> =A0#include <linux/kallsyms.h>
> +#include <linux/sched.h>
>
> =A0#include <asm/uaccess.h>
> =A0#include <asm/unistd.h>
> @@ -609,9 +610,7 @@ __mod_timer(struct timer_list *timer, unsigned lo=
ng expires,
> =A0{
> =A0 =A0 =A0 =A0struct tvec_base *base, *new_base;
> =A0 =A0 =A0 =A0unsigned long flags;
> - =A0 =A0 =A0 int ret;
> -
> - =A0 =A0 =A0 ret =3D 0;
> + =A0 =A0 =A0 int ret =3D 0 , cpu;
>
> =A0 =A0 =A0 =A0timer_stats_timer_set_start_info(timer);
> =A0 =A0 =A0 =A0BUG_ON(!timer->function);
> @@ -630,6 +629,18 @@ __mod_timer(struct timer_list *timer, unsigned l=
ong expires,
>
> =A0 =A0 =A0 =A0new_base =3D __get_cpu_var(tvec_bases);
>
> + =A0 =A0 =A0 cpu =3D smp_processor_id();
> +
> +#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
> + =A0 =A0 =A0 if (!pinned && get_sysctl_timer_migration() && idle_cpu=
(cpu)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int preferred_cpu =3D get_nohz_load_bal=
ancer();
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (preferred_cpu >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D preferred_cpu;
> + =A0 =A0 =A0 }
> +#endif
> + =A0 =A0 =A0 new_base =3D per_cpu(tvec_bases, cpu);
> +
> =A0 =A0 =A0 =A0if (base !=3D new_base) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We are trying to schedule the timer=
 on the local CPU.
>
