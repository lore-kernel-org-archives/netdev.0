From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Mon, 6 Oct 2014 09:55:53 -0700
Message-ID: <20141006095553.18097d68@urahara>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51521 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaJFQ4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:56:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5566770pad.19
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 09:56:06 -0700 (PDT)
In-Reply-To: <20141006000629.32055.2295.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 05 Oct 2014 17:06:31 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> This patch adds a net_device ops to split off a set of driver queues
> from the driver and map the queues into user space via mmap. This
> allows the queues to be directly manipulated from user space. For
> raw packet interface this removes any overhead from the kernel network
> stack.
> 
> Typically in an af_packet interface a packet_type handler is
> registered and used to filter traffic to the socket and do other
> things such as fan out traffic to multiple sockets. In this case the
> networking stack is being bypassed so this code is not run. So the
> hardware must push the correct traffic to the queues obtained from
> the ndo callback ndo_split_queue_pairs().
> 
> Fortunately there is already a flow classification interface which
> is part of the ethtool command set, ETHTOOL_SRXCLSRLINS. It is
> currently supported by multiple drivers including sfc, mlx4, niu,
> ixgbe, and i40e. Supporting some way to steer traffic to a queue
> is the _only_ hardware requirement to support the interface, plus
> the driver needs to implement the correct ndo ops. A follow on
> patch adds support for ixgbe but we expect at least the subset of
> drivers implementing ETHTOOL_SRXCLSRLINS to be implemented later.
> 
> The interface is driven over an af_packet socket which we believe
> is the most natural interface to use. Because it is already used
> for raw packet interfaces which is what we are providing here.
>  The high level flow for this interface looks like:
> 
> 	bind(fd, &sockaddr, sizeof(sockaddr));
> 
> 	/* Get the device type and info */
> 	getsockopt(fd, SOL_PACKET, PACKET_DEV_DESC_INFO, &def_info,
> 		   &optlen);
> 
> 	/* With device info we can look up descriptor format */
> 
> 	/* Get the layout of ring space offset, page_sz, cnt */
> 	getsockopt(fd, SOL_PACKET, PACKET_DEV_QPAIR_MAP_REGION_INFO,
> 		   &info, &optlen);
> 
> 	/* request some queues from the driver */
> 	setsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
> 		   &qpairs_info, sizeof(qpairs_info));
> 
> 	/* if we let the driver pick us queues learn which queues
>          * we were given
>          */
> 	getsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
> 		   &qpairs_info, sizeof(qpairs_info));
> 
> 	/* And mmap queue pairs to user space */
> 	mmap(NULL, info.tp_dev_bar_sz, PROT_READ | PROT_WRITE,
> 	     MAP_SHARED, fd, 0);
> 
> 	/* Now we have some user space queues to read/write to*/
> 
> There is one critical difference when running with these interfaces
> vs running without them. In the normal case the af_packet module
> uses a standard descriptor format exported by the af_packet user
> space headers. In this model because we are working directly with
> driver queues the descriptor format maps to the descriptor format
> used by the device. User space applications can learn device
> information from the socket option PACKET_DEV_DESC_INFO which
> should provide enough details to extrapulate the descriptor formats.
> Although this adds some complexity to user space it removes the
> requirement to copy descriptor fields around.
> 
> The formats are usually provided by the device vendor documentation
> If folks want I can provide a follow up patch to provide the formats
> in a .h file in ./include/uapi/linux/ for ease of use. I have access
> to formats for ixgbe and mlx drivers other driver owners would need to
> provide their formats.
> 
> We tested this interface using traffic generators and doing basic
> L2 forwarding tests on ixgbe devices. Our tests use a set of patches
> to DPDK to enable an interface using this socket interfaace. With
> this interface we can xmit/receive @ line rate from a test user space
> application on a single core.
> 
> Additionally we have a set of DPDK patches to enable DPDK with this
> interface. DPDK can be downloaded @ dpdk.org although as I hope is
> clear from above DPDK is just our paticular test environment we
> expect other libraries could be built on this interface.
> 
> Signed-off-by: Danny Zhou <danny.zhou@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I like the ability to share a device between kernel and user mode networking.
The model used for DPDK for this is really ugly and fragile/broken.
Your proposal assumes that you fully trust the user mode networking application
which is not a generally safe assumption.

A device can DMA from/to any arbitrary physical memory. 
And it would be hard to use IOMMU to protect because the
IOMMU doesn't know that the difference between the applications queue and
the rest of the queues.

At least with DPDK you can use VFIO, and you are claiming the whole device to
allow protection against random memory being read/written.
