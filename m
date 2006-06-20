From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.17] AT91RM9200 Ethernet #4: Suspend/Resume
Date: 20 Jun 2006 12:19:13 +0200
Message-ID: <1150798753.15586.362.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sanpeople.com ([196.41.13.122]:41995 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP id S932582AbWFTKYW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:24:22 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds power-management (suspend/resume) support to the AT91RM9200
Ethernet driver.
Patch from David Brownell.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c linux-2.6.17-rmk/drivers/net/arm/at91_ether.c
--- linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c	Tue Jun 20 11:16:31 2006
+++ linux-2.6.17-rmk/drivers/net/arm/at91_ether.c	Tue Jun 20 11:18:45 2006
@@ -1128,10 +1128,54 @@
 	return 0;
 }
 
+#ifdef CONFIG_PM
+
+static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
+{
+	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
+	struct net_device *net_dev = platform_get_drvdata(pdev);
+	int phy_irq = lp->board_data.phy_irq_pin;
+
+	if (netif_running(net_dev)) {
+		if (phy_irq)
+			disable_irq(phy_irq);
+
+		netif_stop_queue(net_dev);
+		netif_device_detach(net_dev);
+
+		clk_disable(lp->ether_clk);
+	}
+	return 0;
+}
+
+static int at91ether_resume(struct platform_device *pdev)
+{
+	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
+	struct net_device *net_dev = platform_get_drvdata(pdev);
+	int phy_irq = lp->board_data.phy_irq_pin;
+
+	if (netif_running(net_dev)) {
+		clk_enable(lp->ether_clk);
+
+		netif_device_attach(net_dev);
+		netif_start_queue(net_dev);
+
+		if (phy_irq)
+			enable_irq(phy_irq);
+	}
+	return 0;
+}
+
+#else
+#define at91ether_suspend	NULL
+#define at91ether_resume	NULL
+#endif
+
 static struct platform_driver at91ether_driver = {
 	.probe		= at91ether_probe,
 	.remove		= __devexit_p(at91ether_remove),
-	/* FIXME:  support suspend and resume */
+	.suspend	= at91ether_suspend,
+	.resume		= at91ether_resume,
 	.driver		= {
 		.name	= DRV_NAME,
 		.owner	= THIS_MODULE,



