From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 5/6] seccomp: add a way to attach a filter via eBPF fd
Date: Tue, 8 Sep 2015 07:40:44 -0600
Message-ID: <20150908134044.GV26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-6-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jKke44txdYqEgPRrkn8SyWGjJuHxT2qMdq2ztp_16mQyw@mail.gmail.com>
 <55EA95FE.7000006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55EA95FE.7000006-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 05, 2015 at 09:13:02AM +0200, Michael Kerrisk (man-pages) wrote:
> On 09/04/2015 10:41 PM, Kees Cook wrote:
> > On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> > <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> >> This is the final bit needed to support seccomp filters created via the bpf
> >> syscall.
> 
> Hmm. Thanks Kees, for CCinf linux-api@. That really should have been done at
> the outset.

Apologies, I'll cc the list on future versions.

> Tycho, where's the man-pages patch describing this new kernel-userspace
> API feature? :-)

Once we get the API finalized I'm happy to write it.

> >> One concern with this patch is exactly what the interface should look like
> >> for users, since seccomp()'s second argument is a pointer, we could ask
> >> people to pass a pointer to the fd, but implies we might write to it which
> >> seems impolite. Right now we cast the pointer (and force the user to cast
> >> it), which generates ugly warnings. I'm not sure what the right answer is
> >> here.
> >>
> >> Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >> CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> >> CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> >> CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> >> CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >> CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> >> CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> >> ---
> >>  include/linux/seccomp.h      |  3 +-
> >>  include/uapi/linux/seccomp.h |  1 +
> >>  kernel/seccomp.c             | 70 ++++++++++++++++++++++++++++++++++++--------
> >>  3 files changed, 61 insertions(+), 13 deletions(-)
> >>
> >> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> >> index d1a86ed..a725dd5 100644
> >> --- a/include/linux/seccomp.h
> >> +++ b/include/linux/seccomp.h
> >> @@ -3,7 +3,8 @@
> >>
> >>  #include <uapi/linux/seccomp.h>
> >>
> >> -#define SECCOMP_FILTER_FLAG_MASK       (SECCOMP_FILTER_FLAG_TSYNC)
> >> +#define SECCOMP_FILTER_FLAG_MASK       (\
> >> +       SECCOMP_FILTER_FLAG_TSYNC | SECCOMP_FILTER_FLAG_EBPF)
> >>
> >>  #ifdef CONFIG_SECCOMP
> >>
> >> diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
> >> index 0f238a4..c29a423 100644
> >> --- a/include/uapi/linux/seccomp.h
> >> +++ b/include/uapi/linux/seccomp.h
> >> @@ -16,6 +16,7 @@
> >>
> >>  /* Valid flags for SECCOMP_SET_MODE_FILTER */
> >>  #define SECCOMP_FILTER_FLAG_TSYNC      1
> >> +#define SECCOMP_FILTER_FLAG_EBPF       (1 << 1)
> >>
> >>  /*
> >>   * All BPF programs must return a 32-bit value.
> >> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> >> index a2c5b32..9c6bea6 100644
> >> --- a/kernel/seccomp.c
> >> +++ b/kernel/seccomp.c
> >> @@ -355,17 +355,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
> >>
> >>         BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
> >>
> >> -       /*
> >> -        * Installing a seccomp filter requires that the task has
> >> -        * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
> >> -        * This avoids scenarios where unprivileged tasks can affect the
> >> -        * behavior of privileged children.
> >> -        */
> >> -       if (!task_no_new_privs(current) &&
> >> -           security_capable_noaudit(current_cred(), current_user_ns(),
> >> -                                    CAP_SYS_ADMIN) != 0)
> >> -               return ERR_PTR(-EACCES);
> >> -
> >>         /* Allocate a new seccomp_filter */
> >>         sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
> >>         if (!sfilter)
> >> @@ -509,6 +498,48 @@ static void seccomp_send_sigsys(int syscall, int reason)
> >>         info.si_syscall = syscall;
> >>         force_sig_info(SIGSYS, &info, current);
> >>  }
> >> +
> >> +#ifdef CONFIG_BPF_SYSCALL
> >> +static struct seccomp_filter *seccomp_prepare_ebpf(const char __user *filter)
> >> +{
> >> +       /* XXX: this cast generates a warning. should we make people pass in
> >> +        * &fd, or is there some nicer way of doing this?
> >> +        */
> >> +       u32 fd = (u32) filter;
> > 
> > I think this is probably the right way to do it, modulo getting the
> > warning fixed. Let me invoke the great linux-api subscribers to get
> > some more opinions.
> 
> Sigh. It's sad, but the using a cast does seem the simplest option.
> But, how about another idea...
> 
> > tl;dr: adding SECCOMP_FILTER_FLAG_EBPF to the flags changes the
> > pointer argument into an fd argument. Is this sane, should it be a
> > pointer to an fd, or should it not be a flag at all, creating a new
> > seccomp command instead (SECCOMP_MODE_FILTER_EBPF)?
> 
> What about
> 
>     seccomp(SECCOMP_MODE_FILTER_EBPF, flags, structp)
> 
> Where structp is a pointer to something like
> 
> struct seccomp_ebpf {
>     int size;      /* Size of this whole struct */
>     int fd;
> }
> 
> 'size' allows for future expansion of the struct (in case we want to 
> expand it later), and placing 'fd' inside a struct avoids unpleasant
> implication that would be made by passing a pointer to an fd as the
> third argument.

I like this; although perhaps something like bpf() has, with the
unions inside the struct so that we don't have to declare another
struct if we add another seccomp command. Kees?

Tycho

> Cheers,
> 
> Michael
> 
> 
> > -Kees
> > 
> >> +       struct seccomp_filter *ret;
> >> +       struct bpf_prog *prog;
> >> +
> >> +       prog = bpf_prog_get(fd);
> >> +       if (IS_ERR(prog))
> >> +               return (struct seccomp_filter *) prog;
> >> +
> >> +       if (prog->type != BPF_PROG_TYPE_SECCOMP) {
> >> +               bpf_prog_put(prog);
> >> +               return ERR_PTR(-EINVAL);
> >> +       }
> >> +
> >> +       ret = kzalloc(sizeof(*ret), GFP_KERNEL | __GFP_NOWARN);
> >> +       if (!ret) {
> >> +               bpf_prog_put(prog);
> >> +               return ERR_PTR(-ENOMEM);
> >> +       }
> >> +
> >> +       ret->prog = prog;
> >> +       atomic_set(&ret->usage, 1);
> >> +
> >> +       /* Intentionally don't bpf_prog_put() here, because the underlying prog
> >> +        * is refcounted too and we're holding a reference from the struct
> >> +        * seccomp_filter object.
> >> +        */
> >> +
> >> +       return ret;
> >> +}
> >> +#else
> >> +static struct seccomp_filter *seccomp_prepare_ebpf(const char __user *filter)
> >> +{
> >> +       return ERR_PTR(-EINVAL);
> >> +}
> >> +#endif
> >>  #endif /* CONFIG_SECCOMP_FILTER */
> >>
> >>  /*
> >> @@ -775,8 +806,23 @@ static long seccomp_set_mode_filter(unsigned int flags,
> >>         if (flags & ~SECCOMP_FILTER_FLAG_MASK)
> >>                 return -EINVAL;
> >>
> >> +       /*
> >> +        * Installing a seccomp filter requires that the task has
> >> +        * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
> >> +        * This avoids scenarios where unprivileged tasks can affect the
> >> +        * behavior of privileged children.
> >> +        */
> >> +       if (!task_no_new_privs(current) &&
> >> +           security_capable_noaudit(current_cred(), current_user_ns(),
> >> +                                    CAP_SYS_ADMIN) != 0)
> >> +               return -EACCES;
> >> +
> >>         /* Prepare the new filter before holding any locks. */
> >> -       prepared = seccomp_prepare_user_filter(filter);
> >> +       if (flags & SECCOMP_FILTER_FLAG_EBPF)
> >> +               prepared = seccomp_prepare_ebpf(filter);
> >> +       else
> >> +               prepared = seccomp_prepare_user_filter(filter);
> >> +
> >>         if (IS_ERR(prepared))
> >>                 return PTR_ERR(prepared);
> >>
> >> --
> >> 2.1.4
> >>
> > 
> > 
> > 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
