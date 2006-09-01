From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] skge: pci_post bugs
Date: Fri, 01 Sep 2006 15:53:51 -0700
Message-ID: <20060901225449.853621217@zqx3.pdx.osdl.net>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6543 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751207AbWIAW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:57:47 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-pci-post.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several places where this driver needs to ensure that 
PCI accesses have completed before releasing locks. These maybe related
to the problem (not verified):
	http://bugzilla.kernel.org/show_bug.cgi?id=6142

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- netdev-2.6.orig/drivers/net/skge.c
+++ netdev-2.6/drivers/net/skge.c
@@ -2747,7 +2747,7 @@ static int skge_poll(struct net_device *
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= rxirqmask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
-	mmiowb();
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 
 	return 0;
@@ -2881,6 +2881,7 @@ static void skge_extirq(void *arg)
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= IS_EXT_REG;
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 }
 
@@ -2955,6 +2956,7 @@ static irqreturn_t skge_intr(int irq, vo
 		skge_error_irq(hw);
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock(&hw->hw_lock);
 
 	return IRQ_HANDLED;
@@ -3424,6 +3426,7 @@ static void __devexit skge_remove(struct
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
 	skge_write32(hw, B0_IMSK, 0);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 
 	skge_write16(hw, B0_LED, LED_STAT_OFF);

--


-- 
VGER BF report: H 0.178292
