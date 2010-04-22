From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 15:53:32 -0700 (PDT)
Message-ID: <20100422.155332.26350121.davem@davemloft.net>
References: <20100422.042157.99869295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38076
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753268Ab0DVWx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:53:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DBAD824C090
	for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 15:53:32 -0700 (PDT)
In-Reply-To: <20100422.042157.99869295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, based upon Stephen's feedback I added the ethtool bits,
here is the final version I committed to net-next-2.6:

--------------------
niu: Add skb->rxhash support.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   52 ++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/niu.h |    7 +++++--
 2 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 493e25c..30abb4e 100644
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
@@ -3510,8 +3507,17 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 	}
 	rp->rcr_index = index;
 
-	skb_reserve(skb, NET_IP_ALIGN);
-	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
+	len += sizeof(*rh);
+	len = min_t(int, len, sizeof(*rh) + VLAN_ETH_HLEN);
+	__pskb_pull_tail(skb, len);
+
+	rh = (struct rx_pkt_hdr1 *) skb->data;
+	if (np->dev->features & NETIF_F_RXHASH)
+		skb->rxhash = ((u32)rh->hashval2_0 << 24 |
+			       (u32)rh->hashval2_1 << 16 |
+			       (u32)rh->hashval1_1 << 8 |
+			       (u32)rh->hashval1_2 << 0);
+	skb_pull(skb, sizeof(*rh));
 
 	rp->rx_packets++;
 	rp->rx_bytes += skb->len;
@@ -4946,7 +4952,9 @@ static int niu_init_one_rx_channel(struct niu *np, struct rx_ring_info *rp)
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
@@ -7910,6 +7918,18 @@ static int niu_phys_id(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int niu_set_flags(struct net_device *dev, u32 data)
+{
+	if (data & (ETH_FLAG_LRO | ETH_FLAG_NTUPLE))
+		return -EOPNOTSUPP;
+
+	if (data & ETH_FLAG_RXHASH)
+		dev->features |= NETIF_F_RXHASH;
+	else
+		dev->features &= ~NETIF_F_RXHASH;
+	return 0;
+}
+
 static const struct ethtool_ops niu_ethtool_ops = {
 	.get_drvinfo		= niu_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -7926,6 +7946,8 @@ static const struct ethtool_ops niu_ethtool_ops = {
 	.phys_id		= niu_phys_id,
 	.get_rxnfc		= niu_get_nfc,
 	.set_rxnfc		= niu_set_nfc,
+	.set_flags		= niu_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
@@ -9754,6 +9776,12 @@ static void __devinit niu_device_announce(struct niu *np)
 	}
 }
 
+static void __devinit niu_set_basic_features(struct net_device *dev)
+{
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM |
+			  NETIF_F_GRO | NETIF_F_RXHASH);
+}
+
 static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
@@ -9838,7 +9866,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		}
 	}
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GRO);
+	niu_set_basic_features(dev);
 
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
@@ -10080,7 +10108,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 		goto err_out_free_dev;
 	}
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
+	niu_set_basic_features(dev);
 
 	np->regs = of_ioremap(&op->resource[1], 0,
 			      resource_size(&op->resource[1]),
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
-- 
1.7.0.4

