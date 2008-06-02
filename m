From: Glen Turner <gdt@gdt.id.au>
Subject: Re: increase priority of tcp ACK packages in the kernel?
Date: Mon, 02 Jun 2008 14:00:44 +0930
Message-ID: <48437774.1060404@gdt.id.au>
References: <4840F9DF.5080106@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harald Dunkel <harald.dunkel@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:50299 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750862AbYFBEap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 00:30:45 -0400
In-Reply-To: <4840F9DF.5080106@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harald Dunkel wrote:
> AFAICS there is a performance problem for tcp: High volume
> outgoing traffic seriously affects throughput for incoming
> traffic due to the tcp ACK packages waiting between the
> giant packages in the outgoing fifo.
> 
> Do you think it would be possible to increase the priority of
> outgoing tcp ACK packages in the kernel by default?

An embedded wireless router running Linux would want the
opposite policy. So the current user-space configuration
of kernel-provided services appears about right.

ADSL customers often see your problem, since their uplink
is just big enough for Acks and if you run a web server
too then those Acks have to compete on congested capacity.
Use iptables and tc to queue the Acks out first (you can
use the ingress interface to identify the routed Acks),
don't fiddle with the DSCP -- there's no need.

This is deep policy, and it doesn't belong in the kernel.



Note that the --set-tos components in the configurations
you reference are near totally bogus with many ISPs.

You do not know how the ISP is going to interpret the DSCP.
For example, we offer these traffic classes to the public:
  - worst effort
  - best effort (default)
  - video
  - voice

Anything else we interpret as Best Effort.  If you do select
one of these classes then we either rate-limit the ingress or
require a matching control plane call establishment.  If you
exceed these limits your traffic is placed in worst effort.

We are not required to give better effort to priority markings
within the DSCP (we are required not to give them worse service).
So we don't give them better service, because unauthenticated
better service is obviously a DoS vector. In fact, such a common
setting on DoS traffic that setting ToS actually increases your
odds of being placed into the Worst Effort class (the class where
we map all suspicious traffic we can't quite bring ourselves
to discard).

For example, the page recommends Minimize-Delay, which is
meant for interactive terminal traffic. We know a screen
refresh is two back-to-back packets and anything more than
two per second is superhuman typing. So anything more than
that burst is a DoS.  You can see already how your Ack
channel may be limited to the speed of a typist because you
lied about the traffic you marked with Minimize-Delay.

In short, ISPs are increasingly checking that traffic markings
are reasonable -- we have wire-speed routers and we're not afraid
to use them. The only reasonable thing you can do with marking
Acks is put them in the same DSCP as the data. Otherwise you are
lying about the contents of the class and when we go looking
for odd data we'll penalise that.

Oh, and marking Ack traffic and non-Ack traffic in the same
direction with different DSCPs will drop performance, because
we'll deliver them out of order if congestion is seen.

-- 
  Glen Turner
