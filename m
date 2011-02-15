From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [RFC, PATCH 2/4] net: sh_eth: remove the SH_TSU_ADDR
Date: Tue, 15 Feb 2011 20:47:27 +0900
Message-ID: <4D5A67CF.3040406@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The defination is hardcoded in this driver for some CPUs. This patch
modifies to get resource of TSU address from platform_device.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/sh_eth.c |   16 ++++++++++++----
 drivers/net/sh_eth.h |   15 ---------------
 2 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 3b6d545..0593f29 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1446,7 +1446,7 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 static int sh_eth_drv_probe(struct platform_device *pdev)
 {
 	int ret, devno = 0;
-	struct resource *res;
+	struct resource *res, *res_tsu;
 	struct net_device *ndev = NULL;
 	struct sh_eth_private *mdp;
 	struct sh_eth_plat_data *pd;
@@ -1520,9 +1520,13 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 			mdp->cd->chip_reset(ndev);

 #if defined(SH_ETH_HAS_TSU)
-		/* TSU init (Init only)*/
-		mdp->tsu_addr = SH_TSU_ADDR;
-		sh_eth_tsu_init(mdp);
+		res_tsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		if (res_tsu) {
+			mdp->tsu_addr = ioremap(res_tsu->start,
+						resource_size(res_tsu));
+			/* TSU init (Init only)*/
+			sh_eth_tsu_init(mdp);
+		}
 #endif
 	}

@@ -1549,6 +1553,8 @@ out_unregister:

 out_release:
 	/* net_dev free */
+	if (mdp->tsu_addr)
+		iounmap(mdp->tsu_addr);
 	if (ndev)
 		free_netdev(ndev);

@@ -1559,7 +1565,9 @@ out:
 static int sh_eth_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct sh_eth_private *mdp = netdev_priv(ndev);

+	iounmap(mdp->tsu_addr);
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 1510a7c..1a32dc0 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -371,21 +371,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {

 };

-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-/* This CPU register maps is very difference by other SH4 CPU */
-/* Chip Base Address */
-# define SH_TSU_ADDR	0xFEE01800
-# define ARSTR		SH_TSU_ADDR
-#elif defined(CONFIG_CPU_SH4)	/* #if defined(CONFIG_CPU_SUBTYPE_SH7763) */
-#else /* #elif defined(CONFIG_CPU_SH4) */
-/* This section is SH3 or SH2 */
-#ifndef CONFIG_CPU_SUBTYPE_SH7619
-/* Chip base address */
-# define SH_TSU_ADDR  0xA7000804
-# define ARSTR		  0xA7000800
-#endif
-#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
-
 /* Driver's parameters */
 #if defined(CONFIG_CPU_SH4)
 #define SH4_SKB_RX_ALIGN	32
-- 
1.7.1
