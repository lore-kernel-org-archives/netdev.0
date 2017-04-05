From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 10/13] ftgmac100: Add a reset task and use it for link changes
Date: Wed,  5 Apr 2017 12:28:50 +1000
Message-ID: <20170405022853.8238-11-benh@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48214 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754986AbdDECaR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:30:17 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Link speed changes require a full HW reset. This isn't done
properly at the moment. It will involve delays and thus isn't
suitable to do from the link poll callback.

So let's create a reset_task that we can queue up when the
link changes. It will be useful for various cases of error
handling as well.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v2. Fix lock ordering
    Add mdio_bus mutex
---
 drivers/net/ethernet/faraday/ftgmac100.c | 87 +++++++++++++++++++++++++++-----
 1 file changed, 74 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 36f2905..61f02bf 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -74,6 +74,7 @@ struct ftgmac100 {
 	struct device *dev;
 	struct ncsi_dev *ndev;
 	struct napi_struct napi;
+	struct work_struct reset_task;
 	struct mii_bus *mii_bus;
 
 	/* Link management */
@@ -872,7 +873,6 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct phy_device *phydev = netdev->phydev;
 	int new_speed;
-	int ier;
 
 	/* We store "no link" as speed 0 */
 	if (!phydev->link)
@@ -897,20 +897,11 @@ static void ftgmac100_adjust_link(struct net_device *netdev)
 	if (!new_speed)
 		return;
 
-	ier = ioread32(priv->base + FTGMAC100_OFFSET_IER);
-
-	/* disable all interrupts */
+	/* Disable all interrupts */
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
-	netif_stop_queue(netdev);
-	ftgmac100_stop_hw(priv);
-
-	netif_start_queue(netdev);
-	ftgmac100_init_hw(priv);
-	ftgmac100_start_hw(priv);
-
-	/* re-enable interrupts */
-	iowrite32(ier, priv->base + FTGMAC100_OFFSET_IER);
+	/* Reset the adapter asynchronously */
+	schedule_work(&priv->reset_task);
 }
 
 static int ftgmac100_mii_probe(struct ftgmac100 *priv)
@@ -1135,6 +1126,61 @@ static int ftgmac100_init_all(struct ftgmac100 *priv, bool ignore_alloc_err)
 	return err;
 }
 
+static void ftgmac100_reset_task(struct work_struct *work)
+{
+	struct ftgmac100 *priv = container_of(work, struct ftgmac100,
+					      reset_task);
+	struct net_device *netdev = priv->netdev;
+	int err;
+
+	netdev_dbg(netdev, "Resetting NIC...\n");
+
+	/* Lock the world */
+	rtnl_lock();
+	if (netdev->phydev)
+		mutex_lock(&netdev->phydev->lock);
+	if (priv->mii_bus)
+		mutex_lock(&priv->mii_bus->mdio_lock);
+
+
+	/* Check if the interface is still up */
+	if (!netif_running(netdev))
+		goto bail;
+
+	/* Stop the network stack */
+	netif_trans_update(netdev);
+	napi_disable(&priv->napi);
+	netif_tx_disable(netdev);
+
+	/* Stop and reset the MAC */
+	ftgmac100_stop_hw(priv);
+	err = ftgmac100_reset_hw(priv);
+	if (err) {
+		/* Not much we can do ... it might come back... */
+		netdev_err(netdev, "attempting to continue...\n");
+	}
+
+	/* Free all rx and tx buffers */
+	ftgmac100_free_buffers(priv);
+
+	/* The ring pointers have been reset in HW, reflect this here */
+	priv->rx_pointer = 0;
+	priv->tx_clean_pointer = 0;
+	priv->tx_pointer = 0;
+	priv->tx_pending = 0;
+
+	/* Setup everything again and restart chip */
+	ftgmac100_init_all(priv, true);
+
+	netdev_dbg(netdev, "Reset done !\n");
+ bail:
+	if (priv->mii_bus)
+		mutex_unlock(&priv->mii_bus->mdio_lock);
+	if (netdev->phydev)
+		mutex_unlock(&netdev->phydev->lock);
+	rtnl_unlock();
+}
+
 static int ftgmac100_open(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
@@ -1220,6 +1266,14 @@ static int ftgmac100_stop(struct net_device *netdev)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 
+	/* Note about the reset task: We are called with the rtnl lock
+	 * held, so we are synchronized against the core of the reset
+	 * task. We must not try to synchronously cancel it otherwise
+	 * we can deadlock. But since it will test for netif_running()
+	 * which has already been cleared by the net core, we don't
+	 * anything special to do.
+	 */
+
 	/* disable all interrupts */
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
 
@@ -1395,6 +1449,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv = netdev_priv(netdev);
 	priv->netdev = netdev;
 	priv->dev = &pdev->dev;
+	INIT_WORK(&priv->reset_task, ftgmac100_reset_task);
 
 	spin_lock_init(&priv->tx_lock);
 
@@ -1498,6 +1553,12 @@ static int ftgmac100_remove(struct platform_device *pdev)
 	priv = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+
+	/* There's a small chance the reset task will have been re-queued,
+	 * during stop, make sure it's gone before we free the structure.
+	 */
+	cancel_work_sync(&priv->reset_task);
+
 	ftgmac100_destroy_mdio(netdev);
 
 	iounmap(priv->base);
-- 
2.9.3
