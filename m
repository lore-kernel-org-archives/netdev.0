From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 04/14] packet: enable Rx for AF_PACKET V4
Date: Tue, 31 Oct 2017 13:41:35 +0100
Message-ID: <20171031124145.9667-5-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18253 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753004AbdJaMma (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:30 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

In this commit, ingress support is implemented.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 include/linux/tpacket4.h | 361 +++++++++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c   |  83 +++++++----
 2 files changed, 419 insertions(+), 25 deletions(-)

diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index 44ba38034133..1d4c13d472e5 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -191,6 +191,172 @@ static inline struct tp4_umem *tp4q_umem_new(unsigned long addr, size_t size,
 }
 
 /**
+ * tp4q_set_error - Sets an errno on the descriptor
+ *
+ * @desc: Pointer to the descriptor to be manipulated
+ * @errno: The errno number to write to the descriptor
+ **/
+static inline void tp4q_set_error(struct tpacket4_desc *desc,
+				  int errno)
+{
+	desc->error = errno;
+}
+
+/**
+ * tp4q_set_offset - Sets the data offset for the descriptor
+ *
+ * @desc: Pointer to the descriptor to be manipulated
+ * @offset: The data offset to write to the descriptor
+ **/
+static inline void tp4q_set_offset(struct tpacket4_desc *desc,
+				   u16 offset)
+{
+	desc->offset = offset;
+}
+
+/**
+ * tp4q_is_free - Is there a free entry on the queue?
+ *
+ * @q: Pointer to the tp4 queue to examine
+ *
+ * Returns true if there is a free entry, otherwise false
+ **/
+static inline int tp4q_is_free(struct tp4_queue *q)
+{
+	unsigned int idx = q->used_idx & q->ring_mask;
+	unsigned int prev_idx;
+
+	if (!idx)
+		prev_idx = q->ring_mask;
+	else
+		prev_idx = idx - 1;
+
+	/* previous frame is already consumed by userspace
+	 * meaning ring is free
+	 */
+	if (q->ring[prev_idx].flags & TP4_DESC_KERNEL)
+		return 1;
+
+	/* there is some data that userspace can read immediately */
+	return 0;
+}
+
+/**
+ * tp4q_get_data_headroom - How much data headroom does the queue have
+ *
+ * @q: Pointer to the tp4 queue to examine
+ *
+ * Returns the amount of data headroom that has been configured for the
+ * queue
+ **/
+static inline unsigned int tp4q_get_data_headroom(struct tp4_queue *q)
+{
+	return q->umem->data_headroom + TP4_KERNEL_HEADROOM;
+}
+
+/**
+ * tp4q_is_valid_entry - Is the entry valid?
+ *
+ * @q: Pointer to the tp4 queue the descriptor resides in
+ * @desc: Pointer to the descriptor to examine
+ * @validation: The type of validation to perform
+ *
+ * Returns true if the entry is a valid, otherwise false
+ **/
+static inline bool tp4q_is_valid_entry(struct tp4_queue *q,
+				       struct tpacket4_desc *d,
+				       enum tp4_validation validation)
+{
+	if (validation == TP4_VALIDATION_NONE)
+		return true;
+
+	if (unlikely(d->idx >= q->umem->nframes)) {
+		tp4q_set_error(d, EBADF);
+		return false;
+	}
+	if (validation == TP4_VALIDATION_IDX) {
+		tp4q_set_offset(d, tp4q_get_data_headroom(q));
+		return true;
+	}
+
+	/* TP4_VALIDATION_DESC */
+	if (unlikely(d->len > q->umem->frame_size ||
+		     d->len == 0 ||
+		     d->offset > q->umem->frame_size ||
+		     d->offset + d->len > q->umem->frame_size)) {
+		tp4q_set_error(d, EBADF);
+		return false;
+	}
+
+	return true;
+}
+
+/**
+ * tp4q_nb_avail - Returns the number of available entries
+ *
+ * @q: Pointer to the tp4 queue to examine
+ * @dcnt: Max number of entries to check
+ *
+ * Returns the the number of entries available in the queue up to dcnt
+ **/
+static inline int tp4q_nb_avail(struct tp4_queue *q, int dcnt)
+{
+	unsigned int idx, last_avail_idx = q->last_avail_idx;
+	int i, entries = 0;
+
+	for (i = 0; i < dcnt; i++) {
+		idx = (last_avail_idx++) & q->ring_mask;
+		if (!(q->ring[idx].flags & TP4_DESC_KERNEL))
+			break;
+		entries++;
+	}
+
+	return entries;
+}
+
+/**
+ * tp4q_enqueue - Enqueue entries to a tp4 queue
+ *
+ * @q: Pointer to the tp4 queue the descriptor resides in
+ * @d: Pointer to the descriptor to examine
+ * @dcnt: Max number of entries to dequeue
+ *
+ * Returns 0 for success or an errno at failure
+ **/
+static inline int tp4q_enqueue(struct tp4_queue *q,
+			       const struct tpacket4_desc *d, int dcnt)
+{
+	unsigned int used_idx = q->used_idx;
+	int i;
+
+	if (q->num_free < dcnt)
+		return -ENOSPC;
+
+	q->num_free -= dcnt;
+
+	for (i = 0; i < dcnt; i++) {
+		unsigned int idx = (used_idx++) & q->ring_mask;
+
+		q->ring[idx].idx = d[i].idx;
+		q->ring[idx].len = d[i].len;
+		q->ring[idx].offset = d[i].offset;
+		q->ring[idx].error = d[i].error;
+	}
+
+	/* Order flags and data */
+	smp_wmb();
+
+	for (i = dcnt - 1; i >= 0; i--) {
+		unsigned int idx = (q->used_idx + i) & q->ring_mask;
+
+		q->ring[idx].flags = d[i].flags & ~TP4_DESC_KERNEL;
+	}
+	q->used_idx += dcnt;
+
+	return 0;
+}
+
+/**
  * tp4q_enqueue_from_array - Enqueue entries from packet array to tp4 queue
  *
  * @a: Pointer to the packet array to enqueue from
@@ -236,6 +402,45 @@ static inline int tp4q_enqueue_from_array(struct tp4_packet_array *a,
 }
 
 /**
+ * tp4q_dequeue_to_array - Dequeue entries from tp4 queue to packet array
+ *
+ * @a: Pointer to the packet array to dequeue from
+ * @dcnt: Max number of entries to dequeue
+ *
+ * Returns the number of entries dequeued. Non valid entries will be
+ * discarded.
+ **/
+static inline int tp4q_dequeue_to_array(struct tp4_packet_array *a, u32 dcnt)
+{
+	struct tpacket4_desc *d = a->items;
+	int i, entries, valid_entries = 0;
+	struct tp4_queue *q = a->tp4q;
+	u32 start = a->end;
+
+	entries = tp4q_nb_avail(q, dcnt);
+	q->num_free += entries;
+
+	/* Order flags and data */
+	smp_rmb();
+
+	for (i = 0; i < entries; i++) {
+		unsigned int d_idx = start & a->mask;
+		unsigned int idx;
+
+		idx = (q->last_avail_idx++) & q->ring_mask;
+		d[d_idx] = q->ring[idx];
+		if (!tp4q_is_valid_entry(q, &d[d_idx], a->validation)) {
+			WARN_ON_ONCE(tp4q_enqueue(a->tp4q, &d[d_idx], 1));
+			continue;
+		}
+
+		start++;
+		valid_entries++;
+	}
+	return valid_entries;
+}
+
+/**
  * tp4q_disable - Disable a tp4 queue
  *
  * @dev: Pointer to the netdevice the queue is connected to
@@ -309,6 +514,67 @@ static inline int tp4q_enable(struct device *dev,
 	return 0;
 }
 
+/**
+ * tp4q_get_page_offset - Get offset into page frame resides at
+ *
+ * @q: Pointer to the tp4 queue that this frame resides in
+ * @addr: Index of this frame in the packet buffer / umem
+ * @pg: Returns a pointer to the page of this frame
+ * @off: Returns the offset to the page of this frame
+ **/
+static inline void tp4q_get_page_offset(struct tp4_queue *q, u64 addr,
+				       u64 *pg, u64 *off)
+{
+	*pg = addr >> q->umem->nfpplog2;
+	*off = (addr - (*pg << q->umem->nfpplog2))
+	       << q->umem->frame_size_log2;
+}
+
+/**
+ * tp4q_max_data_size - Get the max packet size supported by a queue
+ *
+ * @q: Pointer to the tp4 queue to examine
+ *
+ * Returns the max packet size supported by the queue
+ **/
+static inline unsigned int tp4q_max_data_size(struct tp4_queue *q)
+{
+	return q->umem->frame_size - q->umem->data_headroom -
+		TP4_KERNEL_HEADROOM;
+}
+
+/**
+ * tp4q_get_data - Gets a pointer to the start of the packet
+ *
+ * @q: Pointer to the tp4 queue to examine
+ * @desc: Pointer to descriptor of the packet
+ *
+ * Returns a pointer to the start of the packet the descriptor is pointing
+ * to
+ **/
+static inline void *tp4q_get_data(struct tp4_queue *q,
+				  struct tpacket4_desc *desc)
+{
+	u64 pg, off;
+	u8 *pkt;
+
+	tp4q_get_page_offset(q, desc->idx, &pg, &off);
+	pkt = page_address(q->umem->pgs[pg]);
+	return (u8 *)(pkt + off) + desc->offset;
+}
+
+/**
+ * tp4q_get_desc - Get descriptor associated with frame
+ *
+ * @p: Pointer to the packet to examine
+ *
+ * Returns the descriptor of the current frame of packet p
+ **/
+static inline struct tpacket4_desc *tp4q_get_desc(struct tp4_frame_set *p)
+{
+	return &p->pkt_arr->items[p->curr & p->pkt_arr->mask];
+}
+
 /*************** FRAME OPERATIONS *******************************/
 /* A frame is always just one frame of size frame_size.
  * A frame set is one or more frames.
@@ -331,6 +597,18 @@ static inline bool tp4f_next_frame(struct tp4_frame_set *p)
 }
 
 /**
+ * tp4f_get_data - Gets a pointer to the frame the frame set is on
+ * @p: pointer to the frame set
+ *
+ * Returns a pointer to the data of the frame that the frame set is
+ * pointing to. Note that there might be configured headroom before this
+ **/
+static inline void *tp4f_get_data(struct tp4_frame_set *p)
+{
+	return tp4q_get_data(p->pkt_arr->tp4q, tp4q_get_desc(p));
+}
+
+/**
  * tp4f_set_frame - Sets the properties of a frame
  * @p: pointer to frame
  * @len: the length in bytes of the data in the frame
@@ -443,6 +721,29 @@ static inline bool tp4a_get_flushable_frame_set(struct tp4_packet_array *a,
 }
 
 /**
+ * tp4a_next_frame - Get next frame in array and advance curr pointer
+ * @a: pointer to packet array
+ * @p: supplied pointer to packet structure that is filled in by function
+ *
+ * Returns true if there is a frame, false otherwise. Frame returned in *p.
+ **/
+static inline bool tp4a_next_frame(struct tp4_packet_array *a,
+				   struct tp4_frame_set *p)
+{
+	u32 avail = a->end - a->curr;
+
+	if (avail == 0)
+		return false; /* empty */
+
+	p->pkt_arr = a;
+	p->start = a->curr;
+	p->curr = a->curr;
+	p->end = ++a->curr;
+
+	return true;
+}
+
+/**
  * tp4a_flush - Flush processed packets to associated tp4q
  * @a: pointer to packet array
  *
@@ -489,4 +790,64 @@ static inline void tp4a_free(struct tp4_packet_array *a)
 	kfree(a);
 }
 
+/**
+ * tp4a_get_data_headroom - Returns the data headroom configured for the array
+ * @a: pointer to packet array
+ *
+ * Returns the data headroom configured for the array
+ **/
+static inline unsigned int tp4a_get_data_headroom(struct tp4_packet_array *a)
+{
+	return tp4q_get_data_headroom(a->tp4q);
+}
+
+/**
+ * tp4a_max_data_size - Get the max packet size supported for the array
+ * @a: pointer to packet array
+ *
+ * Returns the maximum size of data that can be put in a frame when headroom
+ * has been accounted for.
+ **/
+static inline unsigned int tp4a_max_data_size(struct tp4_packet_array *a)
+{
+	return tp4q_max_data_size(a->tp4q);
+
+}
+
+/**
+ * tp4a_populate - Populate an array with packets from associated tp4q
+ * @a: pointer to packet array
+ **/
+static inline void tp4a_populate(struct tp4_packet_array *a)
+{
+	u32 cnt, free = a->mask + 1 - (a->end - a->start);
+
+	if (free == 0)
+		return; /* no space! */
+
+	cnt = tp4q_dequeue_to_array(a, free);
+	a->end += cnt;
+}
+
+/**
+ * tp4a_next_frame_populate - Get next frame and populate array if empty
+ * @a: pointer to packet array
+ * @p: supplied pointer to packet structure that is filled in by function
+ *
+ * Returns true if there is a frame, false otherwise. Frame returned in *p.
+ **/
+static inline bool tp4a_next_frame_populate(struct tp4_packet_array *a,
+					    struct tp4_frame_set *p)
+{
+	bool more_frames;
+
+	more_frames = tp4a_next_frame(a, p);
+	if (!more_frames) {
+		tp4a_populate(a);
+		more_frames = tp4a_next_frame(a, p);
+	}
+
+	return more_frames;
+}
+
 #endif /* _LINUX_TPACKET4_H */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 190598eb3461..830d97ff4358 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2192,7 +2192,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
 	unsigned long status = TP_STATUS_USER;
-	unsigned short macoff, netoff, hdrlen;
+	unsigned short macoff = 0, netoff = 0, hdrlen;
 	struct sk_buff *copy_skb = NULL;
 	struct timespec ts;
 	__u32 ts_status;
@@ -2212,9 +2212,6 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (po->tp_version == TPACKET_V4)
-		goto drop;
-
 	if (!net_eq(dev_net(dev), sock_net(sk)))
 		goto drop;
 
@@ -2246,7 +2243,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (sk->sk_type == SOCK_DGRAM) {
 		macoff = netoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 +
 				  po->tp_reserve;
-	} else {
+	} else if (po->tp_version != TPACKET_V4) {
 		unsigned int maclen = skb_network_offset(skb);
 		netoff = TPACKET_ALIGN(po->tp_hdrlen +
 				       (maclen < 16 ? 16 : maclen)) +
@@ -2276,6 +2273,12 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 				do_vnet = false;
 			}
 		}
+	} else if (po->tp_version == TPACKET_V4) {
+		if (snaplen > tp4a_max_data_size(po->rx_ring.tp4a)) {
+			pr_err_once("%s: packet too big, %u, dropping.",
+				    __func__, snaplen);
+			goto drop_n_restore;
+		}
 	} else if (unlikely(macoff + snaplen >
 			    GET_PBDQC_FROM_RB(&po->rx_ring)->max_frame_len)) {
 		u32 nval;
@@ -2291,8 +2294,22 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 	spin_lock(&sk->sk_receive_queue.lock);
-	h.raw = packet_current_rx_frame(po, skb,
-					TP_STATUS_KERNEL, (macoff+snaplen));
+	if (po->tp_version != TPACKET_V4) {
+		h.raw = packet_current_rx_frame(po, skb,
+						TP_STATUS_KERNEL,
+						(macoff + snaplen));
+	} else {
+		struct tp4_frame_set p;
+
+		if (tp4a_next_frame_populate(po->rx_ring.tp4a, &p)) {
+			u16 offset = tp4a_get_data_headroom(po->rx_ring.tp4a);
+
+			tp4f_set_frame(&p, snaplen, offset, true);
+			h.raw = tp4f_get_data(&p);
+		} else {
+			h.raw = NULL;
+		}
+	}
 	if (!h.raw)
 		goto drop_n_account;
 	if (po->tp_version <= TPACKET_V2) {
@@ -2371,20 +2388,25 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		memset(h.h3->tp_padding, 0, sizeof(h.h3->tp_padding));
 		hdrlen = sizeof(*h.h3);
 		break;
+	case TPACKET_V4:
+		hdrlen = 0;
+		break;
 	default:
 		BUG();
 	}
 
-	sll = h.raw + TPACKET_ALIGN(hdrlen);
-	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
-	sll->sll_family = AF_PACKET;
-	sll->sll_hatype = dev->type;
-	sll->sll_protocol = skb->protocol;
-	sll->sll_pkttype = skb->pkt_type;
-	if (unlikely(po->origdev))
-		sll->sll_ifindex = orig_dev->ifindex;
-	else
-		sll->sll_ifindex = dev->ifindex;
+	if (po->tp_version != TPACKET_V4) {
+		sll = h.raw + TPACKET_ALIGN(hdrlen);
+		sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
+		sll->sll_family = AF_PACKET;
+		sll->sll_hatype = dev->type;
+		sll->sll_protocol = skb->protocol;
+		sll->sll_pkttype = skb->pkt_type;
+		if (unlikely(po->origdev))
+			sll->sll_ifindex = orig_dev->ifindex;
+		else
+			sll->sll_ifindex = dev->ifindex;
+	}
 
 	smp_mb();
 
@@ -2401,11 +2423,21 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	smp_wmb();
 #endif
 
-	if (po->tp_version <= TPACKET_V2) {
+	switch (po->tp_version) {
+	case TPACKET_V1:
+	case TPACKET_V2:
 		__packet_set_status(po, h.raw, status);
 		sk->sk_data_ready(sk);
-	} else {
+		break;
+	case TPACKET_V3:
 		prb_clear_blk_fill_status(&po->rx_ring);
+		break;
+	case TPACKET_V4:
+		spin_lock(&sk->sk_receive_queue.lock);
+		WARN_ON_ONCE(tp4a_flush(po->rx_ring.tp4a));
+		spin_unlock(&sk->sk_receive_queue.lock);
+		sk->sk_data_ready(sk);
+		break;
 	}
 
 drop_n_restore:
@@ -4283,20 +4315,21 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned int mask = datagram_poll(file, sock, wait);
 
-	if (po->tp_version == TPACKET_V4)
-		return mask;
-
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->rx_ring.pg_vec) {
-		if (!packet_previous_rx_frame(po, &po->rx_ring,
-			TP_STATUS_KERNEL))
+		if (po->tp_version == TPACKET_V4) {
+			if (!tp4q_is_free(&po->rx_ring.tp4q))
+				mask |= POLLIN | POLLRDNORM;
+		} else if (!packet_previous_rx_frame(po, &po->rx_ring,
+					TP_STATUS_KERNEL)) {
 			mask |= POLLIN | POLLRDNORM;
+		}
 	}
 	if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
 		po->pressure = 0;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
-	if (po->tx_ring.pg_vec) {
+	if (po->tx_ring.pg_vec && po->tp_version != TPACKET_V4) {
 		if (packet_current_frame(po, &po->tx_ring, TP_STATUS_AVAILABLE))
 			mask |= POLLOUT | POLLWRNORM;
 	}
-- 
2.11.0
