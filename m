From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net.git) 2/3] stmmac: fix PTP support for GMAC4
Date: Mon, 14 Nov 2016 09:27:29 +0100
Message-ID: <1479112050-14042-3-git-send-email-peppe.cavallaro@st.com>
References: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <rayagond@vayavyalabs.com>,
        <richardcochran@gmail.com>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <seraphin.bonnaffe@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to bad management of the descriptors, when use ptp4l,
kernel panics as shown below:
-----------------------------------------------------------
 Unable to handle kernel NULL pointer dereference at virtual
 address 000001ac
 ...
 Internal error: Oops: 17 [#1] SMP ARM
 ...
 Hardware name: STi SoC with Flattened Device Tree
 task: c0c05e80 task.stack: c0c00000
 PC is at dwmac4_wrback_get_tx_timestamp_status+0x0/0xc
 LR is at stmmac_tx_clean+0x2f8/0x4d4
-----------------------------------------------------------

In case of GMAC4 the extended descriptor pointers were
used for getting the timestamp. These are NULL for this HW,
and the normal ones must be used.

The PTP also had problems on this chip due to the bad
register management and issues on the algo adopted to
setup the PTP and getting the timestamp values from the
descriptors.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Acked-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 68 ++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h |  4 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  | 43 ++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 97 +++++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  9 +-
 7 files changed, 154 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index d3292c4..6fc214c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -482,11 +482,12 @@ struct stmmac_ops {
 /* PTP and HW Timer helpers */
 struct stmmac_hwtimestamp {
 	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
-	u32 (*config_sub_second_increment) (void __iomem *ioaddr, u32 clk_rate);
+	u32 (*config_sub_second_increment)(void __iomem *ioaddr, u32 ptp_clock,
+					   int gmac4);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend) (void __iomem *ioaddr, u32 addend);
 	int (*adjust_systime) (void __iomem *ioaddr, u32 sec, u32 nsec,
-			       int add_sub);
+			       int add_sub, int gmac4);
 	 u64(*get_systime) (void __iomem *ioaddr);
 };
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index a1b17cd..2ef2f0c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -204,14 +204,18 @@ static void dwmac4_rd_enable_tx_timestamp(struct dma_desc *p)
 
 static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
 {
-	return (p->des3 & TDES3_TIMESTAMP_STATUS)
-		>> TDES3_TIMESTAMP_STATUS_SHIFT;
+	/* Context type from W/B descriptor must be zero */
+	if (p->des3 & TDES3_CONTEXT_TYPE)
+		return -EINVAL;
+
+	/* Tx Timestamp Status is 1 so des0 and des1'll have valid values */
+	if (p->des3 & TDES3_TIMESTAMP_STATUS)
+		return 0;
+
+	return 1;
 }
 
-/*  NOTE: For RX CTX bit has to be checked before
- *  HAVE a specific function for TX and another one for RX
- */
-static u64 dwmac4_wrback_get_timestamp(void *desc, u32 ats)
+static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
 {
 	struct dma_desc *p = (struct dma_desc *)desc;
 	u64 ns;
@@ -223,12 +227,54 @@ static u64 dwmac4_wrback_get_timestamp(void *desc, u32 ats)
 	return ns;
 }
 
-static int dwmac4_context_get_rx_timestamp_status(void *desc, u32 ats)
+static int dwmac4_rx_check_timestamp(void *desc)
+{
+	struct dma_desc *p = (struct dma_desc *)desc;
+	u32 own, ctxt;
+	int ret = 1;
+
+	own = p->des3 & RDES3_OWN;
+	ctxt = ((p->des3 & RDES3_CONTEXT_DESCRIPTOR)
+		>> RDES3_CONTEXT_DESCRIPTOR_SHIFT);
+
+	if (likely(!own && ctxt)) {
+		if ((p->des0 == 0xffffffff) && (p->des1 == 0xffffffff))
+			/* Corrupted value */
+			ret = -EINVAL;
+		else
+			/* A valid Timestamp is ready to be read */
+			ret = 0;
+	}
+
+	/* Timestamp not ready */
+	return ret;
+}
+
+static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 {
 	struct dma_desc *p = (struct dma_desc *)desc;
+	int ret = -EINVAL;
+
+	/* Get the status from normal w/b descriptor */
+	if (likely(p->des3 & TDES3_RS1V)) {
+		if (likely(p->des1 & RDES1_TIMESTAMP_AVAILABLE)) {
+			int i = 0;
+
+			/* Check if timestamp is OK from context descriptor */
+			do {
+				ret = dwmac4_rx_check_timestamp(desc);
+				if (ret < 0)
+					goto exit;
+				i++;
 
-	return (p->des1 & RDES1_TIMESTAMP_AVAILABLE)
-		>> RDES1_TIMESTAMP_AVAILABLE_SHIFT;
+			} while ((ret == 1) || (i < 10));
+
+			if (i == 10)
+				ret = -EBUSY;
+		}
+	}
+exit:
+	return ret;
 }
 
 static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
@@ -373,8 +419,8 @@ const struct stmmac_desc_ops dwmac4_desc_ops = {
 	.get_rx_frame_len = dwmac4_wrback_get_rx_frame_len,
 	.enable_tx_timestamp = dwmac4_rd_enable_tx_timestamp,
 	.get_tx_timestamp_status = dwmac4_wrback_get_tx_timestamp_status,
-	.get_timestamp = dwmac4_wrback_get_timestamp,
-	.get_rx_timestamp_status = dwmac4_context_get_rx_timestamp_status,
+	.get_rx_timestamp_status = dwmac4_wrback_get_rx_timestamp_status,
+	.get_timestamp = dwmac4_get_timestamp,
 	.set_tx_ic = dwmac4_rd_set_tx_ic,
 	.prepare_tx_desc = dwmac4_rd_prepare_tx_desc,
 	.prepare_tso_tx_desc = dwmac4_rd_prepare_tso_tx_desc,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
index 0902a2e..9736c50 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
@@ -59,10 +59,13 @@
 #define TDES3_CTXT_TCMSSV		BIT(26)
 
 /* TDES3 Common */
+#define	TDES3_RS1V			BIT(26)
+#define	TDES3_RS1V_SHIFT		26
 #define TDES3_LAST_DESCRIPTOR		BIT(28)
 #define TDES3_LAST_DESCRIPTOR_SHIFT	28
 #define TDES3_FIRST_DESCRIPTOR		BIT(29)
 #define TDES3_CONTEXT_TYPE		BIT(30)
+#define	TDES3_CONTEXT_TYPE_SHIFT	30
 
 /* TDS3 use for both format (read and write back) */
 #define TDES3_OWN			BIT(31)
@@ -117,6 +120,7 @@
 #define RDES3_LAST_DESCRIPTOR		BIT(28)
 #define RDES3_FIRST_DESCRIPTOR		BIT(29)
 #define RDES3_CONTEXT_DESCRIPTOR	BIT(30)
+#define RDES3_CONTEXT_DESCRIPTOR_SHIFT	30
 
 /* RDES3 (read format) */
 #define RDES3_BUFFER1_VALID_ADDR	BIT(24)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b15fc55..4d2a759 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -129,6 +129,7 @@ struct stmmac_priv {
 	int irq_wake;
 	spinlock_t ptp_lock;
 	void __iomem *mmcaddr;
+	void __iomem *ptpaddr;
 	u32 rx_tail_addr;
 	u32 tx_tail_addr;
 	u32 mss;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index a77f689..10d6059 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -34,21 +34,29 @@ static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
 }
 
 static u32 stmmac_config_sub_second_increment(void __iomem *ioaddr,
-					      u32 ptp_clock)
+					      u32 ptp_clock, int gmac4)
 {
 	u32 value = readl(ioaddr + PTP_TCR);
 	unsigned long data;
 
-	/* Convert the ptp_clock to nano second
-	 * formula = (2/ptp_clock) * 1000000000
-	 * where, ptp_clock = 50MHz.
+	/* For GMAC3.x, 4.x versions, convert the ptp_clock to nano second
+	 *	formula = (1/ptp_clock) * 1000000000
+	 * where ptp_clock is 50MHz if fine method is used to update system
 	 */
-	data = (2000000000ULL / ptp_clock);
+	if (value & PTP_TCR_TSCFUPDT)
+		data = (1000000000ULL / 50000000);
+	else
+		data = (1000000000ULL / ptp_clock);
 
 	/* 0.465ns accuracy */
 	if (!(value & PTP_TCR_TSCTRLSSR))
 		data = (data * 1000) / 465;
 
+	data &= PTP_SSIR_SSINC_MASK;
+
+	if (gmac4)
+		data = data << GMAC4_PTP_SSIR_SSINC_SHIFT;
+
 	writel(data, ioaddr + PTP_SSIR);
 
 	return data;
@@ -104,14 +112,30 @@ static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
 }
 
 static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
-				 int add_sub)
+				 int add_sub, int gmac4)
 {
 	u32 value;
 	int limit;
 
+	if (add_sub) {
+		/* If the new sec value needs to be subtracted with
+		 * the system time, then MAC_STSUR reg should be
+		 * programmed with (2^32 – <new_sec_value>)
+		 */
+		if (gmac4)
+			sec = (100000000ULL - sec);
+
+		value = readl(ioaddr + PTP_TCR);
+		if (value & PTP_TCR_TSCTRLSSR)
+			nsec = (PTP_DIGITAL_ROLLOVER_MODE - nsec);
+		else
+			nsec = (PTP_BINARY_ROLLOVER_MODE - nsec);
+	}
+
 	writel(sec, ioaddr + PTP_STSUR);
-	writel(((add_sub << PTP_STNSUR_ADDSUB_SHIFT) | nsec),
-		ioaddr + PTP_STNSUR);
+	value = (add_sub << PTP_STNSUR_ADDSUB_SHIFT) | nsec;
+	writel(value, ioaddr + PTP_STNSUR);
+
 	/* issue command to initialize the system time value */
 	value = readl(ioaddr + PTP_TCR);
 	value |= PTP_TCR_TSUPDT;
@@ -134,8 +158,9 @@ static u64 stmmac_get_systime(void __iomem *ioaddr)
 {
 	u64 ns;
 
+	/* Get the TSSS value */
 	ns = readl(ioaddr + PTP_STNSR);
-	/* convert sec time value to nanosecond */
+	/* Get the TSS and convert sec time value to nanosecond */
 	ns += readl(ioaddr + PTP_STSR) * 1000000000ULL;
 
 	return ns;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 48e71fa..2e228d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -340,18 +340,17 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 
 /* stmmac_get_tx_hwtstamp - get HW TX timestamps
  * @priv: driver private structure
- * @entry : descriptor index to be used.
+ * @p : descriptor pointer
  * @skb : the socket buffer
  * Description :
  * This function will read timestamp from the descriptor & pass it to stack.
  * and also perform some sanity checks.
  */
 static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
-				   unsigned int entry, struct sk_buff *skb)
+				   struct dma_desc *p, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps shhwtstamp;
 	u64 ns;
-	void *desc = NULL;
 
 	if (!priv->hwts_tx_en)
 		return;
@@ -360,58 +359,55 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 	if (likely(!skb || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
 		return;
 
-	if (priv->adv_ts)
-		desc = (priv->dma_etx + entry);
-	else
-		desc = (priv->dma_tx + entry);
-
 	/* check tx tstamp status */
-	if (!priv->hw->desc->get_tx_timestamp_status((struct dma_desc *)desc))
-		return;
+	if (!priv->hw->desc->get_tx_timestamp_status(p)) {
+		/* get the valid tstamp */
+		ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
-	/* get the valid tstamp */
-	ns = priv->hw->desc->get_timestamp(desc, priv->adv_ts);
+		memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
+		shhwtstamp.hwtstamp = ns_to_ktime(ns);
 
-	memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
-	shhwtstamp.hwtstamp = ns_to_ktime(ns);
-	/* pass tstamp to stack */
-	skb_tstamp_tx(skb, &shhwtstamp);
+		netdev_info(priv->dev, "get valid TX hw timestamp %llu\n", ns);
+		/* pass tstamp to stack */
+		skb_tstamp_tx(skb, &shhwtstamp);
+	}
 
 	return;
 }
 
 /* stmmac_get_rx_hwtstamp - get HW RX timestamps
  * @priv: driver private structure
- * @entry : descriptor index to be used.
+ * @p : descriptor pointer
+ * @np : next descriptor pointer
  * @skb : the socket buffer
  * Description :
  * This function will read received packet's timestamp from the descriptor
  * and pass it to stack. It also perform some sanity checks.
  */
-static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv,
-				   unsigned int entry, struct sk_buff *skb)
+static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
+				   struct dma_desc *np, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamp = NULL;
 	u64 ns;
-	void *desc = NULL;
 
 	if (!priv->hwts_rx_en)
 		return;
 
-	if (priv->adv_ts)
-		desc = (priv->dma_erx + entry);
-	else
-		desc = (priv->dma_rx + entry);
-
-	/* exit if rx tstamp is not valid */
-	if (!priv->hw->desc->get_rx_timestamp_status(desc, priv->adv_ts))
-		return;
+	/* Check if timestamp is available */
+	if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
+		/* For GMAC4, the valid timestamp is from CTX next desc. */
+		if (priv->plat->has_gmac4)
+			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
+		else
+			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
 
-	/* get valid tstamp */
-	ns = priv->hw->desc->get_timestamp(desc, priv->adv_ts);
-	shhwtstamp = skb_hwtstamps(skb);
-	memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
-	shhwtstamp->hwtstamp = ns_to_ktime(ns);
+		netdev_info(priv->dev, "get valid RX hw timestamp %llu\n", ns);
+		shhwtstamp = skb_hwtstamps(skb);
+		memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
+		shhwtstamp->hwtstamp = ns_to_ktime(ns);
+	} else  {
+		netdev_err(priv->dev, "cannot get RX hw timestamp\n");
+	}
 }
 
 /**
@@ -598,17 +594,18 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	priv->hwts_tx_en = config.tx_type == HWTSTAMP_TX_ON;
 
 	if (!priv->hwts_tx_en && !priv->hwts_rx_en)
-		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
+		priv->hw->ptp->config_hw_tstamping(priv->ptpaddr, 0);
 	else {
 		value = (PTP_TCR_TSENA | PTP_TCR_TSCFUPDT | PTP_TCR_TSCTRLSSR |
 			 tstamp_all | ptp_v2 | ptp_over_ethernet |
 			 ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
 			 ts_master_en | snap_type_sel);
-		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
+		priv->hw->ptp->config_hw_tstamping(priv->ptpaddr, value);
 
 		/* program Sub Second Increment reg */
 		sec_inc = priv->hw->ptp->config_sub_second_increment(
-			priv->ioaddr, priv->clk_ptp_rate);
+			priv->ptpaddr, priv->clk_ptp_rate,
+			priv->plat->has_gmac4);
 		temp = div_u64(1000000000ULL, sec_inc);
 
 		/* calculate default added value:
@@ -618,14 +615,14 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 */
 		temp = (u64)(temp << 32);
 		priv->default_addend = div_u64(temp, priv->clk_ptp_rate);
-		priv->hw->ptp->config_addend(priv->ioaddr,
+		priv->hw->ptp->config_addend(priv->ptpaddr,
 					     priv->default_addend);
 
 		/* initialize system time */
 		ktime_get_real_ts64(&now);
 
 		/* lower 32 bits of tv_sec are safe until y2106 */
-		priv->hw->ptp->init_systime(priv->ioaddr, (u32)now.tv_sec,
+		priv->hw->ptp->init_systime(priv->ptpaddr, (u32)now.tv_sec,
 					    now.tv_nsec);
 	}
 
@@ -1333,7 +1330,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
 			}
-			stmmac_get_tx_hwtstamp(priv, entry, skb);
+			stmmac_get_tx_hwtstamp(priv, p, skb);
 		}
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
@@ -1479,10 +1476,13 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
 			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
-	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		priv->ptpaddr = priv->ioaddr + PTP_GMAC4_OFFSET;
 		priv->mmcaddr = priv->ioaddr + MMC_GMAC4_OFFSET;
-	else
+	} else {
+		priv->ptpaddr = priv->ioaddr + PTP_GMAC3_X_OFFSET;
 		priv->mmcaddr = priv->ioaddr + MMC_GMAC3_X_OFFSET;
+	}
 
 	dwmac_mmc_intr_all_mask(priv->mmcaddr);
 
@@ -2477,7 +2477,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	if (netif_msg_rx_status(priv)) {
 		void *rx_head;
 
-		pr_debug("%s: descriptor ring:\n", __func__);
+		pr_info(">>>>>> %s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
 			rx_head = (void *)priv->dma_erx;
 		else
@@ -2488,6 +2488,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	while (count < limit) {
 		int status;
 		struct dma_desc *p;
+		struct dma_desc *np;
 
 		if (priv->extend_desc)
 			p = (struct dma_desc *)(priv->dma_erx + entry);
@@ -2507,9 +2508,11 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		next_entry = priv->cur_rx;
 
 		if (priv->extend_desc)
-			prefetch(priv->dma_erx + next_entry);
+			np = (struct dma_desc *)(priv->dma_erx + next_entry);
 		else
-			prefetch(priv->dma_rx + next_entry);
+			np = priv->dma_rx + next_entry;
+
+		prefetch(np);
 
 		if ((priv->extend_desc) && (priv->hw->desc->rx_extended_status))
 			priv->hw->desc->rx_extended_status(&priv->dev->stats,
@@ -2561,7 +2564,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				frame_len -= ETH_FCS_LEN;
 
 			if (netif_msg_rx_status(priv)) {
-				pr_debug("\tdesc: %p [entry %d] buff=0x%x\n",
+				pr_info("\tdesc: %p [entry %d] buff=0x%x\n",
 					p, entry, des);
 				if (frame_len > ETH_FRAME_LEN)
 					pr_debug("\tframe size %d, COE: %d\n",
@@ -2618,13 +2621,13 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 						 DMA_FROM_DEVICE);
 			}
 
-			stmmac_get_rx_hwtstamp(priv, entry, skb);
-
 			if (netif_msg_pktdata(priv)) {
 				pr_debug("frame received (%dbytes)", frame_len);
 				print_pkt(skb->data, frame_len);
 			}
 
+			stmmac_get_rx_hwtstamp(priv, p, np, skb);
+
 			stmmac_rx_vlan(priv->dev, skb);
 
 			skb->protocol = eth_type_trans(skb, priv->dev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 1477471..3eb281d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -54,7 +54,7 @@ static int stmmac_adjust_freq(struct ptp_clock_info *ptp, s32 ppb)
 
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
-	priv->hw->ptp->config_addend(priv->ioaddr, addend);
+	priv->hw->ptp->config_addend(priv->ptpaddr, addend);
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
@@ -89,7 +89,8 @@ static int stmmac_adjust_time(struct ptp_clock_info *ptp, s64 delta)
 
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
-	priv->hw->ptp->adjust_systime(priv->ioaddr, sec, nsec, neg_adj);
+	priv->hw->ptp->adjust_systime(priv->ptpaddr, sec, nsec, neg_adj,
+				      priv->plat->has_gmac4);
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
@@ -114,7 +115,7 @@ static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec64 *ts)
 
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
-	ns = priv->hw->ptp->get_systime(priv->ioaddr);
+	ns = priv->hw->ptp->get_systime(priv->ptpaddr);
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
@@ -141,7 +142,7 @@ static int stmmac_set_time(struct ptp_clock_info *ptp,
 
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
-	priv->hw->ptp->init_systime(priv->ioaddr, ts->tv_sec, ts->tv_nsec);
+	priv->hw->ptp->init_systime(priv->ptpaddr, ts->tv_sec, ts->tv_nsec);
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
-- 
2.7.4
