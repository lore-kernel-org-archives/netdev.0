From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v10 11/11] Documentation: prctl/seccomp_filter
Date: Tue, 21 Feb 2012 15:12:30 -0800
Message-ID: <20120221231230.GK3990@outflux.net>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-11-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, hpa@zytor.com, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-897-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1329845435-2313-11-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Hi,

I've collected the initial no-new-privs patches, and this whole series
and pushed it here so I could more easily review it:
http://git.kernel.org/?p=linux/kernel/git/kees/linux.git;a=shortlog;h=refs/heads/seccomp

Some minor tweaks below...

On Tue, Feb 21, 2012 at 11:30:35AM -0600, Will Drewry wrote:
> Documents how system call filtering using Berkeley Packet
> Filter programs works and how it may be used.
> Includes an example for x86 (32-bit) and a semi-generic
> example using a macro-based code generator.
> 
> v10: - update for SIGSYS
>      - update for new seccomp_data layout
>      - update for ptrace option use
> v9: - updated bpf-direct.c for SIGILL
> v8: - add PR_SET_NO_NEW_PRIVS to the samples.
> v7: - updated for all the new stuff in v7: TRAP, TRACE
>     - only talk about PR_SET_SECCOMP now
>     - fixed bad JLE32 check (coreyb@linux.vnet.ibm.com)
>     - adds dropper.c: a simple system call disabler
> v6: - tweak the language to note the requirement of
>       PR_SET_NO_NEW_PRIVS being called prior to use. (luto@mit.edu)
> v5: - update sample to use system call arguments
>     - adds a "fancy" example using a macro-based generator
>     - cleaned up bpf in the sample
>     - update docs to mention arguments
>     - fix prctl value (eparis@redhat.com)
>     - language cleanup (rdunlap@xenotime.net)
> v4: - update for no_new_privs use
>     - minor tweaks
> v3: - call out BPF <-> Berkeley Packet Filter (rdunlap@xenotime.net)
>     - document use of tentative always-unprivileged
>     - guard sample compilation for i386 and x86_64
> v2: - move code to samples (corbet@lwn.net)
> 
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
>  Documentation/prctl/seccomp_filter.txt |  157 +++++++++++++++++++++
>  samples/Makefile                       |    2 +-
>  samples/seccomp/Makefile               |   31 ++++
>  samples/seccomp/bpf-direct.c           |  150 ++++++++++++++++++++
>  samples/seccomp/bpf-fancy.c            |  102 ++++++++++++++
>  samples/seccomp/bpf-helper.c           |   89 ++++++++++++
>  samples/seccomp/bpf-helper.h           |  236 ++++++++++++++++++++++++++++++++
>  samples/seccomp/dropper.c              |   68 +++++++++
>  8 files changed, 834 insertions(+), 1 deletions(-)
>  create mode 100644 Documentation/prctl/seccomp_filter.txt
>  create mode 100644 samples/seccomp/Makefile
>  create mode 100644 samples/seccomp/bpf-direct.c
>  create mode 100644 samples/seccomp/bpf-fancy.c
>  create mode 100644 samples/seccomp/bpf-helper.c
>  create mode 100644 samples/seccomp/bpf-helper.h
>  create mode 100644 samples/seccomp/dropper.c
> 
> diff --git a/Documentation/prctl/seccomp_filter.txt b/Documentation/prctl/seccomp_filter.txt
> new file mode 100644
> index 0000000..7de865b
> --- /dev/null
> +++ b/Documentation/prctl/seccomp_filter.txt
> @@ -0,0 +1,157 @@
> +		SECure COMPuting with filters
> +		=============================
> +
> +Introduction
> +------------
> +
> +A large number of system calls are exposed to every userland process
> +with many of them going unused for the entire lifetime of the process.
> +As system calls change and mature, bugs are found and eradicated.  A
> +certain subset of userland applications benefit by having a reduced set
> +of available system calls.  The resulting set reduces the total kernel
> +surface exposed to the application.  System call filtering is meant for
> +use with those applications.
> +
> +Seccomp filtering provides a means for a process to specify a filter for
> +incoming system calls.  The filter is expressed as a Berkeley Packet
> +Filter (BPF) program, as with socket filters, except that the data
> +operated on is related to the system call being made: system call
> +number and the system call arguments.  This allows for expressive
> +filtering of system calls using a filter program language with a long
> +history of being exposed to userland and a straightforward data set.
> +
> +Additionally, BPF makes it impossible for users of seccomp to fall prey
> +to time-of-check-time-of-use (TOCTOU) attacks that are common in system
> +call interposition frameworks.  BPF programs may not dereference
> +pointers which constrains all filters to solely evaluating the system
> +call arguments directly.
> +
> +What it isn't
> +-------------
> +
> +System call filtering isn't a sandbox.  It provides a clearly defined
> +mechanism for minimizing the exposed kernel surface.  It is meant to be
> +a tool for sandbox developers to use.  Beyond that, policy for logical
> +behavior and information flow should be managed with a combination of
> +other system hardening techniques and, potentially, an LSM of your
> +choosing.  Expressive, dynamic filters provide further options down this
> +path (avoiding pathological sizes or selecting which of the multiplexed
> +system calls in socketcall() is allowed, for instance) which could be
> +construed, incorrectly, as a more complete sandboxing solution.
> +
> +Usage
> +-----
> +
> +An additional seccomp mode is added and is enabled using the same
> +prctl(2) call as the strict seccomp.  If the architecture has
> +CONFIG_HAVE_ARCH_SECCOMP_FILTER, then filters may be added as below:
> +
> +PR_SET_SECCOMP:
> +	Now takes an additional argument which specifies a new filter
> +	using a BPF program.
> +	The BPF program will be executed over struct seccomp_data
> +	reflecting the system call number, arguments, and other
> +	metadata.  The BPF program must then return one of the
> +	acceptable values to inform the kernel which action should be
> +	taken.
> +
> +	Usage:
> +		prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, prog);
> +
> +	The 'prog' argument is a pointer to a struct sock_fprog which
> +	will contain the filter program.  If the program is invalid, the
> +	call will return -1 and set errno to EINVAL.
> +
> +	Note, is_compat_task is also tracked for the @prog.  This means
> +	that once set the calling task will have all of its system calls
> +	blocked if it switches its system call ABI.
> +
> +	If fork/clone and execve are allowed by @prog, any child
> +	processes will be constrained to the same filters and system
> +	call ABI as the parent.
> +
> +	Prior to use, the task must call prctl(PR_SET_NO_NEW_PRIVS, 1) or
> +	run with CAP_SYS_ADMIN privileges in its namespace.  If these are not
> +	true, -EACCES will be returned.  This requirement ensures that filter
> +	programs cannot be applied to child processes with greater privileges
> +	than the task that installed them.
> +
> +	Additionally, if prctl(2) is allowed by the attached filter,
> +	additional filters may be layered on which will increase evaluation
> +	time, but allow for further decreasing the attack surface during
> +	execution of a process.
> +
> +The above call returns 0 on success and non-zero on error.
> +
> +Return values
> +-------------
> +
> +A seccomp filter may return any of the following values:
> +	SECCOMP_RET_ALLOW, SECCOMP_RET_KILL, SECCOMP_RET_TRAP,
> +	SECCOMP_RET_ERRNO, or SECCOMP_RET_TRACE.
> +
> +SECCOMP_RET_ALLOW:
> +	If all filters for a given task return this value then
> +	the system call will proceed normally.
> +
> +SECCOMP_RET_KILL:
> +	If any filters for a given take return this value then
> +	the task will exit immediately without executing the system
> +	call.
> +
> +SECCOMP_RET_TRAP:
> +	If any filters specify SECCOMP_RET_TRAP and none of them
> +	specify SECCOMP_RET_KILL, then the kernel will send a SIGTRAP
> +	signal to the task and not execute the system call.  The kernel
> +	will rollback the register state to just before system call
> +	entry such that a signal handler in the process will be able
> +	to inspect the ucontext_t->uc_mcontext registers and emulate
> +	system call success or failure upon return from the signal
> +	handler.
> +
> +	The SIGTRAP is differentiated by other SIGTRAPS by a si_code
> +	of TRAP_SECCOMP.

This should reflect the SIGTRAP->SIGSYS change (and SYS_SECCOMP si_code
change).

> +
> +SECCOMP_RET_ERRNO:
> +	If returned, the value provided in the lower 16-bits is
> +	returned to userland as the errno and the system call is
> +	not executed.

The other sections each say "If any" or "If all" to clarify their
behavior with multiple filters. The same should be done here, but more
comments below. Additionally, it should clarify that on multiple
uses of RET_ERRNO, the lower of the errnos will be returned.

> +
> +SECCOMP_RET_TRACE:
> +	If any filters return this value and the others return
> +	SECCOMP_RET_ALLOW, then the kernel will attempt to notify
> +	a ptrace()-based tracer prior to executing the system call.
> +
> +	A tracer will be notified if it requests PTRACE_O_TRACESECCOMP
> +	via PTRACE_SETOPTIONS.  Otherwise, the system call will
> +	not execute and -ENOSYS will be returned to userspace.
> +
> +	If the tracer ignores notification, then the system call will
> +	proceed normally.  Changes to the registers will function
> +	similarly to PTRACE_SYSCALL.  Additionally, if the tracer
> +	detaches during notification or just after, the task may be
> +	terminated as precautionary measure.
> +
> +Please note that the order of precedence is as follows:
> +SECCOMP_RET_KILL, SECCOMP_RET_ERRNO, SECCOMP_RET_TRAP,
> +SECCOMP_RET_TRACE, SECCOMP_RET_ALLOW.
> +
> +If multiple filters exist, the return value for the evaluation of a given
> +system call will always use the highest precedent value.
> +SECCOMP_RET_KILL will always take precedence.

I think this clarification about precedence is good but should be at the
head of the "Return values" section, and the sections ordered from that
perspective, so that the "highest precedent value" aspect is a little
bit easier to follow:


Return values
-------------
A seccomp filter may return any of the following values. If multiple
filters exist, the return value for the evaluation of a given system
call will always use the highest precedent value. (For example,
SECCOMP_RET_KILL will always take precedence.)

In precedence order, they are:

SECCOMP_RET_KILL:
        If any filters for a given take return this value then
        the task will exit immediately without executing the system
        call.

SECCOMP_RET_TRAP:
        If any filters specify SECCOMP_RET_TRAP and none of them
        specify SECCOMP_RET_KILL, then the kernel will send a SIGSYS
        signal to the task and not execute the system call. The kernel
        will rollback the register state to just before system call
        entry such that a signal handler in the process will be able
        to inspect the ucontext_t->uc_mcontext registers and emulate
        system call success or failure upon return from the signal
        handler.

        The SIGSYS is differentiated by other SIGSYS signals by a si_code
        of SYS_SECCOMP.

SECCOMP_RET_ERRNO:
	If any filters return this value and none of them specify a
	higher precedence value, then the lowest of the values provided
	in the lower 16-bits is returned to userland as the errno and
	the system call is not executed.

SECCOMP_RET_TRACE:
	If any filters return this value and none of them specify a
	higher precedence value, then the kernel will attempt to notify
        a ptrace()-based tracer prior to executing the system call.

        A tracer will be notified if it requests PTRACE_O_TRACESECCOMP
        via PTRACE_SETOPTIONS. Otherwise, the system call will
        not execute and -ENOSYS will be returned to userspace.
        If the tracer ignores notification, then the system call will
        proceed normally. Changes to the registers will function
        similarly to PTRACE_SYSCALL. Additionally, if the tracer
        detaches during notification or just after, the task may be
        terminated as precautionary measure.

SECCOMP_RET_ALLOW:
        If all filters for a given task return this value then
        the system call will proceed normally.




-Kees

-- 
Kees Cook
ChromeOS Security
