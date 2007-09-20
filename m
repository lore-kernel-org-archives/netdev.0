From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: be more selective about FIFO watchdog
Date: Thu, 20 Sep 2007 13:03:49 -0700
Message-ID: <20070920130349.252ecdb9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45057 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbXITUEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 16:04:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Be more selective about when to enable the ram buffer watchdog code.
It is unnecessary on XL A3 or later revs, and with Yukon FE
the buffer is so small (4K) that the watchdog detects false positives.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-09-19 15:36:32.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-20 10:43:42.000000000 -0700
@@ -816,7 +816,8 @@ static void sky2_mac_init(struct sky2_hw
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
-	if (!(hw->flags & SKY2_HW_RAMBUFFER)) {
+	/* On chips without ram buffer, pause is controled by MAC level */
+	if (sky2_read8(hw, B2_E_0) == 0) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -1271,7 +1272,7 @@ static int sky2_up(struct net_device *de
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 imask;
+	u32 imask, ramsize;
 	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
@@ -1326,13 +1327,12 @@ static int sky2_up(struct net_device *de
 
 	sky2_mac_init(hw, port);
 
-	if (hw->flags & SKY2_HW_RAMBUFFER) {
-		/* Register is number of 4K blocks on internal RAM buffer. */
-		u32 ramsize = sky2_read8(hw, B2_E_0) * 4;
+	/* Register is number of 4K blocks on internal RAM buffer. */
+	ramsize = sky2_read8(hw, B2_E_0) * 4;
+	if (ramsize > 0) {
 		u32 rxspace;
 
-		printk(KERN_DEBUG PFX "%s: ram buffer %dK\n", dev->name, ramsize);
-
+		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -1995,7 +1995,7 @@ static int sky2_change_mtu(struct net_de
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (!(hw->flags & SKY2_HW_RAMBUFFER))
+	if (sky2_read8(hw, B2_E_0) == 0)
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2526,7 +2526,7 @@ static void sky2_watchdog(unsigned long 
 			++active;
 
 			/* For chips with Rx FIFO, check if stuck */
-			if ((hw->flags & SKY2_HW_RAMBUFFER) &&
+			if ((hw->flags & SKY2_HW_FIFO_HANG_CHECK) &&
 			     sky2_rx_hung(dev)) {
 				pr_info(PFX "%s: receiver hang detected\n",
 					dev->name);
@@ -2684,8 +2684,10 @@ static int __devinit sky2_init(struct sk
 	switch(hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT
-			| SKY2_HW_NEWER_PHY
-			| SKY2_HW_RAMBUFFER;
+			| SKY2_HW_NEWER_PHY;
+		if (hw->chip_rev < 3)
+			hw->flags |= SKY2_HW_FIFO_HANG_CHECK;
+
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
@@ -2711,11 +2713,10 @@ static int __devinit sky2_init(struct sk
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_RAMBUFFER;
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK;
 		break;
 
 	case CHIP_ID_YUKON_FE:
-		hw->flags = SKY2_HW_RAMBUFFER;
 		break;
 
 	case CHIP_ID_YUKON_FE_P:
--- a/drivers/net/sky2.h	2007-09-19 10:05:28.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-20 10:44:15.000000000 -0700
@@ -2063,7 +2063,7 @@ struct sky2_hw {
 #define SKY2_HW_FIBRE_PHY	0x00000002
 #define SKY2_HW_GIGABIT		0x00000004
 #define SKY2_HW_NEWER_PHY	0x00000008
-#define SKY2_HW_RAMBUFFER	0x00000010	/* chip has RAM FIFO */
+#define SKY2_HW_FIFO_HANG_CHECK	0x00000010
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
