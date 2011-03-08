From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v2 2/6] net: sh_eth: remove the SH_TSU_ADDR
Date: Tue, 08 Mar 2011 16:59:34 +0900
Message-ID: <4D75E1E6.10108@renesas.com>
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
 This patch are based on net-next-2.6.git.

 about v2:
  - fix the ARSTR for SH7763

 drivers/net/sh_eth.c |   31 ++++++++++++++++++++++++-------
 drivers/net/sh_eth.h |   18 +++---------------
 2 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 51268f5..c7abcc5 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -145,8 +145,10 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #define SH_ETH_HAS_TSU	1
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
 	/* reset device */
-	writel(ARSTR_ARSTR, ARSTR);
+	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
 	mdelay(1);
 }

@@ -229,6 +231,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.hw_swap	= 1,
 	.no_trimd	= 1,
 	.no_ade		= 1,
+	.tsu		= 1,
 };

 #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
@@ -246,6 +249,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 #define SH_ETH_HAS_TSU	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.tsu		= 1,
 };
 #endif

@@ -1446,6 +1450,7 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 				ECMR_MCT, ECMR);
 	}
 }
+#endif /* SH_ETH_HAS_TSU */

 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(struct sh_eth_private *mdp)
@@ -1475,7 +1480,6 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 	sh_eth_tsu_write(mdp, 0, TSU_POST3);	/* Disable CAM entry [16-23] */
 	sh_eth_tsu_write(mdp, 0, TSU_POST4);	/* Disable CAM entry [24-31] */
 }
-#endif /* SH_ETH_HAS_TSU */

 /* MDIO bus release function */
 static int sh_mdio_release(struct net_device *ndev)
@@ -1676,14 +1680,23 @@ static int sh_eth_drv_probe(struct platform_device *pdev)

 	/* First device only init */
 	if (!devno) {
+		if (mdp->cd->tsu) {
+			struct resource *rtsu;
+			rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+			if (!rtsu) {
+				dev_err(&pdev->dev, "Not found TSU resource\n");
+				goto out_release;
+			}
+			mdp->tsu_addr = ioremap(rtsu->start,
+						resource_size(rtsu));
+		}
 		if (mdp->cd->chip_reset)
 			mdp->cd->chip_reset(ndev);

-#if defined(SH_ETH_HAS_TSU)
-		/* TSU init (Init only)*/
-		mdp->tsu_addr = SH_TSU_ADDR;
-		sh_eth_tsu_init(mdp);
-#endif
+		if (mdp->cd->tsu) {
+			/* TSU init (Init only)*/
+			sh_eth_tsu_init(mdp);
+		}
 	}

 	/* network device register */
@@ -1709,6 +1722,8 @@ out_unregister:

 out_release:
 	/* net_dev free */
+	if (mdp->tsu_addr)
+		iounmap(mdp->tsu_addr);
 	if (ndev)
 		free_netdev(ndev);

@@ -1719,7 +1734,9 @@ out:
 static int sh_eth_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct sh_eth_private *mdp = netdev_priv(ndev);

+	iounmap(mdp->tsu_addr);
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 1510a7c..35a3adb 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -207,6 +207,7 @@ static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[CEECR]	= 0x0770,
 	[MAFCR]	= 0x0778,

+	[ARSTR]	= 0x0000,
 	[TSU_CTRST]	= 0x0004,
 	[TSU_FWEN0]	= 0x0010,
 	[TSU_FWEN1]	= 0x0014,
@@ -328,6 +329,7 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TPAUSER]	= 0x01c4,
 	[BCFR]	= 0x01cc,

+	[ARSTR]	= 0x0000,
 	[TSU_CTRST]	= 0x0004,
 	[TSU_FWEN0]	= 0x0010,
 	[TSU_FWEN1]	= 0x0014,
@@ -371,21 +373,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {

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
@@ -770,6 +757,7 @@ struct sh_eth_cpu_data {
 	unsigned mpr:1;			/* EtherC have MPR */
 	unsigned tpauser:1;		/* EtherC have TPAUSER */
 	unsigned bculr:1;		/* EtherC have BCULR */
+	unsigned tsu:1;			/* EtherC have TSU */
 	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
 	unsigned rpadir:1;		/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
-- 
1.7.1
