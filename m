From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 23 Jan 2017 12:20:52 -0800
Message-ID: <CALCETrXK65itdDqYTdhB-Td8d-Hzj00dcDScUOUh9psCZN_cLA@mail.gmail.com>
References: <CALCETrW+ZQ1xMEfdEOzx6RK9ZoCvQiqQSnOyhDJ=-FZMwUbucg@mail.gmail.com>
 <20170118224120.GG9171@mtj.duckdns.org> <CALCETrXv3k+=C=9D5YGypzPk8_f4yo8ShQ3tM2fOo++gJFBM4A@mail.gmail.com>
 <20170119005925.GA18554@mtj.duckdns.org> <CALCETrVrEnL4cvkdDu2LUhxmeOZ+SMEmF=yKKsm9OYoW2y1Kpg@mail.gmail.com>
 <20170120023907.GA3294@ast-mbp.thefacebook.com> <CALCETrV6NArtFa89iW+QO3udxpJYpMXLbOEk6ZYyWsw7oZDS2Q@mail.gmail.com>
 <20170123043154.GA93519@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170123043154.GA93519-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2017 at 8:31 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, Jan 19, 2017 at 08:04:59PM -0800, Andy Lutomirski wrote:
>> On Thu, Jan 19, 2017 at 6:39 PM, Alexei Starovoitov
>> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On Wed, Jan 18, 2017 at 06:29:22PM -0800, Andy Lutomirski wrote:
>> >> I think it could work by making a single socket cgroup controller that
>> >> handles all cgroup things that are bound to a socket.  Using
>> >
>> > Such 'socket cgroup controller' would limit usability of the feature
>> > to sockets and force all other use cases like landlock to invent
>> > their own wheel, which is undesirable. Everyone will be
>> > inventing new 'foo cgroup controller', while all of them
>> > are really bpf features. They are different bpf program
>> > types that attach to different hooks and use cgroup for scoping.
>>
>> Can you elaborate on why that would be a problem?  In a cgroup v1
>> world, users who want different hierarchies for different types of
>> control could easily want one hierarchy for socket hooks and a
>> different hierarchy for lsm hooks.  In a cgroup v2 delegation world, I
>> could easily imagine the decision to delegate socket hooks being
>> different from the decision to delegate lsm hooks.  Almost all of the
>> code would be shared between different bpf-using cgroup controllers.
>
> how do you think it can be enforced when directory is chowned?

A combination of delegation policy (a la subtree_control in the
parent) and MAC policy.  I'm quite confident that apparmor can apply
policy to cgroupfs and I'm reasonably confident (although slightly
less so) that selinux can as well.  The docs suck :(

But if there's only one file in there to apply MAC policy to, the
ability to differentiate between subsystems is quite limited.   In the
current API, there are no files to apply policy to, so it won't work
at all.

>
> ... and open() of the directory done by the current api will preserve
> cgroup delegation when and only when bpf_prog_type_cgroup_*
> becomes unprivileged.
> I'm not proposing creating new api here.

I don't know what you mean.  open() of the directory can't check
anything useful because it has to work for programs that just want to
read the directory.

>> Meanwhile, cgroup+bpf actually appears to be buggy in this regard even
>> regardless of what semantics you think are better.  sk_bound_dev_if is
>> exposed as a u32 value, but sk_bound_dev_if only has meaning within a
>> given netns.  The "ip vrf" stuff will straight-up malfunction if a
>> process affected by its hook runs in a different netns from the netns
>> that "ip vrf" was run in.
>
> how is that any different from normal 'ip netns exec'?
> that is expected user behavior.

# ./ip link add dev vrf0 type vrf table 10
# ./ip vrf exec vrf0 ./show_bind
Default binding is "vrf0"
# ./ip vrf exec vrf0 unshare -n ./show_bind
show_bind: getsockopt: No such device

The expected behavior to me is that ip netns exec (or equivalently
unshare -n) gives a clean slate.  Actually malfunctioning (which this
example using the latest iproute2 and linux just did) is not expected.

I'm done with this part of this thread and I'm sending a patch.

>
>> restricting the types of sockets that can be created, then you do want
>> the filter to work across namespaces, but seccomp can do that too and
>> the current code doesn't handle netns correctly.
>
> are you saying that seccomp supports netns filtering? please show the proof.

It can trivially restruct the types of sockets that are created by
filtering on socket(2) syscall parameters, at least on sane
architectures that don't use socketcall().

> To summarize, I think the 'prog override is not allowed' flag would be
> ok feature to have and I wouldn't mind making it the default when no 'flag'
> field is passed to bpf syscall, but it's not acceptable to remove current
> 'prog override is allowed' behavior.
> So if you insist on changing the default, please implement the flag asap.
> Though from security point of view and ABI point of view there is absolutely
> no difference whether this flag is added today or a year later while
> the default is kept as-is.

It's too late and I have too little time.  I'll try to write a patch
to change the default to just deny attempts to override.  Better
behavior can be added later.

IMO your suggestions about priorities are overcomplicated.  For your
instrumentation needs, I can imagine that a simple "make this hook not
run if a descendent has a hook" would do it.  For everything else, run
them all in tree order (depending on filter type) and let the eBPF
code do whatever it wants to do.
