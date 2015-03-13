From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls: Infer payload of packet from via address
 family.
Date: Fri, 13 Mar 2015 14:51:23 +0000
Message-ID: <5502F96B.6030407@brocade.com>
References: <1426078702-23246-1-git-send-email-rshearma@brocade.com>	<87sidba1ea.fsf@x220.int.ebiederm.org> <5500BB5E.4070909@brocade.com> <87385a13jz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41563 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756143AbbCMOva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:51:30 -0400
In-Reply-To: <87385a13jz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/15 18:19, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> On 11/03/15 17:29, Eric W. Biederman wrote:
>>> Robert Shearman <rshearma@brocade.com> writes:
>>>
>>>> This ensures that if a routing protocol incorrectly advertises a label
>>>> for a prefix whose address-family is inconsistent with that of the
>>>> nexthop, then the traffic will be dropped, rather than the issue being
>>>> silently worked around.
>>>
>>> The address family of the next hop need have no particular relationship
>>> to the address families you can send to the next hop.  As such I
>>> consider the behavior your are proposing here actively wrong.  It
>>> appears to block valid use cases such as using a single mpls label
>>> to carry both ipv4 and ipv6 traffic simply because we use an ipv4 next
>>> hop.
>>>
>>> I am not opposed to adding configurability to force the issue,
>>> especially as unexpected traffic may be a problem but I don't think
>>> that should be the default.
>>
>> Having read RFC 3032 section 2.2, I realise that my original intention was
>> misguided. However, as labels are allocated and advertised locally and so the
>> implementation gets to decide what labels are used for, then I think the
>> statement of this being actively wrong is a bit too strong. Allowing the
>> carrying of IPv4 and IPv6 traffic using the same attached nexthop route means
>> our implementation to won't be able to use a single cached hardware header
>> associated with the neighbour (although admittedly it would require reworking
>> for it to be usable here anyway).
>
> What I meant by actively wrong is that the abstraction with the
> neighbour table entries is independent of the protocol used.   If that
> was not the case we would not be able to use them for mpls traffic.
> Imposing funny limits when it is just ipv4 traffic coming out of a
> tunnel I think would be confusing.

Agreed. How about adding a netlink attribute indicating the FEC, or at 
least the address family in the case of IP FECs? That would then give a 
an indicator of the traffic that the LSP is carrying, regardless of 
nexthop type. The same method could then be used to indicate whether the 
label route is for a PW and then the presence or lack or control word.

> As for the hardware headers.  If someone wants to benchmark things
> I think we could support it comparitively easily in this interface
> by having perhaps 3 cached hardware headers.  1 for ipv4, 1 for ipv6
> and 1 for mpls in an array in the neighbour table.  Strangely enough
> the cached hardware header is smaller than the hardware address
> in the neighbour table entry.
>
>> In my experience of MPLS (which admittedly lacks TP) there is no MPLS
>> application that will allocate a label to forward traffic to an attached nexthop
>> that will carry both IPv4 and IPv6 traffic. The only exception I can think of is
>> statically configured labels, but there is no reason why you can't use two
>> labels with appropriate nexthops.
>
> I know the Forwrading-Equivalence-Class to label mapping would need to
> be distinct mappings.  But I do find that surprising that no one has
> implemented a tunnels that carry both v4 and v6 traffic.

This is a use case for TE tunnels. However, the accepted practice is to 
add an IPv6 Explicit NULL label to differentiate IPv4 from IPv6 traffic 
over the tunnel.

Furthermore, in discussions with Stewart Bryant (author of a number of 
IETF RFCs, including 4385) and he wasn't aware of any significant 
existing implementations that carry IPv4 and IPv6 traffic using the same 
label. He was also of the opinion that by doing this we'd be "attempting 
to swim upstream". Furthermore, as the carrying of one type of traffic 
for a given label is considered status quo, then this could cause it to 
be treated as an invariant on which current (there are over 100 RFCs 
relating to MPLS and I certainly haven't read them all) or future 
changes to MPLS are based upon.

> The scenario that I keep imagining is a datacenter where there are mpls
> tunnels to every machine, with the mpls network not carrying if you are
> running v4 or v6 it just has a single tunnel to each machine.  That
> seems like the sensible way to construct things.  Especially since
> the a single MPLS lable overhead is the same as the VLAN header
> overhead.  So you would not need to reduce your MTU below 1500 bytes.

Using a label each for IPv4 and IPv6 is still possible if that is a 
requirement. Note that labels are local in nature (ignoring Segment 
Routing) so you would only hit the label limit if one router needed to 
communicate with ~2^19 machines at once, which seems a lot to me. Note 
that BGP has much higher scales especially when using VPNs and solves 
the issue using per-CE or per-VRF labels

> Also reading RFC4364 BGP/MPLS and RFC4659 BGP/MPLS v6 seem describe
> operating an all ipv4 core network with ipv6 and ipv4 at the edges.
> I may have missed an extra label for tunnel somewhere but it definitely
> works to have a minimum number of tunnels through the core network.

Yes, when using MPLS-VPN of either address family there will always be 
an extra label for the BGP FECs because otherwise you would lose the 
discrimination of which VPN the traffic belongs to, either when using 
PHP or when looking up the destination on the PE router after the final 
label pop.

>> Since adding such a restriction after this has shipped will have implications
>> for anybody relying on it, we should consider the implications of being too
>> liberal with what the kernel accepts.
>
> I agree.  If there are good reasons not to do this I am game.  So far
> minimizing the number of tunnels in the network and keeping the network
> as simple as possible seems to strongly suggest that having both v4 and
> v6 in a single tunnel is a good idea.

I'm fine with keeping that an option with the above suggestion of the 
netlink attribute, for users that want to take that gamble. However, I'd 
also like the option of a control plane that wants to only use a label 
for one traffic type at a time can specify this to guard against bugs 
and allow better observability of the MPLS label table to the operator.

>>>> Rename mpls_egress to mpls_egress_to_ip to make it more obvious that
>>>> the function is used for traffic going out as IP, not for labeled
>>>> traffic (or for the not-yet-implemented pseudo-wires).
>>>
>>> I disagree.
>>>
>>> The name of the function needs to be mpls_egress, and it should be
>>> eventually expanded to handle as many cases are reasonable.  With the
>>> default being to start the decode of packets by looking at the first
>>> nibble.
>>>
>>> Without explicit configuration it seems entirely reasonable to assume
>>> that if the first nibble is 4 it is an ipv4 packet.  If the first nibble
>>> is 6 it is an ipv6 packet.  If the first nibble is 1 it is a generic
>>> association channel.  If the first nibble is 0 it has a control word and
>>> it is a pseudo wire where the output tunnel type matches the output
>>> device.
>>
>> The intention of RFC 4385 was that the control word be used to prevent the
>> payload of an MPLS packet being wrongly as interpreted by intermediate routers
>> (e.g. as the RFC states for ECMP, or for ICMP generation). IMHO the intention
>> wasn't to allow the first nibble to be used as a protocol field with 0/1 meaning
>> L2.
>
> Which in a lot of ways is a weirdness of MPLS there is no well defined
> way of just looking at a packet and seeing what the contents should be.
> Given that there are standards that at least first glance seem to be
> widely deployed that actually allows us to decode what is a packet
> without lots of state and context I think it useful to encourage the
> use of those standards.  Especially when we get to define what the
> labels are or can be used for on our end.

The lack of a protocol type in the packet is just a fact of the MPLS 
protocol. RFC 3032 states that the label is the primary source of what 
is encapsulated.

In my discussion with one of the authors of RFC 4385 it was stated to me 
in no uncertain terms that the label is the indicator that this is a PW 
packet and that the introduction of the control word wasn't intended to 
distinguish an IP packet from a PW packet. Instead the type of the 
encapsulated traffic should be determined from the label, not from the 
payload. Doing the contrary would be diverging from how the rest of the 
industry has implemented it and. moreover, could lead to issues that 
authors of RFCs never considered, because the use was considered outside 
of accepted practice.

>>> I admit that supporting ethernet and similiar pseudo wires will require
>>> the arguments to mpls_egress to be changed a little so that we can skip
>>> taking the next hop address link layer address from the mpls_route, but
>>> that does not mean we should just through it under a bus.
>>>
>>> Fundamentally mpls_egress is the function that we call when the bottom
>>> of stack indicator is reached.  It should either figure out that the
>>> packet can be forwarded or it should indicate that the packet should be
>>> dropped.
>>
>> I don't want to get too drawn into a discussion on what the code will look like
>> with PW implemented, but I had imagined that mpls_forward would be refactored
>> such that it would be known from the route lookup that this was an PW route with
>> or without a control word, and the parsing of the first nibble wouldn't be
>> necessary.
>
> What I don't currently have in mpls_route is a distinction between
> popping a label and popping a final label.  If we want to draw such a
> distinction now would be a good time to have that conversation.

Yes, that would be highly desirable in the case of MPLS-VPN where a 
label route is added via CE. In order to prevent unexpected MPLS traffic 
being sent to the CE (perhaps MPLS-OAM), the control plane would want to 
ask the dataplane to install an "unlabeled" entry where packets with the 
BOS bit not set should be dropped.

I'd like to propose that we change the semantics of no labels being 
specified to be: pop and forward if BOS bit set, drop if BOS not set. 
Then we can allow the control plane to specify a label value with the 
reserved implicit-null value which wouldn't be put into a packet, but 
translated into pop and forward regardless of BOS bit (i.e. IP if BOS 
set, MPLS if BOS not set).

Thanks,
Rob
