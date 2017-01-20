From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Thu, 19 Jan 2017 18:39:12 -0800
Message-ID: <20170120023907.GA3294@ast-mbp.thefacebook.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org>
 <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org>
 <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
In-Reply-To: <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 06:29:22PM -0800, Andy Lutomirski wrote:
> I think it could work by making a single socket cgroup controller that
> handles all cgroup things that are bound to a socket.  Using

Such 'socket cgroup controller' would limit usability of the feature
to sockets and force all other use cases like landlock to invent
their own wheel, which is undesirable. Everyone will be
inventing new 'foo cgroup controller', while all of them
are really bpf features. They are different bpf program
types that attach to different hooks and use cgroup for scoping.

> Having thought about this some more, I think that making it would
> alleviate a bunch of my concerns, as it would make the semantics if
> the capable() check were relaxed to ns_capable() be sane.  Here's what

here we're on the same page. For any meaningful discussion about
'bpf cgroup controller' to happen bpf itself needs to become
delegatable in cgroup sense. In other words BPF_PROG_TYPE_CGROUP*
program types need to become available for unprivileged users.
The only unprivileged prog type today is BPF_PROG_TYPE_SOCKET_FILTER.
To make it secure we severely limited its functionality.
All bpf advances since then (like new map types and verifier extensions)
were done for root only. If early on the priv vs unpriv bpf features
were 80/20. Now it's close to 95/5. No work has been done to
make socket filter type more powerful. It still has to use
slow-ish ld_abs skb access while tc/xdp have direct packet access.
Things like register value tracking is root only as well and so on
and so forth.
We cannot just flip the switch and allow type_cgroup* to unpriv
and I don't see any volunteers willing to do this work.
Until that happens there is no point coming up with designs
for 'cgroup bpf controller'... whatever that means.

> I currently should happen before bpf+cgroup is enabled in a release:
> 
> 1. Make it netns-aware.  This could be as simple as making it only
> work in the root netns because then real netns awareness can be added
> later without breaking anything.  The current situation is bad in that
> network namespaces are just ignored and it's plausible that people
> will start writing user code that depends on having network namespaces
> be ignored.

nothing in bpf today is netns-aware and frankly I don't see
how cgroup+bpf has anything to do with netns.
For regular sockets+bpf we don't check netns.
When tcpdump opens raw socket and attaches bpf there are no netns
checks, since socket itself gives a scope for the program to run.
Same thing applies to cgroup+bpf. cgroup gives a scope for the program.
But, say, we indeed add 'if !root ns' check to BPF_CGROUP_INET_*
hooks. Then if the hooks are used for security, the process
only needs to do setns() to escape security sandbox. Obviously
broken semantics.

> 2. Make it inherit properly.  Inner cgroups should not override outer
> hooks.  As in (1), this could be simplified by preventing the same
> hook from being configured in both an ancestor and a descendent
> cgroup.  Then inheritance could be added for real later on.

In general it sounds fine, but it seems the reasoning to add
such restriction now (instead of later), so that program chain can
be added without breaking abi, since if we don't restrict it now
there will be no way to add it without breaking abi?!
That is incorrect assumption. We can add chaining and can add
'do not override' logic without breaking existing semantics.
For example, we can add 'priority' field to
struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */}
which would indicate relative position of multiple chained programs
applied to the same cgroup+hook pair. Multiple programs with
the same priority will be executed in the order they were added.
Programs with different priorities will execute in the priority order.
Such scheme will be more generic and flexible than earlier proposals.
Similarly we can add another flag that will say 'dissallow override
of bpf program in descendent cgroup'. It's all trivial to do,
since bpf syscall was designed for extensibility.

Also until bpf_type_cgroup* becomes unprivileged there is no reason
to add this 'priority/prog chaining' feature, since if it's
used for security the root can always override it no matter cgroup
hierarchy.

> 3. Give cgroup delegation support some serious thought.  In
> particular, if delegation would be straightforward but the current API
> wouldn't work well with delegation, then at least consider whether the
> API should change before it becomes stable so that two APIs don't need
> to be supported going forward.

please see example above. Since we went with bpf syscall (instead of
inextensible ioctl) we can add any new cgroup+bpf logic without
breaking current abi.
No matter how you twist it the cgroup+bpf is bpf specific feature.
