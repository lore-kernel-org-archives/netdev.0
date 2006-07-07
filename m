From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: What is RDMA (was: RDMA will be reverted)
Date: Fri, 07 Jul 2006 13:25:44 -0500
Message-ID: <1152296744.18332.42.camel@stevo-desktop>
References: <adaac7naj80.fsf@cisco.com>
	 <20060705.200325.74731166.davem@davemloft.net>
	 <1152163503.20248.98.camel@trinity.ogc.int>
	 <20060706.235320.92562667.davem@davemloft.net>
	 <20060707081131.GA2991@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@opengridcomputing.com,
	rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:38998 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1751049AbWGGSZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 14:25:47 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060707081131.GA2991@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Great summation.   Comments in-line...


On Fri, 2006-07-07 at 18:11 +1000, Herbert Xu wrote:
> On Fri, Jul 07, 2006 at 06:53:20AM +0000, David Miller wrote:
> > 
> > What I am saying, however, is that we need to understand the
> > technology and the hooks you guys want before we put any of it in.
> 
> Yes indeed.
> 
> Here is what I've understood so far so let's see if we can start building
> a censensus.
> 
> 1) RDMA over straight Infiniband is not contentious.  In this case no
>    IP networking is involved.
> 

Some IP networking is involved for this.  IP addresses and port numbers
are used by the RDMA Connection Manager.  The motivation for this was
two-fold, I think:

1) to simplify the connection setup model.  The IB CM model was very
complex.

2) to allow ULPs to be transport independent.  Thus a single code base
for NFSoRDMA, for example, can run over Infiniband and RDMA/TCP
transports without code changes or knowing about transport-specific
addressing.

The routing table is also consulted to determine which rdma device
should be used for connection setup.  Each rdma device also installs a
netdev device for native stack traffic.  The RDMA CM maintains an
association between the netdev device and the rdma device.  

And the Infiniband subsystem uses ARP over IPoIB to map IP addresses to
GID/QPN info.  This is done by calling arp_send() directly, and snooping
all ARP packets to "discover" when the arp entry is completed.

> 2) RDMA over TCP/IP (or SCTP) can theoretically run on any network that
>    supported IP, including Infiniband and Ethernet.
> 
> 3) When RDMA over TCP is completely done in hardware, i.e., it has its
>    own IP address, MAC address, and simply presents an RDMA interface
>    (whatever that may be) to Linux, we're OK with it.
> 
>    This is similar to how some iSCSI adapters work.
> 

The Ammasso driver implements this method.  It supports 2 mac addresses
on the single GigE port:  1 for native host networking traffic only, and
one for RDMA/TCP only.  The firmware implements a full TCP/IP/ARP/ICMP
stack and handles all function of the RDMA/TCP connection setup.    

However, even these types of devices need some integration with the
networking subsystem.  Namely the existing Infiniband rdma connection
manager assumes it will find a netdev device for each rdma device
registered.  So it uses the routing table to look up a netdev to
determine which rdma device should be used for connection setup.  The
Ammasso driver installs 2 netdevs, one of which is a virtual device used
soley for assigning IP addresses to the RDMA side of the nic, and for
the RDMA CM to find this device...


> 4) When RDMA over TCP is done completely in the Linux networking stack,
>    we don't have a problem because the existing TCP stack is still in
>    charge.  However, this is pretty pointless.
> 

Indeed.

I see one case where this model might be useful:  If the optimizations
that RDMA gives helps mainly the server side of an application, then the
client side might use a software-only rdma stack and a dumb nic.  The
server buys the deep rnic adapter and gets the perf benefits...

> 
> 5) RDMA over TCP on the receive side is offloaded into the NIC.  This
>    allows the NIC to directly place data into the application's buffer.  
> 
>    We're starting to have a little bit of a problem because it means that
>    part of the incoming IP traffic is now being directly processed by the
>    NIC, with no input from the Linux TCP/IP stack.
> 
>    However, as long as the connection establishment/acks are still
>    controlled/seen by Linux we can probably live with it.
> 
> 6) RDMA over TCP on the transmit side is offloaded into the NIC.  This
>    is starting to look very worrying.
> 
>    The reason is that we lose all control to crucial aspects of TCP like
>    congestion control.  It is now completely up to the NIC to do that.
>    For straight RDMA over Infiniband this isn't an issue because the
>    traffic is not likely to travel across the Internet.
> 
>    However, for RDMA over TCP, one of their goals is to support sending
>    traffic over the Internet so this is a concern.  Incidentally, this is
>    why they need to know about things like MAC/route/MTU changing.
> 
> 7) RDMA over TCP is completely offloaded into the NIC, however, they still
>    use Linux's IP address, MAC address, and rely on us to tell it about
>    events such as MTU updates or MAC changes.
> 

I only know of type 3 rnics (ammasso) and type 7 rnics (chelsio +
others).  I haven't seen any type 5 or 6 designs yet for RDMA/TCP...


>    In addition to the problems we have in 5) and 6), we now have a portion
>    of TCP port space which has suddenly become invisible to Linux.  What's
>    more, we lose control (e.g., netfilter) over what connections may or
>    may not be established.

port space issues and netfilter integration can be fixed, I think, if
there is a desire to do so.


> 
> So to my mind, RDMA over TCP is most problematic when it shares the same
> IP/MAC address as the Linux host, and when the transmit side and/or the
> connection establishment (case 6 and 7) is offloaded into the NIC.  This
> also happens to be the only scenario where they need the notification
> patch that started all this discussion.
> 

Note that the current Infiniband RDMA connection setup could also
benefit from the notification patch.  Then it would not need to filter
all incoming ARP packets...


Steve.

