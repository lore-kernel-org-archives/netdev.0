From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] skge: irq lock race
Date: Fri, 01 Sep 2006 15:53:48 -0700
Message-ID: <20060901225449.239532256@zqx3.pdx.osdl.net>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11919 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751171AbWIAW6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:58:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-irq-lock-order.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver needs to access the IRQ status inside of lock to avoid
races with other places changing IRQ mask etc. This may be related
to some of the SMP bugs reported against skge in kernel bugzilla.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netdev-2.6.orig/drivers/net/skge.c
+++ netdev-2.6/drivers/net/skge.c
@@ -2891,13 +2891,15 @@ static irqreturn_t skge_intr(int irq, vo
 {
 	struct skge_hw *hw = dev_id;
 	u32 status;
+	int handled = 0;
 
+	spin_lock(&hw->hw_lock);
 	/* Reading this register masks IRQ */
 	status = skge_read32(hw, B0_SP_ISRC);
 	if (status == 0)
-		return IRQ_NONE;
+		goto out;
 
-	spin_lock(&hw->hw_lock);
+	handled = 1;
 	status &= hw->intr_mask;
 	if (status & IS_EXT_REG) {
 		hw->intr_mask &= ~IS_EXT_REG;
@@ -2959,9 +2961,10 @@ static irqreturn_t skge_intr(int irq, vo
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
+out:
 	spin_unlock(&hw->hw_lock);
 
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(handled);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER

--


-- 
VGER BF report: H 0.00723675
