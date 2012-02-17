From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 6/8] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Fri, 17 Feb 2012 10:23:59 -0600
Message-ID: <CABqD9hbAQ8dwwAf0Cpk4+dwgWjCYh1Fwg92=Vaq1XNqFQ3VVqw@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-6-git-send-email-wad@chromium.org>
	<a3cc7e306f0ad79f3d49921d8586d18c.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <a3cc7e306f0ad79f3d49921d8586d18c.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 11:08 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Thu, February 16, 2012 21:02, Will Drewry wrote:
>> A new return value is added to seccomp filters that allows
>> the system call policy for the affected system calls to be
>> implemented by a ptrace(2)ing process.
>>
>> If a tracer attaches to a task using PTRACE_SECCOMP, then the
>> traced process will notify the tracer if a seccomp filter
>> returns SECCOMP_RET_TRACE. =A0If the tracer detaches, then
>> system calls made by the task will fail.
>
> This is what I need to make BPF useful to me.
>
> To have least impact on current and future (user space) ptrace code,
> I suspect it's best if PTRACE_SECCOMP becomes a ptrace option. That
> may be a little bit more work, but the end result should be more
> robust against any future ptrace changes.
>
>> To ensure that seccomp is syscall fast-path friendly in the future,
>> ptrace is delegated to by setting TIF_SYSCALL_TRACE. =A0Since seccom=
p
>> events are equivalent to system call entry events, this allows for
>> seccomp to be evaluated as a fork off the fast-path and only,
>> optionally, jump to the slow path.
>
> I think you have to go through the slow path anyway to get access to
> the syscall arguments, at least for some archs.

Just depends on the arch.  On x86, it only populates the arguments and
the syscall number by default, but the slow path takes the time to
copy the rest.

>> When the tracer is notified, all
>> will function as with ptrace(PTRACE_SYSCALLS), but when the tracer c=
alls
>> ptrace(PTRACE_SECCOMP), TIF_SYSCALL_TRACE will be unset and the task
>> will proceed.
>> Note, this patch takes the path of least resistance for integration.=
 It
>> is not necessarily the best path and any guidance will be appreciate=
d!
>> The key challenges are ensuring that register state is correct at
>> ptrace handoff and ensuring that all only seccomp-based notification
>> occurs.
>>
>> v8: - guarded PTRACE_SECCOMP use with an ifdef
>> v7: - introduced
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> =A0arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 ++++++++----
>> =A0include/linux/ptrace.h =A0| =A0 =A01 +
>> =A0include/linux/seccomp.h | =A0 39 ++++++++++++++++++++++++++++++++=
+++++--
>> =A0kernel/ptrace.c =A0 =A0 =A0 =A0 | =A0 12 ++++++++++++
>> =A0kernel/seccomp.c =A0 =A0 =A0 =A0| =A0 15 +++++++++++++++
>> =A05 files changed, 73 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index a01c151..ae40aec 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -203,10 +203,14 @@ config HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0 bool
>> =A0 =A0 =A0 help
>> =A0 =A0 =A0 =A0 This symbol should be selected by an architecure if =
it provides
>> - =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments(),
>> - =A0 =A0 =A0 syscall_set_return_value(), and syscall_rollback().
>> - =A0 =A0 =A0 Additionally, its system call entry path must respect =
a return
>> - =A0 =A0 =A0 value of -1 from __secure_computing_int() and/or secur=
e_computing().
>> + =A0 =A0 =A0 linux/tracehook.h, for TIF_SYSCALL_TRACE, and asm/sysc=
all.h,
>> + =A0 =A0 =A0 specifically syscall_get_arguments(), syscall_set_retu=
rn_value(), and
>> + =A0 =A0 =A0 syscall_rollback(). =A0Additionally, its system call e=
ntry path must
>> + =A0 =A0 =A0 respect a return value of -1 from __secure_computing_i=
nt() and/or
>> + =A0 =A0 =A0 secure_computing(). =A0If secure_computing is not in t=
he system call
>> + =A0 =A0 =A0 slow path, the thread info flags will need to be check=
ed upon exit to
>> + =A0 =A0 =A0 ensure delegation to ptrace(2) did not occur, or if it=
 did, jump to
>> + =A0 =A0 =A0 the slow-path.
>>
>> =A0config SECCOMP_FILTER
>> =A0 =A0 =A0 def_bool y
>> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
>> index c2f1f6a..00220de 100644
>> --- a/include/linux/ptrace.h
>> +++ b/include/linux/ptrace.h
>> @@ -50,6 +50,7 @@
>> =A0#define PTRACE_SEIZE =A0 =A0 =A0 =A0 0x4206
>> =A0#define PTRACE_INTERRUPT =A0 =A0 0x4207
>> =A0#define PTRACE_LISTEN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x4208
>> +#define PTRACE_SECCOMP =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x4209
>>
>> =A0/* flags in @data for PTRACE_SEIZE */
>> =A0#define PTRACE_SEIZE_DEVEL =A0 0x80000000 /* temp flag for develo=
pment */
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index 1be562f..1cb7d5c 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -19,8 +19,9 @@
>> =A0 * selects the least permissive choice.
>> =A0 */
>> =A0#define SECCOMP_RET_KILL =A0 =A0 0x00000000U /* kill the task imm=
ediately */
>> -#define SECCOMP_RET_TRAP =A0 =A0 0x00020000U /* disallow and send s=
igtrap */
>> -#define SECCOMP_RET_ERRNO =A0 =A00x00030000U /* returns an errno */
>> +#define SECCOMP_RET_TRAP =A0 =A0 0x00020000U /* only send sigtrap *=
/
>> +#define SECCOMP_RET_ERRNO =A0 =A00x00030000U /* only return an errn=
o */
>> +#define SECCOMP_RET_TRACE =A0 =A00x7ffe0000U /* allow, but notify t=
he tracer */
>> =A0#define SECCOMP_RET_ALLOW =A0 =A00x7fff0000U /* allow */
>>
>> =A0/* Masks for accessing the above values. */
>> @@ -51,6 +52,7 @@ struct seccomp_filter;
>> =A0 *
>> =A0 * @mode: =A0indicates one of the valid values above for controll=
ed
>> =A0 * =A0 =A0 =A0 =A0 system calls available to a process.
>> + * @flags: per-process flags. Currently only used for SECCOMP_FLAGS=
_TRACED.
>
> If it has only one use, don't make it flags then. You can always chan=
ge
> it to flags later. Until then, it only makes things less clear.

I'll see if the updated one can ditch it.

> I actually think it's better to get rid of this altogether, and only
> check task->ptrace for PTRACE_O_SECCOMP. That would avoid a lot of co=
de.

It wasn't clear to me how to best add a PTRACE_O_* since the most
recent refactor.  Maybe if I see one of Oleg's new patches, I can
model it on that.

>> =A0 * @filter: The metadata and ruleset for determining what system =
calls
>> =A0 * =A0 =A0 =A0 =A0 =A0are allowed for a task.
>> =A0 *
>> @@ -59,9 +61,13 @@ struct seccomp_filter;
>> =A0 */
>> =A0struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 unsigned long flags;
>
> Why a long? That wastes 4 bytes of padding and you still can't use th=
e upper
> 32-bits because you have to support 32-bit systems too.

I was just using the bitset helper functions.  The unsigned long
assures the arch can work its magic, etc.

>> =A0 =A0 =A0 struct seccomp_filter *filter;
>> =A0};
>>
>> +/* Indicates if a tracer is attached. */
>> +#define SECCOMP_FLAGS_TRACED 0
>
> That's not the best way to check if a tracer is attached, and if you =
did use
> it for that, you don't need to toggle it all the time.

It's logically no different than task->ptrace.  If it is less
desirable, that's fine, but it is functionally equivalent.

>> +
>> =A0/*
>> =A0 * Direct callers to __secure_computing should be updated as
>> =A0 * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.
>> @@ -83,6 +89,20 @@ static inline int seccomp_mode(struct seccomp *s)
>> =A0 =A0 =A0 return s->mode;
>> =A0}
>>
>> +static inline void seccomp_set_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 set_bit(SECCOMP_FLAGS_TRACED, &s->flags);
>> +}
>> +
>> +static inline void seccomp_clear_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 clear_bit(SECCOMP_FLAGS_TRACED, &s->flags);
>> +}
>> +
>> +static inline int seccomp_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 return test_bit(SECCOMP_FLAGS_TRACED, &s->flags);
>> +}
>> =A0#else /* CONFIG_SECCOMP */
>>
>> =A0#include <linux/errno.h>
>> @@ -106,6 +126,21 @@ static inline int seccomp_mode(struct seccomp *=
s)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> =A0}
>> +
>> +static inline void seccomp_set_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 return;
>> +}
>> +
>> +static inline void seccomp_clear_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 return;
>> +}
>> +
>> +static inline int seccomp_traced(struct seccomp *s)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> =A0#endif /* CONFIG_SECCOMP */
>>
>> =A0#ifdef CONFIG_SECCOMP_FILTER
>> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
>> index 00ab2ca..199a6da 100644
>> --- a/kernel/ptrace.c
>> +++ b/kernel/ptrace.c
>> @@ -19,6 +19,7 @@
>> =A0#include <linux/signal.h>
>> =A0#include <linux/audit.h>
>> =A0#include <linux/pid_namespace.h>
>> +#include <linux/seccomp.h>
>> =A0#include <linux/syscalls.h>
>> =A0#include <linux/uaccess.h>
>> =A0#include <linux/regset.h>
>> @@ -426,6 +427,7 @@ static int ptrace_detach(struct task_struct *chi=
ld, unsigned int
> data)
>> =A0 =A0 =A0 /* Architecture-specific hardware disable .. */
>> =A0 =A0 =A0 ptrace_disable(child);
>> =A0 =A0 =A0 clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
>> + =A0 =A0 seccomp_clear_traced(&child->seccomp);
>>
>> =A0 =A0 =A0 write_lock_irq(&tasklist_lock);
>> =A0 =A0 =A0 /*
>> @@ -616,6 +618,13 @@ static int ptrace_resume(struct task_struct *ch=
ild, long request,
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_tsk_thread_flag(child, TIF_SYSCALL=
_TRACE);
>>
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 if (request =3D=3D PTRACE_SECCOMP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_set_traced(&child->seccomp);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_clear_traced(&child->seccomp);
>> +#endif
>> +
>> =A0#ifdef TIF_SYSCALL_EMU
>> =A0 =A0 =A0 if (request =3D=3D PTRACE_SYSEMU || request =3D=3D PTRAC=
E_SYSEMU_SINGLESTEP)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_tsk_thread_flag(child, TIF_SYSCALL_E=
MU);
>> @@ -816,6 +825,9 @@ int ptrace_request(struct task_struct *child, lo=
ng request,
>> =A0 =A0 =A0 case PTRACE_SYSEMU:
>> =A0 =A0 =A0 case PTRACE_SYSEMU_SINGLESTEP:
>> =A0#endif
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case PTRACE_SECCOMP:
>> +#endif
>> =A0 =A0 =A0 case PTRACE_SYSCALL:
>> =A0 =A0 =A0 case PTRACE_CONT:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptrace_resume(child, request, dat=
a);
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index c75485c..f9d419f 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -289,6 +289,8 @@ void copy_seccomp(struct seccomp *child,
>> =A0{
>> =A0 =A0 =A0 child->mode =3D prev->mode;
>> =A0 =A0 =A0 child->filter =3D get_seccomp_filter(prev->filter);
>> + =A0 =A0 /* Note, this leaves seccomp tracing enabled across fork. =
*/
>> + =A0 =A0 child->flags =3D prev->flags;
>
> What if the child isn't ptraced?

Then falling through with TIF_SYSCALL_TRACE will result in the
SECCOMP_RET_TRACE events to be allowed, but this comes back to the
race.  If I can effectively "check" that ptrace did its job, then I
think this becomes a non-issue.

>> =A0}
>>
>> =A0/**
>> @@ -363,6 +365,19 @@ int __secure_computing_int(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall_rollback(current=
, task_pt_regs(current));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigtrap();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!seccomp_traced(&curre=
nt->seccomp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Delegate to TIF_SYSCA=
LL_TRACE. This allows fast-path
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* seccomp calls to dele=
gate to slow-path if needed.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Since TIF_SYSCALL_TRA=
CE will be unset on ptrace(2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* continuation, there s=
hould be no direct side
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* effects. =A0If TIF_SY=
SCALL_TRACE is already set, this
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* has no effect.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_tsk_thread_flag(curren=
t, TIF_SYSCALL_TRACE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Falls through to allow.=
 */
>
> This is nice and simple, but not race-free. You want to check if the =
ptracer
> handled the event or not. If the ptracer died before handling this th=
en the
> syscall should be denied and the task should be killed.

Hrm. I think there's a way to do this without forcing seccomp to
always go slow path.  I'll update the patch and see how it goes.

> Many people would like a PTRACE_O_KILL_TRACEE_IF_DEBUGGER_DIES option=
,
> Oleg was working on that, among other things. Perhaps re-use that to
> handle this case too?

Well, if you can inject initial code into the tracee, then it can call
prctl(PR_SET_PDEATHSIG, SIGKILL).  Then when the tracer dies, the
child dies.  If the SIGKILL race in arch_ptrace_... is resolved, then
a SIGKILL that arrives between seccomp and delegation to ptrace should
result in process death.  Though perhaps my proposal above will make
seccomp's integration with ptrace less subject to ptrace behaviors.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ALLOW:
>
> For this and the ERRNO case you could check that PTRACE_O_SECCOMP opt=
ion and
> decide to do something or not in ptrace.

=46or ERRNO, I'd prefer not to since it adds implicit behavior to the
rules and, without pulling a ptrace_event()ish call into this code, it
would change the return flow and potentially open up errno, which
should be solid, to races, etc.  For ALLOW, sure, but at that point,
just use PTRACE_SYSCALL.  Perhaps this can all be ameliorated if I can
get a useful ptrace_entry completed notification.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_KILL:
>> --
>> 1.7.5.4
>>
>>
>
> Greetings,

As usual, thanks!
will
