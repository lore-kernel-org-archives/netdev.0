From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 07/13] stmmac: reorganise class operations.
Date: Thu,  7 Jan 2010 10:07:17 +0100
Message-ID: <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42556 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756333Ab0AGJHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:31 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E5402188
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:25 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6260ABE4
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:25 +0000 (GMT)
In-Reply-To: <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reorganises the internal stmmac ops structure.
The stmmac_ops has been splitted into other three structures named:
 stmmac_ops
 stmmac_dma_ops
 stmmac_desc_ops

This makes the code more clear and also helps the next work to
make the driver more generic.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |   64 +++++++++--------
 drivers/net/stmmac/gmac.c           |   43 +++++++----
 drivers/net/stmmac/mac100.c         |   43 +++++++----
 drivers/net/stmmac/stmmac.h         |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c |    8 +-
 drivers/net/stmmac/stmmac_main.c    |  138 +++++++++++++++++------------------
 drivers/net/stmmac/stmmac_mdio.c    |   10 +-
 7 files changed, 162 insertions(+), 146 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index e49e518..95782cc 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -239,25 +239,11 @@ static inline void stmmac_get_mac_addr(unsigned long ioaddr,
 	return;
 }
 
-struct stmmac_ops {
-	/* MAC core initialization */
-	void (*core_init) (unsigned long ioaddr) ____cacheline_aligned;
-	/* DMA core initialization */
-	int (*dma_init) (unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
-	/* Dump MAC registers */
-	void (*dump_mac_regs) (unsigned long ioaddr);
-	/* Dump DMA registers */
-	void (*dump_dma_regs) (unsigned long ioaddr);
-	/* Set tx/rx threshold in the csr6 register
-	 * An invalid value enables the store-and-forward mode */
-	void (*dma_mode) (unsigned long ioaddr, int txmode, int rxmode);
-	/* To track extra statistic (if supported) */
-	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
-				   unsigned long ioaddr);
-	/* RX descriptor ring initialization */
+struct stmmac_desc_ops {
+	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
-				int disable_rx_ic);
-	/* TX descriptor ring initialization */
+			      int disable_rx_ic);
+	/* DMA TX descriptor ring initialization */
 	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
@@ -281,7 +267,6 @@ struct stmmac_ops {
 	/* Get the buffer size from the descriptor */
 	int (*get_tx_len) (struct dma_desc *p);
 	/* Handle extra events on specific interrupts hw dependent */
-	void (*host_irq_status) (unsigned long ioaddr);
 	int (*get_rx_owner) (struct dma_desc *p);
 	void (*set_rx_owner) (struct dma_desc *p);
 	/* Get the receive frame size */
@@ -289,6 +274,28 @@ struct stmmac_ops {
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
 			  struct dma_desc *p);
+};
+
+struct stmmac_dma_ops {
+	/* DMA core initialization */
+	int (*init) (unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
+	/* Dump DMA registers */
+	void (*dump_regs) (unsigned long ioaddr);
+	/* Set tx/rx threshold in the csr6 register
+	 * An invalid value enables the store-and-forward mode */
+	void (*dma_mode) (unsigned long ioaddr, int txmode, int rxmode);
+	/* To track extra statistic (if supported) */
+	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
+				   unsigned long ioaddr);
+};
+
+struct stmmac_ops {
+	/* MAC core initialization */
+	void (*core_init) (unsigned long ioaddr) ____cacheline_aligned;
+	/* Dump MAC registers */
+	void (*dump_regs) (unsigned long ioaddr);
+	/* Handle extra events on specific interrupts hw dependent */
+	void (*host_irq_status) (unsigned long ioaddr);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev);
 	/* Flow control setting */
@@ -298,9 +305,9 @@ struct stmmac_ops {
 	void (*pmt) (unsigned long ioaddr, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
 	void (*set_umac_addr) (unsigned long ioaddr, unsigned char *addr,
-			     unsigned int reg_n);
+			       unsigned int reg_n);
 	void (*get_umac_addr) (unsigned long ioaddr, unsigned char *addr,
-			     unsigned int reg_n);
+			       unsigned int reg_n);
 };
 
 struct mac_link {
@@ -314,16 +321,13 @@ struct mii_regs {
 	unsigned int data;	/* MII Data */
 };
 
-struct hw_cap {
-	unsigned int version;	/* Core Version register (GMAC) */
-	unsigned int pmt;	/* Power-Down mode (GMAC) */
-	struct mac_link link;
-	struct mii_regs mii;
-};
-
 struct mac_device_info {
-	struct hw_cap hw;
-	struct stmmac_ops *ops;
+	struct stmmac_ops	*mac;
+	struct stmmac_desc_ops	*desc;
+	struct stmmac_dma_ops	*dma;
+	unsigned int pmt;	/* support Power-Down */
+	struct mii_regs mii;	/* MII register Addresses */
+	struct mac_link link;
 };
 
 struct mac_device_info *gmac_setup(unsigned long addr);
diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
index c127887..cf199d9 100644
--- a/drivers/net/stmmac/gmac.c
+++ b/drivers/net/stmmac/gmac.c
@@ -630,19 +630,28 @@ static int gmac_get_rx_frame_len(struct dma_desc *p)
 	return p->des01.erx.frame_length;
 }
 
-struct stmmac_ops gmac_driver = {
+struct stmmac_ops gmac_ops = {
 	.core_init = gmac_core_init,
-	.dump_mac_regs = gmac_dump_regs,
-	.dma_init = gmac_dma_init,
-	.dump_dma_regs = gmac_dump_dma_regs,
+	.dump_regs = gmac_dump_regs,
+	.host_irq_status = gmac_irq_status,
+	.set_filter = gmac_set_filter,
+	.flow_ctrl = gmac_flow_ctrl,
+	.pmt = gmac_pmt,
+	.set_umac_addr = gmac_set_umac_addr,
+	.get_umac_addr = gmac_get_umac_addr,
+};
+
+struct stmmac_dma_ops gmac_dma_ops = {
+	.init = gmac_dma_init,
+	.dump_regs = gmac_dump_dma_regs,
 	.dma_mode = gmac_dma_operation_mode,
 	.dma_diagnostic_fr = gmac_dma_diagnostic_fr,
+};
+
+struct stmmac_desc_ops gmac_desc_ops = {
 	.tx_status = gmac_get_tx_frame_status,
 	.rx_status = gmac_get_rx_frame_status,
 	.get_tx_len = gmac_get_tx_len,
-	.set_filter = gmac_set_filter,
-	.flow_ctrl = gmac_flow_ctrl,
-	.pmt = gmac_pmt,
 	.init_rx_desc = gmac_init_rx_desc,
 	.init_tx_desc = gmac_init_tx_desc,
 	.get_tx_owner = gmac_get_tx_owner,
@@ -655,9 +664,6 @@ struct stmmac_ops gmac_driver = {
 	.set_tx_owner = gmac_set_tx_owner,
 	.set_rx_owner = gmac_set_rx_owner,
 	.get_rx_frame_len = gmac_get_rx_frame_len,
-	.host_irq_status = gmac_irq_status,
-	.set_umac_addr = gmac_set_umac_addr,
-	.get_umac_addr = gmac_get_umac_addr,
 };
 
 struct mac_device_info *gmac_setup(unsigned long ioaddr)
@@ -670,13 +676,16 @@ struct mac_device_info *gmac_setup(unsigned long ioaddr)
 
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
 
-	mac->ops = &gmac_driver;
-	mac->hw.pmt = PMT_SUPPORTED;
-	mac->hw.link.port = GMAC_CONTROL_PS;
-	mac->hw.link.duplex = GMAC_CONTROL_DM;
-	mac->hw.link.speed = GMAC_CONTROL_FES;
-	mac->hw.mii.addr = GMAC_MII_ADDR;
-	mac->hw.mii.data = GMAC_MII_DATA;
+	mac->mac = &gmac_ops;
+	mac->desc = &gmac_desc_ops;
+	mac->dma = &gmac_dma_ops;
+
+	mac->pmt = PMT_SUPPORTED;
+	mac->link.port = GMAC_CONTROL_PS;
+	mac->link.duplex = GMAC_CONTROL_DM;
+	mac->link.speed = GMAC_CONTROL_FES;
+	mac->mii.addr = GMAC_MII_ADDR;
+	mac->mii.data = GMAC_MII_DATA;
 
 	return mac;
 }
diff --git a/drivers/net/stmmac/mac100.c b/drivers/net/stmmac/mac100.c
index 625171b..45d0457 100644
--- a/drivers/net/stmmac/mac100.c
+++ b/drivers/net/stmmac/mac100.c
@@ -467,19 +467,28 @@ static int mac100_get_rx_frame_len(struct dma_desc *p)
 	return p->des01.rx.frame_length;
 }
 
-struct stmmac_ops mac100_driver = {
+struct stmmac_ops mac100_ops = {
 	.core_init = mac100_core_init,
-	.dump_mac_regs = mac100_dump_mac_regs,
-	.dma_init = mac100_dma_init,
-	.dump_dma_regs = mac100_dump_dma_regs,
+	.dump_regs = mac100_dump_mac_regs,
+	.host_irq_status = mac100_irq_status,
+	.set_filter = mac100_set_filter,
+	.flow_ctrl = mac100_flow_ctrl,
+	.pmt = mac100_pmt,
+	.set_umac_addr = mac100_set_umac_addr,
+	.get_umac_addr = mac100_get_umac_addr,
+};
+
+struct stmmac_dma_ops mac100_dma_ops = {
+	.init = mac100_dma_init,
+	.dump_regs = mac100_dump_dma_regs,
 	.dma_mode = mac100_dma_operation_mode,
 	.dma_diagnostic_fr = mac100_dma_diagnostic_fr,
+};
+
+struct stmmac_desc_ops mac100_desc_ops = {
 	.tx_status = mac100_get_tx_frame_status,
 	.rx_status = mac100_get_rx_frame_status,
 	.get_tx_len = mac100_get_tx_len,
-	.set_filter = mac100_set_filter,
-	.flow_ctrl = mac100_flow_ctrl,
-	.pmt = mac100_pmt,
 	.init_rx_desc = mac100_init_rx_desc,
 	.init_tx_desc = mac100_init_tx_desc,
 	.get_tx_owner = mac100_get_tx_owner,
@@ -492,9 +501,6 @@ struct stmmac_ops mac100_driver = {
 	.set_tx_owner = mac100_set_tx_owner,
 	.set_rx_owner = mac100_set_rx_owner,
 	.get_rx_frame_len = mac100_get_rx_frame_len,
-	.host_irq_status = mac100_irq_status,
-	.set_umac_addr = mac100_set_umac_addr,
-	.get_umac_addr = mac100_get_umac_addr,
 };
 
 struct mac_device_info *mac100_setup(unsigned long ioaddr)
@@ -505,13 +511,16 @@ struct mac_device_info *mac100_setup(unsigned long ioaddr)
 
 	pr_info("\tMAC 10/100\n");
 
-	mac->ops = &mac100_driver;
-	mac->hw.pmt = PMT_NOT_SUPPORTED;
-	mac->hw.link.port = MAC_CONTROL_PS;
-	mac->hw.link.duplex = MAC_CONTROL_F;
-	mac->hw.link.speed = 0;
-	mac->hw.mii.addr = MAC_MII_ADDR;
-	mac->hw.mii.data = MAC_MII_DATA;
+	mac->mac = &mac100_ops;
+	mac->desc = &mac100_desc_ops;
+	mac->dma = &mac100_dma_ops;
+
+	mac->pmt = PMT_NOT_SUPPORTED;
+	mac->link.port = MAC_CONTROL_PS;
+	mac->link.duplex = MAC_CONTROL_F;
+	mac->link.speed = 0;
+	mac->mii.addr = MAC_MII_ADDR;
+	mac->mii.data = MAC_MII_DATA;
 
 	return mac;
 }
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 0d5529f..44421d9 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -58,7 +58,7 @@ struct stmmac_priv {
 	int rx_csum;
 	unsigned int dma_buf_sz;
 	struct device *device;
-	struct mac_device_info *mac_type;
+	struct mac_device_info *hw;
 
 	struct stmmac_extra_stats xstats;
 	struct napi_struct napi;
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 694ebe6..9c7ce1e 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -268,8 +268,8 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		}
 	} else {
 		unsigned long ioaddr = netdev->base_addr;
-		priv->mac_type->ops->flow_ctrl(ioaddr, phy->duplex,
-					       priv->flow_ctrl, priv->pause);
+		priv->hw->mac->flow_ctrl(ioaddr, phy->duplex,
+					 priv->flow_ctrl, priv->pause);
 	}
 	spin_unlock(&priv->lock);
 	return ret;
@@ -283,8 +283,8 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 	int i;
 
 	/* Update HW stats if supported */
-	priv->mac_type->ops->dma_diagnostic_fr(&dev->stats, &priv->xstats,
-					       ioaddr);
+	priv->hw->dma->dma_diagnostic_fr(&dev->stats, (void *) &priv->xstats,
+					 ioaddr);
 
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 82ebbc0..86e9103 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -225,38 +225,34 @@ static void stmmac_adjust_link(struct net_device *dev)
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
 			if (!(phydev->duplex))
-				ctrl &= ~priv->mac_type->hw.link.duplex;
+				ctrl &= ~priv->hw->link.duplex;
 			else
-				ctrl |= priv->mac_type->hw.link.duplex;
+				ctrl |= priv->hw->link.duplex;
 			priv->oldduplex = phydev->duplex;
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->mac_type->ops->flow_ctrl(ioaddr, phydev->duplex,
-						       fc, pause_time);
+			priv->hw->mac->flow_ctrl(ioaddr, phydev->duplex,
+						 fc, pause_time);
 
 		if (phydev->speed != priv->speed) {
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
 				if (likely(priv->is_gmac))
-					ctrl &= ~priv->mac_type->hw.link.port;
+					ctrl &= ~priv->hw->link.port;
 				break;
 			case 100:
 			case 10:
 				if (priv->is_gmac) {
-					ctrl |= priv->mac_type->hw.link.port;
+					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
-						ctrl |=
-						    priv->mac_type->hw.link.
-						    speed;
+						ctrl |= priv->hw->link.speed;
 					} else {
-						ctrl &=
-						    ~(priv->mac_type->hw.
-						      link.speed);
+						ctrl &= ~(priv->hw->link.speed);
 					}
 				} else {
-					ctrl &= ~priv->mac_type->hw.link.port;
+					ctrl &= ~priv->hw->link.port;
 				}
 				if (likely(priv->fix_mac_speed))
 					priv->fix_mac_speed(priv->bsp_priv,
@@ -509,8 +505,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->cur_tx = 0;
 
 	/* Clear the Rx/Tx descriptors */
-	priv->mac_type->ops->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
-	priv->mac_type->ops->init_tx_desc(priv->dma_tx, txsize);
+	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize);
 
 	if (netif_msg_hw(priv)) {
 		pr_info("RX descriptor ring:\n");
@@ -545,8 +541,8 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 			struct dma_desc *p = priv->dma_tx + i;
 			if (p->des2)
 				dma_unmap_single(priv->device, p->des2,
-				 priv->mac_type->ops->get_tx_len(p),
-				 DMA_TO_DEVICE);
+						 priv->hw->desc->get_tx_len(p),
+						 DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 		}
@@ -630,18 +626,18 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
 	if (!priv->is_gmac) {
 		/* MAC 10/100 */
-		priv->mac_type->ops->dma_mode(priv->dev->base_addr, tc, 0);
+		priv->hw->dma->dma_mode(priv->dev->base_addr, tc, 0);
 		priv->tx_coe = NO_HW_CSUM;
 	} else {
 		if ((priv->dev->mtu <= ETH_DATA_LEN) && (tx_coe)) {
-			priv->mac_type->ops->dma_mode(priv->dev->base_addr,
-						      SF_DMA_MODE, SF_DMA_MODE);
+			priv->hw->dma->dma_mode(priv->dev->base_addr,
+						SF_DMA_MODE, SF_DMA_MODE);
 			tc = SF_DMA_MODE;
 			priv->tx_coe = HW_CSUM;
 		} else {
 			/* Checksum computation is performed in software. */
-			priv->mac_type->ops->dma_mode(priv->dev->base_addr, tc,
-						      SF_DMA_MODE);
+			priv->hw->dma->dma_mode(priv->dev->base_addr, tc,
+						SF_DMA_MODE);
 			priv->tx_coe = NO_HW_CSUM;
 		}
 	}
@@ -749,16 +745,16 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		struct dma_desc *p = priv->dma_tx + entry;
 
 		/* Check if the descriptor is owned by the DMA. */
-		if (priv->mac_type->ops->get_tx_owner(p))
+		if (priv->hw->desc->get_tx_owner(p))
 			break;
 
 		/* Verify tx error by looking at the last segment */
-		last = priv->mac_type->ops->get_tx_ls(p);
+		last = priv->hw->desc->get_tx_ls(p);
 		if (likely(last)) {
 			int tx_error =
-			    priv->mac_type->ops->tx_status(&priv->dev->stats,
-							   &priv->xstats,
-							   p, ioaddr);
+				priv->hw->desc->tx_status(&priv->dev->stats,
+							  &priv->xstats, p,
+							  ioaddr);
 			if (likely(tx_error == 0)) {
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
@@ -770,7 +766,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 		if (likely(p->des2))
 			dma_unmap_single(priv->device, p->des2,
-					 priv->mac_type->ops->get_tx_len(p),
+					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
 		if (unlikely(p->des3))
 			p->des3 = 0;
@@ -791,7 +787,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			priv->tx_skbuff[entry] = NULL;
 		}
 
-		priv->mac_type->ops->release_tx_desc(p);
+		priv->hw->desc->release_tx_desc(p);
 
 		entry = (++priv->dirty_tx) % txsize;
 	}
@@ -833,7 +829,7 @@ static int stmmac_has_work(struct stmmac_priv *priv)
 	unsigned int has_work = 0;
 	int rxret, tx_work = 0;
 
-	rxret = priv->mac_type->ops->get_rx_owner(priv->dma_rx +
+	rxret = priv->hw->desc->get_rx_owner(priv->dma_rx +
 		(priv->cur_rx % priv->dma_rx_size));
 
 	if (priv->dirty_tx != priv->cur_tx)
@@ -886,7 +882,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 
 	stmmac_dma_stop_tx(priv->dev->base_addr);
 	dma_free_tx_skbufs(priv);
-	priv->mac_type->ops->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	stmmac_dma_start_tx(priv->dev->base_addr);
@@ -926,8 +922,8 @@ static void stmmac_dma_interrupt(struct net_device *dev)
 			if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 				/* Try to bump up the threshold */
 				tc += 64;
-				priv->mac_type->ops->dma_mode(ioaddr, tc,
-					      SF_DMA_MODE);
+				priv->hw->dma->dma_mode(ioaddr, tc,
+							SF_DMA_MODE);
 				priv->xstats.threshold = tc;
 			}
 			stmmac_tx_err(priv);
@@ -1059,20 +1055,20 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	if (unlikely(priv->mac_type->ops->dma_init(ioaddr,
-		priv->pbl, priv->dma_tx_phy, priv->dma_rx_phy) < 0)) {
+	if (unlikely(priv->hw->dma->init(ioaddr, priv->pbl, priv->dma_tx_phy,
+					 priv->dma_rx_phy) < 0)) {
 
 		pr_err("%s: DMA initialization failed\n", __func__);
 		return -1;
 	}
 
 	/* Copy the MAC addr into the HW  */
-	priv->mac_type->ops->set_umac_addr(ioaddr, dev->dev_addr, 0);
+	priv->hw->mac->set_umac_addr(ioaddr, dev->dev_addr, 0);
 	/* If required, perform hw setup of the bus. */
 	if (priv->bus_setup)
 		priv->bus_setup(ioaddr);
 	/* Initialize the MAC Core */
-	priv->mac_type->ops->core_init(ioaddr);
+	priv->hw->mac->core_init(ioaddr);
 
 	priv->shutdown = 0;
 
@@ -1101,8 +1097,8 @@ static int stmmac_open(struct net_device *dev)
 #endif
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
-		priv->mac_type->ops->dump_mac_regs(ioaddr);
-		priv->mac_type->ops->dump_dma_regs(ioaddr);
+		priv->hw->mac->dump_regs(ioaddr);
+		priv->hw->dma->dump_regs(ioaddr);
 	}
 
 	if (priv->phydev)
@@ -1218,8 +1214,8 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    BUF_SIZE_8KiB, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
-						     csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
+						csum_insertion);
 
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
@@ -1228,16 +1224,17 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 					skb->data + BUF_SIZE_8KiB,
 					buf2_size, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 0,
-						     buf2_size, csum_insertion);
-		priv->mac_type->ops->set_tx_owner(desc);
+		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
+						csum_insertion);
+		priv->hw->desc->set_tx_owner(desc);
+
 		priv->tx_skbuff[entry] = NULL;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, nopaged_len,
-						     csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
+						csum_insertion);
 	}
 	return entry;
 }
@@ -1305,8 +1302,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		unsigned int nopaged_len = skb_headlen(skb);
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, nopaged_len,
-						     csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
+						csum_insertion);
 	}
 
 	for (i = 0; i < nfrags; i++) {
@@ -1321,21 +1318,20 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 					  frag->page_offset,
 					  len, DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] = NULL;
-		priv->mac_type->ops->prepare_tx_desc(desc, 0, len,
-						     csum_insertion);
-		priv->mac_type->ops->set_tx_owner(desc);
+		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
+		priv->hw->desc->set_tx_owner(desc);
 	}
 
 	/* Interrupt on completition only for the latest segment */
-	priv->mac_type->ops->close_tx_desc(desc);
+	priv->hw->desc->close_tx_desc(desc);
 
 #ifdef CONFIG_STMMAC_TIMER
 	/* Clean IC while using timer */
 	if (likely(priv->tm->enable))
-		priv->mac_type->ops->clear_tx_ic(desc);
+		priv->hw->desc->clear_tx_ic(desc);
 #endif
 	/* To avoid raise condition */
-	priv->mac_type->ops->set_tx_owner(first);
+	priv->hw->desc->set_tx_owner(first);
 
 	priv->cur_tx++;
 
@@ -1395,7 +1391,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			}
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
-		priv->mac_type->ops->set_rx_owner(p + entry);
+		priv->hw->desc->set_rx_owner(p + entry);
 	}
 	return;
 }
@@ -1416,7 +1412,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	}
 #endif
 	count = 0;
-	while (!priv->mac_type->ops->get_rx_owner(p)) {
+	while (!priv->hw->desc->get_rx_owner(p)) {
 		int status;
 
 		if (count >= limit)
@@ -1429,15 +1425,14 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		prefetch(p_next);
 
 		/* read the status of the incoming frame */
-		status = (priv->mac_type->ops->rx_status(&priv->dev->stats,
-							 &priv->xstats, p));
+		status = (priv->hw->desc->rx_status(&priv->dev->stats,
+						    &priv->xstats, p));
 		if (unlikely(status == discard_frame))
 			priv->dev->stats.rx_errors++;
 		else {
 			struct sk_buff *skb;
 			/* Length should omit the CRC */
-			int frame_len =
-			    priv->mac_type->ops->get_rx_frame_len(p) - 4;
+			int frame_len = priv->hw->desc->get_rx_frame_len(p) - 4;
 
 #ifdef STMMAC_RX_DEBUG
 			if (frame_len > ETH_FRAME_LEN)
@@ -1573,7 +1568,7 @@ static void stmmac_multicast_list(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	spin_lock(&priv->lock);
-	priv->mac_type->ops->set_filter(dev);
+	priv->hw->mac->set_filter(dev);
 	spin_unlock(&priv->lock);
 	return;
 }
@@ -1627,7 +1622,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	if (priv->is_gmac) {
 		unsigned long ioaddr = dev->base_addr;
 		/* To handle GMAC own interrupts */
-		priv->mac_type->ops->host_irq_status(ioaddr);
+		priv->hw->mac->host_irq_status(ioaddr);
 	}
 	stmmac_dma_interrupt(dev);
 
@@ -1748,7 +1743,7 @@ static int stmmac_probe(struct net_device *dev)
 	netif_napi_add(dev, &priv->napi, stmmac_poll, 64);
 
 	/* Get the MAC address */
-	priv->mac_type->ops->get_umac_addr(dev->base_addr, dev->dev_addr, 0);
+	priv->hw->mac->get_umac_addr(dev->base_addr, dev->dev_addr, 0);
 
 	if (!is_valid_ether_addr(dev->dev_addr))
 		pr_warning("\tno valid MAC address;"
@@ -1790,9 +1785,9 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	if (!device)
 		return -ENOMEM;
 
-	priv->mac_type = device;
+	priv->hw = device;
 
-	priv->wolenabled = priv->mac_type->hw.pmt;	/* PMT supported */
+	priv->wolenabled = priv->hw->pmt;	/* PMT supported */
 	if (priv->wolenabled == PMT_SUPPORTED)
 		priv->wolopts = WAKE_MAGIC;		/* Magic Frame */
 
@@ -2048,18 +2043,17 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 		stmmac_dma_stop_tx(dev->base_addr);
 		stmmac_dma_stop_rx(dev->base_addr);
 		/* Clear the Rx/Tx descriptors */
-		priv->mac_type->ops->init_rx_desc(priv->dma_rx,
-						  priv->dma_rx_size, dis_ic);
-		priv->mac_type->ops->init_tx_desc(priv->dma_tx,
-						  priv->dma_tx_size);
+		priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
+					     dis_ic);
+		priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 
 		stmmac_mac_disable_tx(dev->base_addr);
 
 		if (device_may_wakeup(&(pdev->dev))) {
 			/* Enable Power down mode by programming the PMT regs */
 			if (priv->wolenabled == PMT_SUPPORTED)
-				priv->mac_type->ops->pmt(dev->base_addr,
-							 priv->wolopts);
+				priv->hw->mac->pmt(dev->base_addr,
+						   priv->wolopts);
 		} else {
 			stmmac_mac_disable_rx(dev->base_addr);
 		}
@@ -2100,7 +2094,7 @@ static int stmmac_resume(struct platform_device *pdev)
 	 * from another devices (e.g. serial console). */
 	if (device_may_wakeup(&(pdev->dev)))
 		if (priv->wolenabled == PMT_SUPPORTED)
-			priv->mac_type->ops->pmt(dev->base_addr, 0);
+			priv->hw->mac->pmt(dev->base_addr, 0);
 
 	netif_device_attach(dev);
 
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 8498552..131e0a6 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -48,8 +48,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
-	unsigned int mii_data = priv->mac_type->hw.mii.data;
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
 
 	int data;
 	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
@@ -80,8 +80,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
-	unsigned int mii_data = priv->mac_type->hw.mii.data;
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
 
 	u16 value =
 	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
@@ -112,7 +112,7 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
+	unsigned int mii_address = priv->hw->mii.addr;
 
 	if (priv->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-- 
1.6.0.4

