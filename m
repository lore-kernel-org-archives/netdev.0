From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 05/14] packet: enable Tx support for AF_PACKET V4
Date: Tue, 31 Oct 2017 13:41:36 +0100
Message-ID: <20171031124145.9667-6-bjorn.topel@gmail.com>
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
        id S1753095AbdJaMmf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:35 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

In this commit AF_PACKET V4 egress support is added.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 include/linux/tpacket4.h | 192 +++++++++++++++++++++++++++++++++++++++++++++++
 net/packet/af_packet.c   | 169 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 350 insertions(+), 11 deletions(-)

diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index 1d4c13d472e5..ac6c721294e8 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -18,6 +18,8 @@
 #define TP4_UMEM_MIN_FRAME_SIZE 2048
 #define TP4_KERNEL_HEADROOM 256 /* Headrom for XDP */
 
+#define TP4A_FRAME_COMPLETED TP4_DESC_KERNEL
+
 enum tp4_validation {
 	TP4_VALIDATION_NONE,	/* No validation is performed */
 	TP4_VALIDATION_IDX,	/* Only address to packet buffer is validated */
@@ -402,6 +404,60 @@ static inline int tp4q_enqueue_from_array(struct tp4_packet_array *a,
 }
 
 /**
+ * tp4q_enqueue_completed_from_array - Enqueue only completed entries
+ *				       from packet array
+ *
+ * @a: Pointer to the packet array to enqueue from
+ * @dcnt: Max number of entries to enqueue
+ *
+ * Returns the number of entries successfully enqueued or a negative errno
+ * at failure.
+ **/
+static inline int tp4q_enqueue_completed_from_array(struct tp4_packet_array *a,
+						    u32 dcnt)
+{
+	struct tp4_queue *q = a->tp4q;
+	unsigned int used_idx = q->used_idx;
+	struct tpacket4_desc *d = a->items;
+	int i, j;
+
+	if (q->num_free < dcnt)
+		return -ENOSPC;
+
+	for (i = 0; i < dcnt; i++) {
+		unsigned int didx = (a->start + i) & a->mask;
+
+		if (d[didx].flags & TP4A_FRAME_COMPLETED) {
+			unsigned int idx = (used_idx++) & q->ring_mask;
+
+			q->ring[idx].idx = d[didx].idx;
+			q->ring[idx].len = d[didx].len;
+			q->ring[idx].offset = d[didx].offset;
+			q->ring[idx].error = d[didx].error;
+		} else {
+			break;
+		}
+	}
+
+	if (i == 0)
+		return 0;
+
+	/* Order flags and data */
+	smp_wmb();
+
+	for (j = i - 1; j >= 0; j--) {
+		unsigned int idx = (q->used_idx + j) & q->ring_mask;
+		unsigned int didx = (a->start + j) & a->mask;
+
+		q->ring[idx].flags = d[didx].flags & ~TP4_DESC_KERNEL;
+	}
+	q->num_free -= i;
+	q->used_idx += i;
+
+	return i;
+}
+
+/**
  * tp4q_dequeue_to_array - Dequeue entries from tp4 queue to packet array
  *
  * @a: Pointer to the packet array to dequeue from
@@ -581,6 +637,15 @@ static inline struct tpacket4_desc *tp4q_get_desc(struct tp4_frame_set *p)
  **/
 
 /**
+ * tp4f_reset - Start to traverse the frames in the set from the beginning
+ * @p: pointer to frame set
+ **/
+static inline void tp4f_reset(struct tp4_frame_set *p)
+{
+	p->curr = p->start;
+}
+
+/**
  * tp4f_next_frame - Go to next frame in frame set
  * @p: pointer to frame set
  *
@@ -597,6 +662,38 @@ static inline bool tp4f_next_frame(struct tp4_frame_set *p)
 }
 
 /**
+ * tp4f_get_frame_id - Get packet buffer id of frame
+ * @p: pointer to frame set
+ *
+ * Returns the id of the packet buffer of the current frame
+ **/
+static inline u64 tp4f_get_frame_id(struct tp4_frame_set *p)
+{
+	return p->pkt_arr->items[p->curr & p->pkt_arr->mask].idx;
+}
+
+/**
+ * tp4f_get_frame_len - Get length of data in current frame
+ * @p: pointer to frame set
+ *
+ * Returns the length of data in the packet buffer of the current frame
+ **/
+static inline u32 tp4f_get_frame_len(struct tp4_frame_set *p)
+{
+	return p->pkt_arr->items[p->curr & p->pkt_arr->mask].len;
+}
+
+/**
+ * tp4f_set_error - Set an error on the current frame
+ * @p: pointer to frame set
+ * @errno: the errno to be assigned
+ **/
+static inline void tp4f_set_error(struct tp4_frame_set *p, int errno)
+{
+	p->pkt_arr->items[p->curr & p->pkt_arr->mask].error = errno;
+}
+
+/**
  * tp4f_get_data - Gets a pointer to the frame the frame set is on
  * @p: pointer to the frame set
  *
@@ -627,6 +724,48 @@ static inline void tp4f_set_frame(struct tp4_frame_set *p, u32 len, u16 offset,
 		d->flags |= TP4_PKT_CONT;
 }
 
+/*************** PACKET OPERATIONS *******************************/
+/* A packet consists of one or more frames. Both frames and packets
+ * are represented by a tp4_frame_set. The only difference is that
+ * packet functions look at the EOP flag.
+ **/
+
+/**
+ * tp4f_get_packet_len - Length of packet
+ * @p: pointer to packet
+ *
+ * Returns the length of the packet in bytes.
+ * Resets curr pointer of packet.
+ **/
+static inline u32 tp4f_get_packet_len(struct tp4_frame_set *p)
+{
+	u32 len = 0;
+
+	tp4f_reset(p);
+
+	do {
+		len += tp4f_get_frame_len(p);
+	} while (tp4f_next_frame(p));
+
+	return len;
+}
+
+/**
+ * tp4f_packet_completed - Mark packet as completed
+ * @p: pointer to packet
+ *
+ * Resets curr pointer of packet.
+ **/
+static inline void tp4f_packet_completed(struct tp4_frame_set *p)
+{
+	tp4f_reset(p);
+
+	do {
+		p->pkt_arr->items[p->curr & p->pkt_arr->mask].flags |=
+			TP4A_FRAME_COMPLETED;
+	} while (tp4f_next_frame(p));
+}
+
 /**************** PACKET_ARRAY FUNCTIONS ********************************/
 
 static inline struct tp4_packet_array *__tp4a_new(
@@ -815,6 +954,59 @@ static inline unsigned int tp4a_max_data_size(struct tp4_packet_array *a)
 }
 
 /**
+ * tp4a_next_packet - Get next packet in array and advance curr pointer
+ * @a: pointer to packet array
+ * @p: supplied pointer to packet structure that is filled in by function
+ *
+ * Returns true if there is a packet, false otherwise. Packet returned in *p.
+ **/
+static inline bool tp4a_next_packet(struct tp4_packet_array *a,
+				    struct tp4_frame_set *p)
+{
+	u32 avail = a->end - a->curr;
+
+	if (avail == 0)
+		return false; /* empty */
+
+	p->pkt_arr = a;
+	p->start = a->curr;
+	p->curr = a->curr;
+	p->end = a->curr;
+
+	/* XXX Sanity check for too-many-frames packets? */
+	while (a->items[p->end++ & a->mask].flags & TP4_PKT_CONT) {
+		avail--;
+		if (avail == 0)
+			return false;
+	}
+
+	a->curr += (p->end - p->start);
+	return true;
+}
+
+/**
+ * tp4a_flush_completed - Flushes only frames marked as completed
+ * @a: pointer to packet array
+ *
+ * Returns 0 for success and -1 for failure
+ **/
+static inline int tp4a_flush_completed(struct tp4_packet_array *a)
+{
+	u32 avail = a->curr - a->start;
+	int ret;
+
+	if (avail == 0)
+		return 0; /* nothing to flush */
+
+	ret = tp4q_enqueue_completed_from_array(a, avail);
+	if (ret < 0)
+		return -1;
+
+	a->start += ret;
+	return 0;
+}
+
+/**
  * tp4a_populate - Populate an array with packets from associated tp4q
  * @a: pointer to packet array
  **/
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 830d97ff4358..444eb4834362 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2462,6 +2462,28 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	goto drop_n_restore;
 }
 
+static void packet_v4_destruct_skb(struct sk_buff *skb)
+{
+	struct packet_sock *po = pkt_sk(skb->sk);
+
+	if (likely(po->tx_ring.pg_vec)) {
+		u64 idx = (u64)skb_shinfo(skb)->destructor_arg;
+		struct tp4_frame_set p = {.start = idx,
+					  .curr = idx,
+					  .end = idx + 1,
+					  .pkt_arr = po->tx_ring.tp4a};
+
+		spin_lock(&po->sk.sk_write_queue.lock);
+		tp4f_packet_completed(&p);
+		WARN_ON_ONCE(tp4a_flush_completed(po->tx_ring.tp4a));
+		spin_unlock(&po->sk.sk_write_queue.lock);
+
+		packet_dec_pending(&po->tx_ring);
+	}
+
+	sock_wfree(skb);
+}
+
 static void tpacket_destruct_skb(struct sk_buff *skb)
 {
 	struct packet_sock *po = pkt_sk(skb->sk);
@@ -2519,24 +2541,24 @@ static int packet_snd_vnet_parse(struct msghdr *msg, size_t *len,
 }
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
-		void *frame, struct net_device *dev, void *data, int tp_len,
+		void *dtor_arg, struct net_device *dev, void *data, int tp_len,
 		__be16 proto, unsigned char *addr, int hlen, int copylen,
 		const struct sockcm_cookie *sockc)
 {
-	union tpacket_uhdr ph;
 	int to_write, offset, len, nr_frags, len_max;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
 	int err;
 
-	ph.raw = frame;
-
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
-	sock_tx_timestamp(&po->sk, sockc->tsflags, &skb_shinfo(skb)->tx_flags);
-	skb_shinfo(skb)->destructor_arg = ph.raw;
+	if (sockc) {
+		sock_tx_timestamp(&po->sk, sockc->tsflags,
+				  &skb_shinfo(skb)->tx_flags);
+	}
+	skb_shinfo(skb)->destructor_arg = dtor_arg;
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
@@ -2840,6 +2862,126 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	return err;
 }
 
+static int packet_v4_snd(struct packet_sock *po, struct msghdr *msg)
+{
+	DECLARE_SOCKADDR(struct sockaddr_ll *, saddr, msg->msg_name);
+	bool need_wait = !(msg->msg_flags & MSG_DONTWAIT);
+	struct packet_ring_buffer *rb = &po->tx_ring;
+	int err = 0, dlen, size_max, hlen, tlen;
+	struct tp4_frame_set p;
+	struct net_device *dev;
+	struct sk_buff *skb;
+	unsigned char *addr;
+	bool has_packet;
+	__be16 proto;
+	void *data;
+
+	mutex_lock(&po->pg_vec_lock);
+
+	if (likely(!saddr)) {
+		dev = packet_cached_dev_get(po);
+		proto = po->num;
+		addr = NULL;
+	} else {
+		pr_warn("packet v4 not implemented!\n");
+		return -EINVAL;
+	}
+
+	err = -ENXIO;
+	if (unlikely(!dev))
+		goto out;
+	err = -ENETDOWN;
+	if (unlikely(!(dev->flags & IFF_UP)))
+		goto out_put;
+
+	size_max = tp4a_max_data_size(rb->tp4a);
+
+	if (size_max > dev->mtu + dev->hard_header_len + VLAN_HLEN)
+		size_max = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+
+	spin_lock_bh(&po->sk.sk_write_queue.lock);
+	tp4a_populate(rb->tp4a);
+	spin_unlock_bh(&po->sk.sk_write_queue.lock);
+
+	do {
+		spin_lock_bh(&po->sk.sk_write_queue.lock);
+		has_packet = tp4a_next_packet(rb->tp4a, &p);
+		spin_unlock_bh(&po->sk.sk_write_queue.lock);
+
+		if (!has_packet) {
+			if (need_wait && need_resched()) {
+				schedule();
+				continue;
+			}
+			break;
+		}
+
+		dlen = tp4f_get_packet_len(&p);
+		data = tp4f_get_data(&p);
+		hlen = LL_RESERVED_SPACE(dev);
+		tlen = dev->needed_tailroom;
+		skb = sock_alloc_send_skb(&po->sk,
+					  hlen + tlen +
+					  sizeof(struct sockaddr_ll),
+					  !need_wait, &err);
+
+		if (unlikely(!skb)) {
+			err = -EAGAIN;
+			goto out_err;
+		}
+
+		dlen = tpacket_fill_skb(po, skb,
+					(void *)(long)tp4f_get_frame_id(&p),
+					dev,
+					data, dlen, proto, addr, hlen,
+					dev->hard_header_len, NULL);
+		if (likely(dlen >= 0) &&
+		    dlen > dev->mtu + dev->hard_header_len &&
+		    !packet_extra_vlan_len_allowed(dev, skb)) {
+			dlen = -EMSGSIZE;
+		}
+
+		if (unlikely(dlen < 0)) {
+			err = dlen;
+			goto out_err;
+		}
+
+		skb->destructor = packet_v4_destruct_skb;
+		packet_inc_pending(&po->tx_ring);
+
+		err = po->xmit(skb);
+		/* Ignore NET_XMIT_CN as packet might have been sent */
+		if (err == NET_XMIT_DROP || err == NETDEV_TX_BUSY) {
+			err = -EAGAIN;
+			packet_dec_pending(&po->tx_ring);
+			skb = NULL;
+			goto out_err;
+		}
+	} while (!err ||
+		/* Note: packet_read_pending() might be slow if we have
+		 * to call it as it's per_cpu variable, but in fast-path
+		 * we already short-circuit the loop with the first
+		 * condition, and luckily don't have to go that path
+		 * anyway.
+		 */
+		 (need_wait && packet_read_pending(&po->tx_ring)));
+
+	goto out_put;
+
+out_err:
+	spin_lock_bh(&po->sk.sk_write_queue.lock);
+	tp4f_set_error(&p, -err);
+	tp4f_packet_completed(&p);
+	WARN_ON_ONCE(tp4a_flush_completed(rb->tp4a));
+	spin_unlock_bh(&po->sk.sk_write_queue.lock);
+	kfree_skb(skb);
+out_put:
+	dev_put(dev);
+out:
+	mutex_unlock(&po->pg_vec_lock);
+	return 0;
+}
+
 static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 				        size_t reserve, size_t len,
 				        size_t linear, int noblock,
@@ -3015,10 +3157,10 @@ static int packet_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	struct packet_sock *po = pkt_sk(sk);
 
 	if (po->tx_ring.pg_vec) {
-		if (po->tp_version == TPACKET_V4)
-			return -EINVAL;
+		if (po->tp_version != TPACKET_V4)
+			return tpacket_snd(po, msg);
 
-		return tpacket_snd(po, msg);
+		return packet_v4_snd(po, msg);
 	}
 
 	return packet_snd(sock, msg, len);
@@ -4329,9 +4471,14 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 		po->pressure = 0;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
-	if (po->tx_ring.pg_vec && po->tp_version != TPACKET_V4) {
-		if (packet_current_frame(po, &po->tx_ring, TP_STATUS_AVAILABLE))
+	if (po->tx_ring.pg_vec) {
+		if (po->tp_version == TPACKET_V4) {
+			if (tp4q_nb_avail(&po->tx_ring.tp4q, 1))
+				mask |= POLLOUT | POLLWRNORM;
+		} else if (packet_current_frame(po, &po->tx_ring,
+					 TP_STATUS_AVAILABLE)) {
 			mask |= POLLOUT | POLLWRNORM;
+		}
 	}
 	spin_unlock_bh(&sk->sk_write_queue.lock);
 	return mask;
-- 
2.11.0
