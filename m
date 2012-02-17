From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 6/8] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Fri, 17 Feb 2012 06:08:04 +0100
Message-ID: <a3cc7e306f0ad79f3d49921d8586d18c.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <1329422549-16407-6-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost1.greenhost.nl ([195.190.28.78]:47284 "EHLO
	smarthost1.greenhost.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab2BQFIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 00:08:07 -0500
In-Reply-To: <1329422549-16407-6-git-send-email-wad@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, February 16, 2012 21:02, Will Drewry wrote:
> A new return value is added to seccomp filters that allows
> the system call policy for the affected system calls to be
> implemented by a ptrace(2)ing process.
>
> If a tracer attaches to a task using PTRACE_SECCOMP, then the
> traced process will notify the tracer if a seccomp filter
> returns SECCOMP_RET_TRACE.  If the tracer detaches, then
> system calls made by the task will fail.

This is what I need to make BPF useful to me.

To have least impact on current and future (user space) ptrace code,
I suspect it's best if PTRACE_SECCOMP becomes a ptrace option. That
may be a little bit more work, but the end result should be more
robust against any future ptrace changes.

> To ensure that seccomp is syscall fast-path friendly in the future,
> ptrace is delegated to by setting TIF_SYSCALL_TRACE.  Since seccomp
> events are equivalent to system call entry events, this allows for
> seccomp to be evaluated as a fork off the fast-path and only,
> optionally, jump to the slow path.

I think you have to go through the slow path anyway to get access to
the syscall arguments, at least for some archs.

> When the tracer is notified, all
> will function as with ptrace(PTRACE_SYSCALLS), but when the tracer calls
> ptrace(PTRACE_SECCOMP), TIF_SYSCALL_TRACE will be unset and the task
> will proceed.
> Note, this patch takes the path of least resistance for integration. It
> is not necessarily the best path and any guidance will be appreciated!
> The key challenges are ensuring that register state is correct at
> ptrace handoff and ensuring that all only seccomp-based notification
> occurs.
>
> v8: - guarded PTRACE_SECCOMP use with an ifdef
> v7: - introduced
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
>  arch/Kconfig            |   12 ++++++++----
>  include/linux/ptrace.h  |    1 +
>  include/linux/seccomp.h |   39 +++++++++++++++++++++++++++++++++++++--
>  kernel/ptrace.c         |   12 ++++++++++++
>  kernel/seccomp.c        |   15 +++++++++++++++
>  5 files changed, 73 insertions(+), 6 deletions(-)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index a01c151..ae40aec 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -203,10 +203,14 @@ config HAVE_ARCH_SECCOMP_FILTER
>  	bool
>  	help
>  	  This symbol should be selected by an architecure if it provides
> -	  asm/syscall.h, specifically syscall_get_arguments(),
> -	  syscall_set_return_value(), and syscall_rollback().
> -	  Additionally, its system call entry path must respect a return
> -	  value of -1 from __secure_computing_int() and/or secure_computing().
> +	  linux/tracehook.h, for TIF_SYSCALL_TRACE, and asm/syscall.h,
> +	  specifically syscall_get_arguments(), syscall_set_return_value(), and
> +	  syscall_rollback().  Additionally, its system call entry path must
> +	  respect a return value of -1 from __secure_computing_int() and/or
> +	  secure_computing().  If secure_computing is not in the system call
> +	  slow path, the thread info flags will need to be checked upon exit to
> +	  ensure delegation to ptrace(2) did not occur, or if it did, jump to
> +	  the slow-path.
>
>  config SECCOMP_FILTER
>  	def_bool y
> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
> index c2f1f6a..00220de 100644
> --- a/include/linux/ptrace.h
> +++ b/include/linux/ptrace.h
> @@ -50,6 +50,7 @@
>  #define PTRACE_SEIZE		0x4206
>  #define PTRACE_INTERRUPT	0x4207
>  #define PTRACE_LISTEN		0x4208
> +#define PTRACE_SECCOMP		0x4209
>
>  /* flags in @data for PTRACE_SEIZE */
>  #define PTRACE_SEIZE_DEVEL	0x80000000 /* temp flag for development */
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index 1be562f..1cb7d5c 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -19,8 +19,9 @@
>   * selects the least permissive choice.
>   */
>  #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
> -#define SECCOMP_RET_TRAP	0x00020000U /* disallow and send sigtrap */
> -#define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
> +#define SECCOMP_RET_TRAP	0x00020000U /* only send sigtrap */
> +#define SECCOMP_RET_ERRNO	0x00030000U /* only return an errno */
> +#define SECCOMP_RET_TRACE	0x7ffe0000U /* allow, but notify the tracer */
>  #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
>
>  /* Masks for accessing the above values. */
> @@ -51,6 +52,7 @@ struct seccomp_filter;
>   *
>   * @mode:  indicates one of the valid values above for controlled
>   *         system calls available to a process.
> + * @flags: per-process flags. Currently only used for SECCOMP_FLAGS_TRACED.

If it has only one use, don't make it flags then. You can always change
it to flags later. Until then, it only makes things less clear.

I actually think it's better to get rid of this altogether, and only
check task->ptrace for PTRACE_O_SECCOMP. That would avoid a lot of code.

>   * @filter: The metadata and ruleset for determining what system calls
>   *          are allowed for a task.
>   *
> @@ -59,9 +61,13 @@ struct seccomp_filter;
>   */
>  struct seccomp {
>  	int mode;
> +	unsigned long flags;

Why a long? That wastes 4 bytes of padding and you still can't use the upper
32-bits because you have to support 32-bit systems too.

>  	struct seccomp_filter *filter;
>  };
>
> +/* Indicates if a tracer is attached. */
> +#define SECCOMP_FLAGS_TRACED	0

That's not the best way to check if a tracer is attached, and if you did use
it for that, you don't need to toggle it all the time.

> +
>  /*
>   * Direct callers to __secure_computing should be updated as
>   * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.
> @@ -83,6 +89,20 @@ static inline int seccomp_mode(struct seccomp *s)
>  	return s->mode;
>  }
>
> +static inline void seccomp_set_traced(struct seccomp *s)
> +{
> +	set_bit(SECCOMP_FLAGS_TRACED, &s->flags);
> +}
> +
> +static inline void seccomp_clear_traced(struct seccomp *s)
> +{
> +	clear_bit(SECCOMP_FLAGS_TRACED, &s->flags);
> +}
> +
> +static inline int seccomp_traced(struct seccomp *s)
> +{
> +	return test_bit(SECCOMP_FLAGS_TRACED, &s->flags);
> +}
>  #else /* CONFIG_SECCOMP */
>
>  #include <linux/errno.h>
> @@ -106,6 +126,21 @@ static inline int seccomp_mode(struct seccomp *s)
>  {
>  	return 0;
>  }
> +
> +static inline void seccomp_set_traced(struct seccomp *s)
> +{
> +	return;
> +}
> +
> +static inline void seccomp_clear_traced(struct seccomp *s)
> +{
> +	return;
> +}
> +
> +static inline int seccomp_traced(struct seccomp *s)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_SECCOMP */
>
>  #ifdef CONFIG_SECCOMP_FILTER
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 00ab2ca..199a6da 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -19,6 +19,7 @@
>  #include <linux/signal.h>
>  #include <linux/audit.h>
>  #include <linux/pid_namespace.h>
> +#include <linux/seccomp.h>
>  #include <linux/syscalls.h>
>  #include <linux/uaccess.h>
>  #include <linux/regset.h>
> @@ -426,6 +427,7 @@ static int ptrace_detach(struct task_struct *child, unsigned int
data)
>  	/* Architecture-specific hardware disable .. */
>  	ptrace_disable(child);
>  	clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
> +	seccomp_clear_traced(&child->seccomp);
>
>  	write_lock_irq(&tasklist_lock);
>  	/*
> @@ -616,6 +618,13 @@ static int ptrace_resume(struct task_struct *child, long request,
>  	else
>  		clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
>
> +#ifdef CONFIG_SECCOMP_FILTER
> +	if (request == PTRACE_SECCOMP)
> +		seccomp_set_traced(&child->seccomp);
> +	else
> +		seccomp_clear_traced(&child->seccomp);
> +#endif
> +
>  #ifdef TIF_SYSCALL_EMU
>  	if (request == PTRACE_SYSEMU || request == PTRACE_SYSEMU_SINGLESTEP)
>  		set_tsk_thread_flag(child, TIF_SYSCALL_EMU);
> @@ -816,6 +825,9 @@ int ptrace_request(struct task_struct *child, long request,
>  	case PTRACE_SYSEMU:
>  	case PTRACE_SYSEMU_SINGLESTEP:
>  #endif
> +#ifdef CONFIG_SECCOMP_FILTER
> +	case PTRACE_SECCOMP:
> +#endif
>  	case PTRACE_SYSCALL:
>  	case PTRACE_CONT:
>  		return ptrace_resume(child, request, data);
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index c75485c..f9d419f 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -289,6 +289,8 @@ void copy_seccomp(struct seccomp *child,
>  {
>  	child->mode = prev->mode;
>  	child->filter = get_seccomp_filter(prev->filter);
> +	/* Note, this leaves seccomp tracing enabled across fork. */
> +	child->flags = prev->flags;

What if the child isn't ptraced?

>  }
>
>  /**
> @@ -363,6 +365,19 @@ int __secure_computing_int(int this_syscall)
>  			syscall_rollback(current, task_pt_regs(current));
>  			seccomp_send_sigtrap();
>  			return -1;
> +		case SECCOMP_RET_TRACE:
> +			if (!seccomp_traced(&current->seccomp))
> +				return -1;
> +			/*
> +			 * Delegate to TIF_SYSCALL_TRACE. This allows fast-path
> +			 * seccomp calls to delegate to slow-path if needed.
> +			 * Since TIF_SYSCALL_TRACE will be unset on ptrace(2)
> +			 * continuation, there should be no direct side
> +			 * effects.  If TIF_SYSCALL_TRACE is already set, this
> +			 * has no effect.
> +			 */
> +			set_tsk_thread_flag(current, TIF_SYSCALL_TRACE);
> +			/* Falls through to allow. */

This is nice and simple, but not race-free. You want to check if the ptracer
handled the event or not. If the ptracer died before handling this then the
syscall should be denied and the task should be killed.

Many people would like a PTRACE_O_KILL_TRACEE_IF_DEBUGGER_DIES option,
Oleg was working on that, among other things. Perhaps re-use that to
handle this case too?

>  		case SECCOMP_RET_ALLOW:

For this and the ERRNO case you could check that PTRACE_O_SECCOMP option and
decide to do something or not in ptrace.

>  			return 0;
>  		case SECCOMP_RET_KILL:
> --
> 1.7.5.4
>
>

Greetings,

Indan
