From: Donald Becker <becker@scyld.com>
Subject: Re: copybreak and gige network drivers
Date: Mon, 29 Sep 2003 19:14:07 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309291834330.2166-100000@training.scyld.com>
References: <3F787908.7000305@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3F787908.7000305@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003, Chris Friesen wrote:

> I'm looking at doing some work on a driver for the gige portion of the 
> Marvell Disco2.
> 
> The existing driver allocates mtu-sized buffers and always passes them 
> off to the network stack.  I'm thinking about adding some copybreak 
> optimizations, but I'm not sure what value I should use for the 
> copybreak.  I would expect most packets to be on the smaller side.

The initial reason for implementing 'copybreak' was primarily to
mitigate the memory usage impact of the then-new idea of directly
receiving into full-sized skbuffs.

Copying small packets has several subtle benefits / mitigated costs:
   Better VM and cache line usage.
   The copied data of a small packet is largely header info.  This will
     end up in CPU cache for type dispatching anyway, and a copy might
     do this more efficiently than unaligned byte reads.
   The skbuff allocator now only has to allocate from one fixed-sized
     (set as 1536 packet bytes, independent of the driver details) set and
     a limited set of smaller sizes.

In the old days, copybreak was also used (abused) rather than correctly
implementing unaligned word reads when IP header processing on the
Alpha.  Ignore this "benefit".

To decide the optimal value for copybreak you must take into account the
cache and VM characteristics of your machine.  But you don't have to
actually be that precise to be close enough.  Just look at the packet size
distribution and the usage of those packets.  You'll find a bimodal
packet size distribution:
    full sized bulk data packets,
    near-minimal sized ACK, DDOS and protocol packets, which are either
        immediately processed and benefit from the hot cache
	will be held for a long time before processing, and should
	  have minimal memory usage.

The decision point is pretty much break-even in the range of 150-400
bytes, and most packets are either smaller or much larger, so just pick
a likely value.  I tried to look at the bin sizes for the skbuff
allocator, but you'll find that the overhead changes faster than you can
possibly track.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
914 Bay Ridge Road, Suite 220		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
