From: shemminger@osdl.org
Subject: [PATCH 4/9] sky2: MSI test timing
Date: Mon, 28 Aug 2006 10:00:48 -0700
Message-ID: <20060828170217.402803997@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16514 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751239AbWH1SQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:06 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-post-bug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The test for MSI IRQ could have timing issues. The PCI write needs to be 
pushed out before waiting, and the wait queue should be initialized before
the IRQ.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-25 16:05:10.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-25 16:05:14.000000000 -0700
@@ -3189,6 +3189,8 @@
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
+	init_waitqueue_head (&hw->msi_wait);
+
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
 	err = request_irq(pdev->irq, sky2_test_intr, IRQF_SHARED, DRV_NAME, hw);
@@ -3198,10 +3200,8 @@
 		return err;
 	}
 
-	init_waitqueue_head (&hw->msi_wait);
-
 	sky2_write8(hw, B0_CTST, CS_ST_SW_IRQ);
-	wmb();
+	sky2_read8(hw, B0_CTST);
 
 	wait_event_timeout(hw->msi_wait, hw->msi_detected, HZ/10);
 

--
Stephen Hemminger <shemminger@osdl.org>

