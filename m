From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH] net: sh_eth: add support for SH7757's ETHER
Date: Tue, 06 Jul 2010 13:32:50 +0900
Message-ID: <4C32B1F2.4040106@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SH7757 has 2 Fast Ethernet controller (ETHER) and 2 Gigabit Ethernet
Controller (GETHER). This patch supports 2 ETHER only.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/Kconfig  |    5 ++-
 drivers/net/sh_eth.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ce2fcdd..663f863 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -530,14 +530,15 @@ config SH_ETH
 	depends on SUPERH && \
 		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
 		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
-		 CPU_SUBTYPE_SH7724)
+		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7757)
 	select CRC32
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
 	help
 	  Renesas SuperH Ethernet device driver.
-	  This driver support SH7710, SH7712, SH7763, SH7619, and SH7724.
+	  This driver supporting CPUs are:
+		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.

 config SUNLANCE
 	tristate "Sun LANCE support"
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 501a55f..7ac814d 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -88,6 +88,55 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.rpadir		= 1,
 	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
+#elif defined(CONFIG_CPU_SUBTYPE_SH7757)
+#define SH_ETH_RESET_DEFAULT	1
+static void sh_eth_set_duplex(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	if (mdp->duplex) /* Full */
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+	else		/* Half */
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+}
+
+static void sh_eth_set_rate(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 ioaddr = ndev->base_addr;
+
+	switch (mdp->speed) {
+	case 10: /* 10BASE */
+		ctrl_outl(0, ioaddr + RTRATE);
+		break;
+	case 100:/* 100BASE */
+		ctrl_outl(1, ioaddr + RTRATE);
+		break;
+	default:
+		break;
+	}
+}
+
+/* SH7757 */
+static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.set_duplex		= sh_eth_set_duplex,
+	.set_rate		= sh_eth_set_rate,
+
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.rmcr_value	= 0x00000001,
+
+	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
+	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
+			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
+	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.hw_swap	= 1,
+	.no_ade		= 1,
+};

 #elif defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define SH_ETH_HAS_TSU	1
@@ -1023,7 +1072,9 @@ static int sh_eth_open(struct net_device *ndev)
 	pm_runtime_get_sync(&mdp->pdev->dev);

 	ret = request_irq(ndev->irq, sh_eth_interrupt,
-#if defined(CONFIG_CPU_SUBTYPE_SH7763) || defined(CONFIG_CPU_SUBTYPE_SH7764)
+#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
+    defined(CONFIG_CPU_SUBTYPE_SH7764) || \
+    defined(CONFIG_CPU_SUBTYPE_SH7757)
 				IRQF_SHARED,
 #else
 				0,
-- 
1.7.1

