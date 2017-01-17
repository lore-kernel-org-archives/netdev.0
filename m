From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 17 Jan 2017 12:23:37 -0800
Message-ID: <CALCETrWPTVM6HGMoPh3G=J5K20DxwddLNVS3C6xyypCt9e-XWg@mail.gmail.com>
References: <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com> <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net> <20170103102559.GA30129@dhcp22.suse.cz>
 <20170116011901.GH14446@mtj.duckdns.org> <20170117130303.GL19699@dhcp22.suse.cz>
 <20170117133204.GA6515@twins.programming.kicks-ass.net> <20170117135830.GO19699@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170117135830.GO19699-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 5:58 AM, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Tue 17-01-17 14:32:04, Peter Zijlstra wrote:
>> On Tue, Jan 17, 2017 at 02:03:03PM +0100, Michal Hocko wrote:
>> > On Sun 15-01-17 20:19:01, Tejun Heo wrote:
>> > [...]
>> > > So, what's proposed is a proper part of bpf.  In terms of
>> > > implementation, cgroup helps by hosting the pointers but that doesn't
>> > > necessarily affect the conceptual structure of it.  Given that, I
>> > > don't think it'd be a good idea to add anything to cgroup interface
>> > > for this feature.  Introspection is great to have but this should be
>> > > introspectable together with other bpf programs using the same
>> > > mechanism.  That's where it belongs.
>> >
>> > If BPF only piggy backs on top of cgroup to iterate tasks shouldn't we
>> > at least enforce that the cgroup has to be a leaf one and no further
>> > children groups can be created once there is BPF program attached?
>>
>> Why (again) this stupid constraint?
>>
>> If you want to use cgroups for tagging (like perf does), _any_ parent
>> cgroup will also tag you.
>>
>> So creating child cgroups, and placing tasks in it, should not be a
>> problem, the BPF thing should apply to all of them.
>
> This would require using hierarchical cgroup iterators to iterate over
> tasks. As per Andy's testing this doesn't seem to be the case. I haven't
> checked the implementation closely but my understanding was that using
> only cgroup specific tasks was intentional.

The current semantics are AFAIK that only the innermost cgroup that
has a hook installed is in effect.  I think this is the wrong design.

I think that the right semantics are probably to support both
innermost-to-outermost and outermost-to-innermost and to select which
is appropriate for each hook.  Suppose we have a cgroup /a/b where a
and b both have hooks installed.  If the hook is a socket creation or
egress hook, I think that b's hook should run first.  If b's hook
rejects, then a's hook is not run.  If b's hook accepts, then a's hook
is run.  This way a gets the last word on any changes to the socket
settings and a sees exactly what would happen if it were to accept.

Conversely, for ingress hooks, I think that a's hook should run first.
This way a sees the packet as it originally came in and can modify or
reject it, and then b only sees whatever a chooses to let through.

The guiding principle here is that, for actions that originate outside
the machine, the outer hooks should IMO run first and, for actions
that originate from a task in a cgroup, the innermost hooks should run
first.

--Andy
