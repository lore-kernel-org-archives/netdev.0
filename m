From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: explicitly disable BM on 64bit platform
Date: Wed, 30 Mar 2016 17:11:41 +0200
Message-ID: <8737r8uhjm.fsf@free-electrons.com>
References: <1459344310-626-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mw@semihalf.com>,
	<thomas.petazzoni@free-electrons.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459344310-626-1-git-send-email-jszhang@marvell.com> (Jisheng
	Zhang's message of "Wed, 30 Mar 2016 21:25:10 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jisheng,
 
 On mer., mars 30 2016, Jisheng Zhang <jszhang@marvell.com> wrote:

> The mvneta BM can't work on 64bit platform, as the BM hardware expects
> buf virtual address to be placed in the first four bytes of mapped
> buffer, but obviously the virtual address on 64bit platform can't be
> stored in 4 bytes. So we have to explicitly disable BM on 64bit
> platform.

Actually mvneta is used on Armada 3700 which is a 64bits platform.
Is it true that the driver needs some change to use BM in 64 bits, but
we don't have to disable it.

Here is the 64 bits part of the patch we have currently on the hardware
prototype. We have more things which are really related to the way the
mvneta is connected to the Armada 3700 SoC. This code was not ready for
mainline but I prefer share it now instead of having the HWBM blindly
disable for 64 bits platform:

--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -55,7 +55,7 @@ config MVNETA_BM_ENABLE
 
 config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
-	depends on PLAT_ORION
+	depends on ARCH_MVEBU || COMPILE_TEST
 	select MVMDIO
 	select FIXED_PHY
 	---help---
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 577f7ca7deba..6929ad112b64 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -260,7 +260,7 @@
 
 #define MVNETA_VLAN_TAG_LEN             4
 
-#define MVNETA_CPU_D_CACHE_LINE_SIZE    32
+#define MVNETA_CPU_D_CACHE_LINE_SIZE    cache_line_size()
 #define MVNETA_TX_CSUM_DEF_SIZE		1600
 #define MVNETA_TX_CSUM_MAX_SIZE		9800
 #define MVNETA_ACC_MODE_EXT1		1
@@ -297,6 +297,12 @@
 /* descriptor aligned size */
 #define MVNETA_DESC_ALIGNED_SIZE	32
 
+/* Number of bytes to be taken into account by HW when putting incoming data
+ * to the buffers. It is needed in case NET_SKB_PAD exceeds maximum packet
+ * offset supported in MVNETA_RXQ_CONFIG_REG(q) registers.
+ */
+#define MVNETA_RX_PKT_OFFSET_CORRECTION		64
+
 #define MVNETA_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
 	      ETH_HLEN + ETH_FCS_LEN,			     \
@@ -417,6 +423,10 @@ struct mvneta_port {
 	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
 
 	u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
+#ifdef CONFIG_64BIT
+	u64 data_high;
+#endif
+	u16 rx_offset_correction;
 };
 
 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -961,7 +971,9 @@ static int mvneta_bm_port_init(struct platform_device *pdev,
 			       struct mvneta_port *pp)
 {
 	struct device_node *dn = pdev->dev.of_node;
-	u32 long_pool_id, short_pool_id, wsize;
+	u32 long_pool_id, short_pool_id;
+#ifndef CONFIG_64BIT
+	u32 wsize;
 	u8 target, attr;
 	int err;
 
@@ -985,7 +997,7 @@ static int mvneta_bm_port_init(struct platform_device *pdev,
 		netdev_info(pp->dev, "missing long pool id\n");
 		return -EINVAL;
 	}
-
+#endif
 	/* Create port's long pool depending on mtu */
 	pp->pool_long = mvneta_bm_pool_use(pp->bm_priv, long_pool_id,
 					   MVNETA_BM_LONG, pp->id,
@@ -1790,6 +1802,10 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 	if (!data)
 		return -ENOMEM;
 
+#ifdef CONFIG_64BIT
+	if (unlikely(pp->data_high != ((u64)data & 0xffffffff00000000)))
+		return -ENOMEM;
+#endif
 	phys_addr = dma_map_single(pp->dev->dev.parent, data,
 				   MVNETA_RX_BUF_SIZE(pp->pkt_size),
 				   DMA_FROM_DEVICE);
@@ -1798,7 +1814,8 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 		return -ENOMEM;
 	}
 
-	mvneta_rx_desc_fill(rx_desc, phys_addr, (u32)data);
+	phys_addr += pp->rx_offset_correction;
+	mvneta_rx_desc_fill(rx_desc, phys_addr, (uintptr_t)data);
 	return 0;
 }
 
@@ -1860,8 +1877,16 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 
 	for (i = 0; i < rxq->size; i++) {
 		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
-		void *data = (void *)rx_desc->buf_cookie;
-
+		void *data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)data);
+#endif
 		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 		mvneta_frag_free(pp->frag_size, data);
@@ -1898,7 +1923,17 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)rx_desc->buf_cookie);
+#else
 		data = (unsigned char *)rx_desc->buf_cookie;
+#endif
 		phys_addr = rx_desc->buf_phys_addr;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
@@ -2019,7 +2054,17 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
-		data = (unsigned char *)rx_desc->buf_cookie;
+#ifdef CONFIG_64BIT
+		/* In Neta HW only 32 bits data is supported, so in
+		 * order to obtain whole 64 bits address from RX
+		 * descriptor, we store the upper 32 bits when
+		 * allocating buffer, and put it back when using
+		 * buffer cookie for accessing packet in memory.
+		 */
+		data = (u8 *)(pp->data_high | (u64)rx_desc->buf_cookie);
+#else
+		data = (u8 *)rx_desc->buf_cookie;
+#endif
 		phys_addr = rx_desc->buf_phys_addr;
 		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc);
 		bm_pool = &pp->bm_priv->bm_pools[pool_id];
@@ -2774,7 +2819,7 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
 
 	/* Set Offset */
-	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
+	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD - pp->rx_offset_correction);
 
 	/* Set coalescing pkts and time */
 	mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
@@ -2935,6 +2980,22 @@ static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
 static int mvneta_setup_rxqs(struct mvneta_port *pp)
 {
 	int queue;
+#ifdef CONFIG_64BIT
+	void *data_tmp;
+
+	/* In Neta HW only 32 bits data is supported, so in order to
+	 * obtain whole 64 bits address from RX descriptor, we store
+	 * the upper 32 bits when allocating buffer, and put it back
+	 * when using buffer cookie for accessing packet in memory.
+	 * Frags should be allocated from single 'memory' region,
+	 * hence common upper address half should be sufficient.
+	 */
+	data_tmp = mvneta_frag_alloc(pp->frag_size);
+	if (data_tmp) {
+		pp->data_high = (u64)data_tmp & 0xffffffff00000000;
+		mvneta_frag_free(pp->frag_size, data_tmp);
+	}
+#endif
 
 	for (queue = 0; queue < rxq_number; queue++) {
 		int err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
@@ -3672,25 +3733,24 @@ static void mvneta_ethtool_update_stats(struct mvneta_port *pp)
 	const struct mvneta_statistic *s;
 	void __iomem *base = pp->base;
 	u32 high, low, val;
-	u64 val64;
 	int i;
 
 	for (i = 0, s = mvneta_statistics;
 	     s < mvneta_statistics + ARRAY_SIZE(mvneta_statistics);
 	     s++, i++) {
+		val = 0;
 		switch (s->type) {
 		case T_REG_32:
 			val = readl_relaxed(base + s->offset);
-			pp->ethtool_stats[i] += val;
 			break;
 		case T_REG_64:
 			/* Docs say to read low 32-bit then high */
 			low = readl_relaxed(base + s->offset);
 			high = readl_relaxed(base + s->offset + 4);
-			val64 = (u64)high << 32 | low;
-			pp->ethtool_stats[i] += val64;
+			val = (u64)high << 32 | low;
 			break;
 		}
+		pp->ethtool_stats[i] += val;
 	}
 }
 
@@ -4034,6 +4094,13 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp->rxq_def = rxq_def;
 
+	/* Set RX packet offset correction for platforms, whose
+	 * NET_SKB_PAD, exceeds 64B. It should be 64B for 64-bit
+	 * platforms and 0B for 32-bit ones.
+	 */
+	pp->rx_offset_correction =
+		max(0, NET_SKB_PAD - MVNETA_RX_PKT_OFFSET_CORRECTION);
+
 	pp->indir[0] = rxq_def;
 
 	pp->clk = devm_clk_get(&pdev->dev, "core");
--

>
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> ---
>  drivers/net/ethernet/marvell/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
> index b5c6d42..53d6572 100644
> --- a/drivers/net/ethernet/marvell/Kconfig
> +++ b/drivers/net/ethernet/marvell/Kconfig
> @@ -42,7 +42,7 @@ config MVMDIO
>  
>  config MVNETA_BM_ENABLE
>  	tristate "Marvell Armada 38x/XP network interface BM support"
> -	depends on MVNETA
> +	depends on MVNETA && !64BIT
>  	---help---
>  	  This driver supports auxiliary block of the network
>  	  interface units in the Marvell ARMADA XP and ARMADA 38x SoC
> -- 
> 2.8.0.rc3
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
