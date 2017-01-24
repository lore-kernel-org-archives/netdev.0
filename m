From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 20:32:02 -0800
Message-ID: <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com> <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:33106 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXEcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:32:23 -0500
Received: by mail-ua0-f175.google.com with SMTP id i68so125685431uad.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:32:23 -0800 (PST)
In-Reply-To: <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 8:05 PM, David Ahern <dsa@cumulusnetworks.com> wrot=
e:
> On 1/23/17 8:37 PM, Andy Lutomirski wrote:
>> Yes, it is a bug because cgroup+bpf causes unwitting programs to be
>> subject to BPF code installed by a different, potentially unrelated
>> process.  That's a new situation.  The failure can happen when a
>> privileged supervisor (whoever runs ip vrf) runs a clueless or
>> unprivileged program (the thing calling unshare()).
>
> There are many, many ways to misconfigure networking and to run programs =
in a context or with an input argument that causes the program to not work =
at all, not work as expected or stop working. This situation is no differen=
t.
>
> For example, the only aspect of BPF_PROG_TYPE_CGROUP_SOCK filters that ar=
e namespace based is the ifindex. You brought up the example of changing na=
mespaces where the ifindex is not defined. Alexei mentioned an example wher=
e interfaces can be moved to another namespace breaking any ifindex based p=
rograms. Another example is the interface can be deleted. Deleting an inter=
face with sockets bound to it does not impact the program in any way - no n=
otification, no wakeup, nothing. The sockets just don't work.

And if you use 'ip vrf' to bind to a vrf with ifindex 4 and a program
unshares netns and creates an interface with ifindex 4, then that
program will end up with its sockets magically bound to ifindex 4 and
will silently malfunction.

I can think of multiple ways to address this problem.  You could scope
the hooks to a netns (which is sort of what my patch does).  You could
find a way to force programs in a given cgroup to only execute in a
single netns, although that would probably cause other breakage.  You
could improve the BPF hook API to be netns-aware, which could plausbly
address issues related to unshare() but might get very tricky when
setns() is involved.

My point is that, in 4.10-rc, it doesn't work right, and I doubt this
problem is restricted to just 'ip vrf'.  Without some kind of change
to the way that netns and cgroup+bpf interact, anything that uses
sk_bound_dev_if or reads the ifindex on an skb will be subject to a
huge footgun that unprivileged programs can trigger and any future
attempt to make the cgroup+bpf work for unprivileged users is going to
be more complicated than it deserves to be.

(Aside: I wonder if a similar goal to 'ip vrf' could be achieved by
moving the vrf to a different network namespace and putting programs
that you want to be subject to the VRF into that namespace.)

>
> The point of using a management tool like ip is to handle the details to =
make things sane -- which is the consistent with the whole point of ip netn=
s vs running unshare -n.

I still don't understand how you're going to make 'ip netns' make this
problem go away.  Keep in mind that there are real programs that call
the unshare() syscall directly.

>
>>
>> If the way cgroup+bpf worked was that a program did a prctl() or
>> similar to opt in to being managed by a provided cgroup-aware BPF
>> program, then I'd agree with everything you're saying.  But that's not
>> at all how this code works.
>
> I don't want an opt-in approach. The program does not need to know or eve=
n care that it has some restriction. Today, someone runs 'ip netns exec NAM=
E COMMAND' the command does not need to know or care that the network names=
pace was changed on it. Same with 'ip vrf exec' -- it is a network policy t=
hat is forced on the program by the user.

I absolutely agree.  My point is that cgroup+bpf is *not* opt-in, so
the bar should be higher.  You can't blame the evil program that
called unshare() for breaking things when 'ip vrf' unavoidably sets
things up so that unshare will malfunction.  It should avoid
malfunctioning when running Linux programs that are unaware of it.
This should include programs like unshare and 'ip netns'.
