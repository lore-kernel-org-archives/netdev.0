From: Will Drewry <wad@chromium.org>
Subject: Re: Re: [PATCH v10 09/11] ptrace,seccomp: Add
 PTRACE_SECCOMP support
Date: Wed, 22 Feb 2012 13:47:56 -0600
Message-ID: <CABqD9hY-aCqfkk4hO-N0oQUP8UyTZBm3Vads+i658Y1DwACEPw@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-9-git-send-email-wad@chromium.org>
	<25f69829d492b002f418955d9ce30321.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org
To: kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-911-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <25f69829d492b002f418955d9ce30321.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 6:22 AM, Indan Zupancic <indan@nul.nu> wrote:
> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>> A new return value is added to seccomp filters that allows
>> the system call policy for the affected system calls to be
>> implemented by a ptrace(2)ing process.
>>
>> If a tracer attaches to a task, specifies the PTRACE_O_TRACESECCOMP
>> option, then PTRACE_CONT.
>
> Awkward formulation here. I'd start with "If a tracer sets the
> PTRACE_O_TRACESECCOMP option, then ..."
>
>> After doing so, the tracer will
>> be notified if a seccomp filter program returns SECCOMP_RET_TRACE.
>
> This means that strace and gdb won't see seccomp filtered syscalls.
> I think you have to reverse the logic and have an option that asks
> to hide normal SECCOMP_RET_ERRNO, but not SECCOMP_RET_TRACE ones.
>
> That gives the expected behaviour in all cases: Programs not setting
> it behave as they do now, and co-operating tracers can ignore syscall
> events they're not interested in.

Reversing the logic resolves the slow-path/fast-path problem too. I'll
repost.  This will make the code much saner I think!

>> If there is no seccomp event tracer, SECCOMP_RET_TRACE system calls will
>> return a -ENOSYS errno to user space. =A0If the tracer detaches during a
>> hand-off, the process will be killed.
>>
>> To ensure that seccomp is syscall fast-path friendly in the future,
>> ptrace is delegated to by setting TIF_SYSCALL_TRACE. =A0Since seccomp
>> events are equivalent to system call entry events, this allows for
>> seccomp to be evaluated as a fork off the fast-path and only,
>> optionally, jump to the slow path. When the tracer is notified, all
>> will function as with ptrace(PTRACE_SYSCALLS), but when the tracer calls
>> ptrace(PTRACE_CONT), TIF_SYSCALL_TRACE will be unset and the task
>> will proceed just receiving PTRACE_O_TRACESECCOMP events.
>
> Please, no. That's making it more complicated than necessary.
>
> I propose to keep the ptrace rules exactly the same as they are, with
> the only change being that if PTRACE_O_SECCOMP is set, no syscall events
> will be generated for SECCOMP_RET_ERRNO. This way ptrace behaviour is
> the same, but only less syscall events are received. With your way
> ptracers see syscall events when they normally wouldn't.
>
>>
>> I realize there are pending patches for cleaning up ptrace events.
>> I can either reintegrate with those when they are available or
>> vice versa. That's assuming these changes make sense and are viable.
>>
>> v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
>> v9: =A0- n/a
>> v8: =A0- guarded PTRACE_SECCOMP use with an ifdef
>> v7: =A0- introduced
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +++
>> include/linux/ptrace.h =A0 =A0| =A0 =A07 ++++-
>> include/linux/seccomp.h =A0 | =A0 14 +++++++++--
>> include/linux/tracehook.h | =A0 =A07 +++++-
>> kernel/ptrace.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +++
>> kernel/seccomp.c =A0 =A0 =A0 =A0 =A0| =A0 52 +++++++++++++++++++++++++++=
+++++++++++++++--
>> 6 files changed, 79 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index 6d6d9dc..02c18ca 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -203,6 +203,7 @@ config HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0 bool
>> =A0 =A0 =A0 help
>> =A0 =A0 =A0 =A0 This symbol should be selected by an architecure if it p=
rovides:
>> + =A0 =A0 =A0 linux/tracehook.h, for TIF_SYSCALL_TRACE and ptrace_report=
_syscall
>> =A0 =A0 =A0 =A0 asm/syscall.h:
>> =A0 =A0 =A0 =A0 - syscall_get_arch()
>> =A0 =A0 =A0 =A0 - syscall_get_arguments()
>> @@ -211,6 +212,9 @@ config HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0 =A0 SIGSYS siginfo_t support must be implemented.
>> =A0 =A0 =A0 =A0 __secure_computing_int()/secure_computing()'s return val=
ue must be
>> =A0 =A0 =A0 =A0 checked, with -1 resulting in the syscall being skipped.
>> + =A0 =A0 =A0 If secure_computing is not in the system call slow path, t=
he thread
>> + =A0 =A0 =A0 info flags will need to be checked upon exit to ensure del=
egation to
>> + =A0 =A0 =A0 ptrace(2) did not occur, or if it did, jump to the slow-pa=
th.
>>
>> config SECCOMP_FILTER
>> =A0 =A0 =A0 def_bool y
>> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
>> index c2f1f6a..2fccdbc 100644
>> --- a/include/linux/ptrace.h
>> +++ b/include/linux/ptrace.h
>> @@ -62,8 +62,9 @@
>> #define PTRACE_O_TRACEEXEC =A0 =A00x00000010
>> #define PTRACE_O_TRACEVFORKDONE =A0 =A0 =A0 0x00000020
>> #define PTRACE_O_TRACEEXIT =A0 =A00x00000040
>> +#define PTRACE_O_TRACESECCOMP =A0 =A0 =A0 =A00x00000080
>>
>> -#define PTRACE_O_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0000007f
>> +#define PTRACE_O_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x000000ff
>>
>> /* Wait extended result codes for the above trace options. =A0*/
>> #define PTRACE_EVENT_FORK =A0 =A0 1
>> @@ -73,6 +74,7 @@
>> #define PTRACE_EVENT_VFORK_DONE =A0 =A0 =A0 5
>> #define PTRACE_EVENT_EXIT =A0 =A0 6
>> #define PTRACE_EVENT_STOP =A0 =A0 7
>> +#define PTRACE_EVENT_SECCOMP 8 =A0 =A0 =A0 /* never directly delivered =
*/
>>
>> #include <asm/ptrace.h>
>>
>> @@ -101,8 +103,9 @@
>> #define PT_TRACE_EXEC =A0 =A0 =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
>> #define PT_TRACE_VFORK_DONE =A0 PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
>> #define PT_TRACE_EXIT =A0 =A0 =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
>> +#define PT_TRACE_SECCOMP =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
>>
>> -#define PT_TRACE_MASK =A0 =A0 =A0 =A00x000003f4
>> +#define PT_TRACE_MASK =A0 =A0 =A0 =A00x00000ff4
>>
>> /* single stepping state bits (used on ARM and PA-RISC) */
>> #define PT_SINGLESTEP_BIT =A0 =A0 31
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index d039b7b..16887c1 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -19,8 +19,9 @@
>> =A0* selects the least permissive choice.
>> =A0*/
>> #define SECCOMP_RET_KILL =A0 =A0 =A00x00000000U /* kill the task immedia=
tely */
>> -#define SECCOMP_RET_TRAP =A0 =A0 0x00020000U /* disallow and send sigtr=
ap */
>> -#define SECCOMP_RET_ERRNO =A0 =A00x00030000U /* returns an errno */
>> +#define SECCOMP_RET_TRAP =A0 =A0 0x00020000U /* only send sigtrap */
>> +#define SECCOMP_RET_ERRNO =A0 =A00x00030000U /* only return an errno */
>> +#define SECCOMP_RET_TRACE =A0 =A00x7ffe0000U /* allow, but notify the t=
racer */
>> #define SECCOMP_RET_ALLOW =A0 =A0 0x7fff0000U /* allow */
>>
>> /* Masks for the return value sections. */
>> @@ -55,6 +56,7 @@ struct seccomp_filter;
>> =A0*
>> =A0* @mode: =A0indicates one of the valid values above for controlled
>> =A0* =A0 =A0 =A0 =A0 system calls available to a process.
>> + * @in_trace: indicates a seccomp filter hand off to ptrace has occurre=
d
>> =A0* @filter: The metadata and ruleset for determining what system calls
>> =A0* =A0 =A0 =A0 =A0 =A0are allowed for a task.
>> =A0*
>> @@ -63,6 +65,7 @@ struct seccomp_filter;
>> =A0*/
>> struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 int in_trace;
>> =A0 =A0 =A0 struct seccomp_filter *filter;
>> };
>>
>> @@ -116,15 +119,20 @@ static inline int seccomp_mode(struct seccomp *s)
>> extern void put_seccomp_filter(struct seccomp_filter *);
>> extern void copy_seccomp(struct seccomp *child,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct seccomp *par=
ent);
>> +extern void seccomp_tracer_done(void);
>> #else =A0/* CONFIG_SECCOMP_FILTER */
>> /* The macro consumes the ->filter reference. */
>> #define put_seccomp_filter(_s) do { } while (0)
>> -
>> static inline void copy_seccomp(struct seccomp *child,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct=
 seccomp *prev)
>> {
>> =A0 =A0 =A0 return;
>> }
>> +
>> +static inline void seccomp_tracer_done(void)
>> +{
>> + =A0 =A0 return;
>> +}
>> #endif /* CONFIG_SECCOMP_FILTER */
>> #endif /* __KERNEL__ */
>> #endif /* _LINUX_SECCOMP_H */
>> diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
>> index a71a292..5000169 100644
>> --- a/include/linux/tracehook.h
>> +++ b/include/linux/tracehook.h
>> @@ -48,6 +48,7 @@
>>
>> #include <linux/sched.h>
>> #include <linux/ptrace.h>
>> +#include <linux/seccomp.h>
>> #include <linux/security.h>
>> struct linux_binprm;
>>
>> @@ -59,7 +60,7 @@ static inline void ptrace_report_syscall(struct pt_reg=
s *regs)
>> =A0 =A0 =A0 int ptrace =3D current->ptrace;
>>
>> =A0 =A0 =A0 if (!(ptrace & PT_PTRACED))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> =A0 =A0 =A0 ptrace_notify(SIGTRAP | ((ptrace & PT_TRACESYSGOOD) ? 0x80 :=
 0));
>>
>> @@ -72,6 +73,10 @@ static inline void ptrace_report_syscall(struct pt_re=
gs *regs)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 send_sig(current->exit_code, current, 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->exit_code =3D 0;
>> =A0 =A0 =A0 }
>> +
>> +out:
>> + =A0 =A0 if (ptrace & PT_TRACE_SECCOMP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_tracer_done();
>> }
>>
>> /**
>> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
>> index 00ab2ca..61e5ac4 100644
>> --- a/kernel/ptrace.c
>> +++ b/kernel/ptrace.c
>> @@ -19,6 +19,7 @@
>> #include <linux/signal.h>
>> #include <linux/audit.h>
>> #include <linux/pid_namespace.h>
>> +#include <linux/seccomp.h>
>> #include <linux/syscalls.h>
>> #include <linux/uaccess.h>
>> #include <linux/regset.h>
>> @@ -551,6 +552,9 @@ static int ptrace_setoptions(struct task_struct *chi=
ld, unsigned
> long data)
>> =A0 =A0 =A0 if (data & PTRACE_O_TRACEEXIT)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->ptrace |=3D PT_TRACE_EXIT;
>>
>> + =A0 =A0 if (data & PTRACE_O_TRACESECCOMP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 child->ptrace |=3D PT_TRACE_SECCOMP;
>> +
>> =A0 =A0 =A0 return (data & ~PTRACE_O_MASK) ? -EINVAL : 0;
>> }
>>
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index fc25d3a..120ceec 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -270,13 +270,12 @@ void put_seccomp_filter(struct seccomp_filter *ori=
g)
>> =A0* @child: forkee's seccomp
>> =A0* @prev: forker's seccomp
>> =A0*
>> - * Ensures that @child inherits seccomp mode and state if
>> - * seccomp filtering is in use.
>> + * Ensures that @child inherits seccomp filtering if in use.
>> =A0*/
>> void copy_seccomp(struct seccomp *child,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct seccomp *prev)
>> {
>> - =A0 =A0 child->mode =3D prev->mode;
>> + =A0 =A0 /* Other fields are handled by dup_task_struct. */
>> =A0 =A0 =A0 child->filter =3D get_seccomp_filter(prev->filter);
>> }
>>
>> @@ -299,6 +298,31 @@ static void seccomp_send_sigsys(int syscall, int re=
ason)
>> =A0 =A0 =A0 info.si_syscall =3D syscall;
>> =A0 =A0 =A0 force_sig_info(SIGSYS, &info, current);
>> }
>> +
>> +/**
>> + * seccomp_tracer_done: handles clean up after handing off to ptrace.
>> + *
>> + * Checks that the hand off from SECCOMP_RET_TRACE to ptrace was not
>> + * subject to a race condition where the tracer disappeared or was
>> + * never notified because of a pending SIGKILL.
>> + * N.b., if ptrace_syscall_entry returned an int, this call could just
>> + * =A0 =A0 =A0 disable the system call rather than using do_exit on tra=
cer death.
>> + */
>> +void seccomp_tracer_done(void)
>> +{
>> + =A0 =A0 struct seccomp *s =3D &current->seccomp;
>> + =A0 =A0 /* Some other slow-path call occurred */
>> + =A0 =A0 if (!s->in_trace)
>
> So I guess it's more like 'check_trace' or something.

Yup - but I think this whole thing can go now.

>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 s->in_trace =3D 0;
>> + =A0 =A0 /* Tracer detached/died at some point after handing off to ptr=
ace. */
>> + =A0 =A0 if (!(current->ptrace & PT_PTRACED))
>> + =A0 =A0 =A0 =A0 =A0 =A0 do_exit(SIGKILL);
>
> This isn't possible, because seccomp_tracer_done() is only called when
> PT_TRACE_SECCOMP is set, which gets cleared when the tracer goes away.

Well it's still a race.  What I should be checking is
current->seccomp.mode =3D=3D 2 then, once called, check if in_trace is 1.

I'll rework this whole thing with the inverted logic. It is much more appea=
ling.

>> + =A0 =A0 /* If there is a SIGKILL pending, just do_exit. */
>> + =A0 =A0 if (sigismember(&current->pending.signal, SIGKILL) ||
>> + =A0 =A0 =A0 =A0 sigismember(&current->signal->shared_pending.signal, S=
IGKILL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 do_exit(SIGKILL);
>
> This bit shouldn't be necessary, as it should be in ptrace core. Oleg's
> fix should be upstream before your seccomp patches. Except if I missed
> something and this is not to fix current buggy behaviour that the task
> is only killed after the current syscall?

Cool.  The old behavior is the task being killed after the current
syscall.  Any new behavior should fix this I hope :)

> But you got the logic reversed, the task should be killed except if
> seccomp_tracer_done() was called. You can't kill the task from within
> seccomp_tracer_done(), that is unreliable.

Yeah - this is pretty ugly no matter which why you slice it.

>> +}
>> #endif =A0 =A0 =A0 =A0/* CONFIG_SECCOMP_FILTER */
>>
>> /*
>> @@ -360,6 +384,28 @@ int __secure_computing_int(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigsys(this_sys=
call, reason_code);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If there is no interested t=
racer, return ENOSYS. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(current->ptrace & PT_TRA=
CE_SECCOMP))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Delegate to TIF_SYSCALL_T=
RACE. This allows fast-path
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* seccomp calls to delegate=
 to slow-path if needed.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Since TIF_SYSCALL_TRACE w=
ill be unset on ptrace(2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* continuation, there shoul=
d be no direct side
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* effects. =A0If TIF_SYSCAL=
L_TRACE is already set, this
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* has no effect. =A0Upon co=
mpletion of handling, ptrace
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will call seccomp_tracer_=
done() which helps handle
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* races.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_tsk_thread_flag(current, T=
IF_SYSCALL_TRACE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.in_trace =3D =
1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Allow the call, but upon =
completion, ptrace will
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* call seccomp_tracer_done =
to handle tracer
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* disappearance/death to en=
sure notification occurred.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ALLOW:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_KILL:
>> --
>


Thanks!
will
