From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Sat, 17 Dec 2016 12:02:37 -0800
Message-ID: <CALCETrU_ykMD-xmG=vpgXXNf=7qN288X1En6R-+6gUuDWR0y=w@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <58559171.30402@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        John Stultz <john.stultz@linaro.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58559171.30402@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 11:26 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net=
> wrote:
>
> On 17/12/2016 19:18, Andy Lutomirski wrote:
>> Hi all-
>>
>> I apologize for being rather late with this.  I didn't realize that
>> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
>> it on the linux-api list, so I missed the discussion.
>>
>> I think that the inet ingress, egress etc filters are a neat feature,
>> but I think the API has some issues that will bite us down the road
>> if it becomes stable in its current form.
>>
>> Most of the problems I see are summarized in this transcript:
>>
>> # mkdir cg2
>> # mount -t cgroup2 none cg2
>> # mkdir cg2/nosockets
>> # strace cgrp_socket_rule cg2/nosockets/ 0
>> ...
>> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) =3D 3
>>
>> ^^^^ You can modify a cgroup after opening it O_RDONLY?
>
> I sent a patch to check the cgroup.procs permission before attaching a
> BPF program to it [1], but it was not merged because not part of the
> current security model (which may not be crystal clear). The thing is
> that the current socket/BPF/cgroup feature is only available to a
> process with the *global CAP_NET_ADMIN* and such a process can already
> modify the network for every processes, so it doesn't make much sense to
> check if it can modify the network for a subset of this processes.
>
> [1] https://lkml.org/lkml/2016/9/19/854

I don't think that's quite the right approach.  First, checking
permissions on an fd that's not the fd passed to the syscall is weird
and IMO shouldn't be done without a good reason.  Second,
cgroups.procs seems like the wrong file.

Why not create "net.socket_create_filter" and require a writable fd to
*that* to be passed to the syscall.

>
> However, needing a process to open a cgroup *directory* in write mode
> may not make sense because the process does not modify the content of
> the cgroup but only use it as a *reference* in the network stack.
> Forcing an open with write mode may forbid to use this kind of
> network-filtering feature in a read-only file-system but not necessarily
> read-only *network configuration*.

It does modify the cgroup.  Logically it changes the cgroup behavior.
As an implementation matter, it modifies the struct cgroup.

>
> Another point of view is that the CAP_NET_ADMIN may be an unneeded
> privilege if the cgroup migration is using a no_new_privs-like feature
> as I proposed with Landlock [2] (with an extra ptrace_may_access() check)=
.
> The new capability proposition for cgroup may be interesting too.
>
> [2] https://lkml.org/lkml/2016/9/14/82
>
>>
>> bpf(BPF_PROG_LOAD, {prog_type=3D0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=3D=
2,
>> insns=3D0x7fffe3568c10, license=3D"GPL", log_level=3D1, log_size=3D26214=
4,
>> log_buf=3D0x6020c0, kern_version=3D0}, 48) =3D 4
>>
>> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
>>
>> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) =3D 0
>>
>> ^^^^ This is not so good:
>> ^^^^
>> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
>> ^^^^    is manipulating a cgroup.  There's no reason that a socket creat=
ion
>> ^^^^    filter couldn't be written in a different language (new iptables
>> ^^^^    table?  Simple list of address families?), but if that happened,
>> ^^^^    then using bpf() to install it would be entirely nonsensical.
>
> Another point of view is to say that the BPF program (called by the
> network stack) is using a reference to a set of processes thanks to a
> cgroup.

I strongly disagree with this point of view.  From a user's
perspective, nothing about the bpf program changed -- the cgroup
changes.  Even in the code, the bpf program doesn't have a reference
to anything.  The cgroup references the bpf program.

>>
>> # echo $$ >cg2/nosockets/cgroup.procs
>> # ping 127.0.0.1
>> ping: socket: Operation not permitted
>> # ls cg2/nosockets/
>> cgroup.controllers  cgroup.events  cgroup.procs  cgroup.subtree_control
>> # cat cg2/nosockets/cgroup.controllers
>>
>> ^^^^ Something in cgroupfs should give an indication that this cgroup
>> ^^^^ filters socket creation, but there's nothing there.  You should als=
o
>> ^^^^ be able to turn the filter off from cgroupfs.
>
> Right. Everybody was OK at LPC to add such an information but it is not
> there yet.

Then let's do it before CONFIG_CGROUP_BPF=3Dy becomes possible in a
released kernel.

> Right. Because this feature doesn't handle namespaces (only global
> CAP_NET_ADMIN), nested containers should not be allowed to use it at all.
> If we want this kind of feature to be usable by something other than a
> process with a global capability, then we need an inheritance mechanism
> similar to what I designed for Landlock. I think it could be added later.

I think it's okay to have a new kernel feature that doesn't support
namespacing yet.  I don't think it's okay to have a new kernel feature
that will become problematic when namespacing is added, and I think
cgroup-bpf is in the latter class.


Anyway, here's a half-baked proposal to clean this all up:

Make these new fiters actually be cgroup controllers. Fix whatever
needs to be fixed to make that work.  This will mean that they can't
be the "subtree-control" type of controllers.  (Maybe the same set of
fixes will help with the cpu controllers, too.)  Make them stack
properly.  Make them configurable using cgroupfs.

Add a "dangerous" flag on cgroups. Cgroups are "dangerous" if they
have dangerous controllers enabled. Controllers like "inet ingress"
are dangerous. You can only configure dangerous controllers if all
tasks in the cgroup have no_new_privs set and you have appropriate
permission over the tasks or if the cgroup is empty. If trying to bind
an inet ingress filter would make a cgroup dangerous and you don't
have the relevent privilege, then the operation fails. You cannot move
any task into a dangerous cgroup unless that task has no_new_privs set
*and* you have privilege over that task or if the task is in a
namespace that you have CAP_SYS_ADMIN on.  (This is kind of like your
proposal, and maybe they should be merged.  I do think that
*something* is needed and needs fleshing out.

Keep in mind, though, that strictly requiring no_new_privs is
excessive for namespaced applications.  It might be okay to require
that a cgroup only ever contain tasks in a given namespace or perhaps
that a cgroup only contain tasks that are either no_new_privs *or* are
in a given namespace or its descendents.  (In fact, unshare() can
*clear* no_new_privs because being in a fresh userns has more or less
the same effect.)

--Andy
