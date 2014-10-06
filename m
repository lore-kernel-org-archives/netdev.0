From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Sun, 05 Oct 2014 17:06:31 -0700
Message-ID: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com
To: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:49816 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbaJFAG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 20:06:59 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo20so3195576obc.31
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 17:06:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a net_device ops to split off a set of driver queues
from the driver and map the queues into user space via mmap. This
allows the queues to be directly manipulated from user space. For
raw packet interface this removes any overhead from the kernel network
stack.

Typically in an af_packet interface a packet_type handler is
registered and used to filter traffic to the socket and do other
things such as fan out traffic to multiple sockets. In this case the
networking stack is being bypassed so this code is not run. So the
hardware must push the correct traffic to the queues obtained from
the ndo callback ndo_split_queue_pairs().

Fortunately there is already a flow classification interface which
is part of the ethtool command set, ETHTOOL_SRXCLSRLINS. It is
currently supported by multiple drivers including sfc, mlx4, niu,
ixgbe, and i40e. Supporting some way to steer traffic to a queue
is the _only_ hardware requirement to support the interface, plus
the driver needs to implement the correct ndo ops. A follow on
patch adds support for ixgbe but we expect at least the subset of
drivers implementing ETHTOOL_SRXCLSRLINS to be implemented later.

The interface is driven over an af_packet socket which we believe
is the most natural interface to use. Because it is already used
for raw packet interfaces which is what we are providing here.
 The high level flow for this interface looks like:

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
information from the socket option PACKET_DEV_DESC_INFO which
should provide enough details to extrapulate the descriptor formats.
Although this adds some complexity to user space it removes the
requirement to copy descriptor fields around.

The formats are usually provided by the device vendor documentation
If folks want I can provide a follow up patch to provide the formats
in a .h file in ./include/uapi/linux/ for ease of use. I have access
to formats for ixgbe and mlx drivers other driver owners would need to
provide their formats.

We tested this interface using traffic generators and doing basic
L2 forwarding tests on ixgbe devices. Our tests use a set of patches
to DPDK to enable an interface using this socket interfaace. With
this interface we can xmit/receive @ line rate from a test user space
application on a single core.

Additionally we have a set of DPDK patches to enable DPDK with this
interface. DPDK can be downloaded @ dpdk.org although as I hope is
clear from above DPDK is just our paticular test environment we
expect other libraries could be built on this interface.

Signed-off-by: Danny Zhou <danny.zhou@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h      |   63 ++++++++++++++
 include/uapi/linux/if_packet.h |   42 +++++++++
 net/packet/af_packet.c         |  181 ++++++++++++++++++++++++++++++++++++++++
 net/packet/internal.h          |    1 
 4 files changed, 287 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9f5d293..dae96dc2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -51,6 +51,8 @@
 #include <linux/neighbour.h>
 #include <uapi/linux/netdevice.h>
 
+#include <linux/if_packet.h>
+
 struct netpoll_info;
 struct device;
 struct phy_device;
@@ -997,6 +999,47 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ *
+ * int (*ndo_split_queue_pairs) (struct net_device *dev,
+ *				 unsigned int qpairs_start_from,
+ *				 unsigned int qpairs_num,
+ *				 struct sock *sk)
+ *	Called to request a set of queues from the driver to be
+ *	handed to the callee for management. After this returns the
+ *	driver will not use the queues. The call should return zero
+ *	on success otherwise an appropriate error code can be used.
+ *	If qpairs_start_from is less than zero driver can start at
+ *	any available slot.
+ *
+ * int (*ndo_get_queue_pairs)(struct net_device *dev,
+ *			      unsigned int *qpairs_start_from,
+ *			      unsigned int *qpairs_num,
+ *			      struct sock *sk);
+ *	Called to get the queues assigned by the driver to this sock
+ *	when ndo_split_queue_pairs does not specify a start_from and
+ *	qpairs_num field. Returns zero on success.
+ *
+ * int (*ndo_return_queue_pairs) (struct net_device *dev,
+ *				  struct sock *sk)
+ *	Called to return a set of queues identified by sock to
+ *	the driver. The socket must have previously requested
+ *	the queues via ndo_split_queue_pairs for this action to
+ *	be performed.
+ *
+ * int (*ndo_get_device_qpair_map_region_info) (struct net_device *dev,
+ *				struct tpacket_dev_qpair_map_region_info *info)
+ *	Called to return mapping of queue memory region
+ *
+ * int (*ndo_get_device_desc_info) (struct net_device *dev,
+ *				    struct tpacket_dev_info *dev_info)
+ *	Called to get device specific information. This should
+ *	uniquely identify the hardware so that descriptor formats
+ *	can be learned by the stack/user space.
+ *
+ * int (*ndo_direct_qpair_page_map) (struct vm_area_struct *vma,
+ *				     struct net_device *dev)
+ *	Called to map queue pair range from split_queue_pairs into
+ *	mmap region.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1146,6 +1189,26 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+	int			(*ndo_split_queue_pairs)(struct net_device *dev,
+					 unsigned int qpairs_start_from,
+					 unsigned int qpairs_num,
+					 struct sock *sk);
+	int			(*ndo_get_queue_pairs)(struct net_device *dev,
+					 unsigned int *qpairs_start_from,
+					 unsigned int *qpairs_num,
+					 struct sock *sk);
+	int			(*ndo_return_queue_pairs)(
+					 struct net_device *dev,
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
 };
 
 /**
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index da2d668..fa94b65 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -54,6 +54,10 @@ struct sockaddr_ll {
 #define PACKET_FANOUT			18
 #define PACKET_TX_HAS_OFF		19
 #define PACKET_QDISC_BYPASS		20
+#define PACKET_RXTX_QPAIRS_SPLIT	21
+#define PACKET_RXTX_QPAIRS_RETURN	22
+#define PACKET_DEV_QPAIR_MAP_REGION_INFO	23
+#define PACKET_DEV_DESC_INFO		24
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
@@ -64,6 +68,44 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
+#define MAX_MAP_MEMORY_REGIONS		64
+
+struct tpacket_dev_qpair_map_region_info {
+	unsigned int tp_dev_bar_sz;		/* size of BAR */
+	unsigned int tp_dev_sysm_sz;		/* size of systerm memory */
+	/* number of contiguous memory on BAR mapping to user space */
+	unsigned int tp_num_map_regions;
+	/* number of contiguous memory on system mapping to user apce */
+	unsigned int tp_num_sysm_map_regions;
+	struct map_page_region {
+		unsigned page_offset;		/* offset to start of region */
+		unsigned page_sz;		/* size of page */
+		unsigned page_cnt;		/* number of pages */
+	} regions[MAX_MAP_MEMORY_REGIONS];
+};
+
+#define PACKET_QPAIRS_START_ANY		-1
+
+struct tpacket_dev_qpairs_info {
+	unsigned int tp_qpairs_start_from;	/* qpairs index to start from */
+	unsigned int tp_qpairs_num;		/* number of qpairs */
+};
+
+struct tpacket_dev_info {
+	__u16		tp_device_id;
+	__u16		tp_vendor_id;
+	__u16		tp_subsystem_device_id;
+	__u16		tp_subsystem_vendor_id;
+	__u32		tp_numa_node;
+	__u32		tp_revision_id;
+	__u32		tp_num_total_qpairs;
+	__u32		tp_num_inuse_qpairs;
+	unsigned int	tp_rxdesc_size;	/* rx desc size in bytes */
+	__u16		tp_rxdesc_ver;
+	unsigned int	tp_txdesc_size;	/* tx desc size in bytes */
+	__u16		tp_txdesc_ver;
+};
+
 struct tpacket_stats {
 	unsigned int	tp_packets;
 	unsigned int	tp_drops;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 87d20f4..19b43ee 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2611,6 +2611,14 @@ static int packet_release(struct socket *sock)
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
 	preempt_enable();
 
+	if (po->tp_owns_queue_pairs) {
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (dev)
+			dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
+	}
+
 	spin_lock(&po->bind_lock);
 	unregister_prot_hook(sk, false);
 	packet_cached_dev_reset(po);
@@ -3403,6 +3411,70 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
 		return 0;
 	}
+
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
+		err =  ops->ndo_split_queue_pairs(dev,
+						  qpairs.tp_qpairs_start_from,
+						  qpairs.tp_qpairs_num, sk);
+		if (!err)
+			po->tp_owns_queue_pairs = true;
+
+		return err;
+	}
+
+	case PACKET_RXTX_QPAIRS_RETURN:
+	{
+		struct tpacket_dev_qpairs_info qpairs_info;
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
+
+		err =  dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
+		if (!err)
+			po->tp_owns_queue_pairs = false;
+
+		return err;
+	}
+
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3498,6 +3570,99 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
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
+		/* This call only works after a successful queue pairs split-off
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
+		err = dev->netdev_ops->ndo_get_queue_pairs(dev,
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
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3904,6 +4069,21 @@ static int packet_mmap(struct file *file, struct socket *sock,
 
 	mutex_lock(&po->pg_vec_lock);
 
+	if (po->tp_owns_queue_pairs) {
+		const struct net_device_ops *ops;
+		struct net_device *dev;
+
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+
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
@@ -3941,6 +4121,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
 		}
 	}
 
+done:
 	atomic_inc(&po->mapped);
 	vma->vm_ops = &packet_mmap_ops;
 	err = 0;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index cdddf6a..55cadbc 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -113,6 +113,7 @@ struct packet_sock {
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
 	unsigned int		tp_tx_has_off:1;
+	unsigned int		tp_owns_queue_pairs:1;
 	unsigned int		tp_tstamp;
 	struct net_device __rcu	*cached_dev;
 	int			(*xmit)(struct sk_buff *skb);
