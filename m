From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCHv2 net-next 2/7] smc91x: replace printk with netdev_ calls
Date: Fri,  1 Nov 2013 00:27:18 -0400
Message-ID: <1383280043-13552-3-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
 <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:34741 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3KAE1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:27:36 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so379846qab.9
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 21:27:35 -0700 (PDT)
In-Reply-To: <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 237 ++++++++++++++++++-------------------
 drivers/net/ethernet/smsc/smc91x.h |   4 +-
 2 files changed, 118 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 73be7f3..0c9b5d9 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -58,7 +58,7 @@
  *   22/09/04  Nicolas Pitre      big update (see commit log for details)
  */
 static const char version[] =
-	"smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@fluxnic.net>\n";
+	"smc91x.c: v1.1, sep 22 2004 by Nicolas Pitre <nico@fluxnic.net>";
 
 /* Debugging level */
 #ifndef SMC_DEBUG
@@ -149,16 +149,16 @@ MODULE_ALIAS("platform:smc91x");
 #define MII_DELAY		1
 
 #if SMC_DEBUG > 0
-#define DBG(n, args...)					\
+#define DBG(n, dev, args...)				\
 	do {						\
 		if (SMC_DEBUG >= (n))			\
-			printk(args);	\
+			netdev_dbg(dev, args);		\
 	} while (0)
 
-#define PRINTK(args...)   printk(args)
+#define PRINTK(dev, args...)   netdev_info(dev, args)
 #else
-#define DBG(n, args...)   do { } while(0)
-#define PRINTK(args...)   printk(KERN_DEBUG args)
+#define DBG(n, dev, args...)   do { } while (0)
+#define PRINTK(dev, args...)   netdev_dbg(dev, args)
 #endif
 
 #if SMC_DEBUG > 3
@@ -173,24 +173,26 @@ static void PRINT_PKT(u_char *buf, int length)
 
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
-#define PRINT_PKT(x...)  do { } while(0)
+#define PRINT_PKT(x...)  do { } while (0)
 #endif
 
 
@@ -226,8 +228,8 @@ static void PRINT_PKT(u_char *buf, int length)
 		unsigned long timeout = jiffies + 2;			\
 		while (SMC_GET_MMU_CMD(lp) & MC_BUSY) {		\
 			if (time_after(jiffies, timeout)) {		\
-				printk("%s: timeout %s line %d\n",	\
-					dev->name, __FILE__, __LINE__);	\
+				netdev_dbg(dev, "timeout %s line %d\n",	\
+					   __FILE__, __LINE__);		\
 				break;					\
 			}						\
 			cpu_relax();					\
@@ -246,7 +248,7 @@ static void smc_reset(struct net_device *dev)
 	unsigned int ctl, cfg;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	/* Disable all interrupts, block TX tasklet */
 	spin_lock_irq(&lp->lock);
@@ -339,7 +341,7 @@ static void smc_enable(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int mask;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	/* see the header file for options in TCR/RCR DEFAULT */
 	SMC_SELECT_BANK(lp, 0);
@@ -373,7 +375,7 @@ static void smc_shutdown(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", CARDNAME, __func__);
+	DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
 
 	/* no more interrupts for me */
 	spin_lock_irq(&lp->lock);
@@ -406,11 +408,11 @@ static inline void  smc_rcv(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int packet_number, status, packet_len;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	packet_number = SMC_GET_RXFIFO(lp);
 	if (unlikely(packet_number & RXFIFO_REMPTY)) {
-		PRINTK("%s: smc_rcv with nothing on FIFO.\n", dev->name);
+		PRINTK(dev, "smc_rcv with nothing on FIFO.\n");
 		return;
 	}
 
@@ -420,9 +422,8 @@ static inline void  smc_rcv(struct net_device *dev)
 	/* First two words are status and packet length */
 	SMC_GET_PKT_HDR(lp, status, packet_len);
 	packet_len &= 0x07ff;  /* mask off top bits */
-	DBG(2, "%s: RX PNR 0x%x STATUS 0x%04x LENGTH 0x%04x (%d)\n",
-		dev->name, packet_number, status,
-		packet_len, packet_len);
+	DBG(2, dev, "RX PNR 0x%x STATUS 0x%04x LENGTH 0x%04x (%d)\n",
+	    packet_number, status, packet_len, packet_len);
 
 	back:
 	if (unlikely(packet_len < 6 || status & RS_ERRORS)) {
@@ -433,8 +434,8 @@ static inline void  smc_rcv(struct net_device *dev)
 		}
 		if (packet_len < 6) {
 			/* bloody hardware */
-			printk(KERN_ERR "%s: fubar (rxlen %u status %x\n",
-					dev->name, packet_len, status);
+			netdev_err(dev, "fubar (rxlen %u status %x\n",
+				   packet_len, status);
 			status |= RS_TOOSHORT;
 		}
 		SMC_WAIT_MMU_BUSY(lp);
@@ -551,7 +552,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 	unsigned char *buf;
 	unsigned long flags;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	if (!smc_special_trylock(&lp->lock, flags)) {
 		netif_stop_queue(dev);
@@ -568,7 +569,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	packet_no = SMC_GET_AR(lp);
 	if (unlikely(packet_no & AR_FAILED)) {
-		printk("%s: Memory allocation failed.\n", dev->name);
+		netdev_err(dev, "Memory allocation failed.\n");
 		dev->stats.tx_errors++;
 		dev->stats.tx_fifo_errors++;
 		smc_special_unlock(&lp->lock, flags);
@@ -581,8 +582,8 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	buf = skb->data;
 	len = skb->len;
-	DBG(2, "%s: TX PNR 0x%x LENGTH 0x%04x (%d) BUF 0x%p\n",
-		dev->name, packet_no, len, len, buf);
+	DBG(2, dev, "TX PNR 0x%x LENGTH 0x%04x (%d) BUF 0x%p\n",
+	    packet_no, len, len, buf);
 	PRINT_PKT(buf, len);
 
 	/*
@@ -637,7 +638,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int numPages, poll_count, status;
 	unsigned long flags;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -654,7 +655,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	numPages = ((skb->len & ~1) + (6 - 1)) >> 8;
 	if (unlikely(numPages > 7)) {
-		printk("%s: Far too big packet error.\n", dev->name);
+		netdev_warn(dev, "Far too big packet error.\n");
 		dev->stats.tx_errors++;
 		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
@@ -685,7 +686,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
    	if (!poll_count) {
 		/* oh well, wait until the chip finds memory later */
 		netif_stop_queue(dev);
-		DBG(2, "%s: TX memory allocation deferred.\n", dev->name);
+		DBG(2, dev, "TX memory allocation deferred.\n");
 		SMC_ENABLE_INT(lp, IM_ALLOC_INT);
    	} else {
 		/*
@@ -709,12 +710,12 @@ static void smc_tx(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int saved_packet, packet_no, tx_status, pkt_len;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	/* If the TX FIFO is empty then nothing to do */
 	packet_no = SMC_GET_TXFIFO(lp);
 	if (unlikely(packet_no & TXFIFO_TEMPTY)) {
-		PRINTK("%s: smc_tx with nothing on FIFO.\n", dev->name);
+		PRINTK(dev, "smc_tx with nothing on FIFO.\n");
 		return;
 	}
 
@@ -725,8 +726,8 @@ static void smc_tx(struct net_device *dev)
 	/* read the first word (status word) from this packet */
 	SMC_SET_PTR(lp, PTR_AUTOINC | PTR_READ);
 	SMC_GET_PKT_HDR(lp, tx_status, pkt_len);
-	DBG(2, "%s: TX STATUS 0x%04x PNR 0x%02x\n",
-		dev->name, tx_status, packet_no);
+	DBG(2, dev, "TX STATUS 0x%04x PNR 0x%02x\n",
+	    tx_status, packet_no);
 
 	if (!(tx_status & ES_TX_SUC))
 		dev->stats.tx_errors++;
@@ -735,14 +736,12 @@ static void smc_tx(struct net_device *dev)
 		dev->stats.tx_carrier_errors++;
 
 	if (tx_status & (ES_LATCOL | ES_16COL)) {
-		PRINTK("%s: %s occurred on last xmit\n", dev->name,
+		PRINTK(dev, "%s occurred on last xmit\n",
 		       (tx_status & ES_LATCOL) ?
 			"late collision" : "too many collisions");
 		dev->stats.tx_window_errors++;
 		if (!(dev->stats.tx_window_errors & 63) && net_ratelimit()) {
-			printk(KERN_INFO "%s: unexpectedly large number of "
-			       "bad collisions. Please check duplex "
-			       "setting.\n", dev->name);
+			netdev_info(dev, "unexpectedly large number of bad collisions. Please check duplex setting.\n");
 		}
 	}
 
@@ -830,8 +829,8 @@ static int smc_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 	/* Return to idle state */
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
-	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__func__, phyaddr, phyreg, phydata);
+	DBG(3, dev, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
+	    __func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 	return phydata;
@@ -857,8 +856,8 @@ static void smc_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 	/* Return to idle state */
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
-	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__func__, phyaddr, phyreg, phydata);
+	DBG(3, dev, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
+	    __func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 }
@@ -871,7 +870,7 @@ static void smc_phy_detect(struct net_device *dev)
 	struct smc_local *lp = netdev_priv(dev);
 	int phyaddr;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	lp->phy_type = 0;
 
@@ -886,8 +885,8 @@ static void smc_phy_detect(struct net_device *dev)
 		id1 = smc_phy_read(dev, phyaddr & 31, MII_PHYSID1);
 		id2 = smc_phy_read(dev, phyaddr & 31, MII_PHYSID2);
 
-		DBG(3, "%s: phy_id1=0x%x, phy_id2=0x%x\n",
-			dev->name, id1, id2);
+		DBG(3, dev, "phy_id1=0x%x, phy_id2=0x%x\n",
+		    id1, id2);
 
 		/* Make sure it is a valid identifier */
 		if (id1 != 0x0000 && id1 != 0xffff && id1 != 0x8000 &&
@@ -910,7 +909,7 @@ static int smc_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr, cfg1;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	/* Enter Link Disable state */
 	cfg1 = smc_phy_read(dev, phyaddr, PHY_CFG1_REG);
@@ -1044,7 +1043,7 @@ static void smc_phy_configure(struct work_struct *work)
 	int my_ad_caps; /* My Advertised capabilities */
 	int status;
 
-	DBG(3, "%s:smc_program_phy()\n", dev->name);
+	DBG(3, dev, "smc_program_phy()\n");
 
 	spin_lock_irq(&lp->lock);
 
@@ -1055,7 +1054,7 @@ static void smc_phy_configure(struct work_struct *work)
 		goto smc_phy_configure_exit;
 
 	if (smc_phy_reset(dev, phyaddr)) {
-		printk("%s: PHY reset timed out\n", dev->name);
+		netdev_info(dev, "PHY reset timed out\n");
 		goto smc_phy_configure_exit;
 	}
 
@@ -1082,7 +1081,7 @@ static void smc_phy_configure(struct work_struct *work)
 	my_phy_caps = smc_phy_read(dev, phyaddr, MII_BMSR);
 
 	if (!(my_phy_caps & BMSR_ANEGCAPABLE)) {
-		printk(KERN_INFO "Auto negotiation NOT supported\n");
+		netdev_info(dev, "Auto negotiation NOT supported\n");
 		smc_phy_fixed(dev);
 		goto smc_phy_configure_exit;
 	}
@@ -1118,8 +1117,8 @@ static void smc_phy_configure(struct work_struct *work)
 	 */
 	status = smc_phy_read(dev, phyaddr, MII_ADVERTISE);
 
-	DBG(2, "%s: phy caps=%x\n", dev->name, my_phy_caps);
-	DBG(2, "%s: phy advertised caps=%x\n", dev->name, my_ad_caps);
+	DBG(2, dev, "phy caps=%x\n", my_phy_caps);
+	DBG(2, dev, "phy advertised caps=%x\n", my_ad_caps);
 
 	/* Restart auto-negotiation process in order to advertise my caps */
 	smc_phy_write(dev, phyaddr, MII_BMCR, BMCR_ANENABLE | BMCR_ANRESTART);
@@ -1143,7 +1142,7 @@ static void smc_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int phy18;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1179,8 +1178,8 @@ static void smc_10bt_check_media(struct net_device *dev, int init)
 			netif_carrier_on(dev);
 		}
 		if (netif_msg_link(lp))
-			printk(KERN_INFO "%s: link %s\n", dev->name,
-			       new_carrier ? "up" : "down");
+			netdev_info(dev, "link %s\n",
+				    new_carrier ? "up" : "down");
 	}
 }
 
@@ -1211,7 +1210,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	int status, mask, timeout, card_stats;
 	int saved_pointer;
 
-	DBG(3, "%s: %s\n", dev->name, __func__);
+	DBG(3, dev, "%s\n", __func__);
 
 	spin_lock(&lp->lock);
 
@@ -1230,12 +1229,12 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	do {
 		status = SMC_GET_INT(lp);
 
-		DBG(2, "%s: INT 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
-			dev->name, status, mask,
-			({ int meminfo; SMC_SELECT_BANK(lp, 0);
-			   meminfo = SMC_GET_MIR(lp);
-			   SMC_SELECT_BANK(lp, 2); meminfo; }),
-			SMC_GET_FIFO(lp));
+		DBG(2, dev, "INT 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
+		    status, mask,
+		    ({ int meminfo; SMC_SELECT_BANK(lp, 0);
+		       meminfo = SMC_GET_MIR(lp);
+		       SMC_SELECT_BANK(lp, 2); meminfo; }),
+		    SMC_GET_FIFO(lp));
 
 		status &= mask;
 		if (!status)
@@ -1243,20 +1242,20 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
 		if (status & IM_TX_INT) {
 			/* do this before RX as it will free memory quickly */
-			DBG(3, "%s: TX int\n", dev->name);
+			DBG(3, dev, "TX int\n");
 			smc_tx(dev);
 			SMC_ACK_INT(lp, IM_TX_INT);
 			if (THROTTLE_TX_PKTS)
 				netif_wake_queue(dev);
 		} else if (status & IM_RCV_INT) {
-			DBG(3, "%s: RX irq\n", dev->name);
+			DBG(3, dev, "RX irq\n");
 			smc_rcv(dev);
 		} else if (status & IM_ALLOC_INT) {
-			DBG(3, "%s: Allocation irq\n", dev->name);
+			DBG(3, dev, "Allocation irq\n");
 			tasklet_hi_schedule(&lp->tx_task);
 			mask &= ~IM_ALLOC_INT;
 		} else if (status & IM_TX_EMPTY_INT) {
-			DBG(3, "%s: TX empty\n", dev->name);
+			DBG(3, dev, "TX empty\n");
 			mask &= ~IM_TX_EMPTY_INT;
 
 			/* update stats */
@@ -1271,10 +1270,10 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 			/* multiple collisions */
 			dev->stats.collisions += card_stats & 0xF;
 		} else if (status & IM_RX_OVRN_INT) {
-			DBG(1, "%s: RX overrun (EPH_ST 0x%04x)\n", dev->name,
-			       ({ int eph_st; SMC_SELECT_BANK(lp, 0);
-				  eph_st = SMC_GET_EPH_STATUS(lp);
-				  SMC_SELECT_BANK(lp, 2); eph_st; }));
+			DBG(1, dev, "RX overrun (EPH_ST 0x%04x)\n",
+			    ({ int eph_st; SMC_SELECT_BANK(lp, 0);
+			       eph_st = SMC_GET_EPH_STATUS(lp);
+			       SMC_SELECT_BANK(lp, 2); eph_st; }));
 			SMC_ACK_INT(lp, IM_RX_OVRN_INT);
 			dev->stats.rx_errors++;
 			dev->stats.rx_fifo_errors++;
@@ -1285,7 +1284,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 			smc_phy_interrupt(dev);
 		} else if (status & IM_ERCV_INT) {
 			SMC_ACK_INT(lp, IM_ERCV_INT);
-			PRINTK("%s: UNSUPPORTED: ERCV INTERRUPT\n", dev->name);
+			PRINTK(dev, "UNSUPPORTED: ERCV INTERRUPT\n");
 		}
 	} while (--timeout);
 
@@ -1296,11 +1295,11 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 
 #ifndef CONFIG_NET_POLL_CONTROLLER
 	if (timeout == MAX_IRQ_LOOPS)
-		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
-		       dev->name, mask);
+		PRINTK(dev, "spurious interrupt (mask = 0x%02x)\n",
+		       mask);
 #endif
-	DBG(3, "%s: Interrupt done (%d loops)\n",
-	       dev->name, MAX_IRQ_LOOPS - timeout);
+	DBG(3, dev, "Interrupt done (%d loops)\n",
+	    MAX_IRQ_LOOPS - timeout);
 
 	/*
 	 * We return IRQ_HANDLED unconditionally here even if there was
@@ -1333,7 +1332,7 @@ static void smc_timeout(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int status, mask, eph_st, meminfo, fifo;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	spin_lock_irq(&lp->lock);
 	status = SMC_GET_INT(lp);
@@ -1344,9 +1343,8 @@ static void smc_timeout(struct net_device *dev)
 	meminfo = SMC_GET_MIR(lp);
 	SMC_SELECT_BANK(lp, 2);
 	spin_unlock_irq(&lp->lock);
-	PRINTK( "%s: TX timeout (INT 0x%02x INTMASK 0x%02x "
-		"MEM 0x%04x FIFO 0x%04x EPH_ST 0x%04x)\n",
-		dev->name, status, mask, meminfo, fifo, eph_st );
+	PRINTK(dev, "TX timeout (INT 0x%02x INTMASK 0x%02x MEM 0x%04x FIFO 0x%04x EPH_ST 0x%04x)\n",
+	       status, mask, meminfo, fifo, eph_st);
 
 	smc_reset(dev);
 	smc_enable(dev);
@@ -1377,10 +1375,10 @@ static void smc_set_multicast_list(struct net_device *dev)
 	unsigned char multicast_table[8];
 	int update_multicast = 0;
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	if (dev->flags & IFF_PROMISC) {
-		DBG(2, "%s: RCR_PRMS\n", dev->name);
+		DBG(2, dev, "RCR_PRMS\n");
 		lp->rcr_cur_mode |= RCR_PRMS;
 	}
 
@@ -1395,7 +1393,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	 * checked before the table is
 	 */
 	else if (dev->flags & IFF_ALLMULTI || netdev_mc_count(dev) > 16) {
-		DBG(2, "%s: RCR_ALMUL\n", dev->name);
+		DBG(2, dev, "RCR_ALMUL\n");
 		lp->rcr_cur_mode |= RCR_ALMUL;
 	}
 
@@ -1437,7 +1435,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 		/* now, the table can be loaded into the chipset */
 		update_multicast = 1;
 	} else  {
-		DBG(2, "%s: ~(RCR_PRMS|RCR_ALMUL)\n", dev->name);
+		DBG(2, dev, "~(RCR_PRMS|RCR_ALMUL)\n");
 		lp->rcr_cur_mode &= ~(RCR_PRMS | RCR_ALMUL);
 
 		/*
@@ -1470,7 +1468,7 @@ smc_open(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	/* Setup the default Register Modes */
 	lp->tcr_cur_mode = TCR_DEFAULT;
@@ -1514,7 +1512,7 @@ static int smc_close(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __func__);
+	DBG(2, dev, "%s\n", __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1694,7 +1692,7 @@ static int smc_ethtool_geteeprom(struct net_device *dev,
 	int i;
 	int imax;
 
-	DBG(1, "Reading %d bytes at %d(0x%x)\n",
+	DBG(1, dev, "Reading %d bytes at %d(0x%x)\n",
 		eeprom->len, eeprom->offset, eeprom->offset);
 	imax = smc_ethtool_geteeprom_len(dev);
 	for (i = 0; i < eeprom->len; i += 2) {
@@ -1706,7 +1704,7 @@ static int smc_ethtool_geteeprom(struct net_device *dev,
 		ret = smc_read_eeprom_word(dev, offset >> 1, &wbuf);
 		if (ret != 0)
 			return ret;
-		DBG(2, "Read 0x%x from 0x%x\n", wbuf, offset >> 1);
+		DBG(2, dev, "Read 0x%x from 0x%x\n", wbuf, offset >> 1);
 		data[i] = (wbuf >> 8) & 0xff;
 		data[i+1] = wbuf & 0xff;
 	}
@@ -1719,8 +1717,8 @@ static int smc_ethtool_seteeprom(struct net_device *dev,
 	int i;
 	int imax;
 
-	DBG(1, "Writing %d bytes to %d(0x%x)\n",
-			eeprom->len, eeprom->offset, eeprom->offset);
+	DBG(1, dev, "Writing %d bytes to %d(0x%x)\n",
+	    eeprom->len, eeprom->offset, eeprom->offset);
 	imax = smc_ethtool_geteeprom_len(dev);
 	for (i = 0; i < eeprom->len; i += 2) {
 		int ret;
@@ -1729,7 +1727,7 @@ static int smc_ethtool_seteeprom(struct net_device *dev,
 		if (offset > imax)
 			break;
 		wbuf = (data[i] << 8) | data[i + 1];
-		DBG(2, "Writing 0x%x to 0x%x\n", wbuf, offset >> 1);
+		DBG(2, dev, "Writing 0x%x to 0x%x\n", wbuf, offset >> 1);
 		ret = smc_write_eeprom_word(dev, offset >> 1, wbuf);
 		if (ret != 0)
 			return ret;
@@ -1784,7 +1782,7 @@ static int smc_findirq(struct smc_local *lp)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(2, "%s: %s\n", CARDNAME, __func__);
+	DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
 
 	cookie = probe_irq_on();
 
@@ -1856,21 +1854,21 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 		     unsigned long irq_flags)
 {
 	struct smc_local *lp = netdev_priv(dev);
-	static int version_printed = 0;
 	int retval;
 	unsigned int val, revision_register;
 	const char *version_string;
 
-	DBG(2, "%s: %s\n", CARDNAME, __func__);
+	DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
 
 	/* First, see if the high byte is 0x33 */
 	val = SMC_CURRENT_BANK(lp);
-	DBG(2, "%s: bank signature probe returned 0x%04x\n", CARDNAME, val);
+	DBG(2, dev, "%s: bank signature probe returned 0x%04x\n",
+	    CARDNAME, val);
 	if ((val & 0xFF00) != 0x3300) {
 		if ((val & 0xFF) == 0x33) {
-			printk(KERN_WARNING
-				"%s: Detected possible byte-swapped interface"
-				" at IOADDR %p\n", CARDNAME, ioaddr);
+			netdev_warn(dev,
+				    "%s: Detected possible byte-swapped interface at IOADDR %p\n",
+				    CARDNAME, ioaddr);
 		}
 		retval = -ENODEV;
 		goto err_out;
@@ -1897,8 +1895,8 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	val = SMC_GET_BASE(lp);
 	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
 	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
-		printk("%s: IOADDR %p doesn't match configuration (%x).\n",
-			CARDNAME, ioaddr, val);
+		netdev_warn(dev, "%s: IOADDR %p doesn't match configuration (%x).\n",
+			    CARDNAME, ioaddr, val);
 	}
 
 	/*
@@ -1908,21 +1906,19 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	 */
 	SMC_SELECT_BANK(lp, 3);
 	revision_register = SMC_GET_REV(lp);
-	DBG(2, "%s: revision = 0x%04x\n", CARDNAME, revision_register);
+	DBG(2, dev, "%s: revision = 0x%04x\n", CARDNAME, revision_register);
 	version_string = chip_ids[ (revision_register >> 4) & 0xF];
 	if (!version_string || (revision_register & 0xff00) != 0x3300) {
 		/* I don't recognize this chip, so... */
-		printk("%s: IO %p: Unrecognized revision register 0x%04x"
-			", Contact author.\n", CARDNAME,
-			ioaddr, revision_register);
+		netdev_warn(dev, "%s: IO %p: Unrecognized revision register 0x%04x, Contact author.\n",
+			    CARDNAME, ioaddr, revision_register);
 
 		retval = -ENODEV;
 		goto err_out;
 	}
 
 	/* At this point I'll assume that the chip is an SMC91x. */
-	if (version_printed++ == 0)
-		printk("%s", version);
+	pr_info_once("%s\n", version);
 
 	/* fill in some of the fields */
 	dev->base_addr = (unsigned long)ioaddr;
@@ -1940,7 +1936,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	/*
 	 * If dev->irq is 0, then the device has to be banged on to see
 	 * what the IRQ is.
- 	 *
+	 *
 	 * This banging doesn't always detect the IRQ, for unknown reasons.
 	 * a workaround is to reset the chip and try again.
 	 *
@@ -1965,8 +1961,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 		}
 	}
 	if (dev->irq == 0) {
-		printk("%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
-			dev->name);
+		netdev_warn(dev, "Couldn't autodetect your IRQ. Use irq=xx.\n");
 		retval = -ENODEV;
 		goto err_out;
 	}
@@ -2030,32 +2025,31 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	retval = register_netdev(dev);
 	if (retval == 0) {
 		/* now, print out the card info, in a short format.. */
-		printk("%s: %s (rev %d) at %p IRQ %d",
-			dev->name, version_string, revision_register & 0x0f,
-			lp->base, dev->irq);
+		netdev_info(dev, "%s (rev %d) at %p IRQ %d",
+			    version_string, revision_register & 0x0f,
+			    lp->base, dev->irq);
 
 		if (dev->dma != (unsigned char)-1)
-			printk(" DMA %d", dev->dma);
+			pr_cont(" DMA %d", dev->dma);
 
-		printk("%s%s\n",
+		pr_cont("%s%s\n",
 			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
 			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");
 
 		if (!is_valid_ether_addr(dev->dev_addr)) {
-			printk("%s: Invalid ethernet MAC address.  Please "
-			       "set using ifconfig\n", dev->name);
+			netdev_warn(dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: %pM\n",
-			       dev->name, dev->dev_addr);
+			netdev_info(dev, "Ethernet addr: %pM\n",
+				    dev->dev_addr);
 		}
 
 		if (lp->phy_type == 0) {
-			PRINTK("%s: No PHY found\n", dev->name);
+			PRINTK(dev, "No PHY found\n");
 		} else if ((lp->phy_type & 0xfffffff0) == 0x0016f840) {
-			PRINTK("%s: PHY LAN83C183 (LAN91C111 Internal)\n", dev->name);
+			PRINTK(dev, "PHY LAN83C183 (LAN91C111 Internal)\n");
 		} else if ((lp->phy_type & 0xfffffff0) == 0x02821c50) {
-			PRINTK("%s: PHY LAN83C180\n", dev->name);
+			PRINTK(dev, "PHY LAN83C180\n");
 		}
 	}
 
@@ -2165,7 +2159,8 @@ static inline void smc_request_datacs(struct platform_device *pdev, struct net_d
 			return;
 
 		if(!request_mem_region(res->start, SMC_DATA_EXTENT, CARDNAME)) {
-			printk(KERN_INFO "%s: failed to request datacs memory region.\n", CARDNAME);
+			netdev_info(ndev, "%s: failed to request datacs memory region.\n",
+				    CARDNAME);
 			return;
 		}
 
@@ -2307,7 +2302,7 @@ static int smc_drv_probe(struct platform_device *pdev)
  out_free_netdev:
 	free_netdev(ndev);
  out:
-	printk("%s: not found (%d).\n", CARDNAME, ret);
+	pr_info("%s: not found (%d).\n", CARDNAME, ret);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 98eedb9..c9d4c87 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -907,8 +907,8 @@ static const char * chip_ids[ 16 ] =  {
 	({								\
 		int __b = SMC_CURRENT_BANK(lp);			\
 		if (unlikely((__b & ~0xf0) != (0x3300 | bank))) {	\
-			printk( "%s: bank reg screwed (0x%04x)\n",	\
-				CARDNAME, __b );			\
+			pr_err("%s: bank reg screwed (0x%04x)\n",	\
+			       CARDNAME, __b);				\
 			BUG();						\
 		}							\
 		reg<<SMC_IO_SHIFT;					\
-- 
1.8.4.2
