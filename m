From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in
	network devices
Date: Mon, 27 Jul 2009 06:52:43 -0400
Message-ID: <20090727105243.GA15823@hmsreliant.think-freely.org>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51565 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034AbZG0Kwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 06:52:51 -0400
Content-Disposition: inline
In-Reply-To: <20090726.180254.202825489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 26, 2009 at 06:02:54PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Sun, 26 Jul 2009 20:36:09 -0400
> 
> > 	Since Network devices dma their memory into a provided DMA
> > buffer (which can usually be at an arbitrary location, as they must
> > cross potentially several pci busses to reach any memory location),
> > I'm postulating that it would increase our receive path efficiency
> > to provide a hint to the driver layer as to which node to allocate
> > an skb data buffer on.  This hint would be determined by a feedback
> > mechanism.  I was thinking that we could provide a callback function
> > via the skb, that accepted the skb and the originating net_device.
> > This callback can track statistics on which numa nodes consume
> > (read: copy data from) skbs that were produced by specific net
> > devices.  Then, when in the future that netdevice allocates a new
> > skb (perhaps via netdev_alloc_skb), we can use that statistical
> > profile to determine if the data buffer should be allocated on the
> > local node, or on a remote node instead.
> 
> No matter what, you will do an inter-node memory operation.
> 
> Unless, the consumer NUMA node is the same as the one the
> device is on.
> 
> Because since the device is on a NUMA node, if you DMA remotely
> you've eaten the NUMA cost already.
> 
> If you always DMA to the device's NUMA node (what we try to do now) at
> least the is the possibility of eliminating cross-NUMA traffic.
> 
> Better to move the application or stack processing towards the NUMA
> node the network device is on, I think.
> 
I take your point, and I see where we attempt to allocate on the same node that
the device is in in __netdev_alloc_skb, I'm just wondering if (since we are
going to have cross node traffic if the app and device are on disparate nodes),
if it wouldn't be better to eat that cross node latency at the bottom of the
stack, rather than the top.  If we do it at the bottom we at least have a DMA
engine eating that time, rather than a CPU that could be doing some other work.
Not sure if thats worth the effort, but I think its worth asking the question.

Thoughts?

Regards
Neil

