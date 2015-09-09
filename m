From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/4] stmmac: replace all pr_xxx by their dev_xxx counterpart
Date: Wed,  9 Sep 2015 15:14:13 +0200
Message-ID: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stmmac driver use lots of pr_xxx functions to print information.
This is bad since we cannot know which device logs the information.
(moreover if two stmmac device are present)

Furthermore, it seems that it assumes wrongly that all logs will always
be subsequent by using a dev_xxx then some indented pr_xxx like this:
kernel: sun7i-dwmac 1c50000.ethernet: no reset control found
kernel:  Ring mode enabled
kernel:  No HW DMA feature register supported
kernel:  Normal descriptors
kernel:  TX Checksum insertion supported

So this patch replace all pr_xxx by their dev_xxx counterpart.

In the same time I remove some "stmmac:" print since
this will be a duplicate with that dev_xxx displays.
And this patch also change some pr_info by dev_err when
the word ERROR is printed.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 197 ++++++++++++----------
 1 file changed, 112 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 864b476..cb9efb3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -298,7 +298,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 			 */
 			spin_lock_irqsave(&priv->lock, flags);
 			if (priv->eee_active) {
-				pr_debug("stmmac: disable EEE\n");
+				dev_dbg(priv->device, "disable EEE\n");
 				del_timer_sync(&priv->eee_ctrl_timer);
 				priv->hw->mac->set_eee_timer(priv->hw, 0,
 							     tx_lpi_timer);
@@ -327,7 +327,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		ret = true;
 		spin_unlock_irqrestore(&priv->lock, flags);
 
-		pr_debug("stmmac: Energy-Efficient Ethernet initialized\n");
+		dev_dbg(priv->device, "Energy-Efficient Ethernet initialized\n");
 	}
 out:
 	return ret;
@@ -448,8 +448,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			   sizeof(struct hwtstamp_config)))
 		return -EFAULT;
 
-	pr_debug("%s config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
-		 __func__, config.flags, config.tx_type, config.rx_filter);
+	dev_dbg(priv->device, "%s config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		__func__, config.flags, config.tx_type, config.rx_filter);
 
 	/* reserved for future extensions */
 	if (config.flags)
@@ -657,10 +657,10 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 		priv->adv_ts = 1;
 
 	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
-		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+		dev_dbg(priv->device, "IEEE 1588-2002 Time Stamp supported\n");
 
 	if (netif_msg_hw(priv) && priv->adv_ts)
-		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+		dev_dbg(priv->device, "IEEE 1588-2008 Advanced Time Stamp supported\n");
 
 	priv->hw->ptp = &stmmac_ptp;
 	priv->hwts_tx_en = 0;
@@ -740,8 +740,9 @@ static void stmmac_adjust_link(struct net_device *dev)
 				break;
 			default:
 				if (netif_msg_link(priv))
-					pr_warn("%s: Speed (%d) not 10/100\n",
-						dev->name, phydev->speed);
+					dev_warn(priv->device,
+						 "%s: Speed (%d) not 10/100\n",
+						 dev->name, phydev->speed);
 				break;
 			}
 
@@ -788,10 +789,10 @@ static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
 		    (interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 		    (interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 		    (interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
-			pr_debug("STMMAC: PCS RGMII support enable\n");
+			dev_dbg(priv->device, "PCS RGMII support enable\n");
 			priv->pcs = STMMAC_PCS_RGMII;
 		} else if (interface == PHY_INTERFACE_MODE_SGMII) {
-			pr_debug("STMMAC: PCS SGMII support enable\n");
+			dev_dbg(priv->device, "PCS SGMII support enable\n");
 			priv->pcs = STMMAC_PCS_SGMII;
 		}
 	}
@@ -830,15 +831,16 @@ static int stmmac_init_phy(struct net_device *dev)
 
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
-		pr_debug("stmmac_init_phy:  trying to attach to %s\n",
-			 phy_id_fmt);
+		dev_dbg(priv->device, "stmmac_init_phy: trying to attach to %s\n",
+			phy_id_fmt);
 
 		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
 				     interface);
 	}
 
 	if (IS_ERR(phydev)) {
-		pr_err("%s: Could not attach to PHY\n", dev->name);
+		dev_err(priv->device, "%s: Could not attach to PHY\n",
+			dev->name);
 		return PTR_ERR(phydev);
 	}
 
@@ -860,8 +862,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
-	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
-		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
+	dev_dbg(priv->device, "stmmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
+		dev->name, phydev->phy_id, phydev->link);
 
 	priv->phydev = phydev;
 
@@ -908,14 +910,14 @@ static void stmmac_display_rings(struct stmmac_priv *priv)
 	unsigned int rxsize = priv->dma_rx_size;
 
 	if (priv->extend_desc) {
-		pr_info("Extended RX descriptor ring:\n");
+		dev_info(priv->device, "Extended RX descriptor ring:\n");
 		stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
-		pr_info("Extended TX descriptor ring:\n");
+		dev_info(priv->device, "Extended TX descriptor ring:\n");
 		stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
 	} else {
-		pr_info("RX descriptor ring:\n");
+		dev_info(priv->device, "RX descriptor ring:\n");
 		stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
-		pr_info("TX descriptor ring:\n");
+		dev_info(priv->device, "TX descriptor ring:\n");
 		stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
 	}
 }
@@ -985,7 +987,8 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 
 	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
 	if (!skb) {
-		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
+		dev_err(priv->device,
+			"%s: Rx init fails; skb is NULL\n", __func__);
 		return -ENOMEM;
 	}
 	priv->rx_skbuff[i] = skb;
@@ -993,7 +996,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 						priv->dma_buf_sz,
 						DMA_FROM_DEVICE);
 	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
-		pr_err("%s: DMA mapping error\n", __func__);
+		dev_err(priv->device, "%s: DMA mapping error\n", __func__);
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
@@ -1043,15 +1046,15 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	priv->dma_buf_sz = bfsize;
 
 	if (netif_msg_probe(priv))
-		pr_debug("%s: txsize %d, rxsize %d, bfsize %d\n", __func__,
-			 txsize, rxsize, bfsize);
+		dev_dbg(priv->device, "%s: txsize %d, rxsize %d, bfsize %d\n",
+			__func__, txsize, rxsize, bfsize);
 
 	if (netif_msg_probe(priv)) {
-		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
-			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
+		dev_dbg(priv->device, "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
+			__func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
 
 		/* RX INITIALIZATION */
-		pr_debug("\tSKB addresses:\nskb\t\tskb data\tdma data\n");
+		dev_dbg(priv->device, "SKB addresses:\nskb\t\tskb data\tdma data\n");
 	}
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p;
@@ -1065,7 +1068,8 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 			goto err_init_rx_buffers;
 
 		if (netif_msg_probe(priv))
-			pr_debug("[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
+			dev_dbg(priv->device, "[%p]\t[%p]\t[%x]\n",
+				priv->rx_skbuff[i],
 				 priv->rx_skbuff[i]->data,
 				 (unsigned int)priv->rx_skbuff_dma[i]);
 	}
@@ -1348,8 +1352,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
 		if (netif_msg_tx_done(priv))
-			pr_debug("%s: curr %d, dirty %d\n", __func__,
-				 priv->cur_tx, priv->dirty_tx);
+			dev_dbg(priv->device, "%s: curr %d, dirty %d\n",
+				__func__, priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
 			if (priv->tx_skbuff_dma[entry].map_as_page)
@@ -1387,7 +1391,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		if (netif_queue_stopped(priv->dev) &&
 		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
 			if (netif_msg_tx_done(priv))
-				pr_debug("%s: restart transmit\n", __func__);
+				dev_dbg(priv->device, "%s: restart transmit\n",
+					__func__);
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
@@ -1494,7 +1499,7 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 		dwmac_mmc_ctrl(priv->ioaddr, mode);
 		memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
 	} else
-		pr_info(" No MAC Management Counters available\n");
+		dev_info(priv->device, "No MAC Management Counters available\n");
 }
 
 /**
@@ -1512,8 +1517,8 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 		u32 uid = ((hwid & 0x0000ff00) >> 8);
 		u32 synid = (hwid & 0x000000ff);
 
-		pr_info("stmmac - user ID: 0x%x, Synopsys ID: 0x%x\n",
-			uid, synid);
+		dev_info(priv->device, "user ID: 0x%x, Synopsys ID: 0x%x\n",
+			 uid, synid);
 
 		return synid;
 	}
@@ -1530,18 +1535,18 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
 {
 	if (priv->plat->enh_desc) {
-		pr_info(" Enhanced/Alternate descriptors\n");
+		dev_info(priv->device, "Enhanced/Alternate descriptors\n");
 
 		/* GMAC older than 3.50 has no extended descriptors */
 		if (priv->synopsys_id >= DWMAC_CORE_3_50) {
-			pr_info("\tEnabled extended descriptors\n");
+			dev_info(priv->device, "Enabled extended descriptors\n");
 			priv->extend_desc = 1;
 		} else
-			pr_warn("Extended descriptors not supported\n");
+			dev_warn(priv->device, "Extended descriptors not supported\n");
 
 		priv->hw->desc = &enh_desc_ops;
 	} else {
-		pr_info(" Normal descriptors\n");
+		dev_info(priv->device, "Normal descriptors\n");
 		priv->hw->desc = &ndesc_ops;
 	}
 }
@@ -1618,8 +1623,8 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 					     priv->dev->dev_addr, 0);
 		if (!is_valid_ether_addr(priv->dev->dev_addr))
 			eth_hw_addr_random(priv->dev);
-		pr_info("%s: device MAC address %pM\n", priv->dev->name,
-			priv->dev->dev_addr);
+		dev_info(priv->device, "%s: device MAC address %pM\n",
+			 priv->dev->name, priv->dev->dev_addr);
 	}
 }
 
@@ -1704,7 +1709,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* DMA initialization and SW reset */
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
-		pr_err("%s: DMA engine initialization failed\n", __func__);
+		dev_err(priv->device, "%s: DMA engine initialization failed\n",
+			__func__);
 		return ret;
 	}
 
@@ -1720,7 +1726,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 
 	ret = priv->hw->mac->rx_ipc(priv->hw);
 	if (!ret) {
-		pr_warn(" RX IPC Checksum Offload disabled\n");
+		dev_warn(priv->device, "RX IPC Checksum Offload disabled\n");
 		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
 		priv->hw->rx_csum = 0;
 	}
@@ -1736,16 +1742,19 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (init_ptp) {
 		ret = stmmac_init_ptp(priv);
 		if (ret && ret != -EOPNOTSUPP)
-			pr_warn("%s: failed PTP initialisation\n", __func__);
+			dev_warn(priv->device, "%s: failed PTP initialisation\n",
+				 __func__);
 	}
 
 #ifdef CONFIG_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
-		pr_warn("%s: failed debugFS registration\n", __func__);
+		dev_warn(priv->device, "%s: failed debugFS registration\n",
+			 __func__);
 #endif
 	/* Start the ball rolling... */
-	pr_debug("%s: DMA RX/TX processes started...\n", dev->name);
+	dev_dbg(priv->device, "%s: DMA RX/TX processes started...\n",
+		dev->name);
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
@@ -1787,7 +1796,8 @@ static int stmmac_open(struct net_device *dev)
 	    priv->pcs != STMMAC_PCS_RTBI) {
 		ret = stmmac_init_phy(dev);
 		if (ret) {
-			pr_err("%s: Cannot attach to PHY (error: %d)\n",
+			dev_err(priv->device,
+				"%s: Cannot attach to PHY (error: %d)\n",
 			       __func__, ret);
 			return ret;
 		}
@@ -1804,19 +1814,22 @@ static int stmmac_open(struct net_device *dev)
 
 	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
-		pr_err("%s: DMA descriptors allocation failed\n", __func__);
+		dev_err(priv->device, "%s: DMA descriptors allocation failed\n",
+			__func__);
 		goto dma_desc_error;
 	}
 
 	ret = init_dma_desc_rings(dev, GFP_KERNEL);
 	if (ret < 0) {
-		pr_err("%s: DMA descriptors initialization failed\n", __func__);
+		dev_err(priv->device,
+			"%s: DMA descriptors initialization failed\n",
+			__func__);
 		goto init_error;
 	}
 
 	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
-		pr_err("%s: Hw setup failed\n", __func__);
+		dev_err(priv->device, "%s: Hw setup failed\n", __func__);
 		goto init_error;
 	}
 
@@ -1829,7 +1842,8 @@ static int stmmac_open(struct net_device *dev)
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
-		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
+		dev_err(priv->device,
+			"%s: ERROR: allocating the IRQ %d (error: %d)\n",
 		       __func__, dev->irq, ret);
 		goto init_error;
 	}
@@ -1839,7 +1853,8 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->wol_irq, stmmac_interrupt,
 				  IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating the WoL IRQ %d (%d)\n",
+			dev_err(priv->device,
+				"%s: ERROR: allocating the WoL IRQ %d (%d)\n",
 			       __func__, priv->wol_irq, ret);
 			goto wolirq_error;
 		}
@@ -1850,7 +1865,8 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->lpi_irq, stmmac_interrupt, IRQF_SHARED,
 				  dev->name, dev);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating the LPI IRQ %d (%d)\n",
+			dev_err(priv->device,
+				"%s: ERROR: allocating the LPI IRQ %d (%d)\n",
 			       __func__, priv->lpi_irq, ret);
 			goto lpiirq_error;
 		}
@@ -1956,7 +1972,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
-			pr_err("%s: Tx Ring full when queue awake\n", __func__);
+			dev_err(priv->device,
+				"%s: Tx Ring full when queue awake\n",
+				__func__);
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -2045,7 +2063,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->cur_tx++;
 
 	if (netif_msg_pktdata(priv)) {
-		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
+		dev_dbg(priv->device,
+			"%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
 			__func__, (priv->cur_tx % txsize),
 			(priv->dirty_tx % txsize), entry, first, nfrags);
 
@@ -2054,12 +2073,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		else
 			stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
 
-		pr_debug(">>> frame to be transmitted: ");
+		dev_dbg(priv->device, ">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
 	}
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
 		if (netif_msg_hw(priv))
-			pr_debug("%s: stop transmitted packets\n", __func__);
+			dev_dbg(priv->device,
+				"%s: stop transmitted packets\n", __func__);
 		netif_stop_queue(dev);
 	}
 
@@ -2083,7 +2103,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 dma_map_err:
 	spin_unlock(&priv->tx_lock);
-	dev_err(priv->device, "Tx dma map failed\n");
+	dev_err(priv->device, "Tx DMA map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
@@ -2140,7 +2160,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 					   DMA_FROM_DEVICE);
 			if (dma_mapping_error(priv->device,
 					      priv->rx_skbuff_dma[entry])) {
-				dev_err(priv->device, "Rx dma map failed\n");
+				dev_err(priv->device, "Rx DMA map failed\n");
 				dev_kfree_skb(skb);
 				break;
 			}
@@ -2149,7 +2169,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			priv->hw->mode->refill_desc3(priv, p);
 
 			if (netif_msg_rx_status(priv))
-				pr_debug("\trefill entry #%d\n", entry);
+				dev_dbg(priv->device,
+					"refill entry #%d\n", entry);
 		}
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
@@ -2173,7 +2194,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	int coe = priv->hw->rx_csum;
 
 	if (netif_msg_rx_status(priv)) {
-		pr_debug("%s: descriptor ring:\n", __func__);
+		dev_dbg(priv->device, "%s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
 		else
@@ -2234,16 +2255,17 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				frame_len -= ETH_FCS_LEN;
 
 			if (netif_msg_rx_status(priv)) {
-				pr_debug("\tdesc: %p [entry %d] buff=0x%x\n",
-					 p, entry, p->des2);
+				dev_dbg(priv->device, "desc: %p [entry %d] buff=0x%x\n",
+					p, entry, p->des2);
 				if (frame_len > ETH_FRAME_LEN)
-					pr_debug("\tframe size %d, COE: %d\n",
-						 frame_len, status);
+					dev_dbg(priv->device, "frame size %d, COE: %d\n",
+						frame_len, status);
 			}
 			skb = priv->rx_skbuff[entry];
 			if (unlikely(!skb)) {
-				pr_err("%s: Inconsistent Rx descriptor chain\n",
-				       priv->dev->name);
+				dev_err(priv->device,
+					"%s: Inconsistent Rx descriptor chain\n",
+					priv->dev->name);
 				priv->dev->stats.rx_dropped++;
 				break;
 			}
@@ -2258,7 +2280,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 					 priv->dma_buf_sz, DMA_FROM_DEVICE);
 
 			if (netif_msg_pktdata(priv)) {
-				pr_debug("frame received (%dbytes)", frame_len);
+				dev_dbg(priv->device, "frame received (%dbytes)",
+					frame_len);
 				print_pkt(skb->data, frame_len);
 			}
 
@@ -2359,7 +2382,8 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 	int max_mtu;
 
 	if (netif_running(dev)) {
-		pr_err("%s: must be stopped to change its MTU\n", dev->name);
+		dev_err(priv->device,
+			"%s: must be stopped to change its MTU\n", dev->name);
 		return -EBUSY;
 	}
 
@@ -2372,7 +2396,9 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 		max_mtu = priv->plat->maxmtu;
 
 	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
-		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
+		dev_err(priv->device,
+			"%s: invalid MTU, max MTU is: %d\n",
+			dev->name, max_mtu);
 		return -EINVAL;
 	}
 
@@ -2442,7 +2468,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		pm_wakeup_event(priv->device, 0);
 
 	if (unlikely(!dev)) {
-		pr_err("%s: invalid dev pointer\n", __func__);
+		dev_err(priv->device, "%s: invalid dev pointer\n", __func__);
 		return IRQ_NONE;
 	}
 
@@ -2658,8 +2684,7 @@ static int stmmac_init_fs(struct net_device *dev)
 	priv->dbgfs_dir = debugfs_create_dir(dev->name, stmmac_fs_dir);
 
 	if (!priv->dbgfs_dir || IS_ERR(priv->dbgfs_dir)) {
-		pr_err("ERROR %s/%s, debugfs create directory failed\n",
-		       STMMAC_RESOURCE_NAME, dev->name);
+		dev_err(priv->device, "ERROR failed to create debugfs directory\n");
 
 		return -ENOMEM;
 	}
@@ -2671,7 +2696,7 @@ static int stmmac_init_fs(struct net_device *dev)
 				    &stmmac_rings_status_fops);
 
 	if (!priv->dbgfs_rings_status || IS_ERR(priv->dbgfs_rings_status)) {
-		pr_info("ERROR creating stmmac ring debugfs file\n");
+		dev_err(priv->device, "ERROR creating stmmac ring debugfs file\n");
 		debugfs_remove_recursive(priv->dbgfs_dir);
 
 		return -ENOMEM;
@@ -2683,7 +2708,7 @@ static int stmmac_init_fs(struct net_device *dev)
 					    dev, &stmmac_dma_cap_fops);
 
 	if (!priv->dbgfs_dma_cap || IS_ERR(priv->dbgfs_dma_cap)) {
-		pr_info("ERROR creating stmmac MMC debugfs file\n");
+		dev_err(priv->device, "ERROR creating stmmac MMC debugfs file\n");
 		debugfs_remove_recursive(priv->dbgfs_dir);
 
 		return -ENOMEM;
@@ -2748,18 +2773,18 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* To use the chained or ring mode */
 	if (chain_mode) {
 		priv->hw->mode = &chain_mode_ops;
-		pr_info(" Chain mode enabled\n");
+		dev_info(priv->device, "Chain mode enabled\n");
 		priv->mode = STMMAC_CHAIN_MODE;
 	} else {
 		priv->hw->mode = &ring_mode_ops;
-		pr_info(" Ring mode enabled\n");
+		dev_info(priv->device, "Ring mode enabled\n");
 		priv->mode = STMMAC_RING_MODE;
 	}
 
 	/* Get the HW capability (new GMAC newer than 3.50a) */
 	priv->hw_cap_support = stmmac_get_hw_features(priv);
 	if (priv->hw_cap_support) {
-		pr_info(" DMA HW capability register supported");
+		dev_info(priv->device, "DMA HW capability register supported\n");
 
 		/* We can override some gmac/dma configuration fields: e.g.
 		 * enh_desc, tx_coe (e.g. that are passed through the
@@ -2781,21 +2806,21 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 			priv->plat->rx_coe = STMMAC_RX_COE_TYPE1;
 
 	} else
-		pr_info(" No HW DMA feature register supported");
+		dev_info(priv->device, "No HW DMA feature register supported\n");
 
 	/* To use alternate (extended) or normal descriptor structures */
 	stmmac_selec_desc_mode(priv);
 
 	if (priv->plat->rx_coe) {
 		priv->hw->rx_csum = priv->plat->rx_coe;
-		pr_info(" RX Checksum Offload Engine supported (type %d)\n",
-			priv->plat->rx_coe);
+		dev_info(priv->device, "RX Checksum Offload Engine supported (type %d)\n",
+			 priv->plat->rx_coe);
 	}
 	if (priv->plat->tx_coe)
-		pr_info(" TX Checksum insertion supported\n");
+		dev_info(priv->device, "TX Checksum insertion supported\n");
 
 	if (priv->plat->pmt) {
-		pr_info(" Wake-Up On Lan supported\n");
+		dev_info(priv->device, "Wake-Up On Lan supported\n");
 		device_set_wakeup_capable(priv->device, 1);
 	}
 
@@ -2920,7 +2945,7 @@ int stmmac_dvr_probe(struct device *device,
 	 */
 	if ((priv->synopsys_id >= DWMAC_CORE_3_50) && (!priv->plat->riwt_off)) {
 		priv->use_riwt = 1;
-		pr_info(" Enable RX Mitigation via HW Watchdog Timer\n");
+		dev_info(priv->device, "Enable RX Mitigation via HW Watchdog Timer\n");
 	}
 
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
@@ -2930,7 +2955,8 @@ int stmmac_dvr_probe(struct device *device,
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
+		dev_err(priv->device, "%s: ERROR %i registering the device\n",
+			__func__, ret);
 		goto error_netdev_register;
 	}
 
@@ -2952,7 +2978,8 @@ int stmmac_dvr_probe(struct device *device,
 		/* MDIO bus Registration */
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
-			pr_debug("%s: MDIO bus (id: %d) registration failed",
+			dev_err(priv->device,
+				"%s: MDIO bus (id: %d) registration failed",
 				 __func__, priv->plat->bus_id);
 			goto error_mdio_register;
 		}
@@ -2985,7 +3012,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	pr_info("%s:\n\tremoving driver", __func__);
+	dev_info(priv->device, "%s: removing driver", __func__);
 
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
-- 
2.4.6
