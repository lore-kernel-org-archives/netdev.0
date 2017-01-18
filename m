From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Wed, 18 Jan 2017 14:41:20 -0800
Message-ID: <20170118224120.GG9171@mtj.duckdns.org>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
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
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Helloo, Andy.

On Mon, Jan 16, 2017 at 09:18:36PM -0800, Andy Lutomirski wrote:
> Perhaps this is a net feature, though, not a cgroup feature.  This
> would IMO make a certain amount of sense.  Iptables cgroup matches,
> for example, logically are an iptables (i.e., net) feature.  The

Yeap.

> problem here is that network configuration (and this explicitly
> includes iptables) is done on a per-netns level, whereas these new
> hooks entirely ignore network namespaces.  I've pointed out that
> trying to enable them in a namespaced world is problematic (e.g.
> switching to ns_capable() will cause serious problems), and Alexei
> seems to think that this will never happen.  So I don't think we can
> really call this a net feature that works the way that other net
> features work.
> 
> (Suppose that this actually tried to be netns-enabled.  Then you'd
> have to map from (netns, cgroup) -> hook, and this would probably be
> slow and messy.)

I'm not sure how important netns support for these bpf programs
actually is but I have no objection to making it behave in an
equivalent manner to iptables where appropriate.  This is kinda
trivial to do too.  For now, we can simply not run the programs if the
associated socket belongs to non-root netns.  Later, if necessary, we
can add per-ns bpf programs.  And I can't think of a reason why
(netns, cgroup) -> function mapping would be slow and messy.  Why
would that be?

> So I think that leaves it being a cgroup feature.  And it definitely
> does *not* play by the rules of cgroups right now.

Because this in no way is a cgroup feature.  As you wrote above, it is
something similar to iptables with lacking netns considerations.
Let's address that and make it a proper network thing.

> > I'm sure we'll
> > eventually get there but from what I hear it isn't something we can
> > pull off in a restricted timeframe.
> 
> To me, this sounds like "the API isn't that great, we know how to do
> better, but we really really want this feature ASAP so we want to ship
> it with a sub-par API."  I think that's a bad idea.

I see your point but this isn't something which is black and white.
There are arguments for both directions.  I'm leaning the other
direction because

* My impression with bpf is that while delegation is something
  theoretically possible it is not something which is gonna take place
  in any immediate time frame.  If I'm wrong on this, please feel free
  to correct me.

* There are a lot of use cases which can immediately take advantage of
  cgroup-aware bpf programs operating as proposed.  The model is
  semantically equivalent to iptables (let's address the netns part if
  that's an issue) which net people are familiar with.

* It isn't exclusive with adding cgroup bpf controller down the road
  if necessary and practical.  Sure, this isn't the perfect situation
  but it seems like an acceptable trade-off to me.  What ever is
  perfect?

> > This also holds true for the perf controller.  While it is implemented
> > as a controller, it isn't visible to cgroup users in any way and the
> > only function it serves is providing the membership test to perf
> > subsystem.  perf is the one which decides whether and how it is to be
> > used.  cgroup providing membership test to other subsystems is
> > completely acceptable and established.
> 
> Unless I'm mistaken, "perf_event" is an actual cgroup controller, and

Yeah, it is implemented as a controller but in essence what it does is
just tagging the hierarchy to tell perf to use that hierarchy for
membership test purposes.

> it explicitly respects the cgroup hierarchy.  It shows up in
> /proc/cgroups, and I had no problem mounting a cgroupfs instance with
> perf_event enabled.  So I'm not sure what you mean.

That all it's doing is providing membership information.

Thanks.

-- 
tejun
