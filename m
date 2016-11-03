From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Thu, 3 Nov 2016 08:16:31 -0600
Message-ID: <CACby=p=mbxKz1Pz726aNYqxFoJs1w_GPQGrJq6X6vqVnSeAbYw@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
 <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org>
 <CALx6S37s-pTxgqje9+FgmuvVgSZONGURAmJOemL6pOc6_Oepew@mail.gmail.com> <7ac775f4-4638-3bd0-f6f8-e54c7d26e8d8@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:32951 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755028AbcKCOQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 10:16:34 -0400
Received: by mail-vk0-f46.google.com with SMTP id d65so40972022vkg.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 07:16:33 -0700 (PDT)
In-Reply-To: <7ac775f4-4638-3bd0-f6f8-e54c7d26e8d8@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 November 2016 at 04:48, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Nov 2, 2016, at 00:07, Tom Herbert wrote:
>> On the other hand, I'm not really sure how to implement for this level
>> of performance this in LWT+BPF either. It seems like one way to do
>> that would be to create a program each destination and set it each
>> host. As you point out would create a million different programs which
>> doesn't seem manageable. I don't think the BPF map works either since
>> that implies we need a lookup (?). It seems like what we need is one
>> program but allow it to be parameterized with per destination
>> information saved in the route (LWT structure).
>
> Yes, that is my proposal. Just using the dst entry as meta-data (which
> can actually also be an ID for the network namespace the packet is
> coming from).

I have no objection to doing this on top of this series.

> My concern with using BPF is that the rest of the kernel doesn't really
> see the semantics and can't optimize or cache at specific points,
> because the kernel cannot introspect what the BPF program does (for
> metadata manipulation, one can e.g. specifiy that the program is "pure",
> and always provides the same output for some specified given input, thus
> things can be cached and memorized, but that framework seems very hard
> to build).

So you want to reintroduce a routing cache? Each packet needs to pass
through the BPF program anyway for accounting purposes. This is not
just about getting the packets out the right nexthop in the fastest
possible way.

> I also fear this becomes a kernel by-pass:
>
> It might be very hard e.g. to apply NFT/netfilter to such packets, if
> e.g. a redirect happens suddenly and packet flow is diverted from the
> one the user sees currently based on the interfaces and routing tables.

The LWT xmit hook is after the POST_ROUTING hook. The input and output
hook cannot redirect and output will become read-only just like input
already is. We are not bypassing anything. Please stop throwing the
word bypass around. This is just a false claim.

> That's why I am in favor of splitting this patchset down and allow the
> policies that should be expressed by BPF programs being applied to the
> specific subsystems (I am not totally against a generic BPF hook in
> input or output of the protocol engines). E.g. can we deal with static
> rewriting of L2 addresses in the neighbor cache? We already provide a
> fast header cache for L2 data which might be used here?

Split what? What policies?

I have two primary use cases for this:
1) Traffic into local containers: Containers are only supposed to do
L3, all L2 traffic is dropped for security reasons. The L2 header for
any packets in and out of the container is fixed and does not require
any sort of resolving. I in order to feed packets from the local host
into the containers, a route with the container prefix is set up. It
points to a nexthop address which appears behind a veth pair. A BPF
program is listening at tc ingress on the veth pair and will enforce
policies and do accounting. It requires very ugly hacks because Linux
does not like to do forwarding to an address which is considered
local. It works but it is a hack.

What I want to do instead is to run the BPF program for the route
directly, apply the policies, do accounting, push the fixed dummy L2
header and redirect it to the container. If someone has netfilter
rules installed, they will still apply. Nothing is hidden.

2) For external traffic that is coming in. We have a BPF program
listening on tc ingress which matches on the destination address on
all incoming traffic. If the packet is a for a container, we perform
the same actions as above. In this case we are bypassing the routing
table. This is ugly. What I want to do instead is to have the
container prefix invoke the BPF program so all packets have a route
lookup performed and netfilter filtering performed, only after that,
the BPF program is invoked exclusively for the packets destined for
local containers. Yes, it would be possible to redirect into a
temporary veth again and listen on that but it again requires to fake
a L2 segment which is just unnecessary and slow.

This is not hiding anything and it is not bypassing anything.
