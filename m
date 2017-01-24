From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 10:54:03 -0800
Message-ID: <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com> <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com> <20170124174823.GA17813@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:33016 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdAXSyZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:54:25 -0500
Received: by mail-vk0-f51.google.com with SMTP id k127so118161190vke.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 10:54:24 -0800 (PST)
In-Reply-To: <20170124174823.GA17813@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 9:48 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jan 23, 2017 at 08:32:02PM -0800, Andy Lutomirski wrote:
>> On Mon, Jan 23, 2017 at 8:05 PM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
>> > On 1/23/17 8:37 PM, Andy Lutomirski wrote:
>> >> Yes, it is a bug because cgroup+bpf causes unwitting programs to be
>> >> subject to BPF code installed by a different, potentially unrelated
>> >> process.  That's a new situation.  The failure can happen when a
>> >> privileged supervisor (whoever runs ip vrf) runs a clueless or
>> >> unprivileged program (the thing calling unshare()).
>> >
>> > There are many, many ways to misconfigure networking and to run progra=
ms in a context or with an input argument that causes the program to not wo=
rk at all, not work as expected or stop working. This situation is no diffe=
rent.
>> >
>> > For example, the only aspect of BPF_PROG_TYPE_CGROUP_SOCK filters that=
 are namespace based is the ifindex. You brought up the example of changing=
 namespaces where the ifindex is not defined. Alexei mentioned an example w=
here interfaces can be moved to another namespace breaking any ifindex base=
d programs. Another example is the interface can be deleted. Deleting an in=
terface with sockets bound to it does not impact the program in any way - n=
o notification, no wakeup, nothing. The sockets just don't work.
>>
>> And if you use 'ip vrf' to bind to a vrf with ifindex 4 and a program
>> unshares netns and creates an interface with ifindex 4, then that
>> program will end up with its sockets magically bound to ifindex 4 and
>> will silently malfunction.
>>
>> I can think of multiple ways to address this problem.  You could scope
>> the hooks to a netns (which is sort of what my patch does).  You could
>> find a way to force programs in a given cgroup to only execute in a
>> single netns, although that would probably cause other breakage.  You
>> could improve the BPF hook API to be netns-aware, which could plausbly
>> address issues related to unshare() but might get very tricky when
>> setns() is involved.
>
> scoping cgroup to netns will create weird combination of cgroup and netns
> which was never done before. cgroup and netns scopes have to be able
> to overlap in arbitrary way. Application shouldn't not be able to escape
> cgroup scope by changing netns.

I had assumed that too, but I'm not longer at all convinced that this
is a problem.  It's certainly the case that, if you put an application
into a restrictive cgroup, it shouldn't be able to bypass those
restrictions using unshare() or setns().  But I don't think this is
really possible regardless.  The easy way to try to escape is using
unshare(), but this doesn't actually buy you anything.

$ unshare -Urn ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group
default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

Maybe I just escaped the cgroup restrictions on ingress and egress,
but that doesn't seem to matter because I also no longer have any
interfaces that have any traffic.  And, if I created a socket before
unsharing, it's still safe because that socket is bound to the old
netns and would still be subject to the cgroup rules with my patch
applied.

setns() is a bit more complicated, but it should still be fine.
netns_install() requires CAP_NET_ADMIN over the target netns, so you
can only switch in to a netns if you already have privilege in that
netns.

>> My point is that, in 4.10-rc, it doesn't work right, and I doubt this
>> problem is restricted to just 'ip vrf'.  Without some kind of change
>> to the way that netns and cgroup+bpf interact, anything that uses
>> sk_bound_dev_if or reads the ifindex on an skb will be subject to a
>> huge footgun that unprivileged programs can trigger and any future
>> attempt to make the cgroup+bpf work for unprivileged users is going to
>> be more complicated than it deserves to be.
>
> For n-th time, the current BPF_PROG_TYPE_CGROUP* is root only and
> speculation about unprivileged usage are not helping the discussion.

...which has nothing to do with my example of how it's broken.  I used
'ip vrf' the way it was intended to be used and then I ran code in it
that uses only APIs that predate eBPF.  The result was that the
program obtained a broken socket that had sk_bound_dev_if filled in
with a nonsense index.  There's no speculation -- it's just broken.

Maybe you can argue that this is a missing feature in cgroup+bpf (no
API to query which netns is in use) and a corresponding bug in 'ip
vrf', but I see this as evidence that cgroup+bpf as it exists in 4.10
is not carefully enough throught through.  The only non-example user
of it that I can find (ip vrf) is buggy and can't really be fixed
using mechanisms that exist in 4.10-rc.

>
>> things up so that unshare will malfunction.  It should avoid
>> malfunctioning when running Linux programs that are unaware of it.
>
> I agree that for VRF use case it will help to make programs netns
> aware by adding new bpf_get_current_netns_id() or something helper,
> but it's up to the program to function properly or be broken.

This will cause David's code to run slower, and I think he wants very
high performance.

> I will work on the patch to add that.
>

I think that may be a reasonable thing to do, but I think this may be
better as a non-default option.

Tejun, I can see two basic ways that cgroup+bpf delegation could work
down the road.  Both depend on unprivileged users being able to load
BPF programs of the correct type, but that's mostly a matter of
auditing the code and doesn't have any particularly interesting design
challenges as far as I know.

Approach 1: Scope cgroup+bpf hooks to a netns and require
ns_capable(CAP_NET_ADMIN), fs permissions, and (optionally) delegation
to be enabled to install them.  This shouldn't have any particularly
dangerous security implications because ns_capable(CAP_NET_ADMIN)
means you already own the netns.

Approach 2: Keep cgroup+bpf hooks global.  This makes the delegation
story much trickier.  There needs to be some mechanism to prevent some
program that has delegated cgroup control from affecting the behavior
of outside programs.  This isn't so easy.  Imagine that you've
delegated /cgroup/foo to UID 1000.  A program with UID 1000 can now
install a hook on /cgroup/foo, but there needs to be a mechanism to
prevent UID 1000 from running in /cgroup/foo in the global netns and
then running a tool like sudo.  This *might* be possible using just
existing cgroup mechanisms, but it's going to be quite tricky to make
sure it's done completely correctly and without dangerous races.

If cgroup+bpf stays global, then I think you're basically committing
to approach 2.

I would suggest doing approach 1 (i.e. apply my patch) and then, if
truly needed for some use case, add an option so that globally
privileged programs can create hooks that affect all namespaces.

Alexei, do you have an actual use case in mind that requires hooks to
be global?  The only current uses I'm aware of seem to work better if
they're local to a netns.
