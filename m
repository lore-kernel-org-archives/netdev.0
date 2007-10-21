From: Andrew McDonald <andrew@mcdonald.org.uk>
Subject: Re: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Sun, 21 Oct 2007 18:51:40 +0100
Message-ID: <20071021175139.GE28453@mcdonald.org.uk>
References: <20071014111147.GE20850@mcdonald.org.uk> <Pine.LNX.4.64.0710150849580.17284@netcore.fi> <20071016201550.GC28453@mcdonald.org.uk> <Pine.LNX.4.64.0710170911360.21784@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from widget.mcdonald.org.uk ([81.187.72.227]:1990 "EHLO
	widget.mcdonald.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902AbXJURvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 13:51:42 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710170911360.21784@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 09:19:15AM +0300, Pekka Savola wrote:
> Router alert option on a hop-by-hop header means that every router on 
> the path should process the option.

I think I understand what you mean  by "process the option", but it is
a little ambiguous.

The abstract of RFC2711 says:
   This memo describes a new IPv6 Hop-by-Hop Option type that alerts
   transit routers to more closely examine the contents of an IP
   datagram.  This option is useful for situations where a datagram
   addressed to a particular destination contains information that may
   require special processing by routers along the path.
note the "may require special processing by routers" - there is no
expectation that /every/ router will want to do such "special
processing".

For example, there is no expectation that every router supports RSVP.
Non-RSVP routers are simply expected to look the router alert option,
decide they aren't interested in it and forward it normally.

> You did not mention the rationale why the it would be reasonable for a 
> packet that would otherwise be forwarded by the Linux router and 
> expected to be processed by every router on the path to be re-created 
> at every step, and every user-space application have to do that.

I'm confused by your description.

There is certainly no expectation that every router on the path would
be interested in doing "special processing" on the contents of the
packet.

The purpose of the IPV6_ROUTER_ALERT sockopt is so that a userspace
application can say "I'm here, and I'm interested in packets with a
router alert option with value field X." The default case where no
application has expressed an interest in this way is to forward the
packet normally. Anything else would be horrendously broken (though
that does currently apply to some BSD stacks).

> In the specific case of RSVP packets, AFAIK (e.g., Path and PathTear 
> messages), the content of the RSVP packet is expected to be the 
> same at every hop.
> 
> Your argument might make sense in the case where the payload of the 
> packet carrying router-alert option is expected to change at every 
> hop.  I believe that's not the intent of any router alert options that 
> I'm aware of.

The first sentence of the introduction of RFC2711 (IPv6 Router Alert
Option) clearly indicates that modification of packets can occur:
   New protocols, such as RSVP, use control datagrams which, while
   addressed to a particular destination, contain information that needs
   to be examined, and in some case updated, by routers along the path
   between the source and destination.  

To take a couple of examples in RSVP: The RSVP_HOP (PHOP) in a PATH
message is expected to change at each RSVP-capable node. Its purpose is
to tell the next hop the address of the previous hop, so that the RESV
can be sent hop-by-hop back along the path followed by the PATH
messages. The ADSPEC is designed to gather up information about
available resources along the path, so also has to be mutable along the
path in order to fulfil its purpose.

I hope that helps to clarify things.

-- 
Andrew McDonald
E-mail: andrew@mcdonald.org.uk
http://www.mcdonald.org.uk/andrew/
