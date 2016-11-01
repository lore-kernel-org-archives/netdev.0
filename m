From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v4 6/7] net: ethernet: bgmac: add NS2 support
Date: Tue, 1 Nov 2016 17:05:13 -0400
Message-ID: <20161101210512.GB27191@broadcom.com>
References: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
 <1478030682-27012-7-git-send-email-jon.mason@broadcom.com>
 <711f4964-e655-4007-9804-f45bd47fed73@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>, rafal@milecki.pl,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Scott Branden <scott.branden@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <711f4964-e655-4007-9804-f45bd47fed73@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 01:34:30PM -0700, Scott Branden wrote:
> One change in this patch
> 
> On 16-11-01 01:04 PM, Jon Mason wrote:
> >Add support for the variant of amac hardware present in the Broadcom
> >Northstar2 based SoCs.  Northstar2 requires an additional register to be
> >configured with the port speed/duplexity (NICPM).  This can be added to
> >the link callback to hide it from the instances that do not use this.
> >Also, clearing of the pending interrupts on init is required due to
> >observed issues on some platforms.
> >
> >Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> >---
> > drivers/net/ethernet/broadcom/bgmac-platform.c | 56 +++++++++++++++++++++++++-
> > drivers/net/ethernet/broadcom/bgmac.c          |  3 ++
> > drivers/net/ethernet/broadcom/bgmac.h          |  1 +
> > 3 files changed, 58 insertions(+), 2 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
> >index aed5dc5..f6d48c7 100644
> >--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
> >+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
> >@@ -14,12 +14,21 @@
> > #define pr_fmt(fmt)		KBUILD_MODNAME ": " fmt
> >
> > #include <linux/bcma/bcma.h>
> >+#include <linux/brcmphy.h>
> > #include <linux/etherdevice.h>
> > #include <linux/of_address.h>
> > #include <linux/of_mdio.h>
> > #include <linux/of_net.h>
> > #include "bgmac.h"
> >
> >+#define NICPM_IOMUX_CTRL		0x00000008
> >+
> >+#define NICPM_IOMUX_CTRL_INIT_VAL	0x3196e000
> >+#define NICPM_IOMUX_CTRL_SPD_SHIFT	10
> >+#define NICPM_IOMUX_CTRL_SPD_10M	0
> >+#define NICPM_IOMUX_CTRL_SPD_100M	1
> >+#define NICPM_IOMUX_CTRL_SPD_1000M	2
> >+
> > static u32 platform_bgmac_read(struct bgmac *bgmac, u16 offset)
> > {
> > 	return readl(bgmac->plat.base + offset);
> >@@ -87,12 +96,46 @@ static void platform_bgmac_cmn_maskset32(struct bgmac *bgmac, u16 offset,
> > 	WARN_ON(1);
> > }
> >
> >+static void bgmac_nicpm_speed_set(struct net_device *net_dev)
> >+{
> >+	struct bgmac *bgmac = netdev_priv(net_dev);
> >+	u32 val;
> >+
> >+	if (!bgmac->plat.nicpm_base)
> >+		return;
> >+
> >+	val = NICPM_IOMUX_CTRL_INIT_VAL;
> >+	switch (bgmac->net_dev->phydev->speed) {
> >+	default:
> >+		pr_err("Unsupported speed.  Defaulting to 1000Mb\n");
> This should be dev_err

It should probably be netdev_err (and there are a few instances below
that should probably be changed to netdev_err as well).

Thanks,
Jon

> >+	case SPEED_1000:
> >+		val |= NICPM_IOMUX_CTRL_SPD_1000M << NICPM_IOMUX_CTRL_SPD_SHIFT;
> >+		break;
> >+	case SPEED_100:
> >+		val |= NICPM_IOMUX_CTRL_SPD_100M << NICPM_IOMUX_CTRL_SPD_SHIFT;
> >+		break;
> >+	case SPEED_10:
> >+		val |= NICPM_IOMUX_CTRL_SPD_10M << NICPM_IOMUX_CTRL_SPD_SHIFT;
> >+		break;
> >+	}
> >+
> >+	writel(val, bgmac->plat.nicpm_base + NICPM_IOMUX_CTRL);
> >+
> >+	bgmac_adjust_link(bgmac->net_dev);
> >+}
> >+
> > static int platform_phy_connect(struct bgmac *bgmac)
> > {
> > 	struct phy_device *phy_dev;
> >
> >-	phy_dev = of_phy_get_and_connect(bgmac->net_dev, bgmac->dev->of_node,
> >-					 bgmac_adjust_link);
> >+	if (bgmac->plat.nicpm_base)
> >+		phy_dev = of_phy_get_and_connect(bgmac->net_dev,
> >+						 bgmac->dev->of_node,
> >+						 bgmac_nicpm_speed_set);
> >+	else
> >+		phy_dev = of_phy_get_and_connect(bgmac->net_dev,
> >+						 bgmac->dev->of_node,
> >+						 bgmac_adjust_link);
> > 	if (!phy_dev) {
> > 		dev_err(bgmac->dev, "Phy connect failed\n");
> > 		return -ENODEV;
> >@@ -182,6 +225,14 @@ static int bgmac_probe(struct platform_device *pdev)
> > 	if (IS_ERR(bgmac->plat.idm_base))
> > 		return PTR_ERR(bgmac->plat.idm_base);
> >
> >+	regs = platform_get_resource_byname(pdev, IORESOURCE_MEM, "nicpm_base");
> >+	if (regs) {
> >+		bgmac->plat.nicpm_base = devm_ioremap_resource(&pdev->dev,
> >+							       regs);
> >+		if (IS_ERR(bgmac->plat.nicpm_base))
> >+			return PTR_ERR(bgmac->plat.nicpm_base);
> >+	}
> >+
> > 	bgmac->read = platform_bgmac_read;
> > 	bgmac->write = platform_bgmac_write;
> > 	bgmac->idm_read = platform_bgmac_idm_read;
> >@@ -213,6 +264,7 @@ static int bgmac_remove(struct platform_device *pdev)
> > static const struct of_device_id bgmac_of_enet_match[] = {
> > 	{.compatible = "brcm,amac",},
> > 	{.compatible = "brcm,nsp-amac",},
> >+	{.compatible = "brcm,ns2-amac",},
> > 	{},
> > };
> >
> >diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> >index 4584958..a805cc8 100644
> >--- a/drivers/net/ethernet/broadcom/bgmac.c
> >+++ b/drivers/net/ethernet/broadcom/bgmac.c
> >@@ -1082,6 +1082,9 @@ static void bgmac_enable(struct bgmac *bgmac)
> > /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipinit */
> > static void bgmac_chip_init(struct bgmac *bgmac)
> > {
> >+	/* Clear any erroneously pending interrupts */
> >+	bgmac_write(bgmac, BGMAC_INT_STATUS, ~0);
> >+
> > 	/* 1 interrupt per received frame */
> > 	bgmac_write(bgmac, BGMAC_INT_RECV_LAZY, 1 << BGMAC_IRL_FC_SHIFT);
> >
> >diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
> >index ea52ac3..b1820ea 100644
> >--- a/drivers/net/ethernet/broadcom/bgmac.h
> >+++ b/drivers/net/ethernet/broadcom/bgmac.h
> >@@ -463,6 +463,7 @@ struct bgmac {
> > 		struct {
> > 			void *base;
> > 			void *idm_base;
> >+			void *nicpm_base;
> > 		} plat;
> > 		struct {
> > 			struct bcma_device *core;
> >
