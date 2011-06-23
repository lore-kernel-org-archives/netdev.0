From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/2] can: bfin_can: auto-calculate accessor sizes
Date: Thu, 23 Jun 2011 16:36:20 -0400
Message-ID: <1308861380-27485-2-git-send-email-vapier@gentoo.org>
References: <1308861380-27485-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: socketcan-core@lists.berlios.de,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55061 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933927Ab1FWUgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 16:36:22 -0400
In-Reply-To: <1308861380-27485-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have a struct that defines the sizes of the registers, we don't
need to explicitly use the 16bit read/write helpers.  Let the code figure
out which size access to make based on the size of the C type.

There should be no functional changes here.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/can/bfin_can.c |  118 ++++++++++++++++++++++----------------------
 1 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index dc6ef4a..a1c5abc 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -79,8 +79,8 @@ static int bfin_can_set_bittiming(struct net_device *dev)
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
 		timing |= SAM;
 
-	bfin_write16(&reg->clock, clk);
-	bfin_write16(&reg->timing, timing);
+	bfin_write(&reg->clock, clk);
+	bfin_write(&reg->timing, timing);
 
 	dev_info(dev->dev.parent, "setting CLOCK=0x%04x TIMING=0x%04x\n",
 			clk, timing);
@@ -96,16 +96,16 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
 	int i;
 
 	/* disable interrupts */
-	bfin_write16(&reg->mbim1, 0);
-	bfin_write16(&reg->mbim2, 0);
-	bfin_write16(&reg->gim, 0);
+	bfin_write(&reg->mbim1, 0);
+	bfin_write(&reg->mbim2, 0);
+	bfin_write(&reg->gim, 0);
 
 	/* reset can and enter configuration mode */
-	bfin_write16(&reg->control, SRS | CCR);
+	bfin_write(&reg->control, SRS | CCR);
 	SSYNC();
-	bfin_write16(&reg->control, CCR);
+	bfin_write(&reg->control, CCR);
 	SSYNC();
-	while (!(bfin_read16(&reg->control) & CCA)) {
+	while (!(bfin_read(&reg->control) & CCA)) {
 		udelay(10);
 		if (--timeout == 0) {
 			dev_err(dev->dev.parent,
@@ -119,33 +119,33 @@ static void bfin_can_set_reset_mode(struct net_device *dev)
 	 * by writing to CAN Mailbox Configuration Registers 1 and 2
 	 * For all bits: 0 - Mailbox disabled, 1 - Mailbox enabled
 	 */
-	bfin_write16(&reg->mc1, 0);
-	bfin_write16(&reg->mc2, 0);
+	bfin_write(&reg->mc1, 0);
+	bfin_write(&reg->mc2, 0);
 
 	/* Set Mailbox Direction */
-	bfin_write16(&reg->md1, 0xFFFF);   /* mailbox 1-16 are RX */
-	bfin_write16(&reg->md2, 0);   /* mailbox 17-32 are TX */
+	bfin_write(&reg->md1, 0xFFFF);   /* mailbox 1-16 are RX */
+	bfin_write(&reg->md2, 0);   /* mailbox 17-32 are TX */
 
 	/* RECEIVE_STD_CHL */
 	for (i = 0; i < 2; i++) {
-		bfin_write16(&reg->chl[RECEIVE_STD_CHL + i].id0, 0);
-		bfin_write16(&reg->chl[RECEIVE_STD_CHL + i].id1, AME);
-		bfin_write16(&reg->chl[RECEIVE_STD_CHL + i].dlc, 0);
-		bfin_write16(&reg->msk[RECEIVE_STD_CHL + i].amh, 0x1FFF);
-		bfin_write16(&reg->msk[RECEIVE_STD_CHL + i].aml, 0xFFFF);
+		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].id0, 0);
+		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].id1, AME);
+		bfin_write(&reg->chl[RECEIVE_STD_CHL + i].dlc, 0);
+		bfin_write(&reg->msk[RECEIVE_STD_CHL + i].amh, 0x1FFF);
+		bfin_write(&reg->msk[RECEIVE_STD_CHL + i].aml, 0xFFFF);
 	}
 
 	/* RECEIVE_EXT_CHL */
 	for (i = 0; i < 2; i++) {
-		bfin_write16(&reg->chl[RECEIVE_EXT_CHL + i].id0, 0);
-		bfin_write16(&reg->chl[RECEIVE_EXT_CHL + i].id1, AME | IDE);
-		bfin_write16(&reg->chl[RECEIVE_EXT_CHL + i].dlc, 0);
-		bfin_write16(&reg->msk[RECEIVE_EXT_CHL + i].amh, 0x1FFF);
-		bfin_write16(&reg->msk[RECEIVE_EXT_CHL + i].aml, 0xFFFF);
+		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].id0, 0);
+		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].id1, AME | IDE);
+		bfin_write(&reg->chl[RECEIVE_EXT_CHL + i].dlc, 0);
+		bfin_write(&reg->msk[RECEIVE_EXT_CHL + i].amh, 0x1FFF);
+		bfin_write(&reg->msk[RECEIVE_EXT_CHL + i].aml, 0xFFFF);
 	}
 
-	bfin_write16(&reg->mc2, BIT(TRANSMIT_CHL - 16));
-	bfin_write16(&reg->mc1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
+	bfin_write(&reg->mc2, BIT(TRANSMIT_CHL - 16));
+	bfin_write(&reg->mc1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
 	SSYNC();
 
 	priv->can.state = CAN_STATE_STOPPED;
@@ -160,9 +160,9 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
 	/*
 	 * leave configuration mode
 	 */
-	bfin_write16(&reg->control, bfin_read16(&reg->control) & ~CCR);
+	bfin_write(&reg->control, bfin_read(&reg->control) & ~CCR);
 
-	while (bfin_read16(&reg->status) & CCA) {
+	while (bfin_read(&reg->status) & CCA) {
 		udelay(10);
 		if (--timeout == 0) {
 			dev_err(dev->dev.parent,
@@ -174,25 +174,25 @@ static void bfin_can_set_normal_mode(struct net_device *dev)
 	/*
 	 * clear _All_  tx and rx interrupts
 	 */
-	bfin_write16(&reg->mbtif1, 0xFFFF);
-	bfin_write16(&reg->mbtif2, 0xFFFF);
-	bfin_write16(&reg->mbrif1, 0xFFFF);
-	bfin_write16(&reg->mbrif2, 0xFFFF);
+	bfin_write(&reg->mbtif1, 0xFFFF);
+	bfin_write(&reg->mbtif2, 0xFFFF);
+	bfin_write(&reg->mbrif1, 0xFFFF);
+	bfin_write(&reg->mbrif2, 0xFFFF);
 
 	/*
 	 * clear global interrupt status register
 	 */
-	bfin_write16(&reg->gis, 0x7FF); /* overwrites with '1' */
+	bfin_write(&reg->gis, 0x7FF); /* overwrites with '1' */
 
 	/*
 	 * Initialize Interrupts
 	 * - set bits in the mailbox interrupt mask register
 	 * - global interrupt mask
 	 */
-	bfin_write16(&reg->mbim1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
-	bfin_write16(&reg->mbim2, BIT(TRANSMIT_CHL - 16));
+	bfin_write(&reg->mbim1, BIT(RECEIVE_STD_CHL) + BIT(RECEIVE_EXT_CHL));
+	bfin_write(&reg->mbim2, BIT(TRANSMIT_CHL - 16));
 
-	bfin_write16(&reg->gim, EPIM | BOIM | RMLIM);
+	bfin_write(&reg->gim, EPIM | BOIM | RMLIM);
 	SSYNC();
 }
 
@@ -242,28 +242,28 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* fill id */
 	if (id & CAN_EFF_FLAG) {
-		bfin_write16(&reg->chl[TRANSMIT_CHL].id0, id);
+		bfin_write(&reg->chl[TRANSMIT_CHL].id0, id);
 		val = ((id & 0x1FFF0000) >> 16) | IDE;
 	} else
 		val = (id << 2);
 	if (id & CAN_RTR_FLAG)
 		val |= RTR;
-	bfin_write16(&reg->chl[TRANSMIT_CHL].id1, val | AME);
+	bfin_write(&reg->chl[TRANSMIT_CHL].id1, val | AME);
 
 	/* fill payload */
 	for (i = 0; i < 8; i += 2) {
 		val = ((7 - i) < dlc ? (data[7 - i]) : 0) +
 			((6 - i) < dlc ? (data[6 - i] << 8) : 0);
-		bfin_write16(&reg->chl[TRANSMIT_CHL].data[i], val);
+		bfin_write(&reg->chl[TRANSMIT_CHL].data[i], val);
 	}
 
 	/* fill data length code */
-	bfin_write16(&reg->chl[TRANSMIT_CHL].dlc, dlc);
+	bfin_write(&reg->chl[TRANSMIT_CHL].dlc, dlc);
 
 	can_put_echo_skb(skb, dev, 0);
 
 	/* set transmit request */
-	bfin_write16(&reg->trs2, BIT(TRANSMIT_CHL - 16));
+	bfin_write(&reg->trs2, BIT(TRANSMIT_CHL - 16));
 
 	return 0;
 }
@@ -286,26 +286,26 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 	/* get id */
 	if (isrc & BIT(RECEIVE_EXT_CHL)) {
 		/* extended frame format (EFF) */
-		cf->can_id = ((bfin_read16(&reg->chl[RECEIVE_EXT_CHL].id1)
+		cf->can_id = ((bfin_read(&reg->chl[RECEIVE_EXT_CHL].id1)
 			     & 0x1FFF) << 16)
-			     + bfin_read16(&reg->chl[RECEIVE_EXT_CHL].id0);
+			     + bfin_read(&reg->chl[RECEIVE_EXT_CHL].id0);
 		cf->can_id |= CAN_EFF_FLAG;
 		obj = RECEIVE_EXT_CHL;
 	} else {
 		/* standard frame format (SFF) */
-		cf->can_id = (bfin_read16(&reg->chl[RECEIVE_STD_CHL].id1)
+		cf->can_id = (bfin_read(&reg->chl[RECEIVE_STD_CHL].id1)
 			     & 0x1ffc) >> 2;
 		obj = RECEIVE_STD_CHL;
 	}
-	if (bfin_read16(&reg->chl[obj].id1) & RTR)
+	if (bfin_read(&reg->chl[obj].id1) & RTR)
 		cf->can_id |= CAN_RTR_FLAG;
 
 	/* get data length code */
-	cf->can_dlc = get_can_dlc(bfin_read16(&reg->chl[obj].dlc) & 0xF);
+	cf->can_dlc = get_can_dlc(bfin_read(&reg->chl[obj].dlc) & 0xF);
 
 	/* get payload */
 	for (i = 0; i < 8; i += 2) {
-		val = bfin_read16(&reg->chl[obj].data[i]);
+		val = bfin_read(&reg->chl[obj].data[i]);
 		cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
 		cf->data[6 - i] = (6 - i) < cf->can_dlc ? (val >> 8) : 0;
 	}
@@ -359,7 +359,7 @@ static int bfin_can_err(struct net_device *dev, u16 isrc, u16 status)
 
 	if (state != priv->can.state && (state == CAN_STATE_ERROR_WARNING ||
 				state == CAN_STATE_ERROR_PASSIVE)) {
-		u16 cec = bfin_read16(&reg->cec);
+		u16 cec = bfin_read(&reg->cec);
 		u8 rxerr = cec;
 		u8 txerr = cec >> 8;
 
@@ -410,23 +410,23 @@ irqreturn_t bfin_can_interrupt(int irq, void *dev_id)
 	struct net_device_stats *stats = &dev->stats;
 	u16 status, isrc;
 
-	if ((irq == priv->tx_irq) && bfin_read16(&reg->mbtif2)) {
+	if ((irq == priv->tx_irq) && bfin_read(&reg->mbtif2)) {
 		/* transmission complete interrupt */
-		bfin_write16(&reg->mbtif2, 0xFFFF);
+		bfin_write(&reg->mbtif2, 0xFFFF);
 		stats->tx_packets++;
-		stats->tx_bytes += bfin_read16(&reg->chl[TRANSMIT_CHL].dlc);
+		stats->tx_bytes += bfin_read(&reg->chl[TRANSMIT_CHL].dlc);
 		can_get_echo_skb(dev, 0);
 		netif_wake_queue(dev);
-	} else if ((irq == priv->rx_irq) && bfin_read16(&reg->mbrif1)) {
+	} else if ((irq == priv->rx_irq) && bfin_read(&reg->mbrif1)) {
 		/* receive interrupt */
-		isrc = bfin_read16(&reg->mbrif1);
-		bfin_write16(&reg->mbrif1, 0xFFFF);
+		isrc = bfin_read(&reg->mbrif1);
+		bfin_write(&reg->mbrif1, 0xFFFF);
 		bfin_can_rx(dev, isrc);
-	} else if ((irq == priv->err_irq) && bfin_read16(&reg->gis)) {
+	} else if ((irq == priv->err_irq) && bfin_read(&reg->gis)) {
 		/* error interrupt */
-		isrc = bfin_read16(&reg->gis);
-		status = bfin_read16(&reg->esr);
-		bfin_write16(&reg->gis, 0x7FF);
+		isrc = bfin_read(&reg->gis);
+		status = bfin_read(&reg->esr);
+		bfin_write(&reg->gis, 0x7FF);
 		bfin_can_err(dev, isrc, status);
 	} else {
 		return IRQ_NONE;
@@ -631,9 +631,9 @@ static int bfin_can_suspend(struct platform_device *pdev, pm_message_t mesg)
 
 	if (netif_running(dev)) {
 		/* enter sleep mode */
-		bfin_write16(&reg->control, bfin_read16(&reg->control) | SMR);
+		bfin_write(&reg->control, bfin_read(&reg->control) | SMR);
 		SSYNC();
-		while (!(bfin_read16(&reg->intr) & SMACK)) {
+		while (!(bfin_read(&reg->intr) & SMACK)) {
 			udelay(10);
 			if (--timeout == 0) {
 				dev_err(dev->dev.parent,
@@ -654,7 +654,7 @@ static int bfin_can_resume(struct platform_device *pdev)
 
 	if (netif_running(dev)) {
 		/* leave sleep mode */
-		bfin_write16(&reg->intr, 0);
+		bfin_write(&reg->intr, 0);
 		SSYNC();
 	}
 
-- 
1.7.5.3

