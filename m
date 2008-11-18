From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: tulip/de2104x.c replace register macros with static
 inlines
Date: Tue, 18 Nov 2008 13:35:53 -0800
Message-ID: <1227044153.13182.6.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:48218 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbYKRVf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 16:35:57 -0500
Received: by an-out-0708.google.com with SMTP id d40so1375773and.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 13:35:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
I noticed this while checking out the sparse warning about do-while not
being a compound statement, maybe a bit silly, but I had it done, so I'll
see if you want to apply it.

 drivers/net/tulip/de2104x.c |  119 ++++++++++++++++++++++--------------------
 1 files changed, 62 insertions(+), 57 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 3aa60fa..e3a5cdd 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -354,10 +354,15 @@ static u16 t21041_csr13[] = { 0xEF01, 0xEF09, 0xEF09, 0xEF01, 0xEF09, };
 static u16 t21041_csr14[] = { 0xFFFF, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, };
 static u16 t21041_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 
+static inline u32 dr32(const struct de_private *de, unsigned int reg)
+{
+	return readl(de->regs + reg);
+}
 
-#define dr32(reg)		readl(de->regs + (reg))
-#define dw32(reg,val)		writel((val), de->regs + (reg))
-
+static inline void dw32(const struct de_private *de, unsigned int reg, u32 val)
+{
+	writel(val, de->regs + reg);
+}
 
 static void de_rx_err_acct (struct de_private *de, unsigned rx_tail,
 			    u32 status, u32 len)
@@ -486,20 +491,20 @@ static irqreturn_t de_interrupt (int irq, void *dev_instance)
 	struct de_private *de = netdev_priv(dev);
 	u32 status;
 
-	status = dr32(MacStatus);
+	status = dr32(de, MacStatus);
 	if ((!(status & (IntrOK|IntrErr))) || (status == 0xFFFF))
 		return IRQ_NONE;
 
 	if (netif_msg_intr(de))
 		printk(KERN_DEBUG "%s: intr, status %08x mode %08x desc %u/%u/%u\n",
-		        dev->name, status, dr32(MacMode), de->rx_tail, de->tx_head, de->tx_tail);
+		        dev->name, status, dr32(de, MacMode), de->rx_tail, de->tx_head, de->tx_tail);
 
-	dw32(MacStatus, status);
+	dw32(de, MacStatus, status);
 
 	if (status & (RxIntr | RxEmpty)) {
 		de_rx(de);
 		if (status & RxEmpty)
-			dw32(RxPoll, NormalRxPoll);
+			dw32(de, RxPoll, NormalRxPoll);
 	}
 
 	spin_lock(&de->lock);
@@ -636,7 +641,7 @@ static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irq(&de->lock);
 
 	/* Trigger an immediate transmit demand. */
-	dw32(TxPoll, NormalTxPoll);
+	dw32(de, TxPoll, NormalTxPoll);
 	dev->trans_start = jiffies;
 
 	return 0;
@@ -718,7 +723,7 @@ static void __de_set_rx_mode (struct net_device *dev)
 	struct de_desc *txd;
 	struct de_desc *dummy_txd = NULL;
 
-	macmode = dr32(MacMode) & ~(AcceptAllMulticast | AcceptAllPhys);
+	macmode = dr32(de, MacMode) & ~(AcceptAllMulticast | AcceptAllPhys);
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		macmode |= AcceptAllMulticast | AcceptAllPhys;
@@ -786,11 +791,11 @@ static void __de_set_rx_mode (struct net_device *dev)
 		netif_stop_queue(dev);
 
 	/* Trigger an immediate transmit demand. */
-	dw32(TxPoll, NormalTxPoll);
+	dw32(de, TxPoll, NormalTxPoll);
 
 out:
-	if (macmode != dr32(MacMode))
-		dw32(MacMode, macmode);
+	if (macmode != dr32(de, MacMode))
+		dw32(de, MacMode, macmode);
 }
 
 static void de_set_rx_mode (struct net_device *dev)
@@ -813,7 +818,7 @@ static inline void de_rx_missed(struct de_private *de, u32 rx_missed)
 
 static void __de_get_stats(struct de_private *de)
 {
-	u32 tmp = dr32(RxMissed); /* self-clearing */
+	u32 tmp = dr32(de, RxMissed); /* self-clearing */
 
 	de_rx_missed(de, tmp);
 }
@@ -833,7 +838,7 @@ static struct net_device_stats *de_get_stats(struct net_device *dev)
 
 static inline int de_is_running (struct de_private *de)
 {
-	return (dr32(MacStatus) & (RxState | TxState)) ? 1 : 0;
+	return (dr32(de, MacStatus) & (RxState | TxState)) ? 1 : 0;
 }
 
 static void de_stop_rxtx (struct de_private *de)
@@ -841,10 +846,10 @@ static void de_stop_rxtx (struct de_private *de)
 	u32 macmode;
 	unsigned int i = 1300/100;
 
-	macmode = dr32(MacMode);
+	macmode = dr32(de, MacMode);
 	if (macmode & RxTx) {
-		dw32(MacMode, macmode & ~RxTx);
-		dr32(MacMode);
+		dw32(de, MacMode, macmode & ~RxTx);
+		dr32(de, MacMode);
 	}
 
 	/* wait until in-flight frame completes.
@@ -864,10 +869,10 @@ static inline void de_start_rxtx (struct de_private *de)
 {
 	u32 macmode;
 
-	macmode = dr32(MacMode);
+	macmode = dr32(de, MacMode);
 	if ((macmode & RxTx) != RxTx) {
-		dw32(MacMode, macmode | RxTx);
-		dr32(MacMode);
+		dw32(de, MacMode, macmode | RxTx);
+		dr32(de, MacMode);
 	}
 }
 
@@ -875,11 +880,11 @@ static void de_stop_hw (struct de_private *de)
 {
 
 	udelay(5);
-	dw32(IntrMask, 0);
+	dw32(de, IntrMask, 0);
 
 	de_stop_rxtx(de);
 
-	dw32(MacStatus, dr32(MacStatus));
+	dw32(de, MacStatus, dr32(de, MacStatus));
 
 	udelay(10);
 
@@ -909,17 +914,17 @@ static void de_link_down(struct de_private *de)
 static void de_set_media (struct de_private *de)
 {
 	unsigned media = de->media_type;
-	u32 macmode = dr32(MacMode);
+	u32 macmode = dr32(de, MacMode);
 
 	if (de_is_running(de))
 		printk(KERN_WARNING "%s: chip is running while changing media!\n", de->dev->name);
 
 	if (de->de21040)
-		dw32(CSR11, FULL_DUPLEX_MAGIC);
-	dw32(CSR13, 0); /* Reset phy */
-	dw32(CSR14, de->media[media].csr14);
-	dw32(CSR15, de->media[media].csr15);
-	dw32(CSR13, de->media[media].csr13);
+		dw32(de, CSR11, FULL_DUPLEX_MAGIC);
+	dw32(de, CSR13, 0); /* Reset phy */
+	dw32(de, CSR14, de->media[media].csr14);
+	dw32(de, CSR15, de->media[media].csr15);
+	dw32(de, CSR13, de->media[media].csr13);
 
 	/* must delay 10ms before writing to other registers,
 	 * especially CSR6
@@ -936,13 +941,13 @@ static void de_set_media (struct de_private *de)
 		       KERN_INFO "%s:    mode 0x%x, sia 0x%x,0x%x,0x%x,0x%x\n"
 		       KERN_INFO "%s:    set mode 0x%x, set sia 0x%x,0x%x,0x%x\n",
 		       de->dev->name, media_name[media],
-		       de->dev->name, dr32(MacMode), dr32(SIAStatus),
-		       dr32(CSR13), dr32(CSR14), dr32(CSR15),
+		       de->dev->name, dr32(de, MacMode), dr32(de, SIAStatus),
+		       dr32(de, CSR13), dr32(de, CSR14), dr32(de, CSR15),
 		       de->dev->name, macmode, de->media[media].csr13,
 		       de->media[media].csr14, de->media[media].csr15);
 	}
-	if (macmode != dr32(MacMode))
-		dw32(MacMode, macmode);
+	if (macmode != dr32(de, MacMode))
+		dw32(de, MacMode, macmode);
 }
 
 static void de_next_media (struct de_private *de, u32 *media,
@@ -962,7 +967,7 @@ static void de21040_media_timer (unsigned long data)
 {
 	struct de_private *de = (struct de_private *) data;
 	struct net_device *dev = de->dev;
-	u32 status = dr32(SIAStatus);
+	u32 status = dr32(de, SIAStatus);
 	unsigned int carrier;
 	unsigned long flags;
 
@@ -1046,7 +1051,7 @@ static void de21041_media_timer (unsigned long data)
 {
 	struct de_private *de = (struct de_private *) data;
 	struct net_device *dev = de->dev;
-	u32 status = dr32(SIAStatus);
+	u32 status = dr32(de, SIAStatus);
 	unsigned int carrier;
 	unsigned long flags;
 
@@ -1067,7 +1072,7 @@ static void de21041_media_timer (unsigned long data)
 			if (netif_msg_timer(de))
 				printk(KERN_INFO "%s: %s link ok, mode %x status %x\n",
 				       dev->name, media_name[de->media_type],
-				       dr32(MacMode), status);
+				       dr32(de, MacMode), status);
 		return;
 	}
 
@@ -1165,24 +1170,24 @@ static int de_reset_mac (struct de_private *de)
 	 * in this area.
 	 */
 
-	if (dr32(BusMode) == 0xffffffff)
+	if (dr32(de, BusMode) == 0xffffffff)
 		return -EBUSY;
 
 	/* Reset the chip, holding bit 0 set at least 50 PCI cycles. */
-	dw32 (BusMode, CmdReset);
+	dw32(de, BusMode, CmdReset);
 	mdelay (1);
 
-	dw32 (BusMode, de_bus_mode);
+	dw32(de, BusMode, de_bus_mode);
 	mdelay (1);
 
 	for (tmp = 0; tmp < 5; tmp++) {
-		dr32 (BusMode);
+		dr32(de, BusMode);
 		mdelay (1);
 	}
 
 	mdelay (1);
 
-	status = dr32(MacStatus);
+	status = dr32(de, MacStatus);
 	if (status & (RxState | TxState))
 		return -EBUSY;
 	if (status == 0xffffffff)
@@ -1227,7 +1232,7 @@ static int de_init_hw (struct de_private *de)
 
 	de_adapter_wake(de);
 
-	macmode = dr32(MacMode) & ~MacModeClear;
+	macmode = dr32(de, MacMode) & ~MacModeClear;
 
 	rc = de_reset_mac(de);
 	if (rc)
@@ -1235,14 +1240,14 @@ static int de_init_hw (struct de_private *de)
 
 	de_set_media(de); /* reset phy */
 
-	dw32(RxRingAddr, de->ring_dma);
-	dw32(TxRingAddr, de->ring_dma + (sizeof(struct de_desc) * DE_RX_RING_SIZE));
+	dw32(de, RxRingAddr, de->ring_dma);
+	dw32(de, TxRingAddr, de->ring_dma + (sizeof(struct de_desc) * DE_RX_RING_SIZE));
 
-	dw32(MacMode, RxTx | macmode);
+	dw32(de, MacMode, RxTx | macmode);
 
-	dr32(RxMissed); /* self-clearing */
+	dr32(de, RxMissed); /* self-clearing */
 
-	dw32(IntrMask, de_intr_mask);
+	dw32(de, IntrMask, de_intr_mask);
 
 	de_set_rx_mode(dev);
 
@@ -1369,7 +1374,7 @@ static int de_open (struct net_device *dev)
 		return rc;
 	}
 
-	dw32(IntrMask, 0);
+	dw32(de, IntrMask, 0);
 
 	rc = request_irq(dev->irq, de_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
@@ -1425,7 +1430,7 @@ static void de_tx_timeout (struct net_device *dev)
 	struct de_private *de = netdev_priv(dev);
 
 	printk(KERN_DEBUG "%s: NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
-	       dev->name, dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
+	       dev->name, dr32(de, MacStatus), dr32(de, MacMode), dr32(de, SIAStatus),
 	       de->rx_tail, de->tx_head, de->tx_tail);
 
 	del_timer_sync(&de->media_timer);
@@ -1460,7 +1465,7 @@ static void __de_get_regs(struct de_private *de, u8 *buf)
 
 	/* read all CSRs */
 	for (i = 0; i < DE_NUM_REGS; i++)
-		rbuf[i] = dr32(i * 8);
+		rbuf[i] = dr32(de, i * 8);
 
 	/* handle self-clearing RxMissed counter, CSR8 */
 	de_rx_missed(de, rbuf[8]);
@@ -1488,7 +1493,7 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 		break;
 	}
 
-	if (dr32(MacMode) & FullDuplex)
+	if (dr32(de, MacMode) & FullDuplex)
 		ecmd->duplex = DUPLEX_FULL;
 	else
 		ecmd->duplex = DUPLEX_HALF;
@@ -1649,11 +1654,11 @@ static int de_nway_reset(struct net_device *dev)
 	if (netif_carrier_ok(de->dev))
 		de_link_down(de);
 
-	status = dr32(SIAStatus);
-	dw32(SIAStatus, (status & ~NWayState) | NWayRestart);
+	status = dr32(de, SIAStatus);
+	dw32(de, SIAStatus, (status & ~NWayState) | NWayRestart);
 	if (netif_msg_link(de))
 		printk(KERN_INFO "%s: link nway restart, status %x,%x\n",
-		       de->dev->name, status, dr32(SIAStatus));
+		       de->dev->name, status, dr32(de, SIAStatus));
 	return 0;
 }
 
@@ -1686,14 +1691,14 @@ static void __devinit de21040_get_mac_address (struct de_private *de)
 {
 	unsigned i;
 
-	dw32 (ROMCmd, 0);	/* Reset the pointer with a dummy write. */
+	dw32(de, ROMCmd, 0);	/* Reset the pointer with a dummy write. */
 	udelay(5);
 
 	for (i = 0; i < 6; i++) {
 		int value, boguscnt = 100000;
-		do
-			value = dr32(ROMCmd);
-		while (value < 0 && --boguscnt > 0);
+		do {
+			value = dr32(de, ROMCmd);
+		} while (value < 0 && --boguscnt > 0);
 		de->dev->dev_addr[i] = value;
 		udelay(1);
 		if (boguscnt <= 0)
-- 
1.6.0.4.994.g16bd3e



