From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 05/11] seccomp: Split put_seccomp_filter()
 with put_seccomp()
Date: Tue, 18 Apr 2017 15:23:02 -0700
Message-ID: <CAGXu5jK3awbLYJTq9keb7oafUxU=_Ec9uMUHNWQH7skEhEg7WQ@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-6-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328234650.19695-6-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> The semantic is unchanged. This will be useful for the Landlock
> integration with seccomp (next commit).
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Will Drewry <wad@chromium.org>
> ---
>  include/linux/seccomp.h |  4 ++--
>  kernel/fork.c           |  2 +-
>  kernel/seccomp.c        | 18 +++++++++++++-----
>  3 files changed, 16 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> index ecc296c137cd..e25aee2cdfc0 100644
> --- a/include/linux/seccomp.h
> +++ b/include/linux/seccomp.h
> @@ -77,10 +77,10 @@ static inline int seccomp_mode(struct seccomp *s)
>  #endif /* CONFIG_SECCOMP */
>
>  #ifdef CONFIG_SECCOMP_FILTER
> -extern void put_seccomp_filter(struct task_struct *tsk);
> +extern void put_seccomp(struct task_struct *tsk);
>  extern void get_seccomp_filter(struct task_struct *tsk);
>  #else  /* CONFIG_SECCOMP_FILTER */
> -static inline void put_seccomp_filter(struct task_struct *tsk)
> +static inline void put_seccomp(struct task_struct *tsk)
>  {
>         return;
>  }
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 6c463c80e93d..a27d8e67ce33 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -363,7 +363,7 @@ void free_task(struct task_struct *tsk)
>  #endif
>         rt_mutex_debug_task_free(tsk);
>         ftrace_graph_exit_task(tsk);
> -       put_seccomp_filter(tsk);
> +       put_seccomp(tsk);
>         arch_release_task_struct(tsk);
>         if (tsk->flags & PF_KTHREAD)
>                 free_kthread_struct(tsk);
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 65f61077ad50..326f79e32127 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -64,6 +64,8 @@ struct seccomp_filter {
>  /* Limit any path through the tree to 256KB worth of instructions. */
>  #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
>
> +static void put_seccomp_filter(struct seccomp_filter *filter);

Can this be reorganized easily to avoid a forward-declaration?

> +
>  /*
>   * Endianness is explicitly ignored and left for BPF program authors to =
manage
>   * as per the specific architecture.
> @@ -314,7 +316,7 @@ static inline void seccomp_sync_threads(void)
>                  * current's path will hold a reference.  (This also
>                  * allows a put before the assignment.)
>                  */
> -               put_seccomp_filter(thread);
> +               put_seccomp_filter(thread->seccomp.filter);
>                 smp_store_release(&thread->seccomp.filter,
>                                   caller->seccomp.filter);
>
> @@ -476,10 +478,11 @@ static inline void seccomp_filter_free(struct secco=
mp_filter *filter)
>         }
>  }
>
> -/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter =
*/
> -void put_seccomp_filter(struct task_struct *tsk)
> +/* put_seccomp_filter - decrements the ref count of a filter */
> +static void put_seccomp_filter(struct seccomp_filter *filter)
>  {
> -       struct seccomp_filter *orig =3D tsk->seccomp.filter;
> +       struct seccomp_filter *orig =3D filter;
> +
>         /* Clean up single-reference branches iteratively. */
>         while (orig && atomic_dec_and_test(&orig->usage)) {
>                 struct seccomp_filter *freeme =3D orig;
> @@ -488,6 +491,11 @@ void put_seccomp_filter(struct task_struct *tsk)
>         }
>  }
>
> +void put_seccomp(struct task_struct *tsk)
> +{
> +       put_seccomp_filter(tsk->seccomp.filter);
> +}
> +
>  static void seccomp_init_siginfo(siginfo_t *info, int syscall, int reaso=
n)
>  {
>         memset(info, 0, sizeof(*info));
> @@ -914,7 +922,7 @@ long seccomp_get_filter(struct task_struct *task, uns=
igned long filter_off,
>         if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog))=
)
>                 ret =3D -EFAULT;
>
> -       put_seccomp_filter(task);
> +       put_seccomp_filter(task->seccomp.filter);
>         return ret;

I don't like that the arguments to get_seccomp_filter() and
put_seccomp_filter() are now different. I think they should match for
readability.

-Kees

--=20
Kees Cook
Pixel Security
