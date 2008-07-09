From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 03/08]: packet: support extensible, 64 bit clean mmaped ring structure
Date: Wed,  9 Jul 2008 14:09:49 +0200 (MEST)
Message-ID: <20080709120949.11669.38050.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbYGIMJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:51 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

packet: support extensible, 64 bit clean mmaped ring structure

The tpacket_hdr is not 64 bit clean due to use of an unsigned long
and can't be extended because the following struct sockaddr_ll needs
to be at a fixed offset.

Add support for a version 2 tpacket protocol that removes these
limitations.

Userspace can query the header size through a new getsockopt option
and change the protocol version through a setsockopt option. The
changes needed to switch to the new protocol version are:

1. replace struct tpacket_hdr by struct tpacket2_hdr
2. query header len and save
3. set protocol version to 2
 - set up ring as usual
4. for getting the sockaddr_ll, use (void *)hdr + TPACKET_ALIGN(hdrlen)
   instead of (void *)hdr + TPACKET_ALIGN(sizeof(struct tpacket_hdr))

Steps 2 and 4 can be omitted if the struct sockaddr_ll isn't needed.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 67facd0da49b1c2061e17a6623904f675d0b1bc9
tree 3c3f7e5bcd481da693fbdda775c618abf9f89584
parent 2150bca3247c0b497a83937005367092bca86530
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:04:26 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 13:04:26 +0200

 include/linux/if_packet.h |   21 +++++
 net/packet/af_packet.c    |  179 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 167 insertions(+), 33 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index ad09609..d4d3c82 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -43,6 +43,8 @@ struct sockaddr_ll
 #define PACKET_COPY_THRESH		7
 #define PACKET_AUXDATA			8
 #define PACKET_ORIGDEV			9
+#define PACKET_VERSION			10
+#define PACKET_HDRLEN			11
 
 struct tpacket_stats
 {
@@ -79,6 +81,25 @@ struct tpacket_hdr
 #define TPACKET_ALIGN(x)	(((x)+TPACKET_ALIGNMENT-1)&~(TPACKET_ALIGNMENT-1))
 #define TPACKET_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket_hdr)) + sizeof(struct sockaddr_ll))
 
+struct tpacket2_hdr
+{
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u32		tp_sec;
+	__u32		tp_nsec;
+};
+
+#define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr)) + sizeof(struct sockaddr_ll))
+
+enum tpacket_versions
+{
+	TPACKET_V1,
+	TPACKET_V2,
+};
+
 /*
    Frame structure:
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index beca640..85ab3e3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -186,6 +186,8 @@ struct packet_sock {
 	unsigned int            pg_vec_order;
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
+	enum tpacket_versions	tp_version;
+	unsigned int		tp_hdrlen;
 #endif
 };
 
@@ -201,14 +203,52 @@ struct packet_skb_cb {
 
 #ifdef CONFIG_PACKET_MMAP
 
-static inline struct tpacket_hdr *packet_lookup_frame(struct packet_sock *po, unsigned int position)
+static void *packet_lookup_frame(struct packet_sock *po, unsigned int position,
+				 int status)
 {
 	unsigned int pg_vec_pos, frame_offset;
+	union {
+		struct tpacket_hdr *h1;
+		struct tpacket2_hdr *h2;
+		void *raw;
+	} h;
 
 	pg_vec_pos = position / po->frames_per_block;
 	frame_offset = position % po->frames_per_block;
 
-	return (struct tpacket_hdr *)(po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size));
+	h.raw = po->pg_vec[pg_vec_pos] + (frame_offset * po->frame_size);
+	switch (po->tp_version) {
+	case TPACKET_V1:
+		if (status != h.h1->tp_status ? TP_STATUS_USER :
+						TP_STATUS_KERNEL)
+			return NULL;
+		break;
+	case TPACKET_V2:
+		if (status != h.h2->tp_status ? TP_STATUS_USER :
+						TP_STATUS_KERNEL)
+			return NULL;
+		break;
+	}
+	return h.raw;
+}
+
+static void __packet_set_status(struct packet_sock *po, void *frame, int status)
+{
+	union {
+		struct tpacket_hdr *h1;
+		struct tpacket2_hdr *h2;
+		void *raw;
+	} h;
+
+	h.raw = frame;
+	switch (po->tp_version) {
+	case TPACKET_V1:
+		h.h1->tp_status = status;
+		break;
+	case TPACKET_V2:
+		h.h2->tp_status = status;
+		break;
+	}
 }
 #endif
 
@@ -551,14 +591,19 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	struct sock *sk;
 	struct packet_sock *po;
 	struct sockaddr_ll *sll;
-	struct tpacket_hdr *h;
+	union {
+		struct tpacket_hdr *h1;
+		struct tpacket2_hdr *h2;
+		void *raw;
+	} h;
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
 	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
-	unsigned short macoff, netoff;
+	unsigned short macoff, netoff, hdrlen;
 	struct sk_buff *copy_skb = NULL;
 	struct timeval tv;
+	struct timespec ts;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -590,10 +635,11 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 		snaplen = res;
 
 	if (sk->sk_type == SOCK_DGRAM) {
-		macoff = netoff = TPACKET_ALIGN(TPACKET_HDRLEN) + 16;
+		macoff = netoff = TPACKET_ALIGN(po->tp_hdrlen) + 16;
 	} else {
 		unsigned maclen = skb_network_offset(skb);
-		netoff = TPACKET_ALIGN(TPACKET_HDRLEN + (maclen < 16 ? 16 : maclen));
+		netoff = TPACKET_ALIGN(po->tp_hdrlen +
+				       (maclen < 16 ? 16 : maclen));
 		macoff = netoff - maclen;
 	}
 
@@ -616,9 +662,8 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	}
 
 	spin_lock(&sk->sk_receive_queue.lock);
-	h = packet_lookup_frame(po, po->head);
-
-	if (h->tp_status)
+	h.raw = packet_lookup_frame(po, po->head, TP_STATUS_KERNEL);
+	if (!h.raw)
 		goto ring_is_full;
 	po->head = po->head != po->frame_max ? po->head+1 : 0;
 	po->stats.tp_packets++;
@@ -630,20 +675,40 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 		status &= ~TP_STATUS_LOSING;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-	skb_copy_bits(skb, 0, (u8*)h + macoff, snaplen);
+	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
 
-	h->tp_len = skb->len;
-	h->tp_snaplen = snaplen;
-	h->tp_mac = macoff;
-	h->tp_net = netoff;
-	if (skb->tstamp.tv64)
-		tv = ktime_to_timeval(skb->tstamp);
-	else
-		do_gettimeofday(&tv);
-	h->tp_sec = tv.tv_sec;
-	h->tp_usec = tv.tv_usec;
+	switch (po->tp_version) {
+	case TPACKET_V1:
+		h.h1->tp_len = skb->len;
+		h.h1->tp_snaplen = snaplen;
+		h.h1->tp_mac = macoff;
+		h.h1->tp_net = netoff;
+		if (skb->tstamp.tv64)
+			tv = ktime_to_timeval(skb->tstamp);
+		else
+			do_gettimeofday(&tv);
+		h.h1->tp_sec = tv.tv_sec;
+		h.h1->tp_usec = tv.tv_usec;
+		hdrlen = sizeof(*h.h1);
+		break;
+	case TPACKET_V2:
+		h.h2->tp_len = skb->len;
+		h.h2->tp_snaplen = snaplen;
+		h.h2->tp_mac = macoff;
+		h.h2->tp_net = netoff;
+		if (skb->tstamp.tv64)
+			ts = ktime_to_timespec(skb->tstamp);
+		else
+			getnstimeofday(&ts);
+		h.h2->tp_sec = ts.tv_sec;
+		h.h2->tp_nsec = ts.tv_nsec;
+		hdrlen = sizeof(*h.h2);
+		break;
+	default:
+		BUG();
+	}
 
-	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
+	sll = h.raw + TPACKET_ALIGN(hdrlen);
 	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 	sll->sll_family = AF_PACKET;
 	sll->sll_hatype = dev->type;
@@ -654,14 +719,14 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	else
 		sll->sll_ifindex = dev->ifindex;
 
-	h->tp_status = status;
+	__packet_set_status(po, h.raw, status);
 	smp_mb();
 
 	{
 		struct page *p_start, *p_end;
-		u8 *h_end = (u8 *)h + macoff + snaplen - 1;
+		u8 *h_end = h.raw + macoff + snaplen - 1;
 
-		p_start = virt_to_page(h);
+		p_start = virt_to_page(h.raw);
 		p_end = virt_to_page(h_end);
 		while (p_start <= p_end) {
 			flush_dcache_page(p_start);
@@ -1356,6 +1421,25 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		pkt_sk(sk)->copy_thresh = val;
 		return 0;
 	}
+	case PACKET_VERSION:
+	{
+		int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (po->pg_vec)
+			return -EBUSY;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+		switch (val) {
+		case TPACKET_V1:
+		case TPACKET_V2:
+			po->tp_version = val;
+			return 0;
+		default:
+			return -EINVAL;
+		}
+	}
 #endif
 	case PACKET_AUXDATA:
 	{
@@ -1431,6 +1515,31 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
 		data = &val;
 		break;
+#ifdef CONFIG_PACKET_MMAP
+	case PACKET_VERSION:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = po->tp_version;
+		data = &val;
+		break;
+	case PACKET_HDRLEN:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		if (copy_from_user(&val, optval, len))
+			return -EFAULT;
+		switch (val) {
+		case TPACKET_V1:
+			val = sizeof(struct tpacket_hdr);
+			break;
+		case TPACKET_V2:
+			val = sizeof(struct tpacket2_hdr);
+			break;
+		default:
+			return -EINVAL;
+		}
+		data = &val;
+		break;
+#endif
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1564,11 +1673,8 @@ static unsigned int packet_poll(struct file * file, struct socket *sock,
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->pg_vec) {
 		unsigned last = po->head ? po->head-1 : po->frame_max;
-		struct tpacket_hdr *h;
-
-		h = packet_lookup_frame(po, last);
 
-		if (h->tp_status)
+		if (packet_lookup_frame(po, last, TP_STATUS_USER))
 			mask |= POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
@@ -1663,11 +1769,20 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
 		if (unlikely(po->pg_vec))
 			return -EBUSY;
 
+		switch (po->tp_version) {
+		case TPACKET_V1:
+			po->tp_hdrlen = TPACKET_HDRLEN;
+			break;
+		case TPACKET_V2:
+			po->tp_hdrlen = TPACKET2_HDRLEN;
+			break;
+		}
+
 		if (unlikely((int)req->tp_block_size <= 0))
 			return -EINVAL;
 		if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
 			return -EINVAL;
-		if (unlikely(req->tp_frame_size < TPACKET_HDRLEN))
+		if (unlikely(req->tp_frame_size < po->tp_hdrlen))
 			return -EINVAL;
 		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
 			return -EINVAL;
@@ -1686,13 +1801,11 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
 			goto out;
 
 		for (i = 0; i < req->tp_block_nr; i++) {
-			char *ptr = pg_vec[i];
-			struct tpacket_hdr *header;
+			void *ptr = pg_vec[i];
 			int k;
 
 			for (k = 0; k < po->frames_per_block; k++) {
-				header = (struct tpacket_hdr *) ptr;
-				header->tp_status = TP_STATUS_KERNEL;
+				__packet_set_status(po, ptr, TP_STATUS_KERNEL);
 				ptr += req->tp_frame_size;
 			}
 		}
