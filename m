From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/3] net: Add MDIO bus driver for the Hisilicon FEMAC
Date: Mon, 13 Jun 2016 15:32:30 +0200
Message-ID: <20160613133230.GA3132@lunn.ch>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <1465798076-176393-2-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
	davem@davemloft.net, xuejiancheng@hisilicon.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465798076-176393-2-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 02:07:54PM +0800, Dongpo Li wrote:
> This patch adds a separate driver for the MDIO interface of the
> Hisilicon Fast Ethernet MAC.
> 
> Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
> ---
>  .../bindings/net/hisilicon-femac-mdio.txt          |  22 +++
>  drivers/net/phy/Kconfig                            |   8 +
>  drivers/net/phy/Makefile                           |   1 +
>  drivers/net/phy/mdio-hisi-femac.c                  | 165 +++++++++++++++++++++
>  4 files changed, 196 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
>  create mode 100644 drivers/net/phy/mdio-hisi-femac.c
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
> new file mode 100644
> index 0000000..6f46337
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
> @@ -0,0 +1,22 @@
> +Hisilicon Fast Ethernet MDIO Controller interface
> +
> +Required properties:
> +- compatible: should be "hisilicon,hisi-femac-mdio".
> +- reg: address and length of the register set for the device.
> +- clocks: A phandle to the reference clock for this device.
> +
> +- PHY subnode: inherits from phy binding [1]
> +[1] Documentation/devicetree/bindings/net/phy.txt
> +
> +Example:
> +mdio: mdio@10091100 {
> +	compatible = "hisilicon,hisi-femac-mdio";
> +	reg = <0x10091100 0x10>;
> +	clocks = <&crg HI3518EV200_MDIO_CLK>;
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	phy0: phy@1 {
> +		reg = <1>;
> +	};
> +};
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 6dad9a9..e257322 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -271,6 +271,14 @@ config MDIO_BCM_IPROC
>  	  This module provides a driver for the MDIO busses found in the
>  	  Broadcom iProc SoC's.
>  
> +config MDIO_HISI_FEMAC
> +	tristate "Hisilicon FEMAC MDIO bus controller"
> +	depends on ARCH_HISI
> +	depends on HAS_IOMEM && OF_MDIO
> +	help
> +	  This module provides a driver for the MDIO busses found in the
> +	  Hisilicon SoC that have an Fast Ethernet MAC.
> +
>  endif # PHYLIB
>  
>  config MICREL_KS8995MA
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index fcdbb92..039c4be 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -44,3 +44,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
>  obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
>  obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
>  obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
> +obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
> diff --git a/drivers/net/phy/mdio-hisi-femac.c b/drivers/net/phy/mdio-hisi-femac.c
> new file mode 100644
> index 0000000..a9eea61
> --- /dev/null
> +++ b/drivers/net/phy/mdio-hisi-femac.c
> @@ -0,0 +1,165 @@
> +/*
> + * Hisilicon Fast Ethernet MDIO Bus Driver
> + *
> + * Copyright (c) 2016 HiSilicon Technologies Co., Ltd.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program. If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/iopoll.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/of_address.h>
> +#include <linux/of_mdio.h>
> +#include <linux/platform_device.h>
> +
> +#define MDIO_RWCTRL		0x00
> +#define MDIO_RO_DATA		0x04
> +#define MDIO_WRITE		BIT(13)
> +#define MDIO_RW_FINISH		BIT(15)
> +#define BIT_PHY_ADDR_OFFSET	8
> +#define BIT_WR_DATA_OFFSET	16
> +
> +struct hisi_femac_mdio_data {
> +	struct clk *clk;
> +	void __iomem *membase;
> +};
> +

Hi Dongpo

Overall this looks good. Just some minor comments

> +static int hisi_femac_mdio_wait_ready(struct mii_bus *bus)
> +{
> +	struct hisi_femac_mdio_data *data = bus->priv;

You could just pass data here. Your read and write functions already
have it.

> +	data->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(data->clk)) {
> +		ret = -ENODEV;
> +		goto err_out_free_mdiobus;
> +	}

Return the error which devm_clk_get() gives you.

> +
> +	ret = clk_prepare_enable(data->clk);
> +	if (ret)
> +		goto err_out_free_mdiobus;
> +
> +	ret = of_mdiobus_register(bus, np);
> +	if (ret)
> +		goto err_out_free_mdiobus;

You leave the clock prepared and enabled on error.

    Andrew
