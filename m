From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v1 1/3] net: fec: add Wake-on-LAN support
Date: Wed, 24 Dec 2014 17:30:39 +0800
Message-ID: <1419413441-3406-2-git-send-email-b38611@freescale.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0146.outbound.protection.outlook.com ([207.46.100.146]:65180
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751096AbaLXKGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:06:05 -0500
In-Reply-To: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for Wake-on-LAN using Magic Packet. ENET IP supports sleep mode
in low power status, when system enter suspend status, Magic packet can
wake up system even if all SOC clocks are gate. The patch doing below things:
- flagging the device as a wakeup source for the system, as well as
  its Wake-on-LAN interrupt
- prepare the hardware for entering WoL mode
- add standard ethtool WOL interface
- enable the ENET interrupt to wake us

Tested on i.MX6q/dl sabresd, sabreauto boards, i.MX6SX arm2 boards.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |    2 +
 drivers/net/ethernet/freescale/fec.h              |    2 +
 drivers/net/ethernet/freescale/fec_main.c         |  104 +++++++++++++++++++--
 include/linux/fec.h                               |    1 +
 4 files changed, 99 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 0c8775c..a9eb611 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -22,6 +22,8 @@ Optional properties:
 - fsl,num-rx-queues : The property is valid for enet-avb IP, which supports
   hw multi queues. Should specify the rx queue number, otherwise set rx queue
   number to 1.
+- fsl,magic-packet : If present, indicates that the hardware supports waking
+  up via magic packet.
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 469691a..e51ab5d 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -356,6 +356,7 @@ struct bufdesc_ex {
 #define FEC_ENET_RXB    ((uint)0x01000000)      /* A buffer was received */
 #define FEC_ENET_MII    ((uint)0x00800000)      /* MII interrupt */
 #define FEC_ENET_EBERR  ((uint)0x00400000)      /* SDMA bus error */
+#define FEC_ENET_WAKEUP	((uint)0x00020000)	/* Wakeup request */
 #define FEC_ENET_TXF	(FEC_ENET_TXF_0 | FEC_ENET_TXF_1 | FEC_ENET_TXF_2)
 #define FEC_ENET_RXF	(FEC_ENET_RXF_0 | FEC_ENET_RXF_1 | FEC_ENET_RXF_2)
 #define FEC_ENET_TS_AVAIL       ((uint)0x00010000)
@@ -511,6 +512,7 @@ struct fec_enet_private {
 	int	irq[FEC_IRQ_NUM];
 	bool	bufdesc_ex;
 	int	pause_flag;
+	int	wol_flag;
 	u32	quirks;
 
 	struct	napi_struct napi;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5c4a8bd..615b51d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -187,6 +187,9 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define FEC_MMFR_RA(v)		((v & 0x1f) << 18)
 #define FEC_MMFR_TA		(2 << 16)
 #define FEC_MMFR_DATA(v)	(v & 0xffff)
+/* FEC ECR bits definition */
+#define FEC_ECR_MAGICEN		(1 << 2)
+#define FEC_ECR_SLEEP		(1 << 3)
 
 #define FEC_MII_TIMEOUT		30000 /* us */
 
@@ -195,6 +198,9 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 #define FEC_PAUSE_FLAG_AUTONEG	0x1
 #define FEC_PAUSE_FLAG_ENABLE	0x2
+#define FEC_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
+#define FEC_WOL_FLAG_ENABLE		(0x1 << 1)
+#define FEC_WOL_FLAG_SLEEP_ON		(0x1 << 2)
 
 #define COPYBREAK_DEFAULT	256
 
@@ -1089,7 +1095,9 @@ static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	u32 rmii_mode = readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
+	u32 val;
 
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
@@ -1103,17 +1111,28 @@ fec_stop(struct net_device *ndev)
 	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
 	 * instead of reset MAC itself.
 	 */
-	if (fep->quirks & FEC_QUIRK_HAS_AVB) {
-		writel(0, fep->hwp + FEC_ECNTRL);
+	if (!(fep->wol_flag & FEC_WOL_FLAG_SLEEP_ON)) {
+		if (fep->quirks & FEC_QUIRK_HAS_AVB) {
+			writel(0, fep->hwp + FEC_ECNTRL);
+		} else {
+			writel(1, fep->hwp + FEC_ECNTRL);
+			udelay(10);
+		}
+		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 	} else {
-		writel(1, fep->hwp + FEC_ECNTRL);
-		udelay(10);
+		writel(FEC_DEFAULT_IMASK | FEC_ENET_WAKEUP, fep->hwp + FEC_IMASK);
+		val = readl(fep->hwp + FEC_ECNTRL);
+		val |= (FEC_ECR_MAGICEN | FEC_ECR_SLEEP);
+		writel(val, fep->hwp + FEC_ECNTRL);
+
+		if (pdata && pdata->sleep_mode_enable)
+			pdata->sleep_mode_enable(true);
 	}
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 
 	/* We have to keep ENET enabled to have MII interrupt stay working */
-	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
+	if (fep->quirks & FEC_QUIRK_ENET_MAC &&
+		!(fep->wol_flag & FEC_WOL_FLAG_SLEEP_ON)) {
 		writel(2, fep->hwp + FEC_ECNTRL);
 		writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
 	}
@@ -2427,6 +2446,44 @@ static int fec_enet_set_tunable(struct net_device *netdev,
 	return ret;
 }
 
+static void
+fec_enet_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	if (fep->wol_flag & FEC_WOL_HAS_MAGIC_PACKET) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = fep->wol_flag & FEC_WOL_FLAG_ENABLE ? WAKE_MAGIC : 0;
+	} else {
+		wol->supported = wol->wolopts = 0;
+	}
+}
+
+static int
+fec_enet_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	if (!(fep->wol_flag & FEC_WOL_HAS_MAGIC_PACKET))
+		return -EINVAL;
+
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	device_set_wakeup_enable(&ndev->dev, wol->wolopts & WAKE_MAGIC);
+	if (device_may_wakeup(&ndev->dev)) {
+		fep->wol_flag |= FEC_WOL_FLAG_ENABLE;
+		if (fep->irq[0] > 0)
+			enable_irq_wake(fep->irq[0]);
+	} else {
+		fep->wol_flag &= (~FEC_WOL_FLAG_ENABLE);
+		if (fep->irq[0] > 0)
+			disable_irq_wake(fep->irq[0]);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
@@ -2445,6 +2502,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_ts_info		= fec_enet_get_ts_info,
 	.get_tunable		= fec_enet_get_tunable,
 	.set_tunable		= fec_enet_set_tunable,
+	.get_wol		= fec_enet_get_wol,
+	.set_wol		= fec_enet_set_wol,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
@@ -2705,6 +2764,9 @@ fec_enet_open(struct net_device *ndev)
 	phy_start(fep->phy_dev);
 	netif_tx_start_all_queues(ndev);
 
+	device_set_wakeup_enable(&ndev->dev, fep->wol_flag &
+				 FEC_WOL_FLAG_ENABLE);
+
 	return 0;
 
 err_enet_mii_probe:
@@ -3153,6 +3215,9 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
+	if (of_get_property(np, "fsl,magic-packet", NULL))
+		fep->wol_flag |= FEC_WOL_HAS_MAGIC_PACKET;
+
 	phy_node = of_parse_phandle(np, "phy-handle", 0);
 	if (!phy_node && of_phy_is_fixed_link(np)) {
 		ret = of_phy_register_fixed_link(np);
@@ -3247,6 +3312,8 @@ fec_probe(struct platform_device *pdev)
 				       0, pdev->name, ndev);
 		if (ret)
 			goto failed_irq;
+
+		fep->irq[i] = irq;
 	}
 
 	init_completion(&fep->mdio_done);
@@ -3263,6 +3330,9 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
+	device_init_wakeup(&ndev->dev, fep->wol_flag &
+			   FEC_WOL_HAS_MAGIC_PACKET);
+
 	if (fep->bufdesc_ex && fep->ptp_clock)
 		netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);
 
@@ -3316,6 +3386,8 @@ static int __maybe_unused fec_suspend(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
+		if (fep->wol_flag & FEC_WOL_FLAG_ENABLE)
+			fep->wol_flag |= FEC_WOL_FLAG_SLEEP_ON;
 		phy_stop(fep->phy_dev);
 		napi_disable(&fep->napi);
 		netif_tx_lock_bh(ndev);
@@ -3323,11 +3395,12 @@ static int __maybe_unused fec_suspend(struct device *dev)
 		netif_tx_unlock_bh(ndev);
 		fec_stop(ndev);
 		fec_enet_clk_enable(ndev, false);
-		pinctrl_pm_select_sleep_state(&fep->pdev->dev);
+		if (!(fep->wol_flag & FEC_WOL_FLAG_ENABLE))
+			pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 	}
 	rtnl_unlock();
 
-	if (fep->reg_phy)
+	if (fep->reg_phy && !(fep->wol_flag & FEC_WOL_FLAG_ENABLE))
 		regulator_disable(fep->reg_phy);
 
 	/* SOC supply clock to phy, when clock is disabled, phy link down
@@ -3343,9 +3416,11 @@ static int __maybe_unused fec_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	int ret;
+	int val;
 
-	if (fep->reg_phy) {
+	if (fep->reg_phy && !(fep->wol_flag & FEC_WOL_FLAG_ENABLE)) {
 		ret = regulator_enable(fep->reg_phy);
 		if (ret)
 			return ret;
@@ -3353,12 +3428,21 @@ static int __maybe_unused fec_resume(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
-		pinctrl_pm_select_default_state(&fep->pdev->dev);
 		ret = fec_enet_clk_enable(ndev, true);
 		if (ret) {
 			rtnl_unlock();
 			goto failed_clk;
 		}
+		if (fep->wol_flag & FEC_WOL_FLAG_ENABLE) {
+			if (pdata && pdata->sleep_mode_enable)
+				pdata->sleep_mode_enable(false);
+			val = readl(fep->hwp + FEC_ECNTRL);
+			val &= ~(FEC_ECR_MAGICEN | FEC_ECR_SLEEP);
+			writel(val, fep->hwp + FEC_ECNTRL);
+			fep->wol_flag &= ~FEC_WOL_FLAG_SLEEP_ON;
+		} else {
+			pinctrl_pm_select_default_state(&fep->pdev->dev);
+		}
 		fec_restart(ndev);
 		netif_tx_lock_bh(ndev);
 		netif_device_attach(ndev);
diff --git a/include/linux/fec.h b/include/linux/fec.h
index bcff455..1454a50 100644
--- a/include/linux/fec.h
+++ b/include/linux/fec.h
@@ -19,6 +19,7 @@
 struct fec_platform_data {
 	phy_interface_t phy;
 	unsigned char mac[ETH_ALEN];
+	void (*sleep_mode_enable)(int enabled);
 };
 
 #endif
-- 
1.7.8
