From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] mv643xx_eth: move sram window setting code into the driver
Date: Wed, 3 Sep 2008 16:00:49 +0200
Message-ID: <20080903140048.GC19602@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57532 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbYICOAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:00:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of a big mv643xx_eth annoyance of mine where the driver
exports the offsets of some of its internal registers via a header
file, and the Pegasos platform code ioremaps the peripheral directly
and pokes into peripheral registers directly without involving the
driver at all.

I don't have the hardware, though, so I'd appreciate it if someone
with a Pegasos board could test this (and possibly try some followup
patches if it doesn't work).  (You might need to apply some of the
other mv643xx_eth patches that I just sent to netdev@ -- I'll happily
provide a rolled-up patch on request.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/powerpc/platforms/chrp/pegasos_eth.c |   48 +++++++++++--------------
 drivers/net/mv643xx_eth.c                 |   56 +++++++++++++++++++++++------
 include/linux/mv643xx_eth.h               |   21 +++++++----
 3 files changed, 80 insertions(+), 45 deletions(-)

diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 130ff72..1adec8e 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -21,8 +21,8 @@
 #define PEGASOS2_SRAM_BASE 			(0xf2000000)
 #define PEGASOS2_SRAM_SIZE			(256*1024)
 
-#define PEGASOS2_SRAM_BASE_ETH0			(PEGASOS2_SRAM_BASE)
-#define PEGASOS2_SRAM_BASE_ETH1			(PEGASOS2_SRAM_BASE_ETH0 + (PEGASOS2_SRAM_SIZE / 2) )
+#define PEGASOS2_SRAM_OFF_ETH0			(0)
+#define PEGASOS2_SRAM_OFF_ETH1			(PEGASOS2_SRAM_SIZE / 2)
 
 
 #define PEGASOS2_SRAM_RXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
@@ -40,6 +40,14 @@ static struct resource mv643xx_eth_shared_resources[] = {
 	},
 };
 
+static struct mv643xx_eth_shared_platform_data mv643xx_eth_shared_pd = {
+	.sram_mbus_target_id	= 0x02,
+	.sram_mbus_target_attr	= 0x00,
+	.sram_mbus_addr		= PEGASOS2_SRAM_BASE,
+	.sram_size		= PEGASOS2_SRAM_SIZE,
+	.sram_cpu_phys_addr	= PEGASOS2_SRAM_BASE,
+};
+
 static struct platform_device mv643xx_eth_shared_device = {
 	.name		= MV643XX_ETH_SHARED_NAME,
 	.id		= 0,
@@ -61,12 +69,12 @@ static struct mv643xx_eth_platform_data eth0_pd = {
 	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 0,
 
-	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
-	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
+	.sram_tx_offset = PEGASOS2_SRAM_OFF_ETH0,
+	.sram_tx_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
 
-	.rx_sram_addr = PEGASOS2_SRAM_BASE_ETH0 + PEGASOS2_SRAM_TXRING_SIZE,
-	.rx_sram_size = PEGASOS2_SRAM_RXRING_SIZE,
+	.sram_rx_offset = PEGASOS2_SRAM_OFF_ETH0 + PEGASOS2_SRAM_TXRING_SIZE,
+	.sram_tx_size = PEGASOS2_SRAM_RXRING_SIZE,
 	.rx_queue_size = PEGASOS2_SRAM_RXRING_SIZE/16,
 };
 
@@ -93,12 +101,12 @@ static struct mv643xx_eth_platform_data eth1_pd = {
 	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 1,
 
-	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
-	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
+	.sram_tx_offset = PEGASOS2_SRAM_OFF_ETH1,
+	.sram_tx_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
 
-	.rx_sram_addr = PEGASOS2_SRAM_BASE_ETH1 + PEGASOS2_SRAM_TXRING_SIZE,
-	.rx_sram_size = PEGASOS2_SRAM_RXRING_SIZE,
+	.sram_rx_offset = PEGASOS2_SRAM_OFF_ETH1 + PEGASOS2_SRAM_TXRING_SIZE,
+	.sram_rx_size = PEGASOS2_SRAM_RXRING_SIZE,
 	.rx_queue_size = PEGASOS2_SRAM_RXRING_SIZE/16,
 };
 
@@ -123,16 +131,13 @@ static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 #define MV_READ(offset,val) 	{ val = readl(mv643xx_reg_base + offset); }
 #define MV_WRITE(offset,data) writel(data, mv643xx_reg_base + offset)
 
-static void __iomem *mv643xx_reg_base;
-
 static int Enable_SRAM(void)
 {
+	void __iomem *mv643xx_reg_base;
 	u32 ALong;
 
-	if (mv643xx_reg_base == NULL)
-		mv643xx_reg_base = ioremap(PEGASOS2_MARVELL_REGBASE,
-					PEGASOS2_MARVELL_REGSIZE);
-
+	mv643xx_reg_base = ioremap(PEGASOS2_MARVELL_REGBASE,
+				PEGASOS2_MARVELL_REGSIZE);
 	if (mv643xx_reg_base == NULL)
 		return -ENOMEM;
 
@@ -149,23 +154,12 @@ static int Enable_SRAM(void)
 	ALong &= ~(1 << 19);
 	MV_WRITE(MV64340_BASE_ADDR_ENABLE, ALong);
 
-	ALong = 0x02;
-	ALong |= PEGASOS2_SRAM_BASE & 0xffff0000;
-	MV_WRITE(MV643XX_ETH_BAR_4, ALong);
-
-	MV_WRITE(MV643XX_ETH_SIZE_REG_4, (PEGASOS2_SRAM_SIZE-1) & 0xffff0000);
-
-	MV_READ(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
-	ALong &= ~(1 << 4);
-	MV_WRITE(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
-
 #ifdef BE_VERBOSE
 	printk("Pegasos II/Marvell MV64361: register unmapped\n");
 	printk("Pegasos II/Marvell MV64361: SRAM at %p, size=%x\n", (void*) PEGASOS2_SRAM_BASE, PEGASOS2_SRAM_SIZE);
 #endif
 
 	iounmap(mv643xx_reg_base);
-	mv643xx_reg_base = NULL;
 
 	return 1;
 }
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d513a04..a3ffd1c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -262,8 +262,10 @@ struct mv643xx_eth_shared_private {
 	wait_queue_head_t smi_busy_wait;
 
 	/*
-	 * Per-port MBUS window access register value.
+	 * MBUS-related data.
 	 */
+	u32 sram_mbus_addr;
+	unsigned long sram_cpu_phys_addr;
 	u32 win_protect;
 
 	/*
@@ -369,8 +371,9 @@ struct mv643xx_eth_private {
 	 * RX state.
 	 */
 	int default_rx_ring_size;
-	unsigned long rx_desc_sram_addr;
+	u32 rx_desc_sram_mbus;
 	int rx_desc_sram_size;
+	unsigned long rx_desc_sram_phys;
 	int rxq_count;
 	struct timer_list rx_oom;
 	struct rx_queue rxq[8];
@@ -379,8 +382,9 @@ struct mv643xx_eth_private {
 	 * TX state.
 	 */
 	int default_tx_ring_size;
-	unsigned long tx_desc_sram_addr;
+	u32 tx_desc_sram_mbus;
 	int tx_desc_sram_size;
+	unsigned long tx_desc_sram_phys;
 	int txq_count;
 	struct tx_queue txq[8];
 };
@@ -1573,9 +1577,9 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 	size = rxq->rx_ring_size * sizeof(struct rx_desc);
 
 	if (index == 0 && size <= mp->rx_desc_sram_size) {
-		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_addr,
+		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_phys,
 						mp->rx_desc_sram_size);
-		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
+		rxq->rx_desc_dma = mp->rx_desc_sram_mbus;
 	} else {
 		rxq->rx_desc_area = dma_alloc_coherent(NULL, size,
 							&rxq->rx_desc_dma,
@@ -1673,9 +1677,9 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 	size = txq->tx_ring_size * sizeof(struct tx_desc);
 
 	if (index == 0 && size <= mp->tx_desc_sram_size) {
-		txq->tx_desc_area = ioremap(mp->tx_desc_sram_addr,
+		txq->tx_desc_area = ioremap(mp->tx_desc_sram_phys,
 						mp->tx_desc_sram_size);
-		txq->tx_desc_dma = mp->tx_desc_sram_addr;
+		txq->tx_desc_dma = mp->tx_desc_sram_mbus;
 	} else {
 		txq->tx_desc_area = dma_alloc_coherent(NULL, size,
 							&txq->tx_desc_dma,
@@ -2299,6 +2303,26 @@ mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *msp,
 	msp->win_protect = win_protect;
 }
 
+static void
+mv643xx_eth_conf_sram_mbus_windows(struct mv643xx_eth_shared_private *msp,
+				   u8 sram_mbus_target_id, u8 sram_mbus_attr,
+				   u32 sram_mbus_addr, u32 sram_size)
+{
+	void __iomem *base = msp->base;
+	u32 win_enable;
+
+	writel((sram_mbus_addr & 0xffff0000) |
+		(sram_mbus_attr << 8) |
+		sram_mbus_target_id, base + WINDOW_BASE(4));
+	writel((sram_size - 1) & 0xffff0000, base + WINDOW_SIZE(4));
+
+	win_enable = readl(base + WINDOW_BAR_ENABLE);
+	win_enable &= ~(1 << 4);
+	writel(win_enable, base + WINDOW_BAR_ENABLE);
+
+	msp->win_protect |= 3 << (2 * 4);
+}
+
 static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 {
 	/*
@@ -2391,6 +2415,13 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	 */
 	if (pd != NULL && pd->dram != NULL)
 		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
+	if (pd != NULL && pd->sram_mbus_addr) {
+		msp->sram_mbus_addr = pd->sram_mbus_addr;
+		msp->sram_cpu_phys_addr = pd->sram_cpu_phys_addr;
+		mv643xx_eth_conf_sram_mbus_windows(msp,
+			pd->sram_mbus_target_id, pd->sram_mbus_attr,
+			pd->sram_mbus_addr, pd->sram_size);
+	}
 
 	/*
 	 * Detect hardware parameters.
@@ -2457,6 +2488,7 @@ static int phy_addr_get(struct mv643xx_eth_private *mp)
 static void set_params(struct mv643xx_eth_private *mp,
 		       struct mv643xx_eth_platform_data *pd)
 {
+	struct mv643xx_eth_shared_private *msp = mp->shared;
 	struct net_device *dev = mp->dev;
 
 	if (is_valid_ether_addr(pd->mac_addr))
@@ -2467,16 +2499,18 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
 		mp->default_rx_ring_size = pd->rx_queue_size;
-	mp->rx_desc_sram_addr = pd->rx_sram_addr;
-	mp->rx_desc_sram_size = pd->rx_sram_size;
+	mp->rx_desc_sram_phys = msp->sram_cpu_phys_addr + pd->sram_rx_offset;
+	mp->rx_desc_sram_mbus = msp->sram_mbus_addr + pd->sram_rx_offset;
+	mp->rx_desc_sram_size = pd->sram_rx_size;
 
 	mp->rxq_count = pd->rx_queue_count ? : 1;
 
 	mp->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
 		mp->default_tx_ring_size = pd->tx_queue_size;
-	mp->tx_desc_sram_addr = pd->tx_sram_addr;
-	mp->tx_desc_sram_size = pd->tx_sram_size;
+	mp->tx_desc_sram_phys = msp->sram_cpu_phys_addr + pd->sram_tx_offset;
+	mp->tx_desc_sram_mbus = msp->sram_mbus_addr + pd->sram_tx_offset;
+	mp->tx_desc_sram_size = pd->sram_rx_size;
 
 	mp->txq_count = pd->tx_queue_count ? : 1;
 }
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index cbbbe9b..9daa4db 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -11,14 +11,21 @@
 #define MV643XX_ETH_NAME		"mv643xx_eth_port"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
-#define MV643XX_ETH_BAR_4		0x2220
-#define MV643XX_ETH_SIZE_REG_4		0x2224
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
 	struct platform_device	*shared_smi;
 	unsigned int		t_clk;
+
+	/*
+	 * MBUS target data for controller on-chip SRAM (if there
+	 * is any).
+	 */
+	u8			sram_mbus_target_id;
+	u8			sram_mbus_attr;
+	u32			sram_mbus_addr;
+	u32			sram_size;
+	unsigned long		sram_cpu_phys_addr;
 };
 
 #define MV643XX_ETH_PHY_ADDR_DEFAULT	0
@@ -68,10 +75,10 @@ struct mv643xx_eth_platform_data {
 	 * and sufficient to contain all descriptors for the requested
 	 * ring sizes.
 	 */
-	unsigned long		rx_sram_addr;
-	int			rx_sram_size;
-	unsigned long		tx_sram_addr;
-	int			tx_sram_size;
+	int			sram_rx_offset;
+	int			sram_rx_size;
+	int			sram_tx_offset;
+	int			sram_tx_size;
 };
 
 
-- 
1.5.6.4
