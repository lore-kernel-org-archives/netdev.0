From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 09/15] seccomp: remove duplicated failure logging
Date: Fri, 6 Apr 2012 14:14:15 -0700
Message-ID: <20120406141415.93f46bc6.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-10-git-send-email-wad@chromium.org>
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
In-Reply-To: <1333051320-30872-10-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012 15:01:54 -0500
Will Drewry <wad@chromium.org> wrote:

> From: Kees Cook <keescook@chromium.org>
> 
> This consolidates the seccomp filter error logging path and adds more
> details to the audit log.
> 
> ...
>
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
>
> ...
>
>  #define audit_inode(n,d) do { (void)(d); } while (0)
>  #define audit_inode_child(i,p) do { ; } while (0)
>  #define audit_core_dumps(i) do { ; } while (0)
> -#define audit_seccomp(i) do { ; } while (0)
> +#define audit_seccomp(i,s,c) do { ; } while (0)

Sigh.  Someone please convert all these to C.  That way we get
typechecking and don't need dopey party tricks like that "(void)(d)" to
squish compilation warnings.

> ...
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -67,6 +67,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/capability.h>
>  #include <linux/fs_struct.h>
> +#include <linux/compat.h>
>  
>  #include "audit.h"
>  
> @@ -2710,13 +2711,18 @@ void audit_core_dumps(long signr)
>  	audit_log_end(ab);
>  }
>  
> -void __audit_seccomp(unsigned long syscall)
> +void __audit_seccomp(unsigned long syscall, long signr, int code)
>  {
>  	struct audit_buffer *ab;
>  
>  	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
> -	audit_log_abend(ab, "seccomp", SIGKILL);
> +	audit_log_abend(ab, "seccomp", signr);
>  	audit_log_format(ab, " syscall=%ld", syscall);
> +#ifdef CONFIG_COMPAT
> +	audit_log_format(ab, " compat=%d", is_compat_task());
> +#endif

We don't need the ifdef for compilation reasons now.

The question is: should we emit the compat= record on
non-compat-capable architectures?  Doing so would be safer - making it
conditional invites people to write x86-only usersapce.


