From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [RFC, PATCH 4/4] net: sh_eth: add support for SH7757's GETHER
Date: Tue, 15 Feb 2011 20:47:32 +0900
Message-ID: <4D5A67D4.2000408@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SH7757 have GETHER and ETHER both. This patch supports them.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/sh_eth.c |  136 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 135 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index ca7ff4e..330f608 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -87,7 +87,8 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
-#define SH_ETH_RESET_DEFAULT	1
+#define SH_ETH_HAS_BOTH_MODULES	1
+#define SH_ETH_HAS_TSU	1
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -134,6 +135,135 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.no_ade		= 1,
 };

+#define SH_GIGA_ETH_BASE	0xfee00000
+#define GIGA_MALR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c8)
+#define GIGA_MAHR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c0)
+static void sh_eth_chip_reset_giga(struct net_device *ndev)
+{
+	int i;
+	unsigned long mahr[2], malr[2];
+
+	/* save MAHR and MALR */
+	for (i = 0; i < 2; i++) {
+		malr[i] = readl(GIGA_MALR(i));
+		mahr[i] = readl(GIGA_MAHR(i));
+	}
+
+	/* reset device */
+	writel(ARSTR_ARSTR, SH_GIGA_ETH_BASE + 0x1800);
+	mdelay(1);
+
+	/* restore MAHR and MALR */
+	for (i = 0; i < 2; i++) {
+		writel(malr[i], GIGA_MALR(i));
+		writel(mahr[i], GIGA_MAHR(i));
+	}
+}
+
+static int sh_eth_is_gether(struct sh_eth_private *mdp);
+static void sh_eth_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int cnt = 100;
+
+	if (sh_eth_is_gether(mdp)) {
+		sh_eth_write(ndev, 0x03, EDSR);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
+				EDMR);
+		while (cnt > 0) {
+			if (!(sh_eth_read(ndev, EDMR) & 0x3))
+				break;
+			mdelay(1);
+			cnt--;
+		}
+		if (cnt < 0)
+			printk(KERN_ERR "Device reset fail\n");
+
+		/* Table Init */
+		sh_eth_write(ndev, 0x0, TDLAR);
+		sh_eth_write(ndev, 0x0, TDFAR);
+		sh_eth_write(ndev, 0x0, TDFXR);
+		sh_eth_write(ndev, 0x0, TDFFR);
+		sh_eth_write(ndev, 0x0, RDLAR);
+		sh_eth_write(ndev, 0x0, RDFAR);
+		sh_eth_write(ndev, 0x0, RDFXR);
+		sh_eth_write(ndev, 0x0, RDFFR);
+	} else {
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER,
+				EDMR);
+		mdelay(3);
+		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
+				EDMR);
+	}
+}
+
+static void sh_eth_set_duplex_giga(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	if (mdp->duplex) /* Full */
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
+	else		/* Half */
+		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
+}
+
+static void sh_eth_set_rate_giga(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	switch (mdp->speed) {
+	case 10: /* 10BASE */
+		sh_eth_write(ndev, 0x00000000, GECMR);
+		break;
+	case 100:/* 100BASE */
+		sh_eth_write(ndev, 0x00000010, GECMR);
+		break;
+	case 1000: /* 1000BASE */
+		sh_eth_write(ndev, 0x00000020, GECMR);
+		break;
+	default:
+		break;
+	}
+}
+
+/* SH7757(GETHERC) */
+static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
+	.chip_reset	= sh_eth_chip_reset_giga,
+	.set_duplex	= sh_eth_set_duplex_giga,
+	.set_rate	= sh_eth_set_rate_giga,
+
+	.ecsr_value	= ECSR_ICD | ECSR_MPD,
+	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+
+	.tx_check	= EESR_TC1 | EESR_FTC,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
+			  EESR_ECI,
+	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
+			  EESR_TFE,
+	.fdr_value	= 0x0000072f,
+	.rmcr_value	= 0x00000001,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.bculr		= 1,
+	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
+	.no_trimd	= 1,
+	.no_ade		= 1,
+};
+
+static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
+{
+	if (sh_eth_is_gether(mdp))
+		return &sh_eth_my_cpu_data_giga;
+	else
+		return &sh_eth_my_cpu_data;
+}
+
 #elif defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define SH_ETH_HAS_TSU	1
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -1515,7 +1645,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);

 	/* set cpu data */
+#if defined(SH_ETH_HAS_BOTH_MODULES)
+	mdp->cd = sh_eth_get_cpu_data(mdp);
+#else
 	mdp->cd = &sh_eth_my_cpu_data;
+#endif
 	sh_eth_set_default_cpu_data(mdp->cd);

 	/* set function */
-- 
1.7.1
