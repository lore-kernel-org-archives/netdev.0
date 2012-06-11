From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 11 Jun 2012 16:09:23 +0200
Message-ID: <4FD5FC13.8040800@grandegger.com>
References: <4FC135C6.5030206@grandegger.com> <1338816766-7089-1-git-send-email-federico.vaga@gmail.com> <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Federico,

here comes my late review. Mark and others have already commented and I
will focus on further improvements...

On 06/04/2012 03:32 PM, Federico Vaga wrote:

A few more words would be nice here.

> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Cc: Alan Cox <alan@linux.intel.com>
> ---
>  drivers/net/can/c_can/Kconfig     |   11 +-
>  drivers/net/can/c_can/Makefile    |    1 +
>  drivers/net/can/c_can/c_can_pci.c |  221 +++++++++++++++++++++++++++++++++++++
>  3 files changed, 230 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/net/can/c_can/c_can_pci.c
> 
> diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kconfig
> index ffb9773..74ef97d 100644
> --- a/drivers/net/can/c_can/Kconfig
> +++ b/drivers/net/can/c_can/Kconfig
> @@ -2,14 +2,19 @@ menuconfig CAN_C_CAN
>  	tristate "Bosch C_CAN devices"
>  	depends on CAN_DEV && HAS_IOMEM
>  
> -if CAN_C_CAN
> -

Please don't change unrelated things. It's done that way also in other
CAN subdirectories.

>  config CAN_C_CAN_PLATFORM
>  	tristate "Generic Platform Bus based C_CAN driver"
> +	depends on CAN_C_CAN
>  	---help---
>  	  This driver adds support for the C_CAN chips connected to
>  	  the "platform bus" (Linux abstraction for directly to the
>  	  processor attached devices) which can be found on various
>  	  boards from ST Microelectronics (http://www.st.com)
>  	  like the SPEAr1310 and SPEAr320 evaluation boards.
> -endif
> +
> +config CAN_C_CAN_PCI
> +	tristate "Generic PCI Bus based C_CAN driver"
> +	depends on CAN_C_CAN
> +	---help---
> +	  This driver adds support for the C_CAN chips connected to
> +	  the PCI bus.
> diff --git a/drivers/net/can/c_can/Makefile b/drivers/net/can/c_can/Makefile
> index 9273f6d..ad1cc84 100644
> --- a/drivers/net/can/c_can/Makefile
> +++ b/drivers/net/can/c_can/Makefile
> @@ -4,5 +4,6 @@
>  
>  obj-$(CONFIG_CAN_C_CAN) += c_can.o
>  obj-$(CONFIG_CAN_C_CAN_PLATFORM) += c_can_platform.o
> +obj-$(CONFIG_CAN_C_CAN_PCI) += c_can_pci.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
> new file mode 100644
> index 0000000..b635375
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can_pci.c
> @@ -0,0 +1,221 @@
> +/*
> + * Platform CAN bus driver for Bosch C_CAN controller

s /Platform/PCI/ ?

> + *
> + * Copyright (C) 2012 Federico Vaga <federico.vaga@gmail.com>
> +  *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/clk.h>
> +#include <linux/pci.h>
> +#include <linux/can/dev.h>
> +
> +#include "c_can.h"
> +
> +enum c_can_pci_reg_align {
> +	C_CAN_REG_ALIGN_16,
> +	C_CAN_REG_ALIGN_32,
> +};
> +
> +struct c_can_pci_data {
> +	unsigned int reg_align;	/* Set the register alignment in the memory */

Should be "enum c_can_pci_reg_align" here.

> +	unsigned int freq;	/* Set the frequency if clk is not usable */
> +};
> +
> +/*
> + * 16-bit c_can registers can be arranged differently in the memory
> + * architecture of different implementations. For example: 16-bit
> + * registers can be aligned to a 16-bit boundary or 32-bit boundary etc.
> + * Handle the same by providing a common read/write interface.
> + */
> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv *priv,
> +						void *reg)
> +{
> +	return readw(reg);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_16bit(struct c_can_priv *priv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg);
> +}
> +
> +static u16 c_can_pci_read_reg_aligned_to_32bit(struct c_can_priv *priv,
> +						void *reg)
> +{
> +	return readw(reg + (long)reg - (long)priv->regs);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv *priv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg + (long)reg - (long)priv->regs);
> +}

This will look better with the new register access methods.

> +static int __devinit c_can_pci_probe(struct pci_dev *pdev,
> +				     const struct pci_device_id *ent)
> +{
> +	struct c_can_pci_data *c_can_pci_data = (void *)ent->driver_data;
> +	struct c_can_priv *priv;
> +	struct net_device *dev;
> +	void __iomem *addr;
> +	struct clk *clk;
> +	int ret;
> +
> +	ret = pci_enable_device(pdev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "pci_enable_device FAILED\n");
> +		goto out;
> +	}
> +
> +	ret = pci_request_regions(pdev, KBUILD_MODNAME);
> +	if (ret) {
> +		dev_err(&pdev->dev, "pci_request_regions FAILED\n");
> +		goto out_disable_device;
> +	}
> +
> +	pci_set_master(pdev);
> +	pci_enable_msi(pdev);
> +
> +	addr = pci_iomap(pdev, 0, pci_resource_len(pdev, 0));
> +	if (!addr) {
> +		dev_err(&pdev->dev,
> +			"device has no PCI memory resources, "
> +			"failing adapter\n");
> +		ret = -ENOMEM;
> +		goto out_release_regions;
> +	}
> +
> +	/* allocate the c_can device */
> +	dev = alloc_c_can_dev();
> +	if (!dev) {
> +		ret = -ENOMEM;
> +		goto out_iounmap;
> +	}
> +
> +	priv = netdev_priv(dev);
> +	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	dev->irq = pdev->irq;
> +	priv->regs = addr;
> +
> +	if (!c_can_pci_data->freq) {
> +		/* get the appropriate clk */
> +		clk = clk_get(&pdev->dev, NULL);
> +		if (IS_ERR(clk)) {
> +			dev_err(&pdev->dev, "no clock defined\n");
> +			ret = -ENODEV;
> +			goto out_free_c_can;
> +		}
> +		priv->can.clock.freq = clk_get_rate(clk);
> +		priv->priv = clk;
> +	} else {
> +		priv->can.clock.freq = c_can_pci_data->freq;
> +		priv->priv = NULL;
> +	}
> +
> +	switch (c_can_pci_data->reg_align) {
> +	case C_CAN_REG_ALIGN_32:
> +		priv->read_reg = c_can_pci_read_reg_aligned_to_32bit;
> +		priv->write_reg = c_can_pci_write_reg_aligned_to_32bit;
> +		break;
> +	case C_CAN_REG_ALIGN_16:
> +	default:
> +		priv->read_reg = c_can_pci_read_reg_aligned_to_16bit;
> +		priv->write_reg = c_can_pci_write_reg_aligned_to_16bit;
> +		break;
> +	}
> +
> +	ret = register_c_can_dev(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
> +			KBUILD_MODNAME, ret);
> +		goto out_free_clock;
> +	}
> +
> +	dev_info(&pdev->dev, "%s device registered (regs=%p, irq=%d)\n",
> +		 KBUILD_MODNAME, priv->regs, dev->irq);
> +
> +	return 0;
> +
> +out_free_clock:
> +	if (!priv->priv)
> +		clk_put(priv->priv);
> +out_free_c_can:
> +	pci_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);
> +out_iounmap:
> +	pci_iounmap(pdev, addr);
> +out_release_regions:
> +	pci_disable_msi(pdev);
> +	pci_clear_master(pdev);
> +	pci_release_regions(pdev);
> +out_disable_device:
> +	/*
> +	 * do not call pci_disable_device on sta2x11 because it
> +	 * break all other Bus masters on this EP
> +	 */

Puh!

> +	if(pdev->vendor == PCI_VENDOR_ID_STMICRO &&
> +	   pdev->device == PCI_DEVICE_ID_STMICRO_CAN)
> +		goto out;
> +	pci_disable_device(pdev);
> +out:
> +	return ret;
> +}
> +
> +static void __devexit c_can_pci_remove(struct pci_dev *pdev)
> +{
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct c_can_priv *priv = netdev_priv(dev);
> +
> +	pci_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);

Should be moved a few line down.

> +	if (!priv->priv)
> +		clk_put(priv->priv);
> +	pci_iounmap(pdev, priv->regs);
> +	pci_disable_msi(pdev);
> +	pci_clear_master(pdev);
> +	pci_release_regions(pdev);
> +	/*
> +	 * do not call pci_disable_device on sta2x11 because it
> +	 * break all other Bus masters on this EP
> +	 */
> +	if(pdev->vendor == PCI_VENDOR_ID_STMICRO &&
> +	   pdev->device == PCI_DEVICE_ID_STMICRO_CAN)
> +		return;
> +	pci_disable_device(pdev);
> +}
> +
> +static struct c_can_pci_data c_can_sta2x11= {
> +	.reg_align = C_CAN_REG_ALIGN_32,
> +	.freq = 52000000, /* 52 Mhz */
> +};
> +
> +#define C_CAN_ID(_vend, _dev, _driverdata) {		\
> +	PCI_DEVICE(_vend, _dev),			\
> +	.driver_data = (unsigned long)&_driverdata,	\
> +}
> +DEFINE_PCI_DEVICE_TABLE(c_can_pci_tbl) = {
> +	C_CAN_ID(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN,
> +		 c_can_sta2x11),
> +	{},
> +};
> +static struct pci_driver sta2x11_pci_driver = {

Why do you not use a generic name here?

> +	.name = KBUILD_MODNAME,
> +	.id_table = c_can_pci_tbl,
> +	.probe = c_can_pci_probe,
> +	.remove = __devexit_p(c_can_pci_remove),
> +};
> +
> +module_pci_driver(sta2x11_pci_driver);
> +
> +MODULE_AUTHOR("Federico Vaga <federico.vaga@gmail.com>");
> +MODULE_LICENSE("GPL V2");
> +MODULE_DESCRIPTION("PCI CAN bus driver for Bosch C_CAN controller");
> +MODULE_DEVICE_TABLE(pci, c_can_pci_tbl);

Thanks for your contribution.

Wolfgang.
