From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Thu, 19 Jan 2017 20:04:59 -0800
Message-ID: <CALCETrV6NArtFa89iW+QO3udxpJYpMXLbOEk6ZYyWsw7oZDS2Q@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org> <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org> <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
 <20170120023907.GA3294@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        David Ahern <dsahern@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Mack <daniel@zonque.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:36310 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdATENY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 23:13:24 -0500
Received: by mail-ua0-f179.google.com with SMTP id 96so52146987uaq.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 20:13:23 -0800 (PST)
In-Reply-To: <20170120023907.GA3294@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 6:39 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Jan 18, 2017 at 06:29:22PM -0800, Andy Lutomirski wrote:
>> I think it could work by making a single socket cgroup controller that
>> handles all cgroup things that are bound to a socket.  Using
>
> Such 'socket cgroup controller' would limit usability of the feature
> to sockets and force all other use cases like landlock to invent
> their own wheel, which is undesirable. Everyone will be
> inventing new 'foo cgroup controller', while all of them
> are really bpf features. They are different bpf program
> types that attach to different hooks and use cgroup for scoping.

Can you elaborate on why that would be a problem?  In a cgroup v1
world, users who want different hierarchies for different types of
control could easily want one hierarchy for socket hooks and a
different hierarchy for lsm hooks.  In a cgroup v2 delegation world, I
could easily imagine the decision to delegate socket hooks being
different from the decision to delegate lsm hooks.  Almost all of the
code would be shared between different bpf-using cgroup controllers.

>
>> Having thought about this some more, I think that making it would
>> alleviate a bunch of my concerns, as it would make the semantics if
>> the capable() check were relaxed to ns_capable() be sane.  Here's what
>
> here we're on the same page. For any meaningful discussion about
> 'bpf cgroup controller' to happen bpf itself needs to become
> delegatable in cgroup sense. In other words BPF_PROG_TYPE_CGROUP*
> program types need to become available for unprivileged users.
> The only unprivileged prog type today is BPF_PROG_TYPE_SOCKET_FILTER.
> To make it secure we severely limited its functionality.
> All bpf advances since then (like new map types and verifier extensions)
> were done for root only. If early on the priv vs unpriv bpf features
> were 80/20. Now it's close to 95/5. No work has been done to
> make socket filter type more powerful. It still has to use
> slow-ish ld_abs skb access while tc/xdp have direct packet access.
> Things like register value tracking is root only as well and so on
> and so forth.
> We cannot just flip the switch and allow type_cgroup* to unpriv
> and I don't see any volunteers willing to do this work.
> Until that happens there is no point coming up with designs
> for 'cgroup bpf controller'... whatever that means.

Sure there is.  If delegation can be turned on without changing the
API, then the result will be easier to work with and have fewer
compatibility issues.

>
>> I currently should happen before bpf+cgroup is enabled in a release:
>>
>> 1. Make it netns-aware.  This could be as simple as making it only
>> work in the root netns because then real netns awareness can be added
>> later without breaking anything.  The current situation is bad in that
>> network namespaces are just ignored and it's plausible that people
>> will start writing user code that depends on having network namespaces
>> be ignored.
>
> nothing in bpf today is netns-aware and frankly I don't see
> how cgroup+bpf has anything to do with netns.
> For regular sockets+bpf we don't check netns.
> When tcpdump opens raw socket and attaches bpf there are no netns
> checks, since socket itself gives a scope for the program to run.
> Same thing applies to cgroup+bpf. cgroup gives a scope for the program.
> But, say, we indeed add 'if !root ns' check to BPF_CGROUP_INET_*
> hooks.


Here I completely disagree with you.  tcpdump sees packets in its
network namespace.  Regular sockets apply bpf filters to the packets
seen by that socket, and the socket itself is scoped to a netns.

Meanwhile, cgroup+bpf actually appears to be buggy in this regard even
regardless of what semantics you think are better.  sk_bound_dev_if is
exposed as a u32 value, but sk_bound_dev_if only has meaning within a
given netns.  The "ip vrf" stuff will straight-up malfunction if a
process affected by its hook runs in a different netns from the netns
that "ip vrf" was run in.

IOW, the current code is buggy.

> Then if the hooks are used for security, the process
> only needs to do setns() to escape security sandbox. Obviously
> broken semantics.

This could go both ways.  If the goal is to filter packets, then it's
not really important to have the filter keep working if the sandboxed
task unshares netns -- in the new netns, there isn't any access to the
network at all.  If the goal is to reduce attack surface by
restricting the types of sockets that can be created, then you do want
the filter to work across namespaces, but seccomp can do that too and
the current code doesn't handle netns correctly.

>
>> 2. Make it inherit properly.  Inner cgroups should not override outer
>> hooks.  As in (1), this could be simplified by preventing the same
>> hook from being configured in both an ancestor and a descendent
>> cgroup.  Then inheritance could be added for real later on.
>
> In general it sounds fine, but it seems the reasoning to add
> such restriction now (instead of later), so that program chain can
> be added without breaking abi, since if we don't restrict it now
> there will be no way to add it without breaking abi?!

Adding it the straightforward way (by simply making all the hooks in
scope run) would break ABI.  Of course there are more complicated ways
to do it, but those are more complicated and messier.  Do actually
have a use case in which overriding of hooks is a good thing?  As far
as I can tell, the original version of the patch set didn't have hooks
get overridden by descendents, and I don't know why this changed in
the first place.

>
> Also until bpf_type_cgroup* becomes unprivileged there is no reason
> to add this 'priority/prog chaining' feature, since if it's
> used for security the root can always override it no matter cgroup
> hierarchy.
>
>> 3. Give cgroup delegation support some serious thought.  In
>> particular, if delegation would be straightforward but the current API
>> wouldn't work well with delegation, then at least consider whether the
>> API should change before it becomes stable so that two APIs don't need
>> to be supported going forward.
>
> please see example above. Since we went with bpf syscall (instead of
> inextensible ioctl) we can add any new cgroup+bpf logic without
> breaking current abi.

But then you end up with two ABIs.  Ideally delegation would just work
-- then programs written now could run unmodified in unprivileged
containers in future kernels.

--Andy
