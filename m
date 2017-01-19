From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Wed, 18 Jan 2017 16:59:25 -0800
Message-ID: <20170119005925.GA18554@mtj.duckdns.org>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org>
 <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
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
In-Reply-To: <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Andy.

On Wed, Jan 18, 2017 at 04:18:04PM -0800, Andy Lutomirski wrote:
> To map cgroup -> hook, a simple array in each cgroup structure works.
> To map (cgroup, netns) -> hook function, the natural approach would be
> to have some kind of hash, and that would be slower.  This code is
> intended to be *fast*.

Updating these programs isn't a frequent operation.  We can easily
calculate a perfect (or acceptable) hash per-cgroup and rcu swap the
new hashtable.

> I suppose you could have each cgroup structure contain an array where
> each element is (netns, hook function) and just skip the ones that are
> the wrong netns.  Perhaps it would be rare to have many of those.

Yeah, or maybe even that.  It just isn't a fundamentally difficult
problem.

> I think it's currently a broken cgroup feature.  I think it could be
> made into a properly working cgroup feature (which I favor) or a
> properly working net feature.  Can you articulate why you prefer
> having it be a net feature instead of a cgroup feature?  I tend to

I thought that's what I was doing in the previous message.

> favor making it be a working cgroup feature (by giving it a file or
> files in cgroupfs and maybe even a controller) because the result
> would have very obvious semantics.

I'm fine with both directions but one seems far out.

> But maybe this is just a false dichotomy.  Could this feature be a
> per-netns configuration where you can give instructions like "run this
> hook if you're in such-and-such netns and in a given cgroup or one of
> its descendents"?  This would prevent it from being a direct analogue
> to systemd's RestrictAddressFamilies= option, but that may be okay.
> This would side-step issues in the current code where a hook can't
> rely on ifindex meaning what the hook thinks it means.

How is this different from making the current code netns aware?

> Actually, I think I like that approach.  What if it we had a "socket"
> controller and files like "socket.create_socket", "socket.ingress" and
> "socket.egress"?  You could use the bpf() syscall to install a bpf
> filter into "socket.egress" and that filter would filter egress for
> the target cgroup and its descendents on the current netns.  As a
> first pass, the netns issue could be sidestepped by making it only
> work in the root netns (i.e. the bpf() call would fail if you're not
> in the root netns and the hooks wouldn't run if you're not in the root
> netns.)  It *might* even be possible to retrofit in the socket
> controller by saying that the default hierarchy is used if the socket
> controller isn't mounted.

I don't know.  You're throwing out too many ideas too fast and it's
difficult to keep up with what the differences are between those
ideas.  But if we're doing cgroup controllers, shouldn't cgroup ns
support be sufficient?  We can consider the product of cgroup and net
namespaces but that doesn't seem necessary given that people usually
set up these namespaces in conjunction.

> What *isn't* possible to cleanly fix after the fact is the current
> semantics that cgroup hooks override the hooks in their ancestors.
> IMO that is simply broken.  The example you gave (perf_event) is very
> careful not to have this problem.

That's like saying installing an iptables rule for a more specific
target is broken.  As a cgroup controller, it is not an acceptable
behavior given how delegation works.  As something similar to
iptables, it is completely fine.

> > * My impression with bpf is that while delegation is something
> >   theoretically possible it is not something which is gonna take place
> >   in any immediate time frame.  If I'm wrong on this, please feel free
> >   to correct me.
> 
> But the issue isn't *BPF* delegation.  It's cgroup delegation or netns
> creation, both of which exist today.

No, the issue is bpf delegation.  If bpf were fully delegatable in
practical sense, we could just do straight forward cgroup bpf
controller.  Well, we'll have to think about how to chain the programs
which would differ on program type but that shouldn't be too hard.

> > * There are a lot of use cases which can immediately take advantage of
> >   cgroup-aware bpf programs operating as proposed.  The model is
> >   semantically equivalent to iptables (let's address the netns part if
> >   that's an issue) which net people are familiar with.
> 
> That sounds like a great argument for those users to patch their
> kernels to gain experience with this feature.

I don't get why this would particularly point to out-of-tree usage.
Why is that?

> > * It isn't exclusive with adding cgroup bpf controller down the road
> >   if necessary and practical.  Sure, this isn't the perfect situation
> >   but it seems like an acceptable trade-off to me.  What ever is
> >   perfect?
> 
> I think it more or less is exclusive.  I can imagine davem accepting a
> patch to make the sock_cgroup_data think point at a new "socket"
> cgroup type.  I can't imagine him accepting a patch to have sockets
> have more than one pointer to a cgroup, with good reason.

Why would it ever need multiple pointers?  Socket is associated with
one cgroup whether it's this or controller thing.  Membership part
doesn't change.  It can share everything.

> I don't see what's added by having a "bpf" cgroup controller, though
> -- it's just too broad.  If the Landlock stuff goes in, that should
> presumably be either tied to the default hierarchy or use an "lsm"
> controller.  A "bpf" controller for that makes no sense to me.
>
> I can see *huge* value in having some combination of BPF and the
> perf_event controller deciding whether to log perf events, for
> example.  But this would be the perf_event controller, not a
> hypothetical "bpf" controller.

Let's not spiral out.  This isn't relevant to the discussion.  Call it
whatever you want.

> But it's doing it wrong!  Even perf_event tests for membership in a
> given cgroup *or one of its descendents*.  This code does not.
> 
> I think the moral of the story here is that there are lots of open
> questions and design work to be done and that this feature really
> isn't ready to be stable.  For Landlock, I believe that it really
> needs to be done right and I will put my foot down and NAK any effort
> to have Landlock available in a released kernel without resolving
> these types of issues first.  Does anyone really want Landlock to work
> differently than the net hooks simply because the net hooks were in a
> rush?

No idea about landlock but as for the cgroup aware network bpf
programs, let's please try to narrow down the arguments.  Here's one
question.

* If we make the current thing netns aware, how is it different from
  iptables?  Note that at least future-proofing for netns is trivial.
  We can simply skip running the bpf programs for non-root ns for now.

If the answer is "they aren't that different", is the reason that
you're against the current code because you think that it being a part
of cgroup would be more useful?  I'm not necessarily against that
point, I just think that this is a reasonable trade-off given the
circumstances especially given that this doens't block having the
cgroup things in the future.

I'd really appreciate some inputs from bpf folks.  I'm basing my
judgement primarily on the impression that it is very difficult to
make bpf programs practically delegatable.  If that's not the case, we
can easily go the cgroup controller route.

Thanks.

-- 
tejun
