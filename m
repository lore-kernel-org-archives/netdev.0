From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Sat, 27 Aug 2016 00:30:36 -0700
Message-ID: <CALCETrVK1yQw=8ckLn3dcB4LuKft0NOrvQFoyFRs98ON00WgBw@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net> <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net> <20160826230539.GA26683@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160826230539.GA26683-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Aug 27, 2016 1:05 AM, "Alexei Starovoitov"
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=C3=ABl Sala=C3=BCn wrote:
> >
>
> trimming cc list again. When it's too big vger will consider it as spam.
>
> > On 26/08/2016 04:14, Alexei Starovoitov wrote:
> > > On Thu, Aug 25, 2016 at 12:32:44PM +0200, Micka=C3=ABl Sala=C3=BCn wr=
ote:
> > >> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_o=
p)
> > >> to compare the current process cgroup with a cgroup handle, The hand=
le
> > >> can match the current cgroup if it is the same or a child. This allo=
ws
> > >> to make conditional rules according to the current cgroup.
> > >>
> > >> A cgroup handle is a map entry created from a file descriptor referr=
ing
> > >> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case,=
 the
> > >> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
> > >> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.
> > >>
> > >> An unprivileged process can create and manipulate cgroups thanks to
> > >> cgroup delegation.
> > >>
> > >> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
> > > ...
> > >> +static inline u64 bpf_landlock_cmp_cgroup_beneath(u64 r1_option, u6=
4 r2_map,
> > >> +          u64 r3_map_op, u64 r4, u64 r5)
> > >> +{
> > >> +  u8 option =3D (u8) r1_option;
> > >> +  struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map=
;
> > >> +  enum bpf_map_array_op map_op =3D r3_map_op;
> > >> +  struct bpf_array *array =3D container_of(map, struct bpf_array, m=
ap);
> > >> +  struct cgroup *cg1, *cg2;
> > >> +  struct map_landlock_handle *handle;
> > >> +  int i;
> > >> +
> > >> +  /* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_CGROUP is an arraymap */
> > >> +  if (unlikely(!map)) {
> > >> +          WARN_ON(1);
> > >> +          return -EFAULT;
> > >> +  }
> > >> +  if (unlikely((option | _LANDLOCK_FLAG_OPT_MASK) !=3D _LANDLOCK_FL=
AG_OPT_MASK))
> > >> +          return -EINVAL;
> > >> +
> > >> +  /* for now, only handle OP_OR */
> > >> +  switch (map_op) {
> > >> +  case BPF_MAP_ARRAY_OP_OR:
> > >> +          break;
> > >> +  case BPF_MAP_ARRAY_OP_UNSPEC:
> > >> +  case BPF_MAP_ARRAY_OP_AND:
> > >> +  case BPF_MAP_ARRAY_OP_XOR:
> > >> +  default:
> > >> +          return -EINVAL;
> > >> +  }
> > >> +
> > >> +  synchronize_rcu();
> > >> +
> > >> +  for (i =3D 0; i < array->n_entries; i++) {
> > >> +          handle =3D (struct map_landlock_handle *)
> > >> +                          (array->value + array->elem_size * i);
> > >> +
> > >> +          /* protected by the proto types, should not happen */
> > >> +          if (unlikely(handle->type !=3D BPF_MAP_HANDLE_TYPE_LANDLO=
CK_CGROUP_FD)) {
> > >> +                  WARN_ON(1);
> > >> +                  return -EFAULT;
> > >> +          }
> > >> +          if (unlikely(!handle->css)) {
> > >> +                  WARN_ON(1);
> > >> +                  return -EFAULT;
> > >> +          }
> > >> +
> > >> +          if (option & LANDLOCK_FLAG_OPT_REVERSE) {
> > >> +                  cg1 =3D handle->css->cgroup;
> > >> +                  cg2 =3D task_css_set(current)->dfl_cgrp;
> > >> +          } else {
> > >> +                  cg1 =3D task_css_set(current)->dfl_cgrp;
> > >> +                  cg2 =3D handle->css->cgroup;
> > >> +          }
> > >> +
> > >> +          if (cgroup_is_descendant(cg1, cg2))
> > >> +                  return 0;
> > >> +  }
> > >> +  return 1;
> > >> +}
> > >
> > > - please take a loook at exisiting bpf_current_task_under_cgroup and
> > > reuse BPF_MAP_TYPE_CGROUP_ARRAY as a minimum. Doing new cgroup array
> > > is nothing but duplication of the code.
> >
> > Oh, I didn't know about this patchset and the new helper. Indeed, it
> > looks a lot like mine except there is no static verification of the map
> > type as I did with the arraymap of handles, and no batch mode either. I
> > think the return value of bpf_current_task_under_cgroup is error-prone
> > if an eBPF program do an "if(ret)" test on the value (because of the
> > negative ERRNO return value). Inverting the 0 and 1 return values shoul=
d
> > fix this (0 =3D=3D succeed, 1 =3D=3D failed, <0 =3D=3D error).
>
> nothing to fix. It's good as-is. Use if (ret > 0) instead.
>
> >
> > To sum up, there is four related patchsets:
> > * "Landlock LSM: Unprivileged sandboxing" (this series)
> > * "Add Checmate, BPF-driven minor LSM" (Sargun Dhillon)
> > * "Networking cgroup controller" (Anoop Naravaram)
> > * "Add eBPF hooks for cgroups" (Daniel Mack)
> >
> > The three other series (Sargun's, Anoop's and Daniel's) are mainly
> > focused on network access-control via cgroup for *containers*. As far a=
s
> > I can tell, only a *root* user (CAP_SYS_ADMIN) can use them. Landlock's
> > goal is to empower all processes (privileged or not) to create their ow=
n
> > sandbox. This also means, like explained in "[RFC v2 00/10] Landlock
> > LSM: Unprivileged sandboxing", there is more constraints. For example,
> > it is not acceptable to let a process probe the kernel memory as it
> > wish. More details are in the Landlock cover-letter.
> >
> >
> > Another important point is that supporting cgroup for Landlock is
> > optional. It does not rely on cgroup to be usable but is only a feature
> > available when (unprivileged) users can manage there own cgroup, which
> > is an important constraint. Put another way, Landlock should not rely o=
n
> > cgroup to create sandboxes. Indeed, a process creating a sandbox do not
> > necessarily have access to the cgroup mount point (directly or not).
>
> cgroup is the common way to group multiple tasks.
> Without cgroup only parent<->child relationship will be possible,
> which will limit usability of such lsm to a master task that controls
> its children. Such api restriction would have been ok, if we could
> extend it in the future, but unfortunately task-centric won't allow it
> without creating a parallel lsm that is cgroup based.
> Therefore I think we have to go with cgroup-centric api and your
> application has to use cgroups from the start though only parent-child
> would have been enough.
> Also I don't think the kernel can afford two bpf based lsm. One task
> based and another cgroup based, so we have to find common ground
> that suits both use cases.
> Having unprivliged access is a subset. There is no strong reason why
> cgroup+lsm+bpf should be limited to root only always.
> When we can guarantee no pointer leaks, we can allow unpriv.

I don't really understand what you mean.  In the context of landlock,
which is a *sandbox*, can one of you explain a use case that
materially benefits from this type of cgroup usage?  I haven't thought
of one.
