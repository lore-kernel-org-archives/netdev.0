From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv3 2/6] sh_eth: add generic wake-on-lan support via magic packet
Date: Mon,  9 Jan 2017 16:34:05 +0100
Message-ID: <20170109153409.13956-3-niklas.soderlund+renesas@ragnatech.se>
References: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-pm@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add generic functionality to support Wake-on-LAN using MagicPacket which
are supported by at least a few versions of sh_eth. Only add
functionality for WoL, no specific sh_eth versions are marked to support
WoL yet.

WoL is enabled in the suspend callback by setting MagicPacket detection
and disabling all interrupts expect MagicPacket. In the resume path the
driver needs to reset the hardware to rearm the WoL logic, this prevents
the driver from simply restoring the registers and to take advantage of
that sh_eth was not suspended to reduce resume time. To reset the
hardware the driver closes and reopens the device just like it would do
in a normal suspend/resume scenario without WoL enabled, but it both
closes and opens the device in the resume callback since the device
needs to be open for WoL to work.

One quirk needed for WoL is that the module clock needs to be prevented
from being switched off by Runtime PM. To keep the clock alive the
suspend callback need to call clk_enable() directly to increase the
usage count of the clock. Then when Runtime PM decreases the clock usage
count it won't reach 0 and be switched off.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 114 +++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   3 +
 2 files changed, 109 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8a784dce45fa..542c92b57b35 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1552,6 +1552,8 @@ static void sh_eth_emac_interrupt(struct net_device *ndev)
 			sh_eth_rcv_snd_enable(ndev);
 		}
 	}
+	if (felic_stat & ECSR_MPD)
+		pm_wakeup_event(&mdp->pdev->dev, 0);
 }
 
 /* error control function */
@@ -2201,6 +2203,33 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 	return 0;
 }
 
+static void sh_eth_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (mdp->cd->magic && mdp->clk) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = mdp->wol_enabled ? WAKE_MAGIC : 0;
+	}
+}
+
+static int sh_eth_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	if (!mdp->cd->magic || !mdp->clk || wol->wolopts & ~WAKE_MAGIC)
+		return -EOPNOTSUPP;
+
+	mdp->wol_enabled = !!(wol->wolopts & WAKE_MAGIC);
+
+	device_set_wakeup_enable(&mdp->pdev->dev, mdp->wol_enabled);
+
+	return 0;
+}
+
 static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_regs_len	= sh_eth_get_regs_len,
 	.get_regs	= sh_eth_get_regs,
@@ -2215,6 +2244,8 @@ static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.set_ringparam	= sh_eth_set_ringparam,
 	.get_link_ksettings = sh_eth_get_link_ksettings,
 	.set_link_ksettings = sh_eth_set_link_ksettings,
+	.get_wol	= sh_eth_get_wol,
+	.set_wol	= sh_eth_set_wol,
 };
 
 /* network device open function */
@@ -3017,6 +3048,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_release;
 	}
 
+	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
+	mdp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(mdp->clk))
+		mdp->clk = NULL;
+
 	ndev->base_addr = res->start;
 
 	spin_lock_init(&mdp->lock);
@@ -3111,6 +3147,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	if (ret)
 		goto out_napi_del;
 
+	if (mdp->cd->magic && mdp->clk)
+		device_set_wakeup_capable(&pdev->dev, 1);
+
 	/* print device information */
 	netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d.\n",
 		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
@@ -3150,15 +3189,67 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 
 #ifdef CONFIG_PM
 #ifdef CONFIG_PM_SLEEP
+static int sh_eth_wol_setup(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* Only allow ECI interrupts */
+	synchronize_irq(ndev->irq);
+	napi_disable(&mdp->napi);
+	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
+
+	/* Enable MagicPacket */
+	sh_eth_modify(ndev, ECMR, 0, ECMR_MPDE);
+
+	/* Increased clock usage so device won't be suspended */
+	clk_enable(mdp->clk);
+
+	return enable_irq_wake(ndev->irq);
+}
+
+static int sh_eth_wol_restore(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
+
+	napi_enable(&mdp->napi);
+
+	/* Disable MagicPacket */
+	sh_eth_modify(ndev, ECMR, ECMR_MPDE, 0);
+
+	/* The device needs to be reset to restore MagicPacket logic
+	 * for next wakeup. If we close and open the device it will
+	 * both be reset and all registers restored. This is what
+	 * happens during suspend and resume without WoL enabled.
+	 */
+	ret = sh_eth_close(ndev);
+	if (ret < 0)
+		return ret;
+	ret = sh_eth_open(ndev);
+	if (ret < 0)
+		return ret;
+
+	/* Restore clock usage count */
+	clk_disable(mdp->clk);
+
+	return disable_irq_wake(ndev->irq);
+}
+
 static int sh_eth_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ret = 0;
 
-	if (netif_running(ndev)) {
-		netif_device_detach(ndev);
+	if (!netif_running(ndev))
+		return 0;
+
+	netif_device_detach(ndev);
+
+	if (mdp->wol_enabled)
+		ret = sh_eth_wol_setup(ndev);
+	else
 		ret = sh_eth_close(ndev);
-	}
 
 	return ret;
 }
@@ -3166,14 +3257,21 @@ static int sh_eth_suspend(struct device *dev)
 static int sh_eth_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ret = 0;
 
-	if (netif_running(ndev)) {
+	if (!netif_running(ndev))
+		return 0;
+
+	if (mdp->wol_enabled)
+		ret = sh_eth_wol_restore(ndev);
+	else
 		ret = sh_eth_open(ndev);
-		if (ret < 0)
-			return ret;
-		netif_device_attach(ndev);
-	}
+
+	if (ret < 0)
+		return ret;
+
+	netif_device_attach(ndev);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 11798d5c4a1d..96b5459d131f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
 	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
 	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
 	unsigned rtrate:1;	/* EtherC has RTRATE register */
+	unsigned magic:1;	/* EtherC has ECMR.MPDE and ECSR.MPD */
 };
 
 struct sh_eth_private {
@@ -501,6 +502,7 @@ struct sh_eth_private {
 	const u16 *reg_offset;
 	void __iomem *addr;
 	void __iomem *tsu_addr;
+	struct clk *clk;
 	u32 num_rx_ring;
 	u32 num_tx_ring;
 	dma_addr_t rx_desc_dma;
@@ -529,6 +531,7 @@ struct sh_eth_private {
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
 	unsigned is_opened:1;
+	unsigned wol_enabled:1;
 };
 
 static inline void sh_eth_soft_swap(char *src, int len)
-- 
2.11.0
