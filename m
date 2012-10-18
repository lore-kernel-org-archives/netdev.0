From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 11:13:29 +0200
Message-ID: <1350551609.26103.1261.camel@edumazet-glaptop>
References: <507F38D4.102@genband.com>
	 <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47334 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab2JRJNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 05:13:33 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so4012969bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 02:13:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-18 at 10:05 +0200, Mikael Abrahamsson wrote:
> On Wed, 17 Oct 2012, Chris Friesen wrote:
> 
> > 1) create new IP address and assign to eth device
> > 2) TCP server starts listening on that IP address
> > 3) TCP client connects to server
> > 4) remove new IP address
> 
> I'm a network engineer, as in I work primarily with IP routing. Ever since 
> I started running Linux back in the mid 90ties I've had a love/hate 
> relationship with how Linux handles disappearing network connectivity or 
> IP addresses.
> 
> In my mind there are two ways to handle outage:
> 
> 1. When a network connection (physical interface) goes down, keep 
> everything as it is, it might come back up again shortly and then we can 
> continue as if basically nothing happened. TCP was designed for this 
> considering timeouts can be in hours.
> 
> 2. When a network connection (physical interface) goes down, wait a few 
> seconds, give up, reset all connectivity related to that connection, 
> basically give up.
> 
> Now to my question for the netdev people:
> 
> Is there functionality in the kernel for a connection manager to easily 
> accomplish 2, in that when it tries to deconfigure the IP address on the 
> interface to also kill all TCP connections terminated at that IP? On my 
> laptop, I regularily have to kill my ssh client after suspend/resume 
> cycle, because it's been down for quite a while, and the ssh client 
> doesn't know the TCP connection is now not functional anymore (TCP session 
> is still up and retransmit won't happen for a while, so the TCP RST from 
> the server (I use keepalives within SSH) isn't seen for a long time).
> 
> Without knowing what's in place right now, I see some behaviours that I'd 
> like to have:
> 
> After resume (or otherwise network connectivity re-established), 
> connection manager should be able to tell the kernel to:
> 
> a) kill all TCP/UDP/other sessions existing which doesn't currently have 
> an active IP address on the machine. This is for the sake of local 
> clients.

You do realize kernel has no idea that the loss of IP address is
temporary or not ?

Some links can be slow to setup after a resume.

> b) the TCP/SCTP sessions that *do* have an IP, should have their 
> retransmit timers "reset", so that whatever needs to be sent, should be 
> sent immediately (or shortly, within a few seconds).

So they are going to force a close, even if the link becomes alive after
15 seconds. Too bad for some wireless setups, or tunnels.

> c) tell the kernel to kill all TCP sessions bound to a certain IP, because 
> the connection manager is going to remove it shortly. Send TCP RSTs or 
> whatever and close the TCP session, so both ends know that network 
> connectivity is going down.
> 

Yes, why not. Why is it specific to linux I have no idea.
