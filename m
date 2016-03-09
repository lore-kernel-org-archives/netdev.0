From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Wed, 9 Mar 2016 18:08:51 +0800
Message-ID: <1457518131-11339-6-git-send-email-yangbo.lu@nxp.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, <scott.wood@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	<ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	"Santosh Shilimkar" <ssantosh@kernel.org>, <leoyang.li@nxp.com>,
	<xiaobo.xie@nxp.com>, Yangbo Lu <yangbo.lu@nxp.com>
To: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-clk@vger.kernel.org>, <linux-i2c@vger.kernel.org>,
	<iommu@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-mmc@vger.kernel.org>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The eSDHC of T4240-R1.0-R2.0 has incorrect vender version and spec version.
Acturally the right version numbers should be VVN=0x13 and SVN = 0x1.
This patch adds the GUTS driver support for eSDHC driver to get SVR(System
version register). And fix host version to avoid that incorrect version
numbers break down the ADMA data transfer.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
Acked-by: Ulf Hansson <ulf.hansson@linaro.org>
---
Changes for v2:
	- Got SVR through iomap instead of dts
Changes for v3:
	- Managed GUTS through syscon instead of iomap in eSDHC driver
Changes for v4:
	- Got SVR by GUTS driver instead of SYSCON
Changes for v5:
	- Changed to get SVR through API fsl_guts_get_svr()
	- Combined patch 4, patch 5 and patch 6 into one
Changes for v6:
	- Added 'Acked-by: Ulf Hansson'
---
 drivers/mmc/host/Kconfig          |  1 +
 drivers/mmc/host/sdhci-of-esdhc.c | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/drivers/mmc/host/Kconfig b/drivers/mmc/host/Kconfig
index 04feea8..5743b05 100644
--- a/drivers/mmc/host/Kconfig
+++ b/drivers/mmc/host/Kconfig
@@ -142,6 +142,7 @@ config MMC_SDHCI_OF_ESDHC
 	depends on MMC_SDHCI_PLTFM
 	depends on PPC || ARCH_MXC || ARCH_LAYERSCAPE
 	select MMC_SDHCI_IO_ACCESSORS
+	select FSL_GUTS
 	help
 	  This selects the Freescale eSDHC controller support.
 
diff --git a/drivers/mmc/host/sdhci-of-esdhc.c b/drivers/mmc/host/sdhci-of-esdhc.c
index 3f34d35..68cc020 100644
--- a/drivers/mmc/host/sdhci-of-esdhc.c
+++ b/drivers/mmc/host/sdhci-of-esdhc.c
@@ -18,6 +18,8 @@
 #include <linux/of.h>
 #include <linux/delay.h>
 #include <linux/module.h>
+#include <linux/fsl/svr.h>
+#include <linux/fsl/guts.h>
 #include <linux/mmc/host.h>
 #include "sdhci-pltfm.h"
 #include "sdhci-esdhc.h"
@@ -28,6 +30,8 @@
 struct sdhci_esdhc {
 	u8 vendor_ver;
 	u8 spec_ver;
+	u32 soc_ver;
+	u8 soc_rev;
 };
 
 /**
@@ -73,6 +77,8 @@ static u32 esdhc_readl_fixup(struct sdhci_host *host,
 static u16 esdhc_readw_fixup(struct sdhci_host *host,
 				     int spec_reg, u32 value)
 {
+	struct sdhci_pltfm_host *pltfm_host = sdhci_priv(host);
+	struct sdhci_esdhc *esdhc = sdhci_pltfm_priv(pltfm_host);
 	u16 ret;
 	int shift = (spec_reg & 0x2) * 8;
 
@@ -80,6 +86,13 @@ static u16 esdhc_readw_fixup(struct sdhci_host *host,
 		ret = value & 0xffff;
 	else
 		ret = (value >> shift) & 0xffff;
+
+	/* Workaround for T4240-R1.0-R2.0 eSDHC which has incorrect
+	 * vendor version and spec version information.
+	 */
+	if ((spec_reg == SDHCI_HOST_VERSION) &&
+	    (esdhc->soc_ver == SVR_T4240) && (esdhc->soc_rev <= 0x20))
+		ret = (VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) | SDHCI_SPEC_200;
 	return ret;
 }
 
@@ -567,10 +580,20 @@ static void esdhc_init(struct platform_device *pdev, struct sdhci_host *host)
 	struct sdhci_pltfm_host *pltfm_host;
 	struct sdhci_esdhc *esdhc;
 	u16 host_ver;
+	u32 svr;
 
 	pltfm_host = sdhci_priv(host);
 	esdhc = sdhci_pltfm_priv(pltfm_host);
 
+	fsl_guts_init();
+	svr = fsl_guts_get_svr();
+	if (svr) {
+		esdhc->soc_ver = SVR_SOC_VER(svr);
+		esdhc->soc_rev = SVR_REV(svr);
+	} else {
+		dev_err(&pdev->dev, "Failed to get SVR value!\n");
+	}
+
 	host_ver = sdhci_readw(host, SDHCI_HOST_VERSION);
 	esdhc->vendor_ver = (host_ver & SDHCI_VENDOR_VER_MASK) >>
 			     SDHCI_VENDOR_VER_SHIFT;
-- 
2.1.0.27.g96db324

