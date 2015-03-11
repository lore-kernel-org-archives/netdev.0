From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Infer payload of packet from via address family.
Date: Wed, 11 Mar 2015 12:29:17 -0500
Message-ID: <87sidba1ea.fsf@x220.int.ebiederm.org>
References: <1426078702-23246-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:52865 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbCKRdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:33:00 -0400
In-Reply-To: <1426078702-23246-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Wed, 11 Mar 2015 12:58:22 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> This ensures that if a routing protocol incorrectly advertises a label
> for a prefix whose address-family is inconsistent with that of the
> nexthop, then the traffic will be dropped, rather than the issue being
> silently worked around.

The address family of the next hop need have no particular relationship
to the address families you can send to the next hop.  As such I
consider the behavior your are proposing here actively wrong.  It
appears to block valid use cases such as using a single mpls label
to carry both ipv4 and ipv6 traffic simply because we use an ipv4 next
hop.

I am not opposed to adding configurability to force the issue,
especially as unexpected traffic may be a problem but I don't think that
should be the default.  I think the default for a tunnel egress should
be assume everyone sticking packets in that tunnel are playing nice so
we should decode as much as possible.

> The accessible skb length should also be validated prior to the IPv4
> or IPv6 headers being accessed, since only the label header will have
> previously been validated.

I agree I goofed by not including the appropriate pskb_may_pull checks.
And that needs to be fixed.

> Rename mpls_egress to mpls_egress_to_ip to make it more obvious that
> the function is used for traffic going out as IP, not for labeled
> traffic (or for the not-yet-implemented pseudo-wires).

I disagree.

The name of the function needs to be mpls_egress, and it should be
eventually expanded to handle as many cases are reasonable.  With the
default being to start the decode of packets by looking at the first
nibble.

Without explicit configuration it seems entirely reasonable to assume
that if the first nibble is 4 it is an ipv4 packet.  If the first nibble
is 6 it is an ipv6 packet.  If the first nibble is 1 it is a generic
association channel.  If the first nibble is 0 it has a control word and
it is a pseudo wire where the output tunnel type matches the output
device.

A handful of pseudo wires do things differently.  SONET sets bits in the
first nibble, Ethernet has cases where it does not include the control
word and as such the first nible might not be zero.   And then we have
oddball cases that need configuration such as should the ethernet
control words sequence number be honored.

I admit that supporting ethernet and similiar pseudo wires will require
the arguments to mpls_egress to be changed a little so that we can skip
taking the next hop address link layer address from the mpls_route, but
that does not mean we should just through it under a bus.

Fundamentally mpls_egress is the function that we call when the bottom
of stack indicator is reached.  It should either figure out that the
packet can be forwarded or it should indicate that the packet should be
dropped.

Eric
