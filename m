From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 10/13] stmmac: support new GMAC4
Date: Fri, 25 Mar 2016 10:14:17 +0100
Message-ID: <1458897260-14104-11-git-send-email-alexandre.torgue@st.com>
References: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:45913 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752622AbcCYJPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 05:15:10 -0400
In-Reply-To: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the whole GMAC4 support inside the
stmmac d.d. now able to use the new HW and some new features
i.e.: TSO.
It is missing the multi-queue and split Header support at this
stage.
This patch also updates the driver version and the stmmac.txt.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index eabe86b..fc60368 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -169,6 +169,9 @@ struct stmmac_extra_stats {
 	unsigned long mtl_rx_fifo_ctrl_active;
 	unsigned long mac_rx_frame_ctrl_fifo;
 	unsigned long mac_gmii_rx_proto_engine;
+	/* TSO */
+	unsigned long tx_tso_frames;
+	unsigned long tx_tso_nfrags;
 };
 
 /* CSR Frequency Access Defines*/
@@ -545,6 +548,7 @@ void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable);
 void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_mode_ops ring_mode_ops;
 extern const struct stmmac_mode_ops chain_mode_ops;
+extern const struct stmmac_desc_ops dwmac4_desc_ops;
 
 /**
  * stmmac_get_synopsys_id - return the SYINID.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 26fb855..317ce35 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"Oct_2015"
+#define DRV_MODULE_VERSION	"Dec_2015"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
@@ -67,6 +67,7 @@ struct stmmac_priv {
 	spinlock_t tx_lock;
 	bool tx_path_in_lpi_mode;
 	struct timer_list txtimer;
+	bool tso;
 
 	struct dma_desc *dma_rx	____cacheline_aligned_in_smp;
 	struct dma_extended_desc *dma_erx;
@@ -129,6 +130,9 @@ struct stmmac_priv {
 	int irq_wake;
 	spinlock_t ptp_lock;
 	void __iomem *mmcaddr;
+	u32 rx_tail_addr;
+	u32 tx_tail_addr;
+	u32 mss;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbgfs_dir;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index fb2e7fc85..e2b98b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -161,6 +161,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(mtl_rx_fifo_ctrl_active),
 	STMMAC_STAT(mac_rx_frame_ctrl_fifo),
 	STMMAC_STAT(mac_gmii_rx_proto_engine),
+	/* TSO */
+	STMMAC_STAT(tx_tso_frames),
+	STMMAC_STAT(tx_tso_nfrags),
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
@@ -499,7 +502,7 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 	int i, j = 0;
 
 	/* Update the DMA HW counters for dwmac10/100 */
-	if (!priv->plat->has_gmac)
+	if (priv->hw->dma->dma_diagnostic_fr)
 		priv->hw->dma->dma_diagnostic_fr(&dev->stats,
 						 (void *) &priv->xstats,
 						 priv->ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 977487a..cb21884 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -56,6 +56,7 @@
 #include "dwmac1000.h"
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
+#define	TSO_MAX_BUFF_SIZE	(SZ_16K - 1)
 
 /* Module parameters */
 #define TX_TIMEO	5000
@@ -726,13 +727,15 @@ static void stmmac_adjust_link(struct net_device *dev)
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
-				if (likely(priv->plat->has_gmac))
+				if (likely((priv->plat->has_gmac) ||
+					   (priv->plat->has_gmac4)))
 					ctrl &= ~priv->hw->link.port;
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
-				if (priv->plat->has_gmac) {
+				if (likely((priv->plat->has_gmac) ||
+					   (priv->plat->has_gmac4))) {
 					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |= priv->hw->link.speed;
@@ -977,7 +980,10 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 		return -EINVAL;
 	}
 
-	p->des2 = priv->rx_skbuff_dma[i];
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		p->des0 = priv->rx_skbuff_dma[i];
+	else
+		p->des2 = priv->rx_skbuff_dma[i];
 
 	if ((priv->hw->mode->init_desc3) &&
 	    (priv->dma_buf_sz == BUF_SIZE_16KiB))
@@ -1068,7 +1074,16 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 			p = &((priv->dma_etx + i)->basic);
 		else
 			p = priv->dma_tx + i;
-		p->des2 = 0;
+
+		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+			p->des0 = 0;
+			p->des1 = 0;
+			p->des2 = 0;
+			p->des3 = 0;
+		} else {
+			p->des2 = 0;
+		}
+
 		priv->tx_skbuff_dma[i].buf = 0;
 		priv->tx_skbuff_dma[i].map_as_page = false;
 		priv->tx_skbuff_dma[i].len = 0;
@@ -1331,9 +1346,13 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 						 priv->tx_skbuff_dma[entry].len,
 						 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry].buf = 0;
+			priv->tx_skbuff_dma[entry].len = 0;
 			priv->tx_skbuff_dma[entry].map_as_page = false;
 		}
-		priv->hw->mode->clean_desc3(priv, p);
+
+		if (priv->hw->mode->clean_desc3)
+			priv->hw->mode->clean_desc3(priv, p);
+
 		priv->tx_skbuff_dma[entry].last_segment = false;
 		priv->tx_skbuff_dma[entry].is_jumbo = false;
 
@@ -1458,7 +1477,10 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
 			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
-	priv->mmcaddr = priv->ioaddr + MMC_GMAC3_X_OFFSET;
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		priv->mmcaddr = priv->ioaddr + MMC_GMAC4_OFFSET;
+	else
+		priv->mmcaddr = priv->ioaddr + MMC_GMAC3_X_OFFSET;
 
 	dwmac_mmc_intr_all_mask(priv->mmcaddr);
 
@@ -1570,8 +1592,19 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 	priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
 			    aal, priv->dma_tx_phy, priv->dma_rx_phy, atds);
 
-	if ((priv->synopsys_id >= DWMAC_CORE_3_50) &&
-	    (priv->plat->axi && priv->hw->dma->axi))
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		priv->rx_tail_addr = priv->dma_rx_phy +
+			    (DMA_RX_SIZE * sizeof(struct dma_desc));
+		priv->hw->dma->set_rx_tail_ptr(priv->ioaddr, priv->rx_tail_addr,
+					       STMMAC_CHAN0);
+
+		priv->tx_tail_addr = priv->dma_tx_phy +
+			    (DMA_TX_SIZE * sizeof(struct dma_desc));
+		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
+					       STMMAC_CHAN0);
+	}
+
+	if (priv->plat->axi && priv->hw->dma->axi)
 		priv->hw->dma->axi(priv->ioaddr, priv->plat->axi);
 
 	return ret;
@@ -1651,7 +1684,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	}
 
 	/* Enable the MAC Rx/Tx */
-	stmmac_set_mac(priv->ioaddr, true);
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		stmmac_dwmac4_set_mac(priv->ioaddr, true);
+	else
+		stmmac_set_mac(priv->ioaddr, true);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
@@ -1689,6 +1725,18 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (priv->pcs && priv->hw->mac->ctrl_ane)
 		priv->hw->mac->ctrl_ane(priv->hw, 0);
 
+	/*  set TX ring length */
+	if (priv->hw->dma->set_tx_ring_len)
+		priv->hw->dma->set_tx_ring_len(priv->ioaddr,
+					       (DMA_TX_SIZE - 1));
+	/*  set RX ring length */
+	if (priv->hw->dma->set_rx_ring_len)
+		priv->hw->dma->set_rx_ring_len(priv->ioaddr,
+					       (DMA_RX_SIZE - 1));
+	/* Enable TSO */
+	if (priv->tso)
+		priv->hw->dma->enable_tso(priv->ioaddr, 1, STMMAC_CHAN0);
+
 	return 0;
 }
 
@@ -1854,6 +1902,239 @@ static int stmmac_release(struct net_device *dev)
 }
 
 /**
+ *  stmmac_tso_allocator - close entry point of the driver
+ *  @priv: driver private structure
+ *  @des: buffer start address
+ *  @total_len: total length to fill in descriptors
+ *  @last_segmant: condition for the last descriptor
+ *  Description:
+ *  This function fills descriptor and request new descriptors according to
+ *  buffer length to fill
+ */
+static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
+				 int total_len, bool last_segment)
+{
+	struct dma_desc *desc;
+	int tmp_len;
+	u32 buff_size;
+
+	tmp_len = total_len;
+
+	while (tmp_len > 0) {
+		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
+		desc = priv->dma_tx + priv->cur_tx;
+
+		desc->des0 = des + (total_len - tmp_len);
+		buff_size = tmp_len >= TSO_MAX_BUFF_SIZE ?
+			    TSO_MAX_BUFF_SIZE : tmp_len;
+
+		priv->hw->desc->prepare_tso_tx_desc(desc, 0, buff_size,
+			0, 1,
+			(last_segment) && (buff_size < TSO_MAX_BUFF_SIZE),
+			0, 0);
+
+		tmp_len -= TSO_MAX_BUFF_SIZE;
+	}
+}
+
+/**
+ *  stmmac_tso_xmit - Tx entry point of the driver for oversized frames (TSO)
+ *  @skb : the socket buffer
+ *  @dev : device pointer
+ *  Description: this is the transmit function that is called on TSO frames
+ *  (support available on GMAC4 and newer chips).
+ *  Diagram below show the ring programming in case of TSO frames:
+ *
+ *  First Descriptor
+ *   --------
+ *   | DES0 |---> buffer1 = L2/L3/L4 header
+ *   | DES1 |---> TCP Payload (can continue on next descr...)
+ *   | DES2 |---> buffer 1 and 2 len
+ *   | DES3 |---> must set TSE, TCP hdr len-> [22:19]. TCP payload len [17:0]
+ *   --------
+ *	|
+ *     ...
+ *	|
+ *   --------
+ *   | DES0 | --| Split TCP Payload on Buffers 1 and 2
+ *   | DES1 | --|
+ *   | DES2 | --> buffer 1 and 2 len
+ *   | DES3 |
+ *   --------
+ *
+ * mss is fixed when enable tso, so w/o programming the TDES3 ctx field.
+ */
+static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	u32 pay_len, mss;
+	int tmp_pay_len = 0;
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int nfrags = skb_shinfo(skb)->nr_frags;
+	unsigned int first_entry, des;
+	struct dma_desc *desc, *first, *mss_desc = NULL;
+	u8 proto_hdr_len;
+	int i;
+
+	spin_lock(&priv->tx_lock);
+
+	/* Compute header lengths */
+	proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+
+	/* Desc availability based on threshold should be enough safe */
+	if (unlikely(stmmac_tx_avail(priv) <
+		(((skb->len - proto_hdr_len) / TSO_MAX_BUFF_SIZE + 1)))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			/* This is a hard error, log it. */
+			pr_err("%s: Tx Ring full when queue awake\n", __func__);
+		}
+		spin_unlock(&priv->tx_lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	pay_len = skb_headlen(skb) - proto_hdr_len; /* no frags */
+
+	mss = skb_shinfo(skb)->gso_size;
+
+	/* set new MSS value if needed */
+	if (mss != priv->mss) {
+		mss_desc = priv->dma_tx + priv->cur_tx;
+		priv->hw->desc->set_mss(mss_desc, mss);
+		priv->mss = mss;
+		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
+	}
+
+	if (netif_msg_tx_queued(priv)) {
+		pr_info("%s: tcphdrlen %d, hdr_len %d, pay_len %d, mss %d\n",
+			__func__, tcp_hdrlen(skb), proto_hdr_len, pay_len, mss);
+		pr_info("\tskb->len %d, skb->data_len %d\n", skb->len,
+			skb->data_len);
+	}
+
+	first_entry = priv->cur_tx;
+
+	desc = priv->dma_tx + first_entry;
+	first = desc;
+
+	/* first descriptor: fill Headers on Buf1 */
+	des = dma_map_single(priv->device, skb->data, skb_headlen(skb),
+			     DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->device, des))
+		goto dma_map_err;
+
+	priv->tx_skbuff_dma[first_entry].buf = des;
+	priv->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
+	priv->tx_skbuff[first_entry] = skb;
+
+	first->des0 = des;
+
+	/* Fill start of payload in buff2 of first descriptor */
+	if (pay_len)
+		first->des1 =  des + proto_hdr_len;
+
+	/* If needed take extra descriptors to fill the remaining payload */
+	tmp_pay_len = pay_len - TSO_MAX_BUFF_SIZE;
+
+	stmmac_tso_allocator(priv, des, tmp_pay_len, (nfrags == 0));
+
+	/* Prepare fragments */
+	for (i = 0; i < nfrags; i++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		des = skb_frag_dma_map(priv->device, frag, 0,
+				       skb_frag_size(frag),
+				       DMA_TO_DEVICE);
+
+		stmmac_tso_allocator(priv, des, skb_frag_size(frag),
+				     (i == nfrags - 1));
+
+		priv->tx_skbuff_dma[priv->cur_tx].buf = des;
+		priv->tx_skbuff_dma[priv->cur_tx].len = skb_frag_size(frag);
+		priv->tx_skbuff[priv->cur_tx] = NULL;
+		priv->tx_skbuff_dma[priv->cur_tx].map_as_page = true;
+	}
+
+	priv->tx_skbuff_dma[priv->cur_tx].last_segment = true;
+
+	priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
+
+	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
+		if (netif_msg_hw(priv))
+			pr_debug("%s: stop transmitted packets\n", __func__);
+		netif_stop_queue(dev);
+	}
+
+	dev->stats.tx_bytes += skb->len;
+	priv->xstats.tx_tso_frames++;
+	priv->xstats.tx_tso_nfrags += nfrags;
+
+	/* Manage tx mitigation */
+	priv->tx_count_frames += nfrags + 1;
+	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
+	} else {
+		priv->tx_count_frames = 0;
+		priv->hw->desc->set_tx_ic(desc);
+		priv->xstats.tx_set_ic_bit++;
+	}
+
+	if (!priv->hwts_tx_en)
+		skb_tx_timestamp(skb);
+
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		     priv->hwts_tx_en)) {
+		/* declare that device is doing timestamping */
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		priv->hw->desc->enable_tx_timestamp(first);
+	}
+
+	/* Complete the first descriptor before granting the DMA */
+	priv->hw->desc->prepare_tso_tx_desc(first, 1,
+			proto_hdr_len,
+			pay_len,
+			1, priv->tx_skbuff_dma[first_entry].last_segment,
+			tcp_hdrlen(skb) / 4, (skb->len - proto_hdr_len));
+
+	/* If context desc is used to change MSS */
+	if (mss_desc)
+		priv->hw->desc->set_tx_owner(mss_desc);
+
+	/* The own bit must be the latest setting done when prepare the
+	 * descriptor and then barrier is needed to make sure that
+	 * all is coherent before granting the DMA engine.
+	 */
+	smp_wmb();
+
+	if (netif_msg_pktdata(priv)) {
+		pr_info("%s: curr=%d dirty=%d f=%d, e=%d, f_p=%p, nfrags %d\n",
+			__func__, priv->cur_tx, priv->dirty_tx, first_entry,
+			priv->cur_tx, first, nfrags);
+
+		priv->hw->desc->display_ring((void *)priv->dma_tx, DMA_TX_SIZE,
+					     0);
+
+		pr_info(">>> frame to be transmitted: ");
+		print_pkt(skb->data, skb_headlen(skb));
+	}
+
+	netdev_sent_queue(dev, skb->len);
+
+	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
+				       STMMAC_CHAN0);
+
+	spin_unlock(&priv->tx_lock);
+	return NETDEV_TX_OK;
+
+dma_map_err:
+	spin_unlock(&priv->tx_lock);
+	dev_err(priv->device, "Tx dma map failed\n");
+	dev_kfree_skb(skb);
+	priv->dev->stats.tx_dropped++;
+	return NETDEV_TX_OK;
+}
+
+/**
  *  stmmac_xmit - Tx entry point of the driver
  *  @skb : the socket buffer
  *  @dev : device pointer
@@ -1870,6 +2151,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int entry, first_entry;
 	struct dma_desc *desc, *first;
 	unsigned int enh_desc;
+	unsigned int des;
+
+	/* Manage oversized TCP frames for GMAC4 device */
+	if (skb_is_gso(skb) && priv->tso) {
+		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+			return stmmac_tso_xmit(skb, dev);
+	}
 
 	spin_lock(&priv->tx_lock);
 
@@ -1905,7 +2193,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (enh_desc)
 		is_jumbo = priv->hw->mode->is_jumbo_frm(skb->len, enh_desc);
 
-	if (unlikely(is_jumbo)) {
+	if (unlikely(is_jumbo) && likely(priv->synopsys_id <
+					 DWMAC_CORE_4_00)) {
 		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
 		if (unlikely(entry < 0))
 			goto dma_map_err;
@@ -1923,13 +2212,21 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		else
 			desc = priv->dma_tx + entry;
 
-		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
-					      DMA_TO_DEVICE);
-		if (dma_mapping_error(priv->device, desc->des2))
+		des = skb_frag_dma_map(priv->device, frag, 0, len,
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, des))
 			goto dma_map_err; /* should reuse desc w/o issues */
 
 		priv->tx_skbuff[entry] = NULL;
-		priv->tx_skbuff_dma[entry].buf = desc->des2;
+
+		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00)) {
+			desc->des0 = des;
+			priv->tx_skbuff_dma[entry].buf = desc->des0;
+		} else {
+			desc->des2 = des;
+			priv->tx_skbuff_dma[entry].buf = desc->des2;
+		}
+
 		priv->tx_skbuff_dma[entry].map_as_page = true;
 		priv->tx_skbuff_dma[entry].len = len;
 		priv->tx_skbuff_dma[entry].last_segment = last_segment;
@@ -1994,12 +2291,19 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(!is_jumbo)) {
 		bool last_segment = (nfrags == 0);
 
-		first->des2 = dma_map_single(priv->device, skb->data,
-					     nopaged_len, DMA_TO_DEVICE);
-		if (dma_mapping_error(priv->device, first->des2))
+		des = dma_map_single(priv->device, skb->data,
+				     nopaged_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, des))
 			goto dma_map_err;
 
-		priv->tx_skbuff_dma[first_entry].buf = first->des2;
+		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00)) {
+			first->des0 = des;
+			priv->tx_skbuff_dma[first_entry].buf = first->des0;
+		} else {
+			first->des2 = des;
+			priv->tx_skbuff_dma[first_entry].buf = first->des2;
+		}
+
 		priv->tx_skbuff_dma[first_entry].len = nopaged_len;
 		priv->tx_skbuff_dma[first_entry].last_segment = last_segment;
 
@@ -2023,7 +2327,12 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	netdev_sent_queue(dev, skb->len);
-	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
+
+	if (priv->synopsys_id < DWMAC_CORE_4_00)
+		priv->hw->dma->enable_dma_transmission(priv->ioaddr);
+	else
+		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
+					       STMMAC_CHAN0);
 
 	spin_unlock(&priv->tx_lock);
 	return NETDEV_TX_OK;
@@ -2105,9 +2414,15 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 				dev_kfree_skb(skb);
 				break;
 			}
-			p->des2 = priv->rx_skbuff_dma[entry];
 
-			priv->hw->mode->refill_desc3(priv, p);
+			if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00)) {
+				p->des0 = priv->rx_skbuff_dma[entry];
+				p->des1 = 0;
+			} else {
+				p->des2 = priv->rx_skbuff_dma[entry];
+			}
+			if (priv->hw->mode->refill_desc3)
+				priv->hw->mode->refill_desc3(priv, p);
 
 			if (priv->rx_zeroc_thresh > 0)
 				priv->rx_zeroc_thresh--;
@@ -2115,9 +2430,13 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			if (netif_msg_rx_status(priv))
 				pr_debug("\trefill entry #%d\n", entry);
 		}
-
 		wmb();
-		priv->hw->desc->set_rx_owner(p);
+
+		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
+			priv->hw->desc->init_rx_desc(p, priv->use_riwt, 0, 0);
+		else
+			priv->hw->desc->set_rx_owner(p);
+
 		wmb();
 
 		entry = STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
@@ -2198,11 +2517,23 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		} else {
 			struct sk_buff *skb;
 			int frame_len;
+			unsigned int des;
+
+			if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
+				des = p->des0;
+			else
+				des = p->des2;
 
 			frame_len = priv->hw->desc->get_rx_frame_len(p, coe);
 
-			/*  check if frame_len fits the preallocated memory */
+			/*  If frame length is greather than skb buffer size
+			 *  (preallocated during init) then the packet is
+			 *  ignored
+			 */
 			if (frame_len > priv->dma_buf_sz) {
+				pr_err("%s: len %d larger than size (%d)\n",
+				       priv->dev->name, frame_len,
+				       priv->dma_buf_sz);
 				priv->dev->stats.rx_length_errors++;
 				break;
 			}
@@ -2215,14 +2546,19 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 			if (netif_msg_rx_status(priv)) {
 				pr_debug("\tdesc: %p [entry %d] buff=0x%x\n",
-					 p, entry, p->des2);
+					p, entry, des);
 				if (frame_len > ETH_FRAME_LEN)
 					pr_debug("\tframe size %d, COE: %d\n",
 						 frame_len, status);
 			}
 
-			if (unlikely((frame_len < priv->rx_copybreak) ||
-				     stmmac_rx_threshold_count(priv))) {
+			/* The zero-copy is always used for all the sizes
+			 * in case of GMAC4 because it needs
+			 * to refill the used descriptors, always.
+			 */
+			if (unlikely(!priv->plat->has_gmac4 &&
+				     ((frame_len < priv->rx_copybreak) ||
+				     stmmac_rx_threshold_count(priv)))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -2374,7 +2710,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 		return -EBUSY;
 	}
 
-	if (priv->plat->enh_desc)
+	if ((priv->plat->enh_desc) || (priv->synopsys_id >= DWMAC_CORE_4_00))
 		max_mtu = JUMBO_LEN;
 	else
 		max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
@@ -2388,6 +2724,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 	}
 
 	dev->mtu = new_mtu;
+
 	netdev_update_features(dev);
 
 	return 0;
@@ -2412,6 +2749,14 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	if (priv->plat->bugged_jumbo && (dev->mtu > ETH_DATA_LEN))
 		features &= ~NETIF_F_CSUM_MASK;
 
+	/* Disable tso if asked by ethtool */
+	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
+		if (features & NETIF_F_TSO)
+			priv->tso = true;
+		else
+			priv->tso = false;
+	}
+
 	return features;
 }
 
@@ -2458,7 +2803,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	}
 
 	/* To handle GMAC own interrupts */
-	if (priv->plat->has_gmac) {
+	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
 		if (unlikely(status)) {
@@ -2467,6 +2812,10 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 				priv->tx_path_in_lpi_mode = true;
 			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
+			if (status & CORE_IRQ_MTL_RX_OVERFLOW)
+				priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
+							priv->rx_tail_addr,
+							STMMAC_CHAN0);
 		}
 	}
 
@@ -2539,15 +2888,14 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 			x = *(u64 *) ep;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
-				   (unsigned int)x, (unsigned int)(x >> 32),
+				   ep->basic.des0, ep->basic.des1,
 				   ep->basic.des2, ep->basic.des3);
 			ep++;
 		} else {
 			x = *(u64 *) p;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
-				   (unsigned int)x, (unsigned int)(x >> 32),
-				   p->des2, p->des3);
+				   p->des0, p->des1, p->des2, p->des3);
 			p++;
 		}
 		seq_printf(seq, "\n");
@@ -2630,10 +2978,15 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 	seq_printf(seq, "\tAV features: %s\n", (priv->dma_cap.av) ? "Y" : "N");
 	seq_printf(seq, "\tChecksum Offload in TX: %s\n",
 		   (priv->dma_cap.tx_coe) ? "Y" : "N");
-	seq_printf(seq, "\tIP Checksum Offload (type1) in RX: %s\n",
-		   (priv->dma_cap.rx_coe_type1) ? "Y" : "N");
-	seq_printf(seq, "\tIP Checksum Offload (type2) in RX: %s\n",
-		   (priv->dma_cap.rx_coe_type2) ? "Y" : "N");
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		seq_printf(seq, "\tIP Checksum Offload in RX: %s\n",
+			   (priv->dma_cap.rx_coe) ? "Y" : "N");
+	} else {
+		seq_printf(seq, "\tIP Checksum Offload (type1) in RX: %s\n",
+			   (priv->dma_cap.rx_coe_type1) ? "Y" : "N");
+		seq_printf(seq, "\tIP Checksum Offload (type2) in RX: %s\n",
+			   (priv->dma_cap.rx_coe_type2) ? "Y" : "N");
+	}
 	seq_printf(seq, "\tRXFIFO > 2048bytes: %s\n",
 		   (priv->dma_cap.rxfifo_over_2048) ? "Y" : "N");
 	seq_printf(seq, "\tNumber of Additional RX channel: %d\n",
@@ -2744,6 +3097,12 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 				      priv->plat->multicast_filter_bins,
 				      priv->plat->unicast_filter_entries,
 				      &priv->synopsys_id);
+	} else if (priv->plat->has_gmac4) {
+		priv->dev->priv_flags |= IFF_UNICAST_FLT;
+		mac = dwmac4_setup(priv->ioaddr,
+				   priv->plat->multicast_filter_bins,
+				   priv->plat->unicast_filter_entries,
+				   &priv->synopsys_id);
 	} else {
 		mac = dwmac100_setup(priv->ioaddr, &priv->synopsys_id);
 	}
@@ -2753,14 +3112,18 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	priv->hw = mac;
 
 	/* To use the chained or ring mode */
-	if (chain_mode) {
-		priv->hw->mode = &chain_mode_ops;
-		pr_info(" Chain mode enabled\n");
-		priv->mode = STMMAC_CHAIN_MODE;
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		priv->hw->mode = &dwmac4_ring_mode_ops;
 	} else {
-		priv->hw->mode = &ring_mode_ops;
-		pr_info(" Ring mode enabled\n");
-		priv->mode = STMMAC_RING_MODE;
+		if (chain_mode) {
+			priv->hw->mode = &chain_mode_ops;
+			pr_info(" Chain mode enabled\n");
+			priv->mode = STMMAC_CHAIN_MODE;
+		} else {
+			priv->hw->mode = &ring_mode_ops;
+			pr_info(" Ring mode enabled\n");
+			priv->mode = STMMAC_RING_MODE;
+		}
 	}
 
 	/* Get the HW capability (new GMAC newer than 3.50a) */
@@ -2776,11 +3139,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		priv->plat->enh_desc = priv->dma_cap.enh_desc;
 		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
 
-		/* TXCOE doesn't work in thresh DMA mode */
-		if (priv->plat->force_thresh_dma_mode)
-			priv->plat->tx_coe = 0;
-		else
-			priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		/* In case of GMAC4 rx_coe is from HW cap register. */
+		priv->plat->rx_coe = priv->dma_cap.rx_coe;
 
 		if (priv->dma_cap.rx_coe_type2)
 			priv->plat->rx_coe = STMMAC_RX_COE_TYPE2;
@@ -2790,13 +3151,17 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
 
-	/* To use alternate (extended) or normal descriptor structures */
-	stmmac_selec_desc_mode(priv);
+	/* To use alternate (extended), normal or GMAC4 descriptor structures */
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		priv->hw->desc = &dwmac4_desc_ops;
+	else
+		stmmac_selec_desc_mode(priv);
 
 	if (priv->plat->rx_coe) {
 		priv->hw->rx_csum = priv->plat->rx_coe;
-		pr_info(" RX Checksum Offload Engine supported (type %d)\n",
-			priv->plat->rx_coe);
+		pr_info(" RX Checksum Offload Engine supported\n");
+		if (priv->synopsys_id < DWMAC_CORE_4_00)
+			pr_info("\tCOE Type %d\n", priv->hw->rx_csum);
 	}
 	if (priv->plat->tx_coe)
 		pr_info(" TX Checksum insertion supported\n");
@@ -2806,6 +3171,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		device_set_wakeup_capable(priv->device, 1);
 	}
 
+	if (priv->dma_cap.tsoen)
+		pr_info(" TSO supported\n");
+
 	return 0;
 }
 
@@ -2909,6 +3277,12 @@ int stmmac_dvr_probe(struct device *device,
 
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			    NETIF_F_RXCSUM;
+
+	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
+		ndev->hw_features |= NETIF_F_TSO;
+		priv->tso = true;
+		pr_info(" TSO feature enabled\n");
+	}
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
@@ -3103,6 +3477,11 @@ int stmmac_resume(struct net_device *ndev)
 	priv->dirty_rx = 0;
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
+	/* reset private mss value to force mss context settings at
+	 * next tso xmit (only used for gmac4).
+	 */
+	priv->mss = 0;
+
 	stmmac_clear_descriptors(priv);
 
 	stmmac_hw_setup(ndev, false);
-- 
1.9.1
