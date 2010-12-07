From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH net-next-2.6 v8 16/20] CAN : Move MSI processing to
	probe/remove processing.
Date: Tue, 07 Dec 2010 20:10:38 +0900
Message-ID: <4CFE162E.9080002@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently, in case this driver is integrated as module, and when this
module is re-installed, no interrupts is to be occurred.
For the above issue, move MSI processing to open/release processing.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index a1fd3be..ace1fe7 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -845,15 +845,6 @@ static int pch_can_open(struct net_device *ndev)
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
@@ -879,9 +870,6 @@ static int pch_can_open(struct net_device *ndev)
 err_open_candev:
 	free_irq(priv->dev->irq, ndev);
 req_irq_err:
-	if (priv->use_msi)
-		pci_disable_msi(priv->dev);
-
 	pch_can_release(priv);
 
 	return retval;
@@ -895,8 +883,6 @@ static int pch_close(struct net_device *ndev)
 	napi_disable(&priv->napi);
 	pch_can_release(priv);
 	free_irq(priv->dev->irq, ndev);
-	if (priv->use_msi)
-		pci_disable_msi(priv->dev);
 	close_candev(ndev);
 	priv->can.state = CAN_STATE_STOPPED;
 	return 0;
@@ -975,12 +961,14 @@ static void __devexit pch_can_remove(struct pci_dev *pdev)
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
@@ -1244,6 +1232,15 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 
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
@@ -1253,6 +1250,8 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 	return 0;
 
 probe_exit_reg_candev:
+	if (priv->use_msi)
+		pci_disable_msi(priv->dev);
 	free_candev(ndev);
 probe_exit_alloc_candev:
 	pci_iounmap(pdev, addr);
-- 
1.6.0.6
