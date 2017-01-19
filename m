From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Wed, 18 Jan 2017 16:18:04 -0800
Message-ID: <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170118224120.GG9171-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 2:41 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Helloo, Andy.
>
> On Mon, Jan 16, 2017 at 09:18:36PM -0800, Andy Lutomirski wrote:
>> Perhaps this is a net feature, though, not a cgroup feature.  This
>> would IMO make a certain amount of sense.  Iptables cgroup matches,
>> for example, logically are an iptables (i.e., net) feature.  The
>
> Yeap.
>
>> problem here is that network configuration (and this explicitly
>> includes iptables) is done on a per-netns level, whereas these new
>> hooks entirely ignore network namespaces.  I've pointed out that
>> trying to enable them in a namespaced world is problematic (e.g.
>> switching to ns_capable() will cause serious problems), and Alexei
>> seems to think that this will never happen.  So I don't think we can
>> really call this a net feature that works the way that other net
>> features work.
>>
>> (Suppose that this actually tried to be netns-enabled.  Then you'd
>> have to map from (netns, cgroup) -> hook, and this would probably be
>> slow and messy.)
>
> I'm not sure how important netns support for these bpf programs
> actually is but I have no objection to making it behave in an
> equivalent manner to iptables where appropriate.  This is kinda
> trivial to do too.  For now, we can simply not run the programs if the
> associated socket belongs to non-root netns.  Later, if necessary, we
> can add per-ns bpf programs.  And I can't think of a reason why
> (netns, cgroup) -> function mapping would be slow and messy.  Why
> would that be?

To map cgroup -> hook, a simple array in each cgroup structure works.
To map (cgroup, netns) -> hook function, the natural approach would be
to have some kind of hash, and that would be slower.  This code is
intended to be *fast*.

I suppose you could have each cgroup structure contain an array where
each element is (netns, hook function) and just skip the ones that are
the wrong netns.  Perhaps it would be rare to have many of those.

>
>> So I think that leaves it being a cgroup feature.  And it definitely
>> does *not* play by the rules of cgroups right now.
>
> Because this in no way is a cgroup feature.  As you wrote above, it is
> something similar to iptables with lacking netns considerations.
> Let's address that and make it a proper network thing.

I think it's currently a broken cgroup feature.  I think it could be
made into a properly working cgroup feature (which I favor) or a
properly working net feature.  Can you articulate why you prefer
having it be a net feature instead of a cgroup feature?  I tend to
favor making it be a working cgroup feature (by giving it a file or
files in cgroupfs and maybe even a controller) because the result
would have very obvious semantics.

But maybe this is just a false dichotomy.  Could this feature be a
per-netns configuration where you can give instructions like "run this
hook if you're in such-and-such netns and in a given cgroup or one of
its descendents"?  This would prevent it from being a direct analogue
to systemd's RestrictAddressFamilies= option, but that may be okay.
This would side-step issues in the current code where a hook can't
rely on ifindex meaning what the hook thinks it means.

Actually, I think I like that approach.  What if it we had a "socket"
controller and files like "socket.create_socket", "socket.ingress" and
"socket.egress"?  You could use the bpf() syscall to install a bpf
filter into "socket.egress" and that filter would filter egress for
the target cgroup and its descendents on the current netns.  As a
first pass, the netns issue could be sidestepped by making it only
work in the root netns (i.e. the bpf() call would fail if you're not
in the root netns and the hooks wouldn't run if you're not in the root
netns.)  It *might* even be possible to retrofit in the socket
controller by saying that the default hierarchy is used if the socket
controller isn't mounted.

What *isn't* possible to cleanly fix after the fact is the current
semantics that cgroup hooks override the hooks in their ancestors.
IMO that is simply broken.  The example you gave (perf_event) is very
careful not to have this problem.

>
>> > I'm sure we'll
>> > eventually get there but from what I hear it isn't something we can
>> > pull off in a restricted timeframe.
>>
>> To me, this sounds like "the API isn't that great, we know how to do
>> better, but we really really want this feature ASAP so we want to ship
>> it with a sub-par API."  I think that's a bad idea.
>
> I see your point but this isn't something which is black and white.
> There are arguments for both directions.  I'm leaning the other
> direction because
>
> * My impression with bpf is that while delegation is something
>   theoretically possible it is not something which is gonna take place
>   in any immediate time frame.  If I'm wrong on this, please feel free
>   to correct me.

But the issue isn't *BPF* delegation.  It's cgroup delegation or netns
creation, both of which exist today.

>
> * There are a lot of use cases which can immediately take advantage of
>   cgroup-aware bpf programs operating as proposed.  The model is
>   semantically equivalent to iptables (let's address the netns part if
>   that's an issue) which net people are familiar with.

That sounds like a great argument for those users to patch their
kernels to gain experience with this feature.

>
> * It isn't exclusive with adding cgroup bpf controller down the road
>   if necessary and practical.  Sure, this isn't the perfect situation
>   but it seems like an acceptable trade-off to me.  What ever is
>   perfect?

I think it more or less is exclusive.  I can imagine davem accepting a
patch to make the sock_cgroup_data think point at a new "socket"
cgroup type.  I can't imagine him accepting a patch to have sockets
have more than one pointer to a cgroup, with good reason.

I don't see what's added by having a "bpf" cgroup controller, though
-- it's just too broad.  If the Landlock stuff goes in, that should
presumably be either tied to the default hierarchy or use an "lsm"
controller.  A "bpf" controller for that makes no sense to me.

I can see *huge* value in having some combination of BPF and the
perf_event controller deciding whether to log perf events, for
example.  But this would be the perf_event controller, not a
hypothetical "bpf" controller.

>
>> > This also holds true for the perf controller.  While it is implemented
>> > as a controller, it isn't visible to cgroup users in any way and the
>> > only function it serves is providing the membership test to perf
>> > subsystem.  perf is the one which decides whether and how it is to be
>> > used.  cgroup providing membership test to other subsystems is
>> > completely acceptable and established.
>>
>> Unless I'm mistaken, "perf_event" is an actual cgroup controller, and
>
> Yeah, it is implemented as a controller but in essence what it does is
> just tagging the hierarchy to tell perf to use that hierarchy for
> membership test purposes.

It's also a rather innocuous controller in that it doesn't change the
behavior of the controlled tasks.  The bpf hooks definitely do change
behavior.

>
>> it explicitly respects the cgroup hierarchy.  It shows up in
>> /proc/cgroups, and I had no problem mounting a cgroupfs instance with
>> perf_event enabled.  So I'm not sure what you mean.
>
> That all it's doing is providing membership information.

But it's doing it wrong!  Even perf_event tests for membership in a
given cgroup *or one of its descendents*.  This code does not.

I think the moral of the story here is that there are lots of open
questions and design work to be done and that this feature really
isn't ready to be stable.  For Landlock, I believe that it really
needs to be done right and I will put my foot down and NAK any effort
to have Landlock available in a released kernel without resolving
these types of issues first.  Does anyone really want Landlock to work
differently than the net hooks simply because the net hooks were in a
rush?

--Andy
