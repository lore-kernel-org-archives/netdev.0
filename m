From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Wed, 15 Aug 2007 09:42:41 -0500
Message-ID: <46C310E1.7020503@opengridcomputing.com>
References: <46B883B5.8040702@opengridcomputing.com>	<46BB61D0.4090101@opengridcomputing.com>	<46BB89C0.4040303@ichips.intel.com>
	<20070809.145534.102938208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070809.145534.102938208.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



David Miller wrote:
> From: Sean Hefty <mshefty@ichips.intel.com>
> Date: Thu, 09 Aug 2007 14:40:16 -0700
> 
>> Steve Wise wrote:
>>> Any more comments?
>> Does anyone have ideas on how to reserve the port space without using a 
>> struct socket?
> 
> How about we just remove the RDMA stack altogether?  I am not at all
> kidding.  If you guys can't stay in your sand box and need to cause
> problems for the normal network stack, it's unacceptable.  We were
> told all along the if RDMA went into the tree none of this kind of
> stuff would be an issue.

I think removing the RDMA stack is the wrong thing to do, and you 
shouldn't just threaten to yank entire subsystems because you don't like 
the technology.  Lets keep this constructive, can we?  RDMA should get 
the respect of any other technology in Linux.  Maybe its a niche in your 
opinion, but come on, there's more RDMA users than say, the sparc64 
port.  Eh?

> 
> These are exactly the kinds of problems for which people like myself
> were dreading.  These subsystems have no buisness using the TCP port
> space of the Linux software stack, absolutely none.
> 

Ok, although IMO its the correct solution.  But I'll propose other 
solutions below.  I ask for your feedback (and everyones!) on these 
alternate solutions.

> After TCP port reservation, what's next?  It seems an at least
> bi-monthly event that the RDMA folks need to put their fingers
> into something else in the normal networking stack.  No more.
>

The only other change requested and commited, if I recall correctly, was 
for netevents, and that enabled both Infiniband and iWARP to integrate 
with the neighbour subsystem.  I think that was a useful and needed 
change.  Prior to that, these subsystems were snooping ARP replies to 
trigger events.  That was back in 2.6.18 or 2.6.19 I think...

> I will NACK any patch that opens up sockets to eat up ports or
> anything stupid like that.

Got it.

Here are alternate solutions that avoid the need to share the port space:

Solution 1)

1) admins must setup an alias interface on the iwarp device for use with 
rdma.  This interface will have to be a separate subnet from the "TCP 
used" interface.  And with a canonical name that indicates its "for rdma 
only".  Like eth2:iw or eth2:rdma.  There can be many of these per device.

2) admins make sure their sockets/tcp services don't use the interface 
configured in #1, and their rdma service do use said interface.

3) iwarp providers must translation binds to ipaddr 0.0.0.0 to the 
associated "for rdma only" ip addresses.  They can do this by searching 
for all aliases of the canonical name that are aliases of the TCP 
interface for their nic device.  Or: somehow not handle incoming 
connections to any address but the "for rdma use" addresses and instead 
pass them up and not offload them.

This will avoid the collisions as long as the above steps are followed.


Solution 2)

Another possibility would be for the driver to create two net devices 
(and hence two interace names) like "eth2" and "iw2", and artificially 
separate the RDMA stuff that way.

These two solutions are similar in that they create a "rdma only" interface.

Pros:
- is not intrusive into the core networking code
- very minimal changes needed and in the iwarp provider's code, who are 
the ones with this problem
- makes it clear which subnets are RDMA only

Cons:
- relies on system admin to set it up correctly.
- native stack can still "use" this rdma-only interface and the same 
port space issue will exist.


For the record, here are possible port-sharing solutions Dave sez he'll NAK:

Solution NAK-1)

The rdma-cma just allocates a socket and binds it to reserve TCP ports.

Pros:
- minimal changes needed to implement (always a plus in my mind :)
- simple, clean, and it works (KISS)
- if no RDMA is in use, there is no impact on the native stack
- no need for a seperate RDMA interface

Cons:
- wastes memory
- puts a TCP socket in the "CLOSED" state in the pcb tables.
- Dave will NAK it :)

Solution NAK-2)

Create a low-level sockets-agnostic port allocation service that is 
shared by both TCP and RDMA.  This way, the rdma-cm can reserve ports in 
an efficient manor instead of doing it via kernel_bind() using a sock 
struct.

Pros:
- probably the correct solution (my opinion :) if we went down the path 
of sharing port space
- if no RDMA is in use, there is no impact on the native stack
- no need for a separate RDMA interface

Cons:

- very intrusive change because the port allocations stuff is tightly 
bound to the host stack and sock struct, etc.
- Dave will NAK it :)


Steve.
