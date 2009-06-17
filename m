From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] sky2: fix shutdown synchronization
Date: Wed, 17 Jun 2009 10:30:35 -0700
Message-ID: <20090617173139.828049268@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45310 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758132AbZFQReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:03 -0400
Content-Disposition: inline; filename=sky2-rxsync-shut.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic in sky2_down was incorrect. Receiver could report status
after rx_stop was called.

The steps need to be:
   * stop new frames from being transmitted
   * shut off transmit/receive logic
   * synchronize with NAPI to process status info about transmitter
     and receiver

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:53.382997969 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:55.361810536 -0700
@@ -1815,8 +1815,6 @@ static int sky2_down(struct net_device *
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
-	synchronize_irq(hw->pdev->irq);
-
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
 
@@ -1831,9 +1829,6 @@ static int sky2_down(struct net_device *
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
-
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
 
 	/* Workaround shared GMAC reset */
@@ -1864,6 +1859,15 @@ static int sky2_down(struct net_device *
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 
+	/* Force any delayed status interrrupt and NAPI */
+	sky2_write32(hw, STAT_LEV_TIMER_CNT, 0);
+	sky2_write32(hw, STAT_TX_TIMER_CNT, 0);
+	sky2_write32(hw, STAT_ISR_TIMER_CNT, 0);
+	sky2_read8(hw, STAT_ISR_TIMER_CTRL);
+
+	synchronize_irq(hw->pdev->irq);
+	napi_synchronize(&hw->napi);
+
 	sky2_phy_power_down(hw, port);
 
 	/* turn off LED's */

-- 

