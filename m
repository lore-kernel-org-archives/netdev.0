From: Ben Greear <greearb@candelatech.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 15:15:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60F3F7.6090203@candelatech.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>	<3F60CA6D.9090503@pobox.com>	<3F60D0F3.8080006@candelatech.com>	<20030911131219.0ab8dfdd.davem@redhat.com>	<3F60DDCC.5020906@candelatech.com>	<20030911140746.4f0384a1.davem@redhat.com>	<3F60E947.4090005@candelatech.com> <20030911142906.74d9dfe5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030911142906.74d9dfe5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 11 Sep 2003 14:29:43 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Thanks for that clarification.  Is there no way to tell
>>at 'sendto' time that the buffers are over-full, and either
>>block or return -EBUSY or something like that?
> 
> 
> The TX queue state can change by hundreds of packets by
> the time we are finished making the "decision", also how would
> you like to "wake" up sockets when the TX queue is liberated.

So, at some point the decision is already made that we must drop
the packet, or that we can enqueue it.  This is where I would propose
we block the thing trying to enqueue, or at least propagate a failure
code back up the stack(s) so that the packet can be retried by the
calling layer.

Preferably, one would propagate the error all the way to userspace
and let them deal with it, just like we currently deal with socket
queue full issues.

> That extra overhead and logic would be wonderful for performance.

The cost of a retransmit is also expensive, whether it is some hacked
up UDP protocol or for TCP.  Even if one had to implement callbacks
from the device queue to the interested sockets, this should not
be a large performance hit.

> 
> No, this is all nonsense.  Packet scheduling and queueing is
> an opaque layer to all the upper layers.  It is the only sensible
> design.

This is possible, but it does not seem cut and dried to me.  If there
is any documentation or research that support this assertion, please
do let us know.

> 
> IP transmit is black hole that may drop packets at any moment,
> any datagram application not prepared for this should be prepared
> for troubles or choose to move over to something like TCP.
> 
> I listed even a workaround for such stupid UDP apps, simply limit
> their socket send queue limits.

And the original poster shows how a similar problem slows down TCP
as well due to local dropped packets.  Don't you think we'd get better
TCP throughput if we instead had the calling code wait 1us for the buffers
to clear?


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
