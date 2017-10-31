From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 03/14] packet: enable AF_PACKET V4 rings
Date: Tue, 31 Oct 2017 13:41:34 +0100
Message-ID: <20171031124145.9667-4-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:34046 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751807AbdJaMw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:52:26 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

Allow creation of AF_PACKET V4 rings. Tx and Rx are still disabled.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 include/linux/tpacket4.h | 391 +++++++++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c   | 262 +++++++++++++++++++++++++++++--
 net/packet/internal.h    |   4 +
 3 files changed, 641 insertions(+), 16 deletions(-)

diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index fcf4c333c78d..44ba38034133 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -18,6 +18,12 @@
 #define TP4_UMEM_MIN_FRAME_SIZE 2048
 #define TP4_KERNEL_HEADROOM 256 /* Headrom for XDP */
 
+enum tp4_validation {
+	TP4_VALIDATION_NONE,	/* No validation is performed */
+	TP4_VALIDATION_IDX,	/* Only address to packet buffer is validated */
+	TP4_VALIDATION_DESC	/* Full descriptor is validated */
+};
+
 struct tp4_umem {
 	struct pid *pid;
 	struct page **pgs;
@@ -31,9 +37,95 @@ struct tp4_umem {
 	unsigned int data_headroom;
 };
 
+struct tp4_dma_info {
+	dma_addr_t dma;
+	struct page *page;
+};
+
+struct tp4_queue {
+	struct tpacket4_desc *ring;
+
+	unsigned int used_idx;
+	unsigned int last_avail_idx;
+	unsigned int ring_mask;
+	unsigned int num_free;
+
+	struct tp4_umem *umem;
+	struct tp4_dma_info *dma_info;
+	enum dma_data_direction direction;
+};
+
+/**
+ * struct tp4_packet_array - An array of packets/frames
+ *
+ * @tp4q: the tp4q associated with this packet array. Flushes and
+ *	  populates will operate on this.
+ * @dev: pointer to the netdevice the queue should be associated with
+ * @direction: the direction of the DMA channel that is set up.
+ * @validation: type of validation performed on populate
+ * @start: the first packet that has not been processed
+ * @curr: the packet that is currently being processed
+ * @end: the last packet in the array
+ * @mask: convenience variable for internal operations on the array
+ * @items: the actual descriptors to frames/packets that are in the array
+ **/
+struct tp4_packet_array {
+	struct tp4_queue *tp4q;
+	struct device *dev;
+	enum dma_data_direction direction;
+	enum tp4_validation validation;
+	u32 start;
+	u32 curr;
+	u32 end;
+	u32 mask;
+	struct tpacket4_desc items[0];
+};
+
+/**
+ * struct tp4_frame_set - A view of a packet array consisting of
+ *                        one or more frames
+ *
+ * @pkt_arr: the packet array this frame set is located in
+ * @start: the first frame that has not been processed
+ * @curr: the frame that is currently being processed
+ * @end: the last frame in the frame set
+ *
+ * This frame set can either be one or more frames or a single packet
+ * consisting of one or more frames. tp4f_ functions with packet in the
+ * name return a frame set representing a packet, while the other
+ * tp4f_ functions return one or more frames not taking into account if
+ * they consitute a packet or not.
+ **/
+struct tp4_frame_set {
+	struct tp4_packet_array *pkt_arr;
+	u32 start;
+	u32 curr;
+	u32 end;
+};
+
 /*************** V4 QUEUE OPERATIONS *******************************/
 
 /**
+ * tp4q_init - Initializas a tp4 queue
+ *
+ * @q: Pointer to the tp4 queue structure to be initialized
+ * @nentries: Number of descriptor entries in the queue
+ * @umem: Pointer to the umem / packet buffer associated with this queue
+ * @buffer: Pointer to the memory region where the descriptors will reside
+ **/
+static inline void tp4q_init(struct tp4_queue *q, unsigned int nentries,
+			     struct tp4_umem *umem,
+			     struct tpacket4_desc *buffer)
+{
+	q->ring = buffer;
+	q->used_idx = 0;
+	q->last_avail_idx = 0;
+	q->ring_mask = nentries - 1;
+	q->num_free = 0;
+	q->umem = umem;
+}
+
+/**
  * tp4q_umem_new - Creates a new umem (packet buffer)
  *
  * @addr: The address to the umem
@@ -98,4 +190,303 @@ static inline struct tp4_umem *tp4q_umem_new(unsigned long addr, size_t size,
 	return umem;
 }
 
+/**
+ * tp4q_enqueue_from_array - Enqueue entries from packet array to tp4 queue
+ *
+ * @a: Pointer to the packet array to enqueue from
+ * @dcnt: Max number of entries to enqueue
+ *
+ * Returns 0 for success or an errno at failure
+ **/
+static inline int tp4q_enqueue_from_array(struct tp4_packet_array *a,
+					  u32 dcnt)
+{
+	struct tp4_queue *q = a->tp4q;
+	unsigned int used_idx = q->used_idx;
+	struct tpacket4_desc *d = a->items;
+	int i;
+
+	if (q->num_free < dcnt)
+		return -ENOSPC;
+
+	q->num_free -= dcnt;
+
+	for (i = 0; i < dcnt; i++) {
+		unsigned int idx = (used_idx++) & q->ring_mask;
+		unsigned int didx = (a->start + i) & a->mask;
+
+		q->ring[idx].idx = d[didx].idx;
+		q->ring[idx].len = d[didx].len;
+		q->ring[idx].offset = d[didx].offset;
+		q->ring[idx].error = d[didx].error;
+	}
+
+	/* Order flags and data */
+	smp_wmb();
+
+	for (i = dcnt - 1; i >= 0; i--) {
+		unsigned int idx = (q->used_idx + i) & q->ring_mask;
+		unsigned int didx = (a->start + i) & a->mask;
+
+		q->ring[idx].flags = d[didx].flags & ~TP4_DESC_KERNEL;
+	}
+	q->used_idx += dcnt;
+
+	return 0;
+}
+
+/**
+ * tp4q_disable - Disable a tp4 queue
+ *
+ * @dev: Pointer to the netdevice the queue is connected to
+ * @q: Pointer to the tp4 queue to disable
+ **/
+static inline void tp4q_disable(struct device *dev,
+				struct tp4_queue *q)
+{
+	int i;
+
+	if (q->dma_info) {
+		/* Unmap DMA */
+		for (i = 0; i < q->umem->npgs; i++)
+			dma_unmap_page(dev, q->dma_info[i].dma, PAGE_SIZE,
+				       q->direction);
+
+		kfree(q->dma_info);
+		q->dma_info = NULL;
+	}
+}
+
+/**
+ * tp4q_enable - Enable a tp4 queue
+ *
+ * @dev: Pointer to the netdevice the queue should be associated with
+ * @q: Pointer to the tp4 queue to enable
+ * @direction: The direction of the DMA channel that is set up.
+ *
+ * Returns 0 for success or a negative errno for failure
+ **/
+static inline int tp4q_enable(struct device *dev,
+			      struct tp4_queue *q,
+			      enum dma_data_direction direction)
+{
+	int i, j;
+
+	/* DMA map all the buffers in bufs up front, and sync prior
+	 * kicking userspace. Is this sane? Strictly user land owns
+	 * the buffer until they show up on the avail queue. However,
+	 * mapping should be ok.
+	 */
+	if (direction != DMA_NONE) {
+		q->dma_info = kcalloc(q->umem->npgs, sizeof(*q->dma_info),
+				      GFP_KERNEL);
+		if (!q->dma_info)
+			return -ENOMEM;
+
+		for (i = 0; i < q->umem->npgs; i++) {
+			dma_addr_t dma;
+
+			dma = dma_map_page(dev, q->umem->pgs[i], 0,
+					   PAGE_SIZE, direction);
+			if (dma_mapping_error(dev, dma)) {
+				for (j = 0; j < i; j++)
+					dma_unmap_page(dev,
+						       q->dma_info[j].dma,
+						       PAGE_SIZE, direction);
+				kfree(q->dma_info);
+				q->dma_info = NULL;
+				return -EBUSY;
+			}
+
+			q->dma_info[i].page = q->umem->pgs[i];
+			q->dma_info[i].dma = dma;
+		}
+	} else {
+		q->dma_info = NULL;
+	}
+
+	q->direction = direction;
+	return 0;
+}
+
+/*************** FRAME OPERATIONS *******************************/
+/* A frame is always just one frame of size frame_size.
+ * A frame set is one or more frames.
+ **/
+
+/**
+ * tp4f_next_frame - Go to next frame in frame set
+ * @p: pointer to frame set
+ *
+ * Returns true if there is another frame in the frame set.
+ * Advances curr pointer.
+ **/
+static inline bool tp4f_next_frame(struct tp4_frame_set *p)
+{
+	if (p->curr + 1 == p->end)
+		return false;
+
+	p->curr++;
+	return true;
+}
+
+/**
+ * tp4f_set_frame - Sets the properties of a frame
+ * @p: pointer to frame
+ * @len: the length in bytes of the data in the frame
+ * @offset: offset to start of data in frame
+ * @is_eop: Set if this is the last frame of the packet
+ **/
+static inline void tp4f_set_frame(struct tp4_frame_set *p, u32 len, u16 offset,
+				  bool is_eop)
+{
+	struct tpacket4_desc *d =
+		&p->pkt_arr->items[p->curr & p->pkt_arr->mask];
+
+	d->len = len;
+	d->offset = offset;
+	if (!is_eop)
+		d->flags |= TP4_PKT_CONT;
+}
+
+/**************** PACKET_ARRAY FUNCTIONS ********************************/
+
+static inline struct tp4_packet_array *__tp4a_new(
+	struct tp4_queue *tp4q,
+	struct device *dev,
+	enum dma_data_direction direction,
+	enum tp4_validation validation,
+	size_t elems)
+{
+	struct tp4_packet_array *arr;
+	int err;
+
+	if (!is_power_of_2(elems))
+		return NULL;
+
+	arr = kzalloc(sizeof(*arr) + elems * sizeof(struct tpacket4_desc),
+		      GFP_KERNEL);
+	if (!arr)
+		return NULL;
+
+	err = tp4q_enable(dev, tp4q, direction);
+	if (err) {
+		kfree(arr);
+		return NULL;
+	}
+
+	arr->tp4q = tp4q;
+	arr->dev = dev;
+	arr->direction = direction;
+	arr->validation = validation;
+	arr->mask = elems - 1;
+	return arr;
+}
+
+/**
+ * tp4a_rx_new - Create new packet array for ingress
+ * @rx_opaque: opaque from tp4_netdev_params
+ * @elems: number of elements in the packet array
+ * @dev: device or NULL
+ *
+ * Returns a reference to the new packet array or NULL for failure
+ **/
+static inline struct tp4_packet_array *tp4a_rx_new(void *rx_opaque,
+						   size_t elems,
+						   struct device *dev)
+{
+	enum dma_data_direction direction = dev ? DMA_FROM_DEVICE : DMA_NONE;
+
+	return __tp4a_new(rx_opaque, dev, direction, TP4_VALIDATION_IDX,
+			  elems);
+}
+
+/**
+ * tp4a_tx_new - Create new packet array for egress
+ * @tx_opaque: opaque from tp4_netdev_params
+ * @elems: number of elements in the packet array
+ * @dev: device or NULL
+ *
+ * Returns a reference to the new packet array or NULL for failure
+ **/
+static inline struct tp4_packet_array *tp4a_tx_new(void *tx_opaque,
+						   size_t elems,
+						   struct device *dev)
+{
+	enum dma_data_direction direction = dev ? DMA_TO_DEVICE : DMA_NONE;
+
+	return __tp4a_new(tx_opaque, dev, direction, TP4_VALIDATION_DESC,
+			  elems);
+}
+
+/**
+ * tp4a_get_flushable_frame_set - Create a frame set of the flushable region
+ * @a: pointer to packet array
+ * @p: frame set
+ *
+ * Returns true for success and false for failure
+ **/
+static inline bool tp4a_get_flushable_frame_set(struct tp4_packet_array *a,
+						struct tp4_frame_set *p)
+{
+	u32 avail = a->curr - a->start;
+
+	if (avail == 0)
+		return false; /* empty */
+
+	p->pkt_arr = a;
+	p->start = a->start;
+	p->curr = a->start;
+	p->end = a->curr;
+
+	return true;
+}
+
+/**
+ * tp4a_flush - Flush processed packets to associated tp4q
+ * @a: pointer to packet array
+ *
+ * Returns 0 for success and -1 for failure
+ **/
+static inline int tp4a_flush(struct tp4_packet_array *a)
+{
+	u32 avail = a->curr - a->start;
+	int ret;
+
+	if (avail == 0)
+		return 0; /* nothing to flush */
+
+	ret = tp4q_enqueue_from_array(a, avail);
+	if (ret < 0)
+		return -1;
+
+	a->start = a->curr;
+
+	return 0;
+}
+
+/**
+ * tp4a_free - Destroy packet array
+ * @a: pointer to packet array
+ **/
+static inline void tp4a_free(struct tp4_packet_array *a)
+{
+	struct tp4_frame_set f;
+
+	if (a) {
+		/* Flush all outstanding requests. */
+		if (tp4a_get_flushable_frame_set(a, &f)) {
+			do {
+				tp4f_set_frame(&f, 0, 0, true);
+			} while (tp4f_next_frame(&f));
+		}
+
+		WARN_ON_ONCE(tp4a_flush(a));
+
+		tp4q_disable(a->dev, a->tp4q);
+	}
+
+	kfree(a);
+}
+
 #endif /* _LINUX_TPACKET4_H */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b39be424ec0e..190598eb3461 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -189,6 +189,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 #define BLOCK_O2PRIV(x)	((x)->offset_to_priv)
 #define BLOCK_PRIV(x)		((void *)((char *)(x) + BLOCK_O2PRIV(x)))
 
+#define RX_RING 0
+#define TX_RING 1
+
 struct packet_sock;
 static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		       struct packet_type *pt, struct net_device *orig_dev);
@@ -244,6 +247,9 @@ struct packet_skb_cb {
 
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
+static void packet_v4_ring_free(struct sock *sk, int tx_ring);
+static int packet_v4_ring_new(struct sock *sk, struct tpacket_req4 *req,
+			      int tx_ring);
 
 static int packet_direct_xmit(struct sk_buff *skb)
 {
@@ -2206,6 +2212,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
+	if (po->tp_version == TPACKET_V4)
+		goto drop;
+
 	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
@@ -2973,10 +2982,14 @@ static int packet_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
 
-	if (po->tx_ring.pg_vec)
+	if (po->tx_ring.pg_vec) {
+		if (po->tp_version == TPACKET_V4)
+			return -EINVAL;
+
 		return tpacket_snd(po, msg);
-	else
-		return packet_snd(sock, msg, len);
+	}
+
+	return packet_snd(sock, msg, len);
 }
 
 static void
@@ -3105,6 +3118,25 @@ packet_umem_new(unsigned long addr, size_t size, unsigned int frame_size,
 	return ret < 0 ? ERR_PTR(ret) : umem;
 }
 
+static void packet_clear_ring(struct sock *sk, int tx_ring)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_ring_buffer *rb;
+	union tpacket_req_u req_u;
+
+	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
+	if (!rb->pg_vec)
+		return;
+
+	if (po->tp_version == TPACKET_V4) {
+		packet_v4_ring_free(sk, tx_ring);
+		return;
+	}
+
+	memset(&req_u, 0, sizeof(req_u));
+	packet_set_ring(sk, &req_u, 1, tx_ring);
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -3116,7 +3148,6 @@ static int packet_release(struct socket *sock)
 	struct packet_sock *po;
 	struct packet_fanout *f;
 	struct net *net;
-	union tpacket_req_u req_u;
 
 	if (!sk)
 		return 0;
@@ -3144,15 +3175,8 @@ static int packet_release(struct socket *sock)
 
 	packet_flush_mclist(sk);
 
-	if (po->rx_ring.pg_vec) {
-		memset(&req_u, 0, sizeof(req_u));
-		packet_set_ring(sk, &req_u, 1, 0);
-	}
-
-	if (po->tx_ring.pg_vec) {
-		memset(&req_u, 0, sizeof(req_u));
-		packet_set_ring(sk, &req_u, 1, 1);
-	}
+	packet_clear_ring(sk, TX_RING);
+	packet_clear_ring(sk, RX_RING);
 
 	if (po->umem) {
 		packet_umem_free(po->umem);
@@ -3786,16 +3810,24 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			len = sizeof(req_u.req);
 			break;
 		case TPACKET_V3:
-		default:
 			len = sizeof(req_u.req3);
 			break;
+		case TPACKET_V4:
+		default:
+			len = sizeof(req_u.req4);
+			break;
 		}
 		if (optlen < len)
 			return -EINVAL;
 		if (copy_from_user(&req_u.req, optval, len))
 			return -EFAULT;
-		return packet_set_ring(sk, &req_u, 0,
-			optname == PACKET_TX_RING);
+
+		if (po->tp_version == TPACKET_V4)
+			return packet_v4_ring_new(sk, &req_u.req4,
+						  optname == PACKET_TX_RING);
+		else
+			return packet_set_ring(sk, &req_u, 0,
+					       optname == PACKET_TX_RING);
 	}
 	case PACKET_COPY_THRESH:
 	{
@@ -3821,6 +3853,7 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		case TPACKET_V1:
 		case TPACKET_V2:
 		case TPACKET_V3:
+		case TPACKET_V4:
 			break;
 		default:
 			return -EINVAL;
@@ -4061,6 +4094,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		case TPACKET_V3:
 			val = sizeof(struct tpacket3_hdr);
 			break;
+		case TPACKET_V4:
+			val = 0;
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -4247,6 +4283,9 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned int mask = datagram_poll(file, sock, wait);
 
+	if (po->tp_version == TPACKET_V4)
+		return mask;
+
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->rx_ring.pg_vec) {
 		if (!packet_previous_rx_frame(po, &po->rx_ring,
@@ -4363,6 +4402,197 @@ static struct pgv *alloc_pg_vec(struct tpacket_req *req, int order)
 	goto out;
 }
 
+static struct socket *
+packet_v4_umem_sock_get(int fd)
+{
+	struct {
+		struct sockaddr_ll sa;
+		char  buf[MAX_ADDR_LEN];
+	} uaddr;
+	int uaddr_len = sizeof(uaddr), r;
+	struct socket *sock = sockfd_lookup(fd, &r);
+
+	if (!sock)
+		return ERR_PTR(-ENOTSOCK);
+
+	/* Parameter checking */
+	if (sock->sk->sk_type != SOCK_RAW) {
+		r = -ESOCKTNOSUPPORT;
+		goto err;
+	}
+
+	r = sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
+			       &uaddr_len, 0);
+	if (r)
+		goto err;
+
+	if (uaddr.sa.sll_family != AF_PACKET) {
+		r = -EPFNOSUPPORT;
+		goto err;
+	}
+
+	if (!pkt_sk(sock->sk)->umem) {
+		r = -ESOCKTNOSUPPORT;
+		goto err;
+	}
+
+	return sock;
+err:
+	sockfd_put(sock);
+	return ERR_PTR(r);
+}
+
+#define TP4_ARRAY_SIZE 32
+
+static int
+packet_v4_ring_new(struct sock *sk, struct tpacket_req4 *req, int tx_ring)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_ring_buffer *rb;
+	struct sk_buff_head *rb_queue;
+	int was_running, order = 0;
+	struct socket *mrsock;
+	struct tpacket_req r;
+	struct pgv *pg_vec;
+	size_t rb_size;
+	__be16 num;
+	int err;
+
+	if (req->desc_nr == 0)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
+	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
+
+	err = -EBUSY;
+	if (atomic_read(&po->mapped))
+		goto out;
+	if (packet_read_pending(rb))
+		goto out;
+	if (unlikely(rb->pg_vec))
+		goto out;
+
+	err = -EINVAL;
+	if (po->tp_version != TPACKET_V4)
+		goto out;
+
+	po->tp_hdrlen = 0;
+
+	rb_size = req->desc_nr * sizeof(struct tpacket4_desc);
+	if (unlikely(!rb_size))
+		goto out;
+
+	err = -ENOMEM;
+	order = get_order(rb_size);
+
+	r.tp_block_nr = 1;
+	pg_vec = alloc_pg_vec(&r, order);
+	if (unlikely(!pg_vec))
+		goto out;
+
+	mrsock = packet_v4_umem_sock_get(req->mr_fd);
+	if (IS_ERR(mrsock)) {
+		err = PTR_ERR(mrsock);
+		free_pg_vec(pg_vec, order, 1);
+		goto out;
+	}
+
+	/* Check if umem is from this socket, if so don't make
+	 * circular references.
+	 */
+	if (sk->sk_socket == mrsock)
+		sockfd_put(mrsock);
+
+	spin_lock(&po->bind_lock);
+	was_running = po->running;
+	num = po->num;
+	if (was_running) {
+		po->num = 0;
+		__unregister_prot_hook(sk, false);
+	}
+	spin_unlock(&po->bind_lock);
+
+	synchronize_net();
+
+	mutex_lock(&po->pg_vec_lock);
+	spin_lock_bh(&rb_queue->lock);
+
+	rb->pg_vec = pg_vec;
+	rb->head = 0;
+	rb->frame_max = req->desc_nr - 1;
+	rb->mrsock = mrsock;
+	tp4q_init(&rb->tp4q, req->desc_nr, pkt_sk(mrsock->sk)->umem,
+		  (struct tpacket4_desc *)rb->pg_vec->buffer);
+	spin_unlock_bh(&rb_queue->lock);
+
+	rb->tp4a = tx_ring ? tp4a_tx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL)
+		   : tp4a_rx_new(&rb->tp4q, TP4_ARRAY_SIZE, NULL);
+
+	if (!rb->tp4a) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	rb->pg_vec_order = order;
+	rb->pg_vec_len = 1;
+	rb->pg_vec_pages = PAGE_ALIGN(rb_size) / PAGE_SIZE;
+
+	po->prot_hook.func = po->rx_ring.pg_vec ? tpacket_rcv : packet_rcv;
+	skb_queue_purge(rb_queue);
+
+	mutex_unlock(&po->pg_vec_lock);
+
+	spin_lock(&po->bind_lock);
+	if (was_running && po->prot_hook.dev) {
+		/* V4 requires a bound socket, so only rebind if
+		 * ifindex > 0 / !dev
+		 */
+		po->num = num;
+		register_prot_hook(sk);
+	}
+	spin_unlock(&po->bind_lock);
+
+	err = 0;
+out:
+	release_sock(sk);
+	return err;
+}
+
+static void
+packet_v4_ring_free(struct sock *sk, int tx_ring)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_ring_buffer *rb;
+	struct sk_buff_head *rb_queue;
+
+	lock_sock(sk);
+
+	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
+	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
+
+	spin_lock(&po->bind_lock);
+	unregister_prot_hook(sk, true);
+	spin_unlock(&po->bind_lock);
+
+	mutex_lock(&po->pg_vec_lock);
+	spin_lock_bh(&rb_queue->lock);
+
+	if (rb->pg_vec) {
+		free_pg_vec(rb->pg_vec, rb->pg_vec_order, rb->pg_vec_len);
+		rb->pg_vec = NULL;
+	}
+	if (rb->mrsock && sk->sk_socket != rb->mrsock)
+		sockfd_put(rb->mrsock);
+	tp4a_free(rb->tp4a);
+
+	spin_unlock_bh(&rb_queue->lock);
+	skb_queue_purge(rb_queue);
+	mutex_unlock(&po->pg_vec_lock);
+	release_sock(sk);
+}
+
 static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		int closing, int tx_ring)
 {
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 9c07cfe1b8a3..3eedab29e4d7 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -71,6 +71,10 @@ struct packet_ring_buffer {
 	unsigned int __percpu	*pending_refcnt;
 
 	struct tpacket_kbdq_core	prb_bdqc;
+
+	struct tp4_packet_array	*tp4a;
+	struct tp4_queue	tp4q;
+	struct socket		*mrsock;
 };
 
 extern struct mutex fanout_mutex;
-- 
2.11.0
