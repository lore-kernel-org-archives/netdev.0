From: chetan loke <loke.chetan@gmail.com>
Subject: [RFC 01/01]af_packet: Enhance network capture visibility
Date: Wed, 25 May 2011 19:03:08 -0400
Message-ID: <BANLkTimYVUkUWA2XPix2nUL-=rnQKghZQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:40500 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab1EYXDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:03:08 -0400
Received: by pwi15 with SMTP id 15so87353pwi.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 16:03:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is not complete and is intended to:
a) demonstrate the improvments
b) gather suggestions


Signed-off-by: Chetan Loke <lokec@ccs.neu.edu>

-----------------------
 include/linux/if_packet.h |   27 ++
 net/packet/af_packet.c    |  637 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 632 insertions(+), 32 deletions(-)

-----------------------

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 72bfa5a..1452f47 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -55,6 +55,17 @@ struct tpacket_stats {
 	unsigned int	tp_drops;
 };

+struct tpacket_stats_v3 {
+	unsigned int	tp_packets;
+	unsigned int	tp_drops;
+	unsigned int	tp_plug_q_cnt;
+};
+
+union tpacket_stats_u {
+	struct tpacket_stats stats1;
+	struct tpacket_stats_v3 stats3;
+};
+
 struct tpacket_auxdata {
 	__u32		tp_status;
 	__u32		tp_len;
@@ -102,11 +113,27 @@ struct tpacket2_hdr {
 	__u16		tp_vlan_tci;
 };

+
+struct tpacket3_hdr {
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+	__u32		tp_sec;
+	__u32		tp_nsec;
+	__u16		tp_vlan_tci;
+	long		tp_next_offset;
+};
+
 #define TPACKET2_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket2_hdr))
+ sizeof(struct sockaddr_ll))

+#define TPACKET3_HDRLEN		(TPACKET_ALIGN(sizeof(struct tpacket3_hdr))
+ sizeof(struct sockaddr_ll))
+
 enum tpacket_versions {
 	TPACKET_V1,
 	TPACKET_V2,
+	TPACKET_V3
 };

 /*
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91cb1d7..8e0bc51 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -164,6 +164,57 @@ struct packet_mreq_max {
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);

+
+#define V3_ALIGNMENT	(4)
+#define ALIGN_4(x)		(((x)+V3_ALIGNMENT-1)&~(V3_ALIGNMENT-1))
+
+
+struct bd_ts{
+	unsigned int ts_sec;
+	union {
+		unsigned int u1_i1[1];
+		struct {
+			unsigned int ts_usec;
+		}ts_s1;
+		struct {
+			unsigned int ts_nsec;
+		}ts_s2;
+	} ts_u1;
+}__attribute__ ((__packed__));
+
+struct  block_desc{
+	uint32_t		block_status;
+	uint32_t		num_pkts;
+	struct bd_ts	ts_first_pkt;
+	struct bd_ts	ts_last_pkt;
+	long			offset_to_first_pkt;
+	uint32_t		seq_num;
+} __attribute__ ((__packed__));
+
+struct kbdq_core{
+	struct pgv		*pkbdq;
+	unsigned int	hdrlen;
+	unsigned char	reset_pending_on_curr_blk;
+	unsigned char   delete_blk_timer;
+	unsigned short	kactive_blk_num;
+	unsigned short	hole_bytes_size;
+	char			*pkblk_start;
+	char			*pkblk_end;
+	int				kblk_size;
+	unsigned int	knum_blocks;
+	unsigned int	knxt_seq_num;
+	char			*prev;
+	char			*nxt_offset;
+	/* last_kactive_blk_num:
+	 * trick to see if user-space has caught up
+	 * in order to avoid refreshing timer when every single pkt arrives.
+	 */
+	unsigned short	last_kactive_blk_num;
+#define DEFAULT_PRB_RETIRE_TMO	(4)
+	unsigned short  retire_blk_tmo;
+	struct timer_list retire_blk_timer;
+};
+
 #define PGV_FROM_VMALLOC 1
 struct pgv {
 	char *buffer;
@@ -179,11 +230,16 @@ struct packet_ring_buffer {
 	unsigned int		pg_vec_order;
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
-
+	struct kbdq_core			prb_bdqc;
 	atomic_t		pending;
 };

 struct packet_sock;
+
+static void prb_open_block(struct kbdq_core *pkc1,struct block_desc *pbd1);
+static void prb_retire_rx_blk_timer_expired(unsigned long data);
+static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *pkc);
+static void prb_init_blk_timer(struct packet_sock *po,struct
kbdq_core *pkc,void (*func) (unsigned long));
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);

 static void packet_flush_mclist(struct sock *sk);
@@ -192,6 +248,7 @@ struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
 	struct tpacket_stats	stats;
+	union  tpacket_stats_u	stats_u;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
 	int			copy_thresh;
@@ -223,7 +280,14 @@ struct packet_skb_cb {

 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))

-static inline __pure struct page *pgv_to_page(void *addr)
+#define GET_PBDQC_FROM_RB(x)				((struct kbdq_core *)(&(x)->prb_bdqc))
+#define GET_CURR_PBLOCK_DESC_FROM_CORE(x)	((struct block_desc
*)((x)->pkbdq[(x)->kactive_blk_num].buffer))
+#define GET_PBLOCK_DESC(x,bid)				((struct block_desc
*)((x)->pkbdq[(bid)].buffer))
+
+#define INCREMENT_PRB_BLK_NUM(x) \
+	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? ((x)->kactive_blk_num+1) : 0)
+
+static inline struct page *pgv_to_page(void *addr)
 {
 	if (is_vmalloc_addr(addr))
 		return vmalloc_to_page(addr);
@@ -248,8 +312,12 @@ static void __packet_set_status(struct
packet_sock *po, void *frame, int status)
 		h.h2->tp_status = status;
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		break;
+	case TPACKET_V3:
+		pr_err("<%s> TPACKET version not supported.Who is calling?.Dumping
stack.\n",__func__);
+		dump_stack();
+		break;
 	default:
-		pr_err("TPACKET version not supported\n");
+		pr_err("<%s> TPACKET version not supported\n",__func__);
 		BUG();
 	}

@@ -274,6 +342,10 @@ static int __packet_get_status(struct packet_sock
*po, void *frame)
 	case TPACKET_V2:
 		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
 		return h.h2->tp_status;
+	case TPACKET_V3:
+		pr_err("<%s> TPACKET version:%d not supported.Dumping
stack.\n",__func__,po->tp_version);
+		dump_stack();
+		return 0;
 	default:
 		pr_err("TPACKET version not supported\n");
 		BUG();
@@ -309,9 +381,234 @@ static inline void *packet_current_frame(struct
packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status)
 {
-	return packet_lookup_frame(po, rb, rb->head, status);
+	switch (po->tp_version) {
+		case TPACKET_V1:
+		case TPACKET_V2:
+			return packet_lookup_frame(po, rb, rb->head, status);
+		case TPACKET_V3:
+			pr_err("<%s> TPACKET version:%d not supported.Dumping
stack.\n",__func__,po->tp_version);
+			dump_stack();
+			return 0;
+		default:
+			pr_err("<%s> TPACKET version not supported\n",__func__);
+			BUG();
+			return 0;
+	}
+}
+
+static void prb_flush_block(struct block_desc *pbd1)
+{
+	flush_dcache_page(pgv_to_page(pbd1));
+}
+
+/* Side effect:
+ * 1)flush the block-header
+ * 2)Increment active_blk_num
+ */
+static void prb_close_block(struct kbdq_core *pkc1,struct block_desc *pbd1)
+{
+	
+	//long size = pkc1->pkblk_end - pkc1->nxt_offset;
+	pbd1->block_status = TP_STATUS_USER;
+
+	/* Get the ts of the last pkt */
+	if (pbd1->num_pkts) {
+		struct tpacket3_hdr *ph = (struct tpacket3_hdr *)pkc1->prev;
+		pbd1->ts_last_pkt.ts_sec		= ph->tp_sec;
+		pbd1->ts_last_pkt.ts_s2.ts_nsec	= ph->tp_nsec;
+	} else {
+		/* Ok, we tmo'd - so get the current time */
+		struct timespec ts;
+		getnstimeofday(&ts);
+		pbd1->ts_last_pkt.ts_sec		= ts.tp_sec;
+		pbd1->ts_last_pkt.ts_s2.ts_nsec	= ts.tp_nsec;
+	}
+
+	prb_flush_block(pbd1);
+	pkc1->kactive_blk_num = INCREMENT_PRB_BLK_NUM(pkc1);
+}
+
+static inline void prb_unplug_queue(struct kbdq_core *pkc) {
+	pkc->reset_pending_on_curr_blk=0;
+}
+
+/* Side effect of opening a block:
+ * 1) prb_queue is unplugged.
+ * 2) retire_blk_timer is refreshed.
+ */
+static void prb_open_block(struct kbdq_core *pkc1,struct block_desc *pbd1)
+{
+	struct timespec ts;
+
+	pbd1->block_status	= TP_STATUS_KERNEL;
+	getnstimeofday(&ts);
+	pbd1->num_pkts		= 0;
+	pbd1->ts_first_pkt.ts_sec				= ts.tv_sec;
+	pbd1->ts_first_pkt.ts_u1.ts_s2.ts_nsec	= ts.tv_nsec;
+	pkc1->pkblk_start	= (char *)pbd1;
+	pbd1->seq_num		= pkc1->knxt_seq_num++;
+	pkc1->nxt_offset	= (char *)(pkc1->pkblk_start + sizeof(struct block_desc));
+	
+	pbd1->offset_to_first_pkt    = (long)sizeof(struct block_desc);
+
+	pkc1->prev			= pkc1->nxt_offset;
+	pkc1->pkblk_end		= pkc1->pkblk_start + pkc1->kblk_size;
+
+	prb_unplug_queue(pkc1);
+	_prb_refresh_rx_retire_blk_timer(pkc1);
+}
+
+static inline void prb_plug_queue(struct kbdq_core *pkc,struct
packet_sock *po) {
+	pkc->reset_pending_on_curr_blk=1;
+	po->stats_u.stats3.tp_plug_q_cnt++;
+}
+
+static void *prb_try_next_block(struct kbdq_core *pkc,struct packet_sock *po)
+{
+	struct block_desc *pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+
+	/* close current block */
+	if (likely(TP_STATUS_KERNEL == pbd->block_status)) {
+		prb_close_block(pkc,pbd);
+	} else {
+		printk("<%s> ERROR - pbd[%d]:%p\n",__func__,pkc->kactive_blk_num,pbd);
+		BUG();
+	}
+
+	/* Get the next block num */
+	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+	
+	smp_mb();
+	
+	/* If the curr_block is currently in_use then plug the queue */
+	if (TP_STATUS_USER == pbd->block_status) {
+		    prb_plug_queue(pkc,po);
+			return NULL;
+	}
+	/* open next block */
+	prb_open_block(pkc,pbd);
+	return (void *)pkc->nxt_offset;
+}
+
+#define TOTAL_PKT_LEN_INCL_ALIGN(length) (ALIGN_4((length)))
+
+static void prb_fill_curr_block(char *curr,struct kbdq_core
*pkc,struct block_desc *pbd,unsigned int len)
+{
+	struct tpacket3_hdr *ppd;
+	struct tpacket3_hdr *prev;
+
+	ppd  = (struct tpacket3_hdr *)curr;
+	prev = (struct tpacket3_hdr *)pkc->prev;
+	/* lets do pd_s1 for for V4 header */
+	//ppd->pd_u1.pd_s1.nxt_offset = 0;
+	//((struct tpacket3_hdr *)pkc->prev)->pd_u1.pd_s1.next_offset =
(char *)ppd - pkc->prev;
+	ppd->tp_next_offset = 0;
+	if (pkc->prev > (char *)ppd) {
+		printk("<%s> curr:0x%p len:%d pkc->prev:%p \n",__func__,curr,len,pkc->prev);
+		BUG();
+	}
+	prev->tp_next_offset = (long)ppd - (long)pkc->prev;
+	pkc->prev = curr;
+	pkc->nxt_offset += TOTAL_PKT_LEN_INCL_ALIGN(len);
+	pbd->num_pkts += 1;
+}
+
+static inline int prb_curr_blk_in_use(struct kbdq_core *pkc,struct
block_desc *pbd) {
+
+	return (TP_STATUS_USER == pbd->block_status);
+}
+
+static inline int prb_queue_plugged(struct kbdq_core *pkc) {
+	return pkc->reset_pending_on_curr_blk;
+}
+
+/* Assumes caller has the sk->rx_queue.lock */
+static void *__packet_lookup_frame_in_block(struct packet_ring_buffer *rb,
+		int status,unsigned int len,struct packet_sock *po)
+{
+	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	struct block_desc *pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+	char *curr, *end;
+	
+	if (prb_queue_plugged(pkc)) {
+		if (prb_curr_blk_in_use(pkc,pbd)) {
+			return NULL;
+		} else {
+			/* open-block unplugs the queue. Unplugging is a side effect */
+			prb_open_block(pkc,pbd);
+		}
+	}
+
+	smp_mb();
+
+	curr = pkc->nxt_offset;
+	end  = (char *) ( (char *)pbd + pkc->kblk_size);
+	
+	/* first try the current block */
+	if (curr+TOTAL_PKT_LEN_INCL_ALIGN(len) < end) {
+		prb_fill_curr_block(curr,pkc,pbd,len);
+		return (void *)curr;
+	}
+	
+	/* Then try the next block. */
+	if ((curr = (char *)prb_try_next_block(pkc,po))) {
+		pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+		prb_fill_curr_block(curr,pkc,pbd,len);
+		return (void *)curr;
+	}
+
+	/* no free blocks are available - user_space hasn't caught up yet */
+	return NULL;
+}
+
+static inline void *packet_current_rx_frame(struct packet_sock *po,
+		struct packet_ring_buffer *rb,
+		int status, unsigned int len)
+{
+	char *curr=NULL;
+	switch (po->tp_version) {
+		case TPACKET_V1:
+		case TPACKET_V2:
+			curr = packet_lookup_frame(po, rb, rb->head, status);
+			return curr;
+		case TPACKET_V3:
+			return __packet_lookup_frame_in_block(rb, status,len,po);
+		default:
+			pr_err("<%s> TPACKET version:%d not supported\n",__func__,po->tp_version);
+			BUG();
+			return 0;
+	}
+}
+
+static inline void *prb_lookup_block(struct packet_sock *po,
+		struct packet_ring_buffer *rb,unsigned int previous,
+		int status)
+{
+	struct kbdq_core *pkc  = GET_PBDQC_FROM_RB(rb);
+	struct block_desc *pbd = GET_PBLOCK_DESC(pkc,previous);
+
+	if (status != pbd->block_status)
+		return NULL;
+	return pbd;
+}
+
+static inline int prb_previous_blk_num(struct packet_ring_buffer *rb)
+{
+	unsigned int prev = rb->prb_bdqc.kactive_blk_num ?
(rb->prb_bdqc.kactive_blk_num-1) : (rb->prb_bdqc.knum_blocks-1);
+	return prev;
+}
+
+/* Assumes caller has held the rx_queue.lock */
+static inline void* __prb_previous_block(struct packet_sock *po,
+		struct packet_ring_buffer *rb,
+		int status)
+{
+
+	unsigned int previous = prb_previous_blk_num(rb);
+	return prb_lookup_block(po,rb,previous,status);
 }

+
 static inline void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status)
@@ -320,11 +617,38 @@ static inline void *packet_previous_frame(struct
packet_sock *po,
 	return packet_lookup_frame(po, rb, previous, status);
 }

+static inline void *packet_previous_rx_frame(struct packet_sock *po,
+		struct packet_ring_buffer *rb,
+		int status)
+{
+	if (po->tp_version <= TPACKET_V2)
+		return packet_previous_frame(po,rb,status);
+	
+	return __prb_previous_block(po,rb,status);
+}
+
 static inline void packet_increment_head(struct packet_ring_buffer *buff)
 {
 	buff->head = buff->head != buff->frame_max ? buff->head+1 : 0;
 }

+static inline void packet_increment_rx_head(struct packet_sock
*po,struct packet_ring_buffer *rb)
+{
+	switch (po->tp_version) {
+		case TPACKET_V1:
+		case TPACKET_V2:
+			return packet_increment_head(rb);
+		case TPACKET_V3:
+			pr_err("<%s> TPACKET version:%d not supported.Dumping
stack.\n",__func__,po->tp_version);
+			dump_stack();
+			return;
+		default:
+			pr_err("<%s> TPACKET version not supported\n",__func__);
+			BUG();
+			return;
+	}
+}
+
 static inline struct packet_sock *pkt_sk(struct sock *sk)
 {
 	return (struct packet_sock *)sk;
@@ -663,6 +987,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct
net_device *dev,
 	union {
 		struct tpacket_hdr *h1;
 		struct tpacket2_hdr *h2;
+		struct tpacket3_hdr *h3;
 		void *raw;
 	} h;
 	u8 *skb_head = skb->data;
@@ -715,29 +1040,31 @@ static int tpacket_rcv(struct sk_buff *skb,
struct net_device *dev,
 		macoff = netoff - maclen;
 	}

-	if (macoff + snaplen > po->rx_ring.frame_size) {
-		if (po->copy_thresh &&
-		    atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
-		    (unsigned)sk->sk_rcvbuf) {
-			if (skb_shared(skb)) {
-				copy_skb = skb_clone(skb, GFP_ATOMIC);
-			} else {
-				copy_skb = skb_get(skb);
-				skb_head = skb->data;
+	if (po->tp_version <= TPACKET_V2) {
+		if (macoff + snaplen > po->rx_ring.frame_size) {
+			if (po->copy_thresh &&
+				atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
+				(unsigned)sk->sk_rcvbuf) {
+				if (skb_shared(skb)) {
+					copy_skb = skb_clone(skb, GFP_ATOMIC);
+				} else {
+					copy_skb = skb_get(skb);
+					skb_head = skb->data;
+				}
+				if (copy_skb)
+					skb_set_owner_r(copy_skb, sk);
 			}
-			if (copy_skb)
-				skb_set_owner_r(copy_skb, sk);
+			snaplen = po->rx_ring.frame_size - macoff;
+			if ((int)snaplen < 0)
+				snaplen = 0;
 		}
-		snaplen = po->rx_ring.frame_size - macoff;
-		if ((int)snaplen < 0)
-			snaplen = 0;
 	}
-
 	spin_lock(&sk->sk_receive_queue.lock);
-	h.raw = packet_current_frame(po, &po->rx_ring, TP_STATUS_KERNEL);
+	h.raw = packet_current_rx_frame(po, &po->rx_ring,
TP_STATUS_KERNEL,(macoff+snaplen));
 	if (!h.raw)
 		goto ring_is_full;
-	packet_increment_head(&po->rx_ring);
+	if (TPACKET_V3 != po->tp_version)
+		packet_increment_rx_head(po,&po->rx_ring);
 	po->stats.tp_packets++;
 	if (copy_skb) {
 		status |= TP_STATUS_COPY;
@@ -789,6 +1116,21 @@ static int tpacket_rcv(struct sk_buff *skb,
struct net_device *dev,
 		h.h2->tp_vlan_tci = vlan_tx_tag_get(skb);
 		hdrlen = sizeof(*h.h2);
 		break;
+	case TPACKET_V3:
+		/* tp_nxt_offset is already populated above. So DONT clear those
fields here */
+		h.h3->tp_len = skb->len;
+		h.h3->tp_snaplen = snaplen;
+		h.h3->tp_mac = macoff;
+		h.h3->tp_net = netoff;
+		if (skb->tstamp.tv64)
+			ts = ktime_to_timespec(skb->tstamp);
+		else
+			getnstimeofday(&ts);
+		h.h3->tp_sec  = ts.tv_sec;
+		h.h3->tp_nsec = ts.tv_nsec;
+		h.h3->tp_vlan_tci = vlan_tx_tag_get(skb);
+		hdrlen = sizeof(*h.h3);
+		break;	
 	default:
 		BUG();
 	}
@@ -804,7 +1146,8 @@ static int tpacket_rcv(struct sk_buff *skb,
struct net_device *dev,
 	else
 		sll->sll_ifindex = dev->ifindex;

-	__packet_set_status(po, h.raw, status);
+	if (po->tp_version <= TPACKET_V2)
+		__packet_set_status(po, h.raw, status);
 	smp_mb();
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
 	{
@@ -815,7 +1158,6 @@ static int tpacket_rcv(struct sk_buff *skb,
struct net_device *dev,
 			flush_dcache_page(pgv_to_page(start));
 	}
 #endif
-
 	sk->sk_data_ready(sk, 0);

 drop_n_restore:
@@ -1984,6 +2326,7 @@ packet_setsockopt(struct socket *sock, int
level, int optname, char __user *optv
 		switch (val) {
 		case TPACKET_V1:
 		case TPACKET_V2:
+		case TPACKET_V3:
 			po->tp_version = val;
 			return 0;
 		default:
@@ -2082,6 +2425,7 @@ static int packet_getsockopt(struct socket
*sock, int level, int optname,
 	struct packet_sock *po = pkt_sk(sk);
 	void *data;
 	struct tpacket_stats st;
+	union tpacket_stats_u st_u;

 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -2094,15 +2438,25 @@ static int packet_getsockopt(struct socket
*sock, int level, int optname,

 	switch (optname) {
 	case PACKET_STATISTICS:
-		if (len > sizeof(struct tpacket_stats))
-			len = sizeof(struct tpacket_stats);
+		if (po->tp_version == TPACKET_V3) {
+			len = sizeof(struct tpacket_stats_v3);
+		} else {
+			if (len > sizeof(struct tpacket_stats))
+				len = sizeof(struct tpacket_stats);
+		}
 		spin_lock_bh(&sk->sk_receive_queue.lock);
-		st = po->stats;
+		if (po->tp_version == TPACKET_V3) {
+			memcpy(&st_u.stats3,&po->stats,sizeof(struct tpacket_stats));
+			st_u.stats3.tp_plug_q_cnt  = po->stats_u.stats3.tp_plug_q_cnt;
+			st_u.stats3.tp_packets += po->stats.tp_drops;
+			data = &st_u.stats3;
+		} else {
+			st = po->stats;
+			st.tp_packets += st.tp_drops;
+			data = &st;
+		}
 		memset(&po->stats, 0, sizeof(st));
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
-		st.tp_packets += st.tp_drops;
-
-		data = &st;
 		break;
 	case PACKET_AUXDATA:
 		if (len > sizeof(int))
@@ -2143,6 +2497,9 @@ static int packet_getsockopt(struct socket
*sock, int level, int optname,
 		case TPACKET_V2:
 			val = sizeof(struct tpacket2_hdr);
 			break;
+		case TPACKET_V3:
+			val = sizeof(struct tpacket3_hdr);
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -2293,7 +2650,7 @@ static unsigned int packet_poll(struct file
*file, struct socket *sock,

 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (po->rx_ring.pg_vec) {
-		if (!packet_previous_frame(po, &po->rx_ring, TP_STATUS_KERNEL))
+		if (!packet_previous_rx_frame(po, &po->rx_ring, TP_STATUS_KERNEL))
 			mask |= POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
@@ -2396,7 +2753,6 @@ static struct pgv *alloc_pg_vec(struct
tpacket_req *req, int order)
 	pg_vec = kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);
 	if (unlikely(!pg_vec))
 		goto out;
-
 	for (i = 0; i < block_nr; i++) {
 		pg_vec[i].buffer = alloc_one_pg_vec_page(order);
 		if (unlikely(!pg_vec[i].buffer))
@@ -2412,6 +2768,197 @@ out_free_pgvec:
 	goto out;
 }

+
+static void prb_del_retire_blk_timer(struct kbdq_core *pkc)
+{
+	del_timer_sync(&pkc->retire_blk_timer);
+}
+
+static void prb_shutdown_retire_blk_timer(struct packet_sock *po, int
tx_ring,struct sk_buff_head *rb_queue)
+{
+	struct kbdq_core *pkc;
+
+	pkc	= tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	
+	spin_lock(&rb_queue->lock);
+	pkc->delete_blk_timer=1;
+	spin_unlock(&rb_queue->lock);
+
+	prb_del_retire_blk_timer(pkc);
+}
+
+/*  Increment the blk_num and then invoke this func to refresh the timer.
+ *  We do it in this order so that if a timer is about
+ *  to fire then it will fail the blk_num check.
+ *  Assumes sk_buff_head lock is held.
+ */
+static void _prb_refresh_rx_retire_blk_timer(struct kbdq_core *pkc)
+{
+	pkc->last_kactive_blk_num = pkc->kactive_blk_num;
+	mod_timer(&pkc->retire_blk_timer,jiffies+msecs_to_jiffies(pkc->retire_blk_tmo));
+}
+
+/* close current block and open next block or plug the queue */
+static inline void prb_retire_curr_block(struct kbdq_core *pkc,struct
packet_sock *po)
+{
+	prb_try_next_block(pkc,po);
+}
+
+/*
+ * Timer logic:
+ * 1) We refresh the timer only when we open a block.
+ *    By doing this we don't waste cycles refreshing the timer
+ *    on packet-by-packet basis.
+ * With a 1MB block-size, on a 1Gbps line, it will take
+ * ~8 ms to fill a block.
+ * So, if the user sets the 'tmo' to 10ms then the timer will never
fire(which is what we want)!
+ * However, the user could choose to close a block early and that's fine.
+ *
+ * But when the timer does fire, we check whether or not to refresh it.
+ * Since the tmo granularity is in msecs, it is not too expensive
+ * to refresh the timer every '8' msecs.
+ * Either the user can set the 'tmo' or we can derive it based on
+ * a) line-speed and b) block-size
+ */
+static void prb_retire_rx_blk_timer_expired(unsigned long data)
+{
+	struct packet_sock *po = (struct packet_sock *)data;
+	struct kbdq_core *pkc = &po->rx_ring.prb_bdqc;
+	unsigned short tmo;
+	unsigned int plugged;
+	struct block_desc *pbd;
+
+	spin_lock(&po->sk.sk_receive_queue.lock);
+
+	plugged = prb_queue_plugged(pkc);
+	pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
+
+	/* We read the tmo so that user-space can change it anytime they want.
+	 * But, the changes will get into affect only when:
+	 * i) Either when the timer expires(this code path) or
+	 * ii)When a new block is opened.
+	 */
+	tmo = pkc->retire_blk_tmo;
+	if (pkc->last_kactive_blk_num == pkc->kactive_blk_num &&
+		!plugged) {
+		if (TP_STATUS_KERNEL == pbd->block_status) {
+			prb_retire_curr_block(pkc,po);
+		}
+	}
+	pkc->last_kactive_blk_num = pkc->kactive_blk_num;
+	
+	if (pkc->delete_blk_timer)
+		goto out;
+
+	if (plugged) {
+		/* Case 1. queue was plugged because user-space was lagging behind */
+		if (prb_curr_blk_in_use(pkc,pbd)) {
+			/* Ok, user-space is still behind. But we still want to refresh the timer */
+			/* if-check added for code readability */
+		} else {
+			/* Case 2. queue was plugged, user-space caught up and now the
link went idle && the timer fired.
+			 * We don't have a block to close and we cannot close the current
block because
+			 * the timer wasn't really meant for this block. So we just open
this block and restart the timer.
+			 * open-block unplugs the queue, restarts timer.
Unplugging/refreshing-timer is a side effect.
+			 */
+			prb_open_block(pkc,pbd);
+			goto out;
+		}
+	}
+
+	mod_timer(&pkc->retire_blk_timer,jiffies+msecs_to_jiffies(tmo));
+
+out:
+	spin_unlock(&po->sk.sk_receive_queue.lock);
+}
+
+static void prb_init_blk_timer(struct packet_sock *po,struct
kbdq_core *pkc,void (*func) (unsigned long))
+{
+
+	init_timer(&pkc->retire_blk_timer);
+	pkc->retire_blk_timer.data		= (long)po;
+	pkc->retire_blk_timer.function	= func;
+	pkc->retire_blk_timer.expires	= jiffies;
+}
+
+static void prb_setup_retire_blk_timer(struct packet_sock *po,int tx_ring)
+{
+	struct kbdq_core *pkc;
+
+	if (tx_ring)
+		BUG();
+
+	pkc	 = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	prb_init_blk_timer(po,pkc,prb_retire_rx_blk_timer_expired);
+}
+
+static int prb_calc_retire_blk_tmo(struct packet_sock *po, int
blk_size_in_bytes)
+{
+	struct net_device *dev;
+	unsigned int mbits=0,msec=0,div=0,tmo=0;
+
+	dev = dev_get_by_index(sock_net(&po->sk), po->ifindex);
+	if (unlikely(dev == NULL)) {
+		return DEFAULT_PRB_RETIRE_TMO;
+	}
+
+    if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
+		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
+
+        if (!dev->ethtool_ops->get_settings(dev, &ecmd)) {
+			switch(ecmd.speed) {
+				case SPEED_10000:
+					msec = 1;
+					div=10000/1000;
+					break;
+                case SPEED_1000:
+                    msec = 1;
+					div = 1000/1000;
+					break;
+                /* If the link speed is so low you don't really need
to care about perf anyways */
+				case SPEED_100:
+				case SPEED_10:
+				default:
+					return DEFAULT_PRB_RETIRE_TMO;
+            }
+        }
+    }
+
+	mbits = (blk_size_in_bytes * 8) / (1024 * 1024);
+
+	if (div)
+		mbits /= div;
+
+	tmo = mbits * msec;
+
+	if (div)
+		return (tmo+1);
+	return tmo;
+}
+
+static void init_prb_bdqc(struct packet_sock *po,struct
packet_ring_buffer *rb,struct pgv *pg_vec,struct tpacket_req *req,int
tx_ring)
+{
+
+	struct kbdq_core *p1 = &rb->prb_bdqc;
+	struct block_desc *pbd;
+
+	memset(p1,0x0,sizeof(*p1));
+	p1->pkbdq			= pg_vec;
+	pbd					= (struct block_desc *)pg_vec[0].buffer;
+	p1->pkblk_start		= (char *)pg_vec[0].buffer;
+	
+	p1->kblk_size		= req->tp_block_size;
+	p1->knum_blocks		= req->tp_block_nr;
+	p1->hdrlen			= po->tp_hdrlen;
+	
+	p1->last_kactive_blk_num = 0;
+	po->stats_u.stats3.tp_plug_q_cnt = 0;
+	p1->retire_blk_tmo = prb_calc_retire_blk_tmo(po,req->tp_block_size);
+
+	prb_setup_retire_blk_timer(po,tx_ring);
+	prb_open_block(p1,pbd);
+}
+
 static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring)
 {
@@ -2421,7 +2968,14 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req,
 	struct packet_ring_buffer *rb;
 	struct sk_buff_head *rb_queue;
 	__be16 num;
-	int err;
+	int err=-EINVAL;
+
+	/* Opening a Tx-ring is NOT supported post TPACKET_V2 */
+	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
+		pr_err("<%s> Tx-ring is not supported on version:%d.Dumping
stack.\n",__func__,po->tp_version);
+		dump_stack();
+		goto out;
+	}

 	rb = tx_ring ? &po->tx_ring : &po->rx_ring;
 	rb_queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
@@ -2447,6 +3001,9 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req,
 		case TPACKET_V2:
 			po->tp_hdrlen = TPACKET2_HDRLEN;
 			break;
+		case TPACKET_V3:
+			po->tp_hdrlen = TPACKET3_HDRLEN;
+			break;
 		}

 		err = -EINVAL;
@@ -2472,6 +3029,15 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req,
 		pg_vec = alloc_pg_vec(req, order);
 		if (unlikely(!pg_vec))
 			goto out;
+		switch (po->tp_version) {
+			case TPACKET_V3:
+				/* Transmit path is not supported. We checked it above but just
being paranoid */
+				if (!tx_ring)
+					init_prb_bdqc(po,rb,pg_vec,req,tx_ring);
+				break;
+			default:
+				break;
+		}
 	}
 	/* Done */
 	else {
@@ -2529,10 +3095,17 @@ static int packet_set_ring(struct sock *sk,
struct tpacket_req *req,
 	}
 	spin_unlock(&po->bind_lock);

+	if (closing && (po->tp_version > TPACKET_V2)) {
+		/* Because we don't support block-based V3 on tx-ring */
+		if (!tx_ring)	
+			prb_shutdown_retire_blk_timer(po,tx_ring,rb_queue);
+	}
+
 	release_sock(sk);

 	if (pg_vec)
 		free_pg_vec(pg_vec, order, req->tp_block_nr);
+	
 out:
 	return err;
 }
