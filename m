From: Chris Siebenmann <cks@cs.toronto.edu>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Thu, 10 Nov 2011 00:16:49 -0500
Message-ID: <20111110051649.505C8362D2@apps0.cs.toronto.edu>
References: <1320761153.3444.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Cc: Chris Siebenmann <cks@cs.toronto.edu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:42684 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933921Ab1KJFQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 00:16:50 -0500
In-reply-to: eric.dumazet's message of Tue, 08 Nov 2011 15:05:53 +0100.
             <1320761153.3444.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| So it appears the drop is in gre xmit because frame is bigger than
| mtu...
| 
| Maybe you receive some strange ICMP (ICMP_FRAG_NEEDED) from a buggy
| host ?
| 
| You could catch it with "tcpdump -s 1000 -i any icmp" maybe...

 The problem went away for several days and then came roaring back
just now. I couldn't see any outside ICMP messages like this while
the problem was happening. I did see ICMP messages, but they were
locally generated:

	IP 128.100.3.52 > 128.100.3.52: ICMP 128.100.3.51 unreachable - need to frag (mtu 478), length 556

(I verified that these were for the things that were stalling with
'tcpdump -vv -ee'.)

At the time that this was happening, I could see a lot of 'ip route show
table cache' entries like this:

	128.100.3.58 from 66.96.18.208 dev ppp0  src 66.96.18.208
	    cache  expires 286sec ipid 0xdeda mtu 552 rtt 44ms rttvar 30ms ssthresh 7 cwnd 9 iif lo

There were a bunch of other 'mtu 552' routes. Flushing the routing cache
(with 'ip route flush cache; ip route show table cache' to verify that
it had flushed) did not change the situation; the problem continued and
the 'mtu 552' routes came back as fast as I could check (it appeared to
be the moment that the routing cache was repopulated, there they were).

 In general the route cache appears to have strangely low MTUs listed
for the remote end of the tunnel (at least after the problem's
happened), eg:

	128.100.3.58 from 66.96.18.208 dev ppp0 
	    cache  expires 203sec ipid 0xdeda mtu 934 rtt 44ms rttvar 30ms ssthresh 7 cwnd 9
	128.100.3.58 from 66.96.18.208 dev ppp0  src 66.96.18.208 
	    cache  expires 203sec ipid 0xdeda mtu 934 rtt 44ms rttvar 30ms ssthresh 7 cwnd 9 iif lo

I would normally expect this to be 1492, the PPP link MTU.

 This does not seem to happen on the Fedora 14 kernel (the one where
the problem doesn't happen). There the route is listed as:

	128.100.3.58 from 66.96.18.208 dev ppp0 
	    cache  mtu 1492 advmss 1452 hoplimit 64
	128.100.3.58 from 66.96.18.208 dev ppp0 
	    cache  mtu 1492 advmss 1452 hoplimit 64

(to quote what I *think* are the relevant entries.)

 Since things may be pointing towards routing cache oddities, I should
mention that I have a somewhat peculiar policy based routing setup
involving this GRE tunnel. While it's been working fine for literally
years, it's possible that recent changes in the area changed something
so that peculiar things now happen; if you think it might be relevant, I
can provide a dump of the routing rules and explain the setup.

(Part of why this occurs to me now is that I know it's possible to have
a connection to 128.100.3.58 (the remote end of the tunnel) that runs
through the tunnel itself, and I've seen such routes appear in the 'ip
route show table cache' output.)

		- cks
