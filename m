From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/4] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Mon, 30 May 2016 15:16:03 +0200
Message-ID: <6110875.0k1HlSKhzn@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com> <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Scott Wood <oss@buserror.net>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a rewrite of an earlier patch from Yangbo Lu, adding a quirk
for the NXP QorIQ T4240 in the detection of the host device version.

Unfortunately, this device cannot be detected using the compatible
string, as we have to support existing DTS files that use the generic
"fsl,t4240-esdhc" identifier but that have other host versions that
are correctly detected.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/mmc/host/sdhci-of-esdhc.c b/drivers/mmc/host/sdhci-of-esdhc.c
index 3f34d354f1fc..1d4814fe4cb2 100644
--- a/drivers/mmc/host/sdhci-of-esdhc.c
+++ b/drivers/mmc/host/sdhci-of-esdhc.c
@@ -73,14 +73,16 @@ static u32 esdhc_readl_fixup(struct sdhci_host *host,
 static u16 esdhc_readw_fixup(struct sdhci_host *host,
 				     int spec_reg, u32 value)
 {
+	struct sdhci_pltfm_host *pltfm_host = sdhci_priv(host);
+	struct sdhci_esdhc *esdhc = sdhci_pltfm_priv(pltfm_host);
 	u16 ret;
 	int shift = (spec_reg & 0x2) * 8;
 
 	if (spec_reg == SDHCI_HOST_VERSION)
-		ret = value & 0xffff;
-	else
-		ret = (value >> shift) & 0xffff;
-	return ret;
+		return esdhc->vendor_ver << SDHCI_VENDOR_VER_SHIFT |
+		       esdhc->spec_ver;
+
+	return (value >> shift) & 0xffff;
 }
 
 static u8 esdhc_readb_fixup(struct sdhci_host *host,
@@ -562,16 +564,32 @@ static const struct sdhci_pltfm_data sdhci_esdhc_le_pdata = {
 	.ops = &sdhci_esdhc_le_ops,
 };
 
+#define T4240_HOST_VER ((VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) | SDHCI_SPEC_200)
+static const struct soc_device_attribute esdhc_t4240_quirk = {
+	/* T4240 revision < 0x20 uses vendor version 23, SDHCI version 200 */
+	{ .soc_id = "T4*(0x824000)", .revision = "0x[01]?",
+	  .data = (void *)(uintptr_t)(T4240_HOST_VER) },
+	{ },
+};
+
 static void esdhc_init(struct platform_device *pdev, struct sdhci_host *host)
 {
 	struct sdhci_pltfm_host *pltfm_host;
 	struct sdhci_esdhc *esdhc;
-	u16 host_ver;
 
 	pltfm_host = sdhci_priv(host);
 	esdhc = sdhci_pltfm_priv(pltfm_host);
 
 	host_ver = sdhci_readw(host, SDHCI_HOST_VERSION);
+
+	if (of_device_is_compatible(pdev->dev.of_node, "fsl,t4240-esdhc")) {
+		struct soc_device_attribute *match;
+
+		match = soc_device_match(&esdhc_t4240_quirk);
+		if (match)
+			host_ver = (uintptr_t)match->data;
+	}
+
 	esdhc->vendor_ver = (host_ver & SDHCI_VENDOR_VER_MASK) >>
 			     SDHCI_VENDOR_VER_SHIFT;
 	esdhc->spec_ver = host_ver & SDHCI_SPEC_VER_MASK;
