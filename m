From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4]  base: soc: introduce soc_device_match() interface
Date: Mon, 30 May 2016 16:57:55 +0200
Message-ID: <4811326.1KLIei2jcl@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com> <6032641.cjSseEG2PF@wuerfel>
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
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <6032641.cjSseEG2PF@wuerfel>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, May 30, 2016 3:14:38 PM CEST Arnd Bergmann wrote:
> We keep running into cases where device drivers want to know the exact
> version of the SoC a they are currently running on. In the past, this
> has usually been done through a vendor specific API that can be called
> by a driver, or by directly accessing some kind of version register
> that is not part of the device itself but that belongs to a global
> register area of the chip.
> 
> Common reasons for doing this include:
> 
> - A machine is not using devicetree or similar for passing data
>   about on-chip devices, but just announces their presence using
>   boot-time platform devices, and the machine code itself does
>   not care about the revision.
> 
> - There is existing firmware or boot loaders with existing DT
>   binaries with generic compatible strings that do not identify
>   the particular revision of each device, but the driver knows
>   which SoC revisions include which part
> 
> - A prerelease version of a chip has some quirks and we are
>   using the same version of the bootloader and the DT blob
>   on both the prerelease and the final version. An update of
>   the DT binding seems inappropriate because that would involve
>   maintaining multiple copies of the dts and/or bootloader.
> 
> This introduces the soc_device_match() interface that is meant
> to work like of_match_node() but instead of identifying the
> version of a device, it identifies the SoC itself using a
> vendor-agnostic interface.
> 
> Unlike soc_device_match(), we do not do an exact string compare
> but instead use glob_match() to allow wildcards in strings.

I'm sorry the series introduced build failures (I had done some changes
after testing), here is a quick fixup. I'll resend the whole thing
after someone has looked at it as none of the changes below should
have any influence on the review.

	Arnd

diff --git a/drivers/base/soc.c b/drivers/base/soc.c
index e9623c6674a5..c38573249777 100644
--- a/drivers/base/soc.c
+++ b/drivers/base/soc.c
@@ -173,7 +173,7 @@ module_exit(soc_bus_unregister);
 static int soc_device_match_one(struct device *dev, void *arg)
 {
 	struct soc_device *soc_dev = container_of(dev, struct soc_device, dev);
-	struct soc_device_attribute *match = arg;
+	const struct soc_device_attribute *match = arg;
 
 	if (match->machine && !glob_match(match->machine, soc_dev->attr->machine))
 		return 0;
@@ -208,7 +208,7 @@ static int soc_device_match_one(struct device *dev, void *arg)
  * soc_device_attribute to pass a structure or function pointer for
  * each entry.
  */
-struct soc_device_attribute *soc_device_match(struct soc_device_attribute *matches)
+const struct soc_device_attribute *soc_device_match(const struct soc_device_attribute *matches)
 {
 	struct device *dev;
 	int ret;
@@ -219,7 +219,7 @@ struct soc_device_attribute *soc_device_match(struct soc_device_attribute *match
 			return NULL;
 
 		dev = NULL;
-		ret = bus_for_each_dev(&soc_bus_type, dev, matches,
+		ret = bus_for_each_dev(&soc_bus_type, dev, (void *)matches,
 					 soc_device_match_one);
 	}
 
diff --git a/drivers/mmc/host/sdhci-of-esdhc.c b/drivers/mmc/host/sdhci-of-esdhc.c
index 1d4814fe4cb2..a7b8b05a13e8 100644
--- a/drivers/mmc/host/sdhci-of-esdhc.c
+++ b/drivers/mmc/host/sdhci-of-esdhc.c
@@ -19,6 +19,8 @@
 #include <linux/delay.h>
 #include <linux/module.h>
 #include <linux/mmc/host.h>
+#include <linux/sys_soc.h>
+
 #include "sdhci-pltfm.h"
 #include "sdhci-esdhc.h"
 
@@ -75,7 +77,6 @@ static u16 esdhc_readw_fixup(struct sdhci_host *host,
 {
 	struct sdhci_pltfm_host *pltfm_host = sdhci_priv(host);
 	struct sdhci_esdhc *esdhc = sdhci_pltfm_priv(pltfm_host);
-	u16 ret;
 	int shift = (spec_reg & 0x2) * 8;
 
 	if (spec_reg == SDHCI_HOST_VERSION)
@@ -565,7 +566,7 @@ static const struct sdhci_pltfm_data sdhci_esdhc_le_pdata = {
 };
 
 #define T4240_HOST_VER ((VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) | SDHCI_SPEC_200)
-static const struct soc_device_attribute esdhc_t4240_quirk = {
+static const struct soc_device_attribute esdhc_t4240_quirk[] = {
 	/* T4240 revision < 0x20 uses vendor version 23, SDHCI version 200 */
 	{ .soc_id = "T4*(0x824000)", .revision = "0x[01]?",
 	  .data = (void *)(uintptr_t)(T4240_HOST_VER) },
@@ -576,6 +577,7 @@ static void esdhc_init(struct platform_device *pdev, struct sdhci_host *host)
 {
 	struct sdhci_pltfm_host *pltfm_host;
 	struct sdhci_esdhc *esdhc;
+	u32 host_ver;
 
 	pltfm_host = sdhci_priv(host);
 	esdhc = sdhci_pltfm_priv(pltfm_host);
@@ -583,9 +585,9 @@ static void esdhc_init(struct platform_device *pdev, struct sdhci_host *host)
 	host_ver = sdhci_readw(host, SDHCI_HOST_VERSION);
 
 	if (of_device_is_compatible(pdev->dev.of_node, "fsl,t4240-esdhc")) {
-		struct soc_device_attribute *match;
+		const struct soc_device_attribute *match;
 
-		match = soc_device_match(&esdhc_t4240_quirk);
+		match = soc_device_match(esdhc_t4240_quirk);
 		if (match)
 			host_ver = (uintptr_t)match->data;
 	}
diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
index 2f30698f5bcf..476969644bed 100644
--- a/drivers/soc/fsl/guts.c
+++ b/drivers/soc/fsl/guts.c
@@ -34,14 +34,6 @@ static u32 fsl_guts_get_svr(struct guts *guts)
 		return ioread32be(guts->regs + GUTS_SVR);
 }
 
-static u32 fsl_guts_get_pvr(struct guts *guts)
-{
-	if (guts->little_endian)
-		return ioread32(guts->regs + GUTS_PVR);
-	else
-		return ioread32be(guts->regs + GUTS_PVR);
-}
-
 /*
  * Table for matching compatible strings, for device tree
  * guts node, for Freescale QorIQ SOCs.
@@ -76,13 +68,15 @@ static const struct of_device_id fsl_guts_of_match[] = {
 
 static void fsl_guts_init(struct device *dev, struct guts *guts)
 {
-	const struct of_device_id *id;
 	u32 svr = fsl_guts_get_svr(guts);
+	const struct of_device_id *id;
+	const char *socname;
 
 	guts->soc.family = "NXP QorIQ";
 	id = of_match_node(fsl_guts_of_match, dev->of_node);
-	guts->soc.soc_id = devm_kasprintf(dev, "%s (ver 0x%06x)" id->data,
-					  svr >> 8;
+	socname = id->data;
+	guts->soc.soc_id = devm_kasprintf(dev, GFP_KERNEL, "%s (ver 0x%06x)",
+					  socname, svr >> 8);
 	guts->soc.revision = devm_kasprintf(dev, GFP_KERNEL, "0x%02x",
 					    svr & 0xff);
 }
diff --git a/include/linux/sys_soc.h b/include/linux/sys_soc.h
index 02c48c76052b..3dfc8714a88c 100644
--- a/include/linux/sys_soc.h
+++ b/include/linux/sys_soc.h
@@ -36,6 +36,6 @@ void soc_device_unregister(struct soc_device *soc_dev);
  */
 struct device *soc_device_to_device(struct soc_device *soc);
 
-struct soc_device_attribute *soc_device_match(struct soc_device_attribute *matches);
+const struct soc_device_attribute *soc_device_match(const struct soc_device_attribute *matches);
 
 #endif /* __SOC_BUS_H */

