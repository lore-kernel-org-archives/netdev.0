From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 5 Jan 2005 14:29:57 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0501051408330.27046@hibernia.jakma.org>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
  <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
  <1104895169.1117.63.camel@jzny.localdomain>  <Pine.LNX.4.61.0501050627050.27046@hibernia.jakma.org>
 <1104931011.1118.134.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1104931011.1118.134.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 5 Jan 2005, jamal wrote:

> Ok, Iam confused - I thought you guys _wanted this_ ;->

I'm confused too now. We dont want "queue packets" - that's the 
'newish' policy I was referring to. (newish in quotes, as I'm not 
sure from when this behaviour dates).

> The issue is about message obsolency more than it is about reliability.

Right, exactly.

So we do want what you think we want ;) (i think).

> Without this the scenario you played you played for us before was:
>
> 1)=>send a few LSAs from user space, pull cable before they go out
> (this will happen if you are sending sufficiently large amounts of
> packets i.e network is busy),
> 2)=>user space gets notified via netlink, device shuts down acces to
> DMA, packets queued anyways and you have no ability to say "ooops,sorry
> take that packet back"

Right.

Two things:

- we noticed this behaviour because of OSPF

Users reported ospfd would cease to send packets on all interfaces, 
(with certain drivers) because /one/ interface was link-down.

We can workaround this easily by opening a socket per interface - at 
present we simply punt OSPF packets down a single raw socket and rely 
on IP_HDRINCL to have kernel route the packet out correct interface 
(IP_MULTICAST_IF for multicast destined packets).

- The queueing does not affect OSPF terribly, it would affect other
   protocols though

OSPF implements its own 'synchronisation' facilities between 
neighbours and can easily 'detect' obsolecent packets. So the 
obsolence issue does not affect it, routing-information in stale 
packets will not propogate, so they cant do much damage really. (just 
unneccessary to queue and send such packets).

However, other commonly used protocols are not as robust. Mostly 
those where a protocol is used to distribute routing information to 
passive listeners, eg:

- RIP
- IPv4 ICMP based router-discovery (IRDP)
- IPv6 Router-advertisements

In these cases, the queuing behaviour is potentially dangerous and 
could disrupt connectivity by propogating no-longer-valid routing 
information.

> a)You could do a move to another device at this point.
> or
> b) dumb app will continue sending
>
> 3)=>plug cable back in 2 minutes later, obsolete LSAs sent followed by
> any new ones that may follow

Right. Except OSPF is robust enough against stale packets. Other 
protocols are not.

> With the patch, packets in #2 will be dropped.

Perfect.

> As a matter of fact within those two minutes, if stopped, it is 
> probable the device watchdog timer will kick in and flush the DMA 
> but not the scheduler queues above it (which is where upto a 1000 
> stale packets could be sitting).

Right, and our argument it doesnt make sense to send those packets. 
I've never heard of any UDP and/or raw application that expected a 
kernel to queue packets if they could not be sent for lack of link or 
other problem, and any which did are surely broken by definition? ;)

> What is it that you dont like now?

Sorry, wires crossed re "new behaviour". The "new new" behaviour in 
the patch as you describe would be perfect.

PS: Another issue, could we have kernel space IP fragmentation for 
IP_HDRINCL sockets please? We currently have to implement 
fragmentation ourselves, which seems silly given that kernel already 
has this functionality.

> cheers,
> jamal

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
The early bird who catches the worm works for someone who comes in late
and owns the worm farm.
 		-- Travis McGee
