From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 1/2] af_packet: direct dma for packet ineterface
Date: Fri, 27 Jan 2017 13:33:44 -0800
Message-ID: <20170127213344.14162.59976.stgit@john-Precision-Tower-5810>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35548 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdA0VeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:34:23 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so19271431pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:34:06 -0800 (PST)
In-Reply-To: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ndo ops for upper layer objects to request direct DMA from
the network interface into memory "slots". The slots must be DMA'able
memory given by a page/offset/size vector in a packet_ring_buffer
structure.

The PF_PACKET socket interface can use these ndo_ops to do zerocopy
RX from the network device into memory mapped userspace memory. For
this to work drivers encode the correct descriptor blocks and headers
so that existing PF_PACKET applications work without any modification.
This only supports the V2 header formats for now. And works by mapping
a ring of the network device to these slots. Originally I used V2
header formats but this does complicate the driver a bit.

V3 header formats added bulk polling via socket calls and timers
used in the polling interface to return every n milliseconds. Currently,
I don't see any way to support this in hardware because we can't
know if the hardware is in the middle of a DMA operation or not
on a slot. So when a timer fires I don't know how to advance the
descriptor ring leaving empty descriptors similar to how the software
ring works. The easiest (best?) route is to simply not support this.

It might be worth creating a new v4 header that is simple for drivers
to support direct DMA ops with. I can imagine using the xdp_buff
structure as a header for example. Thoughts?

The ndo operations and new socket option PACKET_RX_DIRECT work by
giving a queue_index to run the direct dma operations over. Once
setsockopt returns successfully the indicated queue is mapped
directly to the requesting application and can not be used for
other purposes. Also any kernel layers such as tc will be bypassed
and need to be implemented in the hardware via some other mechanism
such as tc offload or other offload interfaces.

Users steer traffic to the selected queue using flow director,
tc offload infrastructure or via macvlan offload.

The new socket option added to PF_PACKET is called PACKET_RX_DIRECT.
It takes a single unsigned int value specifying the queue index,

     setsockopt(sock, SOL_PACKET, PACKET_RX_DIRECT,
		&queue_index, sizeof(queue_index));

Implementing busy_poll support will allow userspace to kick the
drivers receive routine if needed. This work is TBD.

To test this I hacked a hardcoded test into  the tool psock_tpacket
in the selftests kernel directory here:

     ./tools/testing/selftests/net/psock_tpacket.c

Running this tool opens a socket and listens for packets over
the PACKET_RX_DIRECT enabled socket. Obviously it needs to be
reworked to enable all the older tests and not hardcode my
interface before it actually gets released.

In general this is a rough patch to explore the interface and
put something concrete up for debate. The patch does not handle
all the error cases correctly and needs to be cleaned up.

Known Limitations (TBD):

     (1) Users are required to match the number of rx ring
         slots with ethtool to the number requested by the
         setsockopt PF_PACKET layout. In the future we could
         possibly do this automatically.

     (2) Users need to configure Flow director or setup_tc
         to steer traffic to the correct queues. I don't believe
         this needs to be changed it seems to be a good mechanism
         for driving directed dma.

     (3) Not supporting timestamps or priv space yet, pushing
	 a v4 packet header would resolve this nicely.

     (5) Only RX supported so far. TX already supports direct DMA
         interface but uses skbs which is really not needed. In
         the TX_RING case we can optimize this path as well.

To support TX case we can do a similar "slots" mechanism and
kick operation. The kick could be a busy_poll like operation
but on the TX side. The flow would be user space loads up
n number of slots with packets, kicks tx busy poll bit, the
driver sends packets, and finally when xmit is complete
clears header bits to give slots back. When we have qdisc
bypass set today we already bypass the entire stack so no
paticular reason to use skb's in this case. Using xdp_buff
as a v4 packet header would also allow us to consolidate
driver code.

To be done:

     (1) More testing and performance analysis
     (2) Busy polling sockets
     (3) Implement v4 xdp_buff headers for analysis
     (4) performance testing :/ hopefully it looks good.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h                   |    8 +++
 include/net/af_packet.h                     |   64 +++++++++++++++++++++++++++
 include/uapi/linux/if_packet.h              |    1 
 net/packet/af_packet.c                      |   37 ++++++++++++++++
 net/packet/internal.h                       |   60 -------------------------
 tools/testing/selftests/net/psock_tpacket.c |   51 +++++++++++++++++++---
 6 files changed, 154 insertions(+), 67 deletions(-)
 create mode 100644 include/net/af_packet.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9bde955..a64a333 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -54,6 +54,8 @@
 #include <uapi/linux/pkt_cls.h>
 #include <linux/hashtable.h>
 
+#include <net/af_packet.h>
+
 struct netpoll_info;
 struct device;
 struct phy_device;
@@ -1324,6 +1326,12 @@ struct net_device_ops {
 						       int needed_headroom);
 	int			(*ndo_xdp)(struct net_device *dev,
 					   struct netdev_xdp *xdp);
+	int			(*ndo_ddma_map)(struct net_device *dev,
+					unsigned int rindex,
+					struct sock *sk,
+					struct packet_ring_buffer *rb);
+	void			(*ndo_ddma_unmap)(struct net_device *dev,
+						  unsigned int rindex);
 };
 
 /**
diff --git a/include/net/af_packet.h b/include/net/af_packet.h
new file mode 100644
index 0000000..9e82ba1
--- /dev/null
+++ b/include/net/af_packet.h
@@ -0,0 +1,64 @@
+#include <linux/timer.h>
+
+struct pgv {
+	char *buffer;
+};
+
+/* kbdq - kernel block descriptor queue */
+struct tpacket_kbdq_core {
+	struct pgv	*pkbdq;
+	unsigned int	feature_req_word;
+	unsigned int	hdrlen;
+	unsigned char	reset_pending_on_curr_blk;
+	unsigned char   delete_blk_timer;
+	unsigned short	kactive_blk_num;
+	unsigned short	blk_sizeof_priv;
+
+
+	/* last_kactive_blk_num:
+	 * trick to see if user-space has caught up
+	 * in order to avoid refreshing timer when every single pkt arrives.
+	 */
+	unsigned short	last_kactive_blk_num;
+
+	char		*pkblk_start;
+	char		*pkblk_end;
+	int		kblk_size;
+	unsigned int	max_frame_len;
+	unsigned int	knum_blocks;
+	uint64_t	knxt_seq_num;
+	char		*prev;
+	char		*nxt_offset;
+	struct sk_buff	*skb;
+
+	atomic_t	blk_fill_in_prog;
+
+	/* Default is set to 8ms */
+#define DEFAULT_PRB_RETIRE_TOV	(8)
+
+	unsigned short  retire_blk_tov;
+	unsigned short  version;
+	unsigned long	tov_in_jiffies;
+
+	/* timer to retire an outstanding block */
+	struct timer_list retire_blk_timer;
+};
+
+struct packet_ring_buffer {
+	struct pgv		*pg_vec;
+
+	unsigned int		head;
+	unsigned int		frames_per_block;
+	unsigned int		frame_size;
+	unsigned int		frame_max;
+
+	unsigned int		pg_vec_order;
+	unsigned int		pg_vec_pages;
+	unsigned int		pg_vec_len;
+
+	unsigned int __percpu	*pending_refcnt;
+
+	bool			ddma;
+
+	struct tpacket_kbdq_core prb_bdqc;
+};
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index 9e7edfd..04b069a 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -56,6 +56,7 @@ struct sockaddr_ll {
 #define PACKET_QDISC_BYPASS		20
 #define PACKET_ROLLOVER_STATS		21
 #define PACKET_FANOUT_DATA		22
+#define PACKET_RX_DIRECT		23
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3d555c7..180666f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3731,6 +3731,34 @@ static void packet_flush_mclist(struct sock *sk)
 		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
 		return 0;
 	}
+	case PACKET_RX_DIRECT:
+	{
+		struct packet_ring_buffer *rb = &po->rx_ring;
+		struct net_device *dev;
+		unsigned int index;
+		int err;
+
+		if (optlen != sizeof(index))
+			return -EINVAL;
+		if (copy_from_user(&index, optval, sizeof(index)))
+			return -EFAULT;
+
+		/* This call only works after a bind call which calls a dev_hold
+		 * operation so we do not need to increment dev ref counter
+		 */
+		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
+		if (!dev)
+			return -EINVAL;
+		if (!dev->netdev_ops->ndo_ddma_map)
+			return -EOPNOTSUPP;
+		if (!atomic_read(&po->mapped))
+			return -EINVAL;
+
+		err =  dev->netdev_ops->ndo_ddma_map(dev, index, sk, rb);
+		if (!err)
+			rb->ddma = true;
+		return err;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -4228,6 +4256,15 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		if (atomic_read(&po->mapped))
 			pr_err("packet_mmap: vma is busy: %d\n",
 			       atomic_read(&po->mapped));
+
+		if (rb->ddma) {
+			struct net_device *dev =
+				__dev_get_by_index(sock_net(sk), po->ifindex);
+
+			if (dev && dev->netdev_ops->ndo_ddma_map)
+				dev->netdev_ops->ndo_ddma_unmap(dev, 0);
+			rb->ddma = false;
+		}
 	}
 	mutex_unlock(&po->pg_vec_lock);
 
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 9ee4631..4eec79e 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -10,66 +10,6 @@ struct packet_mclist {
 	unsigned char		addr[MAX_ADDR_LEN];
 };
 
-/* kbdq - kernel block descriptor queue */
-struct tpacket_kbdq_core {
-	struct pgv	*pkbdq;
-	unsigned int	feature_req_word;
-	unsigned int	hdrlen;
-	unsigned char	reset_pending_on_curr_blk;
-	unsigned char   delete_blk_timer;
-	unsigned short	kactive_blk_num;
-	unsigned short	blk_sizeof_priv;
-
-	/* last_kactive_blk_num:
-	 * trick to see if user-space has caught up
-	 * in order to avoid refreshing timer when every single pkt arrives.
-	 */
-	unsigned short	last_kactive_blk_num;
-
-	char		*pkblk_start;
-	char		*pkblk_end;
-	int		kblk_size;
-	unsigned int	max_frame_len;
-	unsigned int	knum_blocks;
-	uint64_t	knxt_seq_num;
-	char		*prev;
-	char		*nxt_offset;
-	struct sk_buff	*skb;
-
-	atomic_t	blk_fill_in_prog;
-
-	/* Default is set to 8ms */
-#define DEFAULT_PRB_RETIRE_TOV	(8)
-
-	unsigned short  retire_blk_tov;
-	unsigned short  version;
-	unsigned long	tov_in_jiffies;
-
-	/* timer to retire an outstanding block */
-	struct timer_list retire_blk_timer;
-};
-
-struct pgv {
-	char *buffer;
-};
-
-struct packet_ring_buffer {
-	struct pgv		*pg_vec;
-
-	unsigned int		head;
-	unsigned int		frames_per_block;
-	unsigned int		frame_size;
-	unsigned int		frame_max;
-
-	unsigned int		pg_vec_order;
-	unsigned int		pg_vec_pages;
-	unsigned int		pg_vec_len;
-
-	unsigned int __percpu	*pending_refcnt;
-
-	struct tpacket_kbdq_core	prb_bdqc;
-};
-
 extern struct mutex fanout_mutex;
 #define PACKET_FANOUT_MAX	256
 
diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 24adf70..32514f3 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -133,6 +133,20 @@ static void status_bar_update(void)
 	}
 }
 
+static void print_payload(void *pay, size_t len)
+{
+	unsigned char *payload = pay;
+	int i;
+
+	printf("payload (bytes %lu): ", len);
+	for (i = 0; i < len; i++) {
+		if ((i % 32) == 0)
+			printf("\n");
+		printf("0x%02x ", payload[i]);
+	}
+	printf("\n");
+}
+
 static void test_payload(void *pay, size_t len)
 {
 	struct ethhdr *eth = pay;
@@ -148,6 +162,7 @@ static void test_payload(void *pay, size_t len)
 			"type: 0x%x!\n", ntohs(eth->h_proto));
 		exit(1);
 	}
+	print_payload(pay, len);
 }
 
 static void create_payload(void *pay, size_t *len)
@@ -232,21 +247,21 @@ static inline void __v1_v2_rx_user_ready(void *base, int version)
 static void walk_v1_v2_rx(int sock, struct ring *ring)
 {
 	struct pollfd pfd;
-	int udp_sock[2];
+	//int udp_sock[2];
 	union frame_map ppd;
 	unsigned int frame_num = 0;
 
 	bug_on(ring->type != PACKET_RX_RING);
 
-	pair_udp_open(udp_sock, PORT_BASE);
-	pair_udp_setfilter(sock);
+	//pair_udp_open(udp_sock, PORT_BASE);
+	//pair_udp_setfilter(sock);
 
 	memset(&pfd, 0, sizeof(pfd));
 	pfd.fd = sock;
 	pfd.events = POLLIN | POLLERR;
 	pfd.revents = 0;
 
-	pair_udp_send(udp_sock, NUM_PACKETS);
+	//pair_udp_send(udp_sock, NUM_PACKETS);
 
 	while (total_packets < NUM_PACKETS * 2) {
 		while (__v1_v2_rx_kernel_ready(ring->rd[frame_num].iov_base,
@@ -257,6 +272,9 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 			case TPACKET_V1:
 				test_payload((uint8_t *) ppd.raw + ppd.v1->tp_h.tp_mac,
 					     ppd.v1->tp_h.tp_snaplen);
+				print_payload((uint8_t *) ppd.raw +
+						ppd.v2->tp_h.tp_mac,
+					      ppd.v2->tp_h.tp_snaplen);
 				total_bytes += ppd.v1->tp_h.tp_snaplen;
 				break;
 
@@ -278,7 +296,7 @@ static void walk_v1_v2_rx(int sock, struct ring *ring)
 		poll(&pfd, 1, 1);
 	}
 
-	pair_udp_close(udp_sock);
+	//pair_udp_close(udp_sock);
 
 	if (total_packets != 2 * NUM_PACKETS) {
 		fprintf(stderr, "walk_v%d_rx: received %u out of %u pkts\n",
@@ -372,7 +390,8 @@ static void walk_v1_v2_tx(int sock, struct ring *ring)
 
 	pair_udp_setfilter(rcv_sock);
 
-	ll.sll_ifindex = if_nametoindex("lo");
+	/* hacking my test up */
+	ll.sll_ifindex = if_nametoindex("eth3");
 	ret = bind(rcv_sock, (struct sockaddr *) &ll, sizeof(ll));
 	if (ret == -1) {
 		perror("bind");
@@ -687,7 +706,7 @@ static void bind_ring(int sock, struct ring *ring)
 
 	ring->ll.sll_family = PF_PACKET;
 	ring->ll.sll_protocol = htons(ETH_P_ALL);
-	ring->ll.sll_ifindex = if_nametoindex("lo");
+	ring->ll.sll_ifindex = if_nametoindex("eth3");
 	ring->ll.sll_hatype = 0;
 	ring->ll.sll_pkttype = 0;
 	ring->ll.sll_halen = 0;
@@ -755,6 +774,19 @@ static int test_user_bit_width(void)
 	[PACKET_TX_RING] = "PACKET_TX_RING",
 };
 
+void direct_dma_ring(int sock)
+{
+	int ret;
+	int index = 1;
+
+	ret = setsockopt(sock, SOL_PACKET, PACKET_RX_DIRECT,
+			 &index, sizeof(index));
+	if (ret == -10)
+		printf("Failed direct dma socket with %i\n", ret);
+	else
+		printf("Configured a direct dma socket!\n");
+}
+
 static int test_tpacket(int version, int type)
 {
 	int sock;
@@ -777,6 +809,7 @@ static int test_tpacket(int version, int type)
 	setup_ring(sock, &ring, version, type);
 	mmap_ring(sock, &ring);
 	bind_ring(sock, &ring);
+	direct_dma_ring(sock);
 	walk_ring(sock, &ring);
 	unmap_ring(sock, &ring);
 	close(sock);
@@ -789,13 +822,17 @@ int main(void)
 {
 	int ret = 0;
 
+#if 0
 	ret |= test_tpacket(TPACKET_V1, PACKET_RX_RING);
 	ret |= test_tpacket(TPACKET_V1, PACKET_TX_RING);
+#endif
 
 	ret |= test_tpacket(TPACKET_V2, PACKET_RX_RING);
+#if 0
 	ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
 
 	ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
+#endif
 
 	if (ret)
 		return 1;
