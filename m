From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 4/6] seccomp: add a way to access filters via bpf fds
Date: Fri, 4 Sep 2015 13:26:42 -0700
Message-ID: <CAGXu5j+B_ENy7txG4nndpeOh_z_3d7bBxeJD-WS_yPBZiuZ7rg@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
	<1441382664-17437-5-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441382664-17437-5-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> This patch adds a way for a process that is "real root" to access the
> seccomp filters of another process. The process first does a
> PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> bpf(BPF_PROG_DUMP) to dump the actual program at each step.

Why is this a new ptrace interface instead of a new seccomp interface?
I would expect this to only be valid for "current", otherwise we could
run into races as the ptracee adds filters. i.e. it is not safe to
examine seccomp filters from tasks other than current.

-Kees

>
> Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> CC: Kees Cook <keescook@chromium.org>
> CC: Will Drewry <wad@chromium.org>
> CC: Oleg Nesterov <oleg@redhat.com>
> CC: Andy Lutomirski <luto@amacapital.net>
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> CC: Alexei Starovoitov <ast@kernel.org>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  include/linux/bpf.h         | 12 ++++++++++
>  include/linux/seccomp.h     | 14 +++++++++++
>  include/uapi/linux/ptrace.h |  3 +++
>  kernel/bpf/syscall.c        | 26 ++++++++++++++++++++-
>  kernel/ptrace.c             |  7 ++++++
>  kernel/seccomp.c            | 57 +++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 118 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 4383476..30682dc 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -157,6 +157,8 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl);
>  void bpf_register_map_type(struct bpf_map_type_list *tl);
>
>  struct bpf_prog *bpf_prog_get(u32 ufd);
> +int bpf_prog_set(u32 ufd, struct bpf_prog *new);
> +int bpf_new_fd(struct bpf_prog *prog, int flags);
>  void bpf_prog_put(struct bpf_prog *prog);
>  void bpf_prog_put_rcu(struct bpf_prog *prog);
>
> @@ -175,6 +177,16 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
>         return ERR_PTR(-EOPNOTSUPP);
>  }
>
> +static inline int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> +{
> +       return -EINVAL;
> +}
> +
> +static inline int bpf_new_fd(struct bpf_prog *prog, int flags)
> +{
> +       return -EINVAL;
> +}
> +
>  static inline void bpf_prog_put(struct bpf_prog *prog)
>  {
>  }
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index f426503..d1a86ed 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -95,4 +95,18 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
>         return;
>  }
>  #endif /* CONFIG_SECCOMP_FILTER */
> +
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
> +extern long seccomp_get_filter_fd(struct task_struct *child);
> +extern long seccomp_next_filter(struct task_struct *child, u32 fd);
> +#else
> +static inline long seccomp_get_filter_fd(struct task_struct *child)
> +{
> +       return -EINVAL;
> +}
> +static inline long seccomp_next_filter(struct task_struct *child, u32 fd)
> +{
> +       return -EINVAL;
> +}
> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
>  #endif /* _LINUX_SECCOMP_H */
> diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
> index a7a6979..dfd7d2e 100644
> --- a/include/uapi/linux/ptrace.h
> +++ b/include/uapi/linux/ptrace.h
> @@ -23,6 +23,9 @@
>
>  #define PTRACE_SYSCALL           24
>
> +#define PTRACE_SECCOMP_GET_FILTER_FD   40
> +#define PTRACE_SECCOMP_NEXT_FILTER     41
> +
>  /* 0x4200-0x4300 are reserved for architecture-independent additions.  */
>  #define PTRACE_SETOPTIONS      0x4200
>  #define PTRACE_GETEVENTMSG     0x4201
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index ee580d0..58e7421 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -506,6 +506,30 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
>  }
>  EXPORT_SYMBOL_GPL(bpf_prog_get);
>
> +int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> +{
> +       struct fd f;
> +       struct bpf_prog *prog;
> +
> +       f = fdget(ufd);
> +
> +       prog = get_prog(f);
> +       if (!IS_ERR(prog) && prog)
> +               bpf_prog_put(prog);
> +
> +       atomic_inc(&new->aux->refcnt);
> +       f.file->private_data = new;
> +       fdput(f);
> +       return 0;
> +}
> +EXPORT_SYMBOL_GPL(bpf_prog_set);
> +
> +int bpf_new_fd(struct bpf_prog *prog, int flags)
> +{
> +       return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, flags);
> +}
> +EXPORT_SYMBOL_GPL(bpf_new_fd);
> +
>  /* last field in 'union bpf_attr' used by this command */
>  #define        BPF_PROG_LOAD_LAST_FIELD kern_version
>
> @@ -572,7 +596,7 @@ static int bpf_prog_load(union bpf_attr *attr)
>         if (err < 0)
>                 goto free_used_maps;
>
> -       err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
> +       err = bpf_new_fd(prog, O_RDWR | O_CLOEXEC);
>         if (err < 0)
>                 /* failed to allocate fd */
>                 goto free_used_maps;
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 787320d..4e4b534 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -1016,6 +1016,13 @@ int ptrace_request(struct task_struct *child, long request,
>                 break;
>         }
>  #endif
> +
> +       case PTRACE_SECCOMP_GET_FILTER_FD:
> +               return seccomp_get_filter_fd(child);
> +
> +       case PTRACE_SECCOMP_NEXT_FILTER:
> +               return seccomp_next_filter(child, data);
> +
>         default:
>                 break;
>         }
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index acfe1fb..a2c5b32 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -26,6 +26,8 @@
>  #endif
>
>  #ifdef CONFIG_SECCOMP_FILTER
> +#include <linux/bpf.h>
> +#include <uapi/linux/bpf.h>
>  #include <linux/filter.h>
>  #include <linux/pid.h>
>  #include <linux/ptrace.h>
> @@ -814,6 +816,61 @@ static inline long seccomp_set_mode_filter(unsigned int flags,
>  }
>  #endif
>
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
> +long seccomp_get_filter_fd(struct task_struct *child)
> +{
> +       long fd;
> +       struct seccomp_filter *filter;
> +
> +       if (!capable(CAP_SYS_ADMIN))
> +               return -EACCES;
> +
> +       if (child->seccomp.mode != SECCOMP_MODE_FILTER)
> +               return -EINVAL;
> +
> +       filter = child->seccomp.filter;
> +
> +       fd = bpf_new_fd(filter->prog, O_RDONLY);
> +       if (fd > 0)
> +               atomic_inc(&filter->prog->aux->refcnt);
> +
> +       return fd;
> +}
> +
> +long seccomp_next_filter(struct task_struct *child, u32 fd)
> +{
> +       struct seccomp_filter *cur;
> +       struct bpf_prog *prog;
> +       long ret = -ESRCH;
> +
> +       if (!capable(CAP_SYS_ADMIN))
> +               return -EACCES;
> +
> +       if (child->seccomp.mode != SECCOMP_MODE_FILTER)
> +               return -EINVAL;
> +
> +       prog = bpf_prog_get(fd);
> +       if (IS_ERR(prog)) {
> +               ret = PTR_ERR(prog);
> +               goto out;
> +       }
> +
> +       for (cur = child->seccomp.filter; cur; cur = cur->prev) {
> +               if (cur->prog == prog) {
> +                       if (!cur->prev)
> +                               ret = -ENOENT;
> +                       else
> +                               ret = bpf_prog_set(fd, cur->prev->prog);
> +                       break;
> +               }
> +       }
> +
> +out:
> +       bpf_prog_put(prog);
> +       return ret;
> +}
> +#endif
> +
>  /* Common entry point for both prctl and syscall. */
>  static long do_seccomp(unsigned int op, unsigned int flags,
>                        const char __user *uargs)
> --
> 2.1.4
>



-- 
Kees Cook
Chrome OS Security
