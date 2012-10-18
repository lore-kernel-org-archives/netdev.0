From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 10:05:29 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se>
References: <507F38D4.102@genband.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:34313 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab2JRIOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 04:14:08 -0400
In-Reply-To: <507F38D4.102@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Oct 2012, Chris Friesen wrote:

> 1) create new IP address and assign to eth device
> 2) TCP server starts listening on that IP address
> 3) TCP client connects to server
> 4) remove new IP address

I'm a network engineer, as in I work primarily with IP routing. Ever since 
I started running Linux back in the mid 90ties I've had a love/hate 
relationship with how Linux handles disappearing network connectivity or 
IP addresses.

In my mind there are two ways to handle outage:

1. When a network connection (physical interface) goes down, keep 
everything as it is, it might come back up again shortly and then we can 
continue as if basically nothing happened. TCP was designed for this 
considering timeouts can be in hours.

2. When a network connection (physical interface) goes down, wait a few 
seconds, give up, reset all connectivity related to that connection, 
basically give up.

Now to my question for the netdev people:

Is there functionality in the kernel for a connection manager to easily 
accomplish 2, in that when it tries to deconfigure the IP address on the 
interface to also kill all TCP connections terminated at that IP? On my 
laptop, I regularily have to kill my ssh client after suspend/resume 
cycle, because it's been down for quite a while, and the ssh client 
doesn't know the TCP connection is now not functional anymore (TCP session 
is still up and retransmit won't happen for a while, so the TCP RST from 
the server (I use keepalives within SSH) isn't seen for a long time).

Without knowing what's in place right now, I see some behaviours that I'd 
like to have:

After resume (or otherwise network connectivity re-established), 
connection manager should be able to tell the kernel to:

a) kill all TCP/UDP/other sessions existing which doesn't currently have 
an active IP address on the machine. This is for the sake of local 
clients.
b) the TCP/SCTP sessions that *do* have an IP, should have their 
retransmit timers "reset", so that whatever needs to be sent, should be 
sent immediately (or shortly, within a few seconds).
c) tell the kernel to kill all TCP sessions bound to a certain IP, because 
the connection manager is going to remove it shortly. Send TCP RSTs or 
whatever and close the TCP session, so both ends know that network 
connectivity is going down.

This would mean that if I resume my laptop and it establishes network 
connectivity, I will then *know* within a few seconds what TCP sessions 
are still valid (the ones that aren't will be killed either because 
they're bound to an IP that is not available, or a TCP packet is sent out 
to which there will be a TCP RST reply from the other side if the TCP 
session is closed at that end).

All of this also has implications on IPv6 and autoconfiguration, I don't 
know if currently we are closing TCP sessions bound to IPv6 addresses that 
are going away due to the RA the addresses were autoconfigured based on, 
now doesn't have a valid lifetime anymore and the kernel is going to 
remove them. It also applies to both DHCPv6 and DHCPv4 when a lease is 
expiring and the IPv4/IPv6 address is going to be removed.

Right now I think the situation with a lot of "hanging" TCP sessions after 
connectivity is restored is suboptimal and negatively impacts user 
experience. Probably there should be knobs to turn for different user 
needs (server or desktop/laptop) because desired behaviour is different in 
different use cases.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
