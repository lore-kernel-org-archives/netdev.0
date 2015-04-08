From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v3 2/4] mpls: Differentiate implicit-null and
 unlabeled neighbours
Date: Wed, 8 Apr 2015 18:08:51 +0100
Message-ID: <552560A3.5060603@brocade.com>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>	<1427739356-28113-1-git-send-email-rshearma@brocade.com>	<1427739356-28113-3-git-send-email-rshearma@brocade.com> <87pp7fkhcg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:25119 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875AbbDHRI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:08:58 -0400
In-Reply-To: <87pp7fkhcg.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/15 17:56, Eric W. Biederman wrote:
> Robert Shearman <rshearma@brocade.com> writes:
>
>> The control plane can advertise labels for neighbours that don't have
>> an outgoing label. RFC 3031 s3.22 states that either the remaining
>> labels should be popped (if the control plane can determine that it's
>> safe to do so, which in light of MPLS-VPN, RFC 4364, is never the case
>> now) or that the packet should be discarded.
>>
>> Therefore, if the peer is unlabeled and the last label wasn't popped
>> then drop the packet. The peer being unlabeled is signalled by an
>> empty label stack. However, penultimate hop popping still needs to be
>> supported (RFC 3031 s4.1.5) where the incoming label is popped and no
>> labels are put on and the packet can still go out labeled with the
>> remainder of the stack. This is achieved by the control plane
>> specifying a label stack consisting of the single special
>> implicit-null value.
>
> I disagree with this approach to limiting what can be in an mpls tunnel.
> I agree that it would be nice to limit what is an mpls tunnel.
>
> However I want the code and semantics as clean as we can make them.
>
> So what I suggest is to add something like
>
> RTA_PSEUDOWIRE
>
> That has a integer for a type with values like:
>
> PW_FRAME_RELAY_DLCI	0x0001
> PW_ATM_AAL5_SDU		0x0002
> PW_ATM_TRANSPARENT_CELL 0x0003
> PW_ETHERNET_TAGGED	0x0004
> PW_ETHERNET		0x0005
> PW_HDLC			0x0006
> PW_PPP			0x0007
> PW_IP			0x000B
>
> Roughly the values from the psedo wire registry
> http://www.iana.org/assignments/pwe3-parameters/pwe3-parameters.xhtml
>
> That won't quite work because psedo wires are a subset of what
> can be transported over an MPLS network, and a superset of what
> we implement in the kernel.  So we need a different identifier.
>
> In passing I will note that the current implementation defaults to
> pseudo wire type 0x000B IP layer2 transport.  Which can carry both ipv4
> and ipv6 traffic, as well as a generic associated channel.  So unlike
> being a weird except to rules what I have actually implemented is
> well enough specified that you can signal it.

Note that the G-ACh cannot appear raw over the LSP:

RFC5586 s4:
>    Generalizing the associated control channel mechanism to LSPs and
>    Sections also requires a method to identify that a packet contains an
>    ACH followed by a non-service payload.  This document specifies that
>    a label is used for that purpose and calls this special label the
>    G-ACh Label (GAL).

I'd also like to further note that there are semantic differences 
between a pseudo-wire and a regular LSP, which are analogous to the 
difference between a switch and a router. The most important difference 
is that the TTL is never propagated either on ingress or egress from the 
LSP. There could be more minor differences regarding fragmentation on 
imposition, ICMP generation and the treatment of multicast traffic.

>
> So for sake of argument let's call it.
>
> RTA_MPLS_PAYLOAD_TYPE
>
> And have values, something like.
>
> #define MPLS_PL_IPV4		0x4
> #define MPLS_PL_IPV6		0x6
> #define MPLS_PL_MPLS		0x10
> #define MPLS_PL_ETHERNET_TAGGED	0x14
> #define MPLS_PL_ETHERNET	0x15
> #define MPLS_PL_IP		0x1B
>
>
> And have the semantics be that if you have foreced the payload type with
> the attribute and the packet does not match the specified payload we
> drop the packet.  Not having the BOS set for anything except for
> MPLS_PL_MPLS would be such an error that would cause the packet to
> be dropped, and having BOS set for MPLS_PL_MPLS would be an error.
>
> Where I am defining MPLS_PL_MPLS to be the payload type of a label
> that transports mpls traffic and is not expected to end at this node.
>
> Although I am not certain that you care about the case I am describing
> being handled by MPLS_PL_MPLS.

I'm happy to go with this approach, but the semantics I'm looking for 
are that a label signaled for the purposes of PHP can carry both IPv4/6 
and MPLS, but a label signaled at the end of an LSP (when not using PHP, 
i.e. for L3VPN or because of an LDP problem) can only carry IPv4/6.

Furthermore, I can't think of a use case for an LSP that can only carry 
other LSPs.

Therefore, I see several options here:
1. Make the payload type a bitmask. This doesn't seem very attractive to 
me as most combinations (e.g. Ethernet|ATM) wouldn't be valid.
2. Introduce further MPLS_PL_IPV4_MPLS and MPLS_PL_IPV6_MPLS options 
that would indicate that the payload could be IPv4/6 or that it's valid 
for there to be further labels.
3. Extract out the property of whether LSP can carry other LSPs or not 
so that it's separate from the payload type.

Any other suggestions? Would what be your preference?

Due to the semantic differences above, no matter which approach is taken 
there will need to be a separate type (or types with option 2) for an 
LSP that can carry both IPv4 and IPv6 traffic that isn't a pseudo-wire 
to preserve the existing desired behaviour.

In addition, the property of whether a control word is present or not is 
common for each PW type so that should be represented an a separate 
property within the same route attribute.

> We should also refuse to accept labels with the implicit NULL set in the
> RTA_NEWDST attribute.

Agreed, in conjunction with this alternative approach.

> I have read through a bunch of RFCs and I have not seen your distinction
> between implict NULL and unlabled show up anywhere quite the way you are
> making it.   Regardless what you are trying to do seems to be a
> transference from a signalling protocol to the rtnetlink attributes that
> mixes semantics.
>
> The current rtnetlink attribute semantics are clean simple and easy to
> understand.  When you see the label RTA_DST you remove it and you apply
> the label RTA_NEWDST.
>
> I find playing games with implicit NULL as opposed to using an
> RTA_MPLS_PAYLOAD_TYPE type to be mixing of unconnected things and likely
> to lead to maintenance problems in the future.

I can certainly understand that. The reasoning for taking this approach 
was that defining a new netlink route attribute seemed quite heavyweight 
for solving this problem in isolation. However, as you quite rightly 
suggest the attribute could be used for signaling other properties as well.

> Your reference to RFC3031 section 3.22 also does not work to justify
> this behavior as RFC3031 is about receiving a packet that whose top most
> label is not in the label table.

Ok, I can see that there is some ambiguity in that section that means 
that alone it could be read as referring to the top-most label being 
missing from the label table. However, there is another section (s3.18. 
Invalid Incoming Labels - 
https://tools.ietf.org/html/rfc3031#section-3.18) that deals explicitly 
with that case. Therefore, I believe that in conjunction with the 
statement in s3.22 stating "even though the incoming label is itself 
valid" and the title of the section ("Lack of Outgoing Label") the 
intention of the authors was to refer to the case I'm trying to address, 
i.e. that the next-hop is known, but there's no next-hop label 
forwarding entry.

> In short I think the packet handling semantics you are after are quite
> reasonable but your approach is unnecessarily complicated, and
> confusing.

Ok, thanks for the review.

>
> Eric
>
