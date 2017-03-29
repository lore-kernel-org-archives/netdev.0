From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH net-next v6 06/11] seccomp,landlock:
 Handle Landlock events per process hierarchy
Date: Wed, 29 Mar 2017 12:35:19 +0200
Message-ID: <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-7-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>, Daniel Borkmann <daniel@iogearbox.net>,
	David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
	"Eric W . Biederman" <ebiederm@xmission.com>, James Morris <james.l.morris@oracle.com>,
	Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
	Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
	Linux API <linux-ap
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-7149-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170328234650.19695-7-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 1:46 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
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
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>
> Cc: Will Drewry <wad@chromium.org>
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
>  };

Sorry if this was discussed before, but since this is mean to be a
stackable LSM, I'm wondering if later you could move the events from
seccomp, and go with a security_task_alloc() model [1] ?

Thanks!

[1] http://kernsec.org/pipermail/linux-security-module-archive/2017-March/0=
00184.html
