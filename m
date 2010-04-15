From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][PATCH v2 0/3] Provide a zero-copy method on KVM
	virtio-net.
Date: Thu, 15 Apr 2010 13:05:47 +0300
Message-ID: <20100415100546.GA17035@redhat.com>
References: <1270193100-6769-1-git-send-email-xiaohui.xin@intel.com> <20100414152519.GA10792@redhat.com> <97F6D3BD476C464182C1B7BABF0B0AF5C18969CC@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583Ab0DOKJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 06:09:43 -0400
Content-Disposition: inline
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C18969CC@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 05:36:07PM +0800, Xin, Xiaohui wrote:
> 
> Michael,
> >> The idea is simple, just to pin the guest VM user space and then
> >> let host NIC driver has the chance to directly DMA to it. 
> >> The patches are based on vhost-net backend driver. We add a device
> >> which provides proto_ops as sendmsg/recvmsg to vhost-net to
> >> send/recv directly to/from the NIC driver. KVM guest who use the
> >> vhost-net backend may bind any ethX interface in the host side to
> >> get copyless data transfer thru guest virtio-net frontend.
> >> 
> >> The scenario is like this:
> >> 
> >> The guest virtio-net driver submits multiple requests thru vhost-net
> >> backend driver to the kernel. And the requests are queued and then
> >> completed after corresponding actions in h/w are done.
> >> 
> >> For read, user space buffers are dispensed to NIC driver for rx when
> >> a page constructor API is invoked. Means NICs can allocate user buffers
> >> from a page constructor. We add a hook in netif_receive_skb() function
> >> to intercept the incoming packets, and notify the zero-copy device.
> >> 
> >> For write, the zero-copy deivce may allocates a new host skb and puts
> >> payload on the skb_shinfo(skb)->frags, and copied the header to skb->data.
> >> The request remains pending until the skb is transmitted by h/w.
> >> 
> >> Here, we have ever considered 2 ways to utilize the page constructor
> >> API to dispense the user buffers.
> >> 
> >> One:	Modify __alloc_skb() function a bit, it can only allocate a 
> >> 	structure of sk_buff, and the data pointer is pointing to a 
> >> 	user buffer which is coming from a page constructor API.
> >> 	Then the shinfo of the skb is also from guest.
> >> 	When packet is received from hardware, the skb->data is filled
> >> 	directly by h/w. What we have done is in this way.
> >> 
> >> 	Pros:	We can avoid any copy here.
> >> 	Cons:	Guest virtio-net driver needs to allocate skb as almost
> >> 		the same method with the host NIC drivers, say the size
> >> 		of netdev_alloc_skb() and the same reserved space in the
> >> 		head of skb. Many NIC drivers are the same with guest and
> >> 		ok for this. But some lastest NIC drivers reserves special
> >> 		room in skb head. To deal with it, we suggest to provide
> >> 		a method in guest virtio-net driver to ask for parameter
> >> 		we interest from the NIC driver when we know which device 
> >> 		we have bind to do zero-copy. Then we ask guest to do so.
> >> 		Is that reasonable?
> 
> >Unfortunately, this would break compatibility with existing virtio.
> >This also complicates migration. 
> 
> You mean any modification to the guest virtio-net driver will break the
> compatibility? We tried to enlarge the virtio_net_config to contains the
> 2 parameter, and add one VIRTIO_NET_F_PASSTHRU flag, virtionet_probe()
> will check the feature flag, and get the parameters, then virtio-net driver use
> it to allocate buffers. How about this?

This means that we can't, for example, live-migrate between different systems
without flushing outstanding buffers.

> >What is the room in skb head used for?
> I'm not sure, but the latest ixgbe driver does this, it reserves 32 bytes compared to
> NET_IP_ALIGN.

Looking at code, this seems to do with alignment - could just be
a performance optimization.

> >> Two:	Modify driver to get user buffer allocated from a page constructor
> >> 	API(to substitute alloc_page()), the user buffer are used as payload
> >> 	buffers and filled by h/w directly when packet is received. Driver
> >> 	should associate the pages with skb (skb_shinfo(skb)->frags). For 
> >> 	the head buffer side, let host allocates skb, and h/w fills it. 
> >> 	After that, the data filled in host skb header will be copied into
> >> 	guest header buffer which is submitted together with the payload buffer.
> >> 
> >> 	Pros:	We could less care the way how guest or host allocates their
> >> 		buffers.
> >> 	Cons:	We still need a bit copy here for the skb header.
> >> 
> >> We are not sure which way is the better here.
> 
> >The obvious question would be whether you see any speed difference
> >with the two approaches. If no, then the second approach would be
> >better.
> 
> I remember the second approach is a bit slower in 1500MTU. 
> But we did not tested too much.

Well, that's an important datapoint. By the way, you'll need
header copy to activate LRO in host, so that's a good
reason to go with option 2 as well.

> >> This is the first thing we want
> >> to get comments from the community. We wish the modification to the network
> >> part will be generic which not used by vhost-net backend only, but a user
> >> application may use it as well when the zero-copy device may provides async
> >> read/write operations later.
> >> 
> >> Please give comments especially for the network part modifications.
> >> 
> >> 
> >> We provide multiple submits and asynchronous notifiicaton to 
> >>vhost-net too.
> >> 
> >> Our goal is to improve the bandwidth and reduce the CPU usage.
> >> Exact performance data will be provided later. But for simple
> >> test with netperf, we found bindwidth up and CPU % up too,
> >> but the bindwidth up ratio is much more than CPU % up ratio.
> >> 
> >> What we have not done yet:
> >> 	packet split support
> 
> >What does this mean, exactly?
> We can support 1500MTU, but for jumbo frame, since vhost driver before don't 
> support mergeable buffer, we cannot try it for multiple sg.

I do not see why, vhost currently supports 64K buffers with indirect
descriptors.

> A jumbo frame will split 5
> frags and hook them once a descriptor, so the user buffer allocation is greatly dependent
> on how guest virtio-net drivers submits buffers. We think mergeable buffer is suitable for it. 
> 
> >> 	To support GRO
> Actually, I think if the mergeable buffer may get good performance, then GRO is not 
> so important then.
> >And TSO/GSO?
> Do we really need them?

My guess would be yes. Mergeable buffers is a memory saving
optimization, not a performance optimization, I don't see
that it can help. And I think you can't solely rely on jumbo frames
in hardware, not everyone can enable them.

Having said that, number one priority is getting decent performance
out of the driver, in whatever way you find fit. I was just
suggesting obvious ways to do this.


> >> 	Performance tuning
> >> 
> >> what we have done in v1:
> >> 	polish the RCU usage
> >> 	deal with write logging in asynchroush mode in vhost
> >> 	add notifier block for mp device
> >> 	rename page_ctor to mp_port in netdevice.h to make it looks generic
> >> 	add mp_dev_change_flags() for mp device to change NIC state
> >> 	add CONIFG_VHOST_MPASSTHRU to limit the usage when module is not load
> >> 	a small fix for missing dev_put when fail
> >> 	using dynamic minor instead of static minor number
> >> 	a __KERNEL__ protect to mp_get_sock()
> >> 
> >> what we have done in v2:
> >> 	
> >> 	remove most of the RCU usage, since the ctor pointer is only
> >> 	changed by BIND/UNBIND ioctl, and during that time, NIC will be
> >> 	stopped to get good cleanup(all outstanding requests are finished),
> >> 	so the ctor pointer cannot be raced into wrong situation.
> >> 
> >> 	Remove the struct vhost_notifier with struct kiocb.
> >> 	Let vhost-net backend to alloc/free the kiocb and transfer them
> >> 	via sendmsg/recvmsg.
> >> 
> >> 	use get_user_pages_fast() and set_page_dirty_lock() when read.
> >> 
> >> 	Add some comments for netdev_mp_port_prep() and handle_mpassthru().
> >> 
> >> 
> >> Comments not addressed yet in this time:
> >> 	the async write logging is not satified by vhost-net
> >> 	Qemu needs a sync write
> >> 	a limit for locked pages from get_user_pages_fast()
> >> 	
> >> 		
> >> performance:
> >> 	using netperf with GSO/TSO disabled, 10G NIC, 
> >> 	disabled packet split mode, with raw socket case compared to vhost.
> >> 
> >> 	bindwidth will be from 1.1Gbps to 1.7Gbps
> >> 	CPU % from 120%-140% to 140%-160%
