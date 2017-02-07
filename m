From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Mon, 6 Feb 2017 17:42:20 -0800
Message-ID: <20170207014218.GA83671@ast-mbp.thefacebook.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
 <20170205032548.GE73775@ast-mbp.thefacebook.com>
 <CALCETrU4_y0qSJu4epTO9aNEVZzt9cXY52=bHyGutbAMuEd-VA@mail.gmail.com>
 <20170205040501.GH73775@ast-mbp.thefacebook.com>
 <CALCETrWvDZp0TFrw88i9gab5L6OhBwrmjYL-yMDwtMHz51HZ+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35903 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdBGBm0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 20:42:26 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so10528766pgf.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 17:42:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrWvDZp0TFrw88i9gab5L6OhBwrmjYL-yMDwtMHz51HZ+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 08:17:57PM -0800, Andy Lutomirski wrote:
> On Sat, Feb 4, 2017 at 8:05 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sat, Feb 04, 2017 at 07:33:14PM -0800, Andy Lutomirski wrote:
> >> On Sat, Feb 4, 2017 at 7:25 PM, Alexei Starovoitov
> >> <alexei.starovoitov@gmail.com> wrote:
> >> > On Sat, Feb 04, 2017 at 09:15:10AM -0800, Andy Lutomirski wrote:
> >> >> On Fri, Feb 3, 2017 at 5:22 PM, Alexei Starovoitov <ast@fb.com> wrote:
> >> >> > Note that all bpf programs types are global.
> >> >>
> >> >> I don't think this has a clear enough meaning to work with.  In
> >> >
> >> > Please clarify what you mean. The quoted part says
> >> > "bpf programs are global". What is not "clear enough" there?
> >>
> >> What does "bpf programs are global" mean?  I am genuinely unable to
> >> figure out what you mean.  Here are some example guesses of what you
> >> might mean:
> >>
> >>  - BPF programs are compiled independently of a namespace.  This is
> >> certainly true, but I don't think it matters.
> >>
> >>  - You want BPF programs to affect everything on the system.  But this
> >> doesn't seem right to be -- they only affect things in the relevant
> >> cgroup, so they're not global in that sense.
> >
> > All bpf program types are global in the sense that you can
> > make all of them to operate across all possible scopes and namespaces.
> 
> I still don't understand what you mean here.  A seccomp program runs
> in the process that installs it and children -- it does not run in
> "all possible scopes". 

seccomp and classic bpf is different, since there is no concept
of the program there. cbpf is a stateless set of instructions
that belong to some entity like seccomp or socket. ebpf is stateful
and starts with the program, then hook and then scope.

> A socket filter runs on a single socket and
> therefore runs in a single netns.  So presumably I'm still
> misunderstanding you

in classic - yes. ebpf can have the same program attached to
multiple sockets in different netns.
For classic - the object is the socket and the user can only
manipulate that socket. For extended - the object is the program
and it can exist on its own. Like the program can be pinned in bpffs
while it's not attached to any hook.
For classic bpf the ideas of CRIU naturally apply, since
it checkpoints the socket and it happens that socket has
a set of statless cbpf instructions within. So it's
expected to save/restore cbpf as part of socket save/restore.
In case of ebpf the program exists independently of the socket.
Doing save/restore of the ebpf program attached to a socket
is meaningless, since it could be pinned in bpffs, attached
to other sockets, has state in bpf maps, some other process
might be actively talking to that program and so on.
ebpf is a graph of interconnected pieces. To criu such thing
one really need to freeze the whole system, all of it processes,
and stop the kernel. I don't see criu ever be applied to ebpf.

> > cgroup only gives a scope for the program to run, but it's
> > not limited by it. The user can have the same program
> > attached to two or more different cgroups, so one program
> > will run across multiple cgroups.
> 
> Does this mean "BPF programs are compiled independently of a
> namespace?"  If so, I don't see why it's relevant at all.  Sure, you
> could compile a BPF program once and install it in two different
> scopes, but that doesn't mean that the kernel should *run* it globally
> in any sense.  Can you clarify?

if single program is attached to different sockets it exactly
means that the kernel should run it for different sockets :)

> >>  - The set of BPF program types and the verification rules are
> >> independent of cgroup and namespace.  This is true, but I don't think
> >> it matters.
> >
> > It matters. That's actually the key to understand. The loading part
> > verifies correctness for particular program type.
> > Afterwards the same program can be attached to any place.
> > Including different cgroups and different namespaces.
> > The 'attach' part is like 'switch on' that enables program
> > on particular hook. The scope (whether it's socket or netdev or cgroup)
> > is a scope that program author uses to narrow down the hook,
> > but it's not an ultimate restriction.
> > For example the socket program can be attached to sockets and
> > share information with cls_bpf program attached to netdev.
> > The kprobe tracing program can peek into kernel internal data
> > and share it with cls_bpf or any other type as long as
> > everything is root. The information flow is global to the whole system.
> 
> Why does any of this imply that a cgroup+bpf program that is attached
> once should run for all network namespaces?

because cgroup is the only scope that is being used to scope this
particular bpf_type_cgroup_sock program type.
In the future we may add bpf_type_netns_sock program type
which will use exactly the same sock create hook, but will be scoped
by netns. It will be completely independent of any cgroups.
The event of socket creation by user process within given netns
will trigger a call to attached bpf program for that netns.
All other netns (where program is not attached) won't see the program called.
But the user will still be able to load single program
and attach it to two netns-es.

Potentially we can also allow a combination of scopes where
single bpf program is attached to a hook while scoped by
both netns and cgroup at the same time.
I see it as an extension to prog_attach command where
user will specify two fds (one for cgroup and one for netns) to make
given prog_fd program scoped by both.
Nothing in the current api prevents such future extensions.

And from the other thread:

> I'm not saying that at all.  I'm saying that this use case sounds
> valid, but maybe it could be solved differently.  Here are some ideas:

I'm happy to discuss api extension ideas as long as I don't hear
a week later that they should be done for 4.10

> - Expose the actual cgroup (relative to the hooked cgroup) to the BPF
> program.  Then you could parse the headers, check what cgroup you're
> in, and proceed accordingly.  This could potentially be even faster
> for your use case if done carefully because it will stress the
> instruction cache less.

that was considered. we thought about exposing cgroup inode
or some form of relative cgroup id and use that for lookup, but for
close to zero overhead network monitoring that extra lookup
is quite costly, but this idea is still on the table.
We might use it together with cls_bpf program type.

>  - Have a (non-default) flag that says "overridable".  The effect is
>  that, if /A and /A/B both have overridable programs attached, then
>  sockets in /A/B don't run /A's program.  If, however, /A has a
>  non-overridable program and /A/B has an overridable program, then
>  sockets in /A/B run both programs.  IOW overridable programs override
>  other overridable programs, but non-overridable programs never
>  override anything and are never overridden by anything.

that sounds a bit complex to maintain of the kernel side.
Is this for the case where sandboxing daemon is using non-overridable
and it still wants to allow inner daemon to do its monitoring?
I guess that's useful. I don't mind adding something like this
in the future.

> Suppose someone wants to make CGROUP_BPF work right when a container
> and a container manager both use it.  It'll have to run both programs.
> What would the semantics be if this were to be added?  This is really
> a question, not an indictment of your approach.  For all I know,
> you're proposing exactly what I suggested above.

sounds like your proposed approach to let kernel keep two sets
of overridable and non-overridable programs can work.
Need to think about it more. There are things to resolve there.
Like there gotta be a handle or some cookie that user will
give to the kernel to identify particular program within a list.
Otherwise i don't see how the user can detach the program later
or even query whether it's attached already or not.
We had a case when user daemon was restarting after an upgrade
and was attaching cls_bpf to tc. After few weeks every packet
was going through a ton of bpf programs. So I like single
program being default, since the user doing a chain of progs
would have to think about handles/cookies beforehand
and would have to enable it explicitly with the flag.

> And sandboxing needn't, and won't, wait until unprivileged bpf
> programs are added.  Plenty of sandboxes run as root.

great. Last time I heard the unprivileged progs were positioned as
must have for landlock. I'm happy to stay root only for now.
