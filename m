From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] sky2: add support for receive hashing
Date: Thu, 22 Apr 2010 16:42:57 -0700
Message-ID: <20100422234319.149785036@vyatta.com>
References: <20100422234255.150547953@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45044 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab0DVX4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 19:56:43 -0400
Content-Disposition: inline; filename=sky2-rxhash.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sky2 hardware supports hardware receive hash calculation.
This enables it unless the chip is probably broken. The list of broken
devices is derived from vendor sk98lin which has fragments of code
for RSS support but never uses it. Setup information for this in the
chip documention is incomplete, so some of this is just best guess.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/sky2.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/sky2.h |   23 ++++++++++++++++
 2 files changed, 96 insertions(+), 2 deletions(-)

--- a/drivers/net/sky2.c	2010-04-22 16:27:35.936207387 -0700
+++ b/drivers/net/sky2.c	2010-04-22 16:29:15.955269083 -0700
@@ -1193,6 +1193,39 @@ static void rx_set_checksum(struct sky2_
 		     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 }
 
+/* Enable/disable receive hash calculation (RSS) */
+static void rx_set_rss(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	int i, nkeys = 4;
+
+	/* Supports IPv6 and other modes */
+	if (hw->flags & SKY2_HW_NEW_LE) {
+		nkeys = 10;
+		sky2_write32(hw, SK_REG(sky2->port, RSS_CFG), HASH_ALL);
+	}
+
+	/* Program RSS initial values */
+	if (dev->features & NETIF_F_RXHASH) {
+		u32 key[nkeys];
+
+		get_random_bytes(key, nkeys * sizeof(u32));
+		for (i = 0; i < nkeys; i++)
+			sky2_write32(hw, SK_REG(sky2->port, RSS_KEY + i * 4),
+				     key[i]);
+
+		/* Need to turn on (undocumented) flag to make hashing work  */
+		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T),
+			     RX_STFW_ENA);
+
+		sky2_write32(hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     BMU_ENA_RX_RSS_HASH);
+	} else
+		sky2_write32(hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     BMU_DIS_RX_RSS_HASH);
+}
+
 /*
  * The RX Stop command will not work for Yukon-2 if the BMU does not
  * reach the end of packet and since we can't make sure that we have
@@ -1425,6 +1458,9 @@ static void sky2_rx_start(struct sky2_po
 	if (!(hw->flags & SKY2_HW_NEW_LE))
 		rx_set_checksum(sky2);
 
+	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
+		rx_set_rss(sky2->netdev);
+
 	/* submit Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
@@ -2534,6 +2570,14 @@ static void sky2_rx_checksum(struct sky2
 	}
 }
 
+static void sky2_rx_hash(struct sky2_port *sky2, u32 status)
+{
+	struct sk_buff *skb;
+
+	skb = sky2->rx_ring[sky2->rx_next].skb;
+	skb->rxhash = le32_to_cpu(status);
+}
+
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 {
@@ -2606,6 +2650,10 @@ static int sky2_status_intr(struct sky2_
 				sky2_rx_checksum(sky2, status);
 			break;
 
+		case OP_RSS_HASH:
+			sky2_rx_hash(sky2, status);
+			break;
+
 		case OP_TXINDEXLE:
 			/* TX index reports status for both ports */
 			sky2_tx_done(hw->dev[0], status & 0xfff);
@@ -2960,6 +3008,8 @@ static int __devinit sky2_init(struct sk
 	switch(hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
+		if (hw->chip_rev < CHIP_REV_YU_XL_A2)
+			hw->flags |= SKY2_HW_RSS_BROKEN;
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
@@ -2985,10 +3035,11 @@ static int __devinit sky2_init(struct sk
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT;
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_RSS_BROKEN;
 		break;
 
 	case CHIP_ID_YUKON_FE:
+		hw->flags = SKY2_HW_RSS_BROKEN;
 		break;
 
 	case CHIP_ID_YUKON_FE_P:
@@ -4112,6 +4163,28 @@ static int sky2_set_eeprom(struct net_de
 	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->len);
 }
 
+static int sky2_set_flags(struct net_device *dev, u32 data)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+
+	if (data & ETH_FLAG_LRO)
+		return -EOPNOTSUPP;
+
+	if (data & ETH_FLAG_NTUPLE)
+		return -EOPNOTSUPP;
+
+	if (data & ETH_FLAG_RXHASH) {
+		if (sky2->hw->flags & SKY2_HW_RSS_BROKEN)
+			return -EINVAL;
+
+		dev->features |= NETIF_F_RXHASH;
+	} else
+		dev->features &= ~NETIF_F_RXHASH;
+
+	rx_set_rss(dev);
+
+	return 0;
+}
 
 static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_settings	= sky2_get_settings,
@@ -4143,6 +4216,7 @@ static const struct ethtool_ops sky2_eth
 	.phys_id	= sky2_phys_id,
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
+	.set_flags	= sky2_set_flags,
 };
 
 #ifdef CONFIG_SKY2_DEBUG
@@ -4491,6 +4565,11 @@ static __devinit struct net_device *sky2
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
+#ifdef CONFIG_RPS
+	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
+		dev->features |= NETIF_F_RXHASH;
+#endif
+
 #ifdef SKY2_VLAN_TAG_USED
 	/* The workaround for FE+ status conflicts with VLAN tag detection. */
 	if (!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
@@ -4687,7 +4766,7 @@ static int __devinit sky2_probe(struct p
 		goto err_out_iounmap;
 
 	/* ring for status responses */
-	hw->st_size = hw->ports * roundup_pow_of_two(2*RX_MAX_PENDING + TX_MAX_PENDING);
+	hw->st_size = hw->ports * roundup_pow_of_two(3*RX_MAX_PENDING + TX_MAX_PENDING);
 	hw->st_le = pci_alloc_consistent(pdev, hw->st_size * sizeof(struct sky2_status_le),
 					 &hw->st_dma);
 	if (!hw->st_le)
--- a/drivers/net/sky2.h	2010-04-22 16:26:46.076521722 -0700
+++ b/drivers/net/sky2.h	2010-04-22 16:29:15.965276892 -0700
@@ -694,8 +694,21 @@ enum {
 	TXA_CTRL	= 0x0210,/*  8 bit	Tx Arbiter Control Register */
 	TXA_TEST	= 0x0211,/*  8 bit	Tx Arbiter Test Register */
 	TXA_STAT	= 0x0212,/*  8 bit	Tx Arbiter Status Register */
+
+	RSS_KEY		= 0x0220, /* RSS Key setup */
+	RSS_CFG		= 0x0248, /* RSS Configuration */
 };
 
+enum {
+	HASH_TCP_IPV6_EX_CTRL	= 1<<5,
+	HASH_IPV6_EX_CTRL	= 1<<4,
+	HASH_TCP_IPV6_CTRL	= 1<<3,
+	HASH_IPV6_CTRL		= 1<<2,
+	HASH_TCP_IPV4_CTRL	= 1<<1,
+	HASH_IPV4_CTRL		= 1<<0,
+
+	HASH_ALL		= 0x3f,
+};
 
 enum {
 	B6_EXT_REG	= 0x0300,/* External registers (GENESIS only) */
@@ -2261,6 +2274,7 @@ struct sky2_hw {
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
+#define SKY2_HW_RSS_BROKEN	0x00000100
 
 	u8	     	     chip_id;
 	u8		     chip_rev;

-- 

