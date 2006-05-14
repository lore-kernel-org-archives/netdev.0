From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: attempt to make via-velocity work on big-endian hosts
Date: Sun, 14 May 2006 18:16:44 +0200
Message-ID: <20060514161644.GA17193@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:55508 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751486AbWENQQq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 12:16:46 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Attached below is an attempt I made, for a friend of mine, to make
via-velocity work on big-endian hosts.  It doesn't quite work,
however, and since I don't have the hardware myself, it's kind of
cumbersome to debug it.  Maybe someone here has an interest?


cheers,
Lennert


Index: linux-2.6.16/drivers/net/via-velocity.c
===================================================================
--- linux-2.6.16.orig/drivers/net/via-velocity.c
+++ linux-2.6.16/drivers/net/via-velocity.c
@@ -511,7 +511,7 @@ static void velocity_rx_reset(struct vel
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		vptr->rd_ring[i].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[i].rdesc0 |= cpu_to_le32(RDESC0_OWNED_BY_NIC);
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -607,7 +607,7 @@ static void velocity_init_registers(stru
 
 		vptr->int_mask = INT_MASK_DEF;
 
-		writel(cpu_to_le32(vptr->rd_pool_dma), &regs->RDBaseLo);
+		writel(vptr->rd_pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
 		mac_rx_queue_run(regs);
 		mac_rx_queue_wake(regs);
@@ -615,7 +615,7 @@ static void velocity_init_registers(stru
 		writew(vptr->options.numtx - 1, &regs->TDCSize);
 
 		for (i = 0; i < vptr->num_txq; i++) {
-			writel(cpu_to_le32(vptr->td_pool_dma[i]), &(regs->TDBaseLo[i]));
+			writel(vptr->td_pool_dma[i], &(regs->TDBaseLo[i]));
 			mac_tx_queue_run(regs, i);
 		}
 
@@ -1022,7 +1022,7 @@ static inline void velocity_give_many_rx
 	dirty = vptr->rd_dirty - unusable;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[dirty].rdesc0 |= cpu_to_le32(RDESC0_OWNED_BY_NIC);
 	}
 
 	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
@@ -1037,7 +1037,7 @@ static int velocity_rx_refill(struct vel
 		struct rx_desc *rd = vptr->rd_ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0 & cpu_to_le32(RDESC0_OWNED_BY_NIC))
 			break;
 
 		if (!vptr->rd_info[dirty].skb) {
@@ -1237,31 +1237,34 @@ static int velocity_rx_srv(struct veloci
 
 	do {
 		struct rx_desc *rd = vptr->rd_ring + rd_curr;
+		u32 rdesc0;
 
 		if (!vptr->rd_info[rd_curr].skb)
 			break;
 
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0 & cpu_to_le32(RDESC0_OWNED_BY_NIC))
 			break;
 
 		rmb();
 
+		rdesc0 = le32_to_cpu(rd->rdesc0);
+
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
 		 */
-		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
+		if ((rdesc0 & RDESC0_RSR_RXOK) || (!(rdesc0 & RDESC0_RSR_RXOK) && (rdesc0 & (RDESC0_RSR_CE | RDESC0_RSR_RL)))) {
 			if (velocity_receive_frame(vptr, rd_curr) < 0)
 				stats->rx_dropped++;
 		} else {
-			if (rd->rdesc0.RSR & RSR_CRC)
+			if (rdesc0 & RDESC0_RSR_CRC)
 				stats->rx_crc_errors++;
-			if (rd->rdesc0.RSR & RSR_FAE)
+			if (rdesc0 & RDESC0_RSR_FAE)
 				stats->rx_frame_errors++;
 
 			stats->rx_dropped++;
 		}
 
-		rd->inten = 1;
+		rd->rdesc3 |= cpu_to_le32(RDESC3_INTEN);
 
 		vptr->dev->last_rx = jiffies;
 
@@ -1294,11 +1297,11 @@ static inline void velocity_rx_csum(stru
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
-	if (rd->rdesc1.CSM & CSM_IPKT) {
-		if (rd->rdesc1.CSM & CSM_IPOK) {
-			if ((rd->rdesc1.CSM & CSM_TCPKT) || 
-					(rd->rdesc1.CSM & CSM_UDPKT)) {
-				if (!(rd->rdesc1.CSM & CSM_TUPOK)) {
+	if (rd->rdesc1 & cpu_to_le32(RDESC1_CSM_IPKT)) {
+		if (rd->rdesc1 & cpu_to_le32(RDESC1_CSM_IPOK)) {
+			if ((rd->rdesc1 & cpu_to_le32(RDESC1_CSM_TCPKT)) ||
+				(rd->rdesc1 & cpu_to_le32(RDESC1_CSM_UDPKT))) {
+				if (!(rd->rdesc1 & cpu_to_le32(RDESC1_CSM_TUPOK))) {
 					return;
 				}
 			}
@@ -1381,16 +1384,20 @@ static int velocity_receive_frame(struct
 	struct net_device_stats *stats = &vptr->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
-	int pkt_len = rd->rdesc0.len;
+	u32 rdesc0;
+	int pkt_len;
 	struct sk_buff *skb;
 
-	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
+	rdesc0 = le32_to_cpu(rd->rdesc0);
+	pkt_len = (rdesc0 >> RDESC0_LEN_SHIFT) & RDESC0_LEN_MASK;
+
+	if (rdesc0 & (RDESC0_RSR_STP | RDESC0_RSR_EDP)) {
 		VELOCITY_PRT(MSG_LEVEL_VERBOSE, KERN_ERR " %s : the received frame span multple RDs.\n", vptr->dev->name);
 		stats->rx_length_errors++;
 		return -EINVAL;
 	}
 
-	if (rd->rdesc0.RSR & RSR_MAR)
+	if (rdesc0 & RDESC0_RSR_MAR)
 		vptr->stats.multicast++;
 
 	skb = rd_info->skb;
@@ -1404,7 +1411,7 @@ static int velocity_receive_frame(struct
 	 */
 	 
 	if (vptr->flags & VELOCITY_FLAGS_VAL_PKT_LEN) {
-		if (rd->rdesc0.RSR & RSR_RL) {
+		if (rdesc0 & RDESC0_RSR_RL) {
 			stats->rx_length_errors++;
 			return -EINVAL;
 		}
@@ -1464,11 +1471,10 @@ static int velocity_alloc_rx_buf(struct 
 	 *	Fill in the descriptor to match
  	 */	
  	 
-	*((u32 *) & (rd->rdesc0)) = 0;
-	rd->len = cpu_to_le32(vptr->rx_buf_sz);
-	rd->inten = 1;
+	rd->rdesc0 = cpu_to_le32(vptr->rx_buf_sz << RDESC0_LEN_SHIFT);
 	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
-	rd->pa_high = 0;
+	rd->rdesc3 = cpu_to_le32(RDESC3_INTEN);
+
 	return 0;
 }
 
@@ -1502,22 +1508,22 @@ static int velocity_tx_srv(struct veloci
 			td = &(vptr->td_rings[qnum][idx]);
 			tdinfo = &(vptr->td_infos[qnum][idx]);
 
-			if (td->tdesc0.owner == OWNED_BY_NIC)
+			if (td->tdesc0 & cpu_to_le32(TDESC0_OWNED_BY_NIC))
 				break;
 
 			if ((works++ > 15))
 				break;
 
-			if (td->tdesc0.TSR & TSR0_TERR) {
+			if (td->tdesc0 & cpu_to_le32(TDESC0_TSR_TERR)) {
 				stats->tx_errors++;
 				stats->tx_dropped++;
-				if (td->tdesc0.TSR & TSR0_CDH)
+				if (td->tdesc0 & cpu_to_le32(TDESC0_TSR_CDH))
 					stats->tx_heartbeat_errors++;
-				if (td->tdesc0.TSR & TSR0_CRS)
+				if (td->tdesc0 & cpu_to_le32(TDESC0_TSR_CRS))
 					stats->tx_carrier_errors++;
-				if (td->tdesc0.TSR & TSR0_ABT)
+				if (td->tdesc0 & cpu_to_le32(TDESC0_TSR_ABT))
 					stats->tx_aborted_errors++;
-				if (td->tdesc0.TSR & TSR0_OWC)
+				if (td->tdesc0 & cpu_to_le32(TDESC0_TSR_OWC))
 					stats->tx_window_errors++;
 			} else {
 				stats->tx_packets++;
@@ -1905,9 +1911,9 @@ static int velocity_xmit(struct sk_buff 
 	td_ptr = &(vptr->td_rings[qnum][index]);
 	tdinfo = &(vptr->td_infos[qnum][index]);
 
-	td_ptr->tdesc1.TCPLS = TCPLS_NORMAL;
-	td_ptr->tdesc1.TCR = TCR0_TIC;
-	td_ptr->td_buf[0].queue = 0;
+	td_ptr->tdesc1 &= ~cpu_to_le32(TDESC1_TCPLS | TDESC1_TCR);
+	td_ptr->tdesc1 |= cpu_to_le32(TDESC1_TCPLS_NORMAL | TDESC1_TCR_TIC);
+	td_ptr->td_buf[0].td_buf1 &= ~cpu_to_le32(TD_BUF1_QUEUE);
 
 	/*
 	 *	Pad short frames. 
@@ -1921,12 +1927,13 @@ static int velocity_xmit(struct sk_buff 
 		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = tdinfo->buf_dma;
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0 &= ~cpu_to_le32(TDESC0_PKTSIZE);
+		td_ptr->tdesc0 |= cpu_to_le32((pktlen & TDESC0_PKTSIZE_MASK) << TDESC0_PKTSIZE_SHIFT);
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].td_buf1 = cpu_to_le32((pktlen & TD_BUF1_BUFSIZE_MASK) << TD_BUF1_BUFSIZE_SHIFT);
 		tdinfo->nskb_dma = 1;
-		td_ptr->tdesc1.CMDZ = 2;
+		td_ptr->tdesc1 &= ~cpu_to_le32(TDESC1_CMDZ);
+		td_ptr->tdesc1 |= cpu_to_le32(2 << TDESC1_CMDZ_SHIFT);
 	} else
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 0) {
@@ -1936,12 +1943,12 @@ static int velocity_xmit(struct sk_buff 
 			skb_linearize(skb, GFP_ATOMIC);
 			memcpy(tdinfo->buf, skb->data, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
-			td_ptr->tdesc0.pktsize = 
+			td_ptr->tdesc0.pktsize =
 			td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-			td_ptr->td_buf[0].pa_high = 0;
-			td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+			td_ptr->td_buf[0].td_buf1 = cpu_to_le32((size & TD_BUF1_BUFSIZE_MASK) << TD_BUF1_BUFSIZE_SHIFT);
 			tdinfo->nskb_dma = 1;
-			td_ptr->tdesc1.CMDZ = 2;
+			td_ptr->tdesc1 &= ~cpu_to_le32(TDESC1_CMDZ);
+			td_ptr->tdesc1 |= cpu_to_le32(2 << TDESC1_CMDZ_SHIFT);
 		} else {
 			int i = 0;
 			tdinfo->nskb_dma = 0;
@@ -1977,19 +1984,19 @@ static int velocity_xmit(struct sk_buff 
 		 */
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0 &= ~cpu_to_le32(TDESC0_PKTSIZE);
+		td_ptr->tdesc0 |= cpu_to_le32((pktlen & TDESC0_PKTSIZE_MASK) << TDESC0_PKTSIZE_SHIFT);
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].td_buf1 = cpu_to_le32((pktlen & TD_BUF1_BUFSIZE_MASK) << TD_BUF1_BUFSIZE_SHIFT);
 		tdinfo->nskb_dma = 1;
-		td_ptr->tdesc1.CMDZ = 2;
+		td_ptr->tdesc1 &= ~cpu_to_le32(TDESC1_CMDZ);
+		td_ptr->tdesc1 |= cpu_to_le32(2 << TDESC1_CMDZ_SHIFT);
 	}
 
 	if (vptr->flags & VELOCITY_FLAGS_TAGGING) {
-		td_ptr->tdesc1.pqinf.VID = (vptr->options.vid & 0xfff);
-		td_ptr->tdesc1.pqinf.priority = 0;
-		td_ptr->tdesc1.pqinf.CFI = 0;
-		td_ptr->tdesc1.TCR |= TCR0_VETAG;
+		td_ptr->tdesc1 |= cpu_to_le32(TDESC1_TCR_VETAG);
+		td_ptr->tdesc1 &= ~cpu_to_le32(TDESC1_PRIORITY | TDESC1_CFI | TDESC1_VID);
+		td_ptr->tdesc1 |= cpu_to_le32((vptr->options.vid & TDESC1_VID_MASK) << TDESC1_VID_SHIFT);
 	}
 
 	/*
@@ -1999,10 +2006,10 @@ static int velocity_xmit(struct sk_buff 
 				 && (skb->ip_summed == CHECKSUM_HW)) {
 		struct iphdr *ip = skb->nh.iph;
 		if (ip->protocol == IPPROTO_TCP)
-			td_ptr->tdesc1.TCR |= TCR0_TCPCK;
+			td_ptr->tdesc1 |= cpu_to_le32(TDESC1_TCR_TCPCK);
 		else if (ip->protocol == IPPROTO_UDP)
-			td_ptr->tdesc1.TCR |= (TCR0_UDPCK);
-		td_ptr->tdesc1.TCR |= TCR0_IPCK;
+			td_ptr->tdesc1 |= cpu_to_le32(TDESC1_TCR_UDPCK);
+		td_ptr->tdesc1 |= cpu_to_le32(TDESC1_TCR_IPCK);
 	}
 	{
 
@@ -2010,7 +2017,7 @@ static int velocity_xmit(struct sk_buff 
 
 		if (prev < 0)
 			prev = vptr->options.numtx - 1;
-		td_ptr->tdesc0.owner = OWNED_BY_NIC;
+		td_ptr->tdesc0 |= cpu_to_le32(TDESC0_OWNED_BY_NIC);
 		vptr->td_used[qnum]++;
 		vptr->td_curr[qnum] = (index + 1) % vptr->options.numtx;
 
@@ -2018,7 +2025,7 @@ static int velocity_xmit(struct sk_buff 
 			netif_stop_queue(dev);
 
 		td_ptr = &(vptr->td_rings[qnum][prev]);
-		td_ptr->td_buf[0].queue = 1;
+		td_ptr->td_buf[0].td_buf1 |= cpu_to_le32(TD_BUF1_QUEUE);
 		mac_tx_queue_wake(vptr->mac_regs, qnum);
 	}
 	dev->trans_start = jiffies;
Index: linux-2.6.16/drivers/net/via-velocity.h
===================================================================
--- linux-2.6.16.orig/drivers/net/via-velocity.h
+++ linux-2.6.16/drivers/net/via-velocity.h
@@ -56,113 +56,6 @@
 
 #define VAR_USED(p)     do {(p)=(p);} while (0)
 
-/*
- * Purpose: Structures for MAX RX/TX descriptors.
- */
-
-
-#define B_OWNED_BY_CHIP     1
-#define B_OWNED_BY_HOST     0
-
-/*
- * Bits in the RSR0 register
- */
-
-#define RSR_DETAG          0x0080
-#define RSR_SNTAG          0x0040
-#define RSR_RXER           0x0020
-#define RSR_RL             0x0010
-#define RSR_CE             0x0008
-#define RSR_FAE            0x0004
-#define RSR_CRC            0x0002
-#define RSR_VIDM           0x0001
-
-/*
- * Bits in the RSR1 register
- */
-
-#define RSR_RXOK           0x8000	// rx OK
-#define RSR_PFT            0x4000	// Perfect filtering address match
-#define RSR_MAR            0x2000	// MAC accept multicast address packet
-#define RSR_BAR            0x1000	// MAC accept broadcast address packet
-#define RSR_PHY            0x0800	// MAC accept physical address packet
-#define RSR_VTAG           0x0400	// 802.1p/1q tagging packet indicator
-#define RSR_STP            0x0200	// start of packet
-#define RSR_EDP            0x0100	// end of packet
-
-/*
- * Bits in the RSR1 register
- */
-
-#define RSR1_RXOK           0x80	// rx OK
-#define RSR1_PFT            0x40	// Perfect filtering address match
-#define RSR1_MAR            0x20	// MAC accept multicast address packet
-#define RSR1_BAR            0x10	// MAC accept broadcast address packet
-#define RSR1_PHY            0x08	// MAC accept physical address packet
-#define RSR1_VTAG           0x04	// 802.1p/1q tagging packet indicator
-#define RSR1_STP            0x02	// start of packet
-#define RSR1_EDP            0x01	// end of packet
-
-/*
- * Bits in the CSM register
- */
-
-#define CSM_IPOK            0x40	//IP Checkusm validatiaon ok
-#define CSM_TUPOK           0x20	//TCP/UDP Checkusm validatiaon ok
-#define CSM_FRAG            0x10	//Fragment IP datagram
-#define CSM_IPKT            0x04	//Received an IP packet
-#define CSM_TCPKT           0x02	//Received a TCP packet
-#define CSM_UDPKT           0x01	//Received a UDP packet
-
-/*
- * Bits in the TSR0 register
- */
-
-#define TSR0_ABT            0x0080	// Tx abort because of excessive collision
-#define TSR0_OWT            0x0040	// Jumbo frame Tx abort
-#define TSR0_OWC            0x0020	// Out of window collision
-#define TSR0_COLS           0x0010	// experience collision in this transmit event
-#define TSR0_NCR3           0x0008	// collision retry counter[3]
-#define TSR0_NCR2           0x0004	// collision retry counter[2]
-#define TSR0_NCR1           0x0002	// collision retry counter[1]
-#define TSR0_NCR0           0x0001	// collision retry counter[0]
-#define TSR0_TERR           0x8000	//
-#define TSR0_FDX            0x4000	// current transaction is serviced by full duplex mode
-#define TSR0_GMII           0x2000	// current transaction is serviced by GMII mode
-#define TSR0_LNKFL          0x1000	// packet serviced during link down
-#define TSR0_SHDN           0x0400	// shutdown case
-#define TSR0_CRS            0x0200	// carrier sense lost
-#define TSR0_CDH            0x0100	// AQE test fail (CD heartbeat)
-
-/*
- * Bits in the TSR1 register
- */
-
-#define TSR1_TERR           0x80	//
-#define TSR1_FDX            0x40	// current transaction is serviced by full duplex mode
-#define TSR1_GMII           0x20	// current transaction is serviced by GMII mode
-#define TSR1_LNKFL          0x10	// packet serviced during link down
-#define TSR1_SHDN           0x04	// shutdown case
-#define TSR1_CRS            0x02	// carrier sense lost
-#define TSR1_CDH            0x01	// AQE test fail (CD heartbeat)
-
-//
-// Bits in the TCR0 register
-//
-#define TCR0_TIC            0x80	// assert interrupt immediately while descriptor has been send complete
-#define TCR0_PIC            0x40	// priority interrupt request, INA# is issued over adaptive interrupt scheme
-#define TCR0_VETAG          0x20	// enable VLAN tag
-#define TCR0_IPCK           0x10	// request IP  checksum calculation.
-#define TCR0_UDPCK          0x08	// request UDP checksum calculation.
-#define TCR0_TCPCK          0x04	// request TCP checksum calculation.
-#define TCR0_JMBO           0x02	// indicate a jumbo packet in GMAC side
-#define TCR0_CRC            0x01	// disable CRC generation
-
-#define TCPLS_NORMAL        3
-#define TCPLS_START         2
-#define TCPLS_END           1
-#define TCPLS_MED           0
-
 
 // max transmit or receive buffer size
 #define CB_RX_BUF_SIZE     2048UL	// max buffer size
@@ -193,68 +86,114 @@
 /*
  *	Receive descriptor
  */
-
-struct rdesc0 {
-	u16 RSR;		/* Receive status */
-	u16 len:14;		/* Received packet length */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns this buffer ? */
-};
-
-struct rdesc1 {
-	u16 PQTAG;
-	u8 CSM;
-	u8 IPKT;
-};
-
 struct rx_desc {
-	struct rdesc0 rdesc0;
-	struct rdesc1 rdesc1;
+	u32 rdesc0;
+	u32 rdesc1;
 	u32 pa_low;		/* Low 32 bit PCI address */
-	u16 pa_high;		/* Next 16 bit PCI address (48 total) */
-	u16 len:15;		/* Frame size */
-	u16 inten:1;		/* Enable interrupt */
-} __attribute__ ((__packed__));
+	u32 rdesc3;
+};
+
+#define RDESC0_OWNED_BY_NIC	0x80000000
+#define RDESC0_LEN		0x3fff0000
+#define RDESC0_LEN_SHIFT		16
+#define RDESC0_LEN_MASK			0x00003fff
+#define RDESC0_RSR		0x0000ffff
+#define RDESC0_RSR_RXOK		0x00008000
+#define RDESC0_RSR_PFT		0x00004000
+#define RDESC0_RSR_MAR		0x00002000
+#define RDESC0_RSR_BAR		0x00001000
+#define RDESC0_RSR_PHY		0x00000800
+#define RDESC0_RSR_VTAG		0x00000400
+#define RDESC0_RSR_STP		0x00000200
+#define RDESC0_RSR_EDP		0x00000100
+#define RDESC0_RSR_DETAG	0x00000080
+#define RDESC0_RSR_SNTAG	0x00000040
+#define RDESC0_RSR_RXER		0x00000020
+#define RDESC0_RSR_RL		0x00000010
+#define RDESC0_RSR_CE		0x00000008
+#define RDESC0_RSR_FAE		0x00000004
+#define RDESC0_RSR_CRC		0x00000002
+#define RDESC0_RSR_VIDM		0x00000001
+
+#define RDESC1_IPKT		0xff000000
+#define RDESC1_CSM		0x00ff0000
+#define RDESC1_CSM_IPOK		0x00400000
+#define RDESC1_CSM_TUPOK	0x00200000
+#define RDESC1_CSM_FRAG		0x00100000
+#define RDESC1_CSM_IPKT		0x00040000
+#define RDESC1_CSM_TCPKT	0x00020000
+#define RDESC1_CSM_UDPKT	0x00010000
+#define RDESC1_PQTAG		0x0000ffff
+
+#define RDESC3_INTEN		0x80000000
+#define RDESC3_LEN		0x3fff0000
+#define RDESC3_PA_HIGH		0x0000ffff
 
 /*
  *	Transmit descriptor
  */
 
-struct tdesc0 {
-	u16 TSR;		/* Transmit status register */
-	u16 pktsize:14;		/* Size of frame */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns the buffer */
-};
-
-struct pqinf {			/* Priority queue info */
-	u16 VID:12;
-	u16 CFI:1;
-	u16 priority:3;
-} __attribute__ ((__packed__));
-
-struct tdesc1 {
-	struct pqinf pqinf;
-	u8 TCR;
-	u8 TCPLS:2;
-	u8 reserved:2;
-	u8 CMDZ:4;
-} __attribute__ ((__packed__));
-
 struct td_buf {
 	u32 pa_low;
-	u16 pa_high;
-	u16 bufsize:14;	
-	u16 reserved:1;
-	u16 queue:1;
-} __attribute__ ((__packed__));
+	u32 td_buf1;
+};
+
+#define TD_BUF1_QUEUE		0x80000000
+#define TD_BUF1_BUFSIZE		0x3fff0000
+#define TD_BUF1_BUFSIZE_SHIFT		16
+#define TD_BUF1_BUFSIZE_MASK		0x00003fff
+#define TD_BUF1_PA_HIGH		0x0000ffff
 
 struct tx_desc {
-	struct tdesc0 tdesc0;
-	struct tdesc1 tdesc1;
+	u32 tdesc0;
+	u32 tdesc1;
 	struct td_buf td_buf[7];
 };
 
+#define TDESC0_OWNED_BY_NIC	0x80000000
+#define TDESC0_PKTSIZE		0x3fff0000
+#define TDESC0_PKTSIZE_SHIFT		16
+#define TDESC0_PKTSIZE_MASK		0x00003fff
+#define TDESC0_TSR		0x0000ffff
+#define TDESC0_TSR_TERR		0x00008000
+#define TDESC0_TSR_FDX		0x00004000
+#define TDESC0_TSR_GMII		0x00002000
+#define TDESC0_TSR_LNKFL	0x00001000
+#define TDESC0_TSR_SHDN		0x00000400
+#define TDESC0_TSR_CRS		0x00000200
+#define TDESC0_TSR_CDH		0x00000100
+#define TDESC0_TSR_ABT		0x00000080
+#define TDESC0_TSR_OWT		0x00000040
+#define TDESC0_TSR_OWC		0x00000020
+#define TDESC0_TSR_COLS		0x00000010
+#define TDESC0_TSR_NCR3		0x00000008
+#define TDESC0_TSR_NCR2		0x00000004
+#define TDESC0_TSR_NCR1		0x00000002
+#define TDESC0_TSR_NCR0		0x00000001
+
+#define TDESC1_CMDZ		0xf0000000
+#define TDESC1_CMDZ_SHIFT		28
+#define TDESC1_CMDZ_MASK		0x0000000f
+#define TDESC1_TCPLS		0x03000000
+#define TDESC1_TCPLS_NORMAL	0x03000000
+#define TDESC1_TCPLS_START	0x02000000
+#define TDESC1_TCPLS_END	0x01000000
+#define TDESC1_TCPLS_MED	0x00000000
+#define TDESC1_TCR		0x00ff0000
+#define TDESC1_TCR_TIC		0x00800000
+#define TDESC1_TCR_PIC		0x00400000
+#define TDESC1_TCR_VETAG	0x00200000
+#define TDESC1_TCR_IPCK		0x00100000
+#define TDESC1_TCR_UDPCK	0x00080000
+#define TDESC1_TCR_TCPCK	0x00040000
+#define TDESC1_TCR_JMBO		0x00020000
+#define TDESC1_TCR_CRC		0x00010000
+#define TDESC1_PRIORITY		0x0000e000
+#define TDESC1_CFI		0x00001000
+#define TDESC1_VID		0x00000fff
+#define TDESC1_VID_SHIFT		0
+#define TDESC1_VID_MASK			0x00000fff
+
 struct velocity_rd_info {
 	struct sk_buff *skb;
 	dma_addr_t skb_dma;
@@ -291,10 +230,6 @@ struct velocity_td_info {
 	dma_addr_t buf_dma;
 };
 
-enum  velocity_owner {
-	OWNED_BY_HOST = 0,
-	OWNED_BY_NIC = 1
-};
 
 
 /*
