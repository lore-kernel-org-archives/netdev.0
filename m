From: Aaron Wu <Aaron.wu@analog.com>
Subject: [PATCH V7 1/3] bfin_can: rewrite the blackfin style of read/write to common ones
Date: Fri, 6 Feb 2015 18:14:17 +0800
Message-ID: <1423217659-27820-1-git-send-email-Aaron.wu@analog.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Aaron Wu <Aaron.wu@analog.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-devel@analog.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the blackfin arch dependent style of bfin_read/bfin_write with
common readw/writew

Signed-off-by: Aaron Wu <Aaron.wu@analog.com>
---
 drivers/net/can/bfin_can.c |  126 +++++++++++++++++++++-----------------------
 1 file changed, 60 insertions(+), 66 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 417d5099..0a5eff4 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -78,8 +78,8 @@ static int bfin_can_set_bittiming(struct net_device *dev)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
 		timing |= SAM;
 
-	bfin_write(&reg->clock, clk);
-	bfin_write(&reg->timing, timing);
+	writew(clk, &reg->clock);
+	writew(timing, &reg->timing);
 
 	netdev_info(dev, "setting CLOCK=0x%04x TIMING=0x%04x\n", clk, timing);
 
@@ -94,16 +94,14 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
 	int i;
 
 	/* disable interrupts */
-	bfin_write(&reg->mbim1, 0);
-	bfin_write(&reg->mbim2, 0);
-	bfin_write(&reg->gim, 0);
+	writew(0, &reg->mbim1);
+	writew(0, &reg->mbim2);
+	writew(0, &reg->gim);
 
 	/* reset can and enter configuration mode */
-	bfin_write(&reg->control, SRS | CCR);
-	SSYNC();
-	bfin_write(&reg->control, CCR);
-	SSYNC();
-	while (!(bfin_read(&reg->control) & CCA)) {
+	writew(SRS | CCR, &reg->control);
+	writew(CCR, &reg->control);
+	while (!(readw(&reg->control) & CCA)) {
 		udelay(10);
 		if (--timeout == 0) {
 			netdev_err(dev, "fail to enter configuration mode\n");
@@ -116,34 +114,33 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
 	 * by writing to CAN Mailbox Configuration Registers 1 and 2
 	 * For all bits: 0 - Mailbox disabled, 1 - Mailbox enabled
 	 */
-	bfin_write(&reg->mc1, 0);
-	bfin_write(&reg->mc2, 0);
+	writew(0, &reg->mc1);
+	writew(0, &reg->mc2);
 
 	/* Set Mailbox Direction */
-	bfin_write(&reg->md1, 0xFFFF);   /* mailbox 1-16 are RX */
-	bfin_write(&reg->md2, 0);   /* mailbox 17-32 are TX */
+	writew(0xFFFF, &reg->md1);   /* mailbox 1-16 are RX */
+	writew(0, &reg->md2);   /* mailbox 17-32 are TX */
 
 	/* RECEIVE_STD_CHL */
 	for (i = 0; i < 2; i++) {
-		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].id0, 0);
-		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].id1, AME);
-		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].dlc, 0);
-		bfin_write(&reg->msk[RECEIVE_STD_CHL + i].amh, 0x1FFF);
-		bfin_write(&reg->msk[RECEIVE_STD_CHL + i].aml, 0xFFFF);
+		writew(0, &reg->chl[RECEIVE_STD_CHL + i].id0);
+		writew(AME, &reg->chl[RECEIVE_STD_CHL + i].id1);
+		writew(0, &reg->chl[RECEIVE_STD_CHL + i].dlc);
+		writew(0x1FFF, &reg->msk[RECEIVE_STD_CHL + i].amh);
+		writew(0xFFFF, &reg->msk[RECEIVE_STD_CHL + i].aml);
 	}
 
 	/* RECEIVE_EXT_CHL */
 	for (i = 0; i < 2; i++) {
-		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].id0, 0);
-		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].id1, AME | IDE);
-		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].dlc, 0);
-		bfin_write(&reg->msk[RECEIVE_EXT_CHL + i].amh, 0x1FFF);
-		bfin_write(&reg->msk[RECEIVE_EXT_CHL + i].aml, 0xFFFF);
+		writew(0, &reg->chl[RECEIVE_EXT_CHL + i].id0);
+		writew(AME | IDE, &reg->chl[RECEIVE_EXT_CHL + i].id1);
+		writew(0, &reg->chl[RECEIVE_EXT_CHL + i].dlc);
+		writew(0x1FFF, &reg->msk[RECEIVE_EXT_CHL + i].amh);
+		writew(0xFFFF, &reg->msk[RECEIVE_EXT_CHL + i].aml);
 	}
 
-	bfin_write(&reg->mc2, BIT(TRANSMIT_CHL - 16));
-	bfin_write(&reg->mc1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
-	SSYNC();
+	writew(BIT(TRANSMIT_CHL - 16), &reg->mc2);
+	writew(BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL), &reg->mc1);
 
 	priv->can.state = CAN_STATE_STOPPED;
 }
@@ -157,9 +154,9 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
 	/*
 	 * leave configuration mode
 	 */
-	bfin_write(&reg->control, bfin_read(&reg->control) & ~CCR);
+	writew(readw(&reg->control) & ~CCR, &reg->control);
 
-	while (bfin_read(&reg->status) & CCA) {
+	while (readw(&reg->status) & CCA) {
 		udelay(10);
 		if (--timeout == 0) {
 			netdev_err(dev, "fail to leave configuration mode\n");
@@ -170,26 +167,25 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
 	/*
 	 * clear _All_  tx and rx interrupts
 	 */
-	bfin_write(&reg->mbtif1, 0xFFFF);
-	bfin_write(&reg->mbtif2, 0xFFFF);
-	bfin_write(&reg->mbrif1, 0xFFFF);
-	bfin_write(&reg->mbrif2, 0xFFFF);
+	writew(0xFFFF, &reg->mbtif1);
+	writew(0xFFFF, &reg->mbtif2);
+	writew(0xFFFF, &reg->mbrif1);
+	writew(0xFFFF, &reg->mbrif2);
 
 	/*
 	 * clear global interrupt status register
 	 */
-	bfin_write(&reg->gis, 0x7FF); /* overwrites with '1' */
+	writew(0x7FF, &reg->gis); /* overwrites with '1' */
 
 	/*
 	 * Initialize Interrupts
 	 * - set bits in the mailbox interrupt mask register
 	 * - global interrupt mask
 	 */
-	bfin_write(&reg->mbim1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
-	bfin_write(&reg->mbim2, BIT(TRANSMIT_CHL - 16));
+	writew(BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL), &reg->mbim1);
+	writew(BIT(TRANSMIT_CHL - 16), &reg->mbim2);
 
-	bfin_write(&reg->gim, EPIM | BOIM | RMLIM);
-	SSYNC();
+	writew(EPIM | BOIM | RMLIM, &reg->gim);
 }
 
 static void bfin_can_start(struct net_device *dev)
@@ -226,7 +222,7 @@ static int bfin_can_get_berr_counter(const struct net_device *dev,
 	struct bfin_can_priv *priv = netdev_priv(dev);
 	struct bfin_can_regs __iomem *reg = priv->membase;
 
-	u16 cec = bfin_read(&reg->cec);
+	u16 cec = readw(&reg->cec);
 
 	bec->txerr = cec >> 8;
 	bec->rxerr = cec;
@@ -252,28 +248,28 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* fill id */
 	if (id & CAN_EFF_FLAG) {
-		bfin_write(&reg->chl[TRANSMIT_CHL].id0, id);
+		writew(id, &reg->chl[TRANSMIT_CHL].id0);
 		val = ((id & 0x1FFF0000) >> 16) | IDE;
 	} else
 		val = (id << 2);
 	if (id & CAN_RTR_FLAG)
 		val |= RTR;
-	bfin_write(&reg->chl[TRANSMIT_CHL].id1, val | AME);
+	writew(val | AME, &reg->chl[TRANSMIT_CHL].id1);
 
 	/* fill payload */
 	for (i = 0; i < 8; i += 2) {
 		val = ((7 - i) < dlc ? (data[7 - i]) : 0) +
 			((6 - i) < dlc ? (data[6 - i] << 8) : 0);
-		bfin_write(&reg->chl[TRANSMIT_CHL].data[i], val);
+		writew(val, &reg->chl[TRANSMIT_CHL].data[i]);
 	}
 
 	/* fill data length code */
-	bfin_write(&reg->chl[TRANSMIT_CHL].dlc, dlc);
+	writew(dlc, &reg->chl[TRANSMIT_CHL].dlc);
 
 	can_put_echo_skb(skb, dev, 0);
 
 	/* set transmit request */
-	bfin_write(&reg->trs2, BIT(TRANSMIT_CHL - 16));
+	writew(BIT(TRANSMIT_CHL - 16), &reg->trs2);
 
 	return 0;
 }
@@ -296,26 +292,26 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 	/* get id */
 	if (isrc & BIT(RECEIVE_EXT_CHL)) {
 		/* extended frame format (EFF) */
-		cf->can_id = ((bfin_read(&reg->chl[RECEIVE_EXT_CHL].id1)
+		cf->can_id = ((readw(&reg->chl[RECEIVE_EXT_CHL].id1)
 			     & 0x1FFF) << 16)
-			     + bfin_read(&reg->chl[RECEIVE_EXT_CHL].id0);
+			     + readw(&reg->chl[RECEIVE_EXT_CHL].id0);
 		cf->can_id |= CAN_EFF_FLAG;
 		obj = RECEIVE_EXT_CHL;
 	} else {
 		/* standard frame format (SFF) */
-		cf->can_id = (bfin_read(&reg->chl[RECEIVE_STD_CHL].id1)
+		cf->can_id = (readw(&reg->chl[RECEIVE_STD_CHL].id1)
 			     & 0x1ffc) >> 2;
 		obj = RECEIVE_STD_CHL;
 	}
-	if (bfin_read(&reg->chl[obj].id1) & RTR)
+	if (readw(&reg->chl[obj].id1) & RTR)
 		cf->can_id |= CAN_RTR_FLAG;
 
 	/* get data length code */
-	cf->can_dlc = get_can_dlc(bfin_read(&reg->chl[obj].dlc) & 0xF);
+	cf->can_dlc = get_can_dlc(readw(&reg->chl[obj].dlc) & 0xF);
 
 	/* get payload */
 	for (i = 0; i < 8; i += 2) {
-		val = bfin_read(&reg->chl[obj].data[i]);
+		val = readw(&reg->chl[obj].data[i]);
 		cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
 		cf->data[6 - i] = (6 - i) < cf->can_dlc ? (val >> 8) : 0;
 	}
@@ -368,7 +364,7 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
 
 	if (state != priv->can.state && (state == CAN_STATE_ERROR_WARNING ||
 				state == CAN_STATE_ERROR_PASSIVE)) {
-		u16 cec = bfin_read(&reg->cec);
+		u16 cec = readw(&reg->cec);
 		u8 rxerr = cec;
 		u8 txerr = cec >> 8;
 
@@ -419,23 +415,23 @@ static irqreturn_t bfin_can_interrupt(int irq, void *dev_id)
 	struct net_device_stats *stats = &dev->stats;
 	u16 status, isrc;
 
-	if ((irq == priv->tx_irq) && bfin_read(&reg->mbtif2)) {
+	if ((irq == priv->tx_irq) && readw(&reg->mbtif2)) {
 		/* transmission complete interrupt */
-		bfin_write(&reg->mbtif2, 0xFFFF);
+		writew(0xFFFF, &reg->mbtif2);
 		stats->tx_packets++;
-		stats->tx_bytes += bfin_read(&reg->chl[TRANSMIT_CHL].dlc);
+		stats->tx_bytes += readw(&reg->chl[TRANSMIT_CHL].dlc);
 		can_get_echo_skb(dev, 0);
 		netif_wake_queue(dev);
-	} else if ((irq == priv->rx_irq) && bfin_read(&reg->mbrif1)) {
+	} else if ((irq == priv->rx_irq) && readw(&reg->mbrif1)) {
 		/* receive interrupt */
-		isrc = bfin_read(&reg->mbrif1);
-		bfin_write(&reg->mbrif1, 0xFFFF);
+		isrc = readw(&reg->mbrif1);
+		writew(0xFFFF, &reg->mbrif1);
 		bfin_can_rx(dev, isrc);
-	} else if ((irq == priv->err_irq) && bfin_read(&reg->gis)) {
+	} else if ((irq == priv->err_irq) && readw(&reg->gis)) {
 		/* error interrupt */
-		isrc = bfin_read(&reg->gis);
-		status = bfin_read(&reg->esr);
-		bfin_write(&reg->gis, 0x7FF);
+		isrc = readw(&reg->gis);
+		status = readw(&reg->esr);
+		writew(0x7FF, &reg->gis);
 		bfin_can_err(dev, isrc, status);
 	} else {
 		return IRQ_NONE;
@@ -640,9 +636,8 @@ static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
 
 	if (netif_running(dev)) {
 		/* enter sleep mode */
-		bfin_write(&reg->control, bfin_read(&reg->control) | SMR);
-		SSYNC();
-		while (!(bfin_read(&reg->intr) & SMACK)) {
+		writew(readw(&reg->control) | SMR, &reg->control);
+		while (!(readw(&reg->intr) & SMACK)) {
 			udelay(10);
 			if (--timeout == 0) {
 				netdev_err(dev, "fail to enter sleep mode\n");
@@ -662,8 +657,7 @@ static int bfin_can_resume(struct platform_device *pdev)
 
 	if (netif_running(dev)) {
 		/* leave sleep mode */
-		bfin_write(&reg->intr, 0);
-		SSYNC();
+		writew(0, &reg->intr);
 	}
 
 	return 0;
-- 
1.7.9.5
