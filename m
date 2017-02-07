From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Mon, 6 Feb 2017 23:00:42 -0800
Message-ID: <20170207070039.GA18842@ast-mbp.thefacebook.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
 <20170205032548.GE73775@ast-mbp.thefacebook.com>
 <CALCETrU4_y0qSJu4epTO9aNEVZzt9cXY52=bHyGutbAMuEd-VA@mail.gmail.com>
 <20170205040501.GH73775@ast-mbp.thefacebook.com>
 <CALCETrWvDZp0TFrw88i9gab5L6OhBwrmjYL-yMDwtMHz51HZ+A@mail.gmail.com>
 <20170207014218.GA83671@ast-mbp.thefacebook.com>
 <CALCETrU8smU7KUoTcAe6sWCTvaCL4Vd24vaFfJqOSVhzHjFULw@mail.gmail.com>
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
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36436 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753064AbdBGHAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:00:51 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so8633188pfo.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:00:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrU8smU7KUoTcAe6sWCTvaCL4Vd24vaFfJqOSVhzHjFULw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 06:57:45PM -0800, Andy Lutomirski wrote:
> On Mon, Feb 6, 2017 at 5:42 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sat, Feb 04, 2017 at 08:17:57PM -0800, Andy Lutomirski wrote:
> >> On Sat, Feb 4, 2017 at 8:05 PM, Alexei Starovoitov
> >> <alexei.starovoitov@gmail.com> wrote:
> >> > On Sat, Feb 04, 2017 at 07:33:14PM -0800, Andy Lutomirski wrote:
> >> >> What does "bpf programs are global" mean?  I am genuinely unable to
> >> >> figure out what you mean.  Here are some example guesses of what you
> >> >> might mean:
> >> >>
> >> >>  - BPF programs are compiled independently of a namespace.  This is
> >> >> certainly true, but I don't think it matters.
> >> >>
> >> >>  - You want BPF programs to affect everything on the system.  But this
> >> >> doesn't seem right to be -- they only affect things in the relevant
> >> >> cgroup, so they're not global in that sense.
> >> >
> >> > All bpf program types are global in the sense that you can
> >> > make all of them to operate across all possible scopes and namespaces.
> >>
> >> I still don't understand what you mean here.  A seccomp program runs
> >> in the process that installs it and children -- it does not run in
> >> "all possible scopes".
> >
> > seccomp and classic bpf is different, since there is no concept
> > of the program there. cbpf is a stateless set of instructions
> > that belong to some entity like seccomp or socket. ebpf is stateful
> > and starts with the program, then hook and then scope.
> 
> So... are you saying that a loaded eBPF object is global in the sense
> that if you attach the same object to more than one thing (two
> sockets, say), the *same* program runs and shares its state?  If so, I
> agree, but that's still not an argument that the *same* attachment of
> an eBPF program to a cgroup should run in multiple network namespaces.
> You could also attach the (same) program once per netns and its state
> would be shared.
> 
> I'm pretty sure I've never suggested that an eBPF program be bound to
> a namespace.  I just think that a lot of things get more
> straightforward if an *attachment* of an eBPF program to a cgroup is
> bound to a single namespace.

Thank you for this whole discussion over the last few months.
Frankly in the beginning I wasn't 100% sure about the api we picked,
now I'm completely convinced that we absolutely made the right choice.
It's clean and keeps scoping constructs clear and explicit for the users.
So I am proposing that in the future we should add the ability to
scope bpf programs by netns. Just like current api scopes them
by cgroup. The attachment must be explicit.
Current api attaches type_cgroup_* program to a hook and scopes it
by a given cgroup. At that time some apps within that cgroup may
already run in different netns and attaching process may be
in yet another netns. There is no way to have sane semantics
without explicitly specifying the scope. Currently we do it
by explicitly specifying the cgroup. In the future we need
to extend it by specifying netns (without cgroup). Then
for container technologies that are based on netns we'll
have an efficient way of scoping programs to given netns.
And when afnetns is finally ready, the same scoping approach
will work for afnetns as well. For cases that need to
have two scopes at the same time (like cgroup and netns)
the bpf_sk_netns_id() helper will work one way and
some future bpf_sk_cgroup_id() helper will work from
the other side.
So far in multi-scope cases one dimension is dominating.
Like number of cgroups is way larger than number of netns,
so explicit bpf_sk_netns_id() from inside the programs
is faster than doing the same in the kernel.
And if in the future there will be a case with a lot of
cgroups and a lot of netns at the same time, we'll extend
the api further to specify two scopes to bpf_prog_attach command.
The kernel side will probably need a hashtable to lookup
a bpf prog based on (cgroup, netns) pair of pointers.

> >> A socket filter runs on a single socket and
> >> therefore runs in a single netns.  So presumably I'm still
> >> misunderstanding you
> >
> > in classic - yes. ebpf can have the same program attached to
> > multiple sockets in different netns.
> > For classic - the object is the socket and the user can only
> > manipulate that socket. For extended - the object is the program
> > and it can exist on its own. Like the program can be pinned in bpffs
> > while it's not attached to any hook.
> > For classic bpf the ideas of CRIU naturally apply, since
> > it checkpoints the socket and it happens that socket has
> > a set of statless cbpf instructions within. So it's
> > expected to save/restore cbpf as part of socket save/restore.
> > In case of ebpf the program exists independently of the socket.
> 
> True.
> 
> > Doing save/restore of the ebpf program attached to a socket
> > is meaningless, since it could be pinned in bpffs, attached
> > to other sockets, has state in bpf maps, some other process
> > might be actively talking to that program and so on.
> > ebpf is a graph of interconnected pieces. To criu such thing
> > one really need to freeze the whole system, all of it processes,
> > and stop the kernel. I don't see criu ever be applied to ebpf.
> 
> Not true, I think.  CRIU could figure out which eBPF program is
> attached to a socket and snapshot the attachment and (separately) the
> eBPF object.  If the eBPF object were to be attached to two sockets,
> CRIU would notice and only snaptshot the eBPF program once.  I don't

that's C part of CRIU... and as soon as it goes to do R part the initial
graph between programs, maps, and apps is now completely different
and everything is broken.
criu cannot save/restore a graph by saving/restoring one
edge at a time while graph keeps changing. It needs to freeze
the whole thing.

> need this patch, and you wouldn't be creating the first major
> non-netns-specific network hook in the kernel.

first?! last time i checked two old cgroupv1 controllers ignore netns.
nflog has an ability to log across netns.

> >> - Expose the actual cgroup (relative to the hooked cgroup) to the BPF
> >> program.  Then you could parse the headers, check what cgroup you're
> >> in, and proceed accordingly.  This could potentially be even faster
> >> for your use case if done carefully because it will stress the
> >> instruction cache less.
> >
> > that was considered. we thought about exposing cgroup inode
> > or some form of relative cgroup id and use that for lookup, but for
> > close to zero overhead network monitoring that extra lookup
> > is quite costly, but this idea is still on the table.
> > We might use it together with cls_bpf program type.
> 
> Another approach would be to let the attach call take an opaque
> parameter that's passed back to the eBPF program on each invocation.
> That would be a single mem-to-register copy, right?

i'm not sure what you mean here.
we discussed adding new types of relocations to bpf instruction stream.
Today there is only BPF_PSEUDO_MAP_FD.
We thought that netns and cgroup can be two other types.
Similarly to maps the user process will open an fd to netns (or cgroup)
and store it inside the program as BPF_PSEUDO_NETNS_FD.
At load time the kernel will increment the refcnt.
The problem with this approach is that bpf programs will suddenly
hold the references to normal kernel objects and debugging
of netns and cgroup destruction will become a nightmare.
Thefore bpf_sk_netns_id() (and future bpf_sk_cgroup_id) approach
is safer and simpler.

> >>  - Have a (non-default) flag that says "overridable".  The effect is
> >>  that, if /A and /A/B both have overridable programs attached, then
> >>  sockets in /A/B don't run /A's program.  If, however, /A has a
> >>  non-overridable program and /A/B has an overridable program, then
> >>  sockets in /A/B run both programs.  IOW overridable programs override
> >>  other overridable programs, but non-overridable programs never
> >>  override anything and are never overridden by anything.
> >
> > that sounds a bit complex to maintain of the kernel side.
> > Is this for the case where sandboxing daemon is using non-overridable
> > and it still wants to allow inner daemon to do its monitoring?
> > I guess that's useful. I don't mind adding something like this
> > in the future.
> >
> 
> I'm just trying to come up with sane semantics to having
> non-overridable programs as well as overridable programs.  It has to
> do *something* if you install both (or be disallowed).

I think what you're proposing with two sets is fine.
(if i understood the idea correctly).
right now we have only overridable and adding non-overridable
doesn't break anything as far as i can see. For simplicity we
can do it with just two pointers (no chaining). Later can add
priority and chain of programs. Which probably should be
an array of programs to have good performance.

I think your main concern all this time was that we won't be
able to extend the api to suit security/sandboxing needs.
I don't share that concern and I think this discussion
outlined the work in that area for the next few years that
we can incrementally do.

> >> Suppose someone wants to make CGROUP_BPF work right when a container
> >> and a container manager both use it.  It'll have to run both programs.
> >> What would the semantics be if this were to be added?  This is really
> >> a question, not an indictment of your approach.  For all I know,
> >> you're proposing exactly what I suggested above.
> >
> > sounds like your proposed approach to let kernel keep two sets
> > of overridable and non-overridable programs can work.
> > Need to think about it more. There are things to resolve there.
> > Like there gotta be a handle or some cookie that user will
> > give to the kernel to identify particular program within a list.
> > Otherwise i don't see how the user can detach the program later
> > or even query whether it's attached already or not.
> 
> I thought your plan was to allow at most one program per (cgroup, hook
> type), in which case this isn't a problem, right?  If you call detach,
> you detach the one and only program that's attached.

yes. when there is only one program the detach is unambiguous.
As soon as we have a chain the user will need a handle or priority
or both.

> > We had a case when user daemon was restarting after an upgrade
> > and was attaching cls_bpf to tc. After few weeks every packet
> > was going through a ton of bpf programs. So I like single
> > program being default, since the user doing a chain of progs
> > would have to think about handles/cookies beforehand
> > and would have to enable it explicitly with the flag.
> >
> >> And sandboxing needn't, and won't, wait until unprivileged bpf
> >> programs are added.  Plenty of sandboxes run as root.
> >
> > great. Last time I heard the unprivileged progs were positioned as
> > must have for landlock. I'm happy to stay root only for now.
> >
> 
> I think that letting sandboxing features work unprivileged is
> extremely valuable.  Just because cgroup+bpf is root only for now
> doesn't mean it won't be used for sandboxing, though.

agree.
