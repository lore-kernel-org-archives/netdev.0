From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.32 3/3] net: Make ks8851 snl work under Beagle Zippy combo board
Date: Thu, 3 Dec 2009 13:30:03 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A42@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Ben Dooks" <ben@simtec.co.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754331AbZLCVa5@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

The Micrel KSZ8851 SNL Ethernet chip is used in the OMAP Beagle Zippy combo board.  Requesting interrupt using level triggering flag hangs the system because the interrupt handling routine is called continually.  Using edge triggering avoids this problem.  As a result, disabling interrupt may not be necessary.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
diff -urpN linux-2.6.32.old/drivers/net/ks8851.c linux-2.6.32.new/drivers/net/ks8851.c
--- linux-2.6.32.old/drivers/net/ks8851.c	2009-11-03 11:37:49.000000000 -0800
+++ linux-2.6.32.new/drivers/net/ks8851.c	2009-12-02 15:31:39.000000000 -0800
@@ -398,7 +398,6 @@ static irqreturn_t ks8851_irq(int irq, v
 {
 	struct ks8851_net *ks = pw;
 
-	disable_irq_nosync(irq);
 	schedule_work(&ks->irq_work);
 	return IRQ_HANDLED;
 }
@@ -611,8 +610,6 @@ static void ks8851_irq_work(struct work_
 	}
 
 	mutex_unlock(&ks->lock);
-
-	enable_irq(ks->netdev->irq);
 }
 
 /**
@@ -1284,7 +1281,7 @@ static int __devinit ks8851_probe(struct
 	ks8851_init_mac(ks);
 	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
-	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
+	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_FALLING,
 			  ndev->name, ks);
 	if (ret < 0) {
 		dev_err(&spi->dev, "failed to get irq\n");
