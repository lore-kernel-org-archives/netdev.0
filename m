From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 net-next 1/1] net: fec: add stop mode request on/off implemention
Date: Wed, 22 Jul 2015 18:13:43 +0800
Message-ID: <1437560023-9271-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Frank.Li@freescale.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0108.outbound.protection.outlook.com ([65.55.169.108]:44529
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933154AbbGVKNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 06:13:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current driver depends on platform data to implement stop mode
request on/off that call api pdata->sleep_mode_enable().

To reduce arch platform redundancy code, since the function only set
SOC GPR register bit to request stop mode of/off, so we can move the
function into driver. And the specifix GPR register offset and MASK
bit can be transferred from DTS.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |  3 +
 drivers/net/ethernet/freescale/fec.h              |  8 +++
 drivers/net/ethernet/freescale/fec_main.c         | 87 +++++++++++++++++++----
 3 files changed, 84 insertions(+), 14 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a9eb611..f0936c3 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -24,6 +24,9 @@ Optional properties:
   number to 1.
 - fsl,magic-packet : If present, indicates that the hardware supports waking
   up via magic packet.
+- fsl,wakeup_irq : The property defines the wakeup irq index in enet irq source.
+- stop-mode : The property defines gpr register bits of stop mode control, the
+  format is <&gpr req_gpr req_bit>.
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 1eee73c..1a09b68 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -431,6 +431,12 @@ struct bufdesc_ex {
 /* Controller supports RACC register */
 #define FEC_QUIRK_HAS_RACC		(1 << 12)
 
+struct fec_enet_stop_mode {
+	struct regmap *gpr;
+	u8 req_gpr;
+	u8 req_bit;
+};
+
 struct fec_enet_priv_tx_q {
 	int index;
 	unsigned char *tx_bounce[TX_RING_SIZE];
@@ -518,6 +524,8 @@ struct fec_enet_private {
 	bool	bufdesc_ex;
 	int	pause_flag;
 	int	wol_flag;
+	int	wake_irq;
+	struct	fec_enet_stop_mode gprctl;
 	u32	quirks;
 
 	struct	napi_struct napi;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1f89c59..8ab03f4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -58,6 +58,8 @@
 #include <linux/if_vlan.h>
 #include <linux/pinctrl/consumer.h>
 #include <linux/prefetch.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
 
 #include <asm/cacheflush.h>
 
@@ -1099,11 +1101,27 @@ fec_restart(struct net_device *ndev)
 
 }
 
+static int fec_enet_stop_mode(struct fec_enet_private *fep, bool enabled)
+{
+	if (IS_ERR_OR_NULL(fep->gprctl.gpr))
+		return 0;
+
+	if (enabled)
+		regmap_update_bits(fep->gprctl.gpr, fep->gprctl.req_gpr,
+				   1 << fep->gprctl.req_bit,
+				   1 << fep->gprctl.req_bit);
+	else
+		regmap_update_bits(fep->gprctl.gpr, fep->gprctl.req_gpr,
+				   1 << fep->gprctl.req_bit,
+				   0);
+
+	return 0;
+}
+
 static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	u32 rmii_mode = readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
 	u32 val;
 
@@ -1133,8 +1151,7 @@ fec_stop(struct net_device *ndev)
 		val |= (FEC_ECR_MAGICEN | FEC_ECR_SLEEP);
 		writel(val, fep->hwp + FEC_ECNTRL);
 
-		if (pdata && pdata->sleep_mode_enable)
-			pdata->sleep_mode_enable(true);
+		fec_enet_stop_mode(fep, true);
 	}
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
@@ -2578,15 +2595,10 @@ fec_enet_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 		return -EINVAL;
 
 	device_set_wakeup_enable(&ndev->dev, wol->wolopts & WAKE_MAGIC);
-	if (device_may_wakeup(&ndev->dev)) {
+	if (device_may_wakeup(&ndev->dev))
 		fep->wol_flag |= FEC_WOL_FLAG_ENABLE;
-		if (fep->irq[0] > 0)
-			enable_irq_wake(fep->irq[0]);
-	} else {
+	else
 		fep->wol_flag &= (~FEC_WOL_FLAG_ENABLE);
-		if (fep->irq[0] > 0)
-			disable_irq_wake(fep->irq[0]);
-	}
 
 	return 0;
 }
@@ -3267,6 +3279,41 @@ fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, int *num_rx)
 
 }
 
+static void fec_enet_of_parse_stop_mode(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct device_node *np = pdev->dev.of_node;
+	struct fec_enet_private *fep = netdev_priv(dev);
+	struct device_node *node;
+	phandle phandle;
+	u32 out_val[3];
+	int ret;
+
+	ret = of_property_read_u32_array(np, "stop-mode", out_val, 3);
+	if (ret) {
+		dev_dbg(&pdev->dev, "no stop-mode property\n");
+		return;
+	}
+
+	phandle = *out_val;
+	node = of_find_node_by_phandle(phandle);
+	if (!node) {
+		dev_dbg(&pdev->dev, "could not find gpr node by phandle\n");
+		return;
+	}
+
+	fep->gprctl.gpr = syscon_node_to_regmap(node);
+	if (IS_ERR(fep->gprctl.gpr)) {
+		dev_dbg(&pdev->dev, "could not find gpr regmap\n");
+		return;
+	}
+
+	of_node_put(node);
+
+	fep->gprctl.req_gpr = out_val[1];
+	fep->gprctl.req_bit = out_val[2];
+}
+
 static int
 fec_probe(struct platform_device *pdev)
 {
@@ -3324,6 +3371,8 @@ fec_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
+	fec_enet_of_parse_stop_mode(pdev);
+
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		fep->wol_flag |= FEC_WOL_HAS_MAGIC_PACKET;
 
@@ -3425,6 +3474,12 @@ fec_probe(struct platform_device *pdev)
 		fep->irq[i] = irq;
 	}
 
+	ret = of_property_read_u32(np, "fsl,wakeup_irq", &irq);
+	if (!ret && irq < FEC_IRQ_NUM)
+		fep->wake_irq = fep->irq[irq];
+	else
+		fep->wake_irq = fep->irq[0];
+
 	init_completion(&fep->mdio_done);
 	ret = fec_enet_mii_init(pdev);
 	if (ret)
@@ -3503,8 +3558,12 @@ static int __maybe_unused fec_suspend(struct device *dev)
 		netif_tx_unlock_bh(ndev);
 		fec_stop(ndev);
 		fec_enet_clk_enable(ndev, false);
-		if (!(fep->wol_flag & FEC_WOL_FLAG_ENABLE))
+		if (!(fep->wol_flag & FEC_WOL_FLAG_ENABLE)) {
 			pinctrl_pm_select_sleep_state(&fep->pdev->dev);
+		} else {
+			disable_irq(fep->wake_irq);
+			enable_irq_wake(fep->wake_irq);
+		}
 	}
 	rtnl_unlock();
 
@@ -3524,7 +3583,6 @@ static int __maybe_unused fec_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
 	int ret;
 	int val;
 
@@ -3542,8 +3600,9 @@ static int __maybe_unused fec_resume(struct device *dev)
 			goto failed_clk;
 		}
 		if (fep->wol_flag & FEC_WOL_FLAG_ENABLE) {
-			if (pdata && pdata->sleep_mode_enable)
-				pdata->sleep_mode_enable(false);
+			disable_irq_wake(fep->wake_irq);
+			fec_enet_stop_mode(fep, false);
+			enable_irq(fep->wake_irq);
 			val = readl(fep->hwp + FEC_ECNTRL);
 			val &= ~(FEC_ECR_MAGICEN | FEC_ECR_SLEEP);
 			writel(val, fep->hwp + FEC_ECNTRL);
-- 
1.9.1
