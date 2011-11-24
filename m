From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Thu, 24 Nov 2011 18:12:49 +0200
Message-ID: <20111124161249.GB26770@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
 <20111124095902.GD14491@redhat.com>
 <OF12661931.5C4899F8-ON65257952.003B84A6-65257952.003D8DA6@in.ibm.com>
 <4ECE4004.8010107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, arnd@arndb.de,
	davem@davemloft.net, levinsasha928@gmail.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	jeffrey.t.kirsher@intel.com
To: jasowang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab1KXQLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 11:11:54 -0500
Content-Disposition: inline
In-Reply-To: <4ECE4004.8010107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2011 at 09:00:52PM +0800, jasowang wrote:
> On 11/24/2011 07:14 PM, Krishna Kumar2 wrote:
> >"Michael S. Tsirkin"<mst@redhat.com>  wrote on 11/24/2011 03:29:03 PM:
> >
> >>Subject Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
> >>
> >>On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
> >>>It was reported that the macvtap device selects a
> >>>different vhost (when used with multiqueue feature)
> >>>for incoming packets of a single connection. Use
> >>>packet hash first. Patch tested on MQ virtio_net.
> >>So this is sure to address the problem, why exactly does this happen?
> >>Does your device spread a single flow across multiple RX queues? Would
> >>not that cause trouble in the TCP layer?
> >>It would seem that using the recorded queue should be faster with
> >>less cache misses. Before we give up on that, I'd
> >>like to understand why it's wrong. Do you know?
> >I am using ixgbe. From what I briefly saw, ixgbe_alloc_rx_buffers
> >calls skb_record_rx_queue when a skb is allocated. When a packet
> >is received (ixgbe_alloc_rx_buffers), it sets rxhash. The
> >recorded value is different for most skbs when I ran a single
> >stream TCP stream test (does skbs move between the rx_rings?).
> 
> Yes, it moves. It depends on last processor or tx queue who
> transmits the packets of this stream. Because ixgbe select tx queue
> based on the processor id, so if vhost thread transmits skbs on
> different processors, the skb of a single stream may comes from
> different rx ring.

Is that so? In that case, it looks like there's bug on the transmit
side, causing skbs to get scattered between ixgbe tx queues,
and the receive side trouble follows.

> >With this patch, macvtap selects the same device for each
> >incoming packet. I can add some debugs in ixgbe to see what is
> >happening also. I am not sure if Sasha was using a different
> >device.
> >
> >Cc'ing Jeffrey in case he can add something.
> >
> >thanks,
> >
> >- KK
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
