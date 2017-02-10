From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Fri, 10 Feb 2017 23:45:07 +0100
Message-ID: <589E4273.3090200@iogearbox.net>
References: <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com> <5894F19A.60305@iogearbox.net> <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com> <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com> <5898847B.2060400@iogearbox.net> <20170206192114.GA54756@ast-mbp.thefacebook.com> <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com> <589AF867.3020009@iogearbox.net> <c19a41f5-7737-d971-67e0-919276b47b95@cumulusnetworks.com> <589C51B1.5040205@iogearbox.net> <20170210052254.GA57910@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Quentin Monnet <quentin.monnet@6wind.com>,
        netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59925 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdBJWpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 17:45:53 -0500
In-Reply-To: <20170210052254.GA57910@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 06:22 AM, Alexei Starovoitov wrote:
> On Thu, Feb 09, 2017 at 12:25:37PM +0100, Daniel Borkmann wrote:
>>
>> Correct the overlap both use-cases share is the dump itself. It needs
>> to be in such a condition for CRIU, that it can be reloaded eventually,
>
> I don't think it makes sense to drag criu into this discussion.
> I expressed my take on criu in the other thread. tldr:
> bpf is a graph of dependencies between programs, maps, applications
> and kernel events. So to save/restore this graph one would need to solve
> very hard problems of stopping multiple applications at once,
> stopping kernel events and so on. I don't think it's worth going that route.

Definitely not straight forward, fully agree. Worst-case you probably
need to go via stop_machine() (like in ftrace case when it modifies
code) in order to get a global consistent snapshot at a specific time.
Sounds ugly. Or if small steps first, tail calls etc would not be supported;
then you would need to tackle progs and generic maps, for the progs part
it could be a very similar interface at least, thus I'm saying that it
would be good if it's designed extendable in future on that regard.

>>>     - Alternatively, the attach is always done by passing the FD as an
>>> attribute, so the netlink dump could attach an fd to the running
>>> program, return the FD as an attribute and the bpf program is retrieved
>> >from the fd. This is a major departure from how dumps work with
>>> processing attributes and needing to attach open files to a process will
>>> be problematic. Integrating the bpf into the dump is a natural fit.
>>
>> Right, I think it's a natural fit to place it into the various points/
>> places where it's attached to, as we're stuck with that anyway for the
>> attachment part. Meaning in cls_bpf, it would go as a mem blob into the
>> netlink attribute. There would need to be a common BPF core helper that
>> the various subsystem users call in order to generate that mentioned
>> output format, and that resulting mem blob is then stuck into either
>> nlattr, mem provided by syscall, etc.
>
> I think if we use ten different ways to dump it, it will
> complicate the user space tooling.
> I'd rather see one way of doing it via new syscall command.
> Pass prog_fd and it will return insns in some form.
>
> Here is more concrete proposal:
> - add two flags to PROG_LOAD:
>    BPF_F_ENFORCE_STATELESS - it will require verifier to check that program
>    doesn't use maps and any other global state (doesn't use bpf_redirect,
>    doesn't use bpf_set_tunnel_key and tunnel_opt)
>    This will ensure that program is stateless and pure instruction
>    dump is meaningful. For 'ip vrf' case it will be enough.

I don't think such flag will be needed from uapi pov. Verifier can
just set a flag like that in the bpf_prog aux bits while verifying ...

>    BPF_F_ALLOW_DUMP - it will save original program, so in the common
>    case we wouldn't need to waste memory to save program

... and when that one is passed and the prog has state, then it gets
rejected. Effectively, both flags are saying the same thing. Plus side
is that you don't waste any resources when not set, but problem I see
is that BPF_F_ALLOW_DUMP requires explicit cooperation from a process,
when used for introspection doing that transparently instead might be
more desirable. Problem is that even when transparent, we have mentioned
limitations, so someone who doesn't want to cooperate could then just
use f.e. an empty tail call map on exit and that would be enough to
make dump not supported again. But also with just BPF_F_ALLOW_DUMP, I
can foresee that in half a year or so people request that dump should
be possible also without BPF_F_ALLOW_DUMP explicitly set.

> - add new bpf syscall command BPF_PROG_DUMP
>    input: prog_fd, output: insns
>    it will work right away with OBJ_GET command and the user will
>    be able to dump stateless programs pinned in bpffs

(And with that it requires really cooperation by design.)

> - add approriate interfaces for different attach points to return prog_fd:
>    for cgroup it will be new BPF_PROG_GET command.
>    for socket it will be new getsockopt. (Actually BPF_PROG_GET can work
>    for sockets too and probably better).

I assume you mean above BPF_PROG_DUMP, right? Yeah, for them it's
not that difficult, agree.

>    for xdp and tc we need to find a way to return prog_fd.
>    netlink is no good, since it would be very weird to install fd
>    and return it async in netlink body. We can simply say that
>    whoever wants to dump programs need to first pin them in bpffs
>    and then attach to tc/xdp. iproute2 already does it anyway.
>    Realistically tc/xdp programs are almost always stateful, so
>    dump won't be available for them anyway.

Right, but if it's just for introspection, I still think that this
format I described earlier could work. Meaning for maps, you dump
all the params used to create the map along with refs where they
are used, that would allow for tc/xdp to dump it at least. It still
wouldn't support tail calls, but you would see that a tail call map
is used somewhere. It would still allow to move all the logic behind
the tail call then to defeat it, but we could make it that user
space can retrieve progs from slots by returning a new fd which
then itself can be used to do the dump again.

> If in the future we will discover magic way of restoring maps,
> we can relax prog loading part and allow BPF_F_ALLOW_DUMP to be
> used independently of BPF_F_ENFORCE_STATELESS flag.
> (In the beginning these two flags would need to be used together).
> Also we'll be able to extend BPF_PROG_DUMP independently
> of attachment points. If we introduce something like global
> variable section or read-only string section (like some folks asked)
> we can dump it back. Insns will not be the only section.
>
> My main point is that right now I'd really like to avoid
> dealing with stateful bits (maps, etc), since there is no
> good way of dumping it, while stateless will be enough

With dumping data, agree, but as mentioned you could at least
dump related map attributes that are immutable during lifetime
of a map, which can help introspection side a bit.

> for 'ip vrf' and simple programs.
>
> Thoughts?
>
