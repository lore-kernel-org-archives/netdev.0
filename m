From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH] c_can_pci: generic module for C_CAN/D_CAN on PCI
Date: Thu, 14 Jun 2012 19:58:14 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA90D5EE4@EAPEX1MAIL1.st.com>
References: <1339674222-27699-1-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	AnilKumar Chimata <anilkumar@ti.com>,
	Alessandro Rubini <rubini@gnudd.com>
To: Federico Vaga <federico.vaga@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1339674222-27699-1-git-send-email-federico.vaga@gmail.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Federico,

Thanks for the patch.

> -----Original Message-----
> From: Federico Vaga [mailto:federico.vaga@gmail.com]
> Sent: Thursday, June 14, 2012 5:14 PM
> To: Wolfgang Grandegger; Marc Kleine-Budde
> Cc: Giancarlo ASNAGHI; Alan Cox; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Bhupesh SHARMA;
> AnilKumar Chimata; Alessandro Rubini; Federico Vaga
> Subject: [PATCH] c_can_pci: generic module for C_CAN/D_CAN on PCI
> 
> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Cc: Alan Cox <alan@linux.intel.com>
> ---
>  drivers/net/can/c_can/Kconfig     |    7 ++
>  drivers/net/can/c_can/Makefile    |    1 +
>  drivers/net/can/c_can/c_can_pci.c |  236
> +++++++++++++++++++++++++++++++++++++
>  3 files changed, 244 insertions(+)
>  create mode 100644 drivers/net/can/c_can/c_can_pci.c
> 
> diff --git a/drivers/net/can/c_can/Kconfig
> b/drivers/net/can/c_can/Kconfig
> index 25d371c..3b83baf 100644
> --- a/drivers/net/can/c_can/Kconfig
> +++ b/drivers/net/can/c_can/Kconfig
> @@ -13,4 +13,11 @@ config CAN_C_CAN_PLATFORM
>  	  boards from ST Microelectronics (http://www.st.com) like the
>  	  SPEAr1310 and SPEAr320 evaluation boards & TI (www.ti.com)
>  	  boards like am335x, dm814x, dm813x and dm811x.
> +
> +config CAN_C_CAN_PCI
> +	tristate "Generic PCI Bus based C_CAN/D_CAN driver"
> +	depends on PCI
> +	---help---
> +	  This driver adds support for the C_CAN/D_CAN chips connected
> +	  to the PCI bus.
>  endif
> diff --git a/drivers/net/can/c_can/Makefile
> b/drivers/net/can/c_can/Makefile
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
> diff --git a/drivers/net/can/c_can/c_can_pci.c
> b/drivers/net/can/c_can/c_can_pci.c
> new file mode 100644
> index 0000000..7bdb793
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can_pci.c
> @@ -0,0 +1,236 @@
> +/*
> + * PCI bus driver for Bosch C_CAN/D_CAN controller
> + *
> + * Copyright (C) 2012 Federico Vaga <federico.vaga@gmail.com>
> + *
> + * Borrowed from c_can_platform.c
> + *
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
> +
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
> +	/* Specify if is C_CAN or D_CAN */
> +	enum c_can_dev_id type;
> +	/* Set the register alignment in the memory */
> +	enum c_can_pci_reg_align reg_align;
> +	/* Set the frequency if clk is not usable */
> +	unsigned int freq;
> +};
> +
> +/*
> + * 16-bit c_can registers can be arranged differently in the memory
> + * architecture of different implementations. For example: 16-bit
> + * registers can be aligned to a 16-bit boundary or 32-bit boundary
> etc.
> + * Handle the same by providing a common read/write interface.
> + */
> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv
> *priv,
> +						enum reg index)
> +{
> +	return readw(priv->base + priv->regs[index]);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_16bit(struct c_can_priv
> *priv,
> +						enum reg index, u16 val)
> +{
> +	writew(val, priv->base + priv->regs[index]);
> +}
> +
> +static u16 c_can_pci_read_reg_aligned_to_32bit(struct c_can_priv
> *priv,
> +						enum reg index)
> +{
> +	return readw(priv->base + 2 * priv->regs[index]);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv
> *priv,
> +						enum reg index, u16 val)
> +{
> +	writew(val, priv->base + 2 * priv->regs[index]);
> +}
> +
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
> +	priv->base = addr;
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
> +	/* Configure CAN type */
> +	switch (c_can_pci_data->type) {
> +	case C_CAN_DEVTYPE:
> +		priv->regs = reg_map_c_can;
> +		break;
> +	case D_CAN_DEVTYPE:
> +		priv->regs = reg_map_d_can;
> +		priv->can.ctrlmode_supported |= CAN_CTRLMODE_3_SAMPLES;
> +		break;
> +	default:
> +		ret = -EINVAL;
> +		goto out_free_clock;
> +	}
> +
> +	/* Configure access to registers */
> +	switch (c_can_pci_data->reg_align) {
> +	case C_CAN_REG_ALIGN_32:
> +		priv->read_reg = c_can_pci_read_reg_aligned_to_32bit;
> +		priv->write_reg = c_can_pci_write_reg_aligned_to_32bit;
> +		break;
> +	case C_CAN_REG_ALIGN_16:
> +		priv->read_reg = c_can_pci_read_reg_aligned_to_16bit;
> +		priv->write_reg = c_can_pci_write_reg_aligned_to_16bit;
> +		break;
> +	default:
> +		ret = -EINVAL;
> +		goto out_free_clock;
> +	}
> +
> +	ret = register_c_can_dev(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
> +			KBUILD_MODNAME, ret);
> +		goto out_free_clock;
> +	}
> +
> +	dev_dbg(&pdev->dev, "%s device registered (regs=%p, irq=%d)\n",
> +		 KBUILD_MODNAME, priv->regs, dev->irq);
> +
> +	return 0;
> +
> +out_free_clock:
> +	if (priv->priv)
> +		clk_put(priv->priv);
> +out_free_c_can:
> +	pci_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);
> +out_iounmap:
> +	pci_iounmap(pdev, priv->base);
> +out_release_regions:
> +	pci_disable_msi(pdev);
> +	pci_clear_master(pdev);
> +	pci_release_regions(pdev);
> +out_disable_device:
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
> +	unregister_c_can_dev(dev);
> +
> +	if (priv->priv)
> +		clk_put(priv->priv);
> +
> +	pci_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);
> +
> +	pci_iounmap(pdev, priv->base);
> +	pci_disable_msi(pdev);
> +	pci_clear_master(pdev);
> +	pci_release_regions(pdev);
> +	pci_disable_device(pdev);
> +}
> +
> +static struct c_can_pci_data c_can_sta2x11= {
> +	.type = C_CAN_DEVTYPE,
> +	.reg_align = C_CAN_REG_ALIGN_32,
> +	.freq = 52000000, /* 52 Mhz */
> +};
> +
> +#define C_CAN_ID(_vend, _dev, _driverdata) {		\
> +	PCI_DEVICE(_vend, _dev),			\
> +	.driver_data = (unsigned long)&_driverdata,	\
> +}
> +static DEFINE_PCI_DEVICE_TABLE(c_can_pci_tbl) = {
> +	C_CAN_ID(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN,
> +		 c_can_sta2x11),
> +	{},
> +};
> +static struct pci_driver c_can_pci_driver = {
> +	.name = KBUILD_MODNAME,
> +	.id_table = c_can_pci_tbl,
> +	.probe = c_can_pci_probe,
> +	.remove = __devexit_p(c_can_pci_remove),
> +};
> +
> +module_pci_driver(c_can_pci_driver);
> +
> +MODULE_AUTHOR("Federico Vaga <federico.vaga@gmail.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("PCI CAN bus driver for Bosch C_CAN/D_CAN
> controller");
> +MODULE_DEVICE_TABLE(pci, c_can_pci_tbl);
> --

Acked-by: Bhupesh Sharma <bhupesh.sharma@st.com>

Regards,
Bhupesh
