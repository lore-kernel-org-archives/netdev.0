From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2 4/5] seccomp: add a way to access filters via bpf fds
Date: Fri, 11 Sep 2015 08:31:04 -0600
Message-ID: <20150911143104.GG27574@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
 <CAKgNAki99ZFgLPE5mWWjj1nvdNyke1w0ttqmiG+Uk0rVfqutZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKgNAki99ZFgLPE5mWWjj1nvdNyke1w0ttqmiG+Uk0rVfqutZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Fri, Sep 11, 2015 at 02:08:50PM +0200, Michael Kerrisk (man-pages) wrote:
> HI Tycho
> 
> On 11 September 2015 at 02:21, Tycho Andersen
> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> > This patch adds a way for a process that is "real root" to access the
> > seccomp filters of another process. The process first does a
> > PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> > attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> > bpf(BPF_PROG_DUMP) to dump the actual program at each step.
> 
> Do you have a man- page patch for this change?

Not yet (r.e. all the man page reqs), I can draft them asap, though.
Hopefully the API is mostly stable at this point :).

Thanks,

Tycho

> Cheers,
> 
> Michael
> 
> > Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> > CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> > CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> > CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> > ---
> >  include/linux/bpf.h         | 12 ++++++++++
> >  include/linux/seccomp.h     | 14 +++++++++++
> >  include/uapi/linux/ptrace.h |  3 +++
> >  kernel/bpf/syscall.c        | 26 ++++++++++++++++++++-
> >  kernel/ptrace.c             |  7 ++++++
> >  kernel/seccomp.c            | 57 +++++++++++++++++++++++++++++++++++++++++++++
> >  6 files changed, 118 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> > index f57d7fe..bfd9cab 100644
> > --- a/include/linux/bpf.h
> > +++ b/include/linux/bpf.h
> > @@ -162,6 +162,8 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl);
> >  void bpf_register_map_type(struct bpf_map_type_list *tl);
> >
> >  struct bpf_prog *bpf_prog_get(u32 ufd);
> > +int bpf_prog_set(u32 ufd, struct bpf_prog *new);
> > +int bpf_new_fd(struct bpf_prog *prog, int flags);
> >  void bpf_prog_put(struct bpf_prog *prog);
> >  void bpf_prog_put_rcu(struct bpf_prog *prog);
> >
> > @@ -180,6 +182,16 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
> >         return ERR_PTR(-EOPNOTSUPP);
> >  }
> >
> > +static inline int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> > +{
> > +       return -EINVAL;
> > +}
> > +
> > +static inline int bpf_new_fd(struct bpf_prog *prog, int flags)
> > +{
> > +       return -EINVAL;
> > +}
> > +
> >  static inline void bpf_prog_put(struct bpf_prog *prog)
> >  {
> >  }
> > diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> > index a19ddac..41b083c 100644
> > --- a/include/linux/seccomp.h
> > +++ b/include/linux/seccomp.h
> > @@ -95,4 +95,18 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
> >         return;
> >  }
> >  #endif /* CONFIG_SECCOMP_FILTER */
> > +
> > +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
> > +extern long seccomp_get_filter_fd(struct task_struct *child);
> > +extern long seccomp_next_filter(struct task_struct *child, u32 fd);
> > +#else
> > +static inline long seccomp_get_filter_fd(struct task_struct *child)
> > +{
> > +       return -EINVAL;
> > +}
> > +static inline long seccomp_next_filter(struct task_struct *child, u32 fd)
> > +{
> > +       return -EINVAL;
> > +}
> > +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
> >  #endif /* _LINUX_SECCOMP_H */
> > diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
> > index cf1019e..041c3c3 100644
> > --- a/include/uapi/linux/ptrace.h
> > +++ b/include/uapi/linux/ptrace.h
> > @@ -23,6 +23,9 @@
> >
> >  #define PTRACE_SYSCALL           24
> >
> > +#define PTRACE_SECCOMP_GET_FILTER_FD   40
> > +#define PTRACE_SECCOMP_NEXT_FILTER     41
> > +
> >  /* 0x4200-0x4300 are reserved for architecture-independent additions.  */
> >  #define PTRACE_SETOPTIONS      0x4200
> >  #define PTRACE_GETEVENTMSG     0x4201
> > diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> > index 58ae9f4..ac3ed1c 100644
> > --- a/kernel/bpf/syscall.c
> > +++ b/kernel/bpf/syscall.c
> > @@ -506,6 +506,30 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
> >  }
> >  EXPORT_SYMBOL_GPL(bpf_prog_get);
> >
> > +int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> > +{
> > +       struct fd f;
> > +       struct bpf_prog *prog;
> > +
> > +       f = fdget(ufd);
> > +
> > +       prog = get_prog(f);
> > +       if (!IS_ERR(prog) && prog)
> > +               bpf_prog_put(prog);
> > +
> > +       atomic_inc(&new->aux->refcnt);
> > +       f.file->private_data = new;
> > +       fdput(f);
> > +       return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(bpf_prog_set);
> > +
> > +int bpf_new_fd(struct bpf_prog *prog, int flags)
> > +{
> > +       return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, flags);
> > +}
> > +EXPORT_SYMBOL_GPL(bpf_new_fd);
> > +
> >  /* last field in 'union bpf_attr' used by this command */
> >  #define        BPF_PROG_LOAD_LAST_FIELD kern_version
> >
> > @@ -572,7 +596,7 @@ static int bpf_prog_load(union bpf_attr *attr)
> >         if (err < 0)
> >                 goto free_used_maps;
> >
> > -       err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
> > +       err = bpf_new_fd(prog, O_RDWR | O_CLOEXEC);
> >         if (err < 0)
> >                 /* failed to allocate fd */
> >                 goto free_used_maps;
> > diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> > index c8e0e05..a151c35 100644
> > --- a/kernel/ptrace.c
> > +++ b/kernel/ptrace.c
> > @@ -1003,6 +1003,13 @@ int ptrace_request(struct task_struct *child, long request,
> >                 break;
> >         }
> >  #endif
> > +
> > +       case PTRACE_SECCOMP_GET_FILTER_FD:
> > +               return seccomp_get_filter_fd(child);
> > +
> > +       case PTRACE_SECCOMP_NEXT_FILTER:
> > +               return seccomp_next_filter(child, data);
> > +
> >         default:
> >                 break;
> >         }
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > index afaeddf..1856f69 100644
> > --- a/kernel/seccomp.c
> > +++ b/kernel/seccomp.c
> > @@ -26,6 +26,8 @@
> >  #endif
> >
> >  #ifdef CONFIG_SECCOMP_FILTER
> > +#include <linux/bpf.h>
> > +#include <uapi/linux/bpf.h>
> >  #include <linux/filter.h>
> >  #include <linux/pid.h>
> >  #include <linux/ptrace.h>
> > @@ -807,6 +809,61 @@ static inline long seccomp_set_mode_filter(unsigned int flags,
> >  }
> >  #endif
> >
> > +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
> > +long seccomp_get_filter_fd(struct task_struct *child)
> > +{
> > +       long fd;
> > +       struct seccomp_filter *filter;
> > +
> > +       if (!capable(CAP_SYS_ADMIN))
> > +               return -EACCES;
> > +
> > +       if (child->seccomp.mode != SECCOMP_MODE_FILTER)
> > +               return -EINVAL;
> > +
> > +       filter = child->seccomp.filter;
> > +
> > +       fd = bpf_new_fd(filter->prog, O_RDONLY);
> > +       if (fd > 0)
> > +               atomic_inc(&filter->prog->aux->refcnt);
> > +
> > +       return fd;
> > +}
> > +
> > +long seccomp_next_filter(struct task_struct *child, u32 fd)
> > +{
> > +       struct seccomp_filter *cur;
> > +       struct bpf_prog *prog;
> > +       long ret = -ESRCH;
> > +
> > +       if (!capable(CAP_SYS_ADMIN))
> > +               return -EACCES;
> > +
> > +       if (child->seccomp.mode != SECCOMP_MODE_FILTER)
> > +               return -EINVAL;
> > +
> > +       prog = bpf_prog_get(fd);
> > +       if (IS_ERR(prog)) {
> > +               ret = PTR_ERR(prog);
> > +               goto out;
> > +       }
> > +
> > +       for (cur = child->seccomp.filter; cur; cur = cur->prev) {
> > +               if (cur->prog == prog) {
> > +                       if (!cur->prev)
> > +                               ret = -ENOENT;
> > +                       else
> > +                               ret = bpf_prog_set(fd, cur->prev->prog);
> > +                       break;
> > +               }
> > +       }
> > +
> > +out:
> > +       bpf_prog_put(prog);
> > +       return ret;
> > +}
> > +#endif
> > +
> >  /* Common entry point for both prctl and syscall. */
> >  static long do_seccomp(unsigned int op, unsigned int flags,
> >                        const char __user *uargs)
> > --
> > 2.1.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-api" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
