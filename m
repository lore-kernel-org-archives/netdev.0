From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] c_can_pci: generic module for C_CAN/D_CAN on PCI
Date: Mon, 18 Jun 2012 21:38:13 +0200
Message-ID: <4FDF83A5.6060703@pengutronix.de>
References: <1339674222-27699-1-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9B92C5B0F45B9C39A3561437"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bhupesh SHARMA <bhupesh.sharma@st.com>,
	AnilKumar Chimata <anilkumar@ti.com>,
	Alessandro Rubini <rubini@gnudd.com>
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1339674222-27699-1-git-send-email-federico.vaga@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9B92C5B0F45B9C39A3561437
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/14/2012 01:43 PM, Federico Vaga wrote:
> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Cc: Alan Cox <alan@linux.intel.com>
> ---
>  drivers/net/can/c_can/Kconfig     |    7 ++
>  drivers/net/can/c_can/Makefile    |    1 +
>  drivers/net/can/c_can/c_can_pci.c |  236 +++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 244 insertions(+)
>  create mode 100644 drivers/net/can/c_can/c_can_pci.c
>=20
> diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kcon=
fig
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
> diff --git a/drivers/net/can/c_can/Makefile b/drivers/net/can/c_can/Mak=
efile
> index 9273f6d..ad1cc84 100644
> --- a/drivers/net/can/c_can/Makefile
> +++ b/drivers/net/can/c_can/Makefile
> @@ -4,5 +4,6 @@
> =20
>  obj-$(CONFIG_CAN_C_CAN) +=3D c_can.o
>  obj-$(CONFIG_CAN_C_CAN_PLATFORM) +=3D c_can_platform.o
> +obj-$(CONFIG_CAN_C_CAN_PCI) +=3D c_can_pci.o
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/=
c_can_pci.c
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
> + * registers can be aligned to a 16-bit boundary or 32-bit boundary et=
c.
> + * Handle the same by providing a common read/write interface.
> + */
> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv *priv=
,
> +						enum reg index)
> +{
> +	return readw(priv->base + priv->regs[index]);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_16bit(struct c_can_priv *pr=
iv,
> +						enum reg index, u16 val)
> +{
> +	writew(val, priv->base + priv->regs[index]);
> +}
> +
> +static u16 c_can_pci_read_reg_aligned_to_32bit(struct c_can_priv *priv=
,
> +						enum reg index)
> +{
> +	return readw(priv->base + 2 * priv->regs[index]);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv *pr=
iv,
> +						enum reg index, u16 val)
> +{
> +	writew(val, priv->base + 2 * priv->regs[index]);
> +}
> +
> +static int __devinit c_can_pci_probe(struct pci_dev *pdev,
> +				     const struct pci_device_id *ent)
> +{
> +	struct c_can_pci_data *c_can_pci_data =3D (void *)ent->driver_data;
> +	struct c_can_priv *priv;
> +	struct net_device *dev;
> +	void __iomem *addr;
> +	struct clk *clk;
> +	int ret;
> +
> +	ret =3D pci_enable_device(pdev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "pci_enable_device FAILED\n");
> +		goto out;
> +	}
> +
> +	ret =3D pci_request_regions(pdev, KBUILD_MODNAME);
> +	if (ret) {
> +		dev_err(&pdev->dev, "pci_request_regions FAILED\n");
> +		goto out_disable_device;
> +	}
> +
> +	pci_set_master(pdev);
> +	pci_enable_msi(pdev);
> +
> +	addr =3D pci_iomap(pdev, 0, pci_resource_len(pdev, 0));
> +	if (!addr) {
> +		dev_err(&pdev->dev,
> +			"device has no PCI memory resources, "
> +			"failing adapter\n");
> +		ret =3D -ENOMEM;
> +		goto out_release_regions;
> +	}
> +
> +	/* allocate the c_can device */
> +	dev =3D alloc_c_can_dev();
> +	if (!dev) {
> +		ret =3D -ENOMEM;
> +		goto out_iounmap;
> +	}
> +
> +	priv =3D netdev_priv(dev);
> +	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	dev->irq =3D pdev->irq;
> +	priv->base =3D addr;
> +
> +	if (!c_can_pci_data->freq) {
> +		/* get the appropriate clk */
> +		clk =3D clk_get(&pdev->dev, NULL);
> +		if (IS_ERR(clk)) {
> +			dev_err(&pdev->dev, "no clock defined\n");
> +			ret =3D -ENODEV;
> +			goto out_free_c_can;
> +		}
> +		priv->can.clock.freq =3D clk_get_rate(clk);
> +		priv->priv =3D clk;
> +	} else {
> +		priv->can.clock.freq =3D c_can_pci_data->freq;
> +		priv->priv =3D NULL;
> +	}
> +
> +	/* Configure CAN type */
> +	switch (c_can_pci_data->type) {
> +	case C_CAN_DEVTYPE:
> +		priv->regs =3D reg_map_c_can;
> +		break;
> +	case D_CAN_DEVTYPE:
> +		priv->regs =3D reg_map_d_can;
> +		priv->can.ctrlmode_supported |=3D CAN_CTRLMODE_3_SAMPLES;
> +		break;
> +	default:
> +		ret =3D -EINVAL;
> +		goto out_free_clock;
> +	}
> +
> +	/* Configure access to registers */
> +	switch (c_can_pci_data->reg_align) {
> +	case C_CAN_REG_ALIGN_32:
> +		priv->read_reg =3D c_can_pci_read_reg_aligned_to_32bit;
> +		priv->write_reg =3D c_can_pci_write_reg_aligned_to_32bit;
> +		break;
> +	case C_CAN_REG_ALIGN_16:
> +		priv->read_reg =3D c_can_pci_read_reg_aligned_to_16bit;
> +		priv->write_reg =3D c_can_pci_write_reg_aligned_to_16bit;
> +		break;
> +	default:
> +		ret =3D -EINVAL;
> +		goto out_free_clock;
> +	}
> +
> +	ret =3D register_c_can_dev(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err=3D%d)\n",
> +			KBUILD_MODNAME, ret);
> +		goto out_free_clock;
> +	}
> +
> +	dev_dbg(&pdev->dev, "%s device registered (regs=3D%p, irq=3D%d)\n",
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

I get this warning:

socketcan/linux/drivers/net/can/c_can/c_can_pci.c: In function 'c_can_pci=
_probe':
socketcan/linux/drivers/net/can/c_can/c_can_pci.c:71: warning: 'priv' may=
 be used uninitialized in this function

What about:

-       pci_iounmap(pdev, priv->base);
+       pci_iounmap(pdev, addr);

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
> +	struct net_device *dev =3D pci_get_drvdata(pdev);
> +	struct c_can_priv *priv =3D netdev_priv(dev);
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
> +static struct c_can_pci_data c_can_sta2x11=3D {
> +	.type =3D C_CAN_DEVTYPE,
> +	.reg_align =3D C_CAN_REG_ALIGN_32,
> +	.freq =3D 52000000, /* 52 Mhz */
> +};
> +
> +#define C_CAN_ID(_vend, _dev, _driverdata) {		\
> +	PCI_DEVICE(_vend, _dev),			\
> +	.driver_data =3D (unsigned long)&_driverdata,	\
> +}
> +static DEFINE_PCI_DEVICE_TABLE(c_can_pci_tbl) =3D {
> +	C_CAN_ID(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN,
> +		 c_can_sta2x11),
> +	{},
> +};
> +static struct pci_driver c_can_pci_driver =3D {
> +	.name =3D KBUILD_MODNAME,
> +	.id_table =3D c_can_pci_tbl,
> +	.probe =3D c_can_pci_probe,
> +	.remove =3D __devexit_p(c_can_pci_remove),
> +};
> +
> +module_pci_driver(c_can_pci_driver);
> +
> +MODULE_AUTHOR("Federico Vaga <federico.vaga@gmail.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("PCI CAN bus driver for Bosch C_CAN/D_CAN controlle=
r");
> +MODULE_DEVICE_TABLE(pci, c_can_pci_tbl);

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9B92C5B0F45B9C39A3561437
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/fg6kACgkQjTAFq1RaXHOMRACfbooz7IXpIRQ0BWTgwgNzitfQ
C18An1t3tfpDpYwOadYpp+22zzI4kOD8
=Pd07
-----END PGP SIGNATURE-----

--------------enig9B92C5B0F45B9C39A3561437--
