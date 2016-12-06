From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [flamebait] xdp Was: Re: bpf bounded loops. Was: [flamebait] xdp
Date: Mon, 5 Dec 2016 19:05:27 -0800
Message-ID: <20161206030525.GA89307@ast-mbp.thefacebook.com>
References: <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <20161202183903.GC54949@ast-mbp.thefacebook.com>
 <2f3ce25c-3f59-9120-7d09-619be9b58e7a@stressinduktion.org>
 <1480707761.3858425.806609417.2E2C5E07@webmail.messagingengine.com>
 <20161202233430.GA58522@ast-mbp>
 <eee898ad-9a77-2987-c38d-984231139475@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33241 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbcLFDFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 22:05:43 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so17879201pfv.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 19:05:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <eee898ad-9a77-2987-c38d-984231139475@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 05:05:28PM +0100, Hannes Frederic Sowa wrote:
>
> If one of those eBPF verifiers only accepts a certain number of INSN, as
> fundamental as backwards jumps, we might end up with two compiler?

two compilers? We already have five. There is gcc bpf backend (unmaintained)
and now lua, python and ply project can generate bpf code without llvm.
The kernel verifier has to become smarter. Right now it understands
only certain instruction patterns which caused all five bpf generators to
do extra work to satisfy the verifier. The solution is to do
data flow analysis using proper compiler techniques.

> program thinks). Ergo, more complexity. What do you do when one of those
> two systems fail? What is the reference data? What do you do if on a
> highly busy box during DoS constant reloading of your vmalloc happens (I
> don't know if it is a problem under DoS)?

ddos is one of the key use cases for xdp. If the system is about to oom
during ddos, it has to be fixed. The faster we move with xdp development
the sooner we will find and fix those issues.
And xdp being a core component of the linux kernel we will fix ddos
for the whole internet. Anyone going dpdk route are simply in
business of selling ddos protection with proprietary solutions.

> I tried to argue that someone wanting to build netmap/DPDK-alike things
> in XDP, one faces the problem of synchronized IPC. Hashmaps solve this
> to some degree but cannot be synchronized.

I don't see ipc as a problem and, yes, xdp is the best platform so far
to deliver packets to user space. I think that the dataplane-in-the-driver
is going to be faster than the fastest streaming to user space approach,
but we cannot rule one way or the other without trying multiple
approaches first and benchmarking them against each other.
So I very much in favor of Jesper's effort to deliver packets to user space.

> DPDK even can configure various hw offloads already before the kernel
> can do so.

that's a harsh lesson that the kernel needs to learn. Since people went
to dpdk to do hw offload it means it's our fault that we were not
accommodative and flexible enough to provide such frameworks within
the kernel. imo John's flow/match api should have been accepted
and it would have been solid building block towards such offloads.

> If users want to use those, they switch to DPDK also, as I
> have seen the industry always wanting the best performance. DPDK can use
> SIMD instructions, all AVX, SSE and MMX stuff, and they do it.

agree as well. The kernel needs to find a way to use all of these
fancy instructions where performance matters.
People who say "kernel cannot do simd" just didn't try hard enough.

> Debugging is harder but currently worked on. But will probably always be
> harder than simply using a debugger.

That's actually the important value proposition of xdp+bpf, since
non-working bpf program is not a concern for the kernel support team.
Unlike kernel modules that the kernel team needs to bless and support
in production, bpf programs are outside of that scope. They are part
of user space apps and part of user space responsibility.

> This all leads to gigantic user space control planes like neutron and
> others that just make everyone's life much harder. The model requires
> this. And that is what I fear.

the neutron is complex and fragile, since it's using bridges on
top of bridges with ebtables and ovs in the mix. Trying to manage
many different kernel technologies and a mix of smaller control planes
by this mega control plane is not an easy task.

> I am not at all that negative against a hook before allocating the
> packet, but making everyone using it and marketing as an alternative to
> DPDK doesn't seem to fit for me.

I don't see developers that are forced to use xdp. I see developers
that are eager to use xdp as soon as support for it is available
in their nics. Those like maglev who developed their own bypass
are not going to use dpdk and people who already using dpdk are
not going to switch to xdp, but there are lots of others who
welcome xdp with open arms.

Thanks
