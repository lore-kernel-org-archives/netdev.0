From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Infer payload of packet from via address family.
Date: Thu, 12 Mar 2015 13:19:44 -0500
Message-ID: <87385a13jz.fsf@x220.int.ebiederm.org>
References: <1426078702-23246-1-git-send-email-rshearma@brocade.com>
	<87sidba1ea.fsf@x220.int.ebiederm.org> <5500BB5E.4070909@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50606 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbbCLSX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:23:27 -0400
In-Reply-To: <5500BB5E.4070909@brocade.com> (Robert Shearman's message of
	"Wed, 11 Mar 2015 22:02:06 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> On 11/03/15 17:29, Eric W. Biederman wrote:
>> Robert Shearman <rshearma@brocade.com> writes:
>>
>>> This ensures that if a routing protocol incorrectly advertises a label
>>> for a prefix whose address-family is inconsistent with that of the
>>> nexthop, then the traffic will be dropped, rather than the issue being
>>> silently worked around.
>>
>> The address family of the next hop need have no particular relationship
>> to the address families you can send to the next hop.  As such I
>> consider the behavior your are proposing here actively wrong.  It
>> appears to block valid use cases such as using a single mpls label
>> to carry both ipv4 and ipv6 traffic simply because we use an ipv4 next
>> hop.
>>
>> I am not opposed to adding configurability to force the issue,
>> especially as unexpected traffic may be a problem but I don't think
>> that should be the default.
>
> Having read RFC 3032 section 2.2, I realise that my original intention was
> misguided. However, as labels are allocated and advertised locally and so the
> implementation gets to decide what labels are used for, then I think the
> statement of this being actively wrong is a bit too strong. Allowing the
> carrying of IPv4 and IPv6 traffic using the same attached nexthop route means
> our implementation to won't be able to use a single cached hardware header
> associated with the neighbour (although admittedly it would require reworking
> for it to be usable here anyway).

What I meant by actively wrong is that the abstraction with the
neighbour table entries is independent of the protocol used.   If that
was not the case we would not be able to use them for mpls traffic.
Imposing funny limits when it is just ipv4 traffic coming out of a
tunnel I think would be confusing.

As for the hardware headers.  If someone wants to benchmark things
I think we could support it comparitively easily in this interface
by having perhaps 3 cached hardware headers.  1 for ipv4, 1 for ipv6
and 1 for mpls in an array in the neighbour table.  Strangely enough
the cached hardware header is smaller than the hardware address
in the neighbour table entry.

> In my experience of MPLS (which admittedly lacks TP) there is no MPLS
> application that will allocate a label to forward traffic to an attached nexthop
> that will carry both IPv4 and IPv6 traffic. The only exception I can think of is
> statically configured labels, but there is no reason why you can't use two
> labels with appropriate nexthops.

I know the Forwrading-Equivalence-Class to label mapping would need to
be distinct mappings.  But I do find that surprising that no one has
implemented a tunnels that carry both v4 and v6 traffic.

The scenario that I keep imagining is a datacenter where there are mpls
tunnels to every machine, with the mpls network not carrying if you are
running v4 or v6 it just has a single tunnel to each machine.  That
seems like the sensible way to construct things.  Especially since
the a single MPLS lable overhead is the same as the VLAN header
overhead.  So you would not need to reduce your MTU below 1500 bytes.

Also reading RFC4364 BGP/MPLS and RFC4659 BGP/MPLS v6 seem describe
operating an all ipv4 core network with ipv6 and ipv4 at the edges.
I may have missed an extra label for tunnel somewhere but it definitely
works to have a minimum number of tunnels through the core network.

> Since adding such a restriction after this has shipped will have implications
> for anybody relying on it, we should consider the implications of being too
> liberal with what the kernel accepts.

I agree.  If there are good reasons not to do this I am game.  So far
minimizing the number of tunnels in the network and keeping the network
as simple as possible seems to strongly suggest that having both v4 and
v6 in a single tunnel is a good idea.

The only reason I can think of for having separate tunnels is so that
you someone can play anycast on the local subnet games with arp or
neighbour discovery.  But that should be rare.

>> I think the default for a tunnel egress should
>> be assume everyone sticking packets in that tunnel are playing nice so
>> we should decode as much as possible.
>
> Naturally - the entire MPLS core is one big trust domain and the PEs have to be
> trusted to be doing the right thing. My point was more about restricting what
> the local control plane can do in terms of allocating labels while we have the
> freedom to do so.
>
> That raises a related issue - as it stands today, with the kernel module loaded
> any interface can receive and process MPLS traffic. If this implementation is to
> act as a PE, then it's imperative we come up with a mechanism of ensuring that
> MPLS packets are only processed on interfaces that the operator has explicitly
> configured.

I started at minimal and simple.  Per interface forwarding and mtu knobs
are likely desirable.

But please note even with the module loaded mpls packets will be ignored
until someone sets the mpls platform label table size to non-zero.

We also have per interface controls if we want to place different
interfaces in different network namespaces, and get different mpls label
tables and different ip forwarding tables.

>>> The accessible skb length should also be validated prior to the IPv4
>>> or IPv6 headers being accessed, since only the label header will have
>>> previously been validated.
>>
>> I agree I goofed by not including the appropriate pskb_may_pull checks.
>> And that needs to be fixed.
>>
>>> Rename mpls_egress to mpls_egress_to_ip to make it more obvious that
>>> the function is used for traffic going out as IP, not for labeled
>>> traffic (or for the not-yet-implemented pseudo-wires).
>>
>> I disagree.
>>
>> The name of the function needs to be mpls_egress, and it should be
>> eventually expanded to handle as many cases are reasonable.  With the
>> default being to start the decode of packets by looking at the first
>> nibble.
>>
>> Without explicit configuration it seems entirely reasonable to assume
>> that if the first nibble is 4 it is an ipv4 packet.  If the first nibble
>> is 6 it is an ipv6 packet.  If the first nibble is 1 it is a generic
>> association channel.  If the first nibble is 0 it has a control word and
>> it is a pseudo wire where the output tunnel type matches the output
>> device.
>
> The intention of RFC 4385 was that the control word be used to prevent the
> payload of an MPLS packet being wrongly as interpreted by intermediate routers
> (e.g. as the RFC states for ECMP, or for ICMP generation). IMHO the intention
> wasn't to allow the first nibble to be used as a protocol field with 0/1 meaning
> L2.

Which in a lot of ways is a weirdness of MPLS there is no well defined
way of just looking at a packet and seeing what the contents should be.
Given that there are standards that at least first glance seem to be
widely deployed that actually allows us to decode what is a packet
without lots of state and context I think it useful to encourage the
use of those standards.  Especially when we get to define what the
labels are or can be used for on our end.

> While I can't think of any concrete concerns, I do feel very uneasy about a
> payload being sent out directly as L2 without the control plane explicitly
> specifying this as the intention for the label route.

Fair enough.  From a be liberal in what you accept and make the easy
things easy perspective it seems like the right thing to me.  At the
same time we haven't implemented any of that yet.  So we can examine it
all in detail when the time comes.

>> A handful of pseudo wires do things differently.  SONET sets bits in the
>> first nibble, Ethernet has cases where it does not include the control
>> word and as such the first nible might not be zero.   And then we have
>> oddball cases that need configuration such as should the ethernet
>> control words sequence number be honored.
>
> Just to clarify, the issue is more that in such cases without a control word the
> first nibble could be 0, 1, 4 or 6. I've seen PW deployments not using control
> words due to some devices not supporting them. I agree that we'll have to
> consider how the configuration of such cases will work.

Agreed.  For whatever it is worth RFC4448 says it is a must to support
ethernet without a control word.  So we don't have to get esoteric for
this issue to come up.

>> I admit that supporting ethernet and similiar pseudo wires will require
>> the arguments to mpls_egress to be changed a little so that we can skip
>> taking the next hop address link layer address from the mpls_route, but
>> that does not mean we should just through it under a bus.
>>
>> Fundamentally mpls_egress is the function that we call when the bottom
>> of stack indicator is reached.  It should either figure out that the
>> packet can be forwarded or it should indicate that the packet should be
>> dropped.
>
> I don't want to get too drawn into a discussion on what the code will look like
> with PW implemented, but I had imagined that mpls_forward would be refactored
> such that it would be known from the route lookup that this was an PW route with
> or without a control word, and the parsing of the first nibble wouldn't be
> necessary.

What I don't currently have in mpls_route is a distinction between
popping a label and popping a final label.  If we want to draw such a
distinction now would be a good time to have that conversation.

Eric
