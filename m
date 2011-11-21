From: Chris Siebenmann <cks@cs.toronto.edu>
Subject: Recursive routing causes MTU collapse (was Re: Bug? GRE tunnel periodically won't transmit some packets)
Date: Sun, 20 Nov 2011 19:23:34 -0500
Message-ID: <20111121002334.76F9F360D9@apps0.cs.toronto.edu>
References: <20111110051649.505C8362D2@apps0.cs.toronto.edu>
Cc: cks@cs.toronto.edu
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:41826 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab1KUAXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 19:23:35 -0500
In-reply-to: cks's message of Thu, 10 Nov 2011 00:16:49 -0500.
             <20111110051649.505C8362D2@apps0.cs.toronto.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I believe I've identified the root cause of my GRE tunnel packet
transmission problems. The short summary is that I have a 'recursive'
routing, where the route for the tunnel endpoint can nominally be routed
over the tunnel itself. In current kernel versions, when a packet for
the tunnel endpoint is actually routed over the tunnel the path MTUs
determined for the endpoint and the tunnel both collapse down to very
small values.

 Here is the routing I have. First, the links themselves, for the DSL
PPPoE device and the GRE tunnel:

3: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc pfifo_fast state UNKNOWN qlen 3
    link/ppp 
    inet 66.96.18.208 peer 66.96.31.6/32 scope global ppp0
5: extun: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1200 qdisc noqueue state UNKNOWN 
    link/gre 66.96.18.208 peer 128.100.3.58
    inet 128.100.3.52/32 scope global extun

(My IPSec policy forces GRE traffic between 128.100.3.58 and
66.96.18.208 to be encrypted in 'esp/tunnel' mode.)

 Now the recursion. To reach other machines on 128.100.3.0/24, I route
128.100.3.0/24 over the GRE tunnel:
	; ip route list match 128.100.3.51
	default dev ppp0  scope link
	128.100.3.0/24 dev extun  scope link

 I also have policy based routing set to force traffic with an IP
origin of 66.96.18.208 out over the PPP link and traffic with an
IP origin of 128.100.3.52 out the GRE tunnel.

 With this setup in place, if I do anything that tries to talk to
128.100.3.58 (such as ping or ssh) what I get is an immediate path
MTU collapse for the 66.96.18.208 -> 128.100.3.58 link used by the
GRE tunnel, ending when the path MTU for 66.96.18.208 -> 128.100.3.58
reaches 552 octets. At this point various things choke (I am guessing
because the GRE tunnel expects a minimum MTU of 576 octets).

 If I add a host route for 128.100.3.58 that forces traffic for it
through ppp0 I can mostly avoid this route collapse:
	; ip route list exact 128.100.3.58
	128.100.3.58 dev ppp0  scope link  src 66.96.18.208  mtu 1492

 However, even with this if I explicitly force traffic for 128.100.3.58
over the GRE tunnel (such as by specifying the IP source address
so as to make my policy based routing kick in) I still see the MTU
collapse. Using 'mtu lock 1492' instead of plain 'mtu 1492' on this
host-based route does not appear to change anything.

 This did not happen back in kernel 2.6.35.14 (the Fedora 14 kernel) and
previous kernels (going back years). In that kernel everything was happy
even without the ppp0-forcing host route for 128.100.3.58 and I could
talk to 128.100.3.58 over the GRE tunnel without causing any path MTU
changes (and without problems in general).

(This always made my head hurt a little bit but since it worked,
I didn't worry about it.)

	- cks
