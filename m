From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Wed,  7 Dec 2016 17:28:43 +0100
Message-ID: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/sh_eth.c | 120 +++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   4 ++
 2 files changed, 116 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 05b0dc5..3974046 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -624,7 +624,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 
 	.register_type	= SH_ETH_REG_FAST_RCAR,
 
-	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
+	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
 
@@ -641,6 +641,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.rmiimode	= 1,
+	.magic		= 1,
 };
 #endif /* CONFIG_OF */
 
@@ -1657,6 +1658,10 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 		goto out;
 
 	if (!likely(mdp->irq_enabled)) {
+		/* Handle MagicPacket interrupt */
+		if (sh_eth_read(ndev, ECSR) & ECSR_MPD)
+			sh_eth_modify(ndev, ECSR, 0, ECSR_MPD);
+
 		sh_eth_write(ndev, 0, EESIPR);
 		goto out;
 	}
@@ -2199,6 +2204,33 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
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
+	mdp->wol_enabled = wol->wolopts & WAKE_MAGIC;
+
+	device_set_wakeup_enable(&mdp->pdev->dev, mdp->wol_enabled);
+
+	return 0;
+}
+
 static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_regs_len	= sh_eth_get_regs_len,
 	.get_regs	= sh_eth_get_regs,
@@ -2213,6 +2245,8 @@ static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.set_ringparam	= sh_eth_set_ringparam,
 	.get_link_ksettings = sh_eth_get_link_ksettings,
 	.set_link_ksettings = sh_eth_set_link_ksettings,
+	.get_wol	= sh_eth_get_wol,
+	.set_wol	= sh_eth_set_wol,
 };
 
 /* network device open function */
@@ -3017,6 +3051,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_release;
 	}
 
+	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
+	mdp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(mdp->clk))
+		mdp->clk = NULL;
+
 	ndev->base_addr = res->start;
 
 	spin_lock_init(&mdp->lock);
@@ -3111,6 +3150,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	if (ret)
 		goto out_napi_del;
 
+	mdp->wol_enabled = false;
+	if (mdp->cd->magic && mdp->clk)
+		device_set_wakeup_capable(&pdev->dev, 1);
+
 	/* print device information */
 	netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d.\n",
 		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
@@ -3150,15 +3193,71 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 
 #ifdef CONFIG_PM
 #ifdef CONFIG_PM_SLEEP
+static int sh_eth_wol_setup(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	/* Only allow ECI interrupts */
+	mdp->irq_enabled = false;
+	synchronize_irq(ndev->irq);
+	napi_disable(&mdp->napi);
+	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
+
+	/* Enable ECI MagicPacket interrupt */
+	sh_eth_write(ndev, ECSIPR_MPDIP, ECSIPR);
+
+	/* Enable MagicPacket */
+	sh_eth_modify(ndev, ECMR, 0, ECMR_PMDE);
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
+	sh_eth_modify(ndev, ECMR, ECMR_PMDE, 0);
+
+	/* The device need to be reset to restore MagicPacket logic
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
@@ -3166,14 +3265,19 @@ static int sh_eth_suspend(struct device *dev)
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
+
+	if (!ret)
 		netif_device_attach(ndev);
-	}
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index d050f37..26c6620 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
 	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
 	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
 	unsigned rtrate:1;	/* EtherC has RTRATE register */
+	unsigned magic:1;	/* EtherC have PMDE in ECMR and MPDIP in ECSIPR */
 };
 
 struct sh_eth_private {
@@ -529,6 +530,9 @@ struct sh_eth_private {
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
 	unsigned is_opened:1;
+
+	bool wol_enabled;
+	struct clk *clk;
 };
 
 static inline void sh_eth_soft_swap(char *src, int len)
-- 
2.10.2
