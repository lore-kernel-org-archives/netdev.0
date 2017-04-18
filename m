From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v6 06/11] seccomp,landlock: Handle Landlock
 events per process hierarchy
Date: Tue, 18 Apr 2017 15:53:45 -0700
Message-ID: <CAGXu5jJ36E8L9=sh62vPy+0t84Bx4n4Y9eiYZU+DtUZom1vpCQ@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-7-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328234650.19695-7-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> The seccomp(2) syscall can be used by a task to apply a Landlock rule to
> itself. As a seccomp filter, a Landlock rule is enforced for the current
> task and all its future children. A rule is immutable and a task can
> only add new restricting rules to itself, forming a chain of rules.
>
> A Landlock rule is tied to a Landlock event. If the use of a kernel
> object is allowed by the other Linux security mechanisms (e.g. DAC,
> capabilities, other LSM), then a Landlock event related to this kind of
> object is triggered. The chain of rules for this event is then
> evaluated. Each rule return a 32-bit value which can deny the use of a
> kernel object with a non-zero value. If every rules of the chain return
> zero, then the use of the object is allowed.
>
> Changes since v5:
> * remove struct landlock_node and use a similar inheritance mechanisme
>   as seccomp-bpf (requested by Andy Lutomirski)
> * rename SECCOMP_ADD_LANDLOCK_RULE to SECCOMP_APPEND_LANDLOCK_RULE
> * rename file manager.c to providers.c
> * add comments
> * typo and cosmetic fixes
>
> Changes since v4:
> * merge manager and seccomp patches
> * return -EFAULT in seccomp(2) when user_bpf_fd is null to easely check
>   if Landlock is supported
> * only allow a process with the global CAP_SYS_ADMIN to use Landlock
>   (will be lifted in the future)
> * add an early check to exit as soon as possible if the current process
>   does not have Landlock rules
>
> Changes since v3:
> * remove the hard link with seccomp (suggested by Andy Lutomirski and
>   Kees Cook):
>   * remove the cookie which could imply multiple evaluation of Landlock
>     rules
>   * remove the origin field in struct landlock_data
> * remove documentation fix (merged upstream)
> * rename the new seccomp command to SECCOMP_ADD_LANDLOCK_RULE
> * internal renaming
> * split commit
> * new design to be able to inherit on the fly the parent rules
>
> Changes since v2:
> * Landlock programs can now be run without seccomp filter but for any
>   syscall (from the process) or interruption
> * move Landlock related functions and structs into security/landlock/*
>   (to manage cgroups as well)
> * fix seccomp filter handling: run Landlock programs for each of their
>   legitimate seccomp filter
> * properly clean up all seccomp results
> * cosmetic changes to ease the understanding
> * fix some ifdef
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Link: https://lkml.kernel.org/r/c10a503d-5e35-7785-2f3d-25ed8dd63fab@digi=
kod.net
> ---
>  include/linux/landlock.h      |  36 +++++++
>  include/linux/seccomp.h       |   8 ++
>  include/uapi/linux/seccomp.h  |   1 +
>  kernel/fork.c                 |  14 ++-
>  kernel/seccomp.c              |   8 ++
>  security/landlock/Makefile    |   2 +-
>  security/landlock/hooks.c     |  37 +++++++
>  security/landlock/hooks.h     |   5 +
>  security/landlock/init.c      |   3 +-
>  security/landlock/providers.c | 232 ++++++++++++++++++++++++++++++++++++=
++++++
>  10 files changed, 342 insertions(+), 4 deletions(-)
>  create mode 100644 security/landlock/providers.c
>
> diff --git a/include/linux/landlock.h b/include/linux/landlock.h
> index 53013dc374fe..c40ee78e86e0 100644
> --- a/include/linux/landlock.h
> +++ b/include/linux/landlock.h
> @@ -12,6 +12,9 @@
>  #define _LINUX_LANDLOCK_H
>  #ifdef CONFIG_SECURITY_LANDLOCK
>
> +#include <linux/bpf.h> /* _LANDLOCK_SUBTYPE_EVENT_LAST */
> +#include <linux/types.h> /* atomic_t */
> +
>  /*
>   * This is not intended for the UAPI headers. Each userland software sho=
uld use
>   * a static minimal version for the required features as explained in th=
e
> @@ -19,5 +22,38 @@
>   */
>  #define LANDLOCK_VERSION 1
>
> +struct landlock_rule {
> +       atomic_t usage;

This should be refcount_t. (And I should convert seccomp to use
refcount_t too!) :)

> +       struct landlock_rule *prev;
> +       struct bpf_prog *prog;
> +};
> +
> +/**
> + * struct landlock_events - Landlock event rules enforced on a thread
> + *
> + * This is used for low performance impact when forking a process. Inste=
ad of
> + * copying the full array and incrementing the usage of each entries, on=
ly
> + * create a pointer to &struct landlock_events and increments its usage.=
 When
> + * appending a new rule, if &struct landlock_events is shared with other=
 tasks,
> + * then duplicate it and append the rule to this new &struct landlock_ev=
ents.
> + *
> + * @usage: reference count to manage the object lifetime. When a thread =
need to
> + *         add Landlock rules and if @usage is greater than 1, then the =
thread
> + *         must duplicate &struct landlock_events to not change the chil=
dren's
> + *         rules as well.
> + * @rules: array of non-NULL &struct landlock_rule pointers
> + */
> +struct landlock_events {
> +       atomic_t usage;
> +       struct landlock_rule *rules[_LANDLOCK_SUBTYPE_EVENT_LAST];
> +};
> +
> +void put_landlock_events(struct landlock_events *events);
> +
> +#ifdef CONFIG_SECCOMP_FILTER

Isn't CONFIG_SECCOMP_FILTER already required for landlock?

> +int landlock_seccomp_append_prog(unsigned int flags,
> +               const char __user *user_bpf_fd);
> +#endif /* CONFIG_SECCOMP_FILTER */
> +
>  #endif /* CONFIG_SECURITY_LANDLOCK */
>  #endif /* _LINUX_LANDLOCK_H */
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index e25aee2cdfc0..9a38de3c0e72 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -10,6 +10,10 @@
>  #include <linux/thread_info.h>
>  #include <asm/seccomp.h>
>
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
> +struct landlock_events;
> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */

Testing LANDLOCK should be sufficient, since it requires ..._FILTER.

> +
>  struct seccomp_filter;
>  /**
>   * struct seccomp - the state of a seccomp'ed process
> @@ -18,6 +22,7 @@ struct seccomp_filter;
>   *         system calls available to a process.
>   * @filter: must always point to a valid seccomp-filter or NULL as it is
>   *          accessed without locking during system call entry.
> + * @landlock_events: contains an array of Landlock rules.
>   *
>   *          @filter must only be accessed from the context of current as=
 there
>   *          is no read locking.
> @@ -25,6 +30,9 @@ struct seccomp_filter;
>  struct seccomp {
>         int mode;
>         struct seccomp_filter *filter;
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
> +       struct landlock_events *landlock_events;
> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */

Same.

>  };
>
>  #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
> diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
> index 0f238a43ff1e..74891cf60ca6 100644
> --- a/include/uapi/linux/seccomp.h
> +++ b/include/uapi/linux/seccomp.h
> @@ -13,6 +13,7 @@
>  /* Valid operations for seccomp syscall. */
>  #define SECCOMP_SET_MODE_STRICT        0
>  #define SECCOMP_SET_MODE_FILTER        1
> +#define SECCOMP_APPEND_LANDLOCK_RULE   2
>
>  /* Valid flags for SECCOMP_SET_MODE_FILTER */
>  #define SECCOMP_FILTER_FLAG_TSYNC      1
> diff --git a/kernel/fork.c b/kernel/fork.c
> index a27d8e67ce33..14c09486c565 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -47,6 +47,7 @@
>  #include <linux/security.h>
>  #include <linux/hugetlb.h>
>  #include <linux/seccomp.h>
> +#include <linux/landlock.h>
>  #include <linux/swap.h>
>  #include <linux/syscalls.h>
>  #include <linux/jiffies.h>
> @@ -528,7 +529,10 @@ static struct task_struct *dup_task_struct(struct ta=
sk_struct *orig, int node)
>          * the usage counts on the error path calling free_task.
>          */
>         tsk->seccomp.filter =3D NULL;
> -#endif
> +#ifdef CONFIG_SECURITY_LANDLOCK
> +       tsk->seccomp.landlock_events =3D NULL;
> +#endif /* CONFIG_SECURITY_LANDLOCK */
> +#endif /* CONFIG_SECCOMP */
>
>         setup_thread_stack(tsk, orig);
>         clear_user_return_notifier(tsk);
> @@ -1405,7 +1409,13 @@ static void copy_seccomp(struct task_struct *p)
>
>         /* Ref-count the new filter user, and assign it. */
>         get_seccomp_filter(current);
> -       p->seccomp =3D current->seccomp;
> +       p->seccomp.mode =3D current->seccomp.mode;
> +       p->seccomp.filter =3D current->seccomp.filter;
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
> +       p->seccomp.landlock_events =3D current->seccomp.landlock_events;
> +       if (p->seccomp.landlock_events)
> +               atomic_inc(&p->seccomp.landlock_events->usage);
> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */

Hrm. So, this needs config cleanup as above. Also, I'm going to need
some help understanding the usage tracking on landlock_events (which
should use a get/put rather than open-coding the _inc). I don't see
why individual assignments are needed here. The only thing that
matters is the usage bump. I would have expected no changes at all in
this code, actually. The filter and the events share the same usage
don't they?

>         /*
>          * Explicitly enable no_new_privs here in case it got set
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 326f79e32127..d122829e6da1 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -34,6 +34,7 @@
>  #include <linux/security.h>
>  #include <linux/tracehook.h>
>  #include <linux/uaccess.h>
> +#include <linux/landlock.h>
>
>  /**
>   * struct seccomp_filter - container for seccomp BPF programs
> @@ -494,6 +495,9 @@ static void put_seccomp_filter(struct seccomp_filter =
*filter)
>  void put_seccomp(struct task_struct *tsk)
>  {
>         put_seccomp_filter(tsk->seccomp.filter);
> +#ifdef CONFIG_SECURITY_LANDLOCK
> +       put_landlock_events(tsk->seccomp.landlock_events);
> +#endif /* CONFIG_SECURITY_LANDLOCK */

put_landlock_events() should be defined in a header file to be a
static inline no-op if ..._LANDLOCK isn't defined. That way we can
avoid all the #ifdef stuff here. Similarly, I think all of these
should take just task_struct so that there isn't an exposed structure
name which lets you avoid the #ifdef too.

>  }
>
>  static void seccomp_init_siginfo(siginfo_t *info, int syscall, int reaso=
n)
> @@ -813,6 +817,10 @@ static long do_seccomp(unsigned int op, unsigned int=
 flags,
>                 return seccomp_set_mode_strict();
>         case SECCOMP_SET_MODE_FILTER:
>                 return seccomp_set_mode_filter(flags, uargs);
> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK)
> +       case SECCOMP_APPEND_LANDLOCK_RULE:
> +               return landlock_seccomp_append_prog(flags, uargs);
> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>         default:
>                 return -EINVAL;
>         }
> diff --git a/security/landlock/Makefile b/security/landlock/Makefile
> index c0db504a6335..da8ba8b5183e 100644
> --- a/security/landlock/Makefile
> +++ b/security/landlock/Makefile
> @@ -2,4 +2,4 @@ ccflags-$(CONFIG_SECURITY_LANDLOCK) +=3D -Werror=3Dunused=
-function
>
>  obj-$(CONFIG_SECURITY_LANDLOCK) :=3D landlock.o
>
> -landlock-y :=3D init.o hooks.o hooks_fs.o
> +landlock-y :=3D init.o providers.o hooks.o hooks_fs.o
> diff --git a/security/landlock/hooks.c b/security/landlock/hooks.c
> index eaee8162ff70..4fa7d0b38d41 100644
> --- a/security/landlock/hooks.c
> +++ b/security/landlock/hooks.c
> @@ -95,6 +95,38 @@ bool landlock_is_valid_access(int off, int size, enum =
bpf_access_type type,
>         return true;
>  }
>
> +/**
> + * landlock_event_deny - run Landlock rules tied to an event
> + *
> + * @event_idx: event index in the rules array
> + * @ctx: non-NULL eBPF context
> + * @events: Landlock events pointer
> + *
> + * Return true if at least one rule deny the event.
> + */
> +static bool landlock_event_deny(u32 event_idx, const struct landlock_con=
text *ctx,
> +               struct landlock_events *events)
> +{
> +       struct landlock_rule *rule;
> +
> +       if (!events)
> +               return false;
> +
> +       for (rule =3D events->rules[event_idx]; rule; rule =3D rule->prev=
) {
> +               u32 ret;
> +
> +               if (WARN_ON(!rule->prog))
> +                       continue;
> +               rcu_read_lock();
> +               ret =3D BPF_PROG_RUN(rule->prog, (void *)ctx);
> +               rcu_read_unlock();
> +               /* deny access if a program returns a value different tha=
n 0 */
> +               if (ret)
> +                       return true;
> +       }
> +       return false;
> +}
> +
>  int landlock_decide(enum landlock_subtype_event event,
>                 __u64 ctx_values[CTX_ARG_NB], u32 cmd, const char *hook)
>  {
> @@ -111,5 +143,10 @@ int landlock_decide(enum landlock_subtype_event even=
t,
>                 .arg2 =3D ctx_values[1],
>         };
>
> +#ifdef CONFIG_SECCOMP_FILTER
> +       deny =3D landlock_event_deny(event_idx, &ctx,
> +                       current->seccomp.landlock_events);
> +#endif /* CONFIG_SECCOMP_FILTER */

Isn't ..._FILTER required?

> +
>         return deny ? -EPERM : 0;
>  }
> diff --git a/security/landlock/hooks.h b/security/landlock/hooks.h
> index 2e180f6ed86b..dd0486a4c284 100644
> --- a/security/landlock/hooks.h
> +++ b/security/landlock/hooks.h
> @@ -12,6 +12,7 @@
>  #include <linux/bpf.h> /* enum bpf_access_type */
>  #include <linux/lsm_hooks.h>
>  #include <linux/sched.h> /* struct task_struct */
> +#include <linux/seccomp.h>
>
>  /* separators */
>  #define SEP_COMMA() ,
> @@ -163,7 +164,11 @@ WRAP_TYPE_RAW_C;
>
>  static inline bool landlocked(const struct task_struct *task)
>  {
> +#ifdef CONFIG_SECCOMP_FILTER
> +       return !!(task->seccomp.landlock_events);
> +#else
>         return false;
> +#endif /* CONFIG_SECCOMP_FILTER */
>  }
>
>  __init void landlock_register_hooks(struct security_hook_list *hooks, in=
t count);
> diff --git a/security/landlock/init.c b/security/landlock/init.c
> index 1c2750e12dfa..ef8a3da69860 100644
> --- a/security/landlock/init.c
> +++ b/security/landlock/init.c
> @@ -135,7 +135,8 @@ static struct bpf_prog_type_list bpf_landlock_type __=
ro_after_init =3D {
>
>  void __init landlock_add_hooks(void)
>  {
> -       pr_info("landlock: Version %u", LANDLOCK_VERSION);
> +       pr_info("landlock: Version %u, ready to sandbox with %s\n",
> +                       LANDLOCK_VERSION, "seccomp");
>         landlock_add_hooks_fs();
>         security_add_hooks(NULL, 0, "landlock");
>         bpf_register_prog_type(&bpf_landlock_type);
> diff --git a/security/landlock/providers.c b/security/landlock/providers.=
c
> new file mode 100644
> index 000000000000..6d867a39c947
> --- /dev/null
> +++ b/security/landlock/providers.c
> @@ -0,0 +1,232 @@
> +/*
> + * Landlock LSM - seccomp provider
> + *
> + * Copyright =C2=A9 2017 Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <asm/page.h> /* PAGE_SIZE */
> +#include <linux/atomic.h> /* atomic_*(), smp_store_release() */
> +#include <linux/bpf.h> /* bpf_prog_put() */
> +#include <linux/filter.h> /* struct bpf_prog */
> +#include <linux/kernel.h> /* round_up() */
> +#include <linux/landlock.h>
> +#include <linux/sched.h> /* current_cred(), task_no_new_privs() */
> +#include <linux/security.h> /* security_capable_noaudit() */
> +#include <linux/slab.h> /* alloc(), kfree() */
> +#include <linux/types.h> /* atomic_t */
> +#include <linux/uaccess.h> /* copy_from_user() */
> +
> +#include "common.h"
> +
> +static void put_landlock_rule(struct landlock_rule *rule)
> +{
> +       struct landlock_rule *orig =3D rule;
> +
> +       /* clean up single-reference branches iteratively */
> +       while (orig && atomic_dec_and_test(&orig->usage)) {
> +               struct landlock_rule *freeme =3D orig;
> +
> +               bpf_prog_put(orig->prog);
> +               orig =3D orig->prev;
> +               kfree(freeme);
> +       }
> +}
> +
> +void put_landlock_events(struct landlock_events *events)
> +{
> +       if (events && atomic_dec_and_test(&events->usage)) {
> +               size_t i;
> +
> +               for (i =3D 0; i < ARRAY_SIZE(events->rules); i++)
> +                       /* XXX: Do we need to use lockless_dereference() =
here? */
> +                       put_landlock_rule(events->rules[i]);
> +               kfree(events);
> +       }
> +}
> +
> +static struct landlock_events *new_landlock_events(void)
> +{
> +       struct landlock_events *ret;
> +
> +       /* array filled with NULL values */
> +       ret =3D kzalloc(sizeof(*ret), GFP_KERNEL);
> +       if (!ret)
> +               return ERR_PTR(-ENOMEM);
> +       atomic_set(&ret->usage, 1);
> +       return ret;
> +}
> +
> +static void add_landlock_rule(struct landlock_events *events,
> +               struct landlock_rule *rule)
> +{
> +       /* subtype.landlock_rule.event > 0 for loaded programs */
> +       u32 event_idx =3D get_index(rule->prog->subtype.landlock_rule.eve=
nt);
> +
> +       rule->prev =3D events->rules[event_idx];
> +       WARN_ON(atomic_read(&rule->usage));
> +       atomic_set(&rule->usage, 1);
> +       /* do not increment the previous rule usage */
> +       smp_store_release(&events->rules[event_idx], rule);
> +}
> +
> +/* limit Landlock events to 256KB */
> +#define LANDLOCK_EVENTS_MAX_PAGES (1 << 6)
> +
> +/**
> + * landlock_append_prog - attach a Landlock rule to @current_events
> + *
> + * @current_events: landlock_events pointer, must be locked (if needed) =
to
> + *                  prevent a concurrent put/free. This pointer must not=
 be
> + *                  freed after the call.
> + * @prog: non-NULL Landlock rule to append to @current_events. @prog wil=
l be
> + *        owned by landlock_append_prog() and freed if an error happened=
.
> + *
> + * Return @current_events or a new pointer when OK. Return a pointer err=
or
> + * otherwise.
> + */
> +static struct landlock_events *landlock_append_prog(
> +               struct landlock_events *current_events, struct bpf_prog *=
prog)
> +{
> +       struct landlock_events *new_events =3D current_events;
> +       unsigned long pages;
> +       struct landlock_rule *rule;
> +       u32 event_idx;
> +
> +       if (prog->type !=3D BPF_PROG_TYPE_LANDLOCK) {
> +               new_events =3D ERR_PTR(-EINVAL);
> +               goto put_prog;
> +       }
> +
> +       /* validate memory size allocation */
> +       pages =3D prog->pages;
> +       if (current_events) {
> +               size_t i;
> +
> +               for (i =3D 0; i < ARRAY_SIZE(current_events->rules); i++)=
 {
> +                       struct landlock_rule *walker_r;
> +
> +                       for (walker_r =3D current_events->rules[i]; walke=
r_r;
> +                                       walker_r =3D walker_r->prev)
> +                               pages +=3D walker_r->prog->pages;
> +               }
> +               /* count a struct landlock_events if we need to allocate =
one */
> +               if (atomic_read(&current_events->usage) !=3D 1)
> +                       pages +=3D round_up(sizeof(*current_events), PAGE=
_SIZE) /
> +                               PAGE_SIZE;
> +       }
> +       if (pages > LANDLOCK_EVENTS_MAX_PAGES) {
> +               new_events =3D ERR_PTR(-E2BIG);
> +               goto put_prog;
> +       }
> +
> +       rule =3D kzalloc(sizeof(*rule), GFP_KERNEL);
> +       if (!rule) {
> +               new_events =3D ERR_PTR(-ENOMEM);
> +               goto put_prog;
> +       }
> +       rule->prog =3D prog;
> +
> +       /* subtype.landlock_rule.event > 0 for loaded programs */
> +       event_idx =3D get_index(rule->prog->subtype.landlock_rule.event);
> +
> +       if (!new_events) {
> +               /*
> +                * If there is no Landlock events used by the current tas=
k,
> +                * then create a new one.
> +                */
> +               new_events =3D new_landlock_events();
> +               if (IS_ERR(new_events))
> +                       goto put_rule;

Shouldn't bpf_prog_put() get called in the face of a rule failure too?
Why separate exit paths?

> +       } else if (atomic_read(&current_events->usage) > 1) {
> +               /*
> +                * If the current task is not the sole user of its Landlo=
ck
> +                * events, then duplicate them.
> +                */
> +               size_t i;
> +
> +               new_events =3D new_landlock_events();
> +               if (IS_ERR(new_events))
> +                       goto put_rule;
> +               for (i =3D 0; i < ARRAY_SIZE(new_events->rules); i++) {
> +                       new_events->rules[i] =3D
> +                               lockless_dereference(current_events->rule=
s[i]);
> +                       if (new_events->rules[i])
> +                               atomic_inc(&new_events->rules[i]->usage);

I was going to ask: isn't the top-level usage counter sufficient to
track rule lifetime? But I think I see how things are tracked now:
each task_struct points to an array of rule list pointers. These
tables are duplicated when additions are made (which means each table
needs to be refcounted for the processes using it), and when a new
table is created, all the refcounters on the rules are bumped (to
track each table that references the rule), and when a new rule is
added, it's just prepended to the list for the new table to point at.

Does this mean that rules are processed in reverse?

> +               }
> +
> +               /*
> +                * Landlock events from the current task will not be free=
d here
> +                * because the usage is strictly greater than 1. It is on=
ly
> +                * prevented to be freed by another subject thanks to the
> +                * caller of landlock_append_prog() which should be locke=
d if
> +                * needed.
> +                */
> +               put_landlock_events(current_events);
> +       }
> +       add_landlock_rule(new_events, rule);
> +       return new_events;
> +
> +put_prog:
> +       bpf_prog_put(prog);
> +       return new_events;
> +
> +put_rule:
> +       put_landlock_rule(rule);
> +       return new_events;
> +}
> +
> +/**
> + * landlock_seccomp_append_prog - attach a Landlock rule to the current =
process
> + *
> + * current->seccomp.landlock_events is lazily allocated. When a process =
fork,
> + * only a pointer is copied. When a new event is added by a process, if =
there
> + * is other references to this process' landlock_events, then a new allo=
cation
> + * is made to contain an array pointing to Landlock rule lists. This des=
ign
> + * enable low-performance impact and is memory efficient while keeping t=
he
> + * property of append-only rules.
> + *
> + * @flags: not used for now, but could be used for TSYNC
> + * @user_bpf_fd: file descriptor pointing to a loaded Landlock rule
> + */
> +#ifdef CONFIG_SECCOMP_FILTER
> +int landlock_seccomp_append_prog(unsigned int flags,
> +               const char __user *user_bpf_fd)
> +{
> +       struct landlock_events *new_events;
> +       struct bpf_prog *prog;
> +       int bpf_fd;
> +
> +       /* force no_new_privs to limit privilege escalation */
> +       if (!task_no_new_privs(current))
> +               return -EPERM;
> +       /* will be removed in the future to allow unprivileged tasks */
> +       if (!capable(CAP_SYS_ADMIN))
> +               return -EPERM;
> +       /* enable to check if Landlock is supported with early EFAULT */
> +       if (!user_bpf_fd)
> +               return -EFAULT;
> +       if (flags)
> +               return -EINVAL;
> +       if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(bpf_fd)))
> +               return -EFAULT;

I think this can just be get_user()?

> +       prog =3D bpf_prog_get(bpf_fd);
> +       if (IS_ERR(prog))
> +               return PTR_ERR(prog);
> +
> +       /*
> +        * We don't need to lock anything for the current process hierarc=
hy,
> +        * everything is guarded by the atomic counters.
> +        */
> +       new_events =3D landlock_append_prog(current->seccomp.landlock_eve=
nts,
> +                       prog);
> +       /* @prog is managed/freed by landlock_append_prog() */

Does kmemcheck notice this "leak"? (i.e. is further annotation needed?)

> +       if (IS_ERR(new_events))
> +               return PTR_ERR(new_events);
> +       current->seccomp.landlock_events =3D new_events;
> +       return 0;
> +}
> +#endif /* CONFIG_SECCOMP_FILTER */
> --
> 2.11.0
>



--=20
Kees Cook
Pixel Security
