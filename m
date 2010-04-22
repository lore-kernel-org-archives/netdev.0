From: David Miller <davem@davemloft.net>
Subject: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 04:21:57 -0700 (PDT)
Message-ID: <20100422.042157.99869295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753843Ab0DVLVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 07:21:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7A96624C11A
	for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 04:21:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


But it turns out using it is largely pointless since the only way to
get the hash value(s) is through a structure which is prepended to the
packet data (so we take a cache miss on the packet data anyways)
instead of being able to fetch it out of the RX descriptors :-/

If anyone out there is trying to design sane hardware, please put the
following into your RX descriptors:

1) ethernet protocol type (u16)
2) a flag bit indicating if the packet destination matched one
   of the programmed unicast MAC addresses
3) a flag bit indicating "multicast"
4) a flag bit indicating "broadcast"
5) at least 32-bits of the computed flow hash (u32)

kthx, bye!

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 493e25c..f8ee985 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -36,8 +36,8 @@
 #include "niu.h"
 
 #define DRV_MODULE_NAME		"niu"
-#define DRV_MODULE_VERSION	"1.0"
-#define DRV_MODULE_RELDATE	"Nov 14, 2008"
+#define DRV_MODULE_VERSION	"1.1"
+#define DRV_MODULE_RELDATE	"Apr 22, 2010"
 
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
@@ -3444,6 +3444,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 			      struct rx_ring_info *rp)
 {
 	unsigned int index = rp->rcr_index;
+	struct rx_pkt_hdr1 *rh;
 	struct sk_buff *skb;
 	int len, num_rcr;
 
@@ -3477,9 +3478,6 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 		if (num_rcr == 1) {
 			int ptype;
 
-			off += 2;
-			append_size -= 2;
-
 			ptype = (val >> RCR_ENTRY_PKT_TYPE_SHIFT);
 			if ((ptype == RCR_PKT_TYPE_TCP ||
 			     ptype == RCR_PKT_TYPE_UDP) &&
@@ -3488,8 +3486,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			else
 				skb->ip_summed = CHECKSUM_NONE;
-		}
-		if (!(val & RCR_ENTRY_MULTI))
+		} else if (!(val & RCR_ENTRY_MULTI))
 			append_size = len - skb->len;
 
 		niu_rx_skb_append(skb, page, off, append_size);
@@ -3510,8 +3507,16 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 	}
 	rp->rcr_index = index;
 
-	skb_reserve(skb, NET_IP_ALIGN);
-	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
+	len += sizeof(*rh);
+	len = min_t(int, len, sizeof(*rh) + VLAN_ETH_HLEN);
+	__pskb_pull_tail(skb, len);
+
+	rh = (struct rx_pkt_hdr1 *) skb->data;
+	skb->rxhash = ((u32)rh->hashval2_0 << 24 |
+		       (u32)rh->hashval2_1 << 16 |
+		       (u32)rh->hashval1_1 << 8 |
+		       (u32)rh->hashval1_2 << 0);
+	skb_pull(skb, sizeof(*rh));
 
 	rp->rx_packets++;
 	rp->rx_bytes += skb->len;
@@ -4946,7 +4951,9 @@ static int niu_init_one_rx_channel(struct niu *np, struct rx_ring_info *rp)
 	      RX_DMA_CTL_STAT_RCRTO |
 	      RX_DMA_CTL_STAT_RBR_EMPTY));
 	nw64(RXDMA_CFIG1(channel), rp->mbox_dma >> 32);
-	nw64(RXDMA_CFIG2(channel), (rp->mbox_dma & 0x00000000ffffffc0));
+	nw64(RXDMA_CFIG2(channel),
+	     ((rp->mbox_dma & RXDMA_CFIG2_MBADDR_L) |
+	      RXDMA_CFIG2_FULL_HDR));
 	nw64(RBR_CFIG_A(channel),
 	     ((u64)rp->rbr_table_size << RBR_CFIG_A_LEN_SHIFT) |
 	     (rp->rbr_dma & (RBR_CFIG_A_STADDR_BASE | RBR_CFIG_A_STADDR)));
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 3bd0b59..d671546 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2706,7 +2706,7 @@ struct rx_pkt_hdr0 {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
 	u8	inputport:2,
 		maccheck:1,
-		class:4;
+		class:5;
 	u8	vlan:1,
 		llcsnap:1,
 		noport:1,
@@ -2715,7 +2715,7 @@ struct rx_pkt_hdr0 {
 		tres:2,
 		tzfvld:1;
 #elif defined(__BIG_ENDIAN_BITFIELD)
-	u8	class:4,
+	u8	class:5,
 		maccheck:1,
 		inputport:2;
 	u8	tzfvld:1,
@@ -2775,6 +2775,9 @@ struct rx_pkt_hdr1 {
 	/* Bits 7:0 of hash value, H1.  */
 	u8	hashval1_2;
 
+	u8	hwrsvd5;
+	u8	hwrsvd6;
+
 	u8	usrdata_0;	/* Bits 39:32 of user data.  */
 	u8	usrdata_1;	/* Bits 31:24 of user data.  */
 	u8	usrdata_2;	/* Bits 23:16 of user data.  */
