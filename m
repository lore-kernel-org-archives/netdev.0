From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2] can: c_can_pci: fix compilation on non HAVE_CLK archs
Date: Wed, 20 Jun 2012 18:04:26 +0200
Message-ID: <1340208266-22098-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Federico Vaga <federico.vaga@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37805 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756868Ab2FTQEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 12:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit:

  5b92da0 c_can_pci: generic module for C_CAN/D_CAN on PCI

the c_can_pci driver has been added. It uses clk_*() functions
resulting in a link error on archs without clock support. This
patch removed these clk_() functions as these parts of the driver
are not tested.

Cc: Federico Vaga <federico.vaga@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
Resending with the missing "v2".

Marc

 drivers/net/can/c_can/c_can_pci.c |   29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 914aecf..1011146 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -13,7 +13,6 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/clk.h>
 #include <linux/pci.h>
 
 #include <linux/can/dev.h>
@@ -30,7 +29,7 @@ struct c_can_pci_data {
 	enum c_can_dev_id type;
 	/* Set the register alignment in the memory */
 	enum c_can_pci_reg_align reg_align;
-	/* Set the frequency if clk is not usable */
+	/* Set the frequency */
 	unsigned int freq;
 };
 
@@ -71,7 +70,6 @@ static int __devinit c_can_pci_probe(struct pci_dev *pdev,
 	struct c_can_priv *priv;
 	struct net_device *dev;
 	void __iomem *addr;
-	struct clk *clk;
 	int ret;
 
 	ret = pci_enable_device(pdev);
@@ -113,18 +111,11 @@ static int __devinit c_can_pci_probe(struct pci_dev *pdev,
 	priv->base = addr;
 
 	if (!c_can_pci_data->freq) {
-		/* get the appropriate clk */
-		clk = clk_get(&pdev->dev, NULL);
-		if (IS_ERR(clk)) {
-			dev_err(&pdev->dev, "no clock defined\n");
-			ret = -ENODEV;
-			goto out_free_c_can;
-		}
-		priv->can.clock.freq = clk_get_rate(clk);
-		priv->priv = clk;
+		dev_err(&pdev->dev, "no clock frequency defined\n");
+		ret = -ENODEV;
+		goto out_free_c_can;
 	} else {
 		priv->can.clock.freq = c_can_pci_data->freq;
-		priv->priv = NULL;
 	}
 
 	/* Configure CAN type */
@@ -138,7 +129,7 @@ static int __devinit c_can_pci_probe(struct pci_dev *pdev,
 		break;
 	default:
 		ret = -EINVAL;
-		goto out_free_clock;
+		goto out_free_c_can;
 	}
 
 	/* Configure access to registers */
@@ -153,14 +144,14 @@ static int __devinit c_can_pci_probe(struct pci_dev *pdev,
 		break;
 	default:
 		ret = -EINVAL;
-		goto out_free_clock;
+		goto out_free_c_can;
 	}
 
 	ret = register_c_can_dev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
 			KBUILD_MODNAME, ret);
-		goto out_free_clock;
+		goto out_free_c_can;
 	}
 
 	dev_dbg(&pdev->dev, "%s device registered (regs=%p, irq=%d)\n",
@@ -168,9 +159,6 @@ static int __devinit c_can_pci_probe(struct pci_dev *pdev,
 
 	return 0;
 
-out_free_clock:
-	if (priv->priv)
-		clk_put(priv->priv);
 out_free_c_can:
 	pci_set_drvdata(pdev, NULL);
 	free_c_can_dev(dev);
@@ -193,9 +181,6 @@ static void __devexit c_can_pci_remove(struct pci_dev *pdev)
 
 	unregister_c_can_dev(dev);
 
-	if (priv->priv)
-		clk_put(priv->priv);
-
 	pci_set_drvdata(pdev, NULL);
 	free_c_can_dev(dev);
 
-- 
1.7.10
