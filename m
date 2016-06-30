From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH v4 7/7] phy: Add Northstar2 PCI Phy support
Date: Thu, 30 Jun 2016 17:46:09 +0530
Message-ID: <57750D89.7070705@ti.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-8-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Jon Mason <jonmason@broadcom.com>
To: Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465216900-11755-8-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Monday 06 June 2016 06:11 PM, Pramod Kumar wrote:
> Add PCI Phy support for Broadcom Northstar2 SoCs.  This driver uses the
> interface from the iproc mdio mux driver to enable the devices
> respective phys.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Jon Mason <jonmason@broadcom.com>
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
>  drivers/phy/Kconfig            |   8 +++
>  drivers/phy/Makefile           |   2 +-
>  drivers/phy/phy-bcm-ns2-pcie.c | 115 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 124 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/phy/phy-bcm-ns2-pcie.c
> 
> diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
> index b869b98..01fb93b 100644
> --- a/drivers/phy/Kconfig
> +++ b/drivers/phy/Kconfig
> @@ -434,4 +434,12 @@ config PHY_CYGNUS_PCIE
>  
>  source "drivers/phy/tegra/Kconfig"
>  
> +config PHY_NS2_PCIE
> +	tristate "Broadcom Northstar2 PCIe PHY driver"
> +	depends on OF && MDIO_BUS_MUX_BCM_IPROC
> +	select GENERIC_PHY
> +	default ARCH_BCM_IPROC
> +	help
> +	  Enable this to support the Broadcom Northstar2 PCIe PHY.
> +	  If unsure, say N.
>  endmenu
> diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
> index 9c3e73c..7aea094 100644
> --- a/drivers/phy/Makefile
> +++ b/drivers/phy/Makefile
> @@ -53,5 +53,5 @@ obj-$(CONFIG_PHY_TUSB1210)		+= phy-tusb1210.o
>  obj-$(CONFIG_PHY_BRCM_SATA)		+= phy-brcm-sata.o
>  obj-$(CONFIG_PHY_PISTACHIO_USB)		+= phy-pistachio-usb.o
>  obj-$(CONFIG_PHY_CYGNUS_PCIE)		+= phy-bcm-cygnus-pcie.o
> -
>  obj-$(CONFIG_ARCH_TEGRA) += tegra/
> +obj-$(CONFIG_PHY_NS2_PCIE)		+= phy-bcm-ns2-pcie.o
> diff --git a/drivers/phy/phy-bcm-ns2-pcie.c b/drivers/phy/phy-bcm-ns2-pcie.c
> new file mode 100644
> index 0000000..9513f7a
> --- /dev/null
> +++ b/drivers/phy/phy-bcm-ns2-pcie.c
> @@ -0,0 +1,115 @@
> +/*
> + * Copyright (C) 2016 Broadcom
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/device.h>
> +#include <linux/module.h>
> +#include <linux/of_mdio.h>
> +#include <linux/mdio.h>
> +#include <linux/phy.h>
> +#include <linux/phy/phy.h>
> +
> +struct ns2_pci_phy {
> +	struct mdio_device *mdiodev;
> +	struct phy *phy;
> +};
> +
> +#define BLK_ADDR_REG_OFFSET	0x1f
> +#define PLL_AFE1_100MHZ_BLK	0x2100
> +#define PLL_CLK_AMP_OFFSET	0x03
> +#define PLL_CLK_AMP_2P05V	0x2b18
> +
> +static int ns2_pci_phy_init(struct phy *p)
> +{
> +	struct ns2_pci_phy *phy = phy_get_drvdata(p);
> +	int rc;
> +
> +	/* select the AFE 100MHz block page */
> +	rc = mdiobus_write(phy->mdiodev->bus, phy->mdiodev->addr,
> +			   BLK_ADDR_REG_OFFSET, PLL_AFE1_100MHZ_BLK);
> +	if (rc)
> +		goto err;
> +
> +	/* set the 100 MHz reference clock amplitude to 2.05 v */
> +	rc = mdiobus_write(phy->mdiodev->bus, phy->mdiodev->addr,
> +			   PLL_CLK_AMP_OFFSET, PLL_CLK_AMP_2P05V);
> +	if (rc)
> +		goto err;
> +
> +	return 0;
> +
> +err:
> +	dev_err(&phy->mdiodev->dev, "Error %d writing to phy\n", rc);
> +	return rc;
> +}
> +
> +static struct phy_ops ns2_pci_phy_ops = {
> +	.init = ns2_pci_phy_init,

.owner is required for phy_ops.
> +};
> +
> +static int ns2_pci_phy_probe(struct mdio_device *mdiodev)
> +{
> +	struct device *dev = &mdiodev->dev;
> +	struct phy_provider *provider;
> +	struct ns2_pci_phy *p;
> +	struct phy *phy;
> +
> +	phy = devm_phy_create(dev, dev->of_node, &ns2_pci_phy_ops);
> +	if (IS_ERR(phy)) {
> +		dev_err(dev, "failed to create Phy\n");
> +		return PTR_ERR(phy);
> +	}
> +
> +	p = devm_kmalloc(dev, sizeof(struct ns2_pci_phy),
> +			 GFP_KERNEL);
> +	if (!p)
> +		return -ENOMEM;
> +
> +	p->mdiodev = mdiodev;
> +	dev_set_drvdata(dev, p);
> +
> +	p->phy = phy;
> +	phy_set_drvdata(phy, p);
> +
> +	provider = devm_of_phy_provider_register(&phy->dev,
> +						 of_phy_simple_xlate);

just use return PTR_ERR_OR_ZERO(provider);

All the error messages are un-necessary.

Thanks
Kishon
