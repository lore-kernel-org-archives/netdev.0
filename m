From: akpm@linux-foundation.org
Subject: [patch 09/13] smc911x: pass along private data and use iomem
Date: Mon, 09 Jun 2008 16:33:54 -0700
Message-ID: <200806092333.m59NXso9014694@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org,
	m.kozlowski@tuxland.pl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39796 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757546AbYFIXem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

This patch contains changes needed for platform data support:
 - Move smc911x_local structure to header file
 - Pass along smc911x_local structure pointer to macros
 - Keep register base address in smc911x_local structure
 - Remove unused ioaddr variables

[m.kozlowski@tuxland.pl: Parenthesis fix in drivers/net/smc911x.h]
Signed-off-by: Magnus Damm <damm@igel.co.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.c |  406 ++++++++++++++++------------------------
 drivers/net/smc911x.h |  353 +++++++++++++++++++---------------
 2 files changed, 370 insertions(+), 389 deletions(-)

diff -puN drivers/net/smc911x.c~smc911x-pass-along-private-data-and-use-iomem drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~smc911x-pass-along-private-data-and-use-iomem
+++ a/drivers/net/smc911x.c
@@ -106,56 +106,6 @@ MODULE_ALIAS("platform:smc911x");
  */
 #define POWER_DOWN		 1
 
-
-/* store this information for the driver.. */
-struct smc911x_local {
-	/*
-	 * If I have to wait until the DMA is finished and ready to reload a
-	 * packet, I will store the skbuff here. Then, the DMA will send it
-	 * out and free it.
-	 */
-	struct sk_buff *pending_tx_skb;
-
-	/* version/revision of the SMC911x chip */
-	u16 version;
-	u16 revision;
-
-	/* FIFO sizes */
-	int tx_fifo_kb;
-	int tx_fifo_size;
-	int rx_fifo_size;
-	int afc_cfg;
-
-	/* Contains the current active receive/phy mode */
-	int ctl_rfduplx;
-	int ctl_rspeed;
-
-	u32 msg_enable;
-	u32 phy_type;
-	struct mii_if_info mii;
-
-	/* work queue */
-	struct work_struct phy_configure;
-	int work_pending;
-
-	int tx_throttle;
-	spinlock_t lock;
-
-	struct net_device *netdev;
-
-#ifdef SMC_USE_DMA
-	/* DMA needs the physical address of the chip */
-	u_long physaddr;
-	int rxdma;
-	int txdma;
-	int rxdma_active;
-	int txdma_active;
-	struct sk_buff *current_rx_skb;
-	struct sk_buff *current_tx_skb;
-	struct device *dev;
-#endif
-};
-
 #if SMC_DEBUG > 0
 #define DBG(n, args...)				 \
 	do {					 \
@@ -203,24 +153,24 @@ static void PRINT_PKT(u_char *buf, int l
 
 
 /* this enables an interrupt in the interrupt mask register */
-#define SMC_ENABLE_INT(x) do {				\
+#define SMC_ENABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
 	unsigned long __flags;				\
 	spin_lock_irqsave(&lp->lock, __flags);		\
-	__mask = SMC_GET_INT_EN();			\
+	__mask = SMC_GET_INT_EN((lp));			\
 	__mask |= (x);					\
-	SMC_SET_INT_EN(__mask);				\
+	SMC_SET_INT_EN((lp), __mask);			\
 	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
 /* this disables an interrupt from the interrupt mask register */
-#define SMC_DISABLE_INT(x) do {				\
+#define SMC_DISABLE_INT(lp, x) do {			\
 	unsigned int  __mask;				\
 	unsigned long __flags;				\
 	spin_lock_irqsave(&lp->lock, __flags);		\
-	__mask = SMC_GET_INT_EN();			\
+	__mask = SMC_GET_INT_EN((lp));			\
 	__mask &= ~(x);					\
-	SMC_SET_INT_EN(__mask);				\
+	SMC_SET_INT_EN((lp), __mask);			\
 	spin_unlock_irqrestore(&lp->lock, __flags);	\
 } while (0)
 
@@ -229,7 +179,6 @@ static void PRINT_PKT(u_char *buf, int l
  */
 static void smc911x_reset(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int reg, timeout=0, resets=1;
 	unsigned long flags;
@@ -237,13 +186,13 @@ static void smc911x_reset(struct net_dev
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/*	 Take out of PM setting first */
-	if ((SMC_GET_PMT_CTRL() & PMT_CTRL_READY_) == 0) {
+	if ((SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_) == 0) {
 		/* Write to the bytetest will take out of powerdown */
-		SMC_SET_BYTE_TEST(0);
+		SMC_SET_BYTE_TEST(lp, 0);
 		timeout=10;
 		do {
 			udelay(10);
-			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
+			reg = SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_;
 		} while (--timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
@@ -253,15 +202,15 @@ static void smc911x_reset(struct net_dev
 
 	/* Disable all interrupts */
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	while (resets--) {
-		SMC_SET_HW_CFG(HW_CFG_SRST_);
+		SMC_SET_HW_CFG(lp, HW_CFG_SRST_);
 		timeout=10;
 		do {
 			udelay(10);
-			reg = SMC_GET_HW_CFG();
+			reg = SMC_GET_HW_CFG(lp);
 			/* If chip indicates reset timeout then try again */
 			if (reg & HW_CFG_SRST_TO_) {
 				PRINTK("%s: chip reset timeout, retrying...\n", dev->name);
@@ -277,7 +226,7 @@ static void smc911x_reset(struct net_dev
 
 	/* make sure EEPROM has finished loading before setting GPIO_CFG */
 	timeout=1000;
-	while ( timeout-- && (SMC_GET_E2P_CMD() & E2P_CMD_EPC_BUSY_)) {
+	while ( timeout-- && (SMC_GET_E2P_CMD(lp) & E2P_CMD_EPC_BUSY_)) {
 		udelay(10);
 	}
 	if (timeout == 0){
@@ -286,24 +235,24 @@ static void smc911x_reset(struct net_dev
 	}
 
 	/* Initialize interrupts */
-	SMC_SET_INT_EN(0);
-	SMC_ACK_INT(-1);
+	SMC_SET_INT_EN(lp, 0);
+	SMC_ACK_INT(lp, -1);
 
 	/* Reset the FIFO level and flow control settings */
-	SMC_SET_HW_CFG((lp->tx_fifo_kb & 0xF) << 16);
+	SMC_SET_HW_CFG(lp, (lp->tx_fifo_kb & 0xF) << 16);
 //TODO: Figure out what appropriate pause time is
-	SMC_SET_FLOW(FLOW_FCPT_ | FLOW_FCEN_);
-	SMC_SET_AFC_CFG(lp->afc_cfg);
+	SMC_SET_FLOW(lp, FLOW_FCPT_ | FLOW_FCEN_);
+	SMC_SET_AFC_CFG(lp, lp->afc_cfg);
 
 
 	/* Set to LED outputs */
-	SMC_SET_GPIO_CFG(0x70070000);
+	SMC_SET_GPIO_CFG(lp, 0x70070000);
 
 	/*
 	 * Deassert IRQ for 1*10us for edge type interrupts
 	 * and drive IRQ pin push-pull
 	 */
-	SMC_SET_IRQ_CFG( (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_ );
+	SMC_SET_IRQ_CFG(lp, (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_);
 
 	/* clear anything saved */
 	if (lp->pending_tx_skb != NULL) {
@@ -319,46 +268,45 @@ static void smc911x_reset(struct net_dev
  */
 static void smc911x_enable(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
-	SMC_SET_MAC_ADDR(dev->dev_addr);
+	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
 
 	/* Enable TX */
-	cfg = SMC_GET_HW_CFG();
+	cfg = SMC_GET_HW_CFG(lp);
 	cfg &= HW_CFG_TX_FIF_SZ_ | 0xFFF;
 	cfg |= HW_CFG_SF_;
-	SMC_SET_HW_CFG(cfg);
-	SMC_SET_FIFO_TDA(0xFF);
+	SMC_SET_HW_CFG(lp, cfg);
+	SMC_SET_FIFO_TDA(lp, 0xFF);
 	/* Update TX stats on every 64 packets received or every 1 sec */
-	SMC_SET_FIFO_TSL(64);
-	SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
+	SMC_SET_FIFO_TSL(lp, 64);
+	SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(cr);
+	SMC_GET_MAC_CR(lp, cr);
 	cr |= MAC_CR_TXEN_ | MAC_CR_HBDIS_;
-	SMC_SET_MAC_CR(cr);
-	SMC_SET_TX_CFG(TX_CFG_TX_ON_);
+	SMC_SET_MAC_CR(lp, cr);
+	SMC_SET_TX_CFG(lp, TX_CFG_TX_ON_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Add 2 byte padding to start of packets */
-	SMC_SET_RX_CFG((2<<8) & RX_CFG_RXDOFF_);
+	SMC_SET_RX_CFG(lp, (2<<8) & RX_CFG_RXDOFF_);
 
 	/* Turn on receiver and enable RX */
 	if (cr & MAC_CR_RXEN_)
 		DBG(SMC_DEBUG_RX, "%s: Receiver already enabled\n", dev->name);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_MAC_CR( cr | MAC_CR_RXEN_ );
+	SMC_SET_MAC_CR(lp, cr | MAC_CR_RXEN_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Interrupt on every received packet */
-	SMC_SET_FIFO_RSA(0x01);
-	SMC_SET_FIFO_RSL(0x00);
+	SMC_SET_FIFO_RSA(lp, 0x01);
+	SMC_SET_FIFO_RSL(lp, 0x00);
 
 	/* now, enable interrupts */
 	mask = INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_ | INT_EN_RSFL_EN_ |
@@ -369,7 +317,7 @@ static void smc911x_enable(struct net_de
 	else {
 		mask|=INT_EN_RDFO_EN_;
 	}
-	SMC_ENABLE_INT(mask);
+	SMC_ENABLE_INT(lp, mask);
 }
 
 /*
@@ -377,7 +325,6 @@ static void smc911x_enable(struct net_de
  */
 static void smc911x_shutdown(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned cr;
 	unsigned long flags;
@@ -385,35 +332,35 @@ static void smc911x_shutdown(struct net_
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
 
 	/* Disable IRQ's */
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* Turn of Rx and TX */
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(cr);
+	SMC_GET_MAC_CR(lp, cr);
 	cr &= ~(MAC_CR_TXEN_ | MAC_CR_RXEN_ | MAC_CR_HBDIS_);
-	SMC_SET_MAC_CR(cr);
-	SMC_SET_TX_CFG(TX_CFG_STOP_TX_);
+	SMC_SET_MAC_CR(lp, cr);
+	SMC_SET_TX_CFG(lp, TX_CFG_STOP_TX_);
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
 static inline void smc911x_drop_pkt(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int fifo_count, timeout, reg;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
-	fifo_count = SMC_GET_RX_FIFO_INF() & 0xFFFF;
+	fifo_count = SMC_GET_RX_FIFO_INF(lp) & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
 		while (fifo_count--)
-			SMC_GET_RX_FIFO();
+			SMC_GET_RX_FIFO(lp);
 	} else	 {
 		/* Fast forward through the bad packet */
-		SMC_SET_RX_DP_CTRL(RX_DP_CTRL_FFWD_BUSY_);
+		SMC_SET_RX_DP_CTRL(lp, RX_DP_CTRL_FFWD_BUSY_);
 		timeout=50;
 		do {
 			udelay(10);
-			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
+			reg = SMC_GET_RX_DP_CTRL(lp) & RX_DP_CTRL_FFWD_BUSY_;
 		} while (--timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
@@ -429,14 +376,14 @@ static inline void smc911x_drop_pkt(stru
  */
 static inline void	 smc911x_rcv(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int pkt_len, status;
 	struct sk_buff *skb;
 	unsigned char *data;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
 		dev->name, __FUNCTION__);
-	status = SMC_GET_RX_STS_FIFO();
+	status = SMC_GET_RX_STS_FIFO(lp);
 	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
 	pkt_len = (status & RX_STS_PKT_LEN_) >> 16;
@@ -473,24 +420,23 @@ static inline void	 smc911x_rcv(struct n
 		skb_put(skb,pkt_len-4);
 #ifdef SMC_USE_DMA
 		{
-		struct smc911x_local *lp = netdev_priv(dev);
 		unsigned int fifo;
 		/* Lower the FIFO threshold if possible */
-		fifo = SMC_GET_FIFO_INT();
+		fifo = SMC_GET_FIFO_INT(lp);
 		if (fifo & 0xFF) fifo--;
 		DBG(SMC_DEBUG_RX, "%s: Setting RX stat FIFO threshold to %d\n",
 			dev->name, fifo & 0xff);
-		SMC_SET_FIFO_INT(fifo);
+		SMC_SET_FIFO_INT(lp, fifo);
 		/* Setup RX DMA */
-		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN16_ | ((2<<8) & RX_CFG_RXDOFF_));
+		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN16_ | ((2<<8) & RX_CFG_RXDOFF_));
 		lp->rxdma_active = 1;
 		lp->current_rx_skb = skb;
-		SMC_PULL_DATA(data, (pkt_len+2+15) & ~15);
+		SMC_PULL_DATA(lp, data, (pkt_len+2+15) & ~15);
 		/* Packet processing deferred to DMA RX interrupt */
 		}
 #else
-		SMC_SET_RX_CFG(RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
-		SMC_PULL_DATA(data, pkt_len+2+3);
+		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
+		SMC_PULL_DATA(lp, data, pkt_len+2+3);
 
 		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
@@ -509,7 +455,6 @@ static inline void	 smc911x_rcv(struct n
 static void smc911x_hardware_send_pkt(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	struct sk_buff *skb;
 	unsigned int cmdA, cmdB, len;
 	unsigned char *buf;
@@ -542,8 +487,8 @@ static void smc911x_hardware_send_pkt(st
 
 	DBG(SMC_DEBUG_TX, "%s: TX PKT LENGTH 0x%04x (%d) BUF 0x%p CMDA 0x%08x CMDB 0x%08x\n",
 		 dev->name, len, len, buf, cmdA, cmdB);
-	SMC_SET_TX_FIFO(cmdA);
-	SMC_SET_TX_FIFO(cmdB);
+	SMC_SET_TX_FIFO(lp, cmdA);
+	SMC_SET_TX_FIFO(lp, cmdB);
 
 	DBG(SMC_DEBUG_PKTS, "%s: Transmitted packet\n", dev->name);
 	PRINT_PKT(buf, len <= 64 ? len : 64);
@@ -551,10 +496,10 @@ static void smc911x_hardware_send_pkt(st
 	/* Send pkt via PIO or DMA */
 #ifdef SMC_USE_DMA
 	lp->current_tx_skb = skb;
-	SMC_PUSH_DATA(buf, len);
+	SMC_PUSH_DATA(lp, buf, len);
 	/* DMA complete IRQ will free buffer and set jiffies */
 #else
-	SMC_PUSH_DATA(buf, len);
+	SMC_PUSH_DATA(lp, buf, len);
 	dev->trans_start = jiffies;
 	dev_kfree_skb(skb);
 #endif
@@ -563,7 +508,7 @@ static void smc911x_hardware_send_pkt(st
 		netif_wake_queue(dev);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-	SMC_ENABLE_INT(INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_);
+	SMC_ENABLE_INT(lp, INT_EN_TDFA_EN_ | INT_EN_TSFL_EN_);
 }
 
 /*
@@ -575,7 +520,6 @@ static void smc911x_hardware_send_pkt(st
 static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	unsigned int free;
 	unsigned long flags;
 
@@ -584,7 +528,7 @@ static int smc911x_hard_start_xmit(struc
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
-	free = SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TDFREE_;
+	free = SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TDFREE_;
 	DBG(SMC_DEBUG_TX, "%s: TX free space %d\n", dev->name, free);
 
 	/* Turn off the flow when running out of space in FIFO */
@@ -593,7 +537,7 @@ static int smc911x_hard_start_xmit(struc
 			dev->name, free);
 		spin_lock_irqsave(&lp->lock, flags);
 		/* Reenable when at least 1 packet of size MTU present */
-		SMC_SET_FIFO_TDA((SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
+		SMC_SET_FIFO_TDA(lp, (SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
 		lp->tx_throttle = 1;
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&lp->lock, flags);
@@ -648,7 +592,6 @@ static int smc911x_hard_start_xmit(struc
  */
 static void smc911x_tx(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int tx_status;
 
@@ -656,11 +599,11 @@ static void smc911x_tx(struct net_device
 		dev->name, __FUNCTION__);
 
 	/* Collect the TX status */
-	while (((SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
+	while (((SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
 		DBG(SMC_DEBUG_TX, "%s: Tx stat FIFO used 0x%04x\n",
 			dev->name,
-			(SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16);
-		tx_status = SMC_GET_TX_STS_FIFO();
+			(SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16);
+		tx_status = SMC_GET_TX_STS_FIFO(lp);
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes+=tx_status>>16;
 		DBG(SMC_DEBUG_TX, "%s: Tx FIFO tag 0x%04x status 0x%04x\n",
@@ -698,10 +641,10 @@ static void smc911x_tx(struct net_device
 
 static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int phydata;
 
-	SMC_GET_MII(phyreg, phyaddr, phydata);
+	SMC_GET_MII(lp, phyreg, phyaddr, phydata);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
@@ -715,12 +658,12 @@ static int smc911x_phy_read(struct net_d
 static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 			int phydata)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
 		__FUNCTION__, phyaddr, phyreg, phydata);
 
-	SMC_SET_MII(phyreg, phyaddr, phydata);
+	SMC_SET_MII(lp, phyreg, phyaddr, phydata);
 }
 
 /*
@@ -729,7 +672,6 @@ static void smc911x_phy_write(struct net
  */
 static void smc911x_phy_detect(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	int phyaddr;
 	unsigned int cfg, id1, id2;
@@ -745,30 +687,30 @@ static void smc911x_phy_detect(struct ne
 	switch(lp->version) {
 		case 0x115:
 		case 0x117:
-			cfg = SMC_GET_HW_CFG();
+			cfg = SMC_GET_HW_CFG(lp);
 			if (cfg & HW_CFG_EXT_PHY_DET_) {
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
 				cfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg |= HW_CFG_EXT_PHY_EN_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg &= ~HW_CFG_PHY_CLK_SEL_;
 				cfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 				udelay(10); /* Wait for clocks to stop */
 
 				cfg |= HW_CFG_SMI_SEL_;
-				SMC_SET_HW_CFG(cfg);
+				SMC_SET_HW_CFG(lp, cfg);
 
 				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
 
 					/* Read the PHY identifiers */
-					SMC_GET_PHY_ID1(phyaddr & 31, id1);
-					SMC_GET_PHY_ID2(phyaddr & 31, id2);
+					SMC_GET_PHY_ID1(lp, phyaddr & 31, id1);
+					SMC_GET_PHY_ID2(lp, phyaddr & 31, id2);
 
 					/* Make sure it is a valid identifier */
 					if (id1 != 0x0000 && id1 != 0xffff &&
@@ -783,8 +725,8 @@ static void smc911x_phy_detect(struct ne
 			}
 		default:
 			/* Internal media only */
-			SMC_GET_PHY_ID1(1, id1);
-			SMC_GET_PHY_ID2(1, id2);
+			SMC_GET_PHY_ID1(lp, 1, id1);
+			SMC_GET_PHY_ID2(lp, 1, id2);
 			/* Save the PHY's address */
 			lp->mii.phy_id = 1;
 			lp->phy_type = id1 << 16 | id2;
@@ -801,16 +743,15 @@ static void smc911x_phy_detect(struct ne
 static int smc911x_phy_fixed(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/* Enter Link Disable state */
-	SMC_GET_PHY_BMCR(phyaddr, bmcr);
+	SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
 	bmcr |= BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	/*
 	 * Set our fixed capabilities
@@ -824,11 +765,11 @@ static int smc911x_phy_fixed(struct net_
 		bmcr |= BMCR_SPEED100;
 
 	/* Write our capabilities to the phy control register */
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	/* Re-Configure the Receive/Phy Control register */
 	bmcr &= ~BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phyaddr, bmcr);
+	SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
 
 	return 1;
 }
@@ -848,7 +789,6 @@ static int smc911x_phy_fixed(struct net_
 static int smc911x_phy_reset(struct net_device *dev, int phy)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int timeout;
 	unsigned long flags;
 	unsigned int reg;
@@ -856,15 +796,15 @@ static int smc911x_phy_reset(struct net_
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	reg = SMC_GET_PMT_CTRL();
+	reg = SMC_GET_PMT_CTRL(lp);
 	reg &= ~0xfffff030;
 	reg |= PMT_CTRL_PHY_RST_;
-	SMC_SET_PMT_CTRL(reg);
+	SMC_SET_PMT_CTRL(lp, reg);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	for (timeout = 2; timeout; timeout--) {
 		msleep(50);
 		spin_lock_irqsave(&lp->lock, flags);
-		reg = SMC_GET_PMT_CTRL();
+		reg = SMC_GET_PMT_CTRL(lp);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		if (!(reg & PMT_CTRL_PHY_RST_)) {
 			/* extra delay required because the phy may
@@ -889,13 +829,13 @@ static int smc911x_phy_reset(struct net_
  */
 static void smc911x_phy_powerdown(struct net_device *dev, int phy)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int bmcr;
 
 	/* Enter Link Disable state */
-	SMC_GET_PHY_BMCR(phy, bmcr);
+	SMC_GET_PHY_BMCR(lp, phy, bmcr);
 	bmcr |= BMCR_PDOWN;
-	SMC_SET_PHY_BMCR(phy, bmcr);
+	SMC_SET_PHY_BMCR(lp, phy, bmcr);
 }
 
 /*
@@ -909,7 +849,6 @@ static void smc911x_phy_powerdown(struct
 static void smc911x_phy_check_media(struct net_device *dev, int init)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
@@ -917,8 +856,8 @@ static void smc911x_phy_check_media(stru
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
-		SMC_GET_PHY_BMCR(phyaddr, bmcr);
-		SMC_GET_MAC_CR(cr);
+		SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
+		SMC_GET_MAC_CR(lp, cr);
 		if (lp->mii.full_duplex) {
 			DBG(SMC_DEBUG_MISC, "%s: Configuring for full-duplex mode\n", dev->name);
 			bmcr |= BMCR_FULLDPLX;
@@ -928,8 +867,8 @@ static void smc911x_phy_check_media(stru
 			bmcr &= ~BMCR_FULLDPLX;
 			cr &= ~MAC_CR_RCVOWN_;
 		}
-		SMC_SET_PHY_BMCR(phyaddr, bmcr);
-		SMC_SET_MAC_CR(cr);
+		SMC_SET_PHY_BMCR(lp, phyaddr, bmcr);
+		SMC_SET_MAC_CR(lp, cr);
 	}
 }
 
@@ -947,7 +886,6 @@ static void smc911x_phy_configure(struct
 	struct smc911x_local *lp = container_of(work, struct smc911x_local,
 						phy_configure);
 	struct net_device *dev = lp->netdev;
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int my_phy_caps; /* My PHY capabilities */
 	int my_ad_caps; /* My Advertised capabilities */
@@ -972,7 +910,7 @@ static void smc911x_phy_configure(struct
 	 * Enable PHY Interrupts (for register 18)
 	 * Interrupts listed here are enabled
 	 */
-	SMC_SET_PHY_INT_MASK(phyaddr, PHY_INT_MASK_ENERGY_ON_ |
+	SMC_SET_PHY_INT_MASK(lp, phyaddr, PHY_INT_MASK_ENERGY_ON_ |
 		 PHY_INT_MASK_ANEG_COMP_ | PHY_INT_MASK_REMOTE_FAULT_ |
 		 PHY_INT_MASK_LINK_DOWN_);
 
@@ -983,7 +921,7 @@ static void smc911x_phy_configure(struct
 	}
 
 	/* Copy our capabilities from MII_BMSR to MII_ADVERTISE */
-	SMC_GET_PHY_BMSR(phyaddr, my_phy_caps);
+	SMC_GET_PHY_BMSR(lp, phyaddr, my_phy_caps);
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
 		printk(KERN_INFO "Auto negotiation NOT supported\n");
 		smc911x_phy_fixed(dev);
@@ -1012,7 +950,7 @@ static void smc911x_phy_configure(struct
 		my_ad_caps &= ~(ADVERTISE_100FULL|ADVERTISE_10FULL);
 
 	/* Update our Auto-Neg Advertisement Register */
-	SMC_SET_PHY_MII_ADV(phyaddr, my_ad_caps);
+	SMC_SET_PHY_MII_ADV(lp, phyaddr, my_ad_caps);
 	lp->mii.advertising = my_ad_caps;
 
 	/*
@@ -1021,13 +959,13 @@ static void smc911x_phy_configure(struct
 	 * the link does not come up.
 	 */
 	udelay(10);
-	SMC_GET_PHY_MII_ADV(phyaddr, status);
+	SMC_GET_PHY_MII_ADV(lp, phyaddr, status);
 
 	DBG(SMC_DEBUG_MISC, "%s: phy caps=0x%04x\n", dev->name, my_phy_caps);
 	DBG(SMC_DEBUG_MISC, "%s: phy advertised caps=0x%04x\n", dev->name, my_ad_caps);
 
 	/* Restart auto-negotiation process in order to advertise my caps */
-	SMC_SET_PHY_BMCR(phyaddr, BMCR_ANENABLE | BMCR_ANRESTART);
+	SMC_SET_PHY_BMCR(lp, phyaddr, BMCR_ANENABLE | BMCR_ANRESTART);
 
 	smc911x_phy_check_media(dev, 1);
 
@@ -1046,7 +984,6 @@ smc911x_phy_configure_exit_nolock:
 static void smc911x_phy_interrupt(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
@@ -1057,11 +994,11 @@ static void smc911x_phy_interrupt(struct
 
 	smc911x_phy_check_media(dev, 0);
 	/* read to clear status bits */
-	SMC_GET_PHY_INT_SRC(phyaddr,status);
+	SMC_GET_PHY_INT_SRC(lp, phyaddr,status);
 	DBG(SMC_DEBUG_MISC, "%s: PHY interrupt status 0x%04x\n",
 		dev->name, status & 0xffff);
 	DBG(SMC_DEBUG_MISC, "%s: AFC_CFG 0x%08x\n",
-		dev->name, SMC_GET_AFC_CFG());
+		dev->name, SMC_GET_AFC_CFG(lp));
 }
 
 /*--- END PHY CONTROL AND CONFIGURATION-------------------------------------*/
@@ -1073,7 +1010,6 @@ static void smc911x_phy_interrupt(struct
 static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int status, mask, timeout;
 	unsigned int rx_overrun=0, cr, pkts;
@@ -1084,21 +1020,21 @@ static irqreturn_t smc911x_interrupt(int
 	spin_lock_irqsave(&lp->lock, flags);
 
 	/* Spurious interrupt check */
-	if ((SMC_GET_IRQ_CFG() & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
+	if ((SMC_GET_IRQ_CFG(lp) & (INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) !=
 		(INT_CFG_IRQ_INT_ | INT_CFG_IRQ_EN_)) {
 		spin_unlock_irqrestore(&lp->lock, flags);
 		return IRQ_NONE;
 	}
 
-	mask = SMC_GET_INT_EN();
-	SMC_SET_INT_EN(0);
+	mask = SMC_GET_INT_EN(lp);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* set a timeout value, so I don't stay here forever */
 	timeout = 8;
 
 
 	do {
-		status = SMC_GET_INT();
+		status = SMC_GET_INT(lp);
 
 		DBG(SMC_DEBUG_MISC, "%s: INT 0x%08x MASK 0x%08x OUTSIDE MASK 0x%08x\n",
 			dev->name, status, mask, status & ~mask);
@@ -1109,53 +1045,53 @@ static irqreturn_t smc911x_interrupt(int
 
 		/* Handle SW interrupt condition */
 		if (status & INT_STS_SW_INT_) {
-			SMC_ACK_INT(INT_STS_SW_INT_);
+			SMC_ACK_INT(lp, INT_STS_SW_INT_);
 			mask &= ~INT_EN_SW_INT_EN_;
 		}
 		/* Handle various error conditions */
 		if (status & INT_STS_RXE_) {
-			SMC_ACK_INT(INT_STS_RXE_);
+			SMC_ACK_INT(lp, INT_STS_RXE_);
 			dev->stats.rx_errors++;
 		}
 		if (status & INT_STS_RXDFH_INT_) {
-			SMC_ACK_INT(INT_STS_RXDFH_INT_);
-			dev->stats.rx_dropped+=SMC_GET_RX_DROP();
+			SMC_ACK_INT(lp, INT_STS_RXDFH_INT_);
+			dev->stats.rx_dropped+=SMC_GET_RX_DROP(lp);
 		 }
 		/* Undocumented interrupt-what is the right thing to do here? */
 		if (status & INT_STS_RXDF_INT_) {
-			SMC_ACK_INT(INT_STS_RXDF_INT_);
+			SMC_ACK_INT(lp, INT_STS_RXDF_INT_);
 		}
 
 		/* Rx Data FIFO exceeds set level */
 		if (status & INT_STS_RDFL_) {
 			if (IS_REV_A(lp->revision)) {
 				rx_overrun=1;
-				SMC_GET_MAC_CR(cr);
+				SMC_GET_MAC_CR(lp, cr);
 				cr &= ~MAC_CR_RXEN_;
-				SMC_SET_MAC_CR(cr);
+				SMC_SET_MAC_CR(lp, cr);
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
-			SMC_ACK_INT(INT_STS_RDFL_);
+			SMC_ACK_INT(lp, INT_STS_RDFL_);
 		}
 		if (status & INT_STS_RDFO_) {
 			if (!IS_REV_A(lp->revision)) {
-				SMC_GET_MAC_CR(cr);
+				SMC_GET_MAC_CR(lp, cr);
 				cr &= ~MAC_CR_RXEN_;
-				SMC_SET_MAC_CR(cr);
+				SMC_SET_MAC_CR(lp, cr);
 				rx_overrun=1;
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
-			SMC_ACK_INT(INT_STS_RDFO_);
+			SMC_ACK_INT(lp, INT_STS_RDFO_);
 		}
 		/* Handle receive condition */
 		if ((status & INT_STS_RSFL_) || rx_overrun) {
 			unsigned int fifo;
 			DBG(SMC_DEBUG_RX, "%s: RX irq\n", dev->name);
-			fifo = SMC_GET_RX_FIFO_INF();
+			fifo = SMC_GET_RX_FIFO_INF(lp);
 			pkts = (fifo & RX_FIFO_INF_RXSUSED_) >> 16;
 			DBG(SMC_DEBUG_RX, "%s: Rx FIFO pkts %d, bytes %d\n",
 				dev->name, pkts, fifo & 0xFFFF );
@@ -1166,61 +1102,61 @@ static irqreturn_t smc911x_interrupt(int
 					DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA,
 						"%s: RX DMA active\n", dev->name);
 					/* The DMA is already running so up the IRQ threshold */
-					fifo = SMC_GET_FIFO_INT() & ~0xFF;
+					fifo = SMC_GET_FIFO_INT(lp) & ~0xFF;
 					fifo |= pkts & 0xFF;
 					DBG(SMC_DEBUG_RX,
 						"%s: Setting RX stat FIFO threshold to %d\n",
 						dev->name, fifo & 0xff);
-					SMC_SET_FIFO_INT(fifo);
+					SMC_SET_FIFO_INT(lp, fifo);
 				} else
 #endif
 				smc911x_rcv(dev);
 			}
-			SMC_ACK_INT(INT_STS_RSFL_);
+			SMC_ACK_INT(lp, INT_STS_RSFL_);
 		}
 		/* Handle transmit FIFO available */
 		if (status & INT_STS_TDFA_) {
 			DBG(SMC_DEBUG_TX, "%s: TX data FIFO space available irq\n", dev->name);
-			SMC_SET_FIFO_TDA(0xFF);
+			SMC_SET_FIFO_TDA(lp, 0xFF);
 			lp->tx_throttle = 0;
 #ifdef SMC_USE_DMA
 			if (!lp->txdma_active)
 #endif
 				netif_wake_queue(dev);
-			SMC_ACK_INT(INT_STS_TDFA_);
+			SMC_ACK_INT(lp, INT_STS_TDFA_);
 		}
 		/* Handle transmit done condition */
 #if 1
 		if (status & (INT_STS_TSFL_ | INT_STS_GPT_INT_)) {
 			DBG(SMC_DEBUG_TX | SMC_DEBUG_MISC,
 				"%s: Tx stat FIFO limit (%d) /GPT irq\n",
-				dev->name, (SMC_GET_FIFO_INT() & 0x00ff0000) >> 16);
+				dev->name, (SMC_GET_FIFO_INT(lp) & 0x00ff0000) >> 16);
 			smc911x_tx(dev);
-			SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
-			SMC_ACK_INT(INT_STS_TSFL_);
-			SMC_ACK_INT(INT_STS_TSFL_ | INT_STS_GPT_INT_);
+			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
+			SMC_ACK_INT(lp, INT_STS_TSFL_);
+			SMC_ACK_INT(lp, INT_STS_TSFL_ | INT_STS_GPT_INT_);
 		}
 #else
 		if (status & INT_STS_TSFL_) {
 			DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq \n", dev->name, );
 			smc911x_tx(dev);
-			SMC_ACK_INT(INT_STS_TSFL_);
+			SMC_ACK_INT(lp, INT_STS_TSFL_);
 		}
 
 		if (status & INT_STS_GPT_INT_) {
 			DBG(SMC_DEBUG_RX, "%s: IRQ_CFG 0x%08x FIFO_INT 0x%08x RX_CFG 0x%08x\n",
 				dev->name,
-				SMC_GET_IRQ_CFG(),
-				SMC_GET_FIFO_INT(),
-				SMC_GET_RX_CFG());
+				SMC_GET_IRQ_CFG(lp),
+				SMC_GET_FIFO_INT(lp),
+				SMC_GET_RX_CFG(lp));
 			DBG(SMC_DEBUG_RX, "%s: Rx Stat FIFO Used 0x%02x "
 				"Data FIFO Used 0x%04x Stat FIFO 0x%08x\n",
 				dev->name,
-				(SMC_GET_RX_FIFO_INF() & 0x00ff0000) >> 16,
-				SMC_GET_RX_FIFO_INF() & 0xffff,
-				SMC_GET_RX_STS_FIFO_PEEK());
-			SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
-			SMC_ACK_INT(INT_STS_GPT_INT_);
+				(SMC_GET_RX_FIFO_INF(lp) & 0x00ff0000) >> 16,
+				SMC_GET_RX_FIFO_INF(lp) & 0xffff,
+				SMC_GET_RX_STS_FIFO_PEEK(lp));
+			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
+			SMC_ACK_INT(lp, INT_STS_GPT_INT_);
 		}
 #endif
 
@@ -1228,12 +1164,12 @@ static irqreturn_t smc911x_interrupt(int
 		if (status & INT_STS_PHY_INT_) {
 			DBG(SMC_DEBUG_MISC, "%s: PHY irq\n", dev->name);
 			smc911x_phy_interrupt(dev);
-			SMC_ACK_INT(INT_STS_PHY_INT_);
+			SMC_ACK_INT(lp, INT_STS_PHY_INT_);
 		}
 	} while (--timeout);
 
 	/* restore mask state */
-	SMC_SET_INT_EN(mask);
+	SMC_SET_INT_EN(lp, mask);
 
 	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
 		dev->name, 8-timeout);
@@ -1335,22 +1271,21 @@ static void smc911x_poll_controller(stru
 static void smc911x_timeout(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int status, mask;
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	status = SMC_GET_INT();
-	mask = SMC_GET_INT_EN();
+	status = SMC_GET_INT(lp);
+	mask = SMC_GET_INT_EN(lp);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	DBG(SMC_DEBUG_MISC, "%s: INT 0x%02x MASK 0x%02x \n",
 		dev->name, status, mask);
 
 	/* Dump the current TX FIFO contents and restart */
-	mask = SMC_GET_TX_CFG();
-	SMC_SET_TX_CFG(mask | TX_CFG_TXS_DUMP_ | TX_CFG_TXD_DUMP_);
+	mask = SMC_GET_TX_CFG(lp);
+	SMC_SET_TX_CFG(lp, mask | TX_CFG_TXS_DUMP_ | TX_CFG_TXD_DUMP_);
 	/*
 	 * Reconfiguring the PHY doesn't seem like a bad idea here, but
 	 * smc911x_phy_configure() calls msleep() which calls schedule_timeout()
@@ -1376,7 +1311,6 @@ static void smc911x_timeout(struct net_d
 static void smc911x_set_multicast_list(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	unsigned int multicast_table[2];
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
@@ -1384,7 +1318,7 @@ static void smc911x_set_multicast_list(s
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_GET_MAC_CR(mcr);
+	SMC_GET_MAC_CR(lp, mcr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (dev->flags & IFF_PROMISC) {
@@ -1461,13 +1395,13 @@ static void smc911x_set_multicast_list(s
 	}
 
 	spin_lock_irqsave(&lp->lock, flags);
-	SMC_SET_MAC_CR(mcr);
+	SMC_SET_MAC_CR(lp, mcr);
 	if (update_multicast) {
 		DBG(SMC_DEBUG_MISC,
 			"%s: update mcast hash table 0x%08x 0x%08x\n",
 			dev->name, multicast_table[0], multicast_table[1]);
-		SMC_SET_HASHL(multicast_table[0]);
-		SMC_SET_HASHH(multicast_table[1]);
+		SMC_SET_HASHL(lp, multicast_table[0]);
+		SMC_SET_HASHH(lp, multicast_table[1]);
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
@@ -1559,7 +1493,6 @@ static int
 smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int ret, status;
 	unsigned long flags;
 
@@ -1587,7 +1520,7 @@ smc911x_ethtool_getsettings(struct net_d
 		else
 			cmd->transceiver = XCVR_EXTERNAL;
 		cmd->port = 0;
-		SMC_GET_PHY_SPECIAL(lp->mii.phy_id, status);
+		SMC_GET_PHY_SPECIAL(lp, lp->mii.phy_id, status);
 		cmd->duplex =
 			(status & (PHY_SPECIAL_SPD_10FULL_ | PHY_SPECIAL_SPD_100FULL_)) ?
 				DUPLEX_FULL : DUPLEX_HALF;
@@ -1668,7 +1601,6 @@ static int smc911x_ethtool_getregslen(st
 static void smc911x_ethtool_getregs(struct net_device *dev,
 										 struct ethtool_regs* regs, void *buf)
 {
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned long flags;
 	u32 reg,i,j=0;
@@ -1676,17 +1608,17 @@ static void smc911x_ethtool_getregs(stru
 
 	regs->version = lp->version;
 	for(i=ID_REV;i<=E2P_CMD;i+=4) {
-		data[j++] = SMC_inl(ioaddr,i);
+		data[j++] = SMC_inl(lp, i);
 	}
 	for(i=MAC_CR;i<=WUCSR;i++) {
 		spin_lock_irqsave(&lp->lock, flags);
-		SMC_GET_MAC_CSR(i, reg);
+		SMC_GET_MAC_CSR(lp, i, reg);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		data[j++] = reg;
 	}
 	for(i=0;i<=31;i++) {
 		spin_lock_irqsave(&lp->lock, flags);
-		SMC_GET_MII(i, lp->mii.phy_id, reg);
+		SMC_GET_MII(lp, i, lp->mii.phy_id, reg);
 		spin_unlock_irqrestore(&lp->lock, flags);
 		data[j++] = reg & 0xFFFF;
 	}
@@ -1694,11 +1626,11 @@ static void smc911x_ethtool_getregs(stru
 
 static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int timeout;
 	int e2p_cmd;
 
-	e2p_cmd = SMC_GET_E2P_CMD();
+	e2p_cmd = SMC_GET_E2P_CMD(lp);
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
 			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
@@ -1706,7 +1638,7 @@ static int smc911x_ethtool_wait_eeprom_r
 			return -EFAULT;
 		}
 		mdelay(1);
-		e2p_cmd = SMC_GET_E2P_CMD();
+		e2p_cmd = SMC_GET_E2P_CMD(lp);
 	}
 	if (timeout == 0) {
 		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
@@ -1719,12 +1651,12 @@ static int smc911x_ethtool_wait_eeprom_r
 static inline int smc911x_ethtool_write_eeprom_cmd(struct net_device *dev,
 													int cmd, int addr)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	SMC_SET_E2P_CMD(E2P_CMD_EPC_BUSY_ |
+	SMC_SET_E2P_CMD(lp, E2P_CMD_EPC_BUSY_ |
 		((cmd) & (0x7<<28)) |
 		((addr) & 0xFF));
 	return 0;
@@ -1733,24 +1665,24 @@ static inline int smc911x_ethtool_write_
 static inline int smc911x_ethtool_read_eeprom_byte(struct net_device *dev,
 													u8 *data)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	*data = SMC_GET_E2P_DATA();
+	*data = SMC_GET_E2P_DATA(lp);
 	return 0;
 }
 
 static inline int smc911x_ethtool_write_eeprom_byte(struct net_device *dev,
 													 u8 data)
 {
-	unsigned long ioaddr = dev->base_addr;
+	struct smc911x_local *lp = netdev_priv(dev);
 	int ret;
 
 	if ((ret = smc911x_ethtool_wait_eeprom_ready(dev))!=0)
 		return ret;
-	SMC_SET_E2P_DATA(data);
+	SMC_SET_E2P_DATA(lp, data);
 	return 0;
 }
 
@@ -1817,8 +1749,9 @@ static const struct ethtool_ops smc911x_
  * This routine has a simple purpose -- make the SMC chip generate an
  * interrupt, so an auto-detect routine can detect it, and find the IRQ,
  */
-static int __init smc911x_findirq(unsigned long ioaddr)
+static int __init smc911x_findirq(struct net_device *dev)
 {
+	struct smc911x_local *lp = netdev_priv(dev);
 	int timeout = 20;
 	unsigned long cookie;
 
@@ -1830,7 +1763,7 @@ static int __init smc911x_findirq(unsign
 	 * Force a SW interrupt
 	 */
 
-	SMC_SET_INT_EN(INT_EN_SW_INT_EN_);
+	SMC_SET_INT_EN(lp, INT_EN_SW_INT_EN_);
 
 	/*
 	 * Wait until positive that the interrupt has been generated
@@ -1838,7 +1771,7 @@ static int __init smc911x_findirq(unsign
 	do {
 		int int_status;
 		udelay(10);
-		int_status = SMC_GET_INT_EN();
+		int_status = SMC_GET_INT_EN(lp);
 		if (int_status & INT_EN_SW_INT_EN_)
 			 break;		/* got the interrupt */
 	} while (--timeout);
@@ -1851,7 +1784,7 @@ static int __init smc911x_findirq(unsign
 	 */
 
 	/* and disable all interrupts again */
-	SMC_SET_INT_EN(0);
+	SMC_SET_INT_EN(lp, 0);
 
 	/* and return what I found */
 	return probe_irq_off(cookie);
@@ -1880,7 +1813,7 @@ static int __init smc911x_findirq(unsign
  * o  actually GRAB the irq.
  * o  GRAB the region
  */
-static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
+static int __init smc911x_probe(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int i, retval;
@@ -1890,7 +1823,7 @@ static int __init smc911x_probe(struct n
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/* First, see if the endian word is recognized */
-	val = SMC_GET_BYTE_TEST();
+	val = SMC_GET_BYTE_TEST(lp);
 	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
 	if (val != 0x87654321) {
 		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
@@ -1903,7 +1836,7 @@ static int __init smc911x_probe(struct n
 	 * recognize.	These might need to be added to later,
 	 * as future revisions could be added.
 	 */
-	chip_id = SMC_GET_PN();
+	chip_id = SMC_GET_PN(lp);
 	DBG(SMC_DEBUG_MISC, "%s: id probe returned 0x%04x\n", CARDNAME, chip_id);
 	for(i=0;chip_ids[i].id != 0; i++) {
 		if (chip_ids[i].id == chip_id) break;
@@ -1915,7 +1848,7 @@ static int __init smc911x_probe(struct n
 	}
 	version_string = chip_ids[i].name;
 
-	revision = SMC_GET_REV();
+	revision = SMC_GET_REV(lp);
 	DBG(SMC_DEBUG_MISC, "%s: revision = 0x%04x\n", CARDNAME, revision);
 
 	/* At this point I'll assume that the chip is an SMC911x. */
@@ -1929,7 +1862,6 @@ static int __init smc911x_probe(struct n
 	}
 
 	/* fill in some of the fields */
-	dev->base_addr = ioaddr;
 	lp->version = chip_ids[i].id;
 	lp->revision = revision;
 	lp->tx_fifo_kb = tx_fifo_kb;
@@ -1988,7 +1920,7 @@ static int __init smc911x_probe(struct n
 	spin_lock_init(&lp->lock);
 
 	/* Get the MAC address */
-	SMC_GET_MAC_ADDR(dev->dev_addr);
+	SMC_GET_MAC_ADDR(lp, dev->dev_addr);
 
 	/* now, reset the chip, and put it into a known state */
 	smc911x_reset(dev);
@@ -2005,7 +1937,7 @@ static int __init smc911x_probe(struct n
 
 		trials = 3;
 		while (trials--) {
-			dev->irq = smc911x_findirq(ioaddr);
+			dev->irq = smc911x_findirq(dev);
 			if (dev->irq)
 				break;
 			/* kick the card and try again */
@@ -2166,7 +2098,9 @@ static int smc911x_drv_probe(struct plat
 	}
 
 	platform_set_drvdata(pdev, ndev);
-	ret = smc911x_probe(ndev, (unsigned long)addr);
+	lp->base = addr;
+	ndev->base_addr = res->start;
+	ret = smc911x_probe(ndev);
 	if (ret != 0) {
 		platform_set_drvdata(pdev, NULL);
 		iounmap(addr);
@@ -2190,6 +2124,7 @@ out:
 static int smc911x_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct smc911x_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
@@ -2201,7 +2136,6 @@ static int smc911x_drv_remove(struct pla
 
 #ifdef SMC_USE_DMA
 	{
-		struct smc911x_local *lp = netdev_priv(ndev);
 		if (lp->rxdma != -1) {
 			SMC_DMA_FREE(dev, lp->rxdma);
 		}
@@ -2210,7 +2144,7 @@ static int smc911x_drv_remove(struct pla
 		}
 	}
 #endif
-	iounmap((void *)ndev->base_addr);
+	iounmap(lp->base);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, SMC911X_IO_EXTENT);
 
@@ -2221,7 +2155,7 @@ static int smc911x_drv_remove(struct pla
 static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
-	unsigned long ioaddr = ndev->base_addr;
+	struct smc911x_local *lp = netdev_priv(ndev);
 
 	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
 	if (ndev) {
@@ -2230,7 +2164,7 @@ static int smc911x_drv_suspend(struct pl
 			smc911x_shutdown(ndev);
 #if POWER_DOWN
 			/* Set D2 - Energy detect only setting */
-			SMC_SET_PMT_CTRL(2<<12);
+			SMC_SET_PMT_CTRL(lp, 2<<12);
 #endif
 		}
 	}
diff -puN drivers/net/smc911x.h~smc911x-pass-along-private-data-and-use-iomem drivers/net/smc911x.h
--- a/drivers/net/smc911x.h~smc911x-pass-along-private-data-and-use-iomem
+++ a/drivers/net/smc911x.h
@@ -44,31 +44,78 @@
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
 #endif
 
+/* store this information for the driver.. */
+struct smc911x_local {
+	/*
+	 * If I have to wait until the DMA is finished and ready to reload a
+	 * packet, I will store the skbuff here. Then, the DMA will send it
+	 * out and free it.
+	 */
+	struct sk_buff *pending_tx_skb;
+
+	/* version/revision of the SMC911x chip */
+	u16 version;
+	u16 revision;
+
+	/* FIFO sizes */
+	int tx_fifo_kb;
+	int tx_fifo_size;
+	int rx_fifo_size;
+	int afc_cfg;
+
+	/* Contains the current active receive/phy mode */
+	int ctl_rfduplx;
+	int ctl_rspeed;
+
+	u32 msg_enable;
+	u32 phy_type;
+	struct mii_if_info mii;
+
+	/* work queue */
+	struct work_struct phy_configure;
+	int work_pending;
+
+	int tx_throttle;
+	spinlock_t lock;
+
+	struct net_device *netdev;
+
+#ifdef SMC_USE_DMA
+	/* DMA needs the physical address of the chip */
+	u_long physaddr;
+	int rxdma;
+	int txdma;
+	int rxdma_active;
+	int txdma_active;
+	struct sk_buff *current_rx_skb;
+	struct sk_buff *current_tx_skb;
+	struct device *dev;
+#endif
+	void __iomem *base;
+};
 
 /*
  * Define the bus width specific IO macros
  */
 
 #if	SMC_USE_16BIT
-#define SMC_inl(a, r)		 (readw((a) + (r)) & 0xFFFF) + (readw((a) + (r) + 2) << 16))
-#define SMC_outl(v, a, r) 			 \
+#define SMC_inl(lp, r)		 ((readw((lp)->base + (r)) & 0xFFFF) + (readw((lp)->base + (r) + 2) << 16))
+#define SMC_outl(v, lp, r) 			 \
 	do{					 \
-		 writew(v & 0xFFFF, (a) + (r));	 \
-		 writew(v >> 16, (a) + (r) + 2); \
+		 writew(v & 0xFFFF, (lp)->base + (r));	 \
+		 writew(v >> 16, (lp)->base + (r) + 2); \
 	 } while (0)
-#define SMC_insl(a, r, p, l)	 readsw((short*)((a) + (r)), p, l*2)
-#define SMC_outsl(a, r, p, l)	 writesw((short*)((a) + (r)), p, l*2)
+#define SMC_insl(lp, r, p, l)	 readsw((short*)((lp)->base + (r)), p, l*2)
+#define SMC_outsl(lp, r, p, l)	 writesw((short*)((lp)->base + (r)), p, l*2)
 
 #elif	SMC_USE_32BIT
-#define SMC_inl(a, r)		 readl((a) + (r))
-#define SMC_outl(v, a, r)	 writel(v, (a) + (r))
-#define SMC_insl(a, r, p, l)	 readsl((int*)((a) + (r)), p, l)
-#define SMC_outsl(a, r, p, l)	 writesl((int*)((a) + (r)), p, l)
+#define SMC_inl(lp, r)		 readl((lp)->base + (r))
+#define SMC_outl(v, lp, r)	 writel(v, (lp)->base + (r))
+#define SMC_insl(lp, r, p, l)	 readsl((int*)((lp)->base + (r)), p, l)
+#define SMC_outsl(lp, r, p, l)	 writesl((int*)((lp)->base + (r)), p, l)
 
 #endif /* SMC_USE_16BIT */
 
-
-
 #ifdef SMC_USE_PXA_DMA
 #define SMC_USE_DMA
 
@@ -103,22 +150,22 @@ static int rx_dmalen, tx_dmalen;
 
 #ifdef SMC_insl
 #undef SMC_insl
-#define SMC_insl(a, r, p, l) \
-	smc_pxa_dma_insl(lp->dev, a, lp->physaddr, r, lp->rxdma, p, l)
+#define SMC_insl(lp, r, p, l) \
+	smc_pxa_dma_insl(lp, lp->physaddr, r, lp->rxdma, p, l)
 
 static inline void
-smc_pxa_dma_insl(struct device *dev, u_long ioaddr, u_long physaddr,
+smc_pxa_dma_insl(struct smc911x_local *lp, u_long physaddr,
 		int reg, int dma, u_char *buf, int len)
 {
 	/* 64 bit alignment is required for memory to memory DMA */
 	if ((long)buf & 4) {
-		*((u32 *)buf) = SMC_inl(ioaddr, reg);
+		*((u32 *)buf) = SMC_inl(lp, reg);
 		buf += 4;
 		len--;
 	}
 
 	len *= 4;
-	rx_dmabuf = dma_map_single(dev, buf, len, DMA_FROM_DEVICE);
+	rx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_FROM_DEVICE);
 	rx_dmalen = len;
 	DCSR(dma) = DCSR_NODESC;
 	DTADR(dma) = rx_dmabuf;
@@ -131,22 +178,22 @@ smc_pxa_dma_insl(struct device *dev, u_l
 
 #ifdef SMC_outsl
 #undef SMC_outsl
-#define SMC_outsl(a, r, p, l) \
-	 smc_pxa_dma_outsl(lp->dev, a, lp->physaddr, r, lp->txdma, p, l)
+#define SMC_outsl(lp, r, p, l) \
+	 smc_pxa_dma_outsl(lp, lp->physaddr, r, lp->txdma, p, l)
 
 static inline void
-smc_pxa_dma_outsl(struct device *dev, u_long ioaddr, u_long physaddr,
+smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 		int reg, int dma, u_char *buf, int len)
 {
 	/* 64 bit alignment is required for memory to memory DMA */
 	if ((long)buf & 4) {
-		SMC_outl(*((u32 *)buf), ioaddr, reg);
+		SMC_outl(*((u32 *)buf), lp, reg);
 		buf += 4;
 		len--;
 	}
 
 	len *= 4;
-	tx_dmabuf = dma_map_single(dev, buf, len, DMA_TO_DEVICE);
+	tx_dmabuf = dma_map_single(lp->dev, buf, len, DMA_TO_DEVICE);
 	tx_dmalen = len;
 	DCSR(dma) = DCSR_NODESC;
 	DSADR(dma) = tx_dmabuf;
@@ -565,213 +612,213 @@ static const struct chip_id chip_ids[] =
  * capabilities.  Please use those and not the in/out primitives.
  */
 /* FIFO read/write macros */
-#define SMC_PUSH_DATA(p, l)	SMC_outsl( ioaddr, TX_DATA_FIFO, p, (l) >> 2 )
-#define SMC_PULL_DATA(p, l)	SMC_insl ( ioaddr, RX_DATA_FIFO, p, (l) >> 2 )
-#define SMC_SET_TX_FIFO(x) 	SMC_outl( x, ioaddr, TX_DATA_FIFO )
-#define SMC_GET_RX_FIFO()	SMC_inl( ioaddr, RX_DATA_FIFO )
+#define SMC_PUSH_DATA(lp, p, l)	SMC_outsl( lp, TX_DATA_FIFO, p, (l) >> 2 )
+#define SMC_PULL_DATA(lp, p, l)	SMC_insl ( lp, RX_DATA_FIFO, p, (l) >> 2 )
+#define SMC_SET_TX_FIFO(lp, x) 	SMC_outl( x, lp, TX_DATA_FIFO )
+#define SMC_GET_RX_FIFO(lp)	SMC_inl( lp, RX_DATA_FIFO )
 
 
 /* I/O mapped register read/write macros */
-#define SMC_GET_TX_STS_FIFO()		SMC_inl( ioaddr, TX_STATUS_FIFO )
-#define SMC_GET_RX_STS_FIFO()		SMC_inl( ioaddr, RX_STATUS_FIFO )
-#define SMC_GET_RX_STS_FIFO_PEEK()	SMC_inl( ioaddr, RX_STATUS_FIFO_PEEK )
-#define SMC_GET_PN()			(SMC_inl( ioaddr, ID_REV ) >> 16)
-#define SMC_GET_REV()			(SMC_inl( ioaddr, ID_REV ) & 0xFFFF)
-#define SMC_GET_IRQ_CFG()		SMC_inl( ioaddr, INT_CFG )
-#define SMC_SET_IRQ_CFG(x)		SMC_outl( x, ioaddr, INT_CFG )
-#define SMC_GET_INT()			SMC_inl( ioaddr, INT_STS )
-#define SMC_ACK_INT(x)			SMC_outl( x, ioaddr, INT_STS )
-#define SMC_GET_INT_EN()		SMC_inl( ioaddr, INT_EN )
-#define SMC_SET_INT_EN(x)		SMC_outl( x, ioaddr, INT_EN )
-#define SMC_GET_BYTE_TEST()		SMC_inl( ioaddr, BYTE_TEST )
-#define SMC_SET_BYTE_TEST(x)		SMC_outl( x, ioaddr, BYTE_TEST )
-#define SMC_GET_FIFO_INT()		SMC_inl( ioaddr, FIFO_INT )
-#define SMC_SET_FIFO_INT(x)		SMC_outl( x, ioaddr, FIFO_INT )
-#define SMC_SET_FIFO_TDA(x)					\
+#define SMC_GET_TX_STS_FIFO(lp)		SMC_inl( lp, TX_STATUS_FIFO )
+#define SMC_GET_RX_STS_FIFO(lp)		SMC_inl( lp, RX_STATUS_FIFO )
+#define SMC_GET_RX_STS_FIFO_PEEK(lp)	SMC_inl( lp, RX_STATUS_FIFO_PEEK )
+#define SMC_GET_PN(lp)			(SMC_inl( lp, ID_REV ) >> 16)
+#define SMC_GET_REV(lp)			(SMC_inl( lp, ID_REV ) & 0xFFFF)
+#define SMC_GET_IRQ_CFG(lp)		SMC_inl( lp, INT_CFG )
+#define SMC_SET_IRQ_CFG(lp, x)		SMC_outl( x, lp, INT_CFG )
+#define SMC_GET_INT(lp)			SMC_inl( lp, INT_STS )
+#define SMC_ACK_INT(lp, x)			SMC_outl( x, lp, INT_STS )
+#define SMC_GET_INT_EN(lp)		SMC_inl( lp, INT_EN )
+#define SMC_SET_INT_EN(lp, x)		SMC_outl( x, lp, INT_EN )
+#define SMC_GET_BYTE_TEST(lp)		SMC_inl( lp, BYTE_TEST )
+#define SMC_SET_BYTE_TEST(lp, x)		SMC_outl( x, lp, BYTE_TEST )
+#define SMC_GET_FIFO_INT(lp)		SMC_inl( lp, FIFO_INT )
+#define SMC_SET_FIFO_INT(lp, x)		SMC_outl( x, lp, FIFO_INT )
+#define SMC_SET_FIFO_TDA(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<24);	\
-		SMC_SET_FIFO_INT( __mask | (x)<<24 );		\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<24);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (x)<<24 );	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_TSL(x)					\
+#define SMC_SET_FIFO_TSL(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<16);	\
-		SMC_SET_FIFO_INT( __mask | (((x) & 0xFF)<<16));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<16);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (((x) & 0xFF)<<16));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_RSA(x)					\
+#define SMC_SET_FIFO_RSA(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~(0xFF<<8);	\
-		SMC_SET_FIFO_INT( __mask | (((x) & 0xFF)<<8));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~(0xFF<<8);	\
+		SMC_SET_FIFO_INT( (lp), __mask | (((x) & 0xFF)<<8));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_SET_FIFO_RSL(x)					\
+#define SMC_SET_FIFO_RSL(lp, x)					\
 	do {							\
 		unsigned long __flags;				\
 		int __mask;					\
 		local_irq_save(__flags);			\
-		__mask = SMC_GET_FIFO_INT() & ~0xFF;		\
-		SMC_SET_FIFO_INT( __mask | ((x) & 0xFF));	\
+		__mask = SMC_GET_FIFO_INT((lp)) & ~0xFF;	\
+		SMC_SET_FIFO_INT( (lp),__mask | ((x) & 0xFF));	\
 		local_irq_restore(__flags);			\
 	} while (0)
-#define SMC_GET_RX_CFG()		SMC_inl( ioaddr, RX_CFG )
-#define SMC_SET_RX_CFG(x)		SMC_outl( x, ioaddr, RX_CFG )
-#define SMC_GET_TX_CFG()		SMC_inl( ioaddr, TX_CFG )
-#define SMC_SET_TX_CFG(x)		SMC_outl( x, ioaddr, TX_CFG )
-#define SMC_GET_HW_CFG()		SMC_inl( ioaddr, HW_CFG )
-#define SMC_SET_HW_CFG(x)		SMC_outl( x, ioaddr, HW_CFG )
-#define SMC_GET_RX_DP_CTRL()		SMC_inl( ioaddr, RX_DP_CTRL )
-#define SMC_SET_RX_DP_CTRL(x)		SMC_outl( x, ioaddr, RX_DP_CTRL )
-#define SMC_GET_PMT_CTRL()		SMC_inl( ioaddr, PMT_CTRL )
-#define SMC_SET_PMT_CTRL(x)		SMC_outl( x, ioaddr, PMT_CTRL )
-#define SMC_GET_GPIO_CFG()		SMC_inl( ioaddr, GPIO_CFG )
-#define SMC_SET_GPIO_CFG(x)		SMC_outl( x, ioaddr, GPIO_CFG )
-#define SMC_GET_RX_FIFO_INF()		SMC_inl( ioaddr, RX_FIFO_INF )
-#define SMC_SET_RX_FIFO_INF(x)		SMC_outl( x, ioaddr, RX_FIFO_INF )
-#define SMC_GET_TX_FIFO_INF()		SMC_inl( ioaddr, TX_FIFO_INF )
-#define SMC_SET_TX_FIFO_INF(x)		SMC_outl( x, ioaddr, TX_FIFO_INF )
-#define SMC_GET_GPT_CFG()		SMC_inl( ioaddr, GPT_CFG )
-#define SMC_SET_GPT_CFG(x)		SMC_outl( x, ioaddr, GPT_CFG )
-#define SMC_GET_RX_DROP()		SMC_inl( ioaddr, RX_DROP )
-#define SMC_SET_RX_DROP(x)		SMC_outl( x, ioaddr, RX_DROP )
-#define SMC_GET_MAC_CMD()		SMC_inl( ioaddr, MAC_CSR_CMD )
-#define SMC_SET_MAC_CMD(x)		SMC_outl( x, ioaddr, MAC_CSR_CMD )
-#define SMC_GET_MAC_DATA()		SMC_inl( ioaddr, MAC_CSR_DATA )
-#define SMC_SET_MAC_DATA(x)		SMC_outl( x, ioaddr, MAC_CSR_DATA )
-#define SMC_GET_AFC_CFG()		SMC_inl( ioaddr, AFC_CFG )
-#define SMC_SET_AFC_CFG(x)		SMC_outl( x, ioaddr, AFC_CFG )
-#define SMC_GET_E2P_CMD()		SMC_inl( ioaddr, E2P_CMD )
-#define SMC_SET_E2P_CMD(x)		SMC_outl( x, ioaddr, E2P_CMD )
-#define SMC_GET_E2P_DATA()		SMC_inl( ioaddr, E2P_DATA )
-#define SMC_SET_E2P_DATA(x)		SMC_outl( x, ioaddr, E2P_DATA )
+#define SMC_GET_RX_CFG(lp)		SMC_inl( lp, RX_CFG )
+#define SMC_SET_RX_CFG(lp, x)		SMC_outl( x, lp, RX_CFG )
+#define SMC_GET_TX_CFG(lp)		SMC_inl( lp, TX_CFG )
+#define SMC_SET_TX_CFG(lp, x)		SMC_outl( x, lp, TX_CFG )
+#define SMC_GET_HW_CFG(lp)		SMC_inl( lp, HW_CFG )
+#define SMC_SET_HW_CFG(lp, x)		SMC_outl( x, lp, HW_CFG )
+#define SMC_GET_RX_DP_CTRL(lp)		SMC_inl( lp, RX_DP_CTRL )
+#define SMC_SET_RX_DP_CTRL(lp, x)		SMC_outl( x, lp, RX_DP_CTRL )
+#define SMC_GET_PMT_CTRL(lp)		SMC_inl( lp, PMT_CTRL )
+#define SMC_SET_PMT_CTRL(lp, x)		SMC_outl( x, lp, PMT_CTRL )
+#define SMC_GET_GPIO_CFG(lp)		SMC_inl( lp, GPIO_CFG )
+#define SMC_SET_GPIO_CFG(lp, x)		SMC_outl( x, lp, GPIO_CFG )
+#define SMC_GET_RX_FIFO_INF(lp)		SMC_inl( lp, RX_FIFO_INF )
+#define SMC_SET_RX_FIFO_INF(lp, x)		SMC_outl( x, lp, RX_FIFO_INF )
+#define SMC_GET_TX_FIFO_INF(lp)		SMC_inl( lp, TX_FIFO_INF )
+#define SMC_SET_TX_FIFO_INF(lp, x)		SMC_outl( x, lp, TX_FIFO_INF )
+#define SMC_GET_GPT_CFG(lp)		SMC_inl( lp, GPT_CFG )
+#define SMC_SET_GPT_CFG(lp, x)		SMC_outl( x, lp, GPT_CFG )
+#define SMC_GET_RX_DROP(lp)		SMC_inl( lp, RX_DROP )
+#define SMC_SET_RX_DROP(lp, x)		SMC_outl( x, lp, RX_DROP )
+#define SMC_GET_MAC_CMD(lp)		SMC_inl( lp, MAC_CSR_CMD )
+#define SMC_SET_MAC_CMD(lp, x)		SMC_outl( x, lp, MAC_CSR_CMD )
+#define SMC_GET_MAC_DATA(lp)		SMC_inl( lp, MAC_CSR_DATA )
+#define SMC_SET_MAC_DATA(lp, x)		SMC_outl( x, lp, MAC_CSR_DATA )
+#define SMC_GET_AFC_CFG(lp)		SMC_inl( lp, AFC_CFG )
+#define SMC_SET_AFC_CFG(lp, x)		SMC_outl( x, lp, AFC_CFG )
+#define SMC_GET_E2P_CMD(lp)		SMC_inl( lp, E2P_CMD )
+#define SMC_SET_E2P_CMD(lp, x)		SMC_outl( x, lp, E2P_CMD )
+#define SMC_GET_E2P_DATA(lp)		SMC_inl( lp, E2P_DATA )
+#define SMC_SET_E2P_DATA(lp, x)		SMC_outl( x, lp, E2P_DATA )
 
 /* MAC register read/write macros */
-#define SMC_GET_MAC_CSR(a,v)						\
+#define SMC_GET_MAC_CSR(lp,a,v)						\
 	do {								\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_CSR_BUSY_ |			\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_CMD((lp),MAC_CSR_CMD_CSR_BUSY_ |		\
 			MAC_CSR_CMD_R_NOT_W_ | (a) );			\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		v = SMC_GET_MAC_DATA();					\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		v = SMC_GET_MAC_DATA((lp));			       	\
 	} while (0)
-#define SMC_SET_MAC_CSR(a,v)						\
+#define SMC_SET_MAC_CSR(lp,a,v)						\
 	do {								\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_DATA(v);					\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_CSR_BUSY_ | (a) );		\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-	} while (0)
-#define SMC_GET_MAC_CR(x)	SMC_GET_MAC_CSR( MAC_CR, x )
-#define SMC_SET_MAC_CR(x)	SMC_SET_MAC_CSR( MAC_CR, x )
-#define SMC_GET_ADDRH(x)	SMC_GET_MAC_CSR( ADDRH, x )
-#define SMC_SET_ADDRH(x)	SMC_SET_MAC_CSR( ADDRH, x )
-#define SMC_GET_ADDRL(x)	SMC_GET_MAC_CSR( ADDRL, x )
-#define SMC_SET_ADDRL(x)	SMC_SET_MAC_CSR( ADDRL, x )
-#define SMC_GET_HASHH(x)	SMC_GET_MAC_CSR( HASHH, x )
-#define SMC_SET_HASHH(x)	SMC_SET_MAC_CSR( HASHH, x )
-#define SMC_GET_HASHL(x)	SMC_GET_MAC_CSR( HASHL, x )
-#define SMC_SET_HASHL(x)	SMC_SET_MAC_CSR( HASHL, x )
-#define SMC_GET_MII_ACC(x)	SMC_GET_MAC_CSR( MII_ACC, x )
-#define SMC_SET_MII_ACC(x)	SMC_SET_MAC_CSR( MII_ACC, x )
-#define SMC_GET_MII_DATA(x)	SMC_GET_MAC_CSR( MII_DATA, x )
-#define SMC_SET_MII_DATA(x)	SMC_SET_MAC_CSR( MII_DATA, x )
-#define SMC_GET_FLOW(x)		SMC_GET_MAC_CSR( FLOW, x )
-#define SMC_SET_FLOW(x)		SMC_SET_MAC_CSR( FLOW, x )
-#define SMC_GET_VLAN1(x)	SMC_GET_MAC_CSR( VLAN1, x )
-#define SMC_SET_VLAN1(x)	SMC_SET_MAC_CSR( VLAN1, x )
-#define SMC_GET_VLAN2(x)	SMC_GET_MAC_CSR( VLAN2, x )
-#define SMC_SET_VLAN2(x)	SMC_SET_MAC_CSR( VLAN2, x )
-#define SMC_SET_WUFF(x)		SMC_SET_MAC_CSR( WUFF, x )
-#define SMC_GET_WUCSR(x)	SMC_GET_MAC_CSR( WUCSR, x )
-#define SMC_SET_WUCSR(x)	SMC_SET_MAC_CSR( WUCSR, x )
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_DATA((lp), v);				\
+		SMC_SET_MAC_CMD((lp), MAC_CSR_CMD_CSR_BUSY_ | (a) );	\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+	} while (0)
+#define SMC_GET_MAC_CR(lp, x)	SMC_GET_MAC_CSR( (lp), MAC_CR, x )
+#define SMC_SET_MAC_CR(lp, x)	SMC_SET_MAC_CSR( (lp), MAC_CR, x )
+#define SMC_GET_ADDRH(lp, x)	SMC_GET_MAC_CSR( (lp), ADDRH, x )
+#define SMC_SET_ADDRH(lp, x)	SMC_SET_MAC_CSR( (lp), ADDRH, x )
+#define SMC_GET_ADDRL(lp, x)	SMC_GET_MAC_CSR( (lp), ADDRL, x )
+#define SMC_SET_ADDRL(lp, x)	SMC_SET_MAC_CSR( (lp), ADDRL, x )
+#define SMC_GET_HASHH(lp, x)	SMC_GET_MAC_CSR( (lp), HASHH, x )
+#define SMC_SET_HASHH(lp, x)	SMC_SET_MAC_CSR( (lp), HASHH, x )
+#define SMC_GET_HASHL(lp, x)	SMC_GET_MAC_CSR( (lp), HASHL, x )
+#define SMC_SET_HASHL(lp, x)	SMC_SET_MAC_CSR( (lp), HASHL, x )
+#define SMC_GET_MII_ACC(lp, x)	SMC_GET_MAC_CSR( (lp), MII_ACC, x )
+#define SMC_SET_MII_ACC(lp, x)	SMC_SET_MAC_CSR( (lp), MII_ACC, x )
+#define SMC_GET_MII_DATA(lp, x)	SMC_GET_MAC_CSR( (lp), MII_DATA, x )
+#define SMC_SET_MII_DATA(lp, x)	SMC_SET_MAC_CSR( (lp), MII_DATA, x )
+#define SMC_GET_FLOW(lp, x)		SMC_GET_MAC_CSR( (lp), FLOW, x )
+#define SMC_SET_FLOW(lp, x)		SMC_SET_MAC_CSR( (lp), FLOW, x )
+#define SMC_GET_VLAN1(lp, x)	SMC_GET_MAC_CSR( (lp), VLAN1, x )
+#define SMC_SET_VLAN1(lp, x)	SMC_SET_MAC_CSR( (lp), VLAN1, x )
+#define SMC_GET_VLAN2(lp, x)	SMC_GET_MAC_CSR( (lp), VLAN2, x )
+#define SMC_SET_VLAN2(lp, x)	SMC_SET_MAC_CSR( (lp), VLAN2, x )
+#define SMC_SET_WUFF(lp, x)		SMC_SET_MAC_CSR( (lp), WUFF, x )
+#define SMC_GET_WUCSR(lp, x)	SMC_GET_MAC_CSR( (lp), WUCSR, x )
+#define SMC_SET_WUCSR(lp, x)	SMC_SET_MAC_CSR( (lp), WUCSR, x )
 
 /* PHY register read/write macros */
-#define SMC_GET_MII(a,phy,v)					\
+#define SMC_GET_MII(lp,a,phy,v)					\
 	do {							\
 		u32 __v;					\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_SET_MII_ACC( ((phy)<<11) | ((a)<<6) |	\
+		SMC_SET_MII_ACC( (lp), ((phy)<<11) | ((a)<<6) |	\
 			MII_ACC_MII_BUSY_);			\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC( (lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_GET_MII_DATA(v);				\
+		SMC_GET_MII_DATA((lp), v);				\
 	} while (0)
-#define SMC_SET_MII(a,phy,v)					\
+#define SMC_SET_MII(lp,a,phy,v)					\
 	do {							\
 		u32 __v;					\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
-		SMC_SET_MII_DATA(v);				\
-		SMC_SET_MII_ACC( ((phy)<<11) | ((a)<<6) |	\
+		SMC_SET_MII_DATA((lp), v);				\
+		SMC_SET_MII_ACC( (lp), ((phy)<<11) | ((a)<<6) |	\
 			MII_ACC_MII_BUSY_	 |		\
 			MII_ACC_MII_WRITE_  );			\
 		do {						\
-			SMC_GET_MII_ACC(__v);			\
+			SMC_GET_MII_ACC((lp), __v);			\
 		} while ( __v & MII_ACC_MII_BUSY_ );		\
 	} while (0)
-#define SMC_GET_PHY_BMCR(phy,x)		SMC_GET_MII( MII_BMCR, phy, x )
-#define SMC_SET_PHY_BMCR(phy,x)		SMC_SET_MII( MII_BMCR, phy, x )
-#define SMC_GET_PHY_BMSR(phy,x)		SMC_GET_MII( MII_BMSR, phy, x )
-#define SMC_GET_PHY_ID1(phy,x)		SMC_GET_MII( MII_PHYSID1, phy, x )
-#define SMC_GET_PHY_ID2(phy,x)		SMC_GET_MII( MII_PHYSID2, phy, x )
-#define SMC_GET_PHY_MII_ADV(phy,x)	SMC_GET_MII( MII_ADVERTISE, phy, x )
-#define SMC_SET_PHY_MII_ADV(phy,x)	SMC_SET_MII( MII_ADVERTISE, phy, x )
-#define SMC_GET_PHY_MII_LPA(phy,x)	SMC_GET_MII( MII_LPA, phy, x )
-#define SMC_SET_PHY_MII_LPA(phy,x)	SMC_SET_MII( MII_LPA, phy, x )
-#define SMC_GET_PHY_CTRL_STS(phy,x)	SMC_GET_MII( PHY_MODE_CTRL_STS, phy, x )
-#define SMC_SET_PHY_CTRL_STS(phy,x)	SMC_SET_MII( PHY_MODE_CTRL_STS, phy, x )
-#define SMC_GET_PHY_INT_SRC(phy,x)	SMC_GET_MII( PHY_INT_SRC, phy, x )
-#define SMC_SET_PHY_INT_SRC(phy,x)	SMC_SET_MII( PHY_INT_SRC, phy, x )
-#define SMC_GET_PHY_INT_MASK(phy,x)	SMC_GET_MII( PHY_INT_MASK, phy, x )
-#define SMC_SET_PHY_INT_MASK(phy,x)	SMC_SET_MII( PHY_INT_MASK, phy, x )
-#define SMC_GET_PHY_SPECIAL(phy,x)	SMC_GET_MII( PHY_SPECIAL, phy, x )
+#define SMC_GET_PHY_BMCR(lp,phy,x)		SMC_GET_MII( (lp), MII_BMCR, phy, x )
+#define SMC_SET_PHY_BMCR(lp,phy,x)		SMC_SET_MII( (lp), MII_BMCR, phy, x )
+#define SMC_GET_PHY_BMSR(lp,phy,x)		SMC_GET_MII( (lp), MII_BMSR, phy, x )
+#define SMC_GET_PHY_ID1(lp,phy,x)		SMC_GET_MII( (lp), MII_PHYSID1, phy, x )
+#define SMC_GET_PHY_ID2(lp,phy,x)		SMC_GET_MII( (lp), MII_PHYSID2, phy, x )
+#define SMC_GET_PHY_MII_ADV(lp,phy,x)	SMC_GET_MII( (lp), MII_ADVERTISE, phy, x )
+#define SMC_SET_PHY_MII_ADV(lp,phy,x)	SMC_SET_MII( (lp), MII_ADVERTISE, phy, x )
+#define SMC_GET_PHY_MII_LPA(lp,phy,x)	SMC_GET_MII( (lp), MII_LPA, phy, x )
+#define SMC_SET_PHY_MII_LPA(lp,phy,x)	SMC_SET_MII( (lp), MII_LPA, phy, x )
+#define SMC_GET_PHY_CTRL_STS(lp,phy,x)	SMC_GET_MII( (lp), PHY_MODE_CTRL_STS, phy, x )
+#define SMC_SET_PHY_CTRL_STS(lp,phy,x)	SMC_SET_MII( (lp), PHY_MODE_CTRL_STS, phy, x )
+#define SMC_GET_PHY_INT_SRC(lp,phy,x)	SMC_GET_MII( (lp), PHY_INT_SRC, phy, x )
+#define SMC_SET_PHY_INT_SRC(lp,phy,x)	SMC_SET_MII( (lp), PHY_INT_SRC, phy, x )
+#define SMC_GET_PHY_INT_MASK(lp,phy,x)	SMC_GET_MII( (lp), PHY_INT_MASK, phy, x )
+#define SMC_SET_PHY_INT_MASK(lp,phy,x)	SMC_SET_MII( (lp), PHY_INT_MASK, phy, x )
+#define SMC_GET_PHY_SPECIAL(lp,phy,x)	SMC_GET_MII( (lp), PHY_SPECIAL, phy, x )
 
 
 
 /* Misc read/write macros */
 
 #ifndef SMC_GET_MAC_ADDR
-#define SMC_GET_MAC_ADDR(addr)					\
+#define SMC_GET_MAC_ADDR(lp, addr)				\
 	do {							\
 		unsigned int __v;				\
 								\
-		SMC_GET_MAC_CSR(ADDRL, __v);			\
+		SMC_GET_MAC_CSR((lp), ADDRL, __v);			\
 		addr[0] = __v; addr[1] = __v >> 8;		\
 		addr[2] = __v >> 16; addr[3] = __v >> 24;	\
-		SMC_GET_MAC_CSR(ADDRH, __v);			\
+		SMC_GET_MAC_CSR((lp), ADDRH, __v);			\
 		addr[4] = __v; addr[5] = __v >> 8;		\
 	} while (0)
 #endif
 
-#define SMC_SET_MAC_ADDR(addr)					\
+#define SMC_SET_MAC_ADDR(lp, addr)				\
 	do {							\
-		 SMC_SET_MAC_CSR(ADDRL,				\
+		 SMC_SET_MAC_CSR((lp), ADDRL,				\
 				 addr[0] |			\
 				(addr[1] << 8) |		\
 				(addr[2] << 16) |		\
 				(addr[3] << 24));		\
-		 SMC_SET_MAC_CSR(ADDRH, addr[4]|(addr[5] << 8));\
+		 SMC_SET_MAC_CSR((lp), ADDRH, addr[4]|(addr[5] << 8));\
 	} while (0)
 
 
-#define SMC_WRITE_EEPROM_CMD(cmd, addr)					\
+#define SMC_WRITE_EEPROM_CMD(lp, cmd, addr)				\
 	do {								\
-		while (SMC_GET_E2P_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
-		SMC_SET_MAC_CMD(MAC_CSR_CMD_R_NOT_W_ | a );		\
-		while (SMC_GET_MAC_CMD() & MAC_CSR_CMD_CSR_BUSY_);	\
+		while (SMC_GET_E2P_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
+		SMC_SET_MAC_CMD((lp), MAC_CSR_CMD_R_NOT_W_ | a );		\
+		while (SMC_GET_MAC_CMD((lp)) & MAC_CSR_CMD_CSR_BUSY_);	\
 	} while (0)
 
 #endif	 /* _SMC911X_H_ */
_
