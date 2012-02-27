From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 10:23:46 -0600
Message-ID: <CABqD9hbKU=EVagCfo25AZsNoq=hmzkeOxK6mE=q8m=Be-ZFb9w@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<20120226202828.GE3990@outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: Kees Cook <kees@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33870 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751Ab2B0QXs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 11:23:48 -0500
Received: by eaah12 with SMTP id h12so2265787eaa.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 08:23:47 -0800 (PST)
In-Reply-To: <20120226202828.GE3990@outflux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 26, 2012 at 2:28 PM, Kees Cook <kees@ubuntu.com> wrote:
> On Fri, Feb 24, 2012 at 09:21:45PM -0600, Will Drewry wrote:
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index e8d76c5..25e8296 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> [...]
>> +static void seccomp_filter_log_failure(int syscall)
>> +{
>> + =A0 =A0 int compat =3D 0;
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 compat =3D is_compat_task();
>> +#endif
>> + =A0 =A0 pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 current->comm, task_pid_nr(current),
>> + =A0 =A0 =A0 =A0 =A0 =A0 (compat ? "compat " : ""),
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall, KSTK_EIP(current));
>> +}
>> [...]
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case SECCOMP_MODE_FILTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (seccomp_run_filters(this_syscall) =3D=3D=
 SECCOMP_RET_ALLOW)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 exit_code =3D SIGSYS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> =A0 =A0 =A0 default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> =A0 =A0 =A0 }
>> @@ -56,7 +324,7 @@ void __secure_computing(int this_syscall)
>> =A0 =A0 =A0 dump_stack();
>> =A0#endif
>> =A0 =A0 =A0 audit_seccomp(this_syscall);
>> - =A0 =A0 do_exit(SIGKILL);
>> + =A0 =A0 do_exit(exit_code);
>> =A0}
>
> I think the seccomp_filter_log_failure() use is redundant with the
> audit_seccomp call. =A0Here's a possible reorganization of the loggin=
g...

Cool - a comment below:

> From: Kees Cook <keescook@chromium.org>
> Date: Sun, 26 Feb 2012 11:56:12 -0800
> Subject: [PATCH] seccomp: improve audit logging details
>
> This consolidates the seccomp filter error logging path and adds more
> details to the audit log.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> =A0include/linux/audit.h | =A0 =A08 ++++----
> =A0kernel/auditsc.c =A0 =A0 =A0| =A0 =A09 +++++++--
> =A0kernel/seccomp.c =A0 =A0 =A0| =A0 15 +--------------
> =A03 files changed, 12 insertions(+), 20 deletions(-)
>
> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 9ff7a2c..5aa6cfc 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -463,7 +463,7 @@ extern void audit_putname(const char *name);
> =A0extern void __audit_inode(const char *name, const struct dentry *d=
entry);
> =A0extern void __audit_inode_child(const struct dentry *dentry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const =
struct inode *parent);
> -extern void __audit_seccomp(unsigned long syscall);
> +extern void __audit_seccomp(unsigned long syscall, long signr);
> =A0extern void __audit_ptrace(struct task_struct *t);
>
> =A0static inline int audit_dummy_context(void)
> @@ -508,10 +508,10 @@ static inline void audit_inode_child(const stru=
ct dentry *dentry,
> =A0}
> =A0void audit_core_dumps(long signr);
>
> -static inline void audit_seccomp(unsigned long syscall)
> +static inline void audit_seccomp(unsigned long syscall, long signr)
> =A0{
> =A0 =A0 =A0 =A0if (unlikely(!audit_dummy_context()))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __audit_seccomp(syscall);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __audit_seccomp(syscall, signr);
> =A0}
>
> =A0static inline void audit_ptrace(struct task_struct *t)
> @@ -634,7 +634,7 @@ extern int audit_signals;
> =A0#define audit_inode(n,d) do { (void)(d); } while (0)
> =A0#define audit_inode_child(i,p) do { ; } while (0)
> =A0#define audit_core_dumps(i) do { ; } while (0)
> -#define audit_seccomp(i) do { ; } while (0)
> +#define audit_seccomp(i,s) do { ; } while (0)
> =A0#define auditsc_get_stamp(c,t,s) (0)
> =A0#define audit_get_loginuid(t) (-1)
> =A0#define audit_get_sessionid(t) (-1)
> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index af1de0f..74652fe 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -67,6 +67,7 @@
> =A0#include <linux/syscalls.h>
> =A0#include <linux/capability.h>
> =A0#include <linux/fs_struct.h>
> +#include <linux/compat.h>
>
> =A0#include "audit.h"
>
> @@ -2710,13 +2711,17 @@ void audit_core_dumps(long signr)
> =A0 =A0 =A0 =A0audit_log_end(ab);
> =A0}
>
> -void __audit_seccomp(unsigned long syscall)
> +void __audit_seccomp(unsigned long syscall, long signr)
> =A0{
> =A0 =A0 =A0 =A0struct audit_buffer *ab;
>
> =A0 =A0 =A0 =A0ab =3D audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_AB=
END);
> - =A0 =A0 =A0 audit_log_abend(ab, "seccomp", SIGKILL);
> + =A0 =A0 =A0 audit_log_abend(ab, "seccomp", signr);
> =A0 =A0 =A0 =A0audit_log_format(ab, " syscall=3D%ld", syscall);
> +#ifdef CONFIG_COMPAT
> + =A0 =A0 =A0 audit_log_format(ab, " compat=3D%d", is_compat_task());
> +#endif

Should this just use syscall_get_arch to get the AUDIT_ARCH now? :)

> + =A0 =A0 =A0 audit_log_format(ab, " ip=3D0x%lx", KSTK_EIP(current));
> =A0 =A0 =A0 =A0audit_log_end(ab);
> =A0}
>
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 5aabc3c..40af83f 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -57,18 +57,6 @@ struct seccomp_filter {
> =A0 =A0 =A0 =A0struct sock_filter insns[];
> =A0};
>
> -static void seccomp_filter_log_failure(int syscall)
> -{
> - =A0 =A0 =A0 int compat =3D 0;
> -#ifdef CONFIG_COMPAT
> - =A0 =A0 =A0 compat =3D is_compat_task();
> -#endif
> - =A0 =A0 =A0 pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->comm, task_pid_nr(current),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (compat ? "compat " : ""),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall, KSTK_EIP(current));
> -}
> -
> =A0/**
> =A0* get_u32 - returns a u32 offset into data
> =A0* @data: a unsigned 64 bit value
> @@ -378,7 +366,6 @@ int __secure_computing_int(int this_syscall)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit_code =3D SIGSYS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> @@ -390,7 +377,7 @@ int __secure_computing_int(int this_syscall)
> =A0#ifdef SECCOMP_DEBUG
> =A0 =A0 =A0 =A0dump_stack();
> =A0#endif
> - =A0 =A0 =A0 audit_seccomp(this_syscall);
> + =A0 =A0 =A0 audit_seccomp(this_syscall, exit_code);
> =A0 =A0 =A0 =A0do_exit(exit_code);
> =A0 =A0 =A0 =A0return -1; =A0 =A0 =A0/* never reached */
> =A0}
> --
> 1.7.0.4

I'll pull this into the series if that's okay with you?

Thanks!
