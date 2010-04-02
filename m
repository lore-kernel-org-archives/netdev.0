From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v2 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Fri,  2 Apr 2010 15:25:00 +0800
Message-ID: <1270193100-6769-1-git-send-email-xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org, davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The idea is simple, just to pin the guest VM user space and then
let host NIC driver has the chance to directly DMA to it. 
The patches are based on vhost-net backend driver. We add a device
which provides proto_ops as sendmsg/recvmsg to vhost-net to
send/recv directly to/from the NIC driver. KVM guest who use the
vhost-net backend may bind any ethX interface in the host side to
get copyless data transfer thru guest virtio-net frontend.

The scenario is like this:

The guest virtio-net driver submits multiple requests thru vhost-net
backend driver to the kernel. And the requests are queued and then
completed after corresponding actions in h/w are done.

For read, user space buffers are dispensed to NIC driver for rx when
a page constructor API is invoked. Means NICs can allocate user buffers
from a page constructor. We add a hook in netif_receive_skb() function
to intercept the incoming packets, and notify the zero-copy device.

For write, the zero-copy deivce may allocates a new host skb and puts
payload on the skb_shinfo(skb)->frags, and copied the header to skb->data.
The request remains pending until the skb is transmitted by h/w.

Here, we have ever considered 2 ways to utilize the page constructor
API to dispense the user buffers.

One:	Modify __alloc_skb() function a bit, it can only allocate a 
	structure of sk_buff, and the data pointer is pointing to a 
	user buffer which is coming from a page constructor API.
	Then the shinfo of the skb is also from guest.
	When packet is received from hardware, the skb->data is filled
	directly by h/w. What we have done is in this way.

	Pros:	We can avoid any copy here.
	Cons:	Guest virtio-net driver needs to allocate skb as almost
		the same method with the host NIC drivers, say the size
		of netdev_alloc_skb() and the same reserved space in the
		head of skb. Many NIC drivers are the same with guest and
		ok for this. But some lastest NIC drivers reserves special
		room in skb head. To deal with it, we suggest to provide
		a method in guest virtio-net driver to ask for parameter
		we interest from the NIC driver when we know which device 
		we have bind to do zero-copy. Then we ask guest to do so.
		Is that reasonable?

Two:	Modify driver to get user buffer allocated from a page constructor
	API(to substitute alloc_page()), the user buffer are used as payload
	buffers and filled by h/w directly when packet is received. Driver
	should associate the pages with skb (skb_shinfo(skb)->frags). For 
	the head buffer side, let host allocates skb, and h/w fills it. 
	After that, the data filled in host skb header will be copied into
	guest header buffer which is submitted together with the payload buffer.

	Pros:	We could less care the way how guest or host allocates their
		buffers.
	Cons:	We still need a bit copy here for the skb header.

We are not sure which way is the better here. This is the first thing we want
to get comments from the community. We wish the modification to the network
part will be generic which not used by vhost-net backend only, but a user
application may use it as well when the zero-copy device may provides async
read/write operations later.

Please give comments especially for the network part modifications.


We provide multiple submits and asynchronous notifiicaton to 
vhost-net too.

Our goal is to improve the bandwidth and reduce the CPU usage.
Exact performance data will be provided later. But for simple
test with netperf, we found bindwidth up and CPU % up too,
but the bindwidth up ratio is much more than CPU % up ratio.

What we have not done yet:
	packet split support
	To support GRO
	Performance tuning

what we have done in v1:
	polish the RCU usage
	deal with write logging in asynchroush mode in vhost
	add notifier block for mp device
	rename page_ctor to mp_port in netdevice.h to make it looks generic
	add mp_dev_change_flags() for mp device to change NIC state
	add CONIFG_VHOST_MPASSTHRU to limit the usage when module is not load
	a small fix for missing dev_put when fail
	using dynamic minor instead of static minor number
	a __KERNEL__ protect to mp_get_sock()

what we have done in v2:
	
	remove most of the RCU usage, since the ctor pointer is only
	changed by BIND/UNBIND ioctl, and during that time, NIC will be
	stopped to get good cleanup(all outstanding requests are finished),
	so the ctor pointer cannot be raced into wrong situation.

	Remove the struct vhost_notifier with struct kiocb.
	Let vhost-net backend to alloc/free the kiocb and transfer them
	via sendmsg/recvmsg.

	use get_user_pages_fast() and set_page_dirty_lock() when read.

	Add some comments for netdev_mp_port_prep() and handle_mpassthru().


Comments not addressed yet in this time:
	the async write logging is not satified by vhost-net
	Qemu needs a sync write
	a limit for locked pages from get_user_pages_fast()
	
		
performance:
	using netperf with GSO/TSO disabled, 10G NIC, 
	disabled packet split mode, with raw socket case compared to vhost.

	bindwidth will be from 1.1Gbps to 1.7Gbps
	CPU % from 120%-140% to 140%-160%
