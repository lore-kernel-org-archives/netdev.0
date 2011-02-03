From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 3 Feb 2011 08:13:26 +0200
Message-ID: <20110203061326.GC22230@redhat.com>
References: <20110202154706.GA12738@redhat.com>
 <1296666635.25430.35.camel@localhost.localdomain>
 <20110202173213.GA13907@redhat.com>
 <1296670311.25430.49.camel@localhost.localdomain>
 <20110202182720.GB14257@redhat.com>
 <1296674975.25430.59.camel@localhost.localdomain>
 <20110202201731.GB15150@redhat.com>
 <1296680585.25430.98.camel@localhost.localdomain>
 <20110202212047.GD15150@redhat.com>
 <1296709556.25430.140.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab1BCGNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 01:13:47 -0500
Content-Disposition: inline
In-Reply-To: <1296709556.25430.140.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 02, 2011 at 09:05:56PM -0800, Shirley Ma wrote:
> On Wed, 2011-02-02 at 23:20 +0200, Michael S. Tsirkin wrote:
> > > I think I need to define the test matrix to collect data for TX xmit
> > > from guest to host here for different tests.
> > > 
> > > Data to be collected:
> > > ---------------------
> > > 1. kvm_stat for VM, I/O exits
> > > 2. cpu utilization for both guest and host
> > > 3. cat /proc/interrupts on guest
> > > 4. packets rate from vhost handle_tx per loop
> > > 5. guest netif queue stop rate
> > > 6. how many packets are waiting for free between vhost signaling and
> > > guest callback
> > > 7. performance results
> > > 
> > > Test
> > > ----
> > > 1. TCP_STREAM single stream test for 1K to 4K message size
> > > 2. TCP_RR (64 instance test): 128 - 1K request/response size
> > > 
> > > Different hacks
> > > ---------------
> > > 1. Base line data ( with the patch to fix capacity check first,
> > > free_old_xmit_skbs returns number of skbs)
> > > 
> > > 2. Drop packet data (will put some debugging in generic networking
> > code)
> 
> Since I found that the netif queue stop/wake up is so expensive, I
> created a dropping packets patch on guest side so I don't need to debug
> generic networking code.
> 
> guest start_xmit()
> 	capacity = free_old_xmit_skb() + virtqueue_get_num_freed()
> 	if (capacity == 0)
> 		drop this packet;
> 		return;
> 
> In the patch, both guest TX interrupts and callback have been omitted.
> Host vhost_signal in handle_tx can totally be removed as well. (A new
> virtio_ring API is needed for exporting total of num_free descriptors
> here -- virtioqueue_get_num_freed)
> 
> Initial TCP_STREAM performance results I got for guest to local host 
> 4.2Gb/s for 1K message size, (vs. 2.5Gb/s)
> 6.2Gb/s for 2K message size, and (vs. 3.8Gb/s)
> 9.8Gb/s for 4K message size. (vs.5.xGb/s)

What is the average packet size, # bytes per ack, and the # of interrupts
per packet? It could be that just slowing down trahsmission
makes GSO work better.

> Since large message size (64K) doesn't hit (capacity == 0) case, so the
> performance only has a little better. (from 13.xGb/s to 14.x Gb/s)
> 
> kvm_stat output shows significant exits reduction for both VM and I/O,
> no guest TX interrupts.
> 
> With dropping packets, TCP retrans has been increased here, so I can see
> performance numbers are various.
> 
> This might be not a good solution, but it gave us some ideas on
> expensive netif queue stop/wake up between guest and host notification.
> 
> I couldn't find a better solution on how to reduce netif queue stop/wake
> up rate for small message size. But I think once we can address this,
> the guest TX performance will burst for small message size.
> 
> I also compared this with return TX_BUSY approach when (capacity == 0),
> it is not as good as dropping packets.
> 
> > > 3. Delay guest netif queue wake up until certain descriptors (1/2
> > ring
> > > size, 1/4 ring size...) are available once the queue has stopped.
> > > 
> > > 4. Accumulate more packets per vhost signal in handle_tx?
> > > 
> > > 5. 3 & 4 combinations
> > > 
> > > 6. Accumulate more packets per guest kick() (TCP_RR) by adding a
> > timer? 
> > > 
> > > 7. Accumulate more packets per vhost handle_tx() by adding some
> > delay?
> > > 
> > > > Haven't noticed that part, how does your patch make it
> > > handle more packets?
> > > 
> > > Added a delay in handle_tx().
> > > 
> > > What else?
> > > 
> > > It would take sometimes to do this.
> > > 
> > > Shirley
> > 
> > 
> > Need to think about this.
> > 
> > 
