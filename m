From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.33] net: Fix ks8851 snl receive problem
Date: Mon, 21 Dec 2009 13:29:42 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A44@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Ben Dooks" <ben@simtec.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757264AbZLUVhL@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

This fixes a receive problem of the ks8851 snl network driver.  Under heavy TCP traffic the device will stop operating correctly.  First the receive interrupt is not triggered anymore.  After then the driver cannot retrieve the correct packets from the device.  A workaround for this problem is to disable the transmit done interrupt.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
This patch has some relations to two previous patches I submitted: "[PATH 2.6.32 2/3] net: Fix ks8851 snl transmit problem" and "[PATCH 2.6.32 3/3] net: Make ks8851 snl work under Beagle Zippy combo board."  Please see my replies regarding those patches.

--- linux-2.6.33-rc1.old/drivers/net/ks8851.c	2009-12-08 17:46:20.000000000 -0800
+++ linux-2.6.33-rc1.new/drivers/net/ks8851.c	2009-12-21 10:43:43.000000000 -0800
@@ -551,6 +551,13 @@ static void ks8851_irq_work(struct work_
 
 	mutex_lock(&ks->lock);
 
+	/*
+	 * Turn off hardware interrupt during receive processing.  This fixes
+	 * the receive problem under heavy TCP traffic while transmit done
+	 * is enabled.
+	 */
+	ks8851_wrreg16(ks, KS_IER, 0);
+
 	status = ks8851_rdreg16(ks, KS_ISR);
 
 	if (netif_msg_intr(ks))
@@ -621,6 +628,9 @@ static void ks8851_irq_work(struct work_
 		ks8851_wrreg16(ks, KS_RXCR1, rxc->rxcr1);
 	}
 
+	/* Re-enable hardware interrupt. */
+	ks8851_wrreg16(ks, KS_IER, ks->rc_ier);
+
 	mutex_unlock(&ks->lock);
 
 	if (status & IRQ_TXI)
