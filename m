From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: Weird problem with PPPoE on tap interface
Date: Mon, 26 Feb 2007 11:29:08 +0100
Message-ID: <20070226102908.GD3318@florz.florz.dyndns.org>
References: <20070225195455.GC3318@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@speakeasy.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbfba0.pool.mediaWays.net ([217.187.251.160]:4873 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbXBZLQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 06:16:53 -0500
Content-Disposition: inline
In-Reply-To: <20070225195455.GC3318@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I'm experiencing a pretty strange problem with kernel PPPoE on tap
> interfaces with a vanilla 2.6.20 kernel that prevents the PPP connection
> from being established:
[...]

Well, I guess I have found the source of the problem: The PPPoE code seems
to match inbound packets to sockets based only on source address and
session ID - so in the given scenario, packets are delivered to pppd
once when they arrive at the "real" ethernet interface and a second time
when they arrive at the tap interface. Now, this is kindof two problems,
actually:

1. This is not in compliance with RFC 2516, which states in section 4:

   | The SESSION_ID field is sixteen bits.  It is an unsigned value in
   | network byte order.  It's value is defined below for Discovery
   | packets.  The value is fixed for a given PPP session and, in fact,
   | defines a PPP session along with the Ethernet SOURCE_ADDR and
   | DESTINATION_ADDR.

   So, it would be legal for there to be multiple sessions with the same
   peer using the same session ID, as long as they are using different
   local MAC addresses - but the current PPPoE code would not be able to
   distinguish those.

   This probably is not a problem for me, but should be fixed anyway,
   IMO. (I say "probably" since I am actually using different local MAC
   addresses for multiple PPPoE sessions to the same DSL-AC, as T-Com
   doesn't allow for multiple sessions from the same MAC address -
   so they would be allowed by the RFC to use the same session ID for
   more than one of those sessions, even though I doubt that they're
   doing that.)

2. In addition to session ID, source and destination address, IMO, the
   incoming interface should be added to the key that's used for
   matching packets to sockets. This is probably somewhat of a design
   decision much like the weak ES vs. strong ES issue with IP, but
   AFAICS, the userspace-API works by binding to an interface index, not
   by binding to a MAC address (unlike IP socket binding), which is why
   I'd expect from pppd's perspective that only packets from that
   interface are delivered.

   Plus, from the end user's perspective, this might even be somewhat of
   a security problem. I for one would (well, I obviuosly _did_ :-)
   expect that if I do specify an interface name in pppd's config,
   pppd won't get into contact with anything that's going on on
   interfaces other than the one specified. As the involved MAC addresses
   probably usually aren't considered a secret, all you'd have to guess
   in order to interfere with/inject packets into PPPoE sessions "on a
   different interface" is the 16-bit session identifier, which might not
   even be random.

Well, your opinions are welcome. Plus any hints as to how to fix this.
I'd tend to simply(?) add some more fields to the
{hash,get,set,delete}_item() functions in drivers/net/pppoe.c.
But maybe there is some better way?

Florian
