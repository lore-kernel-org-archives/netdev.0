From: Xiaotian Feng <xtfeng@gmail.com>
Subject: [PATCH] drivers/net: fix tasklet misuse issue
Date: Wed, 14 Nov 2012 13:47:36 +0800
Message-ID: <1352872056-5637-1-git-send-email-xtfeng@gmail.com>
Cc: Xiaotian Feng <xtfeng@gmail.com>,
	Xiaotian Feng <dannyfeng@tencent.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 175c0dff, drivers uses tasklet_kill to avoid put disabled tasklet
on the tasklet vec. But some of the drivers uses tasklet_init & tasklet_disable
in the driver init code, then tasklet_enable when it is opened. This makes
tasklet_enable on a killed tasklet and make ksoftirqd crazy then. Normally,
drivers should use tasklet_init/tasklet_kill on device open/remove, and use
tasklet_disable/tasklet_enable on device suspend/resume.

Reported-by: Peter Wu <lekensteyn@gmail.com>
Tested-by: Peter Wu <lekensteyn@gmail.com>
Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org 
---
 drivers/net/ethernet/jme.c                        |   28 ++++++---------------
 drivers/net/ethernet/micrel/ksz884x.c             |   16 +++---------
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   12 ++++-----
 3 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 92317e9..c0314c1 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1860,10 +1860,14 @@ jme_open(struct net_device *netdev)
 	jme_clear_pm(jme);
 	JME_NAPI_ENABLE(jme);
 
-	tasklet_enable(&jme->linkch_task);
-	tasklet_enable(&jme->txclean_task);
-	tasklet_hi_enable(&jme->rxclean_task);
-	tasklet_hi_enable(&jme->rxempty_task);
+	tasklet_init(&jme->linkch_task, jme_link_change_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->txclean_task, jme_tx_clean_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->rxclean_task, jme_rx_clean_tasklet,
+		     (unsigned long) jme);
+	tasklet_init(&jme->rxempty_task, jme_rx_empty_tasklet,
+		     (unsigned long) jme);
 
 	rc = jme_request_irq(jme);
 	if (rc)
@@ -3079,22 +3083,6 @@ jme_init_one(struct pci_dev *pdev,
 	tasklet_init(&jme->pcc_task,
 		     jme_pcc_tasklet,
 		     (unsigned long) jme);
-	tasklet_init(&jme->linkch_task,
-		     jme_link_change_tasklet,
-		     (unsigned long) jme);
-	tasklet_init(&jme->txclean_task,
-		     jme_tx_clean_tasklet,
-		     (unsigned long) jme);
-	tasklet_init(&jme->rxclean_task,
-		     jme_rx_clean_tasklet,
-		     (unsigned long) jme);
-	tasklet_init(&jme->rxempty_task,
-		     jme_rx_empty_tasklet,
-		     (unsigned long) jme);
-	tasklet_disable_nosync(&jme->linkch_task);
-	tasklet_disable_nosync(&jme->txclean_task);
-	tasklet_disable_nosync(&jme->rxclean_task);
-	tasklet_disable_nosync(&jme->rxempty_task);
 	jme->dpi.cur = PCC_P1;
 
 	jme->reg_ghc = 0;
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e558edd..b66b285 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5459,8 +5459,10 @@ static int prepare_hardware(struct net_device *dev)
 	rc = request_irq(dev->irq, netdev_intr, IRQF_SHARED, dev->name, dev);
 	if (rc)
 		return rc;
-	tasklet_enable(&hw_priv->rx_tasklet);
-	tasklet_enable(&hw_priv->tx_tasklet);
+	tasklet_init(&hw_priv->rx_tasklet, rx_proc_task,
+		     (unsigned long) hw_priv);
+	tasklet_init(&hw_priv->tx_tasklet, tx_proc_task,
+		     (unsigned long) hw_priv);
 
 	hw->promiscuous = 0;
 	hw->all_multi = 0;
@@ -7033,16 +7035,6 @@ static int __devinit pcidev_init(struct pci_dev *pdev,
 	spin_lock_init(&hw_priv->hwlock);
 	mutex_init(&hw_priv->lock);
 
-	/* tasklet is enabled. */
-	tasklet_init(&hw_priv->rx_tasklet, rx_proc_task,
-		(unsigned long) hw_priv);
-	tasklet_init(&hw_priv->tx_tasklet, tx_proc_task,
-		(unsigned long) hw_priv);
-
-	/* tasklet_enable will decrement the atomic counter. */
-	tasklet_disable(&hw_priv->rx_tasklet);
-	tasklet_disable(&hw_priv->tx_tasklet);
-
 	for (i = 0; i < TOTAL_PORT_NUM; i++)
 		init_waitqueue_head(&hw_priv->counter[i].counter);
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 1d04754..7740f4b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -942,6 +942,10 @@ static int axienet_open(struct net_device *ndev)
 		phy_start(lp->phy_dev);
 	}
 
+	/* Enable tasklets for Axi DMA error handling */
+	tasklet_init(&lp->dma_err_tasklet, axienet_dma_err_handler,
+		     (unsigned long) lp);
+
 	/* Enable interrupts for Axi DMA Tx */
 	ret = request_irq(lp->tx_irq, axienet_tx_irq, 0, ndev->name, ndev);
 	if (ret)
@@ -950,8 +954,7 @@ static int axienet_open(struct net_device *ndev)
 	ret = request_irq(lp->rx_irq, axienet_rx_irq, 0, ndev->name, ndev);
 	if (ret)
 		goto err_rx_irq;
-	/* Enable tasklets for Axi DMA error handling */
-	tasklet_enable(&lp->dma_err_tasklet);
+
 	return 0;
 
 err_rx_irq:
@@ -960,6 +963,7 @@ err_tx_irq:
 	if (lp->phy_dev)
 		phy_disconnect(lp->phy_dev);
 	lp->phy_dev = NULL;
+	tasklet_kill(&lp->dma_err_tasklet);
 	dev_err(lp->dev, "request_irq() failed\n");
 	return ret;
 }
@@ -1613,10 +1617,6 @@ static int __devinit axienet_of_probe(struct platform_device *op)
 		goto err_iounmap_2;
 	}
 
-	tasklet_init(&lp->dma_err_tasklet, axienet_dma_err_handler,
-		     (unsigned long) lp);
-	tasklet_disable(&lp->dma_err_tasklet);
-
 	return 0;
 
 err_iounmap_2:
-- 
1.7.9.6 (Apple Git-31.1)
