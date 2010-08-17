From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next-2.6] net: simplify flags for tx timestamping
Date: Tue, 17 Aug 2010 20:59:14 +0200
Message-ID: <4C6ADC02.5000305@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:56249 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763337Ab0HQS7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 14:59:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the abstraction introduced by the union skb_shared_tx in
the shared skb data.

The access of the different union elements at several places led to some
confusion about accessing the shared tx_flags e.g. in skb_orphan_try().

    http://marc.info/?l=linux-netdev&m=128084897415886&w=2

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index e8c8f4f..782d1fa 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -172,15 +172,19 @@ struct skb_shared_hwtstamps {
 };
 
 Time stamps for outgoing packets are to be generated as follows:
-- In hard_start_xmit(), check if skb_tx(skb)->hardware is set no-zero.
-  If yes, then the driver is expected to do hardware time stamping.
+- In hard_start_xmit(), check if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
+  is set no-zero. If yes, then the driver is expected to do hardware time
+  stamping.
 - If this is possible for the skb and requested, then declare
-  that the driver is doing the time stamping by setting the field
-  skb_tx(skb)->in_progress non-zero. You might want to keep a pointer
-  to the associated skb for the next step and not free the skb. A driver
-  not supporting hardware time stamping doesn't do that. A driver must
-  never touch sk_buff::tstamp! It is used to store software generated
-  time stamps by the network subsystem.
+  that the driver is doing the time stamping by setting the flag 
+  SKBTX_IN_PROGRESS in skb_shinfo(skb)->tx_flags , e.g. with
+ 
+      skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+
+  You might want to keep a pointer to the associated skb for the next step
+  and not free the skb. A driver not supporting hardware time stamping doesn't
+  do that. A driver must never touch sk_buff::tstamp! It is used to store
+  software generated time stamps by the network subsystem.
 - As soon as the driver has sent the packet and/or obtained a
   hardware time stamp for it, it passes the time stamp back by
   calling skb_hwtstamp_tx() with the original skb, the raw
@@ -191,6 +195,6 @@ Time stamps for outgoing packets are to be generated as follows:
   this would occur at a later time in the processing pipeline than other
   software time stamping and therefore could lead to unexpected deltas
   between time stamps.
-- If the driver did not call set skb_tx(skb)->in_progress, then
+- If the driver did not set the SKBTX_IN_PROGRESS flag (see above), then
   dev_hard_start_xmit() checks whether software time stamping
   is wanted as fallback and potentially generates the time stamp.
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 012613f..7a0e415 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -803,15 +803,14 @@ static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts, struct timecompa
 static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 {
 	struct bfin_mac_local *lp = netdev_priv(netdev);
-	union skb_shared_tx *shtx = skb_tx(skb);
 
-	if (shtx->hardware) {
+	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
 		int timeout_cnt = MAX_TIMEOUT_CNT;
 
 		/* When doing time stamping, keep the connection to the socket
 		 * a while longer
 		 */
-		shtx->in_progress = 1;
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 		/*
 		 * The timestamping is done at the EMAC module's MII/RMII interface
@@ -991,7 +990,6 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	u16 *data;
 	u32 data_align = (unsigned long)(skb->data) & 0x3;
-	union skb_shared_tx *shtx = skb_tx(skb);
 
 	current_tx_ptr->skb = skb;
 
@@ -1005,7 +1003,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		 * of this field are the length of the packet payload in bytes and the higher
 		 * 4 bits are the timestamping enable field.
 		 */
-		if (shtx->hardware)
+		if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
 			*data |= 0x1000;
 
 		current_tx_ptr->desc_a.start_addr = (u32)data;
@@ -1015,7 +1013,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	} else {
 		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
 		/* enable timestamping for the sent packet */
-		if (shtx->hardware)
+		if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
 			*((u16 *)(current_tx_ptr->packet)) |= 0x1000;
 		memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
 			skb->len);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3d9f958..e6048d6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2048,7 +2048,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 bufaddr;
 	unsigned long flags;
 	unsigned int nr_frags, nr_txbds, length;
-	union skb_shared_tx *shtx;
 
 	/*
 	 * TOE=1 frames larger than 2500 bytes may see excess delays
@@ -2069,10 +2068,10 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq = netdev_get_tx_queue(dev, rq);
 	base = tx_queue->tx_bd_base;
 	regs = tx_queue->grp->regs;
-	shtx = skb_tx(skb);
 
 	/* check if time stamp should be generated */
-	if (unlikely(shtx->hardware && priv->hwts_tx_en))
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
+		     priv->hwts_tx_en))
 		do_tstamp = 1;
 
 	/* make space for additional header when fcb is needed */
@@ -2174,7 +2173,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Setup tx hardware time stamping if requested */
 	if (unlikely(do_tstamp)) {
-		shtx->in_progress = 1;
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		if (fcb == NULL)
 			fcb = gfar_add_fcb(skb);
 		fcb->ptp = 1;
@@ -2446,7 +2445,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	int howmany = 0;
 	u32 lstatus;
 	size_t buflen;
-	union skb_shared_tx *shtx;
 
 	rx_queue = priv->rx_queue[tx_queue->qindex];
 	bdp = tx_queue->dirty_tx;
@@ -2461,8 +2459,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		 * When time stamping, one additional TxBD must be freed.
 		 * Also, we need to dma_unmap_single() the TxPAL.
 		 */
-		shtx = skb_tx(skb);
-		if (unlikely(shtx->in_progress))
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
 			nr_txbds = frags + 2;
 		else
 			nr_txbds = frags + 1;
@@ -2476,7 +2473,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 				(lstatus & BD_LENGTH_MASK))
 			break;
 
-		if (unlikely(shtx->in_progress)) {
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			next = next_txbd(bdp, base, tx_ring_size);
 			buflen = next->length + GMAC_FCB_LEN;
 		} else
@@ -2485,7 +2482,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
 				buflen, DMA_TO_DEVICE);
 
-		if (unlikely(shtx->in_progress)) {
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 6e63d9a..44e0ff1 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -143,7 +143,7 @@ struct igb_buffer {
 			u16 next_to_watch;
 			unsigned int bytecount;
 			u16 gso_segs;
-			union skb_shared_tx shtx;
+			u8 tx_flags;
 			u8 mapped_as_page;
 		};
 		/* RX */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 9b4e589..985e37c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3954,7 +3954,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	}
 
 	tx_ring->buffer_info[i].skb = skb;
-	tx_ring->buffer_info[i].shtx = skb_shinfo(skb)->tx_flags;
+	tx_ring->buffer_info[i].tx_flags = skb_shinfo(skb)->tx_flags;
 	/* multiply data chunks by size of headers */
 	tx_ring->buffer_info[i].bytecount = ((gso_segs - 1) * hlen) + skb->len;
 	tx_ring->buffer_info[i].gso_segs = gso_segs;
@@ -4088,7 +4088,6 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	u32 tx_flags = 0;
 	u16 first;
 	u8 hdr_len = 0;
-	union skb_shared_tx *shtx = skb_tx(skb);
 
 	/* need: 1 descriptor per page,
 	 *       + 2 desc gap to keep tail from touching head,
@@ -4100,8 +4099,8 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (unlikely(shtx->hardware)) {
-		shtx->in_progress = 1;
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IGB_TX_FLAGS_TSTAMP;
 	}
 
@@ -5319,7 +5318,7 @@ static void igb_tx_hwtstamp(struct igb_q_vector *q_vector, struct igb_buffer *bu
 	u64 regval;
 
 	/* if skb does not support hw timestamp or TX stamp not valid exit */
-	if (likely(!buffer_info->shtx.hardware) ||
+	if (likely(!(buffer_info->tx_flags & SKBTX_HW_TSTAMP)) ||
 	    !(rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID))
 		return;
 
@@ -5500,7 +5499,7 @@ static void igb_rx_hwtstamp(struct igb_q_vector *q_vector, u32 staterr,
 	 * values must belong to this one here and therefore we don't need to
 	 * compare any of the additional attributes stored for it.
 	 *
-	 * If nothing went wrong, then it should have a skb_shared_tx that we
+	 * If nothing went wrong, then it should have a shared tx_flags that we
 	 * can turn into a skb_shared_hwtstamps.
 	 */
 	if (staterr & E1000_RXDADV_STAT_TSIP) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d805038..f067c95 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -163,26 +163,19 @@ struct skb_shared_hwtstamps {
 	ktime_t	syststamp;
 };
 
-/**
- * struct skb_shared_tx - instructions for time stamping of outgoing packets
- * @hardware:		generate hardware time stamp
- * @software:		generate software time stamp
- * @in_progress:	device driver is going to provide
- *			hardware time stamp
- * @prevent_sk_orphan:	make sk reference available on driver level
- * @flags:		all shared_tx flags
- *
- * These flags are attached to packets as part of the
- * &skb_shared_info. Use skb_tx() to get a pointer.
- */
-union skb_shared_tx {
-	struct {
-		__u8	hardware:1,
-			software:1,
-			in_progress:1,
-			prevent_sk_orphan:1;
-	};
-	__u8 flags;
+/* Definitions for tx_flags in struct skb_shared_info */
+enum {
+	/* generate hardware time stamp */
+	SKBTX_HW_TSTAMP = 1 << 0,
+
+	/* generate software time stamp */
+	SKBTX_SW_TSTAMP = 1 << 1,
+
+	/* device driver is going to provide hardware time stamp */
+	SKBTX_IN_PROGRESS = 1 << 2,
+
+	/* ensure the originating sk reference is available on driver level */
+	SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
 };
 
 /* This data is invariant across clones and lives at
@@ -195,7 +188,7 @@ struct skb_shared_info {
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
-	union skb_shared_tx tx_flags;
+	__u8		tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 
@@ -587,11 +580,6 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
 	return &skb_shinfo(skb)->hwtstamps;
 }
 
-static inline union skb_shared_tx *skb_tx(struct sk_buff *skb)
-{
-	return &skb_shinfo(skb)->tx_flags;
-}
-
 /**
  *	skb_queue_empty - check if a queue is empty
  *	@list: queue head
@@ -1996,8 +1984,8 @@ extern void skb_tstamp_tx(struct sk_buff *orig_skb,
 
 static inline void sw_tx_timestamp(struct sk_buff *skb)
 {
-	union skb_shared_tx *shtx = skb_tx(skb);
-	if (shtx->software && !shtx->in_progress)
+	if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
+	    !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
 		skb_tstamp_tx(skb, NULL);
 }
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 890f972..7691aca 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -53,7 +53,7 @@ struct ipcm_cookie {
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
-	union skb_shared_tx	shtx;
+	__u8			tx_flags;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/include/net/sock.h b/include/net/sock.h
index ac53bfb..100e43b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1669,17 +1669,13 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 
 /**
  * sock_tx_timestamp - checks whether the outgoing packet is to be time stamped
- * @msg:	outgoing packet
  * @sk:		socket sending this packet
- * @shtx:	filled with instructions for time stamping
+ * @tx_flags:	filled with instructions for time stamping
  *
  * Currently only depends on SOCK_TIMESTAMPING* flags. Returns error code if
  * parameters are invalid.
  */
-extern int sock_tx_timestamp(struct msghdr *msg,
-			     struct sock *sk,
-			     union skb_shared_tx *shtx);
-
+extern int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
diff --git a/net/can/raw.c b/net/can/raw.c
index a10e333..7d77e67 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -647,12 +647,12 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
 		goto free_skb;
-	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 	if (err < 0)
 		goto free_skb;
 
 	/* to be able to check the received tx sock reference in raw_rcv() */
-	skb_tx(skb)->prevent_sk_orphan = 1;
+	skb_shinfo(skb)->tx_flags |= SKBTX_DRV_NEEDS_SK_REF;
 
 	skb->dev = dev;
 	skb->sk  = sk;
diff --git a/net/core/dev.c b/net/core/dev.c
index 586a11c..c1dc8a9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1902,14 +1902,14 @@ static int dev_gso_segment(struct sk_buff *skb)
 
 /*
  * Try to orphan skb early, right before transmission by the device.
- * We cannot orphan skb if tx timestamp is requested, since
- * drivers need to call skb_tstamp_tx() to send the timestamp.
+ * We cannot orphan skb if tx timestamp is requested or the sk-reference
+ * is needed on driver level for other reasons, e.g. see net/can/raw.c
  */
 static inline void skb_orphan_try(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
-	if (sk && !skb_tx(skb)->flags) {
+	if (sk && !skb_shinfo(skb)->tx_flags) {
 		/* skb_tx_hash() wont be able to get sk.
 		 * We copy sk_hash into skb->rxhash
 		 */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3a2513f..99ef721 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3016,7 +3016,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	} else {
 		/*
 		 * no hardware time stamps available,
-		 * so keep the skb_shared_tx and only
+		 * so keep the shared tx_flags and only
 		 * store software time stamp
 		 */
 		skb->tstamp = ktime_get_real();
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index a0d847c..96bc7f9 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -379,7 +379,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
-	ipc.shtx.flags = 0;
+	ipc.tx_flags = 0;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -538,7 +538,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
-	ipc.shtx.flags = 0;
+	ipc.tx_flags = 0;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 04b6989..e807492 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -953,7 +953,7 @@ alloc_new_skb:
 				else
 					/* only the initial fragment is
 					   time stamped */
-					ipc->shtx.flags = 0;
+					ipc->tx_flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -964,7 +964,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
-			*skb_tx(skb) = ipc->shtx;
+			skb_shinfo(skb)->tx_flags = ipc->tx_flags;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1384,7 +1384,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
-	ipc.shtx.flags = 0;
+	ipc.tx_flags = 0;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 009a7b2..1f85ef2 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -505,7 +505,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
-	ipc.shtx.flags = 0;
+	ipc.tx_flags = 0;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 32e0bef..86e757e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -797,7 +797,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
-	ipc.shtx.flags = 0;
+	ipc.tx_flags = 0;
 
 	if (up->pending) {
 		/*
@@ -845,7 +845,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->inet_saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
-	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
+	err = sock_tx_timestamp(sk, &ipc.tx_flags);
 	if (err)
 		return err;
 	if (msg->msg_controllen) {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9a17f28..3616f27 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -488,7 +488,7 @@ retry:
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 	if (err < 0)
 		goto out_unlock;
 
@@ -1209,7 +1209,7 @@ static int packet_snd(struct socket *sock,
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
-	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 	if (err < 0)
 		goto out_free;
 
diff --git a/net/socket.c b/net/socket.c
index 2270b94..7848d12 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -535,14 +535,13 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
-int sock_tx_timestamp(struct msghdr *msg, struct sock *sk,
-		      union skb_shared_tx *shtx)
+int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 {
-	shtx->flags = 0;
+	*tx_flags = 0;
 	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE))
-		shtx->hardware = 1;
+		*tx_flags |= SKBTX_HW_TSTAMP;
 	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
-		shtx->software = 1;
+		*tx_flags |= SKBTX_SW_TSTAMP;
 	return 0;
 }
 EXPORT_SYMBOL(sock_tx_timestamp);


