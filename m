From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 11:58:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210181151040.21297@uplift.swm.pp.se>
References: <507F38D4.102@genband.com>  <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se> <1350551609.26103.1261.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:37332 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab2JRJ6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 05:58:03 -0400
In-Reply-To: <1350551609.26103.1261.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Oct 2012, Eric Dumazet wrote:

>> After resume (or otherwise network connectivity re-established),
>> connection manager should be able to tell the kernel to:
>>
>> a) kill all TCP/UDP/other sessions existing which doesn't currently have
>> an active IP address on the machine. This is for the sake of local
>> clients.
>
> You do realize kernel has no idea that the loss of IP address is
> temporary or not ?

Indeed, that's why I wrote "connection manager tell the kernel to..", and 
didn't write "the kernel should do".

> Some links can be slow to setup after a resume.

Absolutely.

>> b) the TCP/SCTP sessions that *do* have an IP, should have their
>> retransmit timers "reset", so that whatever needs to be sent, should be
>> sent immediately (or shortly, within a few seconds).
>
> So they are going to force a close, even if the link becomes alive after
> 15 seconds. Too bad for some wireless setups, or tunnels.

I don't get what you're saying. I'm saying reset the retransmit timers, if 
there is no response, exponential backoff applies again. The reset of the 
timers is to avoid that the exponential backoff timer is now in "wait for 
several minutes to send the next packet" due to no connectivity during the 
first 10-20 seconds after coming out of resume.

On my Ubuntu 12.04 system, when I bring it out of resume and press enter 
in the terminal with an established ssh session, it takes minutes to 
discover that this session doesn't work and close it (it seems the TCP RST 
from the server isn't triggered for a long time). I usually end up killing 
the ssh process on the laptop and logging in again. What I want to happen 
is that within a few seconds of network connectivity being established, 
TCP should try to communicate and discover that the other end already 
closed the connection and close the local socket call so ssh quits and I 
can re-login again. One way of doing this would be for the connection 
manager to ask the kernel to reset (or severely lower) the retransmit 
timers on all established TCP connections.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
