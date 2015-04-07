From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 2/4] mpls: Differentiate implicit-null and unlabeled neighbours
Date: Tue, 07 Apr 2015 11:56:15 -0500
Message-ID: <87pp7fkhcg.fsf@x220.int.ebiederm.org>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40557 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbDGRAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:00:19 -0400
In-Reply-To: <1427739356-28113-3-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 30 Mar 2015 19:15:54 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> The control plane can advertise labels for neighbours that don't have
> an outgoing label. RFC 3031 s3.22 states that either the remaining
> labels should be popped (if the control plane can determine that it's
> safe to do so, which in light of MPLS-VPN, RFC 4364, is never the case
> now) or that the packet should be discarded.
>
> Therefore, if the peer is unlabeled and the last label wasn't popped
> then drop the packet. The peer being unlabeled is signalled by an
> empty label stack. However, penultimate hop popping still needs to be
> supported (RFC 3031 s4.1.5) where the incoming label is popped and no
> labels are put on and the packet can still go out labeled with the
> remainder of the stack. This is achieved by the control plane
> specifying a label stack consisting of the single special
> implicit-null value.

I disagree with this approach to limiting what can be in an mpls tunnel.
I agree that it would be nice to limit what is an mpls tunnel.

However I want the code and semantics as clean as we can make them.

So what I suggest is to add something like

RTA_PSEUDOWIRE

That has a integer for a type with values like:

PW_FRAME_RELAY_DLCI	0x0001
PW_ATM_AAL5_SDU		0x0002
PW_ATM_TRANSPARENT_CELL 0x0003
PW_ETHERNET_TAGGED	0x0004
PW_ETHERNET		0x0005
PW_HDLC			0x0006
PW_PPP			0x0007
PW_IP			0x000B

Roughly the values from the psedo wire registry
http://www.iana.org/assignments/pwe3-parameters/pwe3-parameters.xhtml

That won't quite work because psedo wires are a subset of what
can be transported over an MPLS network, and a superset of what
we implement in the kernel.  So we need a different identifier.

In passing I will note that the current implementation defaults to
pseudo wire type 0x000B IP layer2 transport.  Which can carry both ipv4
and ipv6 traffic, as well as a generic associated channel.  So unlike
being a weird except to rules what I have actually implemented is
well enough specified that you can signal it.

So for sake of argument let's call it.

RTA_MPLS_PAYLOAD_TYPE

And have values, something like.

#define MPLS_PL_IPV4		0x4
#define MPLS_PL_IPV6		0x6
#define MPLS_PL_MPLS		0x10
#define MPLS_PL_ETHERNET_TAGGED	0x14
#define MPLS_PL_ETHERNET	0x15
#define MPLS_PL_IP		0x1B


And have the semantics be that if you have foreced the payload type with
the attribute and the packet does not match the specified payload we
drop the packet.  Not having the BOS set for anything except for
MPLS_PL_MPLS would be such an error that would cause the packet to
be dropped, and having BOS set for MPLS_PL_MPLS would be an error.

Where I am defining MPLS_PL_MPLS to be the payload type of a label
that transports mpls traffic and is not expected to end at this node.

Although I am not certain that you care about the case I am describing
being handled by MPLS_PL_MPLS.

We should also refuse to accept labels with the implicit NULL set in the 
RTA_NEWDST attribute.

I have read through a bunch of RFCs and I have not seen your distinction
between implict NULL and unlabled show up anywhere quite the way you are
making it.   Regardless what you are trying to do seems to be a
transference from a signalling protocol to the rtnetlink attributes that
mixes semantics.

The current rtnetlink attribute semantics are clean simple and easy to
understand.  When you see the label RTA_DST you remove it and you apply
the label RTA_NEWDST. 

I find playing games with implicit NULL as opposed to using an
RTA_MPLS_PAYLOAD_TYPE type to be mixing of unconnected things and likely
to lead to maintenance problems in the future.

Your reference to RFC3031 section 3.22 also does not work to justify
this behavior as RFC3031 is about receiving a packet that whose top most
label is not in the label table.

In short I think the packet handling semantics you are after are quite
reasonable but your approach is unnecessarily complicated, and
confusing.

Eric
