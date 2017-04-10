From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [kernel-hardening] [PATCH net-next v6 07/11] landlock: Add ptrace restrictions
Date: Mon, 10 Apr 2017 08:48:36 +0200
Message-ID: <CAEiveUdXGEOywJoYTsBcxCp02_2gtj7Zw0zT_YdGWM3fJLYY7g@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-8-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328234650.19695-8-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 1:46 AM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> A landlocked process has less privileges than a non-landlocked process
> and must then be subject to additional restrictions when manipulating
> processes. To be allowed to use ptrace(2) and related syscalls on a
> target process, a landlocked process must have a subset of the target
> process' rules.
>
> New in v6
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> ---
>  security/landlock/Makefile       |   2 +-
>  security/landlock/hooks_ptrace.c | 126 +++++++++++++++++++++++++++++++++=
++++++
>  security/landlock/hooks_ptrace.h |  11 ++++
>  security/landlock/init.c         |   2 +
>  4 files changed, 140 insertions(+), 1 deletion(-)
>  create mode 100644 security/landlock/hooks_ptrace.c
>  create mode 100644 security/landlock/hooks_ptrace.h
>
[...]

> +/**
> + * landlock_ptrace_access_check - determine whether the current process =
may
> + *                               access another
> + *
> + * @child: the process to be accessed
> + * @mode: the mode of attachment
> + *
> + * If the current task has Landlock rules, then the child must have at l=
east
> + * the same rules.  Else denied.
> + *
> + * Determine whether a process may access another, returning 0 if permis=
sion
> + * granted, -errno if denied.
> + */
> +static int landlock_ptrace_access_check(struct task_struct *child,
> +               unsigned int mode)
> +{
> +       if (!landlocked(current))
> +               return 0;
> +
> +       if (!landlocked(child))
> +               return -EPERM;
> +
> +       if (landlock_task_has_subset_events(current, child))
> +               return 0;
> +
> +       return -EPERM;
> +}
> +

Maybe you want to check the mode argument here if it is a
PTRACE_ATTACH which may translate to read/writes ? PTRACE_READ are
normally for reads only. Or also which creds were used if this was a
direct syscall or a filesystem call through procfs.

I'm bringing this, since you may want to make some room for landlock
ptrace events and what others may want to do with it. Also I'm
planning to send another v2 RFC for procfs separate instances [1], the
aim is to give LSMs a security_ptrace_access_check hook path when
dealing with /proc/<pids>/ [2]  . Right now LSMs don't really have a
security path there, and the implementation does not guarantee that.
With this Yama ptrace scope or other LSMs may take advantage of it and
check the 'PTRACE_MODE_READ_FSCRED' mode for filesystem accesses.
That's why I think it would be better if the default landlock ptrace
semantics are not that wide.

Thanks!

[1] https://lkml.org/lkml/2017/3/30/670
[2] http://lxr.free-electrons.com/source/fs/proc/base.c#L719
