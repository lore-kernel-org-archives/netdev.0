From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 10/13] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Wed, 14 Mar 2012 08:31:07 +0100
Message-ID: <34b2e80343549454d6c026237f248c86.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <1331587715-26069-10-git-send-email-wad@chromium.org>
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
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1331587715-26069-10-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, March 12, 2012 22:28, Will Drewry wrote:
> This change adds support for a new ptrace option, PTRACE_O_TRACESECCOMP,
> and a new return value for seccomp BPF programs, SECCOMP_RET_TRACE.
>
> When a tracer specifies the PTRACE_O_TRACESECCOMP ptrace option, the
> tracer will be notified for any syscall that results in a BPF program
> returning SECCOMP_RET_TRACE.  The 16-bit SECCOMP_RET_DATA mask of the
> BPF program return value will be passed as the ptrace_message and may be
> retrieved using PTRACE_GETEVENTMSG.

Maybe good to tell it gets notified with PTRACE_EVENT_SECCOMP.

>
> If the subordinate process is not using seccomp filter, then no
> system call notifications will occur even if the option is specified.
>
> If there is no attached tracer when SECCOMP_RET_TRACE is returned,
> the system call will not be executed and an -ENOSYS errno will be
> returned to userspace.

When no tracer with PTRACE_O_TRACESECCOMP set is attached?
(Because that's what the code is doing.)

>
> This change adds a dependency on the system call slow path.  Any future
> efforts to use the system call fast path for seccomp filter will need to
> address this restriction.
>
> v14: - rebase/nochanges
> v13: - rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
>       (Brings back a change to ptrace.c and the masks.)
> v12: - rebase to linux-next
>     - use ptrace_event and update arch/Kconfig to mention slow-path dependency
>     - drop all tracehook changes and inclusion (oleg@redhat.com)
> v11: - invert the logic to just make it a PTRACE_SYSCALL accelerator
>       (indan@nul.nu)
> v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
> v9:  - n/a
> v8:  - guarded PTRACE_SECCOMP use with an ifdef
> v7:  - introduced
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
> arch/Kconfig            |   11 ++++++-----
> include/linux/ptrace.h  |    7 +++++--
> include/linux/seccomp.h |    1 +
> kernel/ptrace.c         |    3 +++
> kernel/seccomp.c        |   20 +++++++++++++++-----
> 5 files changed, 30 insertions(+), 12 deletions(-)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index d92a78e..3f8132c 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -202,15 +202,16 @@ config HAVE_CMPXCHG_DOUBLE
> config HAVE_ARCH_SECCOMP_FILTER
> 	bool
> 	help
> -	  This symbol should be selected by an architecure if it provides:
> -	  asm/syscall.h:
> +	  An arch should select this symbol if it provides all of these things:
> 	  - syscall_get_arch()
> 	  - syscall_get_arguments()
> 	  - syscall_rollback()
> 	  - syscall_set_return_value()
> -	  SIGSYS siginfo_t support must be implemented.
> -	  __secure_computing_int()/secure_computing()'s return value must be
> -	  checked, with -1 resulting in the syscall being skipped.
> +	  - SIGSYS siginfo_t support
> +	  - uses __secure_computing_int() or secure_computing()
> +	  - secure_computing is called from a ptrace_event()-safe context
> +	  - secure_computing return value is checked and a return value of -1
> +	    results in the system call being skipped immediately.
>
> config SECCOMP_FILTER
> 	def_bool y
> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
> index c2f1f6a..84b3418 100644
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
> +#define PTRACE_EVENT_SECCOMP	8

I think PTRACE_EVENT_STOP is supposed to be hidden, it's never directly
seen by user space. Instead of doing the obvious thing, they went the
crazy PTRACE_INTERRUPT + PTRACE_LISTEN way.

So it's better to add PTRACE_EVENT_SECCOMP as 8 and bump STOP one up.
But if PTRACE_EVENT_STOP is really hidden then it shouldn't show up in
the user space header at all, it should be after the ifdef KERNEL.

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

This is wrong. Shouldn't it be 0xbf4? (0x7f4 if you bump STOP up.)

>
> /* single stepping state bits (used on ARM and PA-RISC) */
> #define PT_SINGLESTEP_BIT	31
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index e6d4b56..f4c1774 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -21,6 +21,7 @@
> #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
> #define SECCOMP_RET_TRAP	0x00020000U /* disallow and force a SIGSYS */
> #define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
> +#define SECCOMP_RET_TRACE	0x7ffe0000U /* pass to a tracer or disallow */
> #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */

Maybe a good idea to leave more gaps between all the return codes, in
case new return codes are added in the future that fall between existing
ones? E.g:

#define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
#define SECCOMP_RET_TRAP	0x00100000U /* disallow and force a SIGSYS */
#define SECCOMP_RET_ERRNO	0x00200000U /* returns an errno */
#define SECCOMP_RET_TRACE	0x00300000U /* pass to a tracer or disallow */
#define SECCOMP_RET_ALLOW	0x00400000U /* allow */

>
> /* Masks for the return value sections. */
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 00ab2ca..8cf6da1 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -551,6 +551,9 @@ static int ptrace_setoptions(struct task_struct *child, unsigned
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
> index 140490a..ddacc68 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -17,13 +17,13 @@
> #include <linux/audit.h>
> #include <linux/compat.h>
> #include <linux/filter.h>
> +#include <linux/ptrace.h>
> #include <linux/sched.h>
> #include <linux/seccomp.h>
> #include <linux/security.h>
> #include <linux/slab.h>
> #include <linux/uaccess.h>
>
> -#include <linux/tracehook.h>
> #include <asm/syscall.h>
>
> /* #define SECCOMP_DEBUG 1 */
> @@ -389,14 +389,24 @@ int __secure_computing_int(int this_syscall)
> 						 -(action & SECCOMP_RET_DATA),
> 						 0);
> 			return -1;
> -		case SECCOMP_RET_TRAP: {
> -			int reason_code = action & SECCOMP_RET_DATA;
> +		case SECCOMP_RET_TRAP:
> 			/* Show the handler the original registers. */
> 			syscall_rollback(current, task_pt_regs(current));
> 			/* Let the filter pass back 16 bits of data. */
> -			seccomp_send_sigsys(this_syscall, reason_code);
> +			seccomp_send_sigsys(this_syscall,
> +					    action & SECCOMP_RET_DATA);
> 			return -1;
> -		}

These are unrelated changes and probably shouldn't be here. It just makes
it harder to review the code if you change it in a later patch for no
apparent reason.

> +		case SECCOMP_RET_TRACE:
> +			/* Skip these calls if there is no tracer. */
> +			if (!ptrace_event_enabled(current,
> +						  PTRACE_EVENT_SECCOMP))

One line please, it's 81 chars.

> +				return -1;
> +			/* Allow the BPF to provide the event message */
> +			ptrace_event(PTRACE_EVENT_SECCOMP,
> +				     action & SECCOMP_RET_DATA);

Why not move "int reason_code = action & SECCOMP_RET_DATA;" to the start
of the function out of the if checks, instead of duplicating the code?

> +			if (fatal_signal_pending(current))
> +				break;
> +			return 0;
> 		case SECCOMP_RET_ALLOW:
> 			return 0;
> 		case SECCOMP_RET_KILL:

Greetings,

Indan


