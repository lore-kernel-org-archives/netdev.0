From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 02/13] KSZ8851-SNL: Fix receive interrupt problem.
Date: Fri, 30 Apr 2010 00:16:23 +0100
Message-ID: <20100429231739.628756349@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932420Ab0D3Vs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:27 -0400
Content-Disposition: inline; filename=thirdparty/micrel/ks8851-rx-fixeml.txt
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@micrel.com>

This fixes a receive problem of the ks8851 snl network driver.

Under heavy TCP traffic the device will stop operating correctly. First
the receive interrupt is not triggered anymore.  After then the driver
cannot retrieve the correct packets from the device.  A workaround for
this problem is to disable the transmit done interrupt.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
[ben@simtec.co.uk: cleaned up header]
Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
---
 drivers/net/ks8851.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-28 23:24:20.737026841 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 00:51:12.489525834 +0900
@@ -553,6 +553,13 @@ static void ks8851_irq_work(struct work_
 
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
@@ -610,6 +617,9 @@ static void ks8851_irq_work(struct work_
 		ks8851_wrreg16(ks, KS_RXCR1, rxc->rxcr1);
 	}
 
+	/* Re-enable hardware interrupt. */
+	ks8851_wrreg16(ks, KS_IER, ks->rc_ier);
+
 	mutex_unlock(&ks->lock);
 
 	enable_irq(ks->netdev->irq);

