From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: systemport: Add support for SYSTEMPORT Lite
Date: Fri, 20 Jan 2017 11:08:27 -0800
Message-ID: <20170120190827.26444-3-f.fainelli@gmail.com>
References: <20170120190827.26444-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34065 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752590AbdATTIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:08:36 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so5947294pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:08:35 -0800 (PST)
In-Reply-To: <20170120190827.26444-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add supporf for the SYSTEMPORT Lite Ethernet controller, this piece of hardware
is largely based on the full-blown SYSTEMPORT and differs in the following:

- no full-blown UniMAC, instead we have the MagicPacket matching from UniMAC at
  same offset, and a GMII Interface Block (GIB) for the MAC-level stuff, since
  we are always interfaced to an Ethernet switch which is fully Ethernet compliant
  shortcuts could be made

- 16 transmit queues, whose interrupts are moved into the first Level-2 interrupt
  controller bank

- slight TDMA offset change (a register was inserted after TDMA_STATUS, *sigh*)

- 256 RX descriptors (512 words) and 256 TX descriptors (not visible)

As a consequence of these two things, update the code paths accordingly to
differentiate the full-blown from the light version.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../devicetree/bindings/net/brcm,systemport.txt    |   5 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         | 323 +++++++++++++++++----
 drivers/net/ethernet/broadcom/bcmsysport.h         |  78 ++++-
 3 files changed, 327 insertions(+), 79 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,systemport.txt b/Documentation/devicetree/bindings/net/brcm,systemport.txt
index 877da34145b0..83f29e0e11ba 100644
--- a/Documentation/devicetree/bindings/net/brcm,systemport.txt
+++ b/Documentation/devicetree/bindings/net/brcm,systemport.txt
@@ -1,7 +1,10 @@
 * Broadcom BCM7xxx Ethernet Systemport Controller (SYSTEMPORT)
 
 Required properties:
-- compatible: should be one of "brcm,systemport-v1.00" or "brcm,systemport"
+- compatible: should be one of:
+	      "brcm,systemport-v1.00"
+	      "brcm,systemportlite-v1.00" or
+	      "brcm,systemport"
 - reg: address and length of the register set for the device.
 - interrupts: interrupts for the device, first cell must be for the rx
   interrupts, and the second cell should be for the transmit queues. An
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 31bb2c3696ec..a68d4889f5db 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -43,14 +43,43 @@ static inline void name##_writel(struct bcm_sysport_priv *priv,		\
 BCM_SYSPORT_IO_MACRO(intrl2_0, SYS_PORT_INTRL2_0_OFFSET);
 BCM_SYSPORT_IO_MACRO(intrl2_1, SYS_PORT_INTRL2_1_OFFSET);
 BCM_SYSPORT_IO_MACRO(umac, SYS_PORT_UMAC_OFFSET);
+BCM_SYSPORT_IO_MACRO(gib, SYS_PORT_GIB_OFFSET);
 BCM_SYSPORT_IO_MACRO(tdma, SYS_PORT_TDMA_OFFSET);
-BCM_SYSPORT_IO_MACRO(rdma, SYS_PORT_RDMA_OFFSET);
 BCM_SYSPORT_IO_MACRO(rxchk, SYS_PORT_RXCHK_OFFSET);
 BCM_SYSPORT_IO_MACRO(txchk, SYS_PORT_TXCHK_OFFSET);
 BCM_SYSPORT_IO_MACRO(rbuf, SYS_PORT_RBUF_OFFSET);
 BCM_SYSPORT_IO_MACRO(tbuf, SYS_PORT_TBUF_OFFSET);
 BCM_SYSPORT_IO_MACRO(topctrl, SYS_PORT_TOPCTRL_OFFSET);
 
+/* On SYSTEMPORT Lite, any register after RDMA_STATUS has the exact
+ * same layout, except it has been moved by 4 bytes up, *sigh*
+ */
+static inline u32 rdma_readl(struct bcm_sysport_priv *priv, u32 off)
+{
+	if (priv->is_lite && off >= RDMA_STATUS)
+		off += 4;
+	return __raw_readl(priv->base + SYS_PORT_RDMA_OFFSET + off);
+}
+
+static inline void rdma_writel(struct bcm_sysport_priv *priv, u32 val, u32 off)
+{
+	if (priv->is_lite && off >= RDMA_STATUS)
+		off += 4;
+	__raw_writel(val, priv->base + SYS_PORT_RDMA_OFFSET + off);
+}
+
+static inline u32 tdma_control_bit(struct bcm_sysport_priv *priv, u32 bit)
+{
+	if (!priv->is_lite) {
+		return BIT(bit);
+	} else {
+		if (bit >= ACB_ALGO)
+			return BIT(bit + 1);
+		else
+			return BIT(bit);
+	}
+}
+
 /* L2-interrupt masking/unmasking helpers, does automatic saving of the applied
  * mask in a software copy to avoid CPU_MASK_STATUS reads in hot-paths.
   */
@@ -143,9 +172,9 @@ static int bcm_sysport_set_tx_csum(struct net_device *dev,
 	priv->tsb_en = !!(wanted & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM));
 	reg = tdma_readl(priv, TDMA_CONTROL);
 	if (priv->tsb_en)
-		reg |= TSB_EN;
+		reg |= tdma_control_bit(priv, TSB_EN);
 	else
-		reg &= ~TSB_EN;
+		reg &= ~tdma_control_bit(priv, TSB_EN);
 	tdma_writel(priv, reg, TDMA_CONTROL);
 
 	return 0;
@@ -281,11 +310,35 @@ static void bcm_sysport_set_msglvl(struct net_device *dev, u32 enable)
 	priv->msg_enable = enable;
 }
 
+static inline bool bcm_sysport_lite_stat_valid(enum bcm_sysport_stat_type type)
+{
+	switch (type) {
+	case BCM_SYSPORT_STAT_NETDEV:
+	case BCM_SYSPORT_STAT_RXCHK:
+	case BCM_SYSPORT_STAT_RBUF:
+	case BCM_SYSPORT_STAT_SOFT:
+		return true;
+	default:
+		return false;
+	}
+}
+
 static int bcm_sysport_get_sset_count(struct net_device *dev, int string_set)
 {
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	const struct bcm_sysport_stats *s;
+	unsigned int i, j;
+
 	switch (string_set) {
 	case ETH_SS_STATS:
-		return BCM_SYSPORT_STATS_LEN;
+		for (i = 0, j = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
+			s = &bcm_sysport_gstrings_stats[i];
+			if (priv->is_lite &&
+			    !bcm_sysport_lite_stat_valid(s->type))
+				continue;
+			j++;
+		}
+		return j;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -294,14 +347,21 @@ static int bcm_sysport_get_sset_count(struct net_device *dev, int string_set)
 static void bcm_sysport_get_strings(struct net_device *dev,
 				    u32 stringset, u8 *data)
 {
-	int i;
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	const struct bcm_sysport_stats *s;
+	int i, j;
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN,
-			       bcm_sysport_gstrings_stats[i].stat_string,
+		for (i = 0, j = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
+			s = &bcm_sysport_gstrings_stats[i];
+			if (priv->is_lite &&
+			    !bcm_sysport_lite_stat_valid(s->type))
+				continue;
+
+			memcpy(data + j * ETH_GSTRING_LEN, s->stat_string,
 			       ETH_GSTRING_LEN);
+			j++;
 		}
 		break;
 	default:
@@ -327,6 +387,9 @@ static void bcm_sysport_update_mib_counters(struct bcm_sysport_priv *priv)
 		case BCM_SYSPORT_STAT_MIB_RX:
 		case BCM_SYSPORT_STAT_MIB_TX:
 		case BCM_SYSPORT_STAT_RUNT:
+			if (priv->is_lite)
+				continue;
+
 			if (s->type != BCM_SYSPORT_STAT_MIB_RX)
 				offset = UMAC_MIB_STAT_OFFSET;
 			val = umac_readl(priv, UMAC_MIB_START + j + offset);
@@ -355,12 +418,12 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
-	int i;
+	int i, j;
 
 	if (netif_running(dev))
 		bcm_sysport_update_mib_counters(priv);
 
-	for (i =  0; i < BCM_SYSPORT_STATS_LEN; i++) {
+	for (i =  0, j = 0; i < BCM_SYSPORT_STATS_LEN; i++) {
 		const struct bcm_sysport_stats *s;
 		char *p;
 
@@ -370,7 +433,8 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 		else
 			p = (char *)priv;
 		p += s->stat_offset;
-		data[i] = *(unsigned long *)p;
+		data[j] = *(unsigned long *)p;
+		j++;
 	}
 }
 
@@ -573,8 +637,14 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	u16 len, status;
 	struct bcm_rsb *rsb;
 
-	/* Determine how much we should process since last call */
-	p_index = rdma_readl(priv, RDMA_PROD_INDEX);
+	/* Determine how much we should process since last call, SYSTEMPORT Lite
+	 * groups the producer and consumer indexes into the same 32-bit
+	 * which we access using RDMA_CONS_INDEX
+	 */
+	if (!priv->is_lite)
+		p_index = rdma_readl(priv, RDMA_PROD_INDEX);
+	else
+		p_index = rdma_readl(priv, RDMA_CONS_INDEX);
 	p_index &= RDMA_PROD_INDEX_MASK;
 
 	if (p_index < priv->rx_c_index)
@@ -791,7 +861,11 @@ static int bcm_sysport_tx_poll(struct napi_struct *napi, int budget)
 	if (work_done == 0) {
 		napi_complete(napi);
 		/* re-enable TX interrupt */
-		intrl2_1_mask_clear(ring->priv, BIT(ring->index));
+		if (!ring->priv->is_lite)
+			intrl2_1_mask_clear(ring->priv, BIT(ring->index));
+		else
+			intrl2_0_mask_clear(ring->priv, BIT(ring->index +
+					    INTRL2_0_TDMA_MBDONE_SHIFT));
 
 		return 0;
 	}
@@ -817,7 +891,15 @@ static int bcm_sysport_poll(struct napi_struct *napi, int budget)
 
 	priv->rx_c_index += work_done;
 	priv->rx_c_index &= RDMA_CONS_INDEX_MASK;
-	rdma_writel(priv, priv->rx_c_index, RDMA_CONS_INDEX);
+
+	/* SYSTEMPORT Lite groups the producer/consumer index, producer is
+	 * maintained by HW, but writes to it will be ignore while RDMA
+	 * is active
+	 */
+	if (!priv->is_lite)
+		rdma_writel(priv, priv->rx_c_index, RDMA_CONS_INDEX);
+	else
+		rdma_writel(priv, priv->rx_c_index << 16, RDMA_CONS_INDEX);
 
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
@@ -848,6 +930,8 @@ static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_tx_ring *txr;
+	unsigned int ring, ring_bit;
 
 	priv->irq0_stat = intrl2_0_readl(priv, INTRL2_CPU_STATUS) &
 			  ~intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
@@ -877,6 +961,22 @@ static irqreturn_t bcm_sysport_rx_isr(int irq, void *dev_id)
 		bcm_sysport_resume_from_wol(priv);
 	}
 
+	if (!priv->is_lite)
+		goto out;
+
+	for (ring = 0; ring < dev->num_tx_queues; ring++) {
+		ring_bit = BIT(ring + INTRL2_0_TDMA_MBDONE_SHIFT);
+		if (!(priv->irq0_stat & ring_bit))
+			continue;
+
+		txr = &priv->tx_rings[ring];
+
+		if (likely(napi_schedule_prep(&txr->napi))) {
+			intrl2_0_mask_set(priv, ring_bit);
+			__napi_schedule(&txr->napi);
+		}
+	}
+out:
 	return IRQ_HANDLED;
 }
 
@@ -930,9 +1030,11 @@ static void bcm_sysport_poll_controller(struct net_device *dev)
 	bcm_sysport_rx_isr(priv->irq0, priv);
 	enable_irq(priv->irq0);
 
-	disable_irq(priv->irq1);
-	bcm_sysport_tx_isr(priv->irq1, priv);
-	enable_irq(priv->irq1);
+	if (!priv->is_lite) {
+		disable_irq(priv->irq1);
+		bcm_sysport_tx_isr(priv->irq1, priv);
+		enable_irq(priv->irq1);
+	}
 }
 #endif
 
@@ -1129,6 +1231,9 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 		priv->old_duplex = phydev->duplex;
 	}
 
+	if (priv->is_lite)
+		goto out;
+
 	switch (phydev->speed) {
 	case SPEED_2500:
 		cmd_bits = CMD_SPEED_2500;
@@ -1169,8 +1274,9 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 		reg |= cmd_bits;
 		umac_writel(priv, reg, UMAC_CMD);
 	}
-
-	phy_print_status(phydev);
+out:
+	if (changed)
+		phy_print_status(phydev);
 }
 
 static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
@@ -1315,9 +1421,9 @@ static inline int tdma_enable_set(struct bcm_sysport_priv *priv,
 
 	reg = tdma_readl(priv, TDMA_CONTROL);
 	if (enable)
-		reg |= TDMA_EN;
+		reg |= tdma_control_bit(priv, TDMA_EN);
 	else
-		reg &= ~TDMA_EN;
+		reg &= ~tdma_control_bit(priv, TDMA_EN);
 	tdma_writel(priv, reg, TDMA_CONTROL);
 
 	/* Poll for TMDA disabling completion */
@@ -1342,7 +1448,7 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 	int i;
 
 	/* Initialize SW view of the RX ring */
-	priv->num_rx_bds = NUM_RX_DESC;
+	priv->num_rx_bds = priv->num_rx_desc_words / WORDS_PER_DESC;
 	priv->rx_bds = priv->base + SYS_PORT_RDMA_OFFSET;
 	priv->rx_c_index = 0;
 	priv->rx_read_ptr = 0;
@@ -1379,7 +1485,7 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 	rdma_writel(priv, 0, RDMA_START_ADDR_HI);
 	rdma_writel(priv, 0, RDMA_START_ADDR_LO);
 	rdma_writel(priv, 0, RDMA_END_ADDR_HI);
-	rdma_writel(priv, NUM_HW_RX_DESC_WORDS - 1, RDMA_END_ADDR_LO);
+	rdma_writel(priv, priv->num_rx_desc_words - 1, RDMA_END_ADDR_LO);
 
 	rdma_writel(priv, 1, RDMA_MBDONE_INTR);
 
@@ -1421,6 +1527,9 @@ static void bcm_sysport_set_rx_mode(struct net_device *dev)
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	u32 reg;
 
+	if (priv->is_lite)
+		return;
+
 	reg = umac_readl(priv, UMAC_CMD);
 	if (dev->flags & IFF_PROMISC)
 		reg |= CMD_PROMISC;
@@ -1438,12 +1547,21 @@ static inline void umac_enable_set(struct bcm_sysport_priv *priv,
 {
 	u32 reg;
 
-	reg = umac_readl(priv, UMAC_CMD);
-	if (enable)
-		reg |= mask;
-	else
-		reg &= ~mask;
-	umac_writel(priv, reg, UMAC_CMD);
+	if (!priv->is_lite) {
+		reg = umac_readl(priv, UMAC_CMD);
+		if (enable)
+			reg |= mask;
+		else
+			reg &= ~mask;
+		umac_writel(priv, reg, UMAC_CMD);
+	} else {
+		reg = gib_readl(priv, GIB_CONTROL);
+		if (enable)
+			reg |= mask;
+		else
+			reg &= ~mask;
+		gib_writel(priv, reg, GIB_CONTROL);
+	}
 
 	/* UniMAC stops on a packet boundary, wait for a full-sized packet
 	 * to be processed (1 msec).
@@ -1456,6 +1574,9 @@ static inline void umac_reset(struct bcm_sysport_priv *priv)
 {
 	u32 reg;
 
+	if (priv->is_lite)
+		return;
+
 	reg = umac_readl(priv, UMAC_CMD);
 	reg |= CMD_SW_RESET;
 	umac_writel(priv, reg, UMAC_CMD);
@@ -1468,9 +1589,17 @@ static inline void umac_reset(struct bcm_sysport_priv *priv)
 static void umac_set_hw_addr(struct bcm_sysport_priv *priv,
 			     unsigned char *addr)
 {
-	umac_writel(priv, (addr[0] << 24) | (addr[1] << 16) |
-			(addr[2] << 8) | addr[3], UMAC_MAC0);
-	umac_writel(priv, (addr[4] << 8) | addr[5], UMAC_MAC1);
+	u32 mac0 = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) |
+		    addr[3];
+	u32 mac1 = (addr[4] << 8) | addr[5];
+
+	if (!priv->is_lite) {
+		umac_writel(priv, mac0, UMAC_MAC0);
+		umac_writel(priv, mac1, UMAC_MAC1);
+	} else {
+		gib_writel(priv, mac0, GIB_MAC0);
+		gib_writel(priv, mac1, GIB_MAC1);
+	}
 }
 
 static void topctrl_flush(struct bcm_sysport_priv *priv)
@@ -1515,8 +1644,11 @@ static void bcm_sysport_netif_start(struct net_device *dev)
 
 	phy_start(dev->phydev);
 
-	/* Enable TX interrupts for the 32 TXQs */
-	intrl2_1_mask_clear(priv, 0xffffffff);
+	/* Enable TX interrupts for the TXQs */
+	if (!priv->is_lite)
+		intrl2_1_mask_clear(priv, 0xffffffff);
+	else
+		intrl2_0_mask_clear(priv, INTRL2_0_TDMA_MBDONE_MASK);
 
 	/* Last call before we start the real business */
 	netif_tx_start_all_queues(dev);
@@ -1528,9 +1660,37 @@ static void rbuf_init(struct bcm_sysport_priv *priv)
 
 	reg = rbuf_readl(priv, RBUF_CONTROL);
 	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
+	/* Set a correct RSB format on SYSTEMPORT Lite */
+	if (priv->is_lite) {
+		reg &= ~RBUF_RSB_SWAP1;
+		reg |= RBUF_RSB_SWAP0;
+	}
 	rbuf_writel(priv, reg, RBUF_CONTROL);
 }
 
+static inline void bcm_sysport_mask_all_intrs(struct bcm_sysport_priv *priv)
+{
+	intrl2_0_mask_set(priv, 0xffffffff);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	if (!priv->is_lite) {
+		intrl2_1_mask_set(priv, 0xffffffff);
+		intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	}
+}
+
+static inline void gib_set_pad_extension(struct bcm_sysport_priv *priv)
+{
+	u32 __maybe_unused reg;
+
+	/* Include Broadcom tag in pad extension */
+	if (netdev_uses_dsa(priv->netdev)) {
+		reg = gib_readl(priv, GIB_CONTROL);
+		reg &= ~(GIB_PAD_EXTENSION_MASK << GIB_PAD_EXTENSION_SHIFT);
+		reg |= ENET_BRCM_TAG_LEN << GIB_PAD_EXTENSION_SHIFT;
+		gib_writel(priv, reg, GIB_CONTROL);
+	}
+}
+
 static int bcm_sysport_open(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
@@ -1551,13 +1711,20 @@ static int bcm_sysport_open(struct net_device *dev)
 	rbuf_init(priv);
 
 	/* Set maximum frame length */
-	umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+	if (!priv->is_lite)
+		umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+	else
+		gib_set_pad_extension(priv);
 
 	/* Set MAC address */
 	umac_set_hw_addr(priv, dev->dev_addr);
 
 	/* Read CRC forward */
-	priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
+	if (!priv->is_lite)
+		priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
+	else
+		priv->crc_fwd = !!(gib_readl(priv, GIB_CONTROL) &
+				   GIB_FCS_STRIP);
 
 	phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
 				0, priv->phy_interface);
@@ -1572,12 +1739,7 @@ static int bcm_sysport_open(struct net_device *dev)
 	priv->old_pause = -1;
 
 	/* mask all interrupts and request them */
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	bcm_sysport_mask_all_intrs(priv);
 
 	ret = request_irq(priv->irq0, bcm_sysport_rx_isr, 0, dev->name, dev);
 	if (ret) {
@@ -1585,10 +1747,13 @@ static int bcm_sysport_open(struct net_device *dev)
 		goto out_phy_disconnect;
 	}
 
-	ret = request_irq(priv->irq1, bcm_sysport_tx_isr, 0, dev->name, dev);
-	if (ret) {
-		netdev_err(dev, "failed to request TX interrupt\n");
-		goto out_free_irq0;
+	if (!priv->is_lite) {
+		ret = request_irq(priv->irq1, bcm_sysport_tx_isr, 0,
+				  dev->name, dev);
+		if (ret) {
+			netdev_err(dev, "failed to request TX interrupt\n");
+			goto out_free_irq0;
+		}
 	}
 
 	/* Initialize both hardware and software ring */
@@ -1635,7 +1800,8 @@ static int bcm_sysport_open(struct net_device *dev)
 out_free_tx_ring:
 	for (i = 0; i < dev->num_tx_queues; i++)
 		bcm_sysport_fini_tx_ring(priv, i);
-	free_irq(priv->irq1, dev);
+	if (!priv->is_lite)
+		free_irq(priv->irq1, dev);
 out_free_irq0:
 	free_irq(priv->irq0, dev);
 out_phy_disconnect:
@@ -1653,10 +1819,7 @@ static void bcm_sysport_netif_stop(struct net_device *dev)
 	phy_stop(dev->phydev);
 
 	/* mask all interrupts */
-	intrl2_0_mask_set(priv, 0xffffffff);
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_1_mask_set(priv, 0xffffffff);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	bcm_sysport_mask_all_intrs(priv);
 }
 
 static int bcm_sysport_stop(struct net_device *dev)
@@ -1694,7 +1857,8 @@ static int bcm_sysport_stop(struct net_device *dev)
 	bcm_sysport_fini_rx_ring(priv);
 
 	free_irq(priv->irq0, dev);
-	free_irq(priv->irq1, dev);
+	if (!priv->is_lite)
+		free_irq(priv->irq1, dev);
 
 	/* Disconnect from PHY */
 	phy_disconnect(dev->phydev);
@@ -1733,8 +1897,32 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 
 #define REV_FMT	"v%2x.%02x"
 
+static const struct bcm_sysport_hw_params bcm_sysport_params[] = {
+	[SYSTEMPORT] = {
+		.is_lite = false,
+		.num_rx_desc_words = SP_NUM_HW_RX_DESC_WORDS,
+	},
+	[SYSTEMPORT_LITE] = {
+		.is_lite = true,
+		.num_rx_desc_words = SP_LT_NUM_HW_RX_DESC_WORDS,
+	},
+};
+
+static const struct of_device_id bcm_sysport_of_match[] = {
+	{ .compatible = "brcm,systemportlite-v1.00",
+	  .data = &bcm_sysport_params[SYSTEMPORT_LITE] },
+	{ .compatible = "brcm,systemport-v1.00",
+	  .data = &bcm_sysport_params[SYSTEMPORT] },
+	{ .compatible = "brcm,systemport",
+	  .data = &bcm_sysport_params[SYSTEMPORT] },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, bcm_sysport_of_match);
+
 static int bcm_sysport_probe(struct platform_device *pdev)
 {
+	const struct bcm_sysport_hw_params *params;
+	const struct of_device_id *of_id = NULL;
 	struct bcm_sysport_priv *priv;
 	struct device_node *dn;
 	struct net_device *dev;
@@ -1745,6 +1933,12 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	dn = pdev->dev.of_node;
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	of_id = of_match_node(bcm_sysport_of_match, dn);
+	if (!of_id || !of_id->data)
+		return -EINVAL;
+
+	/* Fairly quickly we need to know the type of adapter we have */
+	params = of_id->data;
 
 	/* Read the Transmit/Receive Queue properties */
 	if (of_property_read_u32(dn, "systemport,num-txq", &txq))
@@ -1770,10 +1964,14 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	if (!priv->tx_rings)
 		return -ENOMEM;
 
+	priv->is_lite = params->is_lite;
+	priv->num_rx_desc_words = params->num_rx_desc_words;
+
 	priv->irq0 = platform_get_irq(pdev, 0);
-	priv->irq1 = platform_get_irq(pdev, 1);
+	if (!priv->is_lite)
+		priv->irq1 = platform_get_irq(pdev, 1);
 	priv->wol_irq = platform_get_irq(pdev, 2);
-	if (priv->irq0 <= 0 || priv->irq1 <= 0) {
+	if (priv->irq0 <= 0 || (priv->irq1 <= 0 && !priv->is_lite)) {
 		dev_err(&pdev->dev, "invalid interrupts\n");
 		ret = -EINVAL;
 		goto err_free_netdev;
@@ -1847,8 +2045,9 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 
 	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
 	dev_info(&pdev->dev,
-		 "Broadcom SYSTEMPORT" REV_FMT
+		 "Broadcom SYSTEMPORT%s" REV_FMT
 		 " at 0x%p (irqs: %d, %d, TXQs: %d, RXQs: %d)\n",
+		 priv->is_lite ? " Lite" : "",
 		 (priv->rev >> 8) & 0xff, priv->rev & 0xff,
 		 priv->base, priv->irq0, priv->irq1, txq, rxq);
 
@@ -2044,7 +2243,10 @@ static int bcm_sysport_resume(struct device *d)
 	rbuf_init(priv);
 
 	/* Set maximum frame length */
-	umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+	if (!priv->is_lite)
+		umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+	else
+		gib_set_pad_extension(priv);
 
 	/* Set MAC address */
 	umac_set_hw_addr(priv, dev->dev_addr);
@@ -2080,13 +2282,6 @@ static int bcm_sysport_resume(struct device *d)
 static SIMPLE_DEV_PM_OPS(bcm_sysport_pm_ops,
 		bcm_sysport_suspend, bcm_sysport_resume);
 
-static const struct of_device_id bcm_sysport_of_match[] = {
-	{ .compatible = "brcm,systemport-v1.00" },
-	{ .compatible = "brcm,systemport" },
-	{ /* sentinel */ }
-};
-MODULE_DEVICE_TABLE(of, bcm_sysport_of_match);
-
 static struct platform_driver bcm_sysport_driver = {
 	.probe	= bcm_sysport_probe,
 	.remove	= bcm_sysport_remove,
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index f051356b0274..863ddd7870b7 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -127,6 +127,10 @@ struct bcm_rsb {
 #define INTRL2_0_DESC_ALLOC_ERR		(1 << 10)
 #define INTRL2_0_UNEXP_PKTSIZE_ACK	(1 << 11)
 
+/* SYSTEMPORT Lite groups the TX queues interrupts on instance 0 */
+#define INTRL2_0_TDMA_MBDONE_SHIFT	12
+#define INTRL2_0_TDMA_MBDONE_MASK	(0xffff << INTRL2_0_TDMA_MBDONE_SHIFT)
+
 /* RXCHK offset and defines */
 #define SYS_PORT_RXCHK_OFFSET		0x300
 
@@ -176,7 +180,9 @@ struct bcm_rsb {
 #define  RBUF_OK_TO_SEND_MASK		0xff
 #define  RBUF_CRC_REPLACE		(1 << 20)
 #define  RBUF_OK_TO_SEND_MODE		(1 << 21)
-#define  RBUF_RSB_SWAP			(1 << 22)
+/* SYSTEMPORT Lite uses two bits here */
+#define  RBUF_RSB_SWAP0			(1 << 22)
+#define  RBUF_RSB_SWAP1			(1 << 23)
 #define  RBUF_ACPI_EN			(1 << 23)
 
 #define RBUF_PKT_RDY_THRESH		0x04
@@ -247,6 +253,7 @@ struct bcm_rsb {
 #define  MIB_RUNT_CNT_RST		(1 << 1)
 #define  MIB_TX_CNT_RST			(1 << 2)
 
+/* These offsets are valid for SYSTEMPORT and SYSTEMPORT Lite */
 #define UMAC_MPD_CTRL			0x620
 #define  MPD_EN				(1 << 0)
 #define  MSEQ_LEN_SHIFT			16
@@ -258,6 +265,34 @@ struct bcm_rsb {
 #define UMAC_MDF_CTRL			0x650
 #define UMAC_MDF_ADDR			0x654
 
+/* Only valid on SYSTEMPORT Lite */
+#define SYS_PORT_GIB_OFFSET		0x1000
+
+#define GIB_CONTROL			0x00
+#define  GIB_TX_EN			(1 << 0)
+#define  GIB_RX_EN			(1 << 1)
+#define  GIB_TX_FLUSH			(1 << 2)
+#define  GIB_RX_FLUSH			(1 << 3)
+#define  GIB_GTX_CLK_SEL_SHIFT		4
+#define  GIB_GTX_CLK_EXT_CLK		(0 << GIB_GTX_CLK_SEL_SHIFT)
+#define  GIB_GTX_CLK_125MHZ		(1 << GIB_GTX_CLK_SEL_SHIFT)
+#define  GIB_GTX_CLK_250MHZ		(2 << GIB_GTX_CLK_SEL_SHIFT)
+#define  GIB_FCS_STRIP			(1 << 6)
+#define  GIB_LCL_LOOP_EN		(1 << 7)
+#define  GIB_LCL_LOOP_TXEN		(1 << 8)
+#define  GIB_RMT_LOOP_EN		(1 << 9)
+#define  GIB_RMT_LOOP_RXEN		(1 << 10)
+#define  GIB_RX_PAUSE_EN		(1 << 11)
+#define  GIB_PREAMBLE_LEN_SHIFT		12
+#define  GIB_PREAMBLE_LEN_MASK		0xf
+#define  GIB_IPG_LEN_SHIFT		16
+#define  GIB_IPG_LEN_MASK		0x3f
+#define  GIB_PAD_EXTENSION_SHIFT	22
+#define  GIB_PAD_EXTENSION_MASK		0x3f
+
+#define GIB_MAC1			0x08
+#define GIB_MAC0			0x0c
+
 /* Receive DMA offset and defines */
 #define SYS_PORT_RDMA_OFFSET		0x2000
 
@@ -409,16 +444,19 @@ struct bcm_rsb {
 					RING_PCP_DEI_VID)
 
 #define TDMA_CONTROL			0x600
-#define  TDMA_EN			(1 << 0)
-#define  TSB_EN				(1 << 1)
-#define  TSB_SWAP			(1 << 2)
-#define  ACB_ALGO			(1 << 3)
+#define  TDMA_EN			0
+#define  TSB_EN				1
+/* Uses 2 bits on SYSTEMPORT Lite and shifts everything by 1 bit, we
+ * keep the SYSTEMPORT layout here and adjust with tdma_control_bit()
+ */
+#define  TSB_SWAP			2
+#define  ACB_ALGO			3
 #define  BUF_DATA_OFFSET_SHIFT		4
 #define  BUF_DATA_OFFSET_MASK		0x3ff
-#define  VLAN_EN			(1 << 14)
-#define  SW_BRCM_TAG			(1 << 15)
-#define  WNC_KPT_SIZE_UPDATE		(1 << 16)
-#define  SYNC_PKT_SIZE			(1 << 17)
+#define  VLAN_EN			14
+#define  SW_BRCM_TAG			15
+#define  WNC_KPT_SIZE_UPDATE		16
+#define  SYNC_PKT_SIZE			17
 #define  ACH_TXDONE_DELAY_SHIFT		18
 #define  ACH_TXDONE_DELAY_MASK		0xff
 
@@ -475,12 +513,12 @@ struct dma_desc {
 };
 
 /* Number of Receive hardware descriptor words */
-#define NUM_HW_RX_DESC_WORDS		1024
-/* Real number of usable descriptors */
-#define NUM_RX_DESC			(NUM_HW_RX_DESC_WORDS / WORDS_PER_DESC)
+#define SP_NUM_HW_RX_DESC_WORDS		1024
+#define SP_LT_NUM_HW_RX_DESC_WORDS	256
 
-/* Internal linked-list RAM has up to 1536 entries */
-#define NUM_TX_DESC			1536
+/* Internal linked-list RAM size */
+#define SP_NUM_TX_DESC			1536
+#define SP_LT_NUM_TX_DESC		256
 
 #define WORDS_PER_DESC			(sizeof(struct dma_desc) / sizeof(u32))
 
@@ -627,6 +665,16 @@ struct bcm_sysport_cb {
 	DEFINE_DMA_UNMAP_LEN(dma_len);
 };
 
+enum bcm_sysport_type {
+	SYSTEMPORT = 0,
+	SYSTEMPORT_LITE,
+};
+
+struct bcm_sysport_hw_params {
+	bool		is_lite;
+	unsigned int	num_rx_desc_words;
+};
+
 /* Software view of the TX ring */
 struct bcm_sysport_tx_ring {
 	spinlock_t	lock;		/* Ring lock for tx reclaim/xmit */
@@ -651,6 +699,8 @@ struct bcm_sysport_priv {
 	u32			irq0_mask;
 	u32			irq1_stat;
 	u32			irq1_mask;
+	bool			is_lite;
+	unsigned int		num_rx_desc_words;
 	struct napi_struct	napi ____cacheline_aligned;
 	struct net_device	*netdev;
 	struct platform_device	*pdev;
-- 
2.11.0
