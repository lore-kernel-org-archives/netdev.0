From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 5/9] stmmac: add IEEE 1588-2008 PTP V2 support
Date: Thu,  7 Mar 2013 11:50:15 +0100
Message-ID: <1362653419-1047-6-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56594 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756704Ab3CGLrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:07 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch enhances the stmmac driver to support IEEE 1588-2008 PTP v2
timestamping.
Basic TimeStamps (IEEE 1588-2002 Precision Time Protocol) is selected
by using the STMMAC_USE_HWSTAMP option and at run-time, thanks to
the HW capability register, we verify if the support can be used.
This "basic" TimeStamp support can be used on chips that have the
normal descriptor structures.
To support the IEEE 1588-2008 Precision Time Protocol (Advanced
TimeStamping) the HW has to be the  Extended descriptors (DES4-5-6-7)
so this is firtly solved by Kconfig and at runtime all is verified
according to the HW capability register.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   24 ++-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   26 ++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   10 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   39 +++--
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   10 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_hwstamp.c   |    4 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  192 +++++++++++++++++---
 8 files changed, 242 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 4fa974c..cdd63a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -72,16 +72,32 @@ config STMMAC_CHAINED
 endchoice
 
 config STMMAC_USE_HWSTAMP
-	bool "Use IEEE 1588 Precision Time Protocol"
+	bool "IEEE 1588-2002 Precision Time Protocol (HW TimeStamping)"
 	depends on STMMAC_ETH
 	select PTP_1588_CLOCK
 	default n
 	---help---
-	  Enable this option to support the IEEE 1588 Precision Time Protocol
-	  (PTP) and HW Timestamps.
+	  Enable this option to support the IEEE 1588-2008 Precision Time
+	  Protocol (PTP) and HW Timestamps.
+	  At runtime, on new chip generations, the hardware capability
+	  register will be used to verify if IEEE 1588-2002 is actually
+	  supported.
+	  This mode can be also supported by chip with normal descriptor
+	  structures and w/o Extended descriptors.
+
+config STMMAC_USE_HW_A_STAMP
+	bool "IEEE 1588-2008 Precision Time Protocol (Advanced TimeStamping)"
+	depends on STMMAC_ETH
+	select STMMAC_USE_HWSTAMP
+	select STMMAC_EXTENDED_DESC
+	default n
+	---help---
+	  Enable this option to support the IEEE 1588-2008 Precision Time
+	  Protocol (PTP) Advanced HW Timestamps.
 	  At runtime, on new chip generations, the hardware capability
 	  register will be used to verify if either the IEEE 1588-2008 Advanced
-	  Timestamping (PTPv2) or IEEE 1588-2002 (PTPv1) is actually supported.
+	  Timestamping. To support this, it is mandatory to have the extended
+	  descriptor support.
 
 config STMMAC_EXTENDED_DESC
 	bool "Enable Extended descriptors (DES4-5-6-7)"
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index dd60f6b..61e870f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -94,6 +94,7 @@ static unsigned int stmmac_is_jumbo_frm(int len, int enh_desc)
 
 static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
 
 	if (priv->hwts_rx_en)
@@ -101,26 +102,29 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
 		 */
-		p->des3 = (unsigned int)(priv->dma_rx +
-			((priv->dirty_rx) + 1) % priv->dma_rx_size);
+		p->des3 = (unsigned int)(priv->dma_rx_phy +
+					 (((priv->dirty_rx) + 1) %
+					 priv->dma_rx_size) *
+					 sizeof(struct dma_desc));
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
 }
 
 static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p)
 {
 }
 
-static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
-				int tstamp_taken)
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
 
-	if (tstamp_taken && priv->hw->desc->get_tx_ls(p))
-		/* NOTE: Device will overwrite des3 with timestamp value if
-		 * 1588-2002 time stamping is enabled, hence reinitialize it
-		 * to keep explicit chaining in the descriptor.
-		 */
-		p->des3 = (unsigned int)(priv->dma_tx +
-			((priv->dirty_tx + 1) % priv->dma_tx_size));
+	if (priv->hwts_tx_en && priv->hw->desc->get_tx_ls(p)
+	    && !priv->dma_cap.atime_stamp)
+		p->des3 = (unsigned int)(priv->dma_tx_phy +
+					 (((priv->dirty_tx + 1) %
+					 priv->dma_tx_size) *
+					 sizeof(struct dma_desc)));
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
 }
 
 static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index a10974c..f5965b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -315,16 +315,18 @@ struct stmmac_desc_ops {
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
 			  struct dma_desc *p, int atds);
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 	/* Set tx timestamp enable bit */
 	void (*enable_tx_timestamp) (struct dma_desc *p);
 	/* get tx timestamp status */
 	int (*get_tx_timestamp_status) (struct dma_desc *p);
 	/* get tx/rx timestamp low value */
-	u32 (*get_timestamp_low) (struct dma_desc *p);
+	u32 (*get_timestamp_low) (struct dma_desc *p, u32 ats);
 	/* get tx/rx timestamp high value */
-	u32 (*get_timestamp_high) (struct dma_desc *p);
+	u32 (*get_timestamp_high) (struct dma_desc *p, u32 ats);
 	/* get rx timestamp status */
-	int (*get_rx_timestamp_status) (struct dma_desc *p);
+	int (*get_rx_timestamp_status) (struct dma_desc *p, u32 ats);
+#endif
 };
 
 struct stmmac_dma_ops {
@@ -412,7 +414,7 @@ struct stmmac_ring_mode_ops {
 	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
 	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
 				unsigned int size);
-	void (*clean_desc3) (void *priv, struct dma_desc *p, int tstamp_taken);
+	void (*clean_desc3) (void *priv, struct dma_desc *p);
 	int (*set_16kib_bfsize) (int mtu);
 };
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 50707c5..581f82b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -377,6 +377,7 @@ static int enh_desc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 		return p->des01.erx.frame_length;
 }
 
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 static void enh_desc_enable_tx_timestamp(struct dma_desc *p)
 {
 	p->des01.etx.time_stamp_enable = 1;
@@ -387,27 +388,39 @@ static int enh_desc_get_tx_timestamp_status(struct dma_desc *p)
 	return p->des01.etx.time_stamp_status;
 }
 
-static u32 enh_desc_get_timestamp_low(struct dma_desc *p)
+static u32 enh_desc_get_timestamp_low(struct dma_desc *p, u32 ats)
 {
-	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
-	return p->des2;
+#ifdef CONFIG_STMMAC_USE_HW_A_STAMP
+	if (ats)
+		return p->des6;
+	else
+#endif /* CONFIG_STMMAC_USE_HW_A_STAMP */
+		return p->des2;
 }
 
-static u32 enh_desc_get_timestamp_high(struct dma_desc *p)
+static u32 enh_desc_get_timestamp_high(struct dma_desc *p, u32 ats)
 {
-	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
-	return p->des3;
+#ifdef CONFIG_STMMAC_USE_HW_A_STAMP
+	if (ats)
+		return p->des7;
+	else
+#endif /* CONFIG_STMMAC_USE_HW_A_STAMP */
+		return p->des2;
 }
 
-static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
+static int enh_desc_get_rx_timestamp_status(struct dma_desc *p, u32 ats)
 {
-	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
-	if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
+	if (ats)
+		return p->des01.erx.ipc_csum_error;
+	else {
 		/* timestamp is currupted, hence don't store it */
-		return 0;
-	else
-		return 1;
+		if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
+			return 0;
+		else
+			return 1;
+	}
 }
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
 
 const struct stmmac_desc_ops enh_desc_ops = {
 	.tx_status = enh_desc_get_tx_status,
@@ -425,9 +438,11 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.set_tx_owner = enh_desc_set_tx_owner,
 	.set_rx_owner = enh_desc_set_rx_owner,
 	.get_rx_frame_len = enh_desc_get_rx_frame_len,
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 	.enable_tx_timestamp = enh_desc_enable_tx_timestamp,
 	.get_tx_timestamp_status = enh_desc_get_tx_timestamp_status,
 	.get_timestamp_low = enh_desc_get_timestamp_low,
 	.get_timestamp_high = enh_desc_get_timestamp_high,
 	.get_rx_timestamp_status = enh_desc_get_rx_timestamp_status,
+#endif
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 9eefb6c..3770942 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -215,6 +215,7 @@ static int ndesc_get_rx_frame_len(struct dma_desc *p, int rx_coe_type)
 		return p->des01.rx.frame_length;
 }
 
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 static void ndesc_enable_tx_timestamp(struct dma_desc *p)
 {
 	p->des01.tx.time_stamp_enable = 1;
@@ -225,17 +226,17 @@ static int ndesc_get_tx_timestamp_status(struct dma_desc *p)
 	return p->des01.tx.time_stamp_status;
 }
 
-static u32 ndesc_get_timestamp_low(struct dma_desc *p)
+static u32 ndesc_get_timestamp_low(struct dma_desc *p, u32 ats)
 {
 	return p->des2;
 }
 
-static u32 ndesc_get_timestamp_high(struct dma_desc *p)
+static u32 ndesc_get_timestamp_high(struct dma_desc *p, u32 ats)
 {
 	return p->des3;
 }
 
-static int ndesc_get_rx_timestamp_status(struct dma_desc *p)
+static int ndesc_get_rx_timestamp_status(struct dma_desc *p, u32 ats)
 {
 	if ((p->des2 == 0xffffffff) && (p->des3 == 0xffffffff))
 		/* timestamp is currupted, hence don't store it */
@@ -243,6 +244,7 @@ static int ndesc_get_rx_timestamp_status(struct dma_desc *p)
 	else
 		return 1;
 }
+#endif
 
 const struct stmmac_desc_ops ndesc_ops = {
 	.tx_status = ndesc_get_tx_status,
@@ -260,9 +262,11 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.set_tx_owner = ndesc_set_tx_owner,
 	.set_rx_owner = ndesc_set_rx_owner,
 	.get_rx_frame_len = ndesc_get_rx_frame_len,
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
 	.enable_tx_timestamp = ndesc_enable_tx_timestamp,
 	.get_tx_timestamp_status = ndesc_get_tx_timestamp_status,
 	.get_timestamp_low = ndesc_get_timestamp_low,
 	.get_timestamp_high = ndesc_get_timestamp_high,
 	.get_rx_timestamp_status = ndesc_get_rx_timestamp_status,
+#endif
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 94a1c2f..fbcc454 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -108,8 +108,7 @@ static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy_addr,
 {
 }
 
-static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
-				int tstamp_taken)
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
 	if (unlikely(p->des3))
 		p->des3 = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
index bec2278..5c71836 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
@@ -48,6 +48,10 @@ static void stmmac_config_sub_second_increment(void __iomem *ioaddr)
 	else
 		data = (1000000000ULL / STMMAC_SYSCLOCK);
 
+	/* 0.465ns accuracy */
+	if (value & PTP_TCR_TSCTRLSSR)
+		data = (data * 100) / 465;
+
 	writel(data, ioaddr + PTP_SSIR);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 009abf8..ae92191 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -316,38 +316,36 @@ static void stmmac_eee_adjust(struct stmmac_priv *priv)
  * Description :
  * This function will read timestamp from the descriptor & pass it to stack.
  * and also perform some sanity checks.
- * Return value :
- * 1 if time stamp is taken & 0 if time stamp is not taken.
  */
-static unsigned int stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
-					   struct dma_desc *p,
-					   struct sk_buff *skb)
+static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
+				   struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps shhwtstamp;
+	u32 ats = priv->dma_cap.atime_stamp;
 	u64 ns;
 
 	if (!priv->hwts_tx_en)
-		return 0;
+		return;
 
 	/* if skb doesn't support hw tstamp */
 	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
-		return 0;
+		return;
 
 	/* check tx tstamp status */
 	if (!priv->hw->desc->get_tx_timestamp_status(p))
-		return 0;
+		return;
 
 	/* get the valid tstamp */
-	ns = priv->hw->desc->get_timestamp_low(p);
+	ns = priv->hw->desc->get_timestamp_low(p, ats);
 	/* convert high/sec time stamp value to nanosecond */
-	ns += priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
+	ns += (priv->hw->desc->get_timestamp_high(p, ats) * 1000000000ULL);
 
 	memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 	shhwtstamp.hwtstamp = ns_to_ktime(ns);
 	/* pass tstamp to stack */
 	skb_tstamp_tx(skb, &shhwtstamp);
 
-	return 1;
+	return;
 }
 
 /* stmmac_get_rx_hwtstamp:
@@ -362,19 +360,20 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 				   struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamp = NULL;
+	u32 ats = priv->dma_cap.atime_stamp;
 	u64 ns;
 
 	if (!priv->hwts_rx_en)
 		return;
 
 	/* if rx tstamp is not valid */
-	if (!priv->hw->desc->get_rx_timestamp_status(p))
+	if (!priv->hw->desc->get_rx_timestamp_status(p, ats))
 		return;
 
 	/* get valid tstamp */
-	ns = priv->hw->desc->get_timestamp_low(p);
+	ns = priv->hw->desc->get_timestamp_low(p, ats);
 	/* convert high/sec time stamp value to nanosecond */
-	ns += priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
+	ns += (priv->hw->desc->get_timestamp_high(p, ats) * 1000000000ULL);
 	shhwtstamp = skb_hwtstamps(skb);
 	memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
 	shhwtstamp->hwtstamp = ns_to_ktime(ns);
@@ -397,8 +396,17 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	struct hwtstamp_config config;
 	struct timespec now;
 	u64 temp = 0;
-
-	if (!priv->dma_cap.time_stamp) {
+	u32 ptp_v2 = 0;
+	u32 tstamp_all = 0;
+	u32 ptp_over_ipv4_udp = 0;
+	u32 ptp_over_ipv6_udp = 0;
+	u32 ptp_over_ethernet = 0;
+	u32 snap_type_sel = 0;
+	u32 ts_master_en = 0;
+	u32 ts_event_en = 0;
+	u32 value = 0;
+
+	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp)) {
 		netdev_alert(priv->dev, "No HW time stamping supported\n");
 		priv->hwts_tx_en = 0;
 		priv->hwts_rx_en = 0;
@@ -428,22 +436,147 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		return -ERANGE;
 	}
 
-	switch (config.rx_filter) {
-	case HWTSTAMP_FILTER_NONE:
-		config.rx_filter = HWTSTAMP_FILTER_NONE;
-		break;
-	default:
+	if (priv->dma_cap.atime_stamp) {
+		switch (config.rx_filter) {
+		/* time stamp no incoming packet at all */
+		case HWTSTAMP_FILTER_NONE:
+			config.rx_filter = HWTSTAMP_FILTER_NONE;
+			break;
+
 		/* PTP v1, UDP, any kind of event packet */
-		config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
-		break;
+		case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+			/* take time stamp for all event messages */
+			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v1, UDP, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_SYNC;
+			/* take time stamp for SYNC messages only */
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v1, UDP, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en = PTP_TCR_TSMSTRENA;
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, any kind of event packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for all event messages */
+			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_SYNC;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for SYNC messages only */
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en = PTP_TCR_TSMSTRENA;
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, any kind of event packet */
+		case HWTSTAMP_FILTER_PTP_V2_EVENT:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for all event messages */
+			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet = PTP_TCR_TSIPENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V2_SYNC:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_SYNC;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for SYNC messages only */
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet = PTP_TCR_TSIPENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_DELAY_REQ;
+			ptp_v2 = PTP_TCR_TSVER2ENA;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en = PTP_TCR_TSMSTRENA;
+			ts_event_en = PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet = PTP_TCR_TSIPENA;
+			break;
+
+		/* time stamp any incoming packet */
+		case HWTSTAMP_FILTER_ALL:
+			config.rx_filter = HWTSTAMP_FILTER_ALL;
+			tstamp_all = PTP_TCR_TSENALL;
+			break;
+
+		default:
+			return -ERANGE;
+		}
+	} else {
+		switch (config.rx_filter) {
+		case HWTSTAMP_FILTER_NONE:
+			config.rx_filter = HWTSTAMP_FILTER_NONE;
+			break;
+		default:
+			/* PTP v1, UDP, any kind of event packet */
+			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+			break;
+		}
 	}
+
 	priv->hwts_rx_en = ((config.rx_filter == HWTSTAMP_FILTER_NONE) ? 0 : 1);
 
 	if (!priv->hwts_tx_en && !priv->hwts_rx_en)
 		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
 	else {
-		priv->hw->ptp->config_hw_tstamping(priv->ioaddr,
-			(PTP_TCR_TSENA | PTP_TCR_TSCFUPDT));
+		value = (PTP_TCR_TSENA | PTP_TCR_TSCFUPDT | PTP_TCR_TSCTRLSSR |
+			tstamp_all | ptp_v2 | ptp_over_ethernet |
+			ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
+			ts_master_en | snap_type_sel);
+
+		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
 
 		/* program Sub Second Increment reg */
 		priv->hw->ptp->config_sub_second_increment(priv->ioaddr);
@@ -454,7 +587,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 * where, freq_div_ratio = STMMAC_SYSCLOCK/50MHz
 		 * hence, addend = ((2^32) * 50MHz)/STMMAC_SYSCLOCK;
 		 * NOTE: STMMAC_SYSCLOCK should be >= 50MHz to
-		 *       achive 20ns accuracy.
+		 *	 achive 20ns accuracy.
 		 *
 		 * 2^x * y == (y << x), hence
 		 * 2^32 * 50000000 ==> (50000000 << 32)
@@ -502,7 +635,7 @@ static void stmmac_release_ptp(struct stmmac_priv *priv)
 #else
 #define stmmac_hwtstamp_ioctl(dev, ifr)	(-EOPNOTSUPP)
 #define stmmac_get_rx_hwtstamp(priv, p, skb)
-#define stmmac_get_tx_hwtstamp(priv, p, skb) 0
+#define stmmac_get_tx_hwtstamp(priv, p, skb)
 #define stmmac_init_ptp(priv) 0
 #define stmmac_release_ptp(priv)
 #endif /* CONFIG_STMMAC_USE_HWSTAMP */
@@ -915,7 +1048,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 	while (priv->dirty_tx != priv->cur_tx) {
 		int last;
-		unsigned int ts = 0;
 		unsigned int entry = priv->dirty_tx % txsize;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
 		struct dma_desc *p = priv->dma_tx + entry;
@@ -937,7 +1069,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			} else
 				priv->dev->stats.tx_errors++;
 
-			ts = stmmac_get_tx_hwtstamp(priv, p, skb);
+			stmmac_get_tx_hwtstamp(priv, p, skb);
 		}
 		TX_DBG("%s: curr %d, dirty %d\n", __func__,
 			priv->cur_tx, priv->dirty_tx);
@@ -949,7 +1081,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 					 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry] = 0;
 		}
-		priv->hw->ring->clean_desc3(priv, p, ts);
+		priv->hw->ring->clean_desc3(priv, p);
 
 		if (likely(skb != NULL)) {
 			dev_kfree_skb(skb);
-- 
1.7.4.4
