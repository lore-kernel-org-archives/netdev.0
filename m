From: David Brownell <david-b@pacbell.net>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 20:45:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2DD6BD.7070504@pacbell.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>	<3F2CA65F.8060105@pobox.com>	<3F2CBA71.2070503@candelatech.com>	<20030803003239.4257ef24.davem@redhat.com>	<3F2DCE56.6030601@pacbell.net> <20030803200851.7d46a605.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030803200851.7d46a605.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>>>>Although I have not tried this latest patch, the existing e100 and e1000 in
>>>>2.4.21 seldom seem to return true to this method:  netif_queue_stopped(odev),
>>>>even when the next hard_start_xmit() call fails.
>>>
>>>
>>>Returning an error from hard_start_xmit() from normal ethernet
>>>drivers is, frankly, a driver bug and should never happen.
>>
>>What's "normal" mean?
> 
> 
> One that can manage it's own TX resources.

Which for the moment, would seem to exclude USB.


>>With the current USB stack, network adapters tend to need
>>memory allocations there.  Those can fail, though it seems
>>that's not very common.  Doesn't seem like a bug, for all
>>that I'd rather see the those paths be zero-alloc in 2.7.
> 
> 
> Any particular reason why the SKB data itself can't be
> mapped directly?  We created all of these DMA mapping
> abstractions remember? :-)

Yes, but the network drivers weren't the ones that needed them!

Some older drivers do copy the buffer out of (or for rx, into)
the skb, but newer ones just pass the skb data, avoiding a copy.
In either case, the buffer was always DMA mapped.  Nowadays,
some drivers will even set NETIF_F_HIGHDMA if they're going out
through a host controller that allows it!  (Intel boxes only,
AFAIK.)


> Another option is to pre-allocate, such that while the TX
> queue is awake we know we have enough resources to send any
> given packet.  Then in ->hard_start_xmit() after using a buffer
> we allocate a replacement buffer, if this fails in such a way
> that a subsequent ->hard_start_xmit() could possibly fail, we
> do netif_stop_queue().

Pre-allocation can be done for the URBs that wrap the data
buffers, yes.  Not often done today; but it could be.

What can't be pre-allocated in a reliable way is the resources
used by the host controller drivers, specifically the transfer
descriptors.  EHCI and OHCI usually need one per URB, unless
MTU is over 4 KB.  UHCI normally needs quite a few.

The API that works inside USB "gadgets' does allow pre-allocation
at all those levels, mostly because it's factored to make the
submission and completion paths fast.  So that "stop if can't
pre-allocate" scheme would work, given an "ether.c" patch!  :)

- Dave
