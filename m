From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 11:49:56 -0500
Message-ID: <1330361396.2542.11.camel@localhost>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	 <1330140111-17201-6-git-send-email-wad@chromium.org>
	 <20120226202828.GE3990@outflux.net>
	 <CABqD9hbKU=EVagCfo25AZsNoq=hmzkeOxK6mE=q8m=Be-ZFb9w@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <kees@ubuntu.com>, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
        mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
        rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
        luto@mit.edu, serge.hallyn@canonical.com, djm@mindrot.org,
        scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
        akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
        markus@chromium.org, coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-969-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CABqD9hbKU=EVagCfo25AZsNoq=hmzkeOxK6mE=q8m=Be-ZFb9w@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-27 at 10:23 -0600, Will Drewry wrote:
> On Sun, Feb 26, 2012 at 2:28 PM, Kees Cook <kees@ubuntu.com> wrote:
> > On Fri, Feb 24, 2012 at 09:21:45PM -0600, Will Drewry wrote:
> >> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> >> index e8d76c5..25e8296 100644
> >> --- a/kernel/seccomp.c
> >> +++ b/kernel/seccomp.c
> >> [...]
> >> +static void seccomp_filter_log_failure(int syscall)
> >> +{
> >> +     int compat = 0;
> >> +#ifdef CONFIG_COMPAT
> >> +     compat = is_compat_task();
> >> +#endif
> >> +     pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> >> +             current->comm, task_pid_nr(current),
> >> +             (compat ? "compat " : ""),
> >> +             syscall, KSTK_EIP(current));
> >> +}
> >> [...]
> >> +#ifdef CONFIG_SECCOMP_FILTER
> >> +     case SECCOMP_MODE_FILTER:
> >> +             if (seccomp_run_filters(this_syscall) == SECCOMP_RET_ALLOW)
> >> +                     return;
> >> +             seccomp_filter_log_failure(this_syscall);
> >> +             exit_code = SIGSYS;
> >> +             break;
> >> +#endif
> >>       default:
> >>               BUG();
> >>       }
> >> @@ -56,7 +324,7 @@ void __secure_computing(int this_syscall)
> >>       dump_stack();
> >>  #endif
> >>       audit_seccomp(this_syscall);
> >> -     do_exit(SIGKILL);
> >> +     do_exit(exit_code);
> >>  }
> >
> > I think the seccomp_filter_log_failure() use is redundant with the
> > audit_seccomp call.  Here's a possible reorganization of the logging...
> 
> Cool - a comment below:
> 
> > From: Kees Cook <keescook@chromium.org>
> > Date: Sun, 26 Feb 2012 11:56:12 -0800
> > Subject: [PATCH] seccomp: improve audit logging details
> >
> > This consolidates the seccomp filter error logging path and adds more
> > details to the audit log.
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  include/linux/audit.h |    8 ++++----
> >  kernel/auditsc.c      |    9 +++++++--
> >  kernel/seccomp.c      |   15 +--------------
> >  3 files changed, 12 insertions(+), 20 deletions(-)
> >
> > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > index 9ff7a2c..5aa6cfc 100644
> > --- a/include/linux/audit.h
> > +++ b/include/linux/audit.h
> > @@ -463,7 +463,7 @@ extern void audit_putname(const char *name);
> >  extern void __audit_inode(const char *name, const struct dentry *dentry);
> >  extern void __audit_inode_child(const struct dentry *dentry,
> >                                const struct inode *parent);
> > -extern void __audit_seccomp(unsigned long syscall);
> > +extern void __audit_seccomp(unsigned long syscall, long signr);
> >  extern void __audit_ptrace(struct task_struct *t);
> >
> >  static inline int audit_dummy_context(void)
> > @@ -508,10 +508,10 @@ static inline void audit_inode_child(const struct dentry *dentry,
> >  }
> >  void audit_core_dumps(long signr);
> >
> > -static inline void audit_seccomp(unsigned long syscall)
> > +static inline void audit_seccomp(unsigned long syscall, long signr)
> >  {
> >        if (unlikely(!audit_dummy_context()))
> > -               __audit_seccomp(syscall);
> > +               __audit_seccomp(syscall, signr);
> >  }
> >
> >  static inline void audit_ptrace(struct task_struct *t)
> > @@ -634,7 +634,7 @@ extern int audit_signals;
> >  #define audit_inode(n,d) do { (void)(d); } while (0)
> >  #define audit_inode_child(i,p) do { ; } while (0)
> >  #define audit_core_dumps(i) do { ; } while (0)
> > -#define audit_seccomp(i) do { ; } while (0)
> > +#define audit_seccomp(i,s) do { ; } while (0)
> >  #define auditsc_get_stamp(c,t,s) (0)
> >  #define audit_get_loginuid(t) (-1)
> >  #define audit_get_sessionid(t) (-1)
> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> > index af1de0f..74652fe 100644
> > --- a/kernel/auditsc.c
> > +++ b/kernel/auditsc.c
> > @@ -67,6 +67,7 @@
> >  #include <linux/syscalls.h>
> >  #include <linux/capability.h>
> >  #include <linux/fs_struct.h>
> > +#include <linux/compat.h>
> >
> >  #include "audit.h"
> >
> > @@ -2710,13 +2711,17 @@ void audit_core_dumps(long signr)
> >        audit_log_end(ab);
> >  }
> >
> > -void __audit_seccomp(unsigned long syscall)
> > +void __audit_seccomp(unsigned long syscall, long signr)
> >  {
> >        struct audit_buffer *ab;
> >
> >        ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
> > -       audit_log_abend(ab, "seccomp", SIGKILL);
> > +       audit_log_abend(ab, "seccomp", signr);
> >        audit_log_format(ab, " syscall=%ld", syscall);
> > +#ifdef CONFIG_COMPAT
> > +       audit_log_format(ab, " compat=%d", is_compat_task());
> > +#endif
> 
> Should this just use syscall_get_arch to get the AUDIT_ARCH now? :)

I'm waffling on this one, but I'm leaning towards not including compat
at all.  If you include it, yes, you should use the generic function.

If you have CONFIG_AUDITSC and started audit you are going to get this,
along with a0-a4, in a separate but associated audit record.  Thus you
get all the interesting/relevant info.  Without CONFIG_AUDITSC and
running auditd you get compat, but nothing else.  Why is compat so
interesting?

This patch would duplicate the arch=field from that record (calling it
compat).  So if we are going to duplicate it in another record, we
should at least call it the same thing (arch=%x)

My current thinking, and I'm not settled would be to include syscall,
a0-a4 and arch in the record only if !CONFIG_AUDITSC.  (ip doesn't show
up elsewhere, so that makes sense here)

It might be annoying to have to find the info in the right record, but
if you use the auparse audit library tools, it should 'Just Work'...

> > +       audit_log_format(ab, " ip=0x%lx", KSTK_EIP(current));
> >        audit_log_end(ab);
> >  }
> >
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > index 5aabc3c..40af83f 100644
> > --- a/kernel/seccomp.c
> > +++ b/kernel/seccomp.c
> > @@ -57,18 +57,6 @@ struct seccomp_filter {
> >        struct sock_filter insns[];
> >  };
> >
> > -static void seccomp_filter_log_failure(int syscall)
> > -{
> > -       int compat = 0;
> > -#ifdef CONFIG_COMPAT
> > -       compat = is_compat_task();
> > -#endif
> > -       pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> > -               current->comm, task_pid_nr(current),
> > -               (compat ? "compat " : ""),
> > -               syscall, KSTK_EIP(current));
> > -}
> > -
> >  /**
> >  * get_u32 - returns a u32 offset into data
> >  * @data: a unsigned 64 bit value
> > @@ -378,7 +366,6 @@ int __secure_computing_int(int this_syscall)
> >                default:
> >                        break;
> >                }
> > -               seccomp_filter_log_failure(this_syscall);
> >                exit_code = SIGSYS;
> >                break;
> >        }
> > @@ -390,7 +377,7 @@ int __secure_computing_int(int this_syscall)
> >  #ifdef SECCOMP_DEBUG
> >        dump_stack();
> >  #endif
> > -       audit_seccomp(this_syscall);
> > +       audit_seccomp(this_syscall, exit_code);
> >        do_exit(exit_code);
> >        return -1;      /* never reached */
> >  }
> > --
> > 1.7.0.4
> 
> I'll pull this into the series if that's okay with you?
> 
> Thanks!
