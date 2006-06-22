From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Thu, 22 Jun 2006 18:12:53 +1000
Message-ID: <20060622081253.GA22671@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12548 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932838AbWFVIM5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:12:57 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: Merge TSO/UFO fields in sk_buff

Having separate fields in sk_buff for TSO/UFO (tso_size/ufo_size) is not
going to scale if we add any more segmentation methods (e.g., DCCP).  So
let's merge them.

They were used to tell the protocol of a packet.  This function has been
subsumed by the new gso_type field.  This is essentially a set of netdev
feature bits (shifted by 16 bits) that are required to process a specific
skb.  As such it's easy to tell whether a given device can process a GSO
skb: you just have to and the gso_type field and the netdev's features
field.

I've made gso_type a conjunction.  The idea is that you have a base type
(e.g., SKB_GSO_TCPV4) that can be modified further to support new features.
For example, if we add a hardware TSO type that supports ECN, they would
declare NETIF_F_TSO | NETIF_F_TSO_ECN.  All TSO packets with CWR set would
have a gso_type of SKB_GSO_TCPV4 | SKB_GSO_TCPV4_ECN while all other TSO
packets would be SKB_GSO_TCPV4.  This means that only the CWR packets need
to be emulated in software.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -792,7 +792,7 @@ static int cp_start_xmit (struct sk_buff
 	entry = cp->tx_head;
 	eor = (entry == (CP_TX_RING_SIZE - 1)) ? RingEnd : 0;
 	if (dev->features & NETIF_F_TSO)
-		mss = skb_shinfo(skb)->tso_size;
+		mss = skb_shinfo(skb)->gso_size;
 
 	if (skb_shinfo(skb)->nr_frags == 0) {
 		struct cp_desc *txd = &cp->tx_ring[entry];
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1640,7 +1640,7 @@ bnx2_tx_int(struct bnx2 *bp)
 		skb = tx_buf->skb;
 #ifdef BCM_TSO 
 		/* partial BD completions possible with TSO packets */
-		if (skb_shinfo(skb)->tso_size) {
+		if (skb_shinfo(skb)->gso_size) {
 			u16 last_idx, last_ring_idx;
 
 			last_idx = sw_cons +
@@ -4428,7 +4428,7 @@ bnx2_start_xmit(struct sk_buff *skb, str
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
 #ifdef BCM_TSO 
-	if ((mss = skb_shinfo(skb)->tso_size) &&
+	if ((mss = skb_shinfo(skb)->gso_size) &&
 		(skb->len > (bp->dev->mtu + ETH_HLEN))) {
 		u32 tcp_opt_len, ip_tcp_len;
 
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1418,7 +1418,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 	struct cpl_tx_pkt *cpl;
 
 #ifdef NETIF_F_TSO
-	if (skb_shinfo(skb)->tso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
 
@@ -1433,7 +1433,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 		hdr->ip_hdr_words = skb->nh.iph->ihl;
 		hdr->tcp_hdr_words = skb->h.th->doff;
 		hdr->eth_type_mss = htons(MK_ETH_TYPE_MSS(eth_type,
-						skb_shinfo(skb)->tso_size));
+						skb_shinfo(skb)->gso_size));
 		hdr->len = htonl(skb->len - sizeof(*hdr));
 		cpl = (struct cpl_tx_pkt *)hdr;
 		sge->stats.tx_lso_pkts++;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2394,7 +2394,7 @@ e1000_tso(struct e1000_adapter *adapter,
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
-	if (skb_shinfo(skb)->tso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (err)
@@ -2402,7 +2402,7 @@ e1000_tso(struct e1000_adapter *adapter,
 		}
 
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
-		mss = skb_shinfo(skb)->tso_size;
+		mss = skb_shinfo(skb)->gso_size;
 		if (skb->protocol == htons(ETH_P_IP)) {
 			skb->nh.iph->tot_len = 0;
 			skb->nh.iph->check = 0;
@@ -2519,7 +2519,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 		 * tso gets written back prematurely before the data is fully
 		 * DMA'd to the controller */
 		if (!skb->data_len && tx_ring->last_tx_tso &&
-		    !skb_shinfo(skb)->tso_size) {
+		    !skb_shinfo(skb)->gso_size) {
 			tx_ring->last_tx_tso = 0;
 			size -= 4;
 		}
@@ -2757,7 +2757,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	}
 
 #ifdef NETIF_F_TSO
-	mss = skb_shinfo(skb)->tso_size;
+	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
@@ -2807,7 +2807,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 #ifdef NETIF_F_TSO
 	/* Controller Erratum workaround */
 	if (!skb->data_len && tx_ring->last_tx_tso &&
-	    !skb_shinfo(skb)->tso_size)
+	    !skb_shinfo(skb)->gso_size)
 		count++;
 #endif
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1495,8 +1495,8 @@ static int nv_start_xmit(struct sk_buff 
 	np->tx_skbuff[nr] = skb;
 
 #ifdef NETIF_F_TSO
-	if (skb_shinfo(skb)->tso_size)
-		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->tso_size << NV_TX2_TSO_SHIFT);
+	if (skb_shinfo(skb)->gso_size)
+		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
 	else
 #endif
 	tx_flags_extra = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1173,7 +1173,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 	uint16_t ipcse, tucse, mss;
 	int err;
 
-	if(likely(skb_shinfo(skb)->tso_size)) {
+	if(likely(skb_shinfo(skb)->gso_size)) {
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (err)
@@ -1181,7 +1181,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 		}
 
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
-		mss = skb_shinfo(skb)->tso_size;
+		mss = skb_shinfo(skb)->gso_size;
 		skb->nh.iph->tot_len = 0;
 		skb->nh.iph->check = 0;
 		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -74,7 +74,7 @@ static void emulate_large_send_offload(s
 	struct iphdr *iph = skb->nh.iph;
 	struct tcphdr *th = (struct tcphdr*)(skb->nh.raw + (iph->ihl * 4));
 	unsigned int doffset = (iph->ihl + th->doff) * 4;
-	unsigned int mtu = skb_shinfo(skb)->tso_size + doffset;
+	unsigned int mtu = skb_shinfo(skb)->gso_size + doffset;
 	unsigned int offset = 0;
 	u32 seq = ntohl(th->seq);
 	u16 id  = ntohs(iph->id);
@@ -139,7 +139,7 @@ static int loopback_xmit(struct sk_buff 
 #endif
 
 #ifdef LOOPBACK_TSO
-	if (skb_shinfo(skb)->tso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		BUG_ON(skb->protocol != htons(ETH_P_IP));
 		BUG_ON(skb->nh.iph->protocol != IPPROTO_TCP);
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1879,7 +1879,7 @@ again:
 
 #ifdef NETIF_F_TSO
 	if (skb->len > (dev->mtu + ETH_HLEN)) {
-		mss = skb_shinfo(skb)->tso_size;
+		mss = skb_shinfo(skb)->gso_size;
 		if (mss != 0)
 			max_segments = MYRI10GE_MAX_SEND_DESC_TSO;
 	}
@@ -2113,7 +2113,7 @@ abort_linearize:
 		}
 		idx = (idx + 1) & tx->mask;
 	} while (idx != last_idx);
-	if (skb_shinfo(skb)->tso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		printk(KERN_ERR
 		       "myri10ge: %s: TSO but wanted to linearize?!?!?\n",
 		       mgp->dev->name);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2172,7 +2172,7 @@ static int rtl8169_xmit_frags(struct rtl
 static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 {
 	if (dev->features & NETIF_F_TSO) {
-		u32 mss = skb_shinfo(skb)->tso_size;
+		u32 mss = skb_shinfo(skb)->gso_size;
 
 		if (mss)
 			return LargeSend | ((mss & MSSMask) << MSSShift);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3915,8 +3915,8 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Control_1 = 0;
 	txdp->Control_2 = 0;
 #ifdef NETIF_F_TSO
-	mss = skb_shinfo(skb)->tso_size;
-	if (mss) {
+	mss = skb_shinfo(skb)->gso_size;
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(mss);
 	}
@@ -3936,10 +3936,10 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	frg_len = skb->len - skb->data_len;
-	if (skb_shinfo(skb)->ufo_size) {
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4) {
 		int ufo_size;
 
-		ufo_size = skb_shinfo(skb)->ufo_size;
+		ufo_size = skb_shinfo(skb)->gso_size;
 		ufo_size &= ~7;
 		txdp->Control_1 |= TXD_UFO_EN;
 		txdp->Control_1 |= TXD_UFO_MSS(ufo_size);
@@ -3965,7 +3965,7 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 
-	if (skb_shinfo(skb)->ufo_size)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
 		txdp->Control_1 |= TXD_UFO_EN;
 
 	frg_cnt = skb_shinfo(skb)->nr_frags;
@@ -3980,12 +3980,12 @@ static int s2io_xmit(struct sk_buff *skb
 		    (sp->pdev, frag->page, frag->page_offset,
 		     frag->size, PCI_DMA_TODEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
-		if (skb_shinfo(skb)->ufo_size)
+		if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
 			txdp->Control_1 |= TXD_UFO_EN;
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_LAST;
 
-	if (skb_shinfo(skb)->ufo_size)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
 		frg_cnt++; /* as Txd0 was used for inband header */
 
 	tx_fifo = mac_control->tx_FIFO_start[queue];
@@ -3999,7 +3999,7 @@ static int s2io_xmit(struct sk_buff *skb
 	if (mss)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
 #endif
-	if (skb_shinfo(skb)->ufo_size)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
 	writeq(val64, &tx_fifo->List_Control);
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1160,7 +1160,7 @@ static unsigned tx_le_req(const struct s
 	count = sizeof(dma_addr_t) / sizeof(u32);
 	count += skb_shinfo(skb)->nr_frags * count;
 
-	if (skb_shinfo(skb)->tso_size)
+	if (skb_shinfo(skb)->gso_size)
 		++count;
 
 	if (skb->ip_summed == CHECKSUM_HW)
@@ -1232,7 +1232,7 @@ static int sky2_xmit_frame(struct sk_buf
 	}
 
 	/* Check for TCP Segmentation Offload */
-	mss = skb_shinfo(skb)->tso_size;
+	mss = skb_shinfo(skb)->gso_size;
 	if (mss != 0) {
 		/* just drop the packet if non-linear expansion fails */
 		if (skb_header_cloned(skb) &&
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3780,7 +3780,7 @@ static int tg3_start_xmit(struct sk_buff
 #if TG3_TSO_SUPPORT != 0
 	mss = 0;
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
-	    (mss = skb_shinfo(skb)->tso_size) != 0) {
+	    (mss = skb_shinfo(skb)->gso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
 
 		if (skb_header_cloned(skb) &&
@@ -3905,7 +3905,7 @@ static int tg3_start_xmit_dma_bug(struct
 #if TG3_TSO_SUPPORT != 0
 	mss = 0;
 	if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
-	    (mss = skb_shinfo(skb)->tso_size) != 0) {
+	    (mss = skb_shinfo(skb)->gso_size) != 0) {
 		int tcp_opt_len, ip_tcp_len;
 
 		if (skb_header_cloned(skb) &&
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -340,7 +340,7 @@ enum state_values {
 #endif
 
 #if defined(NETIF_F_TSO)
-#define skb_tso_size(x)		(skb_shinfo(x)->tso_size)
+#define skb_tso_size(x)		(skb_shinfo(x)->gso_size)
 #define TSO_NUM_DESCRIPTORS	2
 #define TSO_OFFLOAD_ON		TYPHOON_OFFLOAD_TCP_SEGMENT
 #else
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -420,7 +420,7 @@ __qeth_eddp_fill_context_tcp(struct qeth
        }
 	tcph = eddp->skb->h.th;
 	while (eddp->skb_offset < eddp->skb->len) {
-		data_len = min((int)skb_shinfo(eddp->skb)->tso_size,
+		data_len = min((int)skb_shinfo(eddp->skb)->gso_size,
 			       (int)(eddp->skb->len - eddp->skb_offset));
 		/* prepare qdio hdr */
 		if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2){
@@ -515,20 +515,20 @@ qeth_eddp_calc_num_pages(struct qeth_edd
 
 	QETH_DBF_TEXT(trace, 5, "eddpcanp");
 	/* can we put multiple skbs in one page? */
-	skbs_per_page = PAGE_SIZE / (skb_shinfo(skb)->tso_size + hdr_len);
+	skbs_per_page = PAGE_SIZE / (skb_shinfo(skb)->gso_size + hdr_len);
 	if (skbs_per_page > 1){
-		ctx->num_pages = (skb_shinfo(skb)->tso_segs + 1) /
+		ctx->num_pages = (skb_shinfo(skb)->gso_segs + 1) /
 				 skbs_per_page + 1;
 		ctx->elements_per_skb = 1;
 	} else {
 		/* no -> how many elements per skb? */
-		ctx->elements_per_skb = (skb_shinfo(skb)->tso_size + hdr_len +
+		ctx->elements_per_skb = (skb_shinfo(skb)->gso_size + hdr_len +
 				     PAGE_SIZE) >> PAGE_SHIFT;
 		ctx->num_pages = ctx->elements_per_skb *
-				 (skb_shinfo(skb)->tso_segs + 1);
+				 (skb_shinfo(skb)->gso_segs + 1);
 	}
 	ctx->num_elements = ctx->elements_per_skb *
-			    (skb_shinfo(skb)->tso_segs + 1);
+			    (skb_shinfo(skb)->gso_segs + 1);
 }
 
 static inline struct qeth_eddp_context *
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -4417,7 +4417,7 @@ qeth_send_packet(struct qeth_card *card,
 	struct qeth_eddp_context *ctx = NULL;
 	int tx_bytes = skb->len;
 	unsigned short nr_frags = skb_shinfo(skb)->nr_frags;
-	unsigned short tso_size = skb_shinfo(skb)->tso_size;
+	unsigned short tso_size = skb_shinfo(skb)->gso_size;
 	int rc;
 
 	QETH_DBF_TEXT(trace, 6, "sendpkt");
@@ -4453,7 +4453,7 @@ qeth_send_packet(struct qeth_card *card,
 	queue = card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 
-	if (skb_shinfo(skb)->tso_size)
+	if (skb_shinfo(skb)->gso_size)
 		large_send = card->options.large_send;
 
 	/*are we able to do TSO ? If so ,prepare and send it from here */
diff --git a/drivers/s390/net/qeth_tso.h b/drivers/s390/net/qeth_tso.h
--- a/drivers/s390/net/qeth_tso.h
+++ b/drivers/s390/net/qeth_tso.h
@@ -51,7 +51,7 @@ qeth_tso_fill_header(struct qeth_card *c
 	hdr->ext.hdr_version = 1;
 	hdr->ext.hdr_len     = 28;
 	/*insert non-fix values */
-	hdr->ext.mss = skb_shinfo(skb)->tso_size;
+	hdr->ext.mss = skb_shinfo(skb)->gso_size;
 	hdr->ext.dg_hdr_len = (__u16)(iph->ihl*4 + tcph->doff*4);
 	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
 				       sizeof(struct qeth_hdr_tso));
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -309,9 +309,12 @@ struct net_device
 #define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
 #define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
-#define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
-#define NETIF_F_UFO             8192    /* Can offload UDP Large Send*/
+
+	/* Segmentation offload features */
+#define NETIF_F_GSO_SHIFT	16
+#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
@@ -980,6 +983,13 @@ extern void dev_seq_stop(struct seq_file
 
 extern void linkwatch_run_queue(void);
 
+static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
+{
+	int feature = skb_shinfo(skb)->gso_type << NETIF_F_GSO_SHIFT;
+	return skb_shinfo(skb)->gso_size &&
+	       (dev->features & feature) != feature;
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -135,9 +135,10 @@ struct skb_frag_struct {
 struct skb_shared_info {
 	atomic_t	dataref;
 	unsigned short	nr_frags;
-	unsigned short	tso_size;
-	unsigned short	tso_segs;
-	unsigned short  ufo_size;
+	unsigned short	gso_size;
+	/* Warning: this field is not always filled in (UFO)! */
+	unsigned short	gso_segs;
+	unsigned short  gso_type;
 	unsigned int    ip6_frag_id;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
@@ -169,6 +170,11 @@ enum {
 	SKB_FCLONE_CLONE,
 };
 
+enum {
+	SKB_GSO_TCPV4 = 1 << 0,
+	SKB_GSO_UDPV4 = 1 << 1,
+};
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -570,13 +570,13 @@ struct tcp_skb_cb {
  */
 static inline int tcp_skb_pcount(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->tso_segs;
+	return skb_shinfo(skb)->gso_segs;
 }
 
 /* This is valid iff tcp_skb_pcount() > 1. */
 static inline int tcp_skb_mss(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->tso_size;
+	return skb_shinfo(skb)->gso_size;
 }
 
 static inline void tcp_dec_pcount_approx(__u32 *count,
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -34,8 +34,8 @@ static inline unsigned packet_length(con
 
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
-	/* drop mtu oversized packets except tso */
-	if (packet_length(skb) > skb->dev->mtu && !skb_shinfo(skb)->tso_size)
+	/* drop mtu oversized packets except gso */
+	if (packet_length(skb) > skb->dev->mtu && !skb_shinfo(skb)->gso_size)
 		kfree_skb(skb);
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -761,7 +761,7 @@ static int br_nf_dev_queue_xmit(struct s
 {
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len > skb->dev->mtu &&
-	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
+	    !skb_shinfo(skb)->gso_size)
 		return ip_fragment(skb, br_dev_queue_push_xmit);
 	else
 		return br_dev_queue_push_xmit(skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -172,9 +172,9 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
 	shinfo->nr_frags  = 0;
-	shinfo->tso_size = 0;
-	shinfo->tso_segs = 0;
-	shinfo->ufo_size = 0;
+	shinfo->gso_size = 0;
+	shinfo->gso_segs = 0;
+	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
 
@@ -238,8 +238,9 @@ struct sk_buff *alloc_skb_from_cache(kme
 
 	atomic_set(&(skb_shinfo(skb)->dataref), 1);
 	skb_shinfo(skb)->nr_frags  = 0;
-	skb_shinfo(skb)->tso_size = 0;
-	skb_shinfo(skb)->tso_segs = 0;
+	skb_shinfo(skb)->gso_size = 0;
+	skb_shinfo(skb)->gso_segs = 0;
+	skb_shinfo(skb)->gso_type = 0;
 	skb_shinfo(skb)->frag_list = NULL;
 out:
 	return skb;
@@ -528,8 +529,9 @@ static void copy_skb_header(struct sk_bu
 #endif
 	skb_copy_secmark(new, old);
 	atomic_set(&new->users, 1);
-	skb_shinfo(new)->tso_size = skb_shinfo(old)->tso_size;
-	skb_shinfo(new)->tso_segs = skb_shinfo(old)->tso_segs;
+	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
+	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
+	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
 /**
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -210,8 +210,7 @@ static inline int ip_finish_output(struc
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > dst_mtu(skb->dst) &&
-	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
+	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->gso_size)
 		return ip_fragment(skb, ip_finish_output2);
 	else
 		return ip_finish_output2(skb);
@@ -362,7 +361,7 @@ packet_routed:
 	}
 
 	ip_select_ident_more(iph, &rt->u.dst, sk,
-			     (skb_shinfo(skb)->tso_segs ?: 1) - 1);
+			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	/* Add an IP checksum. */
 	ip_send_check(iph);
@@ -744,7 +743,8 @@ static inline int ip_ufo_append_data(str
 			       (length - transhdrlen));
 	if (!err) {
 		/* specify the length of each IP datagram fragment*/
-		skb_shinfo(skb)->ufo_size = (mtu - fragheaderlen);
+		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
 
 		return 0;
@@ -1087,14 +1087,16 @@ ssize_t	ip_append_page(struct sock *sk, 
 
 	inet->cork.length += size;
 	if ((sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->u.dst.dev->features & NETIF_F_UFO))
-		skb_shinfo(skb)->ufo_size = (mtu - fragheaderlen);
+	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
+	}
 
 
 	while (size > 0) {
 		int i;
 
-		if (skb_shinfo(skb)->ufo_size)
+		if (skb_shinfo(skb)->gso_size)
 			len = size;
 		else {
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -571,7 +571,7 @@ new_segment:
 		skb->ip_summed = CHECKSUM_HW;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
-		skb_shinfo(skb)->tso_segs = 0;
+		skb_shinfo(skb)->gso_segs = 0;
 
 		if (!copied)
 			TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
@@ -818,7 +818,7 @@ new_segment:
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
-			skb_shinfo(skb)->tso_segs = 0;
+			skb_shinfo(skb)->gso_segs = 0;
 
 			from += copy;
 			copied += copy;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1073,7 +1073,7 @@ tcp_sacktag_write_queue(struct sock *sk,
 				else
 					pkt_len = (end_seq -
 						   TCP_SKB_CB(skb)->seq);
-				if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->tso_size))
+				if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size))
 					break;
 				pcount = tcp_skb_pcount(skb);
 			}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -515,15 +515,17 @@ static void tcp_set_skb_tso_segs(struct 
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
-		skb_shinfo(skb)->tso_segs = 1;
-		skb_shinfo(skb)->tso_size = 0;
+		skb_shinfo(skb)->gso_segs = 1;
+		skb_shinfo(skb)->gso_size = 0;
+		skb_shinfo(skb)->gso_type = 0;
 	} else {
 		unsigned int factor;
 
 		factor = skb->len + (mss_now - 1);
 		factor /= mss_now;
-		skb_shinfo(skb)->tso_segs = factor;
-		skb_shinfo(skb)->tso_size = mss_now;
+		skb_shinfo(skb)->gso_segs = factor;
+		skb_shinfo(skb)->gso_size = mss_now;
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 	}
 }
 
@@ -914,7 +916,7 @@ static int tcp_init_tso_segs(struct sock
 
 	if (!tso_segs ||
 	    (tso_segs > 1 &&
-	     skb_shinfo(skb)->tso_size != mss_now)) {
+	     tcp_skb_mss(skb) != mss_now)) {
 		tcp_set_skb_tso_segs(sk, skb, mss_now);
 		tso_segs = tcp_skb_pcount(skb);
 	}
@@ -1724,8 +1726,9 @@ int tcp_retransmit_skb(struct sock *sk, 
 	   tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
-			skb_shinfo(skb)->tso_segs = 1;
-			skb_shinfo(skb)->tso_size = 0;
+			skb_shinfo(skb)->gso_segs = 1;
+			skb_shinfo(skb)->gso_size = 0;
+			skb_shinfo(skb)->gso_type = 0;
 			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 		}
@@ -1930,8 +1933,9 @@ void tcp_send_fin(struct sock *sk)
 		skb->csum = 0;
 		TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		TCP_SKB_CB(skb)->sacked = 0;
-		skb_shinfo(skb)->tso_segs = 1;
-		skb_shinfo(skb)->tso_size = 0;
+		skb_shinfo(skb)->gso_segs = 1;
+		skb_shinfo(skb)->gso_size = 0;
+		skb_shinfo(skb)->gso_type = 0;
 
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		TCP_SKB_CB(skb)->seq = tp->write_seq;
@@ -1963,8 +1967,9 @@ void tcp_send_active_reset(struct sock *
 	skb->csum = 0;
 	TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	TCP_SKB_CB(skb)->sacked = 0;
-	skb_shinfo(skb)->tso_segs = 1;
-	skb_shinfo(skb)->tso_size = 0;
+	skb_shinfo(skb)->gso_segs = 1;
+	skb_shinfo(skb)->gso_size = 0;
+	skb_shinfo(skb)->gso_type = 0;
 
 	/* Send it off. */
 	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk, tp);
@@ -2047,8 +2052,9 @@ struct sk_buff * tcp_make_synack(struct 
 	TCP_SKB_CB(skb)->seq = tcp_rsk(req)->snt_isn;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
 	TCP_SKB_CB(skb)->sacked = 0;
-	skb_shinfo(skb)->tso_segs = 1;
-	skb_shinfo(skb)->tso_size = 0;
+	skb_shinfo(skb)->gso_segs = 1;
+	skb_shinfo(skb)->gso_size = 0;
+	skb_shinfo(skb)->gso_type = 0;
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
@@ -2152,8 +2158,9 @@ int tcp_connect(struct sock *sk)
 	TCP_SKB_CB(buff)->flags = TCPCB_FLAG_SYN;
 	TCP_ECN_send_syn(sk, tp, buff);
 	TCP_SKB_CB(buff)->sacked = 0;
-	skb_shinfo(buff)->tso_segs = 1;
-	skb_shinfo(buff)->tso_size = 0;
+	skb_shinfo(buff)->gso_segs = 1;
+	skb_shinfo(buff)->gso_size = 0;
+	skb_shinfo(buff)->gso_type = 0;
 	buff->csum = 0;
 	TCP_SKB_CB(buff)->seq = tp->write_seq++;
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
@@ -2257,8 +2264,9 @@ void tcp_send_ack(struct sock *sk)
 		buff->csum = 0;
 		TCP_SKB_CB(buff)->flags = TCPCB_FLAG_ACK;
 		TCP_SKB_CB(buff)->sacked = 0;
-		skb_shinfo(buff)->tso_segs = 1;
-		skb_shinfo(buff)->tso_size = 0;
+		skb_shinfo(buff)->gso_segs = 1;
+		skb_shinfo(buff)->gso_size = 0;
+		skb_shinfo(buff)->gso_type = 0;
 
 		/* Send it off, this clears delayed acks for us. */
 		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk, tp);
@@ -2293,8 +2301,9 @@ static int tcp_xmit_probe_skb(struct soc
 	skb->csum = 0;
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = urgent;
-	skb_shinfo(skb)->tso_segs = 1;
-	skb_shinfo(skb)->tso_size = 0;
+	skb_shinfo(skb)->gso_segs = 1;
+	skb_shinfo(skb)->gso_size = 0;
+	skb_shinfo(skb)->gso_type = 0;
 
 	/* Use a previous sequence.  This should cause the other
 	 * end to send an ack.  Don't queue or clone SKB, just
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -148,7 +148,7 @@ static int ip6_output2(struct sk_buff *s
 
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->ufo_size) ||
+	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->gso_size) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
@@ -833,8 +833,9 @@ static inline int ip6_ufo_append_data(st
 		struct frag_hdr fhdr;
 
 		/* specify the length of each IP datagram fragment*/
-		skb_shinfo(skb)->ufo_size = (mtu - fragheaderlen) - 
-						sizeof(struct frag_hdr);
+		skb_shinfo(skb)->gso_size = mtu - fragheaderlen - 
+					    sizeof(struct frag_hdr);
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
 		ipv6_select_ident(skb, &fhdr);
 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);

--4Ckj6UjgE2iN1+kY--
