From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 12:41:00 -0800
Message-ID: <45EDD1DC.2010200@hp.com>
References: <45EBFD13.1060106@symas.com>	<200703051528.02564.dada1@cosmosbay.com>	<45ED32CA.5080709@symas.com> <45EDB708.1010103@hp.com> <45EDC00E.8020805@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:39481 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965109AbXCFUlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 15:41:03 -0500
In-Reply-To: <45EDC00E.8020805@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> With transparant bridging, nobody knows how long the datagram may be 
>> out there.  Admittedly, the chances of a datagram living for a full 
>> two minutes these days is probably nil, but just being in the same IP 
>> subnet doesn't really mean anything when it comes to physical locality.
> 
> 
> Bridging isn't necessarily a problem though. The 2MSL timeout is 
> designed to prevent problems from delayed packets that got sent through 
> multiple paths. In a bridging setup you don't allow multiple paths, 
> that's what STP is designed to prevent. If you want to configure a 
> network that allows multiple paths, you need to use a router, not a bridge.

Well, there is trunking at the data link layer, and in theory there 
could be an active-standby where the standby took a somewhat different path.

The timeout is also to cover datagrams which just got "stuck" somewhere 
too (IIRC) and may not necessarily require a multiple path situation.

> 
>> SPECweb benchmarking has had to deal with the issue of attempted 
>> TIME_WAIT reuse going back to 1997.  It deals with it by not relying 
>> on the client's configured local/anonymous/ephemeral port number range 
>> and instead making explicit bind() calls in the (more or less) entire 
>> unpriv port range (actually it may just be from 5000 to 65535 but still)
> 
> 
> That still doesn't solve the problem, it only ~doubles the available 
> port range. That means it takes 0.6 seconds to trigger the problem 
> instead of only 0.3 seconds...

True.  Thankfully, the web learned to use persistent connections so 
later versions of SPECweb benchmarking make use of persistent connections.

> In an environment where connections are opened and closed very quickly 
> with only a small amount of data carried per connection, it might make 
> sense to remember the last sequence number used on a port and use that 
> as the floor of the next randomly generated ISN. Monotonically 
> increasing sequence numbers aren't a security risk if there's still a 
> randomly determined gap from one connection to the next. But I don't 
> think it's necessary to consider this at the moment.

I thought that all the "security types" started squawking if the ISN 
wasn't completely random?

I've not tried this, but if a client does want to cycle through 
thousands of connections per second, and if it is the one to initiate 
connection close, would it be sufficient to only use something like:

socket()
bind()
loop:
connect()
request()
response()
shudtown(SHUT_RDWR)
goto loop

ie not call close on the FD so there is still a direct link to the 
connection in TIME_WAIT so one could in theory initiate a new connection 
from TIME_WAIT?  Then in theory the randomness could be _almost_ the 
entire sequence space, less the previous connection's window (IIRC).

rick jones

rick jones
