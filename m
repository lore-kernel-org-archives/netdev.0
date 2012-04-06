From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 10/15] seccomp: add SECCOMP_RET_ERRNO
Date: Fri, 6 Apr 2012 14:19:36 -0700
Message-ID: <20120406141936.25d68860.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-11-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1333051320-30872-11-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:55 -0500
Will Drewry <wad@chromium.org> wrote:

> This change adds the SECCOMP_RET_ERRNO as a valid return value from a
> seccomp filter.  Additionally, it makes the first use of the lower
> 16-bits for storing a filter-supplied errno.  16-bits is more than
> enough for the errno-base.h calls.
> 
> Returning errors instead of immediately terminating processes that
> violate seccomp policy allow for broader use of this functionality
> for kernel attack surface reduction.  For example, a linux container
> could maintain a whitelist of pre-existing system calls but drop
> all new ones with errnos.  This would keep a logically static attack
> surface while providing errnos that may allow for graceful failure
> without the downside of do_exit() on a bad call.
> 
>
> ...
>
> @@ -64,11 +65,17 @@ struct seccomp {
>  	struct seccomp_filter *filter;
>  };
>  
> -extern void __secure_computing(int);
> -static inline void secure_computing(int this_syscall)
> +/*
> + * Direct callers to __secure_computing should be updated as
> + * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.

Are there any such callers?  There's one I see in arm, but it's called
from assembly code.

> + */
> +extern void __secure_computing(int) __deprecated;
> +extern int __secure_computing_int(int);
> +static inline int secure_computing(int this_syscall)
>  {
>  	if (unlikely(test_thread_flag(TIF_SECCOMP)))
> -		__secure_computing(this_syscall);
> +		return  __secure_computing_int(this_syscall);
> +	return 0;
>  }
>  
> ...
>
>  void __secure_computing(int this_syscall)
>  {
> +	/* Filter calls should never use this function. */
> +	BUG_ON(current->seccomp.mode == SECCOMP_MODE_FILTER);
> +	__secure_computing_int(this_syscall);
> +}
> +
> +int __secure_computing_int(int this_syscall)

What the heck does "_int" mean here?  I read it as "integer" but
perhaps it's shorthand for "internal".  Give us a better name, please. 
Or a code comment.

> +{
>  	int mode = current->seccomp.mode;
>  	int exit_sig = 0;
>  	int *syscall;
> +	u32 ret = SECCOMP_RET_KILL;
> +	int data;
>  
>  	switch (mode) {
>  	case SECCOMP_MODE_STRICT:

