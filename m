From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: fix for Yukon FE (regression in 2.6.25)
Date: Mon, 4 Feb 2008 19:45:13 -0800
Message-ID: <20080204194513.700f6387@extreme>
References: <20080202105243.GA14581@vana.vc.cvut.cz>
	<20080202120203.5387d1cb@extreme>
	<47A51168.5040301@vandrovec.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Petr Vandrovec <petr@vandrovec.name>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38997 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751595AbYBEDp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 22:45:29 -0500
In-Reply-To: <47A51168.5040301@vandrovec.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Yukon FE chip has a ram buffer therefore it needs the alignment
restriction and hang check workarounds. 

Therefore:
  * Autodetect the prescence/absence of ram buffer
  * Rename the flag value to reflect this
  * Use it consistently (ie don't reread register)

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2008-02-03 10:20:43.000000000 -0800
+++ b/drivers/net/sky2.c	2008-02-03 10:32:25.000000000 -0800
@@ -855,7 +855,7 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
 	/* On chips without ram buffer, pause is controled by MAC level */
-	if (sky2_read8(hw, B2_E_0) == 0) {
+	if (!(hw->flags & SKY2_HW_RAM_BUFFER)) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -1192,7 +1192,7 @@ static struct sk_buff *sky2_rx_alloc(str
 	struct sk_buff *skb;
 	int i;
 
-	if (sky2->hw->flags & SKY2_HW_FIFO_HANG_CHECK) {
+	if (sky2->hw->flags & SKY2_HW_RAM_BUFFER) {
 		unsigned char *start;
 		/*
 		 * Workaround for a bug in FIFO that cause hang
@@ -1385,6 +1385,7 @@ static int sky2_up(struct net_device *de
 	if (ramsize > 0) {
 		u32 rxspace;
 
+		hw->flags |= SKY2_HW_RAM_BUFFER;
 		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
@@ -2023,7 +2024,7 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (sky2_read8(hw, B2_E_0) == 0)
+	if (!(hw->flags & SKY2_HW_RAM_BUFFER))
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2559,7 +2560,7 @@ static void sky2_watchdog(unsigned long 
 			++active;
 
 			/* For chips with Rx FIFO, check if stuck */
-			if ((hw->flags & SKY2_HW_FIFO_HANG_CHECK) &&
+			if ((hw->flags & SKY2_HW_RAM_BUFFER) &&
 			     sky2_rx_hung(dev)) {
 				pr_info(PFX "%s: receiver hang detected\n",
 					dev->name);
@@ -2715,11 +2716,7 @@ static int __devinit sky2_init(struct sk
 
 	switch(hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
-		hw->flags = SKY2_HW_GIGABIT
-			| SKY2_HW_NEWER_PHY;
-		if (hw->chip_rev < 3)
-			hw->flags |= SKY2_HW_FIFO_HANG_CHECK;
-
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
@@ -2745,7 +2742,7 @@ static int __devinit sky2_init(struct sk
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK;
+		hw->flags = SKY2_HW_GIGABIT;
 		break;
 
 	case CHIP_ID_YUKON_FE:
--- a/drivers/net/sky2.h	2008-02-03 10:20:43.000000000 -0800
+++ b/drivers/net/sky2.h	2008-02-03 10:26:45.000000000 -0800
@@ -2045,7 +2045,7 @@ struct sky2_hw {
 #define SKY2_HW_FIBRE_PHY	0x00000002
 #define SKY2_HW_GIGABIT		0x00000004
 #define SKY2_HW_NEWER_PHY	0x00000008
-#define SKY2_HW_FIFO_HANG_CHECK	0x00000010
+#define SKY2_HW_RAM_BUFFER	0x00000010
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
