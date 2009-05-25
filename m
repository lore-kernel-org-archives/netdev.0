From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH 5/5] net: sh_eth: Add support SH7724
Date: Mon, 25 May 2009 18:54:30 +0900
Message-ID: <4A1A6AD6.7020401@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Kuninori Morimoto <morimoto.kuninori@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/Kconfig  |    7 +++--
 drivers/net/sh_eth.c |   52 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sh_eth.h |   58 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 111 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..436954f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -526,15 +526,16 @@ config STNIC
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || CPU_SUBTYPE_SH7763 || \
-		 CPU_SUBTYPE_SH7619)
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
+		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
+		 CPU_SUBTYPE_SH7724)
 	select CRC32
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
 	help
 	  Renesas SuperH Ethernet device driver.
-	  This driver support SH7710, SH7712, SH7763 and SH7619.
+	  This driver support SH7710, SH7712, SH7763, SH7619, and SH7724.

 config SUNLANCE
 	tristate "Sun LANCE support"
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 19571f7..cdd73b9 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -34,7 +34,57 @@
 #include "sh_eth.h"

 /* There is CPU dependent code */
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+#if defined(CONFIG_CPU_SUBTYPE_SH7724)
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
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_RTM, ioaddr + ECMR);
+		break;
+	case 100:/* 100BASE */
+		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_RTM, ioaddr + ECMR);
+		break;
+	default:
+		break;
+	}
+}
+
+/* SH7724 */
+static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate,
+
+	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
+	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
+	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x01ff009f,
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
+};
+
+#elif defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define SH_ETH_HAS_TSU	1
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index eec6c4a..9afe5b4 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -40,6 +40,8 @@
 #define PKT_BUF_SZ		1538

 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
+/* This CPU register maps is very difference by other SH4 CPU */
+
 /* Chip Base Address */
 # define SH_TSU_ADDR	0xFEE01800
 # define ARSTR		SH_TSU_ADDR
@@ -141,7 +143,59 @@
 # define FWNLCR1         0xB0
 # define FWALCR1         0x40

-#else /* #elif defined(CONFIG_CPU_SUBTYPE_SH7763) */
+#elif defined(CONFIG_CPU_SH4)	/* #if defined(CONFIG_CPU_SUBTYPE_SH7763) */
+/* EtherC */
+#define ECMR		0x100
+#define RFLR		0x108
+#define ECSR		0x110
+#define ECSIPR		0x118
+#define PIR		0x120
+#define PSR		0x128
+#define RDMLR		0x140
+#define IPGR		0x150
+#define APR		0x154
+#define MPR		0x158
+#define TPAUSER		0x164
+#define RFCF		0x160
+#define TPAUSECR	0x168
+#define BCFRR		0x16c
+#define MAHR		0x1c0
+#define MALR		0x1c8
+#define TROCR		0x1d0
+#define CDCR		0x1d4
+#define LCCR		0x1d8
+#define CNDCR		0x1dc
+#define CEFCR		0x1e4
+#define FRECR		0x1e8
+#define TSFRCR		0x1ec
+#define TLFRCR		0x1f0
+#define RFCR		0x1f4
+#define MAFCR		0x1f8
+#define RTRATE		0x1fc
+
+/* E-DMAC */
+#define EDMR		0x000
+#define EDTRR		0x008
+#define EDRRR		0x010
+#define TDLAR		0x018
+#define RDLAR		0x020
+#define EESR		0x028
+#define EESIPR		0x030
+#define TRSCER		0x038
+#define RMFCR		0x040
+#define TFTR		0x048
+#define FDR		0x050
+#define RMCR		0x058
+#define TFUCR		0x064
+#define RFOCR		0x068
+#define FCFTR		0x070
+#define RPADIR		0x078
+#define TRIMD		0x07c
+#define RBWAR		0x0c8
+#define RDFAR		0x0cc
+#define TBRAR		0x0d4
+#define TDFAR		0x0d8
+#else /* #elif defined(CONFIG_CPU_SH4) */
 /* This section is SH3 or SH2 */
 #ifndef CONFIG_CPU_SUBTYPE_SH7619
 /* Chip base address */
@@ -426,7 +480,7 @@ enum FELIC_MODE_BIT {
 	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
 	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
 	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
-	ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004,
+	ECMR_RTM = 0x00000010, ECMR_ILB = 0x00000008, ECMR_ELB = 0x00000004,
 	ECMR_DM = 0x00000002, ECMR_PRM = 0x00000001,
 };

-- 
1.5.5

