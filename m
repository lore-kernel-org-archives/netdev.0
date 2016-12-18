From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Sun, 18 Dec 2016 17:15:10 +0100
Message-ID: <a2cbcfcd-f377-565c-a21c-3daa3abce519@gmx.de>
References: <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd> <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd> <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd> <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de> <20161217173150.GA20231@amd>
 <20161218001507.GA5343@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>, Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161218001507.GA5343@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 18.12.2016 01:15, Francois Romieu wrote:
> Pavel Machek <pavel@ucw.cz> :
> [...]
>> Won't this up/down the interface, in a way userspace can observe?
> 
> It won't up/down the interface as it doesn't exactly mimic what the
> network code does (there's more than rtnl_lock).
> 

Right. Userspace wont see link down/up, but it will see carrier off/on.
But this is AFAIK acceptable for a rare situation like a tx error.

> For the same reason it's broken if it races with the transmit path: it
> can release driver resources while the transmit path uses these.
> 
> Btw the points below may not matter/hurt much for a proof a concept
> but they would need to be addressed as well:
> 1) unchecked (and avoidable) extra error paths due to stmmac_release()
> 2) racy cancel_work_sync. Low probability as it is, an irq + error could
>    take place right after cancel_work_sync

It was indeed only meant as a proof of concept. Nevertheless the race is not 
good, since one can run into it when faking the tx error for testings purposes.
So below is a slightly improved version of the restart handling.
Its not meant as a final version either. But maybe we can use it as a starting
point.

> Lino, have you considered via-rhine.c since its "move work from irq to
> workqueue context" changes that started in
> 7ab87ff4c770eed71e3777936299292739fcd0fe [*] ?
> It's a shameless plug - originated in r8169.c - but it should be rather
> close to what the sxgbe and friends require. Thought / opinion ?
> 

Not really. There are a few drivers that I use to look into if I want to know
how certain things are done correctly (e.g the sky2 or the intel drivers) because
I think they are well implemented.
But you seem to have put some thoughts into various race condition problems
in the via-rhine driver and I can image that sxgbe and stmmac still have some
of these issues, too.

> [*] Including fixes/changes in:
> - 3a5a883a8a663b930908cae4abe5ec913b9b2fd2

Ok, the issues you fixed here are concerning the tx_curr and tx_dirty
pointers. For now this is not needed in stmmac and sxgbe since the
tx completion handlers in both drivers are not lock-free like in 
the via-rhine.c but are synchronized with xmit by means of the xmit_lock.

> - e1efa87241272104d6a12c8b9fcdc4f62634d447

Yep, a sync of the dma descriptors before the hardware gets ownership of the tx tail
idx is missing in the stmmac, too. 

> - 810f19bcb862f8889b27e0c9d9eceac9593925dd
> - e45af497950a89459a0c4b13ffd91e1729fffef4
> - a926592f5e4e900f3fa903298c4619a131e60963

I think we should use netif_tx_disable() instead of netif_stop_queue(), too, in 
case of restart to avoid a possible schedule of the xmit function while we restart. 
So this is also part of the new patch.

Again the patch is only compile tested.

Regards,
Lino

---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 95 +++++++++++++++--------
 2 files changed, 63 insertions(+), 33 deletions(-)

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
index 3e40578..5762750 100644
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
@@ -1902,6 +1871,7 @@ static int stmmac_release(struct net_device *dev)
 	if (priv->lpi_irq > 0)
 		free_irq(priv->lpi_irq, dev);
 
+	cancel_work_sync(&priv->tx_err_work);
 	/* Stop TX/RX DMA and clear the descriptors */
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
@@ -1920,9 +1890,67 @@ static int stmmac_release(struct net_device *dev)
 
 	stmmac_release_ptp(priv);
 
+
 	return 0;
 }
 
+static void stmmac_shutdown(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	/* make sure xmit is not scheduled any more */
+	netif_tx_disable(dev);
+
+	if (priv->eee_enabled)
+		del_timer_sync(&priv->eee_ctrl_timer);
+
+	/* Stop and disconnect the PHY */
+	if (dev->phydev) {
+		phy_stop(dev->phydev);
+		phy_disconnect(dev->phydev);
+	}
+
+	napi_disable(&priv->napi);
+
+	del_timer_sync(&priv->txtimer);
+
+	/* Free the IRQ lines */
+	free_irq(dev->irq, dev);
+	if (priv->wol_irq != dev->irq)
+		free_irq(priv->wol_irq, dev);
+	if (priv->lpi_irq > 0)
+		free_irq(priv->lpi_irq, dev);
+
+	/* Stop TX/RX DMA and clear the descriptors */
+	priv->hw->dma->stop_tx(priv->ioaddr);
+	priv->hw->dma->stop_rx(priv->ioaddr);
+
+	/* Release and free the Rx/Tx resources */
+	free_dma_desc_resources(priv);
+
+	/* Disable the MAC Rx/Tx */
+	stmmac_set_mac(priv->ioaddr, false);
+
+	netif_carrier_off(dev);
+
+#ifdef CONFIG_DEBUG_FS
+	stmmac_exit_fs(dev);
+#endif
+
+	stmmac_release_ptp(priv);
+}
+
+static void stmmac_tx_err_work(struct work_struct *work)
+{
+	struct stmmac_priv *priv = container_of(work, struct stmmac_priv,
+						tx_err_work);
+	/* restart netdev */
+	rtnl_lock();
+	stmmac_shutdown(priv->dev);
+	stmmac_open(priv->dev);
+	rtnl_unlock();
+}
+
 /**
  *  stmmac_tso_allocator - close entry point of the driver
  *  @priv: driver private structure
@@ -2688,7 +2716,7 @@ static void stmmac_tx_timeout(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	/* Clear Tx resources and restart transmitting again */
-	stmmac_tx_err(priv);
+	schedule_work(&priv->tx_err_work);
 }
 
 /**
@@ -3338,6 +3366,7 @@ int stmmac_dvr_probe(struct device *device,
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
 
 	spin_lock_init(&priv->lock);
+	INIT_WORK(&priv->tx_err_work, stmmac_tx_err_work);
 
 	ret = register_netdev(ndev);
 	if (ret) {
-- 
1.9.1
