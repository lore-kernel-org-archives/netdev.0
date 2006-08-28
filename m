From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] skge: pci bus post fixes
Date: Mon, 28 Aug 2006 16:19:36 -0700
Message-ID: <20060828232038.060731488@localhost.localdomain>
References: <20060828231934.477469235@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35206 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964895AbWH1Xam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 19:30:42 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-pci-post.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the end of a critical section, we need to force the PCI write
to complete by doing a read.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
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
Stephen Hemminger <shemminger@osdl.org>

