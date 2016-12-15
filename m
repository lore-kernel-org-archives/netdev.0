From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 15 Dec 2016 23:33:22 +0100
Message-ID: <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd> <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd> <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd> <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------64BF7E40EBE405D314B2779C"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------64BF7E40EBE405D314B2779C
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 15.12.2016 22:32, Lino Sanfilippo wrote:

> Ah ok. Then maybe priv->hw->dma->stop_tx() does not do the job correctly (stop the
> tx path properly) and the HW is still active on the tx path while the tx buffers are
> freed. OTOH stmmac_release() also stops the phy before the tx (and rx) paths are stopped.
> Did you try to stop the phy fist in stmmac_tx_err_work(), too?
> 
> Regards,
> Lino
> 

And this is the "sledgehammer" approach: Do a complete shutdown and restart
of the hardware in case of tx error (against net-next and only compile tested).


--------------64BF7E40EBE405D314B2779C
Content-Type: text/x-patch;
 name="0001-Sledgehammer.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Sledgehammer.patch"

>From 0eda87ce6cbc2fb6d25653f30121f30f89332199 Mon Sep 17 00:00:00 2001
From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Thu, 15 Dec 2016 23:18:15 +0100
Subject: [PATCH] Sledgehammer

---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 70 ++++++++++-------------
 2 files changed, 31 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index eab04ae..9c240d7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -131,6 +131,7 @@ struct stmmac_priv {
 	u32 rx_tail_addr;
 	u32 tx_tail_addr;
 	u32 mss;
+	struct work_struct tx_err_work;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbgfs_dir;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3e40578..7546574 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1403,37 +1403,6 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_tx_err - to manage the tx error
- * @priv: driver private structure
- * Description: it cleans the descriptors and restarts the transmission
- * in case of transmission errors.
- */
-static void stmmac_tx_err(struct stmmac_priv *priv)
-{
-	int i;
-	netif_stop_queue(priv->dev);
-
-	priv->hw->dma->stop_tx(priv->ioaddr);
-	dma_free_tx_skbufs(priv);
-	for (i = 0; i < DMA_TX_SIZE; i++)
-		if (priv->extend_desc)
-			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
-						     priv->mode,
-						     (i == DMA_TX_SIZE - 1));
-		else
-			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
-						     priv->mode,
-						     (i == DMA_TX_SIZE - 1));
-	priv->dirty_tx = 0;
-	priv->cur_tx = 0;
-	netdev_reset_queue(priv->dev);
-	priv->hw->dma->start_tx(priv->ioaddr);
-
-	priv->dev->stats.tx_errors++;
-	netif_wake_queue(priv->dev);
-}
-
-/**
  * stmmac_dma_interrupt - DMA ISR
  * @priv: driver private structure
  * Description: this is the DMA ISR. It is called by the main ISR.
@@ -1466,7 +1435,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 			priv->xstats.threshold = tc;
 		}
 	} else if (unlikely(status == tx_hard_error))
-		stmmac_tx_err(priv);
+		schedule_work(&priv->tx_err_work);
 }
 
 /**
@@ -1870,13 +1839,7 @@ static int stmmac_open(struct net_device *dev)
 	return ret;
 }
 
-/**
- *  stmmac_release - close entry point of the driver
- *  @dev : device pointer.
- *  Description:
- *  This is the stop entry point of the driver.
- */
-static int stmmac_release(struct net_device *dev)
+static int stmmac_do_release(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
@@ -1919,10 +1882,36 @@ static int stmmac_release(struct net_device *dev)
 #endif
 
 	stmmac_release_ptp(priv);
+}
+
+/**
+ *  stmmac_release - close entry point of the driver
+ *  @dev : device pointer.
+ *  Description:
+ *  This is the stop entry point of the driver.
+ */
+static int stmmac_release(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	cancel_work_sync(&priv->tx_err_work);
+
+	stmmac_do_release(dev);
 
 	return 0;
 }
 
+static void stmmac_tx_err_work(struct work_struct *work)
+{
+	struct stmmac_priv *priv = container_of(work, struct stmmac_priv,
+						tx_err_work);
+	/* restart netdev */
+	rtnl_lock();
+	stmmac_release(priv->dev);
+	stmmac_open(priv->dev);
+	rtnl_unlock();
+}
+
 /**
  *  stmmac_tso_allocator - close entry point of the driver
  *  @priv: driver private structure
@@ -2688,7 +2677,7 @@ static void stmmac_tx_timeout(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	/* Clear Tx resources and restart transmitting again */
-	stmmac_tx_err(priv);
+	schedule_work(&priv->tx_err_work);
 }
 
 /**
@@ -3338,6 +3327,7 @@ int stmmac_dvr_probe(struct device *device,
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
+	INIT_WORK(&priv->tx_err_work, stmmac_tx_err_work);
 
 	ret = register_netdev(ndev);
 	if (ret) {
-- 
1.9.1


--------------64BF7E40EBE405D314B2779C--
