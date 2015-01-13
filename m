From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 11:19:58 -0500
Message-ID: <20150113161958.GD1547@hmsreliant.think-freely.org>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, danny.zhou@intel.com, dborkman@redhat.com,
	john.ronciak@intel.com, hannes@stressinduktion.org,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44927 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbAMQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:20:12 -0500
Content-Disposition: inline
In-Reply-To: <20150113043509.29985.33515.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 08:35:11PM -0800, John Fastabend wrote:
> This patch adds net_device ops to split off a set of driver queues
> from the driver and map the queues into user space via mmap. This
> allows the queues to be directly manipulated from user space. For
> raw packet interface this removes any overhead from the kernel network
> stack.
> 
> With these operations we bypass the network stack and packet_type
> handlers that would typically send traffic to an af_packet socket.
> This means hardware must do the forwarding. To do this ew can use
> the ETHTOOL_SRXCLSRLINS ops in the ethtool command set. It is
> currently supported by multiple drivers including sfc, mlx4, niu,
> ixgbe, and i40e. Supporting some way to steer traffic to a queue
> is the _only_ hardware requirement to support this interface.
> 
> A follow on patch adds support for ixgbe but we expect at least
> the subset of drivers implementing ETHTOOL_SRXCLSRLINS can be
> implemented later.
> 
> The high level flow, leveraging the af_packet control path, looks
> like:
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
> information from the socket option PACKET_DEV_DESC_INFO. These
> are described by giving the vendor/deviceid and a descriptor layout
> in offset/length/width/alignment/byte_ordering.
> 
> To protect against arbitrary DMA writes IOMMU devices put memory
> in a single domain to stop arbitrary DMA to memory. Note it would
> be possible to dma into another sockets pages because most NIC
> devices only support a single domain. This would require being
> able to guess another sockets page layout. However the socket
> operation does require CAP_NET_ADMIN privileges.
> 
> Additionally we have a set of DPDK patches to enable DPDK with this
> interface. DPDK can be downloaded @ dpdk.org although as I hope is
> clear from above DPDK is just our paticular test environment we
> expect other libraries could be built on this interface.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Just thinking about this a bit, have you considered collapsing this work in with
the macvtap work you and I did when we enabled some nics to allocate queue pairs
to those tap devices?  I ask, because it seems like that infrastructure already
embodies the notion of reserving queues from underlying hardware, and so if you
were to only allow queue mapping from macvlan/tap devices, you could reduce both
the api surface that you need to add in your ndo_ops (no more need for a ndo op
to reserve/free queues, and you could eliminate the need to explicitly reserve
queues from user space (i.e. reserving queues on a macvtap device automatically
reserves all its queues).

Neil
