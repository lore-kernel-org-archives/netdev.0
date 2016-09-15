From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 21:38:16 -0700
Message-ID: <CALCETrU=tGLx8s_eqji6SfXRi=3W8FkGC7wA6VMfD-_wAVb66w@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net> <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com> <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
 <20160915040054.GA65308@ast-mbp.thefacebook.com> <CALCETrXTS8R1E2b9mmWzpOO6QOW5nWYW_RQRJYU1CGRsbNy+Yw@mail.gmail.com>
 <20160915043120.GA65819@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160915043120.GA65819-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 9:31 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Sep 14, 2016 at 09:08:57PM -0700, Andy Lutomirski wrote:
>> On Wed, Sep 14, 2016 at 9:00 PM, Alexei Starovoitov
>> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On Wed, Sep 14, 2016 at 07:27:08PM -0700, Andy Lutomirski wrote:
>> >> >> >
>> >> >> > This RFC handle both cgroup and seccomp approaches in a similar way. I
>> >> >> > don't see why building on top of cgroup v2 is a problem. Is there
>> >> >> > security issues with delegation?
>> >> >>
>> >> >> What I mean is: cgroup v2 delegation has a functionality problem.
>> >> >> Tejun says [1]:
>> >> >>
>> >> >> We haven't had to face this decision because cgroup has never properly
>> >> >> supported delegating to applications and the in-use setups where this
>> >> >> happens are custom configurations where there is no boundary between
>> >> >> system and applications and adhoc trial-and-error is good enough a way
>> >> >> to find a working solution.  That wiggle room goes away once we
>> >> >> officially open this up to individual applications.
>> >> >>
>> >> >> Unless and until that changes, I think that landlock should stay away
>> >> >> from cgroups.  Others could reasonably disagree with me.
>> >> >
>> >> > Ours and Sargun's use cases for cgroup+lsm+bpf is not for security
>> >> > and not for sandboxing. So the above doesn't matter in such contexts.
>> >> > lsm hooks + cgroups provide convenient scope and existing entry points.
>> >> > Please see checmate examples how it's used.
>> >> >
>> >>
>> >> To be clear: I'm not arguing at all that there shouldn't be
>> >> bpf+lsm+cgroup integration.  I'm arguing that the unprivileged
>> >> landlock interface shouldn't expose any cgroup integration, at least
>> >> until the cgroup situation settles down a lot.
>> >
>> > ahh. yes. we're perfectly in agreement here.
>> > I'm suggesting that the next RFC shouldn't include unpriv
>> > and seccomp at all. Once bpf+lsm+cgroup is merged, we can
>> > argue about unpriv with cgroups and even unpriv as a whole,
>> > since it's not a given. Seccomp integration is also questionable.
>> > I'd rather not have seccomp as a gate keeper for this lsm.
>> > lsm and seccomp are orthogonal hook points. Syscalls and lsm hooks
>> > don't have one to one relationship, so mixing them up is only
>> > asking for trouble further down the road.
>> > If we really need to carry some information from seccomp to lsm+bpf,
>> > it's easier to add eBPF support to seccomp and let bpf side deal
>> > with passing whatever information.
>> >
>>
>> As an argument for keeping seccomp (or an extended seccomp) as the
>> interface for an unprivileged bpf+lsm: seccomp already checks off most
>> of the boxes for safely letting unprivileged programs sandbox
>> themselves.
>
> you mean the attach part of seccomp syscall that deals with no_new_priv?
> sure, that's reusable.
>
>> Furthermore, to the extent that there are use cases for
>> unprivileged bpf+lsm that *aren't* expressible within the seccomp
>> hierarchy, I suspect that syscall filters have exactly the same
>> problem and that we should fix seccomp to cover it.
>
> not sure what you mean by 'seccomp hierarchy'. The normal process
> hierarchy ?

Kind of.  I mean the filter layers that are inherited across fork(),
the TSYNC mechanism, etc.

> imo the main deficiency of secccomp is inability to look into arguments.
> One can argue that it's a blessing, since composite args
> are not yet copied into the kernel memory.
> But in a lot of cases the seccomp arguments are FDs pointing
> to kernel objects and if programs could examine those objects
> the sandboxing scope would be more precise.
> lsm+bpf solves that part and I'd still argue that it's
> orthogonal to seccomp's pass/reject flow.
> I mean if seccomp says 'ok' the syscall should continue executing
> as normal and whatever LSM hooks were triggered by it may have
> their own lsm+bpf verdicts.

I agree with all of this...

> Furthermore in the process hierarchy different children
> should be able to set their own lsm+bpf filters that are not
> related to parallel seccomp+bpf hierarchy of programs.
> seccomp syscall can be an interface to attach programs
> to lsm hooks, but nothing more than that.

I'm not sure what you mean.  I mean that, logically, I think we should
be able to do:

seccomp(attach a syscall filter);
fork();
child does seccomp(attach some lsm filters);

I think that they *should* be related to the seccomp+bpf hierarchy of
programs in that they are entries in the same logical list of filter
layers installed.  Some of those layers can be syscall filters and
some of the layers can be lsm filters.  If we subsequently add a way
to attach a removable seccomp filter or a way to attach a seccomp
filter that logs failures to some fd watched by an outside monitor, I
think that should work for lsm, too, with more or less the same
interface.

If we need a way for a sandbox manager to opt different children into
different subsets of fancy filters, then I think that syscall filters
and lsm filters should use the same mechanism.

I think we might be on the same page here and just saying it different ways.
