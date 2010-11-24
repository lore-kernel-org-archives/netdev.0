From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 15/17 v2] can: EG20T PCH: Move MSI processing
 open/close to probe/remove
Date: Wed, 24 Nov 2010 16:38:49 +0900
Message-ID: <4CECC109.4010407__28923.7526980743$1290584418$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:31955 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452Ab0KXHjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 02:39:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move MSI processing to probe/remove processing.
Currently, in case this driver is integrated as module, and when this
module is re-installed, no interrupts is to be occurred.
For the above issue, move MSI processing to open/release processing.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index df14569..c612a99 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -859,15 +859,6 @@ static int pch_can_open(struct net_device *ndev)
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	int retval;
 -	retval = pci_enable_msi(priv->dev);
-	if (retval) {
-		netdev_err(ndev, "PCH CAN opened without MSI\n");
-		priv->use_msi = 0;
-	} else {
-		netdev_err(ndev, "PCH CAN opened with MSI\n");
-		priv->use_msi = 1;
-	}
-
 	/* Regstering the interrupt. */
 	retval = request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED,
 			     ndev->name, ndev);
@@ -893,9 +884,6 @@ static int pch_can_open(struct net_device *ndev)
 err_open_candev:
 	free_irq(priv->dev->irq, ndev);
 req_irq_err:
-	if (priv->use_msi)
-		pci_disable_msi(priv->dev);
-
 	pch_can_release(priv);
  	return retval;
@@ -909,8 +897,6 @@ static int pch_close(struct net_device *ndev)
 	napi_disable(&priv->napi);
 	pch_can_release(priv);
 	free_irq(priv->dev->irq, ndev);
-	if (priv->use_msi)
-		pci_disable_msi(priv->dev);
 	close_candev(ndev);
 	priv->can.state = CAN_STATE_STOPPED;
 	return 0;
@@ -993,12 +979,14 @@ static void __devexit pch_can_remove(struct
pci_dev *pdev)
 	struct pch_can_priv *priv = netdev_priv(ndev);
  	unregister_candev(priv->ndev);
-	free_candev(priv->ndev);
 	pci_iounmap(pdev, priv->regs);
+	if (priv->use_msi)
+		pci_disable_msi(priv->dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	pch_can_reset(priv);
+	free_candev(priv->ndev);
 }
  #ifdef CONFIG_PM
@@ -1255,6 +1243,15 @@ static int __devinit pch_can_probe(struct pci_dev
*pdev,
  	netif_napi_add(ndev, &priv->napi, pch_can_poll, PCH_RX_OBJ_END);
 +	rc = pci_enable_msi(priv->dev);
+	if (rc) {
+		netdev_err(ndev, "PCH CAN opened without MSI\n");
+		priv->use_msi = 0;
+	} else {
+		netdev_err(ndev, "PCH CAN opened with MSI\n");
+		priv->use_msi = 1;
+	}
+
 	rc = register_candev(ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Failed register_candev %d\n", rc);
@@ -1264,6 +1261,8 @@ static int __devinit pch_can_probe(struct pci_dev
*pdev,
 	return 0;
  probe_exit_reg_candev:
+	if (priv->use_msi)
+		pci_disable_msi(priv->dev);
 	free_candev(ndev);
 probe_exit_alloc_candev:
 	pci_iounmap(pdev, addr);
-- 
1.6.0.6

