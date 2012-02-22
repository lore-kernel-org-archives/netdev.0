From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v10 09/11] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Wed, 22 Feb 2012 13:22:51 +0100
Message-ID: <25f69829d492b002f418955d9ce30321.squirrel@webmail.greenhost.nl>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
    <1329845435-2313-9-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org,
	"Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1329845435-2313-9-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, February 21, 2012 18:30, Will Drewry wrote:
> A new return value is added to seccomp filters that allows
> the system call policy for the affected system calls to be
> implemented by a ptrace(2)ing process.
>
> If a tracer attaches to a task, specifies the PTRACE_O_TRACESECCOMP
> option, then PTRACE_CONT.

Awkward formulation here. I'd start with "If a tracer sets the
PTRACE_O_TRACESECCOMP option, then ..."

> After doing so, the tracer will
> be notified if a seccomp filter program returns SECCOMP_RET_TRACE.

This means that strace and gdb won't see seccomp filtered syscalls.
I think you have to reverse the logic and have an option that asks
to hide normal SECCOMP_RET_ERRNO, but not SECCOMP_RET_TRACE ones.

That gives the expected behaviour in all cases: Programs not setting
it behave as they do now, and co-operating tracers can ignore syscall
events they're not interested in.

> If there is no seccomp event tracer, SECCOMP_RET_TRACE system calls will
> return a -ENOSYS errno to user space.  If the tracer detaches during a
> hand-off, the process will be killed.
>
> To ensure that seccomp is syscall fast-path friendly in the future,
> ptrace is delegated to by setting TIF_SYSCALL_TRACE.  Since seccomp
> events are equivalent to system call entry events, this allows for
> seccomp to be evaluated as a fork off the fast-path and only,
> optionally, jump to the slow path. When the tracer is notified, all
> will function as with ptrace(PTRACE_SYSCALLS), but when the tracer calls
> ptrace(PTRACE_CONT), TIF_SYSCALL_TRACE will be unset and the task
> will proceed just receiving PTRACE_O_TRACESECCOMP events.

Please, no. That's making it more complicated than necessary.

I propose to keep the ptrace rules exactly the same as they are, with
the only change being that if PTRACE_O_SECCOMP is set, no syscall events
will be generated for SECCOMP_RET_ERRNO. This way ptrace behaviour is
the same, but only less syscall events are received. With your way
ptracers see syscall events when they normally wouldn't.

>
> I realize there are pending patches for cleaning up ptrace events.
> I can either reintegrate with those when they are available or
> vice versa. That's assuming these changes make sense and are viable.
>
> v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
> v9:  - n/a
> v8:  - guarded PTRACE_SECCOMP use with an ifdef
> v7:  - introduced
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
> arch/Kconfig              |    4 +++
> include/linux/ptrace.h    |    7 ++++-
> include/linux/seccomp.h   |   14 +++++++++--
> include/linux/tracehook.h |    7 +++++-
> kernel/ptrace.c           |    4 +++
> kernel/seccomp.c          |   52 ++++++++++++++++++++++++++++++++++++++++++--
> 6 files changed, 79 insertions(+), 9 deletions(-)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 6d6d9dc..02c18ca 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -203,6 +203,7 @@ config HAVE_ARCH_SECCOMP_FILTER
> 	bool
> 	help
> 	  This symbol should be selected by an architecure if it provides:
> +	  linux/tracehook.h, for TIF_SYSCALL_TRACE and ptrace_report_syscall
> 	  asm/syscall.h:
> 	  - syscall_get_arch()
> 	  - syscall_get_arguments()
> @@ -211,6 +212,9 @@ config HAVE_ARCH_SECCOMP_FILTER
> 	  SIGSYS siginfo_t support must be implemented.
> 	  __secure_computing_int()/secure_computing()'s return value must be
> 	  checked, with -1 resulting in the syscall being skipped.
> +	  If secure_computing is not in the system call slow path, the thread
> +	  info flags will need to be checked upon exit to ensure delegation to
> +	  ptrace(2) did not occur, or if it did, jump to the slow-path.
>
> config SECCOMP_FILTER
> 	def_bool y
> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
> index c2f1f6a..2fccdbc 100644
> --- a/include/linux/ptrace.h
> +++ b/include/linux/ptrace.h
> @@ -62,8 +62,9 @@
> #define PTRACE_O_TRACEEXEC	0x00000010
> #define PTRACE_O_TRACEVFORKDONE	0x00000020
> #define PTRACE_O_TRACEEXIT	0x00000040
> +#define PTRACE_O_TRACESECCOMP	0x00000080
>
> -#define PTRACE_O_MASK		0x0000007f
> +#define PTRACE_O_MASK		0x000000ff
>
> /* Wait extended result codes for the above trace options.  */
> #define PTRACE_EVENT_FORK	1
> @@ -73,6 +74,7 @@
> #define PTRACE_EVENT_VFORK_DONE	5
> #define PTRACE_EVENT_EXIT	6
> #define PTRACE_EVENT_STOP	7
> +#define PTRACE_EVENT_SECCOMP	8	/* never directly delivered */
>
> #include <asm/ptrace.h>
>
> @@ -101,8 +103,9 @@
> #define PT_TRACE_EXEC		PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
> #define PT_TRACE_VFORK_DONE	PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
> #define PT_TRACE_EXIT		PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
> +#define PT_TRACE_SECCOMP	PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
>
> -#define PT_TRACE_MASK	0x000003f4
> +#define PT_TRACE_MASK	0x00000ff4
>
> /* single stepping state bits (used on ARM and PA-RISC) */
> #define PT_SINGLESTEP_BIT	31
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index d039b7b..16887c1 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -19,8 +19,9 @@
>  * selects the least permissive choice.
>  */
> #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
> -#define SECCOMP_RET_TRAP	0x00020000U /* disallow and send sigtrap */
> -#define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
> +#define SECCOMP_RET_TRAP	0x00020000U /* only send sigtrap */
> +#define SECCOMP_RET_ERRNO	0x00030000U /* only return an errno */
> +#define SECCOMP_RET_TRACE	0x7ffe0000U /* allow, but notify the tracer */
> #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
>
> /* Masks for the return value sections. */
> @@ -55,6 +56,7 @@ struct seccomp_filter;
>  *
>  * @mode:  indicates one of the valid values above for controlled
>  *         system calls available to a process.
> + * @in_trace: indicates a seccomp filter hand off to ptrace has occurred
>  * @filter: The metadata and ruleset for determining what system calls
>  *          are allowed for a task.
>  *
> @@ -63,6 +65,7 @@ struct seccomp_filter;
>  */
> struct seccomp {
> 	int mode;
> +	int in_trace;
> 	struct seccomp_filter *filter;
> };
>
> @@ -116,15 +119,20 @@ static inline int seccomp_mode(struct seccomp *s)
> extern void put_seccomp_filter(struct seccomp_filter *);
> extern void copy_seccomp(struct seccomp *child,
> 			 const struct seccomp *parent);
> +extern void seccomp_tracer_done(void);
> #else  /* CONFIG_SECCOMP_FILTER */
> /* The macro consumes the ->filter reference. */
> #define put_seccomp_filter(_s) do { } while (0)
> -
> static inline void copy_seccomp(struct seccomp *child,
> 				const struct seccomp *prev)
> {
> 	return;
> }
> +
> +static inline void seccomp_tracer_done(void)
> +{
> +	return;
> +}
> #endif /* CONFIG_SECCOMP_FILTER */
> #endif /* __KERNEL__ */
> #endif /* _LINUX_SECCOMP_H */
> diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
> index a71a292..5000169 100644
> --- a/include/linux/tracehook.h
> +++ b/include/linux/tracehook.h
> @@ -48,6 +48,7 @@
>
> #include <linux/sched.h>
> #include <linux/ptrace.h>
> +#include <linux/seccomp.h>
> #include <linux/security.h>
> struct linux_binprm;
>
> @@ -59,7 +60,7 @@ static inline void ptrace_report_syscall(struct pt_regs *regs)
> 	int ptrace = current->ptrace;
>
> 	if (!(ptrace & PT_PTRACED))
> -		return;
> +		goto out;
>
> 	ptrace_notify(SIGTRAP | ((ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
>
> @@ -72,6 +73,10 @@ static inline void ptrace_report_syscall(struct pt_regs *regs)
> 		send_sig(current->exit_code, current, 1);
> 		current->exit_code = 0;
> 	}
> +
> +out:
> +	if (ptrace & PT_TRACE_SECCOMP)
> +		seccomp_tracer_done();
> }
>
> /**
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 00ab2ca..61e5ac4 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -19,6 +19,7 @@
> #include <linux/signal.h>
> #include <linux/audit.h>
> #include <linux/pid_namespace.h>
> +#include <linux/seccomp.h>
> #include <linux/syscalls.h>
> #include <linux/uaccess.h>
> #include <linux/regset.h>
> @@ -551,6 +552,9 @@ static int ptrace_setoptions(struct task_struct *child, unsigned
long data)
> 	if (data & PTRACE_O_TRACEEXIT)
> 		child->ptrace |= PT_TRACE_EXIT;
>
> +	if (data & PTRACE_O_TRACESECCOMP)
> +		child->ptrace |= PT_TRACE_SECCOMP;
> +
> 	return (data & ~PTRACE_O_MASK) ? -EINVAL : 0;
> }
>
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index fc25d3a..120ceec 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -270,13 +270,12 @@ void put_seccomp_filter(struct seccomp_filter *orig)
>  * @child: forkee's seccomp
>  * @prev: forker's seccomp
>  *
> - * Ensures that @child inherits seccomp mode and state if
> - * seccomp filtering is in use.
> + * Ensures that @child inherits seccomp filtering if in use.
>  */
> void copy_seccomp(struct seccomp *child,
> 		  const struct seccomp *prev)
> {
> -	child->mode = prev->mode;
> +	/* Other fields are handled by dup_task_struct. */
> 	child->filter = get_seccomp_filter(prev->filter);
> }
>
> @@ -299,6 +298,31 @@ static void seccomp_send_sigsys(int syscall, int reason)
> 	info.si_syscall = syscall;
> 	force_sig_info(SIGSYS, &info, current);
> }
> +
> +/**
> + * seccomp_tracer_done: handles clean up after handing off to ptrace.
> + *
> + * Checks that the hand off from SECCOMP_RET_TRACE to ptrace was not
> + * subject to a race condition where the tracer disappeared or was
> + * never notified because of a pending SIGKILL.
> + * N.b., if ptrace_syscall_entry returned an int, this call could just
> + *       disable the system call rather than using do_exit on tracer death.
> + */
> +void seccomp_tracer_done(void)
> +{
> +	struct seccomp *s = &current->seccomp;
> +	/* Some other slow-path call occurred */
> +	if (!s->in_trace)

So I guess it's more like 'check_trace' or something.

> +		return;
> +	s->in_trace = 0;
> +	/* Tracer detached/died at some point after handing off to ptrace. */
> +	if (!(current->ptrace & PT_PTRACED))
> +		do_exit(SIGKILL);

This isn't possible, because seccomp_tracer_done() is only called when
PT_TRACE_SECCOMP is set, which gets cleared when the tracer goes away.

> +	/* If there is a SIGKILL pending, just do_exit. */
> +	if (sigismember(&current->pending.signal, SIGKILL) ||
> +	    sigismember(&current->signal->shared_pending.signal, SIGKILL))
> +		do_exit(SIGKILL);

This bit shouldn't be necessary, as it should be in ptrace core. Oleg's
fix should be upstream before your seccomp patches. Except if I missed
something and this is not to fix current buggy behaviour that the task
is only killed after the current syscall?

But you got the logic reversed, the task should be killed except if
seccomp_tracer_done() was called. You can't kill the task from within
seccomp_tracer_done(), that is unreliable.

> +}
> #endif	/* CONFIG_SECCOMP_FILTER */
>
> /*
> @@ -360,6 +384,28 @@ int __secure_computing_int(int this_syscall)
> 			seccomp_send_sigsys(this_syscall, reason_code);
> 			return -1;
> 		}
> +		case SECCOMP_RET_TRACE:
> +			/* If there is no interested tracer, return ENOSYS. */
> +			if (!(current->ptrace & PT_TRACE_SECCOMP))
> +				return -1;
> +			/*
> +			 * Delegate to TIF_SYSCALL_TRACE. This allows fast-path
> +			 * seccomp calls to delegate to slow-path if needed.
> +			 * Since TIF_SYSCALL_TRACE will be unset on ptrace(2)
> +			 * continuation, there should be no direct side
> +			 * effects.  If TIF_SYSCALL_TRACE is already set, this
> +			 * has no effect.  Upon completion of handling, ptrace
> +			 * will call seccomp_tracer_done() which helps handle
> +			 * races.
> +			 */
> +			set_tsk_thread_flag(current, TIF_SYSCALL_TRACE);
> +			current->seccomp.in_trace = 1;
> +			/*
> +			 * Allow the call, but upon completion, ptrace will
> +			 * call seccomp_tracer_done to handle tracer
> +			 * disappearance/death to ensure notification occurred.
> +			 */
> +			return 0;
> 		case SECCOMP_RET_ALLOW:
> 			return 0;
> 		case SECCOMP_RET_KILL:
> --

Greetings,

Indan
