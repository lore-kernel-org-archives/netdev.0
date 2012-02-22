From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it
 synchronous.
Date: Wed, 22 Feb 2012 09:34:42 +0100
Message-ID: <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
    <1329845435-2313-7-git-send-email-wad@chromium.org>
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1329845435-2313-7-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, February 21, 2012 18:30, Will Drewry wrote:
> This change enables SIGSYS, defines _sigfields._sigsys, and adds
> x86 (compat) arch support.  _sigsys defines fields which allow
> a signal handler to receive the triggering system call number,
> the relevant AUDIT_ARCH_* value for that number, and the address
> of the callsite.
>
> To ensure that SIGSYS delivery occurs on return from the triggering
> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro.  I'm
> this is enough to ensure it will be synchronous or if it is explicitly
> required to ensure an immediate delivery of the signal upon return from
> the blocked system call.
>
> The first consumer of SIGSYS would be seccomp filter.  In particular,
> a filter program could specify a new return value, SECCOMP_RET_TRAP,
> which would result in the system call being denied and the calling
> thread signaled.  This also means that implementing arch-specific
> support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.

I think others said this is useful, but I don't see how. Easier
debugging compared to checking return values?

I suppose SIGSYS can be blocked, so there is no guarantee the process
will be killed.

> v10: - first version based on suggestion
>
> Suggested-by: H. Peter Anvin <hpa@zytor.com>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
>  arch/x86/ia32/ia32_signal.c   |    4 ++++
>  arch/x86/include/asm/ia32.h   |    6 ++++++
>  include/asm-generic/siginfo.h |   18 ++++++++++++++++++
>  kernel/signal.c               |    2 +-
>  4 files changed, 29 insertions(+), 1 deletions(-)
>
> diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
> index 6557769..c81d2c7 100644
> --- a/arch/x86/ia32/ia32_signal.c
> +++ b/arch/x86/ia32/ia32_signal.c
> @@ -73,6 +73,10 @@ int copy_siginfo_to_user32(compat_siginfo_t __user *to, siginfo_t
> *from)
>  			switch (from->si_code >> 16) {
>  			case __SI_FAULT >> 16:
>  				break;
> +			case __SI_SYS >> 16:
> +				put_user_ex(from->si_syscall, &to->si_syscall);
> +				put_user_ex(from->si_arch, &to->si_arch);
> +				break;
>  			case __SI_CHLD >> 16:
>  				put_user_ex(from->si_utime, &to->si_utime);
>  				put_user_ex(from->si_stime, &to->si_stime);
> diff --git a/arch/x86/include/asm/ia32.h b/arch/x86/include/asm/ia32.h
> index 1f7e625..541485f 100644
> --- a/arch/x86/include/asm/ia32.h
> +++ b/arch/x86/include/asm/ia32.h
> @@ -126,6 +126,12 @@ typedef struct compat_siginfo {
>  			int _band;	/* POLL_IN, POLL_OUT, POLL_MSG */
>  			int _fd;
>  		} _sigpoll;
> +
> +		struct {
> +			unsigned int _call_addr; /* calling insn */

Why an int here, but a pointer below?

> +			int _syscall;	/* triggering system call number */
> +			unsigned int _arch;	/* AUDIT_ARCH_* of syscall */
> +		} _sigsys;
>  	} _sifields;
>  } compat_siginfo_t;
>
> diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
> index 0dd4e87..a83b478 100644
> --- a/include/asm-generic/siginfo.h
> +++ b/include/asm-generic/siginfo.h
> @@ -90,6 +90,13 @@ typedef struct siginfo {
>  			__ARCH_SI_BAND_T _band;	/* POLL_IN, POLL_OUT, POLL_MSG */
>  			int _fd;
>  		} _sigpoll;
> +
> +		/* SIGSYS */
> +		struct {
> +			void __user *_call_addr; /* calling insn */

Is this a user instruction pointer or a filter instruction?

> +			int _syscall;	/* triggering system call number */
> +			unsigned int _arch;	/* AUDIT_ARCH_* of syscall */
> +		} _sigsys;
>  	} _sifields;
>  } siginfo_t;
>
> @@ -116,6 +123,9 @@ typedef struct siginfo {
>  #define si_addr_lsb	_sifields._sigfault._addr_lsb
>  #define si_band		_sifields._sigpoll._band
>  #define si_fd		_sifields._sigpoll._fd
> +#define si_call_addr	_sifields._sigsys._call_addr
> +#define si_syscall	_sifields._sigsys._syscall
> +#define si_arch		_sifields._sigsys._arch
>
>  #ifdef __KERNEL__
>  #define __SI_MASK	0xffff0000u
> @@ -126,6 +136,7 @@ typedef struct siginfo {
>  #define __SI_CHLD	(4 << 16)
>  #define __SI_RT		(5 << 16)
>  #define __SI_MESGQ	(6 << 16)
> +#define __SI_SYS	(7 << 16)
>  #define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
>  #else
>  #define __SI_KILL	0
> @@ -135,6 +146,7 @@ typedef struct siginfo {
>  #define __SI_CHLD	0
>  #define __SI_RT		0
>  #define __SI_MESGQ	0
> +#define __SI_SYS	0
>  #define __SI_CODE(T,N)	(N)
>  #endif
>
> @@ -232,6 +244,12 @@ typedef struct siginfo {
>  #define NSIGPOLL	6
>
>  /*
> + * SIGSYS si_codes
> + */
> +#define SYS_SECCOMP		(__SI_SYS|1)	/* seccomp triggered */
> +#define NSIGSYS	1
> +
> +/*
>   * sigevent definitions
>   *
>   * It seems likely that SIGEV_THREAD will have to be handled from
> diff --git a/kernel/signal.c b/kernel/signal.c
> index c73c428..7573819 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -160,7 +160,7 @@ void recalc_sigpending(void)
>
>  #define SYNCHRONOUS_MASK \
>  	(sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | \
> -	 sigmask(SIGTRAP) | sigmask(SIGFPE))
> +	 sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))
>
>  int next_signal(struct sigpending *pending, sigset_t *mask)
>  {
> --

Greetings,

Indan


