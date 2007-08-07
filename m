From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] sky2: backport patch
Date: Tue, 7 Aug 2007 17:14:15 -0400
Message-ID: <20070807171415.6892a070@oldman>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
	<20070807185631.GA19140@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43773 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965482AbXHGVOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 17:14:10 -0400
In-Reply-To: <20070807185631.GA19140@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any volunteers to test this, it has a backport for the three main stability patches:
 1. carrier management
 2. lost irq timer
 3. rechecking for packets in poll
 4. overlength packet hang.

I am away from any sky2 hardware for another week, but others maybe
able to validate this.

--- a/drivers/net/sky2.c	2007-07-20 04:30:14.000000000 -0400
+++ b/drivers/net/sky2.c	2007-08-07 17:08:21.000000000 -0400
@@ -96,7 +96,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 0;
+static int idle_timeout = 100;
 module_param(idle_timeout, int, 0);
 MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
 
@@ -1234,6 +1234,8 @@ static int sky2_up(struct net_device *de
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
+	netif_carrier_off(dev);
+
 	/* must be power of 2 */
 	sky2->tx_le = pci_alloc_consistent(hw->pdev,
 					   TX_RING_SIZE *
@@ -1573,7 +1575,6 @@ static int sky2_down(struct net_device *
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
-	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1625,6 +1626,8 @@ static int sky2_down(struct net_device *
 
 	sky2_phy_power(hw, port, 0);
 
+	netif_carrier_off(dev);
+
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
@@ -1689,7 +1692,6 @@ static void sky2_link_up(struct sky2_por
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
 	netif_carrier_on(sky2->netdev);
-	netif_wake_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
@@ -1741,7 +1743,6 @@ static void sky2_link_down(struct sky2_p
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
 	netif_carrier_off(sky2->netdev);
-	netif_stop_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
@@ -2064,6 +2065,9 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
+	if (status >> 16 != length)
+		goto len_mismatch;
+
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2073,6 +2077,11 @@ resubmit:
 
 	return skb;
 
+len_mismatch:
+	/* Truncation of overlength packets
+	   causes PHY length to not match MAC length */
+	++sky2->net_stats.rx_length_errors;
+
 error:
 	++sky2->net_stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {
@@ -2441,17 +2450,24 @@ static int sky2_poll(struct net_device *
 		sky2_phy_intr(hw, 1);
 
 	work_done = sky2_status_intr(hw, work_limit);
-	if (work_done < work_limit) {
-		netif_rx_complete(dev0);
+	*budget -= work_done;
+	dev0->quota -= work_done;
 
-		/* end of interrupt, re-enables also acts as I/O synchronization */
-		sky2_read32(hw, B0_Y2_SP_LISR);
-		return 0;
-	} else {
-		*budget -= work_done;
-		dev0->quota -= work_done;
+	/* More work? */
+ 	if (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX))
 		return 1;
+
+	/* Bug/Errata workaround?
+	 * Need to kick the TX irq moderation timer.
+	 */
+	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
 	}
+	netif_rx_complete(dev0);
+
+	sky2_read32(hw, B0_Y2_SP_LISR);
+	return 0;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)
@@ -3486,10 +3502,6 @@ static __devinit struct net_device *sky2
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	/* device is off until link detection */
-	netif_carrier_off(dev);
-	netif_stop_queue(dev);
-
 	return dev;
 }
 
