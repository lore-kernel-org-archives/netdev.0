From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sky2: fix hang in napi_disable
Date: Thu, 17 Nov 2011 16:37:35 -0800
Message-ID: <20111117163735.0a16660b@nehalam.linuxnetplumber.net>
References: <20111116234254.319625694@vyatta.com>
 <20111116234344.526517614@vyatta.com>
 <87r517w2z0.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37764 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088Ab1KRAhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 19:37:38 -0500
In-Reply-To: <87r517w2z0.fsf@turtle.gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IRQ was never initialized, then calling napi_disable() would hang.
Add more bookkeeping to track whether IRQ was ever initialized.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-17 11:10:35.938076778 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-17 11:15:49.527882932 -0800
@@ -1723,6 +1723,8 @@ static int sky2_setup_irq(struct sky2_hw
 	if (err)
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
 	else {
+		hw->flags |= SKY2_HW_IRQ_SETUP;
+
 		napi_enable(&hw->napi);
 		sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 		sky2_read32(hw, B0_IMSK);
@@ -2120,6 +2122,7 @@ static int sky2_close(struct net_device
 
 		napi_disable(&hw->napi);
 		free_irq(hw->pdev->irq, hw);
+		hw->flags &= ~SKY2_HW_IRQ_SETUP;
 	} else {
 		u32 imask;
 
@@ -3423,12 +3426,13 @@ static void sky2_all_down(struct sky2_hw
 {
 	int i;
 
-	sky2_read32(hw, B0_IMSK);
-	sky2_write32(hw, B0_IMSK, 0);
+	if (hw->flags & SKY2_HW_IRQ_SETUP) {
+		sky2_read32(hw, B0_IMSK);
+		sky2_write32(hw, B0_IMSK, 0);
 
-	if (hw->ports > 1 || netif_running(hw->dev[0]))
 		synchronize_irq(hw->pdev->irq);
-	napi_disable(&hw->napi);
+		napi_disable(&hw->napi);
+	}
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
@@ -3445,7 +3449,7 @@ static void sky2_all_down(struct sky2_hw
 
 static void sky2_all_up(struct sky2_hw *hw)
 {
-	u32 imask = 0;
+	u32 imask = Y2_IS_BASE;
 	int i;
 
 	for (i = 0; i < hw->ports; i++) {
@@ -3461,8 +3465,7 @@ static void sky2_all_up(struct sky2_hw *
 		netif_wake_queue(dev);
 	}
 
-	if (imask || hw->ports > 1) {
-		imask |= Y2_IS_BASE;
+	if (hw->flags & SKY2_HW_IRQ_SETUP) {
 		sky2_write32(hw, B0_IMSK, imask);
 		sky2_read32(hw, B0_IMSK);
 		sky2_read32(hw, B0_Y2_SP_LISR);
--- a/drivers/net/ethernet/marvell/sky2.h	2011-11-16 15:15:40.964280527 -0800
+++ b/drivers/net/ethernet/marvell/sky2.h	2011-11-17 11:13:00.154858718 -0800
@@ -2287,6 +2287,7 @@ struct sky2_hw {
 #define SKY2_HW_RSS_BROKEN	0x00000100
 #define SKY2_HW_VLAN_BROKEN     0x00000200
 #define SKY2_HW_RSS_CHKSUM	0x00000400	/* RSS requires chksum */
+#define SKY2_HW_IRQ_SETUP	0x00000800
 
 	u8	     	     chip_id;
 	u8		     chip_rev;
