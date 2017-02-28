From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Tue, 28 Feb 2017 12:01:50 -0800
Message-ID: <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com>
References: <20170222012632.4196-1-mic@digikod.net> <20170222012632.4196-7-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
	Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
	Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-6849-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170222012632.4196-7-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> The seccomp(2) syscall can be use to apply a Landlock rule to the
> current process. As with a seccomp filter, the Landlock rule is enforced
> for all its future children. An inherited rule tree can be updated
> (append-only) by the owner of inherited Landlock nodes (e.g. a parent
> process that create a new rule)

Can you clarify exaclty what this type of update does?  Is it
something that should be supported by normal seccomp rules as well?

> +/**
> + * landlock_run_prog - run Landlock program for a syscall

Unless this is actually specific to syscalls, s/for a syscall//, perhaps?

> +               if (new_events->nodes[event_idx]->owner =3D=3D
> +                               &new_events->nodes[event_idx]) {
> +                       /* We are the owner, we can then update the node.=
 */
> +                       add_landlock_rule(new_events, rule);

This is the part I don't get.  Adding a rule if you're the owner (BTW,
why is ownership visible to userspace at all?) for just yourself and
future children is very different from adding it so it applies to
preexisting children too.


> +               } else if (atomic_read(&current_events->usage) =3D=3D 1) =
{
> +                       WARN_ON(new_events->nodes[event_idx]->owner);
> +                       /*
> +                        * We can become the new owner if no other task u=
se it.
> +                        * This avoid an unnecessary allocation.
> +                        */
> +                       new_events->nodes[event_idx]->owner =3D
> +                               &new_events->nodes[event_idx];
> +                       add_landlock_rule(new_events, rule);
> +               } else {
> +                       /*
> +                        * We are not the owner, we need to fork current_=
events
> +                        * and then add a new node.
> +                        */
> +                       struct landlock_node *node;
> +                       size_t i;
> +
> +                       node =3D kmalloc(sizeof(*node), GFP_KERNEL);
> +                       if (!node) {
> +                               new_events =3D ERR_PTR(-ENOMEM);
> +                               goto put_rule;
> +                       }
> +                       atomic_set(&node->usage, 1);
> +                       /* set the previous node after the new_events
> +                        * allocation */
> +                       node->prev =3D NULL;
> +                       /* do not increment the previous node usage */
> +                       node->owner =3D &new_events->nodes[event_idx];
> +                       /* rule->prev is already NULL */
> +                       atomic_set(&rule->usage, 1);
> +                       node->rule =3D rule;
> +
> +                       new_events =3D new_raw_landlock_events();
> +                       if (IS_ERR(new_events)) {
> +                               /* put the rule as well */
> +                               put_landlock_node(node);
> +                               return ERR_PTR(-ENOMEM);
> +                       }
> +                       for (i =3D 0; i < ARRAY_SIZE(new_events->nodes); =
i++) {
> +                               new_events->nodes[i] =3D
> +                                       lockless_dereference(
> +                                                       current_events->n=
odes[i]);
> +                               if (i =3D=3D event_idx)
> +                                       node->prev =3D new_events->nodes[=
i];
> +                               if (!WARN_ON(!new_events->nodes[i]))
> +                                       atomic_inc(&new_events->nodes[i]-=
>usage);
> +                       }
> +                       new_events->nodes[event_idx] =3D node;
> +
> +                       /*
> +                        * @current_events will not be freed here because=
 it's usage
> +                        * field is > 1. It is only prevented to be freed=
 by another
> +                        * subject thanks to the caller of landlock_appen=
d_prog() which
> +                        * should be locked if needed.
> +                        */
> +                       put_landlock_events(current_events);
> +               }
> +       }
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
> + * is made to contains an array pointing to Landlock rule lists. This de=
sign
> + * has low-performance impact and is memory efficient while keeping the
> + * property of append-only rules.
> + *
> + * @flags: not used for now, but could be used for TSYNC
> + * @user_bpf_fd: file descriptor pointing to a loaded Landlock rule
> + */
> +#ifdef CONFIG_SECCOMP_FILTER
> +int landlock_seccomp_append_prog(unsigned int flags, const char __user *=
user_bpf_fd)
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
> +       if (!user_bpf_fd)
> +               return -EFAULT;
> +       if (flags)
> +               return -EINVAL;
> +       if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(bpf_fd)))
> +               return -EFAULT;
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
nts, prog);

Do you need to check that it's the right *kind* of bpf prog or is that
handled elsewhere?

--Andy
