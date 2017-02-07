From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Mon, 6 Feb 2017 18:57:45 -0800
Message-ID: <CALCETrU8smU7KUoTcAe6sWCTvaCL4Vd24vaFfJqOSVhzHjFULw@mail.gmail.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
 <20170205032548.GE73775@ast-mbp.thefacebook.com> <CALCETrU4_y0qSJu4epTO9aNEVZzt9cXY52=bHyGutbAMuEd-VA@mail.gmail.com>
 <20170205040501.GH73775@ast-mbp.thefacebook.com> <CALCETrWvDZp0TFrw88i9gab5L6OhBwrmjYL-yMDwtMHz51HZ+A@mail.gmail.com>
 <20170207014218.GA83671@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:35156 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdBGC6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 21:58:08 -0500
Received: by mail-ua0-f179.google.com with SMTP id y9so75495646uae.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 18:58:07 -0800 (PST)
In-Reply-To: <20170207014218.GA83671@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 5:42 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Feb 04, 2017 at 08:17:57PM -0800, Andy Lutomirski wrote:
>> On Sat, Feb 4, 2017 at 8:05 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Sat, Feb 04, 2017 at 07:33:14PM -0800, Andy Lutomirski wrote:
>> >> What does "bpf programs are global" mean?  I am genuinely unable to
>> >> figure out what you mean.  Here are some example guesses of what you
>> >> might mean:
>> >>
>> >>  - BPF programs are compiled independently of a namespace.  This is
>> >> certainly true, but I don't think it matters.
>> >>
>> >>  - You want BPF programs to affect everything on the system.  But this
>> >> doesn't seem right to be -- they only affect things in the relevant
>> >> cgroup, so they're not global in that sense.
>> >
>> > All bpf program types are global in the sense that you can
>> > make all of them to operate across all possible scopes and namespaces.
>>
>> I still don't understand what you mean here.  A seccomp program runs
>> in the process that installs it and children -- it does not run in
>> "all possible scopes".
>
> seccomp and classic bpf is different, since there is no concept
> of the program there. cbpf is a stateless set of instructions
> that belong to some entity like seccomp or socket. ebpf is stateful
> and starts with the program, then hook and then scope.

So... are you saying that a loaded eBPF object is global in the sense
that if you attach the same object to more than one thing (two
sockets, say), the *same* program runs and shares its state?  If so, I
agree, but that's still not an argument that the *same* attachment of
an eBPF program to a cgroup should run in multiple network namespaces.
You could also attach the (same) program once per netns and its state
would be shared.

I'm pretty sure I've never suggested that an eBPF program be bound to
a namespace.  I just think that a lot of things get more
straightforward if an *attachment* of an eBPF program to a cgroup is
bound to a single namespace.

>
>> A socket filter runs on a single socket and
>> therefore runs in a single netns.  So presumably I'm still
>> misunderstanding you
>
> in classic - yes. ebpf can have the same program attached to
> multiple sockets in different netns.
> For classic - the object is the socket and the user can only
> manipulate that socket. For extended - the object is the program
> and it can exist on its own. Like the program can be pinned in bpffs
> while it's not attached to any hook.
> For classic bpf the ideas of CRIU naturally apply, since
> it checkpoints the socket and it happens that socket has
> a set of statless cbpf instructions within. So it's
> expected to save/restore cbpf as part of socket save/restore.
> In case of ebpf the program exists independently of the socket.

True.

> Doing save/restore of the ebpf program attached to a socket
> is meaningless, since it could be pinned in bpffs, attached
> to other sockets, has state in bpf maps, some other process
> might be actively talking to that program and so on.
> ebpf is a graph of interconnected pieces. To criu such thing
> one really need to freeze the whole system, all of it processes,
> and stop the kernel. I don't see criu ever be applied to ebpf.

Not true, I think.  CRIU could figure out which eBPF program is
attached to a socket and snapshot the attachment and (separately) the
eBPF object.  If the eBPF object were to be attached to two sockets,
CRIU would notice and only snaptshot the eBPF program once.  I don't
see why the whole system would need to be snapshotted.

Obviously this code isn't written yet.  But if eBPF were to be widely
used for, say, seccomp, I bet the CRIU code would show up in short
order.

>
> Potentially we can also allow a combination of scopes where
> single bpf program is attached to a hook while scoped by
> both netns and cgroup at the same time.
> I see it as an extension to prog_attach command where
> user will specify two fds (one for cgroup and one for netns) to make
> given prog_fd program scoped by both.
> Nothing in the current api prevents such future extensions.

I think this might be sufficient for all usecases.  Facebook's use
case of monitoring everything (if I understood correctly) could be
addressed by just attaching the program to the cgroup once for each
namespace.  The benefit would be a good deal of simplicity: you could
relax the capable() call to ns_capable() in the future, you wouldn't
need this patch, and you wouldn't be creating the first major
non-netns-specific network hook in the kernel.

>
> And from the other thread:
>
>> I'm not saying that at all.  I'm saying that this use case sounds
>> valid, but maybe it could be solved differently.  Here are some ideas:
>
> I'm happy to discuss api extension ideas as long as I don't hear
> a week later that they should be done for 4.10
>
>> - Expose the actual cgroup (relative to the hooked cgroup) to the BPF
>> program.  Then you could parse the headers, check what cgroup you're
>> in, and proceed accordingly.  This could potentially be even faster
>> for your use case if done carefully because it will stress the
>> instruction cache less.
>
> that was considered. we thought about exposing cgroup inode
> or some form of relative cgroup id and use that for lookup, but for
> close to zero overhead network monitoring that extra lookup
> is quite costly, but this idea is still on the table.
> We might use it together with cls_bpf program type.

Another approach would be to let the attach call take an opaque
parameter that's passed back to the eBPF program on each invocation.
That would be a single mem-to-register copy, right?

>
>>  - Have a (non-default) flag that says "overridable".  The effect is
>>  that, if /A and /A/B both have overridable programs attached, then
>>  sockets in /A/B don't run /A's program.  If, however, /A has a
>>  non-overridable program and /A/B has an overridable program, then
>>  sockets in /A/B run both programs.  IOW overridable programs override
>>  other overridable programs, but non-overridable programs never
>>  override anything and are never overridden by anything.
>
> that sounds a bit complex to maintain of the kernel side.
> Is this for the case where sandboxing daemon is using non-overridable
> and it still wants to allow inner daemon to do its monitoring?
> I guess that's useful. I don't mind adding something like this
> in the future.
>

I'm just trying to come up with sane semantics to having
non-overridable programs as well as overridable programs.  It has to
do *something* if you install both (or be disallowed).

>> Suppose someone wants to make CGROUP_BPF work right when a container
>> and a container manager both use it.  It'll have to run both programs.
>> What would the semantics be if this were to be added?  This is really
>> a question, not an indictment of your approach.  For all I know,
>> you're proposing exactly what I suggested above.
>
> sounds like your proposed approach to let kernel keep two sets
> of overridable and non-overridable programs can work.
> Need to think about it more. There are things to resolve there.
> Like there gotta be a handle or some cookie that user will
> give to the kernel to identify particular program within a list.
> Otherwise i don't see how the user can detach the program later
> or even query whether it's attached already or not.

I thought your plan was to allow at most one program per (cgroup, hook
type), in which case this isn't a problem, right?  If you call detach,
you detach the one and only program that's attached.

> We had a case when user daemon was restarting after an upgrade
> and was attaching cls_bpf to tc. After few weeks every packet
> was going through a ton of bpf programs. So I like single
> program being default, since the user doing a chain of progs
> would have to think about handles/cookies beforehand
> and would have to enable it explicitly with the flag.
>
>> And sandboxing needn't, and won't, wait until unprivileged bpf
>> programs are added.  Plenty of sandboxes run as root.
>
> great. Last time I heard the unprivileged progs were positioned as
> must have for landlock. I'm happy to stay root only for now.
>

I think that letting sandboxing features work unprivileged is
extremely valuable.  Just because cgroup+bpf is root only for now
doesn't mean it won't be used for sandboxing, though.
