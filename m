From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 20:29:17 -0700
Message-ID: <CALCETrUeRH6bpY_7WQh_SKiURPEExtw67+Mj26u4aveV9EgWxA@mail.gmail.com>
References: <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net> <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net> <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
 <57C5EAA3.5090901@digikod.net> <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
 <57C5ED9B.3040303@digikod.net> <20160830205552.GB71063@ast-mbp.thefacebook.com>
 <CALCETrX6hPFZwdnypkPA0p9VjdcK=ZFYpR8zXpzOYS6f=fx3_g@mail.gmail.com> <20160831013605.GB75654@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160831013605.GB75654-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 30, 2016 at 6:36 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Aug 30, 2016 at 02:45:14PM -0700, Andy Lutomirski wrote:
>>
>> One might argue that landlock shouldn't be tied to seccomp (in theory,
>> attached progs could be given access to syscall_get_xyz()), but I
>
> proposed lsm is way more powerful than syscall_get_xyz.
> no need to dumb it down.

I think you're misunderstanding me.

Micka=C3=ABl's code allows one to make the LSM hook filters depend on the
syscall using SECCOMP_RET_LANDLOCK.  I'm suggesting that a similar
effect could be achieved by allowing the eBPF LSM hook to call
syscall_get_xyz() if it wants to.

>
>> think that the seccomp attachment mechanism is the right way to
>> install unprivileged filters.  It handles the no_new_privs stuff, it
>> allows TSYNC, it's totally independent of systemwide policy, etc.
>>
>> Trying to use cgroups or similar for this is going to be much nastier.
>> Some tighter sandboxes (Sandstorm, etc) aren't even going to dream of
>> putting cgroupfs in their containers, so requiring cgroups or similar
>> would be a mess for that type of application.
>
> I don't see why it is a 'mess'. cgroups are already used by majority
> of the systems, so I don't see why requiring a cgroup is such a big deal.

Requiring cgroup to be configured in isn't a big deal.  Requiring

> But let's say we don't do them. How implementation is going to look like
> for task based hierarchy? Note that we need an array of bpf_prog pointers=
.
> One for each lsm hook. Where this array is going to be stored?
> We cannot put in task_struct, since it's too large. Cannot put it
> into 'struct seccomp' directly either, unless it will become a pointer.
> Is that the proposal?

It would go in struct seccomp_filter or in something pointed to from there.

> So now we will be wasting extra 1kbyte of memory per task. Not great.
> We'd want to optimize it by sharing this such struct seccomp with prog ar=
ray
> across threads of the same task? Or dynimically allocating it when
> landlock is in use? May sound nice, but how to account for that kernel
> memory? I guess also solvable by charging memlock.
> With cgroup based approach we don't need to worry about all that.
>

The considerations are essentially identical either way.

With cgroups, if you want to share the memory between multiple
separate sandboxes (Firejail instances, Sandstorm grains, Chromium
instances, xdg-apps, etc), you'd need to get them to all coordinate to
share a cgroup.  With a seccomp-like interface, you'd need to get them
to coordinate to share an installed layer (using my FD idea or
similar).

There would *not* be any duplication of this memory just because a
sandboxed process called fork().

--Andy

--=20
Andy Lutomirski
AMA Capital Management, LLC
