From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 2/9] sky2: status irq hang fix
Date: Mon, 08 May 2006 15:11:27 -0700
Message-ID: <20060508221228.361788000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12733 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751321AbWEHWXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003747
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:49 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNm2o023546
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-status-irq-race.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The status interrupt flag should be cleared before processing,
not afterwards to avoid race. Need to process in poll routine
even if no new interrupt status. This is a normal occurrence when
more than 64 frames (NAPI weight) are processed in one poll routine.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-02 09:42:18.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-02 09:46:39.000000000 -0700
@@ -2105,45 +2105,42 @@
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
-	if (unlikely(status & ~Y2_IS_STAT_BMU)) {
-		if (status & Y2_IS_HW_ERR)
-			sky2_hw_intr(hw);
+	if (status & Y2_IS_HW_ERR)
+		sky2_hw_intr(hw);
 
-		if (status & Y2_IS_IRQ_PHY1)
-			sky2_phy_intr(hw, 0);
+	if (status & Y2_IS_IRQ_PHY1)
+		sky2_phy_intr(hw, 0);
 
-		if (status & Y2_IS_IRQ_PHY2)
-			sky2_phy_intr(hw, 1);
+	if (status & Y2_IS_IRQ_PHY2)
+		sky2_phy_intr(hw, 1);
 
-		if (status & Y2_IS_IRQ_MAC1)
-			sky2_mac_intr(hw, 0);
+	if (status & Y2_IS_IRQ_MAC1)
+		sky2_mac_intr(hw, 0);
 
-		if (status & Y2_IS_IRQ_MAC2)
-			sky2_mac_intr(hw, 1);
+	if (status & Y2_IS_IRQ_MAC2)
+		sky2_mac_intr(hw, 1);
 
-		if (status & Y2_IS_CHK_RX1)
-			sky2_descriptor_error(hw, 0, "receive", Y2_IS_CHK_RX1);
+	if (status & Y2_IS_CHK_RX1)
+		sky2_descriptor_error(hw, 0, "receive", Y2_IS_CHK_RX1);
 
-		if (status & Y2_IS_CHK_RX2)
-			sky2_descriptor_error(hw, 1, "receive", Y2_IS_CHK_RX2);
+	if (status & Y2_IS_CHK_RX2)
+		sky2_descriptor_error(hw, 1, "receive", Y2_IS_CHK_RX2);
 
-		if (status & Y2_IS_CHK_TXA1)
-			sky2_descriptor_error(hw, 0, "transmit", Y2_IS_CHK_TXA1);
+	if (status & Y2_IS_CHK_TXA1)
+		sky2_descriptor_error(hw, 0, "transmit", Y2_IS_CHK_TXA1);
 
-		if (status & Y2_IS_CHK_TXA2)
-			sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
-	}
+	if (status & Y2_IS_CHK_TXA2)
+		sky2_descriptor_error(hw, 1, "transmit", Y2_IS_CHK_TXA2);
 
-	if (status & Y2_IS_STAT_BMU) {
-		work_done = sky2_status_intr(hw, work_limit);
-		*budget -= work_done;
-		dev0->quota -= work_done;
+	if (status & Y2_IS_STAT_BMU)
+		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 
-		if (work_done >= work_limit)
-			return 1;
+	work_done = sky2_status_intr(hw, work_limit);
+	*budget -= work_done;
+	dev0->quota -= work_done;
 
-		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-	}
+	if (work_done >= work_limit)
+		return 1;
 
 	mod_timer(&hw->idle_timer, jiffies + HZ);
 

--

