From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Thu, 5 Aug 2010 16:52:15 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791BAB3B81D8@shsmsx502.ccr.corp.intel.com>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64889 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839Ab0HEIxt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 04:53:49 -0400
In-Reply-To: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert,
The v8 patches are modified mostly based on your comments about
napi_gro_frags interface. How do you think about the patches about
net core system part?
We know currently there are some comments about the mp device,
such as to support zero-copy for tun/tap and macvtap. Since there 
isn't a decision yet about it. May you give comments about the 
net core system first, since this part is all the same for zero-copy.

Thanks
Xiaohui

>-----Original Message-----
>From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@vger.kernel.org] On
>Behalf Of xiaohui.xin@intel.com
>Sent: Thursday, July 29, 2010 7:15 PM
>To: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apana.org.au;
>jdike@linux.intel.com
>Subject: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
>
>We provide an zero-copy method which driver side may get external
>buffers to DMA. Here external means driver don't use kernel space
>to allocate skb buffers. Currently the external buffer can be from
>guest virtio-net driver.
>
>The idea is simple, just to pin the guest VM user space and then
>let host NIC driver has the chance to directly DMA to it.
>The patches are based on vhost-net backend driver. We add a device
>which provides proto_ops as sendmsg/recvmsg to vhost-net to
>send/recv directly to/from the NIC driver. KVM guest who use the
>vhost-net backend may bind any ethX interface in the host side to
>get copyless data transfer thru guest virtio-net frontend.
>
>patch 01-10:  	net core and kernel changes.
>patch 11-13:  	new device as interface to mantpulate external buffers.
>patch 14: 	for vhost-net.
>patch 15:	An example on modifying NIC driver to using napi_gro_frags().
>patch 16:	An example how to get guest buffers based on driver
>		who using napi_gro_frags().
>
>The guest virtio-net driver submits multiple requests thru vhost-net
>backend driver to the kernel. And the requests are queued and then
>completed after corresponding actions in h/w are done.
>
>For read, user space buffers are dispensed to NIC driver for rx when
>a page constructor API is invoked. Means NICs can allocate user buffers
>from a page constructor. We add a hook in netif_receive_skb() function
>to intercept the incoming packets, and notify the zero-copy device.
>
>For write, the zero-copy deivce may allocates a new host skb and puts
>payload on the skb_shinfo(skb)->frags, and copied the header to skb->data.
>The request remains pending until the skb is transmitted by h/w.
>
>We provide multiple submits and asynchronous notifiicaton to
>vhost-net too.
>
>Our goal is to improve the bandwidth and reduce the CPU usage.
>Exact performance data will be provided later.
>
>What we have not done yet:
>	Performance tuning
>
>what we have done in v1:
>	polish the RCU usage
>	deal with write logging in asynchroush mode in vhost
>	add notifier block for mp device
>	rename page_ctor to mp_port in netdevice.h to make it looks generic
>	add mp_dev_change_flags() for mp device to change NIC state
>	add CONIFG_VHOST_MPASSTHRU to limit the usage when module is not load
>	a small fix for missing dev_put when fail
>	using dynamic minor instead of static minor number
>	a __KERNEL__ protect to mp_get_sock()
>
>what we have done in v2:
>
>	remove most of the RCU usage, since the ctor pointer is only
>	changed by BIND/UNBIND ioctl, and during that time, NIC will be
>	stopped to get good cleanup(all outstanding requests are finished),
>	so the ctor pointer cannot be raced into wrong situation.
>
>	Remove the struct vhost_notifier with struct kiocb.
>	Let vhost-net backend to alloc/free the kiocb and transfer them
>	via sendmsg/recvmsg.
>
>	use get_user_pages_fast() and set_page_dirty_lock() when read.
>
>	Add some comments for netdev_mp_port_prep() and handle_mpassthru().
>
>what we have done in v3:
>	the async write logging is rewritten
>	a drafted synchronous write function for qemu live migration
>	a limit for locked pages from get_user_pages_fast() to prevent Dos
>	by using RLIMIT_MEMLOCK
>
>
>what we have done in v4:
>	add iocb completion callback from vhost-net to queue iocb in mp device
>	replace vq->receiver by mp_sock_data_ready()
>	remove stuff in mp device which access structures from vhost-net
>	modify skb_reserve() to ignore host NIC driver reserved space
>	rebase to the latest vhost tree
>	split large patches into small pieces, especially for net core part.
>
>
>what we have done in v5:
>	address Arnd Bergmann's comments
>		-remove IFF_MPASSTHRU_EXCL flag in mp device
>		-Add CONFIG_COMPAT macro
>		-remove mp_release ops
>	move dev_is_mpassthru() as inline func
>	fix a bug in memory relinquish
>	Apply to current git (2.6.34-rc6) tree.
>
>what we have done in v6:
>	move create_iocb() out of page_dtor which may happen in interrupt context
>	-This remove the potential issues which lock called in interrupt context
>	make the cache used by mp, vhost as static, and created/destoryed during
>	modules init/exit functions.
>	-This makes multiple mp guest created at the same time.
>
>what we have done in v7:
>	some cleanup prepared to suppprt PS mode
>
>what we have done in v8
>	discarding the modifications to point skb->data to guest buffer directly.
>	Add code to modify driver to support napi_gro_frags() with Herbert's comments.
>	To support PS mode.
>	Add mergeable buffer support in mp device.
>	Add GSO/GRO support in mp deice.
>	Address comments from Eric Dumazet about cache line and rcu usage.
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
