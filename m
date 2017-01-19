From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Wed, 18 Jan 2017 18:29:22 -0800
Message-ID: <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org> <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Hocko <mhocko@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        David Ahern <dsahern@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
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
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119005925.GA18554@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2017 at 4:59 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Andy.
>
> On Wed, Jan 18, 2017 at 04:18:04PM -0800, Andy Lutomirski wrote:
>> To map cgroup -> hook, a simple array in each cgroup structure works.
>> To map (cgroup, netns) -> hook function, the natural approach would be
>> to have some kind of hash, and that would be slower.  This code is
>> intended to be *fast*.
>
> Updating these programs isn't a frequent operation.  We can easily
> calculate a perfect (or acceptable) hash per-cgroup and rcu swap the
> new hashtable.
>

Fair enough.

>
>> I think it's currently a broken cgroup feature.  I think it could be
>> made into a properly working cgroup feature (which I favor) or a
>> properly working net feature.  Can you articulate why you prefer
>> having it be a net feature instead of a cgroup feature?  I tend to
>
> I thought that's what I was doing in the previous message.
>
>> favor making it be a working cgroup feature (by giving it a file or
>> files in cgroupfs and maybe even a controller) because the result
>> would have very obvious semantics.
>
> I'm fine with both directions but one seems far out.

I thought you were saying why you thought it wasn't a cgroup feature,
but I'm not sure I understand why you thought it shouldn't be a cgroup
feature.

When I chatted with Alexei, I had the impression that you and he had
wanted it to be a cgroup controller but thought it wouldn't work well.
I think it could work by making a single socket cgroup controller that
handles all cgroup things that are bound to a socket.  Using
individual files would play nicer with cgroup delegation within a
single netns.

>
>> But maybe this is just a false dichotomy.  Could this feature be a
>> per-netns configuration where you can give instructions like "run this
>> hook if you're in such-and-such netns and in a given cgroup or one of
>> its descendents"?  This would prevent it from being a direct analogue
>> to systemd's RestrictAddressFamilies= option, but that may be okay.
>> This would side-step issues in the current code where a hook can't
>> rely on ifindex meaning what the hook thinks it means.
>
> How is this different from making the current code netns aware?

The descendents part is important.

>
>> Actually, I think I like that approach.  What if it we had a "socket"
>> controller and files like "socket.create_socket", "socket.ingress" and
>> "socket.egress"?  You could use the bpf() syscall to install a bpf
>> filter into "socket.egress" and that filter would filter egress for
>> the target cgroup and its descendents on the current netns.  As a
>> first pass, the netns issue could be sidestepped by making it only
>> work in the root netns (i.e. the bpf() call would fail if you're not
>> in the root netns and the hooks wouldn't run if you're not in the root
>> netns.)  It *might* even be possible to retrofit in the socket
>> controller by saying that the default hierarchy is used if the socket
>> controller isn't mounted.
>
> I don't know.  You're throwing out too many ideas too fast and it's
> difficult to keep up with what the differences are between those
> ideas.  But if we're doing cgroup controllers, shouldn't cgroup ns
> support be sufficient?  We can consider the product of cgroup and net
> namespaces but that doesn't seem necessary given that people usually
> set up these namespaces in conjunction.

Fair enough.  See way below.

>
>> What *isn't* possible to cleanly fix after the fact is the current
>> semantics that cgroup hooks override the hooks in their ancestors.
>> IMO that is simply broken.  The example you gave (perf_event) is very
>> careful not to have this problem.
>
> That's like saying installing an iptables rule for a more specific
> target is broken.  As a cgroup controller, it is not an acceptable
> behavior given how delegation works.  As something similar to
> iptables, it is completely fine.

Even the xt_cgroup code checks cgroup_is_descendent().

>
>> > * My impression with bpf is that while delegation is something
>> >   theoretically possible it is not something which is gonna take place
>> >   in any immediate time frame.  If I'm wrong on this, please feel free
>> >   to correct me.
>>
>> But the issue isn't *BPF* delegation.  It's cgroup delegation or netns
>> creation, both of which exist today.
>
> No, the issue is bpf delegation.  If bpf were fully delegatable in
> practical sense, we could just do straight forward cgroup bpf
> controller.  Well, we'll have to think about how to chain the programs
> which would differ on program type but that shouldn't be too hard.

What do you mean by "if bpf were fully delegatable"?  I don't know
what it would even mean to delegate bpf.  I do know what it means to
allow programs to create new network namespaces and for cgroup
sub-hierarchies to be delegated.

>
>> > * There are a lot of use cases which can immediately take advantage of
>> >   cgroup-aware bpf programs operating as proposed.  The model is
>> >   semantically equivalent to iptables (let's address the netns part if
>> >   that's an issue) which net people are familiar with.
>>
>> That sounds like a great argument for those users to patch their
>> kernels to gain experience with this feature.
>
> I don't get why this would particularly point to out-of-tree usage.
> Why is that?

Because I think that the API currently has some issues that will be
difficult to fix without either breaking the API or supporting
multiple APIs going forward.

>
>> > * It isn't exclusive with adding cgroup bpf controller down the road
>> >   if necessary and practical.  Sure, this isn't the perfect situation
>> >   but it seems like an acceptable trade-off to me.  What ever is
>> >   perfect?
>>
>> I think it more or less is exclusive.  I can imagine davem accepting a
>> patch to make the sock_cgroup_data think point at a new "socket"
>> cgroup type.  I can't imagine him accepting a patch to have sockets
>> have more than one pointer to a cgroup, with good reason.
>
> Why would it ever need multiple pointers?  Socket is associated with
> one cgroup whether it's this or controller thing.  Membership part
> doesn't change.  It can share everything.

Exactly.  If it starts out using the default hierarchy and then
switches to being a socket controller, there will still be old
deployed code that tries to attach bpf programs to the default
hierarchy.  That will require defining some semantics for it.

> No idea about landlock but as for the cgroup aware network bpf
> programs, let's please try to narrow down the arguments.  Here's one
> question.
>
> * If we make the current thing netns aware, how is it different from
>   iptables?  Note that at least future-proofing for netns is trivial.
>   We can simply skip running the bpf programs for non-root ns for now.
>
> If the answer is "they aren't that different", is the reason that
> you're against the current code because you think that it being a part
> of cgroup would be more useful?  I'm not necessarily against that
> point, I just think that this is a reasonable trade-off given the
> circumstances especially given that this doens't block having the
> cgroup things in the future.

Having thought about this some more, I think that making it would
alleviate a bunch of my concerns, as it would make the semantics if
the capable() check were relaxed to ns_capable() be sane.  Here's what
I currently should happen before bpf+cgroup is enabled in a release:

1. Make it netns-aware.  This could be as simple as making it only
work in the root netns because then real netns awareness can be added
later without breaking anything.  The current situation is bad in that
network namespaces are just ignored and it's plausible that people
will start writing user code that depends on having network namespaces
be ignored.

2. Make it inherit properly.  Inner cgroups should not override outer
hooks.  As in (1), this could be simplified by preventing the same
hook from being configured in both an ancestor and a descendent
cgroup.  Then inheritance could be added for real later on.

3. Give cgroup delegation support some serious thought.  In
particular, if delegation would be straightforward but the current API
wouldn't work well with delegation, then at least consider whether the
API should change before it becomes stable so that two APIs don't need
to be supported going forward.

>From the bpf side, I think that the only thing needed to get
delegation working is to make inheritance work right -- if the same
hook is set up multiple places in the hierarchy, call all of the in an
appropriate order.  The rest is probably all on the cgroup side --
setting up a way to enable delegation (subtree_control?), making sure
that filesystem permissions are checked when configuring hooks, and
perhaps dealing with setuid issues.

--Andy
