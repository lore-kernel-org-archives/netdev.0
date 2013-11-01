From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv2 net-next 3/7] smc911x: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 00:27:19 -0400
Message-ID: <1383280043-13552-4-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:45344 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3KAE1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:27:39 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so377761qab.16
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:27:38 -0700 (PDT)
In-Reply-To: <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc911x.c | 331 ++++++++++++++++++------------------
 drivers/net/ethernet/smsc/smc911x.h |   2 +-
 2 files changed, 166 insertions(+), 167 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index afe01c4..0f096a8 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -106,16 +106,16 @@ MODULE_ALIAS("platform:smc911x");
 #define POWER_DOWN		 1
 
 #if SMC_DEBUG > 0
-#define DBG(n, args...)				 \
+#define DBG(n, dev, args...)			 \
 	do {					 \
 		if (SMC_DEBUG & (n))		 \
-			printk(args);		 \
+			netdev_dbg(dev, args);	 \
 	} while (0)
 
-#define PRINTK(args...)   printk(args)
+#define PRINTK(dev, args...)   netdev_info(dev, args)
 #else
-#define DBG(n, args...)   do { } while (0)
-#define PRINTK(args...)   printk(KERN_DEBUG args)
+#define DBG(n, dev, args...)   do { } while (0)
+#define PRINTK(dev, args...)   netdev_dbg(dev, args)
 #endif
 
 #if SMC_DEBUG_PKTS > 0
@@ -130,21 +130,23 @@ static void PRINT_PKT(u_char *buf, int length)
 
 	for (i = 0; i < lines ; i ++) {
 		int cur;
+		printk(KERN_DEBUG);
 		for (cur = 0; cur < 8; cur++) {
 			u_char a, b;
 			a = *buf++;
 			b = *buf++;
-			printk("%02x%02x ", a, b);
+			pr_cont("%02x%02x ", a, b);
 		}
-		printk("\n");
+		pr_cont("\n");
 	}
+	printk(KERN_DEBUG);
 	for (i = 0; i < remainder/2 ; i++) {
 		u_char a, b;
 		a = *buf++;
 		b = *buf++;
-		printk("%02x%02x ", a, b);
+		pr_cont("%02x%02x ", a, b);
 	}
-	printk("\n");
+	pr_cont("\n");
 }
 #else
 #define PRINT_PKT(x...)  do { } while (0)
@@ -176,7 +178,7 @@ static void smc911x_reset(struct net_device *dev)
 	unsigned int reg, timeout=0, resets=1, irq_cfg;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	/*	 Take out of PM setting first */
 	if ((SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_) == 0) {
@@ -188,7 +190,7 @@ static void smc911x_reset(struct net_device *dev)
 			reg = SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_;
 		} while (--timeout && !reg);
 		if (timeout == 0) {
-			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
+			PRINTK(dev, "smc911x_reset timeout waiting for PM restore\n");
 			return;
 		}
 	}
@@ -206,14 +208,14 @@ static void smc911x_reset(struct net_device *dev)
 			reg = SMC_GET_HW_CFG(lp);
 			/* If chip indicates reset timeout then try again */
 			if (reg & HW_CFG_SRST_TO_) {
-				PRINTK("%s: chip reset timeout, retrying...\n", dev->name);
+				PRINTK(dev, "chip reset timeout, retrying...\n");
 				resets++;
 				break;
 			}
 		} while (--timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout == 0) {
-		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
+		PRINTK(dev, "smc911x_reset timeout waiting for reset\n");
 		return;
 	}
 
@@ -223,7 +225,7 @@ static void smc911x_reset(struct net_device *dev)
 		udelay(10);
 
 	if (timeout == 0){
-		PRINTK("%s: smc911x_reset timeout waiting for EEPROM busy\n", dev->name);
+		PRINTK(dev, "smc911x_reset timeout waiting for EEPROM busy\n");
 		return;
 	}
 
@@ -270,7 +272,7 @@ static void smc911x_enable(struct net_device *dev)
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -296,7 +298,7 @@ static void smc911x_enable(struct net_device *dev)
 
 	/* Turn on receiver and enable RX */
 	if (cr & MAC_CR_RXEN_)
-		DBG(SMC_DEBUG_RX, "%s: Receiver already enabled\n", dev->name);
+		DBG(SMC_DEBUG_RX, dev, "Receiver already enabled\n");
 
 	SMC_SET_MAC_CR(lp, cr | MAC_CR_RXEN_);
 
@@ -327,7 +329,7 @@ static void smc911x_shutdown(struct net_device *dev)
 	unsigned cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "%s: --> %s\n", CARDNAME, __func__);
 
 	/* Disable IRQ's */
 	SMC_SET_INT_EN(lp, 0);
@@ -346,7 +348,8 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int fifo_count, timeout, reg;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __func__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, dev, "%s: --> %s\n",
+	    CARDNAME, __func__);
 	fifo_count = SMC_GET_RX_FIFO_INF(lp) & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
@@ -361,7 +364,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 			reg = SMC_GET_RX_DP_CTRL(lp) & RX_DP_CTRL_FFWD_BUSY_;
 		} while (--timeout && reg);
 		if (timeout == 0) {
-			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
+			PRINTK(dev, "timeout waiting for RX fast forward\n");
 		}
 	}
 }
@@ -379,11 +382,11 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	struct sk_buff *skb;
 	unsigned char *data;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
-		dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, dev, "--> %s\n",
+	    __func__);
 	status = SMC_GET_RX_STS_FIFO(lp);
-	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x\n",
-		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
+	DBG(SMC_DEBUG_RX, dev, "Rx pkt len %d status 0x%08x\n",
+	    (status & 0x3fff0000) >> 16, status & 0xc000ffff);
 	pkt_len = (status & RX_STS_PKT_LEN_) >> 16;
 	if (status & RX_STS_ES_) {
 		/* Deal with a bad packet */
@@ -403,8 +406,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		/* Alloc a buffer with extra room for DMA alignment */
 		skb = netdev_alloc_skb(dev, pkt_len+32);
 		if (unlikely(skb == NULL)) {
-			PRINTK( "%s: Low memory, rcvd packet dropped.\n",
-				dev->name);
+			PRINTK(dev, "Low memory, rcvd packet dropped.\n");
 			dev->stats.rx_dropped++;
 			smc911x_drop_pkt(dev);
 			return;
@@ -422,8 +424,8 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		/* Lower the FIFO threshold if possible */
 		fifo = SMC_GET_FIFO_INT(lp);
 		if (fifo & 0xFF) fifo--;
-		DBG(SMC_DEBUG_RX, "%s: Setting RX stat FIFO threshold to %d\n",
-			dev->name, fifo & 0xff);
+		DBG(SMC_DEBUG_RX, dev, "Setting RX stat FIFO threshold to %d\n",
+		    fifo & 0xff);
 		SMC_SET_FIFO_INT(lp, fifo);
 		/* Setup RX DMA */
 		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN16_ | ((2<<8) & RX_CFG_RXDOFF_));
@@ -436,7 +438,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		SMC_SET_RX_CFG(lp, RX_CFG_RX_END_ALGN4_ | ((2<<8) & RX_CFG_RXDOFF_));
 		SMC_PULL_DATA(lp, data, pkt_len+2+3);
 
-		DBG(SMC_DEBUG_PKTS, "%s: Received packet\n", dev->name);
+		DBG(SMC_DEBUG_PKTS, dev, "Received packet\n");
 		PRINT_PKT(data, ((pkt_len - 4) <= 64) ? pkt_len - 4 : 64);
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
@@ -456,7 +458,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	unsigned int cmdA, cmdB, len;
 	unsigned char *buf;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, dev, "--> %s\n", __func__);
 	BUG_ON(lp->pending_tx_skb == NULL);
 
 	skb = lp->pending_tx_skb;
@@ -481,12 +483,12 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	/* tag is packet length so we can use this in stats update later */
 	cmdB = (skb->len  << 16) | (skb->len & 0x7FF);
 
-	DBG(SMC_DEBUG_TX, "%s: TX PKT LENGTH 0x%04x (%d) BUF 0x%p CMDA 0x%08x CMDB 0x%08x\n",
-		 dev->name, len, len, buf, cmdA, cmdB);
+	DBG(SMC_DEBUG_TX, dev, "TX PKT LENGTH 0x%04x (%d) BUF 0x%p CMDA 0x%08x CMDB 0x%08x\n",
+	    len, len, buf, cmdA, cmdB);
 	SMC_SET_TX_FIFO(lp, cmdA);
 	SMC_SET_TX_FIFO(lp, cmdB);
 
-	DBG(SMC_DEBUG_PKTS, "%s: Transmitted packet\n", dev->name);
+	DBG(SMC_DEBUG_PKTS, dev, "Transmitted packet\n");
 	PRINT_PKT(buf, len <= 64 ? len : 64);
 
 	/* Send pkt via PIO or DMA */
@@ -517,20 +519,20 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int free;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, dev, "--> %s\n",
+	    __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
 	free = SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TDFREE_;
-	DBG(SMC_DEBUG_TX, "%s: TX free space %d\n", dev->name, free);
+	DBG(SMC_DEBUG_TX, dev, "TX free space %d\n", free);
 
 	/* Turn off the flow when running out of space in FIFO */
 	if (free <= SMC911X_TX_FIFO_LOW_THRESHOLD) {
-		DBG(SMC_DEBUG_TX, "%s: Disabling data flow due to low FIFO space (%d)\n",
-			dev->name, free);
+		DBG(SMC_DEBUG_TX, dev, "Disabling data flow due to low FIFO space (%d)\n",
+		    free);
 		/* Reenable when at least 1 packet of size MTU present */
 		SMC_SET_FIFO_TDA(lp, (SMC911X_TX_FIFO_LOW_THRESHOLD)/64);
 		lp->tx_throttle = 1;
@@ -545,8 +547,8 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *	  End padding				 15 bytes
 	 */
 	if (unlikely(free < (skb->len + 8 + 15 + 15))) {
-		printk("%s: No Tx free space %d < %d\n",
-			dev->name, free, skb->len);
+		netdev_warn(dev, "No Tx free space %d < %d\n",
+			    free, skb->len);
 		lp->pending_tx_skb = NULL;
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
@@ -561,13 +563,13 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * the DMA IRQ starts it
 		 */
 		if (lp->txdma_active) {
-			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: Tx DMA running, deferring packet\n", dev->name);
+			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev, "Tx DMA running, deferring packet\n");
 			lp->pending_tx_skb = skb;
 			netif_stop_queue(dev);
 			spin_unlock_irqrestore(&lp->lock, flags);
 			return NETDEV_TX_OK;
 		} else {
-			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: Activating Tx DMA\n", dev->name);
+			DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev, "Activating Tx DMA\n");
 			lp->txdma_active = 1;
 		}
 	}
@@ -589,20 +591,19 @@ static void smc911x_tx(struct net_device *dev)
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int tx_status;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, dev, "--> %s\n",
+	    __func__);
 
 	/* Collect the TX status */
 	while (((SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
-		DBG(SMC_DEBUG_TX, "%s: Tx stat FIFO used 0x%04x\n",
-			dev->name,
-			(SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16);
+		DBG(SMC_DEBUG_TX, dev, "Tx stat FIFO used 0x%04x\n",
+		    (SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16);
 		tx_status = SMC_GET_TX_STS_FIFO(lp);
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes+=tx_status>>16;
-		DBG(SMC_DEBUG_TX, "%s: Tx FIFO tag 0x%04x status 0x%04x\n",
-			dev->name, (tx_status & 0xffff0000) >> 16,
-			tx_status & 0x0000ffff);
+		DBG(SMC_DEBUG_TX, dev, "Tx FIFO tag 0x%04x status 0x%04x\n",
+		    (tx_status & 0xffff0000) >> 16,
+		    tx_status & 0x0000ffff);
 		/* count Tx errors, but ignore lost carrier errors when in
 		 * full-duplex mode */
 		if ((tx_status & TX_STS_ES_) && !(lp->ctl_rfduplx &&
@@ -640,8 +641,8 @@ static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 
 	SMC_GET_MII(lp, phyreg, phyaddr, phydata);
 
-	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
-		__func__, phyaddr, phyreg, phydata);
+	DBG(SMC_DEBUG_MISC, dev, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
+	    __func__, phyaddr, phyreg, phydata);
 	return phydata;
 }
 
@@ -654,8 +655,8 @@ static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__func__, phyaddr, phyreg, phydata);
+	DBG(SMC_DEBUG_MISC, dev, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
+	    __func__, phyaddr, phyreg, phydata);
 
 	SMC_SET_MII(lp, phyreg, phyaddr, phydata);
 }
@@ -670,7 +671,7 @@ static void smc911x_phy_detect(struct net_device *dev)
 	int phyaddr;
 	unsigned int cfg, id1, id2;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	lp->phy_type = 0;
 
@@ -731,8 +732,8 @@ static void smc911x_phy_detect(struct net_device *dev)
 			lp->phy_type = id1 << 16 | id2;
 	}
 
-	DBG(SMC_DEBUG_MISC, "%s: phy_id1=0x%x, phy_id2=0x%x phyaddr=0x%d\n",
-		dev->name, id1, id2, lp->mii.phy_id);
+	DBG(SMC_DEBUG_MISC, dev, "phy_id1=0x%x, phy_id2=0x%x phyaddr=0x%d\n",
+	    id1, id2, lp->mii.phy_id);
 }
 
 /*
@@ -745,7 +746,7 @@ static int smc911x_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	/* Enter Link Disable state */
 	SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
@@ -792,7 +793,7 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
 	unsigned long flags;
 	unsigned int reg;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s()\n", __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	reg = SMC_GET_PMT_CTRL(lp);
@@ -851,18 +852,18 @@ static void smc911x_phy_check_media(struct net_device *dev, int init)
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
 		SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
 		SMC_GET_MAC_CR(lp, cr);
 		if (lp->mii.full_duplex) {
-			DBG(SMC_DEBUG_MISC, "%s: Configuring for full-duplex mode\n", dev->name);
+			DBG(SMC_DEBUG_MISC, dev, "Configuring for full-duplex mode\n");
 			bmcr |= BMCR_FULLDPLX;
 			cr |= MAC_CR_RCVOWN_;
 		} else {
-			DBG(SMC_DEBUG_MISC, "%s: Configuring for half-duplex mode\n", dev->name);
+			DBG(SMC_DEBUG_MISC, dev, "Configuring for half-duplex mode\n");
 			bmcr &= ~BMCR_FULLDPLX;
 			cr &= ~MAC_CR_RCVOWN_;
 		}
@@ -891,7 +892,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	int status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s()\n", __func__);
 
 	/*
 	 * We should not be called if phy_type is zero.
@@ -900,7 +901,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 		return;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
-		printk("%s: PHY reset timed out\n", dev->name);
+		netdev_info(dev, "PHY reset timed out\n");
 		return;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
@@ -922,7 +923,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	/* Copy our capabilities from MII_BMSR to MII_ADVERTISE */
 	SMC_GET_PHY_BMSR(lp, phyaddr, my_phy_caps);
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
-		printk(KERN_INFO "Auto negotiation NOT supported\n");
+		netdev_info(dev, "Auto negotiation NOT supported\n");
 		smc911x_phy_fixed(dev);
 		goto smc911x_phy_configure_exit;
 	}
@@ -960,8 +961,8 @@ static void smc911x_phy_configure(struct work_struct *work)
 	udelay(10);
 	SMC_GET_PHY_MII_ADV(lp, phyaddr, status);
 
-	DBG(SMC_DEBUG_MISC, "%s: phy caps=0x%04x\n", dev->name, my_phy_caps);
-	DBG(SMC_DEBUG_MISC, "%s: phy advertised caps=0x%04x\n", dev->name, my_ad_caps);
+	DBG(SMC_DEBUG_MISC, dev, "phy caps=0x%04x\n", my_phy_caps);
+	DBG(SMC_DEBUG_MISC, dev, "phy advertised caps=0x%04x\n", my_ad_caps);
 
 	/* Restart auto-negotiation process in order to advertise my caps */
 	SMC_SET_PHY_BMCR(lp, phyaddr, BMCR_ANENABLE | BMCR_ANRESTART);
@@ -984,7 +985,7 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -992,10 +993,10 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 	smc911x_phy_check_media(dev, 0);
 	/* read to clear status bits */
 	SMC_GET_PHY_INT_SRC(lp, phyaddr,status);
-	DBG(SMC_DEBUG_MISC, "%s: PHY interrupt status 0x%04x\n",
-		dev->name, status & 0xffff);
-	DBG(SMC_DEBUG_MISC, "%s: AFC_CFG 0x%08x\n",
-		dev->name, SMC_GET_AFC_CFG(lp));
+	DBG(SMC_DEBUG_MISC, dev, "PHY interrupt status 0x%04x\n",
+	    status & 0xffff);
+	DBG(SMC_DEBUG_MISC, dev, "AFC_CFG 0x%08x\n",
+	    SMC_GET_AFC_CFG(lp));
 }
 
 /*--- END PHY CONTROL AND CONFIGURATION-------------------------------------*/
@@ -1012,7 +1013,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	unsigned int rx_overrun=0, cr, pkts;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1033,8 +1034,8 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	do {
 		status = SMC_GET_INT(lp);
 
-		DBG(SMC_DEBUG_MISC, "%s: INT 0x%08x MASK 0x%08x OUTSIDE MASK 0x%08x\n",
-			dev->name, status, mask, status & ~mask);
+		DBG(SMC_DEBUG_MISC, dev, "INT 0x%08x MASK 0x%08x OUTSIDE MASK 0x%08x\n",
+		    status, mask, status & ~mask);
 
 		status &= mask;
 		if (!status)
@@ -1066,7 +1067,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 				SMC_GET_MAC_CR(lp, cr);
 				cr &= ~MAC_CR_RXEN_;
 				SMC_SET_MAC_CR(lp, cr);
-				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
+				DBG(SMC_DEBUG_RX, dev, "RX overrun\n");
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
@@ -1078,7 +1079,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 				cr &= ~MAC_CR_RXEN_;
 				SMC_SET_MAC_CR(lp, cr);
 				rx_overrun=1;
-				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
+				DBG(SMC_DEBUG_RX, dev, "RX overrun\n");
 				dev->stats.rx_errors++;
 				dev->stats.rx_fifo_errors++;
 			}
@@ -1087,23 +1088,23 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		/* Handle receive condition */
 		if ((status & INT_STS_RSFL_) || rx_overrun) {
 			unsigned int fifo;
-			DBG(SMC_DEBUG_RX, "%s: RX irq\n", dev->name);
+			DBG(SMC_DEBUG_RX, dev, "RX irq\n");
 			fifo = SMC_GET_RX_FIFO_INF(lp);
 			pkts = (fifo & RX_FIFO_INF_RXSUSED_) >> 16;
-			DBG(SMC_DEBUG_RX, "%s: Rx FIFO pkts %d, bytes %d\n",
-				dev->name, pkts, fifo & 0xFFFF );
+			DBG(SMC_DEBUG_RX, dev, "Rx FIFO pkts %d, bytes %d\n",
+			    pkts, fifo & 0xFFFF);
 			if (pkts != 0) {
 #ifdef SMC_USE_DMA
 				unsigned int fifo;
 				if (lp->rxdma_active){
-					DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA,
-						"%s: RX DMA active\n", dev->name);
+					DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, dev,
+					    "RX DMA active\n");
 					/* The DMA is already running so up the IRQ threshold */
 					fifo = SMC_GET_FIFO_INT(lp) & ~0xFF;
 					fifo |= pkts & 0xFF;
-					DBG(SMC_DEBUG_RX,
-						"%s: Setting RX stat FIFO threshold to %d\n",
-						dev->name, fifo & 0xff);
+					DBG(SMC_DEBUG_RX, dev,
+					    "Setting RX stat FIFO threshold to %d\n",
+					    fifo & 0xff);
 					SMC_SET_FIFO_INT(lp, fifo);
 				} else
 #endif
@@ -1113,7 +1114,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		}
 		/* Handle transmit FIFO available */
 		if (status & INT_STS_TDFA_) {
-			DBG(SMC_DEBUG_TX, "%s: TX data FIFO space available irq\n", dev->name);
+			DBG(SMC_DEBUG_TX, dev, "TX data FIFO space available irq\n");
 			SMC_SET_FIFO_TDA(lp, 0xFF);
 			lp->tx_throttle = 0;
 #ifdef SMC_USE_DMA
@@ -1125,9 +1126,9 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		/* Handle transmit done condition */
 #if 1
 		if (status & (INT_STS_TSFL_ | INT_STS_GPT_INT_)) {
-			DBG(SMC_DEBUG_TX | SMC_DEBUG_MISC,
-				"%s: Tx stat FIFO limit (%d) /GPT irq\n",
-				dev->name, (SMC_GET_FIFO_INT(lp) & 0x00ff0000) >> 16);
+			DBG(SMC_DEBUG_TX | SMC_DEBUG_MISC, dev,
+			    "Tx stat FIFO limit (%d) /GPT irq\n",
+			    (SMC_GET_FIFO_INT(lp) & 0x00ff0000) >> 16);
 			smc911x_tx(dev);
 			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
 			SMC_ACK_INT(lp, INT_STS_TSFL_);
@@ -1135,23 +1136,20 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		}
 #else
 		if (status & INT_STS_TSFL_) {
-			DBG(SMC_DEBUG_TX, "%s: TX status FIFO limit (%d) irq\n", dev->name, );
+			DBG(SMC_DEBUG_TX, dev, "TX status FIFO limit (%d) irq\n", ?);
 			smc911x_tx(dev);
 			SMC_ACK_INT(lp, INT_STS_TSFL_);
 		}
 
 		if (status & INT_STS_GPT_INT_) {
-			DBG(SMC_DEBUG_RX, "%s: IRQ_CFG 0x%08x FIFO_INT 0x%08x RX_CFG 0x%08x\n",
-				dev->name,
-				SMC_GET_IRQ_CFG(lp),
-				SMC_GET_FIFO_INT(lp),
-				SMC_GET_RX_CFG(lp));
-			DBG(SMC_DEBUG_RX, "%s: Rx Stat FIFO Used 0x%02x "
-				"Data FIFO Used 0x%04x Stat FIFO 0x%08x\n",
-				dev->name,
-				(SMC_GET_RX_FIFO_INF(lp) & 0x00ff0000) >> 16,
-				SMC_GET_RX_FIFO_INF(lp) & 0xffff,
-				SMC_GET_RX_STS_FIFO_PEEK(lp));
+			DBG(SMC_DEBUG_RX, dev, "IRQ_CFG 0x%08x FIFO_INT 0x%08x RX_CFG 0x%08x\n",
+			    SMC_GET_IRQ_CFG(lp),
+			    SMC_GET_FIFO_INT(lp),
+			    SMC_GET_RX_CFG(lp));
+			DBG(SMC_DEBUG_RX, dev, "Rx Stat FIFO Used 0x%02x Data FIFO Used 0x%04x Stat FIFO 0x%08x\n",
+			    (SMC_GET_RX_FIFO_INF(lp) & 0x00ff0000) >> 16,
+			    SMC_GET_RX_FIFO_INF(lp) & 0xffff,
+			    SMC_GET_RX_STS_FIFO_PEEK(lp));
 			SMC_SET_GPT_CFG(lp, GPT_CFG_TIMER_EN_ | 10000);
 			SMC_ACK_INT(lp, INT_STS_GPT_INT_);
 		}
@@ -1159,7 +1157,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 
 		/* Handle PHY interrupt condition */
 		if (status & INT_STS_PHY_INT_) {
-			DBG(SMC_DEBUG_MISC, "%s: PHY irq\n", dev->name);
+			DBG(SMC_DEBUG_MISC, dev, "PHY irq\n");
 			smc911x_phy_interrupt(dev);
 			SMC_ACK_INT(lp, INT_STS_PHY_INT_);
 		}
@@ -1168,8 +1166,8 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	/* restore mask state */
 	SMC_SET_INT_EN(lp, mask);
 
-	DBG(SMC_DEBUG_MISC, "%s: Interrupt done (%d loops)\n",
-		dev->name, 8-timeout);
+	DBG(SMC_DEBUG_MISC, dev, "Interrupt done (%d loops)\n",
+	    8-timeout);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -1185,9 +1183,9 @@ smc911x_tx_dma_irq(int dma, void *data)
 	struct sk_buff *skb = lp->current_tx_skb;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
-	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: TX DMA irq handler\n", dev->name);
+	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev, "TX DMA irq handler\n");
 	/* Clear the DMA interrupt sources */
 	SMC_DMA_ACK_IRQ(dev, dma);
 	BUG_ON(skb == NULL);
@@ -1198,8 +1196,8 @@ smc911x_tx_dma_irq(int dma, void *data)
 	if (lp->pending_tx_skb != NULL)
 		smc911x_hardware_send_pkt(dev);
 	else {
-		DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA,
-			"%s: No pending Tx packets. DMA disabled\n", dev->name);
+		DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev,
+		    "No pending Tx packets. DMA disabled\n");
 		spin_lock_irqsave(&lp->lock, flags);
 		lp->txdma_active = 0;
 		if (!lp->tx_throttle) {
@@ -1208,8 +1206,8 @@ smc911x_tx_dma_irq(int dma, void *data)
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 
-	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA,
-		"%s: TX DMA irq completed\n", dev->name);
+	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev,
+	    "TX DMA irq completed\n");
 }
 static void
 smc911x_rx_dma_irq(int dma, void *data)
@@ -1221,8 +1219,8 @@ smc911x_rx_dma_irq(int dma, void *data)
 	unsigned long flags;
 	unsigned int pkts;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
-	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, "%s: RX DMA irq handler\n", dev->name);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
+	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, dev, "RX DMA irq handler\n");
 	/* Clear the DMA interrupt sources */
 	SMC_DMA_ACK_IRQ(dev, dma);
 	dma_unmap_single(NULL, rx_dmabuf, rx_dmalen, DMA_FROM_DEVICE);
@@ -1242,9 +1240,9 @@ smc911x_rx_dma_irq(int dma, void *data)
 		lp->rxdma_active = 0;
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA,
-		"%s: RX DMA irq completed. DMA RX FIFO PKTS %d\n",
-		dev->name, pkts);
+	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, dev,
+	    "RX DMA irq completed. DMA RX FIFO PKTS %d\n",
+	    pkts);
 }
 #endif	 /* SMC_USE_DMA */
 
@@ -1268,14 +1266,14 @@ static void smc911x_timeout(struct net_device *dev)
 	int status, mask;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	status = SMC_GET_INT(lp);
 	mask = SMC_GET_INT_EN(lp);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	DBG(SMC_DEBUG_MISC, "%s: INT 0x%02x MASK 0x%02x\n",
-		dev->name, status, mask);
+	DBG(SMC_DEBUG_MISC, dev, "INT 0x%02x MASK 0x%02x\n",
+	    status, mask);
 
 	/* Dump the current TX FIFO contents and restart */
 	mask = SMC_GET_TX_CFG(lp);
@@ -1306,7 +1304,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(lp, mcr);
@@ -1314,7 +1312,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 
-		DBG(SMC_DEBUG_MISC, "%s: RCR_PRMS\n", dev->name);
+		DBG(SMC_DEBUG_MISC, dev, "RCR_PRMS\n");
 		mcr |= MAC_CR_PRMS_;
 	}
 	/*
@@ -1323,7 +1321,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	 * checked before the table is
 	 */
 	else if (dev->flags & IFF_ALLMULTI || netdev_mc_count(dev) > 16) {
-		DBG(SMC_DEBUG_MISC, "%s: RCR_ALMUL\n", dev->name);
+		DBG(SMC_DEBUG_MISC, dev, "RCR_ALMUL\n");
 		mcr |= MAC_CR_MCPAS_;
 	}
 
@@ -1363,8 +1361,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 		/* now, the table can be loaded into the chipset */
 		update_multicast = 1;
 	} else	 {
-		DBG(SMC_DEBUG_MISC, "%s: ~(MAC_CR_PRMS_|MAC_CR_MCPAS_)\n",
-			dev->name);
+		DBG(SMC_DEBUG_MISC, dev, "~(MAC_CR_PRMS_|MAC_CR_MCPAS_)\n");
 		mcr &= ~(MAC_CR_PRMS_ | MAC_CR_MCPAS_);
 
 		/*
@@ -1378,9 +1375,9 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_SET_MAC_CR(lp, mcr);
 	if (update_multicast) {
-		DBG(SMC_DEBUG_MISC,
-			"%s: update mcast hash table 0x%08x 0x%08x\n",
-			dev->name, multicast_table[0], multicast_table[1]);
+		DBG(SMC_DEBUG_MISC, dev,
+		    "update mcast hash table 0x%08x 0x%08x\n",
+		    multicast_table[0], multicast_table[1]);
 		SMC_SET_HASHL(lp, multicast_table[0]);
 		SMC_SET_HASHH(lp, multicast_table[1]);
 	}
@@ -1398,7 +1395,7 @@ smc911x_open(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	/* reset the hardware */
 	smc911x_reset(dev);
@@ -1425,7 +1422,7 @@ static int smc911x_close(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1459,7 +1456,7 @@ smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret, status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
 
@@ -1597,16 +1594,16 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 	e2p_cmd = SMC_GET_E2P_CMD(lp);
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
-			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
-				dev->name, __func__);
+			PRINTK(dev, "%s timeout waiting for EEPROM to respond\n",
+			       __func__);
 			return -EFAULT;
 		}
 		mdelay(1);
 		e2p_cmd = SMC_GET_E2P_CMD(lp);
 	}
 	if (timeout == 0) {
-		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
-			dev->name, __func__);
+		PRINTK(dev, "%s timeout waiting for EEPROM CMD not busy\n",
+		       __func__);
 		return -ETIMEDOUT;
 	}
 	return 0;
@@ -1719,7 +1716,7 @@ static int smc911x_findirq(struct net_device *dev)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	cookie = probe_irq_on();
 
@@ -1799,13 +1796,14 @@ static int smc911x_probe(struct net_device *dev)
 	const char *version_string;
 	unsigned long irq_flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
+	DBG(SMC_DEBUG_FUNC, dev, "--> %s\n", __func__);
 
 	/* First, see if the endian word is recognized */
 	val = SMC_GET_BYTE_TEST(lp);
-	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
+	DBG(SMC_DEBUG_MISC, dev, "%s: endian probe returned 0x%04x\n",
+	    CARDNAME, val);
 	if (val != 0x87654321) {
-		printk(KERN_ERR "Invalid chip endian 0x%08x\n",val);
+		netdev_err(dev, "Invalid chip endian 0x%08x\n", val);
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -1816,26 +1814,29 @@ static int smc911x_probe(struct net_device *dev)
 	 * as future revisions could be added.
 	 */
 	chip_id = SMC_GET_PN(lp);
-	DBG(SMC_DEBUG_MISC, "%s: id probe returned 0x%04x\n", CARDNAME, chip_id);
+	DBG(SMC_DEBUG_MISC, dev, "%s: id probe returned 0x%04x\n",
+	    CARDNAME, chip_id);
 	for(i=0;chip_ids[i].id != 0; i++) {
 		if (chip_ids[i].id == chip_id) break;
 	}
 	if (!chip_ids[i].id) {
-		printk(KERN_ERR "Unknown chip ID %04x\n", chip_id);
+		netdev_err(dev, "Unknown chip ID %04x\n", chip_id);
 		retval = -ENODEV;
 		goto err_out;
 	}
 	version_string = chip_ids[i].name;
 
 	revision = SMC_GET_REV(lp);
-	DBG(SMC_DEBUG_MISC, "%s: revision = 0x%04x\n", CARDNAME, revision);
+	DBG(SMC_DEBUG_MISC, dev, "%s: revision = 0x%04x\n", CARDNAME, revision);
 
 	/* At this point I'll assume that the chip is an SMC911x. */
-	DBG(SMC_DEBUG_MISC, "%s: Found a %s\n", CARDNAME, chip_ids[i].name);
+	DBG(SMC_DEBUG_MISC, dev, "%s: Found a %s\n",
+	    CARDNAME, chip_ids[i].name);
 
 	/* Validate the TX FIFO size requested */
 	if ((tx_fifo_kb < 2) || (tx_fifo_kb > 14)) {
-		printk(KERN_ERR "Invalid TX FIFO size requested %d\n", tx_fifo_kb);
+		netdev_err(dev, "Invalid TX FIFO size requested %d\n",
+			   tx_fifo_kb);
 		retval = -EINVAL;
 		goto err_out;
 	}
@@ -1887,14 +1888,13 @@ static int smc911x_probe(struct net_device *dev)
 		case 14:/* 1920 Rx Data Fifo Size */
 			lp->afc_cfg=0x0006032F;break;
 		 default:
-			 PRINTK("%s: ERROR -- no AFC_CFG setting found",
-				dev->name);
+			 PRINTK(dev, "ERROR -- no AFC_CFG setting found");
 			 break;
 	}
 
-	DBG(SMC_DEBUG_MISC | SMC_DEBUG_TX | SMC_DEBUG_RX,
-		"%s: tx_fifo %d rx_fifo %d afc_cfg 0x%08x\n", CARDNAME,
-		lp->tx_fifo_size, lp->rx_fifo_size, lp->afc_cfg);
+	DBG(SMC_DEBUG_MISC | SMC_DEBUG_TX | SMC_DEBUG_RX, dev,
+	    "%s: tx_fifo %d rx_fifo %d afc_cfg 0x%08x\n", CARDNAME,
+	    lp->tx_fifo_size, lp->rx_fifo_size, lp->afc_cfg);
 
 	spin_lock_init(&lp->lock);
 
@@ -1924,8 +1924,7 @@ static int smc911x_probe(struct net_device *dev)
 		}
 	}
 	if (dev->irq == 0) {
-		printk("%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
-			dev->name);
+		netdev_warn(dev, "Couldn't autodetect your IRQ. Use irq=xx.\n");
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -1980,33 +1979,32 @@ static int smc911x_probe(struct net_device *dev)
 	retval = register_netdev(dev);
 	if (retval == 0) {
 		/* now, print out the card info, in a short format.. */
-		printk("%s: %s (rev %d) at %#lx IRQ %d",
-			dev->name, version_string, lp->revision,
-			dev->base_addr, dev->irq);
+		netdev_info(dev, "%s (rev %d) at %#lx IRQ %d",
+			    version_string, lp->revision,
+			    dev->base_addr, dev->irq);
 
 #ifdef SMC_USE_DMA
 		if (lp->rxdma != -1)
-			printk(" RXDMA %d ", lp->rxdma);
+			pr_cont(" RXDMA %d", lp->rxdma);
 
 		if (lp->txdma != -1)
-			printk("TXDMA %d", lp->txdma);
+			pr_cont(" TXDMA %d", lp->txdma);
 #endif
-		printk("\n");
+		pr_cont("\n");
 		if (!is_valid_ether_addr(dev->dev_addr)) {
-			printk("%s: Invalid ethernet MAC address. Please "
-					"set using ifconfig\n", dev->name);
+			netdev_warn(dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: %pM\n",
-				dev->name, dev->dev_addr);
+			netdev_info(dev, "Ethernet addr: %pM\n",
+				    dev->dev_addr);
 		}
 
 		if (lp->phy_type == 0) {
-			PRINTK("%s: No PHY found\n", dev->name);
+			PRINTK(dev, "No PHY found\n");
 		} else if ((lp->phy_type & ~0xff) == LAN911X_INTERNAL_PHY_ID) {
-			PRINTK("%s: LAN911x Internal PHY\n", dev->name);
+			PRINTK(dev, "LAN911x Internal PHY\n");
 		} else {
-			PRINTK("%s: External PHY 0x%08x\n", dev->name, lp->phy_type);
+			PRINTK(dev, "External PHY 0x%08x\n", lp->phy_type);
 		}
 	}
 
@@ -2025,7 +2023,7 @@ err_out:
 }
 
 /*
- * smc911x_init(void)
+ * smc911x_drv_probe(void)
  *
  *	  Output:
  *	 0 --> there is a device
@@ -2039,6 +2037,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	void __iomem *addr;
 	int ret;
 
+	/* ndev is not valid yet, so avoid passing it in. */
 	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __func__);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
@@ -2093,7 +2092,7 @@ release_both:
 release_1:
 		release_mem_region(res->start, SMC911X_IO_EXTENT);
 out:
-		printk("%s: not found (%d).\n", CARDNAME, ret);
+		pr_info("%s: not found (%d).\n", CARDNAME, ret);
 	}
 #ifdef SMC_USE_DMA
 	else {
@@ -2111,7 +2110,7 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 	struct smc911x_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
+	DBG(SMC_DEBUG_FUNC, ndev, "--> %s\n", __func__);
 
 	unregister_netdev(ndev);
 
@@ -2140,7 +2139,7 @@ static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 	struct net_device *ndev = platform_get_drvdata(dev);
 	struct smc911x_local *lp = netdev_priv(ndev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
+	DBG(SMC_DEBUG_FUNC, ndev, "--> %s\n", __func__);
 	if (ndev) {
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
@@ -2158,7 +2157,7 @@ static int smc911x_drv_resume(struct platform_device *dev)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
+	DBG(SMC_DEBUG_FUNC, ndev, "--> %s\n", __func__);
 	if (ndev) {
 		struct smc911x_local *lp = netdev_priv(ndev);
 
diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
index d51261b..9965da3 100644
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -227,7 +227,7 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 #define SMC_DMA_ACK_IRQ(dev, dma)					\
 {									\
 	if (DCSR(dma) & DCSR_BUSERR) {					\
-		printk("%s: DMA %d bus error!\n", dev->name, dma);	\
+		netdev_err(dev, "DMA %d bus error!\n", dma);		\
 	}								\
 	DCSR(dma) = DCSR_STARTINTR|DCSR_ENDINTR|DCSR_BUSERR;		\
 }
-- 
1.8.4.2
