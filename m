From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Sun, 28 Aug 2016 01:14:46 -0700
Message-ID: <CALCETrUsa0U-q0EZaKKzy9u3pTDVQsk==tn-9RpPwNaq1E5WYg@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net> <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net> <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <CALCETrVK1yQw=8ckLn3dcB4LuKft0NOrvQFoyFRs98ON00WgBw@mail.gmail.com> <20160827181153.GB38754@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160827181153.GB38754-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Aug 27, 2016 8:12 PM, "Alexei Starovoitov"
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> On Sat, Aug 27, 2016 at 12:30:36AM -0700, Andy Lutomirski wrote:
> > > cgroup is the common way to group multiple tasks.
> > > Without cgroup only parent<->child relationship will be possible,
> > > which will limit usability of such lsm to a master task that controls
> > > its children. Such api restriction would have been ok, if we could
> > > extend it in the future, but unfortunately task-centric won't allow it
> > > without creating a parallel lsm that is cgroup based.
> > > Therefore I think we have to go with cgroup-centric api and your
> > > application has to use cgroups from the start though only parent-child
> > > would have been enough.
> > > Also I don't think the kernel can afford two bpf based lsm. One task
> > > based and another cgroup based, so we have to find common ground
> > > that suits both use cases.
> > > Having unprivliged access is a subset. There is no strong reason why
> > > cgroup+lsm+bpf should be limited to root only always.
> > > When we can guarantee no pointer leaks, we can allow unpriv.
> >
> > I don't really understand what you mean.  In the context of landlock,
> > which is a *sandbox*, can one of you explain a use case that
> > materially benefits from this type of cgroup usage?  I haven't thought
> > of one.
>
> In case of seccomp-like sandbox where parent controls child processes
> cgroup is not needed. It's needed when container management software
> needs to control a set of applications. If we can have one bpf-based lsm
> that works via cgroup and without, I'd be fine with it. Right now
> I haven't seen a plausible proposal to do that. Therefore cgroup based
> api is a common api that works for sandbox as well, though requiring
> parent to create a cgroup just to control a single child is cumbersome.
>

I don't believe that a common API can work to accomplish your goal.
For privileged container management, the manager is trusted.  For
unprivileged sandboxing, the manager is emphatically not trusted,
which means you need special rules like NO_NEW_PRIVS, and, unless you
want to start restricting setuid and such in some cgroups, you really
do need a different interface for joining the sandbox than whatever
the container manager is using.

What could make sense is to have one BPF-based LSM that supports both
a seccomp-like unprivileged interface and a cgroup-based privileged
interface.  Most of the code for it is the BPF part anyway -- all that
the cgroup or seccomp part needs to do is to figure out which BPF
program(s) to call.

Also, for container management software, you don't really need
everything tied to cgroup -- you just need a way to cleanly add new
processes to the same security context.
