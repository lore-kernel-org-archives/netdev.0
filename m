From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 1/2] net: af_packet support for direct ring access in
 user space
Date: Mon, 12 Jan 2015 20:35:11 -0800
Message-ID: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: danny.zhou@intel.com, nhorman@tuxdriver.com, dborkman@redhat.com,
	john.ronciak@intel.com, hannes@stressinduktion.org,
	brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:50137 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbAMEfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 23:35:36 -0500
Received: by mail-ob0-f176.google.com with SMTP id vb8so760328obc.7
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 20:35:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds net_device ops to split off a set of driver queues
from the driver and map the queues into user space via mmap. This
allows the queues to be directly manipulated from user space. For
raw packet interface this removes any overhead from the kernel network
stack.

With these operations we bypass the network stack and packet_type
handlers that would typically send traffic to an af_packet socket.
This means hardware must do the forwarding. To do this ew can use
the ETHTOOL_SRXCLSRLINS ops in the ethtool command set. It is
currently supported by multiple drivers including sfc, mlx4, niu,
ixgbe, and i40e. Supporting some way to steer traffic to a queue
is the _only_ hardware requirement to support this interface.

A follow on patch adds support for ixgbe but we expect at least
the subset of drivers implementing ETHTOOL_SRXCLSRLINS can be
implemented later.

The high level flow, leveraging the af_packet control path, looks
like:

	bind(fd, &sockaddr, sizeof(sockaddr));

	/* Get the device type and info */
	getsockopt(fd, SOL_PACKET, PACKET_DEV_DESC_INFO, &def_info,
		   &optlen);

	/* With device info we can look up descriptor format */

	/* Get the layout of ring space offset, page_sz, cnt */
	getsockopt(fd, SOL_PACKET, PACKET_DEV_QPAIR_MAP_REGION_INFO,
		   &info, &optlen);

	/* request some queues from the driver */
	setsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
		   &qpairs_info, sizeof(qpairs_info));

	/* if we let the driver pick us queues learn which queues
         * we were given
         */
	getsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
		   &qpairs_info, sizeof(qpairs_info));

	/* And mmap queue pairs to user space */
	mmap(NULL, info.tp_dev_bar_sz, PROT_READ | PROT_WRITE,
	     MAP_SHARED, fd, 0);

	/* Now we have some user space queues to read/write to*/

There is one critical difference when running with these interfaces
vs running without them. In the normal case the af_packet module
uses a standard descriptor format exported by the af_packet user
space headers. In this model because we are working directly with
driver queues the descriptor format maps to the descriptor format
used by the device. User space applications can learn device
information from the socket option PACKET_DEV_DESC_INFO. These
are described by giving the vendor/deviceid and a descriptor layout
in offset/length/width/alignment/byte_ordering.

To protect against arbitrary DMA writes IOMMU devices put memory
in a single domain to stop arbitrary DMA to memory. Note it would
be possible to dma into another sockets pages because most NIC
devices only support a single domain. This would require being
able to guess another sockets page layout. However the socket
operation does require CAP_NET_ADMIN privileges.

Additionally we have a set of DPDK patches to enable DPDK with this
interface. DPDK can be downloaded @ dpdk.org although as I hope is
clear from above DPDK is just our paticular test environment we
expect other libraries could be built on this interface.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h      |   79 ++++++++
 include/uapi/linux/if_packet.h |   88 +++++++++
 net/packet/af_packet.c         |  397 ++++++++++++++++++++++++++++++++++++++++
 net/packet/internal.h          |   10 +
 4 files changed, 573 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 679e6e9..b71c97d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,8 @@
 #include <linux/neighbour.h>
 #include <uapi/linux/netdevice.h>
 
+#include <linux/if_packet.h>
+
 struct netpoll_info;
 struct device;
 struct phy_device;
@@ -1030,6 +1032,54 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
  *	Called to notify switch device port of bridge port STP
  *	state change.
+ *
+ * int (*ndo_split_queue_pairs) (struct net_device *dev,
+ *				 unsigned int qpairs_start_from,
+ *				 unsigned int qpairs_num,
+ *				 struct sock *sk)
+ *	Called to request a set of queues from the driver to be handed to the
+ *	callee for management. After this returns the driver will not use the
+ *	queues.
+ *
+ * int (*ndo_get_split_queue_pairs) (struct net_device *dev,
+ *				 unsigned int *qpairs_start_from,
+ *				 unsigned int *qpairs_num,
+ *				 struct sock *sk)
+ *	Called to get the location of queues that have been split for user
+ *	space to use. The socket must have previously requested the queues via
+ *	ndo_split_queue_pairs successfully.
+ *
+ * int (*ndo_return_queue_pairs) (struct net_device *dev,
+ *				  struct sock *sk)
+ *	Called to return a set of queues identified by sock to the driver. The
+ *	socket must have previously requested the queues via
+ *	ndo_split_queue_pairs for this action to be performed.
+ *
+ * int (*ndo_get_device_qpair_map_region_info) (struct net_device *dev,
+ *				struct tpacket_dev_qpair_map_region_info *info)
+ *	Called to return mapping of queue memory region.
+ *
+ * int (*ndo_get_device_desc_info) (struct net_device *dev,
+ *				    struct tpacket_dev_info *dev_info)
+ *	Called to get device specific information. This should uniquely identify
+ *	the hardware so that descriptor formats can be learned by the stack/user
+ *	space.
+ *
+ * int (*ndo_direct_qpair_page_map) (struct vm_area_struct *vma,
+ *				     struct net_device *dev)
+ *	Called to map queue pair range from split_queue_pairs into mmap region.
+ *
+ * int (*ndo_direct_validate_dma_mem_region_map)
+ *					(struct net_device *dev,
+ *					 struct tpacket_dma_mem_region *region,
+ *					 struct sock *sk)
+ *	Called to validate DMA address remaping for userspace memory region
+ *
+ * int (*ndo_get_dma_region_info)
+ *				 (struct net_device *dev,
+ *				  struct tpacket_dma_mem_region *region,
+ *				  struct sock *sk)
+ *	Called to get dma region' information such as iova.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1190,6 +1240,35 @@ struct net_device_ops {
 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
 							      u8 state);
 #endif
+	int			(*ndo_split_queue_pairs)(struct net_device *dev,
+					 unsigned int qpairs_start_from,
+					 unsigned int qpairs_num,
+					 struct sock *sk);
+	int			(*ndo_get_split_queue_pairs)
+					(struct net_device *dev,
+					 unsigned int *qpairs_start_from,
+					 unsigned int *qpairs_num,
+					 struct sock *sk);
+	int			(*ndo_return_queue_pairs)
+					(struct net_device *dev,
+					 struct sock *sk);
+	int			(*ndo_get_device_qpair_map_region_info)
+					(struct net_device *dev,
+					 struct tpacket_dev_qpair_map_region_info *info);
+	int			(*ndo_get_device_desc_info)
+					(struct net_device *dev,
+					 struct tpacket_dev_info *dev_info);
+	int			(*ndo_direct_qpair_page_map)
+					(struct vm_area_struct *vma,
+					 struct net_device *dev);
+	int			(*ndo_validate_dma_mem_region_map)
+					(struct net_device *dev,
+					 struct tpacket_dma_mem_region *region,
+					 struct sock *sk);
+	int			(*ndo_get_dma_region_info)
+					(struct net_device *dev,
+					 struct tpacket_dma_mem_region *region,
+					 struct sock *sk);
 };
 
 /**
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index da2d668..eb7a727 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -54,6 +54,13 @@ struct sockaddr_ll {
 #define PACKET_FANOUT			18
 #define PACKET_TX_HAS_OFF		19
 #define PACKET_QDISC_BYPASS		20
+#define PACKET_RXTX_QPAIRS_SPLIT	21
+#define PACKET_RXTX_QPAIRS_RETURN	22
+#define PACKET_DEV_QPAIR_MAP_REGION_INFO	23
+#define PACKET_DEV_DESC_INFO		24
+#define PACKET_DMA_MEM_REGION_MAP       25
+#define PACKET_DMA_MEM_REGION_RELEASE   26
+
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
@@ -64,6 +71,87 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
+#define PACKET_MAX_NUM_MAP_MEMORY_REGIONS 64
+#define PACKET_MAX_NUM_DESC_FORMATS	  8
+#define PACKET_MAX_NUM_DESC_FIELDS	  64
+#define PACKET_NIC_DESC_FIELD(fseq, foffset, fwidth, falign, fbo) \
+		.seqn = (__u8)fseq,				\
+		.offset = (__u8)foffset,			\
+		.width = (__u8)fwidth,				\
+		.align = (__u8)falign,				\
+		.byte_order = (__u8)fbo
+
+#define MAX_MAP_MEMORY_REGIONS	64
+
+/* setsockopt takes addr, size ,direction parametner, getsockopt takes
+ * iova, size, direction.
+ * */
+struct tpacket_dma_mem_region {
+	void *addr;		/* userspace virtual address */
+	__u64 phys_addr;	/* physical address */
+	__u64 iova;		/* IO virtual address used for DMA */
+	unsigned long size;	/* size of region */
+	int direction;		/* dma data direction */
+};
+
+struct tpacket_dev_qpair_map_region_info {
+	unsigned int tp_dev_bar_sz;		/* size of BAR */
+	unsigned int tp_dev_sysm_sz;		/* size of systerm memory */
+	/* number of contiguous memory on BAR mapping to user space */
+	unsigned int tp_num_map_regions;
+	/* number of contiguous memory on system mapping to user apce */
+	unsigned int tp_num_sysm_map_regions;
+	struct map_page_region {
+		unsigned page_offset;	/* offset to start of region */
+		unsigned page_sz;	/* size of page */
+		unsigned page_cnt;	/* number of pages */
+	} tp_regions[MAX_MAP_MEMORY_REGIONS];
+};
+
+struct tpacket_dev_qpairs_info {
+	unsigned int tp_qpairs_start_from;	/* qpairs index to start from */
+	unsigned int tp_qpairs_num;		/* number of qpairs */
+};
+
+enum tpack_desc_byte_order {
+	BO_NATIVE = 0,
+	BO_NETWORK,
+	BO_BIG_ENDIAN,
+	BO_LITTLE_ENDIAN,
+};
+
+struct tpacket_nic_desc_fld {
+	__u8 seqn;	/* Sequency index of descriptor field */
+	__u8 offset;	/* Offset to start */
+	__u8 width;	/* Width of field */
+	__u8 align;	/* Alignment in bits */
+	enum tpack_desc_byte_order byte_order;	/* Endian flag */
+};
+
+struct tpacket_nic_desc_expr {
+	__u8 version;		/* Version number */
+	__u8 size;		/* Descriptor size in bytes */
+	enum tpack_desc_byte_order byte_order;		/* Endian flag */
+	__u8 num_of_fld;	/* Number of valid fields */
+	/* List of each descriptor field */
+	struct tpacket_nic_desc_fld fields[PACKET_MAX_NUM_DESC_FIELDS];
+};
+
+struct tpacket_dev_info {
+	__u16	tp_device_id;
+	__u16	tp_vendor_id;
+	__u16	tp_subsystem_device_id;
+	__u16	tp_subsystem_vendor_id;
+	__u32	tp_numa_node;
+	__u32	tp_revision_id;
+	__u32	tp_num_total_qpairs;
+	__u32	tp_num_inuse_qpairs;
+	__u32	tp_num_rx_desc_fmt;
+	__u32	tp_num_tx_desc_fmt;
+	struct tpacket_nic_desc_expr tp_rx_dexpr[PACKET_MAX_NUM_DESC_FORMATS];
+	struct tpacket_nic_desc_expr tp_tx_dexpr[PACKET_MAX_NUM_DESC_FORMATS];
+};
+
 struct tpacket_stats {
 	unsigned int	tp_packets;
 	unsigned int	tp_drops;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6880f34..8cd17da 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -214,6 +214,9 @@ static void prb_clear_rxhash(struct tpacket_kbdq_core *,
 static void prb_fill_vlan_info(struct tpacket_kbdq_core *,
 		struct tpacket3_hdr *);
 static void packet_flush_mclist(struct sock *sk);
+static int umem_release(struct net_device *dev, struct packet_sock *po);
+static int get_umem_pages(struct tpacket_dma_mem_region *region,
+			  struct packet_umem_region *umem);
 
 struct packet_skb_cb {
 	unsigned int origlen;
@@ -2633,6 +2636,16 @@ static int packet_release(struct socket *sock)
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	preempt_enable();
 
+	if (po->tp_owns_queue_pairs) {
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (dev) {
+			dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
+			umem_release(dev, po);
+		}
+	}
+
 	spin_lock(&po->bind_lock);
 	unregister_prot_hook(sk, false);
 	packet_cached_dev_reset(po);
@@ -2829,6 +2842,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	po->num = proto;
 	po->xmit = dev_queue_xmit;
 
+	INIT_LIST_HEAD(&po->umem_list);
+
 	err = packet_alloc_pending(po);
 	if (err)
 		goto out2;
@@ -3226,6 +3241,88 @@ static void packet_flush_mclist(struct sock *sk)
 }
 
 static int
+get_umem_pages(struct tpacket_dma_mem_region *region,
+	       struct packet_umem_region *umem)
+{
+	struct page **page_list;
+	unsigned long npages;
+	unsigned long offset;
+	unsigned long base;
+	unsigned long i;
+	int ret;
+	dma_addr_t phys_base;
+
+	phys_base = (region->phys_addr) & PAGE_MASK;
+	base = ((unsigned long)region->addr) & PAGE_MASK;
+	offset = ((unsigned long)region->addr) & (~PAGE_MASK);
+	npages = PAGE_ALIGN(region->size + offset) >> PAGE_SHIFT;
+
+	npages = min_t(unsigned long, npages, umem->nents);
+	sg_init_table(umem->sglist, npages);
+
+	umem->nmap = 0;
+	page_list = (struct page **)__get_free_page(GFP_KERNEL);
+	if (!page_list)
+		return -ENOMEM;
+
+	while (npages) {
+		unsigned long min = min_t(unsigned long, npages,
+					  PAGE_SIZE / sizeof(struct page *));
+
+		ret = get_user_pages(current, current->mm, base, min,
+				     1, 0, page_list, NULL);
+		if (ret < 0)
+			break;
+
+		base += ret * PAGE_SIZE;
+		npages -= ret;
+
+		/* validate if the memory region is physically contigenous */
+		for (i = 0; i < ret; i++) {
+			unsigned int page_index =
+				(page_to_phys(page_list[i]) - phys_base) /
+				PAGE_SIZE;
+
+			if (page_index != umem->nmap + i) {
+				int j;
+
+				for (j = 0; j < (umem->nmap + i); j++)
+					put_page(sg_page(&umem->sglist[j]));
+
+				free_page((unsigned long)page_list);
+				return -EFAULT;
+			}
+
+			sg_set_page(&umem->sglist[umem->nmap + i],
+				    page_list[i], PAGE_SIZE, 0);
+		}
+
+		umem->nmap += ret;
+	}
+
+	free_page((unsigned long)page_list);
+	return 0;
+}
+
+static int
+umem_release(struct net_device *dev, struct packet_sock *po)
+{
+	struct packet_umem_region *umem, *tmp;
+	int i;
+
+	list_for_each_entry_safe(umem, tmp, &po->umem_list, list) {
+		dma_unmap_sg(dev->dev.parent, umem->sglist,
+			     umem->nmap, umem->direction);
+		for (i = 0; i < umem->nmap; i++)
+			put_page(sg_page(&umem->sglist[i]));
+
+		vfree(umem);
+	}
+
+	return 0;
+}
+
+static int
 packet_setsockopt(struct socket *sock, int level, int optname, char __user *optval, unsigned int optlen)
 {
 	struct sock *sk = sock->sk;
@@ -3428,6 +3525,167 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
 		return 0;
 	}
+	case PACKET_RXTX_QPAIRS_SPLIT:
+	{
+		struct tpacket_dev_qpairs_info qpairs;
+		const struct net_device_ops *ops;
+		struct net_device *dev;
+		int err;
+
+		if (optlen != sizeof(qpairs))
+			return -EINVAL;
+		if (copy_from_user(&qpairs, optval, sizeof(qpairs)))
+			return -EFAULT;
+
+		/* Only allow one set of queues to be owned by userspace */
+		if (po->tp_owns_queue_pairs)
+			return -EBUSY;
+
+		/* This call only works after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+		ops = dev->netdev_ops;
+		if (!ops->ndo_split_queue_pairs)
+			return -EOPNOTSUPP;
+
+		err =  ops->ndo_split_queue_pairs(dev,
+						  qpairs.tp_qpairs_start_from,
+						  qpairs.tp_qpairs_num, sk);
+		if (!err)
+			po->tp_owns_queue_pairs = true;
+
+		return err;
+	}
+	case PACKET_RXTX_QPAIRS_RETURN:
+	{
+		struct tpacket_dev_qpairs_info qpairs_info;
+		const struct net_device_ops *ops;
+		struct net_device *dev;
+		int err;
+
+		if (optlen != sizeof(qpairs_info))
+			return -EINVAL;
+		if (copy_from_user(&qpairs_info, optval, sizeof(qpairs_info)))
+			return -EFAULT;
+
+		if (!po->tp_owns_queue_pairs)
+			return -EINVAL;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+		ops = dev->netdev_ops;
+		if (!ops->ndo_split_queue_pairs)
+			return -EOPNOTSUPP;
+
+		err =  dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
+		if (!err)
+			po->tp_owns_queue_pairs = false;
+
+		return err;
+	}
+	case PACKET_DMA_MEM_REGION_MAP:
+	{
+		struct tpacket_dma_mem_region region;
+		const struct net_device_ops *ops;
+		struct net_device *dev;
+		struct packet_umem_region *umem;
+		unsigned long npages;
+		unsigned long offset;
+		unsigned long i;
+		int err;
+
+		if (optlen != sizeof(region))
+			return -EINVAL;
+		if (copy_from_user(&region, optval, sizeof(region)))
+			return -EFAULT;
+		if ((region.direction != DMA_BIDIRECTIONAL) &&
+		    (region.direction != DMA_TO_DEVICE) &&
+		    (region.direction != DMA_FROM_DEVICE))
+			return -EFAULT;
+
+		if (!po->tp_owns_queue_pairs)
+			return -EINVAL;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+
+		offset = ((unsigned long)region.addr) & (~PAGE_MASK);
+		npages = PAGE_ALIGN(region.size + offset) >> PAGE_SHIFT;
+
+		umem = vzalloc(sizeof(*umem) +
+			       sizeof(struct scatterlist) * npages);
+		if (!umem)
+			return -ENOMEM;
+
+		umem->nents = npages;
+		umem->direction = region.direction;
+
+		down_write(&current->mm->mmap_sem);
+		if (get_umem_pages(&region, umem) < 0) {
+			ret = -EFAULT;
+			goto exit;
+		}
+
+		if ((umem->nmap == npages) &&
+		    (0 != dma_map_sg(dev->dev.parent, umem->sglist,
+				     umem->nmap, region.direction))) {
+			region.iova = sg_dma_address(umem->sglist) + offset;
+
+			ops = dev->netdev_ops;
+			if (!ops->ndo_validate_dma_mem_region_map) {
+				ret = -EOPNOTSUPP;
+				goto unmap;
+			}
+
+			/* use driver to validate mapping of dma memory */
+			err = ops->ndo_validate_dma_mem_region_map(dev,
+								   &region,
+								   sk);
+			if (!err) {
+				list_add_tail(&umem->list, &po->umem_list);
+				ret = 0;
+				goto exit;
+			}
+		}
+
+unmap:
+		dma_unmap_sg(dev->dev.parent, umem->sglist,
+			     umem->nmap, umem->direction);
+		for (i = 0; i < umem->nmap; i++)
+			put_page(sg_page(&umem->sglist[i]));
+
+		vfree(umem);
+exit:
+		up_write(&current->mm->mmap_sem);
+
+		return ret;
+	}
+	case PACKET_DMA_MEM_REGION_RELEASE:
+	{
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+
+		down_write(&current->mm->mmap_sem);
+		ret = umem_release(dev, po);
+		up_write(&current->mm->mmap_sem);
+
+		return ret;
+	}
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3523,6 +3781,129 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	case PACKET_QDISC_BYPASS:
 		val = packet_use_direct_xmit(po);
 		break;
+	case PACKET_RXTX_QPAIRS_SPLIT:
+	{
+		struct net_device *dev;
+		struct tpacket_dev_qpairs_info qpairs_info;
+		int err;
+
+		if (len != sizeof(qpairs_info))
+			return -EINVAL;
+		if (copy_from_user(&qpairs_info, optval, sizeof(qpairs_info)))
+			return -EFAULT;
+
+		/* This call only work after a successful queue pairs split-off
+		 * operation via setsockopt()
+		 */
+		if (!po->tp_owns_queue_pairs)
+			return -EINVAL;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+		if (!dev->netdev_ops->ndo_split_queue_pairs)
+			return -EOPNOTSUPP;
+
+		err =  dev->netdev_ops->ndo_get_split_queue_pairs(dev,
+					&qpairs_info.tp_qpairs_start_from,
+					&qpairs_info.tp_qpairs_num, sk);
+
+		lv = sizeof(qpairs_info);
+		data = &qpairs_info;
+		break;
+	}
+	case PACKET_DEV_QPAIR_MAP_REGION_INFO:
+	{
+		struct tpacket_dev_qpair_map_region_info info;
+		const struct net_device_ops *ops;
+		struct net_device *dev;
+		int err;
+
+		if (len != sizeof(info))
+			return -EINVAL;
+		if (copy_from_user(&info, optval, sizeof(info)))
+			return -EFAULT;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+
+		ops = dev->netdev_ops;
+		if (!ops->ndo_get_device_qpair_map_region_info)
+			return -EOPNOTSUPP;
+
+		err = ops->ndo_get_device_qpair_map_region_info(dev, &info);
+		if (err)
+			return err;
+
+		lv = sizeof(struct tpacket_dev_qpair_map_region_info);
+		data = &info;
+		break;
+	}
+	case PACKET_DEV_DESC_INFO:
+	{
+		struct net_device *dev;
+		struct tpacket_dev_info info;
+		int err;
+
+		if (len != sizeof(info))
+			return -EINVAL;
+		if (copy_from_user(&info, optval, sizeof(info)))
+			return -EFAULT;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+		if (!dev->netdev_ops->ndo_get_device_desc_info)
+			return -EOPNOTSUPP;
+
+		err =  dev->netdev_ops->ndo_get_device_desc_info(dev, &info);
+		if (err)
+			return err;
+
+		lv = sizeof(struct tpacket_dev_info);
+		data = &info;
+		break;
+	}
+	case PACKET_DMA_MEM_REGION_MAP:
+	{
+		struct tpacket_dma_mem_region info;
+		struct net_device *dev;
+		int err;
+
+		if (len != sizeof(info))
+				return -EINVAL;
+		if (copy_from_user(&info, optval, sizeof(info)))
+				return -EFAULT;
+
+		/* This call only work after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+
+		if (!dev->netdev_ops->ndo_get_dma_region_info)
+			return -EOPNOTSUPP;
+
+		err =  dev->netdev_ops->ndo_get_dma_region_info(dev, &info, sk);
+		if (err)
+			return err;
+
+		lv = sizeof(struct tpacket_dma_mem_region);
+		data = &info;
+		break;
+	}
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3536,7 +3917,6 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
-
 static int packet_notifier(struct notifier_block *this,
 			   unsigned long msg, void *ptr)
 {
@@ -3920,6 +4300,8 @@ static int packet_mmap(struct file *file, struct socket *sock,
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned long size, expected_size;
 	struct packet_ring_buffer *rb;
+	const struct net_device_ops *ops;
+	struct net_device *dev;
 	unsigned long start;
 	int err = -EINVAL;
 	int i;
@@ -3927,8 +4309,20 @@ static int packet_mmap(struct file *file, struct socket *sock,
 	if (vma->vm_pgoff)
 		return -EINVAL;
 
+	dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+	if (!dev)
+		return -EINVAL;
+
 	mutex_lock(&po->pg_vec_lock);
 
+	if (po->tp_owns_queue_pairs) {
+		ops = dev->netdev_ops;
+		err = ops->ndo_direct_qpair_page_map(vma, dev);
+		if (err)
+			goto out;
+		goto done;
+	}
+
 	expected_size = 0;
 	for (rb = &po->rx_ring; rb <= &po->tx_ring; rb++) {
 		if (rb->pg_vec) {
@@ -3966,6 +4360,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
 		}
 	}
 
+done:
 	atomic_inc(&po->mapped);
 	vma->vm_ops = &packet_mmap_ops;
 	err = 0;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index cdddf6a..55d2fce 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -90,6 +90,14 @@ struct packet_fanout {
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
+struct packet_umem_region {
+	struct list_head	list;
+	int			nents;
+	int			nmap;
+	int			direction;
+	struct scatterlist	sglist[0];
+};
+
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
@@ -97,6 +105,7 @@ struct packet_sock {
 	union  tpacket_stats_u	stats;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
+	struct list_head        umem_list;
 	int			copy_thresh;
 	spinlock_t		bind_lock;
 	struct mutex		pg_vec_lock;
@@ -113,6 +122,7 @@ struct packet_sock {
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
 	unsigned int		tp_tx_has_off:1;
+	unsigned int		tp_owns_queue_pairs:1;
 	unsigned int		tp_tstamp;
 	struct net_device __rcu	*cached_dev;
 	int			(*xmit)(struct sk_buff *skb);
