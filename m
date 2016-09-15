From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 18:25:07 -0700
Message-ID: <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com> <57D9CB25.1010103@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Linux API <linu
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57D9CB25.1010103-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 3:11 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
>
> On 14/09/2016 20:27, Andy Lutomirski wrote:
>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>> Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initiall=
y
>>> set for all cgroup except the root. The flag is clear when a new proces=
s
>>> without the no_new_privs flags is attached to the cgroup.
>>>
>>> If a cgroup is landlocked, then any new attempt, from an unprivileged
>>> process, to attach a process without no_new_privs to this cgroup will
>>> be denied.
>>
>> Until and unless everyone can agree on a way to properly namespace,
>> delegate, etc cgroups, I think that trying to add unprivileged
>> semantics to cgroups is nuts.  Given the big thread about cgroup v2,
>> no-internal-tasks, etc, I just don't see how this approach can be
>> viable.
>
> As far as I can tell, the no_new_privs flag of at task is not related to
> namespaces. The CGRP_NO_NEW_PRIVS flag is only a cache to quickly access
> the no_new_privs property of *tasks* in a cgroup. The semantic is unchang=
ed.
>
> Using cgroup is optional, any task could use the seccomp-based
> landlocking instead. However, for those that want/need to manage a
> security policy in a more dynamic way, using cgroups may make sense.
>
> I though cgroup delegation was OK in the v2, isn't it the case? Do you
> have some links?
>
>>
>> Can we try to make landlock work completely independently of cgroups
>> so that it doesn't get stuck and so that programs can use it without
>> worrying about cgroup v1 vs v2, interactions with cgroup managers,
>> cgroup managers that (supposedly?) will start migrating processes
>> around piecemeal and almost certainly blowing up landlock in the
>> process, etc?
>
> This RFC handle both cgroup and seccomp approaches in a similar way. I
> don't see why building on top of cgroup v2 is a problem. Is there
> security issues with delegation?

What I mean is: cgroup v2 delegation has a functionality problem.
Tejun says [1]:

We haven't had to face this decision because cgroup has never properly
supported delegating to applications and the in-use setups where this
happens are custom configurations where there is no boundary between
system and applications and adhoc trial-and-error is good enough a way
to find a working solution.  That wiggle room goes away once we
officially open this up to individual applications.

Unless and until that changes, I think that landlock should stay away
from cgroups.  Others could reasonably disagree with me.


[1] https://lkml.kernel.org/g/<20160909225747.GA30105-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org
