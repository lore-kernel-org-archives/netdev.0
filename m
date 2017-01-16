From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Sun, 15 Jan 2017 20:19:01 -0500
Message-ID: <20170116011901.GH14446@mtj.duckdns.org>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <2dbec775-6304-e44c-19c5-fbf07877e7b1@gmail.com>
 <CALCETrUW2jEYmjSsOrPj+MAjkDGGUCw_rdxQh+5Er0r4ReGLnA@mail.gmail.com>
 <20161220091150.GJ3124@twins.programming.kicks-ass.net>
 <20170103102559.GA30129@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170103102559.GA30129-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

Sorry about the delay.  Some fire fighthing followed the holidays.

On Tue, Jan 03, 2017 at 11:25:59AM +0100, Michal Hocko wrote:
> > So from what I understand the proposed cgroup is not in fact
> > hierarchical at all.
> > 
> > @TJ, I thought you were enforcing all new cgroups to be properly
> > hierarchical, that would very much include this one.
> 
> I would be interested in that as well. We have made that mistake in
> memcg v1 where hierarchy could be disabled for performance reasons and
> that turned out to be major PITA in the end. Why do we want to repeat
> the same mistake here?

Across the different threads on this subject, there have been multiple
explanations but I'll try to sum it up more clearly.

The big issue here is whether this is a cgroup thing or a bpf thing.
I don't think there's anything inherently wrong with one approach or
the other.  Forget about the proposed cgroup bpf extentions but thinkg
about how iptables does cgroups.  Whether it's the netcls/netprio in
v1 or direct membership matching in v2, it is the network side testing
for cgroup membership one way or the other.  The only part where
cgroup is involved in is answering that test.

This also holds true for the perf controller.  While it is implemented
as a controller, it isn't visible to cgroup users in any way and the
only function it serves is providing the membership test to perf
subsystem.  perf is the one which decides whether and how it is to be
used.  cgroup providing membership test to other subsystems is
completely acceptable and established.

Now coming back to bpf, the current implementation is just that.
Sure, cgroup hosts the rules in its data structures but that isn't
something conceptually relevant.  We might as well implement it as a
prefixed hash table from bpf side.  Having pointers in struct cgroup
is just a more efficient and easier way of achieving the same result.
In fact, IIUC, this whole thing was born out of discussions around
implementing scalable cgroup membership matching from bpf programs.

So, what's proposed is a proper part of bpf.  In terms of
implementation, cgroup helps by hosting the pointers but that doesn't
necessarily affect the conceptual structure of it.  Given that, I
don't think it'd be a good idea to add anything to cgroup interface
for this feature.  Introspection is great to have but this should be
introspectable together with other bpf programs using the same
mechanism.  That's where it belongs.

None of the issues that people have been raising here is actually an
issue if one thinks of it as a part of bpf.  Its security model is
exactly the same as any other bpf programs.  Recursive behavior is
exactly the same as how other external cgroup descendant membership
testing work.  There is no issue here whatsoever.

Now, I'm not claiming that a bpf mechanism which is a proper part of
cgrou isn't attractive.  It is, especially with delegation; however,
that is also where we don't quite know how to proceed.  This doesn't
have much to do with cgroup.  If something is delegatable to non-priv
users and scoped, cgroup's fine with it and if that's not possible it
simply isn't something which is delegatable and putting it on cgroup
doesn't change that.

I'm far from being a bpf expert, so I could be wrong here, but I don't
think there's anything fundamental which prevents bpf from being
delegatable but at the same time bpf is something which is extremely
flexible and nobody really thought about or worked that much on
delegating bpf. If there's enough need for it, I'm sure we'll
eventually get there but from what I hear it isn't something we can
pull off in a restricted timeframe.

There's nothing which makes the currently implemented mechanism
exclusive with a cgroup controller based one.  The hooks are the
expensive part but can be shared, the rest is just about which
programs to execute in what order and how they should be chained.

There are a lot of immediate use cases which can benefit from the
proposed cgroup bpf mechanism and they're all fine with it being a
part of bpf and behaving like any other network mechanism behaves in
terms of configuration and delegation.  I don't see a reason why we
would hold back on merging this.  All the raised issues are coming
from confusing this as a part of cgroup.  It isn't.  It is a part of
bpf.  If we want a bpf cgroup controller, great, but that is a
separate thing.

Thanks.

-- 
tejun
