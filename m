From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 29/39] mv643xx_eth: general cleanup
Date: Tue,  3 Jun 2008 13:02:44 +0200
Message-ID: <1212490974-23719-30-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48751 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755603AbYFCMAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:40 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

General cleanup of the mv643xx_eth driver.  Mainly fixes coding
style / indentation issues, get rid of some useless 'volatile's,
kill some more superfluous comments, and such.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c   |  939 ++++++++++++++++++++-----------------------
 include/linux/mv643xx_eth.h |   59 ++-
 2 files changed, 469 insertions(+), 529 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ef1c461..ff31cd8 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -59,8 +59,6 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define MAX_DESCS_PER_SKB	1
 #endif
 
-#define ETH_HW_IP_ALIGN		2
-
 /*
  * Registers shared between all ports.
  */
@@ -149,12 +147,6 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define DEFAULT_RX_QUEUE_SIZE		400
 #define DEFAULT_TX_QUEUE_SIZE		800
 
-/* SMI reg */
-#define SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
-#define SMI_READ_VALID		0x08000000	/* 0 - Write, 1 - Read	*/
-#define SMI_OPCODE_WRITE	0		/* Completion of Read	*/
-#define SMI_OPCODE_READ		0x04000000	/* Operation is in progress */
-
 
 /*
  * RX/TX descriptors.
@@ -222,13 +214,24 @@ struct tx_desc {
 
 /* global *******************************************************************/
 struct mv643xx_eth_shared_private {
+	/*
+	 * Ethernet controller base address.
+	 */
 	void __iomem *base;
 
-	/* used to protect SMI_REG, which is shared across ports */
+	/*
+	 * Protects access to SMI_REG, which is shared between ports.
+	 */
 	spinlock_t phy_lock;
 
+	/*
+	 * Per-port MBUS window access register value.
+	 */
 	u32 win_protect;
 
+	/*
+	 * Hardware-specific parameters.
+	 */
 	unsigned int t_clk;
 };
 
@@ -297,16 +300,17 @@ struct tx_queue {
 
 struct mv643xx_eth_private {
 	struct mv643xx_eth_shared_private *shared;
-	int port_num;			/* User Ethernet port number	*/
+	int port_num;
 
-	struct mv643xx_eth_shared_private *shared_smi;
+	struct net_device *dev;
 
-	struct work_struct tx_timeout_task;
+	struct mv643xx_eth_shared_private *shared_smi;
+	int phy_addr;
 
-	struct net_device *dev;
-	struct mib_counters mib_counters;
 	spinlock_t lock;
 
+	struct mib_counters mib_counters;
+	struct work_struct tx_timeout_task;
 	struct mii_if_info mii;
 
 	/*
@@ -441,7 +445,7 @@ static void rxq_refill(struct rx_queue *rxq)
 						RX_ENABLE_INTERRUPT;
 		wmb();
 
-		skb_reserve(skb, ETH_HW_IP_ALIGN);
+		skb_reserve(skb, 2);
 	}
 
 	if (rxq->rx_desc_count == 0) {
@@ -465,9 +469,9 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 
 	rx = 0;
 	while (rx < budget) {
-		struct sk_buff *skb;
-		volatile struct rx_desc *rx_desc;
+		struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
+		struct sk_buff *skb;
 		unsigned long flags;
 
 		spin_lock_irqsave(&mep->lock, flags);
@@ -488,8 +492,8 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 
 		spin_unlock_irqrestore(&mep->lock, flags);
 
-		dma_unmap_single(NULL, rx_desc->buf_ptr + ETH_HW_IP_ALIGN,
-					mep->dev->mtu + 24, DMA_FROM_DEVICE);
+		dma_unmap_single(NULL, rx_desc->buf_ptr + 2,
+				 mep->dev->mtu + 24, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
 		rx++;
 
@@ -498,24 +502,26 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		 * Note byte count includes 4 byte CRC count
 		 */
 		stats->rx_packets++;
-		stats->rx_bytes += rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
+		stats->rx_bytes += rx_desc->byte_cnt - 2;
 
 		/*
-		 * In case received a packet without first / last bits on OR
-		 * the error summary bit is on, the packets needs to be dropeed.
+		 * In case we received a packet without first / last bits
+		 * on, or the error summary bit is set, the packet needs
+		 * to be dropped.
 		 */
 		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 					(RX_FIRST_DESC | RX_LAST_DESC))
 				|| (cmd_sts & ERROR_SUMMARY)) {
 			stats->rx_dropped++;
+
 			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 				(RX_FIRST_DESC | RX_LAST_DESC)) {
 				if (net_ratelimit())
-					printk(KERN_ERR
-						"%s: Received packet spread "
-						"on multiple descriptors\n",
-						mep->dev->name);
+					dev_printk(KERN_ERR, &mep->dev->dev,
+						   "received packet spanning "
+						   "multiple descriptors\n");
 			}
+
 			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
@@ -525,7 +531,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
 			 */
-			skb_put(skb, rx_desc->byte_cnt - ETH_HW_IP_ALIGN - 4);
+			skb_put(skb, rx_desc->byte_cnt - 2 - 4);
 
 			if (cmd_sts & LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -539,8 +545,10 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			netif_rx(skb);
 #endif
 		}
+
 		mep->dev->last_rx = jiffies;
 	}
+
 	rxq_refill(rxq);
 
 	return rx;
@@ -707,7 +715,7 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	txq->tx_desc_count += nr_frags + 1;
 }
 
-static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
@@ -718,8 +726,9 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
 		stats->tx_dropped++;
-		printk(KERN_DEBUG "%s: failed to linearize tiny "
-				"unaligned fragment\n", dev->name);
+		dev_printk(KERN_DEBUG, &dev->dev,
+			   "failed to linearize skb with tiny "
+			   "unaligned fragment\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -749,13 +758,15 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 
 /* mii management interface *************************************************/
-static int phy_addr_get(struct mv643xx_eth_private *mep);
+#define SMI_BUSY		0x10000000
+#define SMI_READ_VALID		0x08000000
+#define SMI_OPCODE_READ		0x04000000
+#define SMI_OPCODE_WRITE	0x00000000
 
-static void read_smi_reg(struct mv643xx_eth_private *mep,
-				unsigned int phy_reg, unsigned int *value)
+static void smi_reg_read(struct mv643xx_eth_private *mep, unsigned int addr,
+			 unsigned int reg, unsigned int *value)
 {
 	void __iomem *smi_reg = mep->shared_smi->base + SMI_REG;
-	int phy_addr = phy_addr_get(mep);
 	unsigned long flags;
 	int i;
 
@@ -771,7 +782,7 @@ static void read_smi_reg(struct mv643xx_eth_private *mep,
 		udelay(10);
 	}
 
-	writel((phy_addr << 16) | (phy_reg << 21) | SMI_OPCODE_READ, smi_reg);
+	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
 	/* now wait for the data to be valid */
 	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
@@ -787,11 +798,11 @@ out:
 	spin_unlock_irqrestore(&mep->shared_smi->phy_lock, flags);
 }
 
-static void write_smi_reg(struct mv643xx_eth_private *mep,
-				   unsigned int phy_reg, unsigned int value)
+static void smi_reg_write(struct mv643xx_eth_private *mep,
+			  unsigned int addr,
+			  unsigned int reg, unsigned int value)
 {
 	void __iomem *smi_reg = mep->shared_smi->base + SMI_REG;
-	int phy_addr = phy_addr_get(mep);
 	unsigned long flags;
 	int i;
 
@@ -807,65 +818,63 @@ static void write_smi_reg(struct mv643xx_eth_private *mep,
 		udelay(10);
 	}
 
-	writel((phy_addr << 16) | (phy_reg << 21) |
-		SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
+	writel(SMI_OPCODE_WRITE | (reg << 21) |
+		(addr << 16) | (value & 0xffff), smi_reg);
 out:
 	spin_unlock_irqrestore(&mep->shared_smi->phy_lock, flags);
 }
 
 
 /* mib counters *************************************************************/
-static void clear_mib_counters(struct mv643xx_eth_private *mep)
+static inline u32 mib_read(struct mv643xx_eth_private *mep, int offset)
 {
-	unsigned int port_num = mep->port_num;
-	int i;
-
-	/* Perform dummy reads from MIB counters */
-	for (i = 0; i < 0x80; i += 4)
-		rdl(mep, MIB_COUNTERS(port_num) + i);
+	return rdl(mep, MIB_COUNTERS(mep->port_num) + offset);
 }
 
-static inline u32 read_mib(struct mv643xx_eth_private *mep, int offset)
+static void mib_counters_clear(struct mv643xx_eth_private *mep)
 {
-	return rdl(mep, MIB_COUNTERS(mep->port_num) + offset);
+	int i;
+
+	for (i = 0; i < 0x80; i += 4)
+		mib_read(mep, i);
 }
 
-static void update_mib_counters(struct mv643xx_eth_private *mep)
+static void mib_counters_update(struct mv643xx_eth_private *mep)
 {
 	struct mib_counters *p = &mep->mib_counters;
 
-	p->good_octets_received += read_mib(mep, 0x00);
-	p->good_octets_received += (u64)read_mib(mep, 0x04) << 32;
-	p->bad_octets_received += read_mib(mep, 0x08);
-	p->internal_mac_transmit_err += read_mib(mep, 0x0c);
-	p->good_frames_received += read_mib(mep, 0x10);
-	p->bad_frames_received += read_mib(mep, 0x14);
-	p->broadcast_frames_received += read_mib(mep, 0x18);
-	p->multicast_frames_received += read_mib(mep, 0x1c);
-	p->frames_64_octets += read_mib(mep, 0x20);
-	p->frames_65_to_127_octets += read_mib(mep, 0x24);
-	p->frames_128_to_255_octets += read_mib(mep, 0x28);
-	p->frames_256_to_511_octets += read_mib(mep, 0x2c);
-	p->frames_512_to_1023_octets += read_mib(mep, 0x30);
-	p->frames_1024_to_max_octets += read_mib(mep, 0x34);
-	p->good_octets_sent += read_mib(mep, 0x38);
-	p->good_octets_sent += (u64)read_mib(mep, 0x3c) << 32;
-	p->good_frames_sent += read_mib(mep, 0x40);
-	p->excessive_collision += read_mib(mep, 0x44);
-	p->multicast_frames_sent += read_mib(mep, 0x48);
-	p->broadcast_frames_sent += read_mib(mep, 0x4c);
-	p->unrec_mac_control_received += read_mib(mep, 0x50);
-	p->fc_sent += read_mib(mep, 0x54);
-	p->good_fc_received += read_mib(mep, 0x58);
-	p->bad_fc_received += read_mib(mep, 0x5c);
-	p->undersize_received += read_mib(mep, 0x60);
-	p->fragments_received += read_mib(mep, 0x64);
-	p->oversize_received += read_mib(mep, 0x68);
-	p->jabber_received += read_mib(mep, 0x6c);
-	p->mac_receive_error += read_mib(mep, 0x70);
-	p->bad_crc_event += read_mib(mep, 0x74);
-	p->collision += read_mib(mep, 0x78);
-	p->late_collision += read_mib(mep, 0x7c);
+	p->good_octets_received += mib_read(mep, 0x00);
+	p->good_octets_received += (u64)mib_read(mep, 0x04) << 32;
+	p->bad_octets_received += mib_read(mep, 0x08);
+	p->internal_mac_transmit_err += mib_read(mep, 0x0c);
+	p->good_frames_received += mib_read(mep, 0x10);
+	p->bad_frames_received += mib_read(mep, 0x14);
+	p->broadcast_frames_received += mib_read(mep, 0x18);
+	p->multicast_frames_received += mib_read(mep, 0x1c);
+	p->frames_64_octets += mib_read(mep, 0x20);
+	p->frames_65_to_127_octets += mib_read(mep, 0x24);
+	p->frames_128_to_255_octets += mib_read(mep, 0x28);
+	p->frames_256_to_511_octets += mib_read(mep, 0x2c);
+	p->frames_512_to_1023_octets += mib_read(mep, 0x30);
+	p->frames_1024_to_max_octets += mib_read(mep, 0x34);
+	p->good_octets_sent += mib_read(mep, 0x38);
+	p->good_octets_sent += (u64)mib_read(mep, 0x3c) << 32;
+	p->good_frames_sent += mib_read(mep, 0x40);
+	p->excessive_collision += mib_read(mep, 0x44);
+	p->multicast_frames_sent += mib_read(mep, 0x48);
+	p->broadcast_frames_sent += mib_read(mep, 0x4c);
+	p->unrec_mac_control_received += mib_read(mep, 0x50);
+	p->fc_sent += mib_read(mep, 0x54);
+	p->good_fc_received += mib_read(mep, 0x58);
+	p->bad_fc_received += mib_read(mep, 0x5c);
+	p->undersize_received += mib_read(mep, 0x60);
+	p->fragments_received += mib_read(mep, 0x64);
+	p->oversize_received += mib_read(mep, 0x68);
+	p->jabber_received += mib_read(mep, 0x6c);
+	p->mac_receive_error += mib_read(mep, 0x70);
+	p->bad_crc_event += mib_read(mep, 0x74);
+	p->collision += mib_read(mep, 0x78);
+	p->late_collision += mib_read(mep, 0x7c);
 }
 
 
@@ -935,7 +944,9 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	err = mii_ethtool_gset(&mep->mii, cmd);
 	spin_unlock_irq(&mep->lock);
 
-	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
+	/*
+	 * The MAC does not support 1000baseT_Half.
+	 */
 	cmd->supported &= ~SUPPORTED_1000baseT_Half;
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
@@ -947,6 +958,11 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int err;
 
+	/*
+	 * The MAC does not support 1000baseT_Half.
+	 */
+	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+
 	spin_lock_irq(&mep->lock);
 	err = mii_ethtool_sset(&mep->mii, cmd);
 	spin_unlock_irq(&mep->lock);
@@ -954,17 +970,17 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	return err;
 }
 
-static void mv643xx_eth_get_drvinfo(struct net_device *netdev,
-				struct ethtool_drvinfo *drvinfo)
+static void mv643xx_eth_get_drvinfo(struct net_device *dev,
+				    struct ethtool_drvinfo *drvinfo)
 {
 	strncpy(drvinfo->driver,  mv643xx_eth_driver_name, 32);
 	strncpy(drvinfo->version, mv643xx_eth_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "mv643xx", 32);
+	strncpy(drvinfo->bus_info, "platform", 32);
 	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
 }
 
-static int mv643xx_eth_nway_restart(struct net_device *dev)
+static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
@@ -974,33 +990,31 @@ static int mv643xx_eth_nway_restart(struct net_device *dev)
 static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-
 	return mii_link_ok(&mep->mii);
 }
 
-static void mv643xx_eth_get_strings(struct net_device *netdev, uint32_t stringset,
-				uint8_t *data)
+static void mv643xx_eth_get_strings(struct net_device *dev,
+				    uint32_t stringset, uint8_t *data)
 {
 	int i;
 
-	switch(stringset) {
-	case ETH_SS_STATS:
-		for (i=0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
+	if (stringset == ETH_SS_STATS) {
+		for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
 				mv643xx_eth_stats[i].stat_string,
 				ETH_GSTRING_LEN);
 		}
-		break;
 	}
 }
 
-static void mv643xx_eth_get_ethtool_stats(struct net_device *netdev,
-				struct ethtool_stats *stats, uint64_t *data)
+static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
+					  struct ethtool_stats *stats,
+					  uint64_t *data)
 {
-	struct mv643xx_eth_private *mep = netdev->priv;
+	struct mv643xx_eth_private *mep = dev->priv;
 	int i;
 
-	update_mib_counters(mep);
+	mib_counters_update(mep);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 		const struct mv643xx_eth_stats *stat;
@@ -1018,38 +1032,35 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *netdev,
 	}
 }
 
-static int mv643xx_eth_get_sset_count(struct net_device *netdev, int sset)
+static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset)
 {
-	switch (sset) {
-	case ETH_SS_STATS:
+	if (sset == ETH_SS_STATS)
 		return ARRAY_SIZE(mv643xx_eth_stats);
-	default:
-		return -EOPNOTSUPP;
-	}
+
+	return -EOPNOTSUPP;
 }
 
 static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
-	.get_settings           = mv643xx_eth_get_settings,
-	.set_settings           = mv643xx_eth_set_settings,
-	.get_drvinfo            = mv643xx_eth_get_drvinfo,
-	.get_link               = mv643xx_eth_get_link,
+	.get_settings		= mv643xx_eth_get_settings,
+	.set_settings		= mv643xx_eth_set_settings,
+	.get_drvinfo		= mv643xx_eth_get_drvinfo,
+	.nway_reset		= mv643xx_eth_nway_reset,
+	.get_link		= mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
+	.get_strings		= mv643xx_eth_get_strings,
+	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
 	.get_sset_count		= mv643xx_eth_get_sset_count,
-	.get_ethtool_stats      = mv643xx_eth_get_ethtool_stats,
-	.get_strings            = mv643xx_eth_get_strings,
-	.nway_reset		= mv643xx_eth_nway_restart,
 };
 
 
 /* address handling *********************************************************/
 static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
-	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = rdl(mep, MAC_ADDR_HIGH(port_num));
-	mac_l = rdl(mep, MAC_ADDR_LOW(port_num));
+	mac_h = rdl(mep, MAC_ADDR_HIGH(mep->port_num));
+	mac_l = rdl(mep, MAC_ADDR_LOW(mep->port_num));
 
 	addr[0] = (mac_h >> 24) & 0xff;
 	addr[1] = (mac_h >> 16) & 0xff;
@@ -1061,72 +1072,54 @@ static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *addr)
 
 static void init_mac_tables(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mep->port_num;
-	int table_index;
-
-	/* Clear DA filter unicast table (Ex_dFUT) */
-	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		wrl(mep, UNICAST_TABLE(port_num) + table_index, 0);
+	int i;
 
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0);
+	for (i = 0; i < 0x100; i += 4) {
+		wrl(mep, SPECIAL_MCAST_TABLE(mep->port_num) + i, 0);
+		wrl(mep, OTHER_MCAST_TABLE(mep->port_num) + i, 0);
 	}
+
+	for (i = 0; i < 0x10; i += 4)
+		wrl(mep, UNICAST_TABLE(mep->port_num) + i, 0);
 }
 
 static void set_filter_table_entry(struct mv643xx_eth_private *mep,
-					    int table, unsigned char entry)
+				   int table, unsigned char entry)
 {
 	unsigned int table_reg;
-	unsigned int tbl_offset;
-	unsigned int reg_offset;
-
-	tbl_offset = (entry / 4) * 4;	/* Register offset of DA table entry */
-	reg_offset = entry % 4;		/* Entry offset within the register */
 
 	/* Set "accepts frame bit" at specified table entry */
-	table_reg = rdl(mep, table + tbl_offset);
-	table_reg |= 0x01 << (8 * reg_offset);
-	wrl(mep, table + tbl_offset, table_reg);
+	table_reg = rdl(mep, table + (entry & 0xfc));
+	table_reg |= 0x01 << (8 * (entry & 3));
+	wrl(mep, table + (entry & 0xfc), table_reg);
 }
 
 static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
-	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	int table;
 
-	mac_l = (addr[4] << 8) | (addr[5]);
-	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) |
-							(addr[3] << 0);
+	mac_l = (addr[4] << 8) | addr[5];
+	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
 
-	wrl(mep, MAC_ADDR_LOW(port_num), mac_l);
-	wrl(mep, MAC_ADDR_HIGH(port_num), mac_h);
+	wrl(mep, MAC_ADDR_LOW(mep->port_num), mac_l);
+	wrl(mep, MAC_ADDR_HIGH(mep->port_num), mac_h);
 
-	/* Accept frames with this address */
-	table = UNICAST_TABLE(port_num);
+	table = UNICAST_TABLE(mep->port_num);
 	set_filter_table_entry(mep, table, addr[5] & 0x0f);
 }
 
-static void mv643xx_eth_update_mac_address(struct net_device *dev)
+static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
+	/* +2 is for the offset of the HW addr type */
+	memcpy(dev->dev_addr, addr + 2, 6);
+
 	init_mac_tables(mep);
 	uc_addr_set(mep, dev->dev_addr);
-}
-
-static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
-{
-	int i;
 
-	for (i = 0; i < 6; i++)
-		/* +2 is for the offset of the HW addr type */
-		dev->dev_addr[i] = ((unsigned char *)addr)[i + 2];
-	mv643xx_eth_update_mac_address(dev);
 	return 0;
 }
 
@@ -1148,95 +1141,53 @@ static int addr_crc(unsigned char *addr)
 	return crc;
 }
 
-static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *addr)
+static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	unsigned int port_num = mep->port_num;
-	int table;
-	int crc;
-
-	if ((addr[0] == 0x01) && (addr[1] == 0x00) &&
-	    (addr[2] == 0x5E) && (addr[3] == 0x00) && (addr[4] == 0x00)) {
-		table = SPECIAL_MCAST_TABLE(port_num);
-		set_filter_table_entry(mep, table, addr[5]);
-		return;
-	}
-
-	crc = addr_crc(addr);
-
-	table = OTHER_MCAST_TABLE(port_num);
-	set_filter_table_entry(mep, table, crc);
-}
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	u32 port_config;
+	struct dev_addr_list *addr;
+	int i;
 
-static void set_multicast_list(struct net_device *dev)
-{
+	port_config = rdl(mep, PORT_CONFIG(mep->port_num));
+	if (dev->flags & IFF_PROMISC)
+		port_config |= 0x00000001;
+	else
+		port_config &= ~0x00000001;
+	wrl(mep, PORT_CONFIG(mep->port_num), port_config);
 
-	struct dev_mc_list	*mc_list;
-	int			i;
-	int			table_index;
-	struct mv643xx_eth_private	*mep = netdev_priv(dev);
-	unsigned int		port_num = mep->port_num;
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		int port_num = mep->port_num;
+		u32 accept = 0x01010101;
 
-	/* If the device is in promiscuous mode or in all multicast mode,
-	 * we will fully populate both multicast tables with accept.
-	 * This is guaranteed to yield a match on all multicast addresses...
-	 */
-	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
-		for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-			/* Set all entries in DA filter special multicast
-			 * table (Ex_dFSMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0x01010101);
-
-			/* Set all entries in DA filter other multicast
-			 * table (Ex_dFOMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0x01010101);
+		for (i = 0; i < 0x100; i += 4) {
+			wrl(mep, SPECIAL_MCAST_TABLE(port_num) + i, accept);
+			wrl(mep, OTHER_MCAST_TABLE(port_num) + i, accept);
 		}
 		return;
 	}
 
-	/* We will clear out multicast tables every time we get the list.
-	 * Then add the entire new list...
-	 */
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
-
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0);
+	for (i = 0; i < 0x100; i += 4) {
+		wrl(mep, SPECIAL_MCAST_TABLE(mep->port_num) + i, 0);
+		wrl(mep, OTHER_MCAST_TABLE(mep->port_num) + i, 0);
 	}
 
-	/* Get pointer to net_device multicast list and add each one... */
-	for (i = 0, mc_list = dev->mc_list;
-			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
-			i++, mc_list = mc_list->next)
-		if (mc_list->dmi_addrlen == 6)
-			mc_addr(mep, mc_list->dmi_addr);
-}
+	for (addr = dev->mc_list; addr != NULL; addr = addr->next) {
+		u8 *a = addr->da_addr;
+		int table;
 
-static void mv643xx_eth_set_rx_mode(struct net_device *dev)
-{
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	u32 config_reg;
+		if (addr->da_addrlen != 6)
+			continue;
 
-	config_reg = rdl(mep, PORT_CONFIG(mep->port_num));
-	if (dev->flags & IFF_PROMISC)
-		config_reg |= 0x00000001;
-	else
-		config_reg &= ~0x00000001;
-	wrl(mep, PORT_CONFIG(mep->port_num), config_reg);
+		if (memcmp(a, "\x01\x00\x5e\x00\x00", 5) == 0) {
+			table = SPECIAL_MCAST_TABLE(mep->port_num);
+			set_filter_table_entry(mep, table, a[5]);
+		} else {
+			int crc = addr_crc(a);
 
-	set_multicast_list(dev);
+			table = OTHER_MCAST_TABLE(mep->port_num);
+			set_filter_table_entry(mep, table, crc);
+		}
+	}
 }
 
 
@@ -1474,10 +1425,7 @@ static void txq_deinit(struct tx_queue *txq)
 
 
 /* netdev ops and related ***************************************************/
-static void port_reset(struct mv643xx_eth_private *mep);
-
-static void mv643xx_eth_update_pscr(struct mv643xx_eth_private *mep,
-				    struct ethtool_cmd *ecmd)
+static void update_pscr(struct mv643xx_eth_private *mep, int speed, int duplex)
 {
 	u32 pscr_o;
 	u32 pscr_n;
@@ -1490,15 +1438,15 @@ static void mv643xx_eth_update_pscr(struct mv643xx_eth_private *mep,
 			    SET_FULL_DUPLEX_MODE   |
 			    MAX_RX_PACKET_MASK);
 
-	if (ecmd->speed == SPEED_1000) {
+	if (speed == SPEED_1000) {
 		pscr_n |= SET_GMII_SPEED_TO_1000 | MAX_RX_PACKET_9700BYTE;
 	} else {
-		if (ecmd->speed == SPEED_100)
+		if (speed == SPEED_100)
 			pscr_n |= SET_MII_SPEED_TO_100;
 		pscr_n |= MAX_RX_PACKET_1522BYTE;
 	}
 
-	if (ecmd->duplex == DUPLEX_FULL)
+	if (duplex == DUPLEX_FULL)
 		pscr_n |= SET_FULL_DUPLEX_MODE;
 
 	if (pscr_n != pscr_o) {
@@ -1515,27 +1463,30 @@ static void mv643xx_eth_update_pscr(struct mv643xx_eth_private *mep,
 	}
 }
 
-static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
+static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	u32 int_cause, int_cause_ext = 0;
+	u32 int_cause;
+	u32 int_cause_ext;
 
-	/* Read interrupt cause registers */
 	int_cause = rdl(mep, INT_CAUSE(mep->port_num)) & (INT_RX | INT_EXT);
+	if (int_cause == 0)
+		return IRQ_NONE;
+
+	int_cause_ext = 0;
 	if (int_cause & INT_EXT) {
 		int_cause_ext = rdl(mep, INT_CAUSE_EXT(mep->port_num))
 				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 		wrl(mep, INT_CAUSE_EXT(mep->port_num), ~int_cause_ext);
 	}
 
-	/* PHY status changed */
-	if (int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
+	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
 		if (mii_link_ok(&mep->mii)) {
 			struct ethtool_cmd cmd;
 
 			mii_ethtool_gset(&mep->mii, &cmd);
-			mv643xx_eth_update_pscr(mep, &cmd);
+			update_pscr(mep, cmd.speed, cmd.duplex);
 			txq_enable(mep->txq);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
@@ -1549,10 +1500,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 
 #ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
-		/* schedule the NAPI poll routine to maintain port */
 		wrl(mep, INT_MASK(mep->port_num), 0x00000000);
-
-		/* wait for previous write to complete */
 		rdl(mep, INT_MASK(mep->port_num));
 
 		netif_rx_schedule(dev, &mep->napi);
@@ -1561,40 +1509,31 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	if (int_cause & INT_RX)
 		rxq_process(mep->rxq, INT_MAX);
 #endif
+
 	if (int_cause_ext & INT_EXT_TX) {
 		txq_reclaim(mep->txq, 0);
 		__txq_maybe_wake(mep->txq);
 	}
 
-	/*
-	 * If no real interrupt occured, exit.
-	 * This can happen when using gigE interrupt coalescing mechanism.
-	 */
-	if ((int_cause == 0x0) && (int_cause_ext == 0x0))
-		return IRQ_NONE;
-
 	return IRQ_HANDLED;
 }
 
 static void phy_reset(struct mv643xx_eth_private *mep)
 {
-	unsigned int phy_reg_data;
+	unsigned int data;
 
-	/* Reset the PHY */
-	read_smi_reg(mep, 0, &phy_reg_data);
-	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	write_smi_reg(mep, 0, phy_reg_data);
+	smi_reg_read(mep, mep->phy_addr, 0, &data);
+	data |= 0x8000;
+	smi_reg_write(mep, mep->phy_addr, 0, data);
 
-	/* wait for PHY to come out of reset */
 	do {
 		udelay(1);
-		read_smi_reg(mep, 0, &phy_reg_data);
-	} while (phy_reg_data & 0x8000);
+		smi_reg_read(mep, mep->phy_addr, 0, &data);
+	} while (data & 0x8000);
 }
 
-static void port_start(struct net_device *dev)
+static void port_start(struct mv643xx_eth_private *mep)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	u32 pscr;
 	struct ethtool_cmd ethtool_cmd;
 	int i;
@@ -1616,9 +1555,9 @@ static void port_start(struct net_device *dev)
 
 	wrl(mep, SDMA_CONFIG(mep->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
-	mv643xx_eth_get_settings(dev, &ethtool_cmd);
+	mv643xx_eth_get_settings(mep->dev, &ethtool_cmd);
 	phy_reset(mep);
-	mv643xx_eth_set_settings(dev, &ethtool_cmd);
+	mv643xx_eth_set_settings(mep->dev, &ethtool_cmd);
 
 	/*
 	 * Configure TX path and queues.
@@ -1634,8 +1573,10 @@ static void port_start(struct net_device *dev)
 		wrl(mep, off, addr);
 	}
 
-	/* Add the assigned Ethernet address to the port's address table */
-	uc_addr_set(mep, dev->dev_addr);
+	/*
+	 * Add configured unicast address to address filter table.
+	 */
+	uc_addr_set(mep, mep->dev->dev_addr);
 
 	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
@@ -1666,13 +1607,14 @@ static void port_start(struct net_device *dev)
 
 static void set_rx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
 {
-	unsigned int port_num = mep->port_num;
 	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
 
-	/* Set RX Coalescing mechanism */
-	wrl(mep, SDMA_CONFIG(port_num),
+	if (coal > 0x3fff)
+		coal = 0x3fff;
+
+	wrl(mep, SDMA_CONFIG(mep->port_num),
 		((coal & 0x3fff) << 8) |
-		(rdl(mep, SDMA_CONFIG(port_num))
+		(rdl(mep, SDMA_CONFIG(mep->port_num))
 			& 0xffc000ff));
 }
 
@@ -1680,68 +1622,59 @@ static void set_tx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
 {
 	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
 
-	/* Set TX Coalescing mechanism */
-	wrl(mep, TX_FIFO_URGENT_THRESHOLD(mep->port_num), coal << 4);
-}
-
-static void port_init(struct mv643xx_eth_private *mep)
-{
-	port_reset(mep);
-
-	init_mac_tables(mep);
+	if (coal > 0x3fff)
+		coal = 0x3fff;
+	wrl(mep, TX_FIFO_URGENT_THRESHOLD(mep->port_num), (coal & 0x3fff) << 4);
 }
 
 static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	unsigned int port_num = mep->port_num;
 	int err;
 
-	/* Clear any pending ethernet port interrupts */
-	wrl(mep, INT_CAUSE(port_num), 0);
-	wrl(mep, INT_CAUSE_EXT(port_num), 0);
-	/* wait for previous write to complete */
-	rdl(mep, INT_CAUSE_EXT(port_num));
+	wrl(mep, INT_CAUSE(mep->port_num), 0);
+	wrl(mep, INT_CAUSE_EXT(mep->port_num), 0);
+	rdl(mep, INT_CAUSE_EXT(mep->port_num));
 
-	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	err = request_irq(dev->irq, mv643xx_eth_irq,
+			  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
+			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR "%s: Can not assign IRQ\n", dev->name);
+		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
 		return -EAGAIN;
 	}
 
-	port_init(mep);
+	init_mac_tables(mep);
 
 	err = rxq_init(mep);
 	if (err)
-		goto out_free_irq;
+		goto out;
 	rxq_refill(mep->rxq);
 
 	err = txq_init(mep);
 	if (err)
-		goto out_free_rx_skb;
+		goto out_free;
 
 #ifdef MV643XX_ETH_NAPI
 	napi_enable(&mep->napi);
 #endif
 
-	port_start(dev);
+	port_start(mep);
 
 	set_rx_coal(mep, 0);
 	set_tx_coal(mep, 0);
 
-	/* Unmask phy and link status changes interrupts */
-	wrl(mep, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+	wrl(mep, INT_MASK_EXT(mep->port_num),
+	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 
-	/* Unmask RX buffer and TX end interrupt */
-	wrl(mep, INT_MASK(port_num), INT_RX | INT_EXT);
+	wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_EXT);
 
 	return 0;
 
 
-out_free_rx_skb:
+out_free:
 	rxq_deinit(mep->rxq);
-out_free_irq:
+out:
 	free_irq(dev->irq, dev);
 
 	return err;
@@ -1749,34 +1682,27 @@ out_free_irq:
 
 static void port_reset(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mep->port_num;
-	unsigned int reg_data;
+	unsigned int data;
 
 	txq_disable(mep->txq);
 	rxq_disable(mep->rxq);
 	while (!(rdl(mep, PORT_STATUS(mep->port_num)) & TX_FIFO_EMPTY))
 		udelay(10);
 
-	/* Clear all MIB counters */
-	clear_mib_counters(mep);
-
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = rdl(mep, PORT_SERIAL_CONTROL(port_num));
-	reg_data &= ~(SERIAL_PORT_ENABLE		|
-			DO_NOT_FORCE_LINK_FAIL	|
-			FORCE_LINK_PASS);
-	wrl(mep, PORT_SERIAL_CONTROL(port_num), reg_data);
+	data = rdl(mep, PORT_SERIAL_CONTROL(mep->port_num));
+	data &= ~(SERIAL_PORT_ENABLE		|
+		  DO_NOT_FORCE_LINK_FAIL	|
+		  FORCE_LINK_PASS);
+	wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), data);
 }
 
 static int mv643xx_eth_stop(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	unsigned int port_num = mep->port_num;
 
-	/* Mask all interrupts on ethernet port */
-	wrl(mep, INT_MASK(port_num), 0x00000000);
-	/* wait for previous write to complete */
-	rdl(mep, INT_MASK(port_num));
+	wrl(mep, INT_MASK(mep->port_num), 0x00000000);
+	rdl(mep, INT_MASK(mep->port_num));
 
 #ifdef MV643XX_ETH_NAPI
 	napi_disable(&mep->napi);
@@ -1784,17 +1710,18 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
+	free_irq(dev->irq, dev);
+
 	port_reset(mep);
+	mib_counters_update(mep);
 
 	txq_deinit(mep->txq);
 	rxq_deinit(mep->rxq);
 
-	free_irq(dev->irq, dev);
-
 	return 0;
 }
 
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
@@ -1803,7 +1730,7 @@ static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int c
 
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if ((new_mtu > 9500) || (new_mtu < 64))
+	if (new_mtu < 64 || new_mtu > 9500)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
@@ -1814,73 +1741,70 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 	 * Stop and then re-open the interface. This will allocate RX
 	 * skbs of the new MTU.
 	 * There is a possible danger that the open will not succeed,
-	 * due to memory being full, which might fail the open function.
+	 * due to memory being full.
 	 */
 	mv643xx_eth_stop(dev);
 	if (mv643xx_eth_open(dev)) {
-		printk(KERN_ERR "%s: Fatal error on opening device\n",
-			dev->name);
+		dev_printk(KERN_ERR, &dev->dev,
+			   "fatal error on re-opening device after "
+			   "MTU change\n");
 	}
 
 	return 0;
 }
 
-static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
+static void tx_timeout_task(struct work_struct *ugly)
 {
-	struct mv643xx_eth_private *mep = container_of(ugly, struct mv643xx_eth_private,
-						  tx_timeout_task);
-	struct net_device *dev = mep->dev;
-
-	if (!netif_running(dev))
-		return;
+	struct mv643xx_eth_private *mep;
 
-	netif_stop_queue(dev);
+	mep = container_of(ugly, struct mv643xx_eth_private, tx_timeout_task);
+	if (netif_running(mep->dev)) {
+		netif_stop_queue(mep->dev);
 
-	port_reset(mep);
-	port_start(dev);
+		port_reset(mep);
+		port_start(mep);
 
-	__txq_maybe_wake(mep->txq);
+		__txq_maybe_wake(mep->txq);
+	}
 }
 
 static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: TX timeout  ", dev->name);
+	dev_printk(KERN_INFO, &dev->dev, "tx timeout\n");
 
-	/* Do the reset outside of interrupt context */
 	schedule_work(&mep->tx_timeout_task);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void mv643xx_eth_netpoll(struct net_device *netdev)
+static void mv643xx_eth_netpoll(struct net_device *dev)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(netdev);
-	int port_num = mep->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	wrl(mep, INT_MASK(port_num), 0x00000000);
-	/* wait for previous write to complete */
-	rdl(mep, INT_MASK(port_num));
+	wrl(mep, INT_MASK(mep->port_num), 0x00000000);
+	rdl(mep, INT_MASK(mep->port_num));
 
-	mv643xx_eth_int_handler(netdev->irq, netdev);
+	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mep, INT_MASK(port_num), INT_RX | INT_CAUSE_EXT);
+	wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_CAUSE_EXT);
 }
 #endif
 
-static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
+static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int val;
 
-	read_smi_reg(mep, location, &val);
+	smi_reg_read(mep, addr, reg, &val);
+
 	return val;
 }
 
-static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	write_smi_reg(mep, location, val);
+	smi_reg_write(mep, addr, reg, val);
 }
 
 
@@ -1947,9 +1871,6 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		goto out_free;
 
 	spin_lock_init(&mesp->phy_lock);
-	mesp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
-
-	platform_set_drvdata(pdev, mesp);
 
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
@@ -1957,6 +1878,13 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (pd != NULL && pd->dram != NULL)
 		mv643xx_eth_conf_mbus_windows(mesp, pd->dram);
 
+	/*
+	 * Detect hardware parameters.
+	 */
+	mesp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+
+	platform_set_drvdata(pdev, mesp);
+
 	return 0;
 
 out_free:
@@ -1976,104 +1904,158 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 }
 
 static struct platform_driver mv643xx_eth_shared_driver = {
-	.probe = mv643xx_eth_shared_probe,
-	.remove = mv643xx_eth_shared_remove,
+	.probe		= mv643xx_eth_shared_probe,
+	.remove		= mv643xx_eth_shared_remove,
 	.driver = {
-		.name = MV643XX_ETH_SHARED_NAME,
+		.name	= MV643XX_ETH_SHARED_NAME,
 		.owner	= THIS_MODULE,
 	},
 };
 
 static void phy_addr_set(struct mv643xx_eth_private *mep, int phy_addr)
 {
-	u32 reg_data;
 	int addr_shift = 5 * mep->port_num;
+	u32 data;
 
-	reg_data = rdl(mep, PHY_ADDR);
-	reg_data &= ~(0x1f << addr_shift);
-	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	wrl(mep, PHY_ADDR, reg_data);
+	data = rdl(mep, PHY_ADDR);
+	data &= ~(0x1f << addr_shift);
+	data |= (phy_addr & 0x1f) << addr_shift;
+	wrl(mep, PHY_ADDR, data);
 }
 
 static int phy_addr_get(struct mv643xx_eth_private *mep)
 {
-	unsigned int reg_data;
+	unsigned int data;
+
+	data = rdl(mep, PHY_ADDR);
+
+	return (data >> (5 * mep->port_num)) & 0x1f;
+}
+
+static void set_params(struct mv643xx_eth_private *mep,
+		       struct mv643xx_eth_platform_data *pd)
+{
+	struct net_device *dev = mep->dev;
+
+	if (is_valid_ether_addr(pd->mac_addr))
+		memcpy(dev->dev_addr, pd->mac_addr, 6);
+	else
+		uc_addr_get(mep, dev->dev_addr);
+
+	if (pd->phy_addr == -1) {
+		mep->shared_smi = NULL;
+		mep->phy_addr = -1;
+	} else {
+		mep->shared_smi = mep->shared;
+		if (pd->shared_smi != NULL)
+			mep->shared_smi = platform_get_drvdata(pd->shared_smi);
+
+		if (pd->force_phy_addr || pd->phy_addr) {
+			mep->phy_addr = pd->phy_addr & 0x3f;
+			phy_addr_set(mep, mep->phy_addr);
+		} else {
+			mep->phy_addr = phy_addr_get(mep);
+		}
+	}
 
-	reg_data = rdl(mep, PHY_ADDR);
+	mep->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	if (pd->rx_queue_size)
+		mep->default_rx_ring_size = pd->rx_queue_size;
+	mep->rx_desc_sram_addr = pd->rx_sram_addr;
+	mep->rx_desc_sram_size = pd->rx_sram_size;
 
-	return ((reg_data >> (5 * mep->port_num)) & 0x1f);
+	mep->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	if (pd->tx_queue_size)
+		mep->default_tx_ring_size = pd->tx_queue_size;
+	mep->tx_desc_sram_addr = pd->tx_sram_addr;
+	mep->tx_desc_sram_size = pd->tx_sram_size;
 }
 
 static int phy_detect(struct mv643xx_eth_private *mep)
 {
-	unsigned int phy_reg_data0;
-	int auto_neg;
+	unsigned int data;
+	unsigned int data2;
+
+	smi_reg_read(mep, mep->phy_addr, 0, &data);
+	smi_reg_write(mep, mep->phy_addr, 0, data ^ 0x1000);
 
-	read_smi_reg(mep, 0, &phy_reg_data0);
-	auto_neg = phy_reg_data0 & 0x1000;
-	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	write_smi_reg(mep, 0, phy_reg_data0);
+	smi_reg_read(mep, mep->phy_addr, 0, &data2);
+	if (((data ^ data2) & 0x1000) == 0)
+		return -ENODEV;
 
-	read_smi_reg(mep, 0, &phy_reg_data0);
-	if ((phy_reg_data0 & 0x1000) == auto_neg)
-		return -ENODEV;				/* change didn't take */
+	smi_reg_write(mep, mep->phy_addr, 0, data);
 
-	phy_reg_data0 ^= 0x1000;
-	write_smi_reg(mep, 0, phy_reg_data0);
 	return 0;
 }
 
-static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
-				     int speed, int duplex,
-				     struct ethtool_cmd *cmd)
+static int phy_init(struct mv643xx_eth_private *mep,
+		    struct mv643xx_eth_platform_data *pd)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	struct ethtool_cmd cmd;
+	int err;
 
-	memset(cmd, 0, sizeof(*cmd));
+	err = phy_detect(mep);
+	if (err) {
+		dev_printk(KERN_INFO, &mep->dev->dev,
+			   "no PHY detected at addr %d\n", mep->phy_addr);
+		return err;
+	}
+	phy_reset(mep);
+
+	mep->mii.phy_id = mep->phy_addr;
+	mep->mii.phy_id_mask = 0x3f;
+	mep->mii.reg_num_mask = 0x1f;
+	mep->mii.dev = mep->dev;
+	mep->mii.mdio_read = mv643xx_eth_mdio_read;
+	mep->mii.mdio_write = mv643xx_eth_mdio_write;
 
-	cmd->port = PORT_MII;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->phy_address = phy_address;
+	mep->mii.supports_gmii = mii_check_gmii_support(&mep->mii);
 
-	if (speed == 0) {
-		cmd->autoneg = AUTONEG_ENABLE;
-		/* mii lib checks, but doesn't use speed on AUTONEG_ENABLE */
-		cmd->speed = SPEED_100;
-		cmd->advertising = ADVERTISED_10baseT_Half  |
-				   ADVERTISED_10baseT_Full  |
-				   ADVERTISED_100baseT_Half |
-				   ADVERTISED_100baseT_Full;
+	memset(&cmd, 0, sizeof(cmd));
+
+	cmd.port = PORT_MII;
+	cmd.transceiver = XCVR_INTERNAL;
+	cmd.phy_address = mep->phy_addr;
+	if (pd->speed == 0) {
+		cmd.autoneg = AUTONEG_ENABLE;
+		cmd.speed = SPEED_100;
+		cmd.advertising = ADVERTISED_10baseT_Half  |
+				  ADVERTISED_10baseT_Full  |
+				  ADVERTISED_100baseT_Half |
+				  ADVERTISED_100baseT_Full;
 		if (mep->mii.supports_gmii)
-			cmd->advertising |= ADVERTISED_1000baseT_Full;
+			cmd.advertising |= ADVERTISED_1000baseT_Full;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->speed = speed;
-		cmd->duplex = duplex;
+		cmd.autoneg = AUTONEG_DISABLE;
+		cmd.speed = pd->speed;
+		cmd.duplex = pd->duplex;
 	}
+
+	update_pscr(mep, cmd.speed, cmd.duplex);
+	mv643xx_eth_set_settings(mep->dev, &cmd);
+
+	return 0;
 }
 
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
-	int port_num;
 	struct mv643xx_eth_private *mep;
 	struct net_device *dev;
-	u8 *p;
 	struct resource *res;
-	int err;
-	struct ethtool_cmd cmd;
-	int duplex = DUPLEX_HALF;
-	int speed = 0;			/* default to auto-negotiation */
 	DECLARE_MAC_BUF(mac);
+	int err;
 
 	pd = pdev->dev.platform_data;
 	if (pd == NULL) {
-		printk(KERN_ERR "No mv643xx_eth_platform_data\n");
+		dev_printk(KERN_ERR, &pdev->dev,
+			   "no mv643xx_eth_platform_data\n");
 		return -ENODEV;
 	}
 
 	if (pd->shared == NULL) {
-		printk(KERN_ERR "No mv643xx_eth_platform_data->shared\n");
+		dev_printk(KERN_ERR, &pdev->dev,
+			   "no mv643xx_eth_platform_data->shared\n");
 		return -ENODEV;
 	}
 
@@ -2081,145 +2063,80 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
-	platform_set_drvdata(pdev, dev);
-
 	mep = netdev_priv(dev);
+	platform_set_drvdata(pdev, mep);
+
+	mep->shared = platform_get_drvdata(pd->shared);
+	mep->port_num = pd->port_number;
+
 	mep->dev = dev;
 #ifdef MV643XX_ETH_NAPI
 	netif_napi_add(dev, &mep->napi, mv643xx_eth_poll, 64);
 #endif
 
+	set_params(mep, pd);
+
+	spin_lock_init(&mep->lock);
+
+	mib_counters_clear(mep);
+	INIT_WORK(&mep->tx_timeout_task, tx_timeout_task);
+
+	err = phy_init(mep, pd);
+	if (err)
+		goto out;
+	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
+
+
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
 	dev->irq = res->start;
 
+	dev->hard_start_xmit = mv643xx_eth_xmit;
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
-	dev->hard_start_xmit = mv643xx_eth_start_xmit;
-	dev->set_mac_address = mv643xx_eth_set_mac_address;
 	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
-
-	/* No need to Tx Timeout */
+	dev->set_mac_address = mv643xx_eth_set_mac_address;
+	dev->do_ioctl = mv643xx_eth_ioctl;
+	dev->change_mtu = mv643xx_eth_change_mtu;
 	dev->tx_timeout = mv643xx_eth_tx_timeout;
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = mv643xx_eth_netpoll;
 #endif
-
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
-	dev->change_mtu = mv643xx_eth_change_mtu;
-	dev->do_ioctl = mv643xx_eth_do_ioctl;
-	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 
 #ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-#ifdef MAX_SKB_FRAGS
 	/*
 	 * Zero copy can only work if we use Discovery II memory. Else, we will
 	 * have to map the buffers to ISA memory which is only 16 MB
 	 */
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
 #endif
-#endif
 
-	/* Configure the timeout task */
-	INIT_WORK(&mep->tx_timeout_task, mv643xx_eth_tx_timeout_task);
-
-	spin_lock_init(&mep->lock);
-
-	mep->shared = platform_get_drvdata(pd->shared);
-	port_num = mep->port_num = pd->port_number;
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (mep->shared->win_protect)
-		wrl(mep, WINDOW_PROTECT(port_num), mep->shared->win_protect);
-
-	mep->shared_smi = mep->shared;
-	if (pd->shared_smi != NULL)
-		mep->shared_smi = platform_get_drvdata(pd->shared_smi);
-
-	/* set default config values */
-	uc_addr_get(mep, dev->dev_addr);
-
-	if (is_valid_ether_addr(pd->mac_addr))
-		memcpy(dev->dev_addr, pd->mac_addr, 6);
-
-	if (pd->phy_addr || pd->force_phy_addr)
-		phy_addr_set(mep, pd->phy_addr);
-
-	mep->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
-	if (pd->rx_queue_size)
-		mep->default_rx_ring_size = pd->rx_queue_size;
-
-	mep->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
-	if (pd->tx_queue_size)
-		mep->default_tx_ring_size = pd->tx_queue_size;
-
-	if (pd->tx_sram_size) {
-		mep->tx_desc_sram_size = pd->tx_sram_size;
-		mep->tx_desc_sram_addr = pd->tx_sram_addr;
-	}
-
-	if (pd->rx_sram_size) {
-		mep->rx_desc_sram_addr = pd->rx_sram_addr;
-		mep->rx_desc_sram_size = pd->rx_sram_size;
-	}
-
-	duplex = pd->duplex;
-	speed = pd->speed;
+		wrl(mep, WINDOW_PROTECT(mep->port_num), mep->shared->win_protect);
 
-	/* Hook up MII support for ethtool */
-	mep->mii.dev = dev;
-	mep->mii.mdio_read = mv643xx_eth_mdio_read;
-	mep->mii.mdio_write = mv643xx_eth_mdio_write;
-	mep->mii.phy_id = phy_addr_get(mep);
-	mep->mii.phy_id_mask = 0x3f;
-	mep->mii.reg_num_mask = 0x1f;
-
-	err = phy_detect(mep);
-	if (err) {
-		pr_debug("%s: No PHY detected at addr %d\n",
-				dev->name, phy_addr_get(mep));
-		goto out;
-	}
-
-	phy_reset(mep);
-	mep->mii.supports_gmii = mii_check_gmii_support(&mep->mii);
-	mv643xx_init_ethtool_cmd(dev, mep->mii.phy_id, speed, duplex, &cmd);
-	mv643xx_eth_update_pscr(mep, &cmd);
-	mv643xx_eth_set_settings(dev, &cmd);
-
-	SET_NETDEV_DEV(dev, &pdev->dev);
 	err = register_netdev(dev);
 	if (err)
 		goto out;
 
-	p = dev->dev_addr;
-	printk(KERN_NOTICE
-		"%s: port %d with MAC address %s\n",
-		dev->name, port_num, print_mac(mac, p));
+	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %s\n",
+		   mep->port_num, print_mac(mac, dev->dev_addr));
 
 	if (dev->features & NETIF_F_SG)
-		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
+		dev_printk(KERN_NOTICE, &dev->dev, "scatter/gather enabled\n");
 
 	if (dev->features & NETIF_F_IP_CSUM)
-		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
-								dev->name);
-
-#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
-	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
-#endif
-
-#ifdef MV643XX_ETH_COAL
-	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
-								dev->name);
-#endif
+		dev_printk(KERN_NOTICE, &dev->dev, "tx checksum offload\n");
 
 #ifdef MV643XX_ETH_NAPI
-	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
+	dev_printk(KERN_NOTICE, &dev->dev, "napi enabled\n");
 #endif
 
 	if (mep->tx_desc_sram_size > 0)
-		printk(KERN_NOTICE "%s: Using SRAM\n", dev->name);
+		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
 
 	return 0;
 
@@ -2231,35 +2148,35 @@ out:
 
 static int mv643xx_eth_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
+	struct mv643xx_eth_private *mep = platform_get_drvdata(pdev);
 
-	unregister_netdev(dev);
+	unregister_netdev(mep->dev);
 	flush_scheduled_work();
+	free_netdev(mep->dev);
 
-	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
+
 	return 0;
 }
 
 static void mv643xx_eth_shutdown(struct platform_device *pdev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	unsigned int port_num = mep->port_num;
+	struct mv643xx_eth_private *mep = platform_get_drvdata(pdev);
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mep, INT_MASK(port_num), 0);
-	rdl(mep, INT_MASK(port_num));
+	wrl(mep, INT_MASK(mep->port_num), 0);
+	rdl(mep, INT_MASK(mep->port_num));
 
-	port_reset(mep);
+	if (netif_running(mep->dev))
+		port_reset(mep);
 }
 
 static struct platform_driver mv643xx_eth_driver = {
-	.probe = mv643xx_eth_probe,
-	.remove = mv643xx_eth_remove,
-	.shutdown = mv643xx_eth_shutdown,
+	.probe		= mv643xx_eth_probe,
+	.remove		= mv643xx_eth_remove,
+	.shutdown	= mv643xx_eth_shutdown,
 	.driver = {
-		.name = MV643XX_ETH_NAME,
+		.name	= MV643XX_ETH_NAME,
 		.owner	= THIS_MODULE,
 	},
 };
@@ -2274,21 +2191,21 @@ static int __init mv643xx_eth_init_module(void)
 		if (rc)
 			platform_driver_unregister(&mv643xx_eth_shared_driver);
 	}
+
 	return rc;
 }
+module_init(mv643xx_eth_init_module);
 
 static void __exit mv643xx_eth_cleanup_module(void)
 {
 	platform_driver_unregister(&mv643xx_eth_driver);
 	platform_driver_unregister(&mv643xx_eth_shared_driver);
 }
-
-module_init(mv643xx_eth_init_module);
 module_exit(mv643xx_eth_cleanup_module);
 
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
-		" and Dale Farnsworth");
+MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani "
+	      "and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
-MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
+MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index a15cdd4..6461776 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -17,30 +17,53 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
-	unsigned int	t_clk;
+	unsigned int		t_clk;
 };
 
 struct mv643xx_eth_platform_data {
+	/*
+	 * Pointer back to our parent instance, and our port number.
+	 */
 	struct platform_device	*shared;
-	int		port_number;
+	int			port_number;
 
+	/*
+	 * Whether a PHY is present, and if yes, at which address.
+	 */
 	struct platform_device	*shared_smi;
+	int			force_phy_addr;
+	int			phy_addr;
 
-	u16		force_phy_addr;	/* force override if phy_addr == 0 */
-	u16		phy_addr;
-
-	/* If speed is 0, then speed and duplex are autonegotiated. */
-	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
-	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
-
-	/* non-zero values of the following fields override defaults */
-	u32		tx_queue_size;
-	u32		rx_queue_size;
-	u32		tx_sram_addr;
-	u32		tx_sram_size;
-	u32		rx_sram_addr;
-	u32		rx_sram_size;
-	u8		mac_addr[6];	/* mac address if non-zero*/
+	/*
+	 * Use this MAC address if it is valid, overriding the
+	 * address that is already in the hardware.
+	 */
+	u8			mac_addr[6];
+
+	/*
+	 * If speed is 0, autonegotiation is enabled.
+	 *   Valid values for speed: 0, SPEED_10, SPEED_100, SPEED_1000.
+	 *   Valid values for duplex: DUPLEX_HALF, DUPLEX_FULL.
+	 */
+	int			speed;
+	int			duplex;
+
+	/*
+	 * Override default RX/TX queue sizes if nonzero.
+	 */
+	int			rx_queue_size;
+	int			tx_queue_size;
+
+	/*
+	 * Use on-chip SRAM for RX/TX descriptors if size is nonzero
+	 * and sufficient to contain all descriptors for the requested
+	 * ring sizes.
+	 */
+	unsigned long		rx_sram_addr;
+	int			rx_sram_size;
+	unsigned long		tx_sram_addr;
+	int			tx_sram_size;
 };
 
-#endif /* __LINUX_MV643XX_ETH_H */
+
+#endif
-- 
1.5.3.4

