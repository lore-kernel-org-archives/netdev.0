From: Xiaotian Feng <xtfeng@gmail.com>
Subject: [PATCH] drivers/net: use tasklet_kill in device remove/close process
Date: Wed, 31 Oct 2012 18:29:57 +0800
Message-ID: <1351679397-26994-1-git-send-email-xtfeng@gmail.com>
Cc: Xiaotian Feng <xtfeng@gmail.com>,
	Xiaotian Feng <dannyfeng@tencent.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63682 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641Ab2JaK3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 06:29:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some driver uses tasklet_disable in device remove/close process,
tasklet_disable will inc tasklet->count and return. If the tasklet
is not handled yet because some softirq pressure, the tasklet will
placed on the tasklet_vec, never have a chance to excute. This might
lead to ksoftirqd heavy loaded, wakeup with pending_softirq, but
tasklet is disabled. tasklet_kill should be used in this case.

Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org 
---
 drivers/net/ethernet/jme.c                        |    8 ++++----
 drivers/net/ethernet/marvell/skge.c               |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c             |    4 ++--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 drivers/net/wireless/b43legacy/pio.c              |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 8ddf9ca..76a91f6 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1948,10 +1948,10 @@ jme_close(struct net_device *netdev)
 
 	JME_NAPI_DISABLE(jme);
 
-	tasklet_disable(&jme->linkch_task);
-	tasklet_disable(&jme->txclean_task);
-	tasklet_disable(&jme->rxclean_task);
-	tasklet_disable(&jme->rxempty_task);
+	tasklet_kill(&jme->linkch_task);
+	tasklet_kill(&jme->txclean_task);
+	tasklet_kill(&jme->rxclean_task);
+	tasklet_kill(&jme->rxempty_task);
 
 	jme_disable_rx_engine(jme);
 	jme_disable_tx_engine(jme);
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 9b9c2ac..d19a143 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4026,7 +4026,7 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 	dev0 = hw->dev[0];
 	unregister_netdev(dev0);
 
-	tasklet_disable(&hw->phy_task);
+	tasklet_kill(&hw->phy_task);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 318fee9..e558edd 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5407,8 +5407,8 @@ static int netdev_close(struct net_device *dev)
 		/* Delay for receive task to stop scheduling itself. */
 		msleep(2000 / HZ);
 
-		tasklet_disable(&hw_priv->rx_tasklet);
-		tasklet_disable(&hw_priv->tx_tasklet);
+		tasklet_kill(&hw_priv->rx_tasklet);
+		tasklet_kill(&hw_priv->tx_tasklet);
 		free_irq(dev->irq, hw_priv->dev);
 
 		transmit_cleanup(hw_priv, 0);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 0793299..1d04754 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -990,7 +990,7 @@ static int axienet_stop(struct net_device *ndev)
 	axienet_setoptions(ndev, lp->options &
 			   ~(XAE_OPTION_TXEN | XAE_OPTION_RXEN));
 
-	tasklet_disable(&lp->dma_err_tasklet);
+	tasklet_kill(&lp->dma_err_tasklet);
 
 	free_irq(lp->tx_irq, ndev);
 	free_irq(lp->rx_irq, ndev);
diff --git a/drivers/net/wireless/b43legacy/pio.c b/drivers/net/wireless/b43legacy/pio.c
index 192251a..282eede 100644
--- a/drivers/net/wireless/b43legacy/pio.c
+++ b/drivers/net/wireless/b43legacy/pio.c
@@ -382,7 +382,7 @@ static void cancel_transfers(struct b43legacy_pioqueue *queue)
 {
 	struct b43legacy_pio_txpacket *packet, *tmp_packet;
 
-	tasklet_disable(&queue->txtask);
+	tasklet_kill(&queue->txtask);
 
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txrunning, list)
 		free_txpacket(packet, 0);
-- 
1.7.9.5
