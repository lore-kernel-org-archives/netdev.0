From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/6] sky2: MSI test timing
Date: Wed, 06 Sep 2006 10:17:56 -0700
Message-ID: <20060906171921.612595000@localhost.localdomain>
References: <20060906171752.781595000@localhost.localdomain>
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19879 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751458AbWIFSKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:10:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-post-bug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The test for MSI IRQ could have timing issues. The PCI write needs to be 
pushed out before waiting, and the wait queue should be initialized before
the IRQ.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -3184,6 +3184,8 @@ static int __devinit sky2_test_msi(struc
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
+	init_waitqueue_head (&hw->msi_wait);
+
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
 	err = request_irq(pdev->irq, sky2_test_intr, SA_SHIRQ, DRV_NAME, hw);
@@ -3193,10 +3195,8 @@ static int __devinit sky2_test_msi(struc
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

