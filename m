From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH v3 1/2] ravb: add wake-on-lan support via magic packet
Date: Tue,  1 Aug 2017 12:14:36 +0200
Message-ID: <20170801101437.9020-2-niklas.soderlund+renesas@ragnatech.se>
References: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:44202 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdHAKPT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:15:19 -0400
In-Reply-To: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WoL is enabled in the suspend callback by setting MagicPacket detection
and disabling all interrupts expect MagicPacket. In the resume path the
driver needs to reset the hardware to rearm the WoL logic, this prevents
the driver from simply restoring the registers and to take advantage of
that ravb was not suspended to reduce resume time. To reset the
hardware the driver closes the device, sets it in reset mode and reopens
the device just like it would do in a normal suspend/resume scenario
without WoL enabled, but it both closes and opens the device in the
resume callback since the device needs to be reset for WoL to work.

One quirk needed for WoL is that the module clock needs to be prevented
from being switched off by Runtime PM. To keep the clock alive the
suspend callback need to call clk_enable() directly to increase the
usage count of the clock. Then when Runtime PM decreases the clock usage
count it won't reach 0 and be switched off.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/ravb.h      |   2 +
 drivers/net/ethernet/renesas/ravb_main.c | 108 +++++++++++++++++++++++++++++--
 2 files changed, 106 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 0525bd696d5d02e5..96a27b00c90e212a 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -991,6 +991,7 @@ struct ravb_private {
 	struct net_device *ndev;
 	struct platform_device *pdev;
 	void __iomem *addr;
+	struct clk *clk;
 	struct mdiobb_ctrl mdiobb;
 	u32 num_rx_ring[NUM_RX_QUEUE];
 	u32 num_tx_ring[NUM_TX_QUEUE];
@@ -1033,6 +1034,7 @@ struct ravb_private {
 
 	unsigned no_avb_link:1;
 	unsigned avb_link_active_low:1;
+	unsigned wol_enabled:1;
 };
 
 static inline u32 ravb_read(struct net_device *ndev, enum ravb_reg reg)
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 5931e859876c2aee..6d10db1b51468031 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -680,6 +680,9 @@ static void ravb_emac_interrupt_unlocked(struct net_device *ndev)
 
 	ecsr = ravb_read(ndev, ECSR);
 	ravb_write(ndev, ecsr, ECSR);	/* clear interrupt */
+
+	if (ecsr & ECSR_MPD)
+		pm_wakeup_event(&priv->pdev->dev, 0);
 	if (ecsr & ECSR_ICD)
 		ndev->stats.tx_carrier_errors++;
 	if (ecsr & ECSR_LCHNG) {
@@ -1330,6 +1333,33 @@ static int ravb_get_ts_info(struct net_device *ndev,
 	return 0;
 }
 
+static void ravb_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (priv->clk) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = priv->wol_enabled ? WAKE_MAGIC : 0;
+	}
+}
+
+static int ravb_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	if (!priv->clk || wol->wolopts & ~WAKE_MAGIC)
+		return -EOPNOTSUPP;
+
+	priv->wol_enabled = !!(wol->wolopts & WAKE_MAGIC);
+
+	device_set_wakeup_enable(&priv->pdev->dev, priv->wol_enabled);
+
+	return 0;
+}
+
 static const struct ethtool_ops ravb_ethtool_ops = {
 	.nway_reset		= ravb_nway_reset,
 	.get_msglevel		= ravb_get_msglevel,
@@ -1343,6 +1373,8 @@ static const struct ethtool_ops ravb_ethtool_ops = {
 	.get_ts_info		= ravb_get_ts_info,
 	.get_link_ksettings	= ravb_get_link_ksettings,
 	.set_link_ksettings	= ravb_set_link_ksettings,
+	.get_wol		= ravb_get_wol,
+	.set_wol		= ravb_set_wol,
 };
 
 static inline int ravb_hook_irq(unsigned int irq, irq_handler_t handler,
@@ -2041,6 +2073,11 @@ static int ravb_probe(struct platform_device *pdev)
 
 	priv->chip_id = chip_id;
 
+	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
+	priv->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(priv->clk))
+		priv->clk = NULL;
+
 	/* Set function */
 	ndev->netdev_ops = &ravb_netdev_ops;
 	ndev->ethtool_ops = &ravb_ethtool_ops;
@@ -2107,6 +2144,9 @@ static int ravb_probe(struct platform_device *pdev)
 	if (error)
 		goto out_napi_del;
 
+	if (priv->clk)
+		device_set_wakeup_capable(&pdev->dev, 1);
+
 	/* Print device information */
 	netdev_info(ndev, "Base address at %#x, %pM, IRQ %d.\n",
 		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
@@ -2160,15 +2200,66 @@ static int ravb_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static int ravb_wol_setup(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	/* Disable interrupts by clearing the interrupt masks. */
+	ravb_write(ndev, 0, RIC0);
+	ravb_write(ndev, 0, RIC2);
+	ravb_write(ndev, 0, TIC);
+
+	/* Only allow ECI interrupts */
+	synchronize_irq(priv->emac_irq);
+	napi_disable(&priv->napi[RAVB_NC]);
+	napi_disable(&priv->napi[RAVB_BE]);
+	ravb_write(ndev, ECSIPR_MPDIP, ECSIPR);
+
+	/* Enable MagicPacket */
+	ravb_modify(ndev, ECMR, ECMR_MPDE, ECMR_MPDE);
+
+	/* Increased clock usage so device won't be suspended */
+	clk_enable(priv->clk);
+
+	return enable_irq_wake(priv->emac_irq);
+}
+
+static int ravb_wol_restore(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int ret;
+
+	napi_enable(&priv->napi[RAVB_NC]);
+	napi_enable(&priv->napi[RAVB_BE]);
+
+	/* Disable MagicPacket */
+	ravb_modify(ndev, ECMR, ECMR_MPDE, 0);
+
+	ret = ravb_close(ndev);
+	if (ret < 0)
+		return ret;
+
+	/* Restore clock usage count */
+	clk_disable(priv->clk);
+
+	return disable_irq_wake(priv->emac_irq);
+}
+
 static int __maybe_unused ravb_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
-	int ret = 0;
+	struct ravb_private *priv = netdev_priv(ndev);
+	int ret;
 
-	if (netif_running(ndev)) {
-		netif_device_detach(ndev);
+	if (!netif_running(ndev))
+		return 0;
+
+	netif_device_detach(ndev);
+
+	if (priv->wol_enabled)
+		ret = ravb_wol_setup(ndev);
+	else
 		ret = ravb_close(ndev);
-	}
 
 	return ret;
 }
@@ -2179,6 +2270,10 @@ static int __maybe_unused ravb_resume(struct device *dev)
 	struct ravb_private *priv = netdev_priv(ndev);
 	int ret = 0;
 
+	/* If WoL is enabled set reset mode to rearm the WoL logic */
+	if (priv->wol_enabled)
+		ravb_write(ndev, CCC_OPC_RESET, CCC);
+
 	/* All register have been reset to default values.
 	 * Restore all registers which where setup at probe time and
 	 * reopen device if it was running before system suspended.
@@ -2202,6 +2297,11 @@ static int __maybe_unused ravb_resume(struct device *dev)
 	ravb_write(ndev, priv->desc_bat_dma, DBAT);
 
 	if (netif_running(ndev)) {
+		if (priv->wol_enabled) {
+			ret = ravb_wol_restore(ndev);
+			if (ret)
+				return ret;
+		}
 		ret = ravb_open(ndev);
 		if (ret < 0)
 			return ret;
-- 
2.13.3
