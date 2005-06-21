From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 13:37:04 -0700 (PDT)
Message-ID: <20050621.133704.08321534.davem@davemloft.net>
References: <42A5284C.3060808@osdl.org>
	<1118147904.6320.108.camel@localhost.localdomain>
	<Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@osdl.org, mitch.a.williams@intel.com,
        john.ronciak@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gandalf@wlug.westbo.se
In-Reply-To: <Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Martin Josefsson <gandalf@wlug.westbo.se>
Date: Tue, 7 Jun 2005 14:06:18 +0200 (CEST)

> One thing that jumps to mind is that e1000 starts at lastrxdescriptor+1
> and loops and checks the status of each descriptor and stops when it finds
> a descriptor that isn't finished. Another way to do it is to read out the
> current position of the ring and loop from lastrxdescriptor+1 up to the
> current position. Scott Feldman implemented this for TX and there it
> increased performance somewhat (discussed here on netdev some months ago).
> I wonder if it could also decrease RX latency, I mean, we have to get the
> cache miss sometime anyway.
> 
> I havn't checked how tg3 does it.

I don't think this matters all that much.  tg3 does loop on RX
producer index, so doesn't touch descriptors unless the RX producer
index states there is a ready packet there.

One thing I noticed with Super TSO testing is that e1000 has very
expensive TSO transmit processing.  The big problem is the context
descriptor.  This is 4 extra 32-bit words eaten up in the transmit
ring for every TSO packet.  Whereas tg3 stores all the TSO offload
information directly in the normal TX descriptor (which is the
same size, 16 bytes, as the e1000 normal TX descriptor).

It accounts for a non-trivial amount of overhead.  On my SunBlade1500
with Super TSO, e1000 transmitter eats %40 of CPU to fill a gigabit
pipe whereas tg3 takes %30.  All of the extra time, based upon quick
scans of oprofile dumps, shows it in the e1000 driver.

Also, e1000 sends full MTU sized SKBs down into the stack even if the
packet is very small.  This also hurts performance a lot.  As
discussed elsewhere, it should use a "small packet" cut-off just like
other drivers do.  If the RX frame is less than this cut-off value, a
new smaller sized SKB is allocated and the RX data copied into it.
The RX ring SKB is left in-place and given back to the chip.

My only guess is that the e1000 driver implemented things this way
to simplify the RX recycling logic.  Well, it is an area ripe for
improvement in this driver :)
