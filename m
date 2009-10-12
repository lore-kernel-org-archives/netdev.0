From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 8/8] gianfar: Add support for hibernation
Date: Mon, 12 Oct 2009 20:00:42 +0400
Message-ID: <20091012160042.GH2463@oksana.dev.rtsoft.ru>
References: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Thanks to various cleanups and refactorings this is now straightforward:
convert the gianfar driver to dev_pm_ops, plus add ->restore() callback
that will fully reinitialize MAC internal registers and BDs.

Note that I kept legacy suspend/resume callbacks so that this patch
doesn't depend on PowerPC changes (i.e. dev_pm_ops support for OF
platform drivers).

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   87 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 70 insertions(+), 17 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 634a15b..f714186 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -700,23 +700,24 @@ static int gfar_remove(struct of_device *ofdev)
 }
 
 #ifdef CONFIG_PM
-static int gfar_suspend(struct of_device *ofdev, pm_message_t state)
+
+static int gfar_suspend(struct device *dev)
 {
-	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
-	struct net_device *dev = priv->ndev;
+	struct gfar_private *priv = dev_get_drvdata(dev);
+	struct net_device *ndev = priv->ndev;
 	unsigned long flags;
 	u32 tempval;
 
 	int magic_packet = priv->wol_en &&
 		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
-	netif_device_detach(dev);
+	netif_device_detach(ndev);
 
-	if (netif_running(dev)) {
+	if (netif_running(ndev)) {
 		spin_lock_irqsave(&priv->txlock, flags);
 		spin_lock(&priv->rxlock);
 
-		gfar_halt_nodisable(dev);
+		gfar_halt_nodisable(ndev);
 
 		/* Disable Tx, and Rx if wake-on-LAN is disabled. */
 		tempval = gfar_read(&priv->regs->maccfg1);
@@ -749,17 +750,17 @@ static int gfar_suspend(struct of_device *ofdev, pm_message_t state)
 	return 0;
 }
 
-static int gfar_resume(struct of_device *ofdev)
+static int gfar_resume(struct device *dev)
 {
-	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
-	struct net_device *dev = priv->ndev;
+	struct gfar_private *priv = dev_get_drvdata(dev);
+	struct net_device *ndev = priv->ndev;
 	unsigned long flags;
 	u32 tempval;
 	int magic_packet = priv->wol_en &&
 		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
-	if (!netif_running(dev)) {
-		netif_device_attach(dev);
+	if (!netif_running(ndev)) {
+		netif_device_attach(ndev);
 		return 0;
 	}
 
@@ -777,20 +778,71 @@ static int gfar_resume(struct of_device *ofdev)
 	tempval &= ~MACCFG2_MPEN;
 	gfar_write(&priv->regs->maccfg2, tempval);
 
-	gfar_start(dev);
+	gfar_start(ndev);
 
 	spin_unlock(&priv->rxlock);
 	spin_unlock_irqrestore(&priv->txlock, flags);
 
-	netif_device_attach(dev);
+	netif_device_attach(ndev);
+
+	napi_enable(&priv->napi);
+
+	return 0;
+}
+
+static int gfar_restore(struct device *dev)
+{
+	struct gfar_private *priv = dev_get_drvdata(dev);
+	struct net_device *ndev = priv->ndev;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	gfar_init_bds(ndev);
+	init_registers(ndev);
+	gfar_set_mac_address(ndev);
+	gfar_init_mac(ndev);
+	gfar_start(ndev);
+
+	priv->oldlink = 0;
+	priv->oldspeed = 0;
+	priv->oldduplex = -1;
+
+	if (priv->phydev)
+		phy_start(priv->phydev);
 
+	netif_device_attach(ndev);
 	napi_enable(&priv->napi);
 
 	return 0;
 }
+
+static struct dev_pm_ops gfar_pm_ops = {
+	.suspend = gfar_suspend,
+	.resume = gfar_resume,
+	.freeze = gfar_suspend,
+	.thaw = gfar_resume,
+	.restore = gfar_restore,
+};
+
+#define GFAR_PM_OPS (&gfar_pm_ops)
+
+static int gfar_legacy_suspend(struct of_device *ofdev, pm_message_t state)
+{
+	return gfar_suspend(&ofdev->dev);
+}
+
+static int gfar_legacy_resume(struct of_device *ofdev)
+{
+	return gfar_resume(&ofdev->dev);
+}
+
 #else
-#define gfar_suspend NULL
-#define gfar_resume NULL
+
+#define GFAR_PM_OPS NULL
+#define gfar_legacy_suspend NULL
+#define gfar_legacy_resume NULL
+
 #endif
 
 /* Reads the controller's registers to determine what interface
@@ -2362,8 +2414,9 @@ static struct of_platform_driver gfar_driver = {
 
 	.probe = gfar_probe,
 	.remove = gfar_remove,
-	.suspend = gfar_suspend,
-	.resume = gfar_resume,
+	.suspend = gfar_legacy_suspend,
+	.resume = gfar_legacy_resume,
+	.driver.pm = GFAR_PM_OPS,
 };
 
 static int __init gfar_init(void)
-- 
1.6.3.3
