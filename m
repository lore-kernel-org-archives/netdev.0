From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring
 access in user space
Date: Tue, 13 Jan 2015 13:35:10 +0100
Message-ID: <1421152510.13626.22.camel@stressinduktion.org>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, dborkman@redhat.com, john.ronciak@intel.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36169 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbbAMMfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 07:35:14 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 67E6E20B1B
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 07:35:13 -0500 (EST)
In-Reply-To: <20150113043509.29985.33515.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2015-01-12 at 20:35 -0800, John Fastabend wrote:
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
> ---
>  include/linux/netdevice.h      |   79 ++++++++
>  include/uapi/linux/if_packet.h |   88 +++++++++
>  net/packet/af_packet.c         |  397 ++++++++++++++++++++++++++++++++++++++++
>  net/packet/internal.h          |   10 +
>  4 files changed, 573 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 679e6e9..b71c97d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -52,6 +52,8 @@
>  #include <linux/neighbour.h>
>  #include <uapi/linux/netdevice.h>
>  
> +#include <linux/if_packet.h>
> +
>  struct netpoll_info;
>  struct device;
>  struct phy_device;
> @@ -1030,6 +1032,54 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>   *	Called to notify switch device port of bridge port STP
>   *	state change.
> + *
> + * int (*ndo_split_queue_pairs) (struct net_device *dev,
> + *				 unsigned int qpairs_start_from,
> + *				 unsigned int qpairs_num,
> + *				 struct sock *sk)
> + *	Called to request a set of queues from the driver to be handed to the
> + *	callee for management. After this returns the driver will not use the
> + *	queues.
> + *
> + * int (*ndo_get_split_queue_pairs) (struct net_device *dev,
> + *				 unsigned int *qpairs_start_from,
> + *				 unsigned int *qpairs_num,
> + *				 struct sock *sk)
> + *	Called to get the location of queues that have been split for user
> + *	space to use. The socket must have previously requested the queues via
> + *	ndo_split_queue_pairs successfully.
> + *
> + * int (*ndo_return_queue_pairs) (struct net_device *dev,
> + *				  struct sock *sk)
> + *	Called to return a set of queues identified by sock to the driver. The
> + *	socket must have previously requested the queues via
> + *	ndo_split_queue_pairs for this action to be performed.
> + *
> + * int (*ndo_get_device_qpair_map_region_info) (struct net_device *dev,
> + *				struct tpacket_dev_qpair_map_region_info *info)
> + *	Called to return mapping of queue memory region.
> + *
> + * int (*ndo_get_device_desc_info) (struct net_device *dev,
> + *				    struct tpacket_dev_info *dev_info)
> + *	Called to get device specific information. This should uniquely identify
> + *	the hardware so that descriptor formats can be learned by the stack/user
> + *	space.
> + *
> + * int (*ndo_direct_qpair_page_map) (struct vm_area_struct *vma,
> + *				     struct net_device *dev)
> + *	Called to map queue pair range from split_queue_pairs into mmap region.
> + *
> + * int (*ndo_direct_validate_dma_mem_region_map)
> + *					(struct net_device *dev,
> + *					 struct tpacket_dma_mem_region *region,
> + *					 struct sock *sk)
> + *	Called to validate DMA address remaping for userspace memory region
> + *
> + * int (*ndo_get_dma_region_info)
> + *				 (struct net_device *dev,
> + *				  struct tpacket_dma_mem_region *region,
> + *				  struct sock *sk)
> + *	Called to get dma region' information such as iova.
>   */
>  struct net_device_ops {
>  	int			(*ndo_init)(struct net_device *dev);
> @@ -1190,6 +1240,35 @@ struct net_device_ops {
>  	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
>  							      u8 state);
>  #endif
> +	int			(*ndo_split_queue_pairs)(struct net_device *dev,
> +					 unsigned int qpairs_start_from,
> +					 unsigned int qpairs_num,
> +					 struct sock *sk);
> +	int			(*ndo_get_split_queue_pairs)
> +					(struct net_device *dev,
> +					 unsigned int *qpairs_start_from,
> +					 unsigned int *qpairs_num,
> +					 struct sock *sk);
> +	int			(*ndo_return_queue_pairs)
> +					(struct net_device *dev,
> +					 struct sock *sk);
> +	int			(*ndo_get_device_qpair_map_region_info)
> +					(struct net_device *dev,
> +					 struct tpacket_dev_qpair_map_region_info *info);
> +	int			(*ndo_get_device_desc_info)
> +					(struct net_device *dev,
> +					 struct tpacket_dev_info *dev_info);
> +	int			(*ndo_direct_qpair_page_map)
> +					(struct vm_area_struct *vma,
> +					 struct net_device *dev);
> +	int			(*ndo_validate_dma_mem_region_map)
> +					(struct net_device *dev,
> +					 struct tpacket_dma_mem_region *region,
> +					 struct sock *sk);
> +	int			(*ndo_get_dma_region_info)
> +					(struct net_device *dev,
> +					 struct tpacket_dma_mem_region *region,
> +					 struct sock *sk);
>  };
>  
>  /**
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index da2d668..eb7a727 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -54,6 +54,13 @@ struct sockaddr_ll {
>  #define PACKET_FANOUT			18
>  #define PACKET_TX_HAS_OFF		19
>  #define PACKET_QDISC_BYPASS		20
> +#define PACKET_RXTX_QPAIRS_SPLIT	21
> +#define PACKET_RXTX_QPAIRS_RETURN	22
> +#define PACKET_DEV_QPAIR_MAP_REGION_INFO	23
> +#define PACKET_DEV_DESC_INFO		24
> +#define PACKET_DMA_MEM_REGION_MAP       25
> +#define PACKET_DMA_MEM_REGION_RELEASE   26
> +
>  
>  #define PACKET_FANOUT_HASH		0
>  #define PACKET_FANOUT_LB		1
> @@ -64,6 +71,87 @@ struct sockaddr_ll {
>  #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
>  #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
>  
> +#define PACKET_MAX_NUM_MAP_MEMORY_REGIONS 64
> +#define PACKET_MAX_NUM_DESC_FORMATS	  8
> +#define PACKET_MAX_NUM_DESC_FIELDS	  64
> +#define PACKET_NIC_DESC_FIELD(fseq, foffset, fwidth, falign, fbo) \
> +		.seqn = (__u8)fseq,				\
> +		.offset = (__u8)foffset,			\
> +		.width = (__u8)fwidth,				\
> +		.align = (__u8)falign,				\
> +		.byte_order = (__u8)fbo

Are the __u8 necessary? They seem to hide compiler warnings?

> +
> +#define MAX_MAP_MEMORY_REGIONS	64
> +
> +/* setsockopt takes addr, size ,direction parametner, getsockopt takes
> + * iova, size, direction.
> + * */
> +struct tpacket_dma_mem_region {
> +	void *addr;		/* userspace virtual address */
> +	__u64 phys_addr;	/* physical address */
> +	__u64 iova;		/* IO virtual address used for DMA */
> +	unsigned long size;	/* size of region */
> +	int direction;		/* dma data direction */
> +};

Have you tested this with with 32 bit user space and 32 bit kernel, too?
I don't have any problem with only supporting 64 bit kernels for this
feature, but looking through the code I wonder if we handle the __u64
addresses correctly in all situations.

The other question I have, would it make sense to move the

+#ifdef CONFIG_DMA_MEMORY_PROTECTION
+	/* IOVA not equal to physical address means IOMMU takes effect */
+	if (region->phys_addr == region->iova)
+		return -EFAULT;
+#endif

check from the ixgbe driver into the kernel core, so we never expose
memory mapped io which is not protected by its own memory domain?

Thanks,
Hannes
