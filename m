From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 04 Jun 2012 16:04:39 +0200
Message-ID: <4FCCC077.7000303@pengutronix.de>
References: <4FC135C6.5030206@grandegger.com> <1338816766-7089-1-git-send-email-federico.vaga@gmail.com> <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC82CAD5BE406E983A1A3103B"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>,
	Alessandro Rubini <rubini@gnudd.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC82CAD5BE406E983A1A3103B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/04/2012 03:32 PM, Federico Vaga wrote:
> Signed-off-by: Federico Vaga <federico.vaga@gmail.com>
> Acked-by: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
> Cc: Alan Cox <alan@linux.intel.com>

Please port you driver to the recent c_can changes. Use the c_can branch
of the linux-can-next repo[1] as base for your work. You have to rework
the register access function. Please have a look if there are devm_
variants for the registration/mapping of the pci and clock.

[1] https://gitorious.org/linux-can/linux-can-next

More comments inline. Marc

> ---
>  drivers/net/can/c_can/Kconfig     |   11 +-
>  drivers/net/can/c_can/Makefile    |    1 +
>  drivers/net/can/c_can/c_can_pci.c |  221 +++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 230 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/net/can/c_can/c_can_pci.c
>=20
> diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kcon=
fig
> index ffb9773..74ef97d 100644
> --- a/drivers/net/can/c_can/Kconfig
> +++ b/drivers/net/can/c_can/Kconfig
> @@ -2,14 +2,19 @@ menuconfig CAN_C_CAN
>  	tristate "Bosch C_CAN devices"
>  	depends on CAN_DEV && HAS_IOMEM
> =20
> -if CAN_C_CAN

please keep the if CAN_C_CAN...

> -
>  config CAN_C_CAN_PLATFORM
>  	tristate "Generic Platform Bus based C_CAN driver"
> +	depends on CAN_C_CAN

=2E..then you don't have to add the depends on here.

>  	---help---
>  	  This driver adds support for the C_CAN chips connected to
>  	  the "platform bus" (Linux abstraction for directly to the
>  	  processor attached devices) which can be found on various
>  	  boards from ST Microelectronics (http://www.st.com)
>  	  like the SPEAr1310 and SPEAr320 evaluation boards.
> -endif

=2E.. Just move you pci driver inside the if...endif block...
> +
> +config CAN_C_CAN_PCI
> +	tristate "Generic PCI Bus based C_CAN driver"
> +	depends on CAN_C_CAN

=2E..and remove the depends on CAN_C_CAN. You probably have to add a
depends on PCI.

> +	---help---
> +	  This driver adds support for the C_CAN chips connected to
> +	  the PCI bus.
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
> index 0000000..b635375
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can_pci.c
> @@ -0,0 +1,221 @@
> +/*
> + * Platform CAN bus driver for Bosch C_CAN controller
> + *
> + * Copyright (C) 2012 Federico Vaga <federico.vaga@gmail.com>
> +  *
   ^^^ double space :)

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
> +	unsigned int reg_align;	/* Set the register alignment in the memory *=
/
        ^^^^^^^^^^^^
use the enum you defined above.

> +	unsigned int freq;	/* Set the frequency if clk is not usable */
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
> +						void *reg)
> +{
> +	return readw(reg);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_16bit(struct c_can_priv *pr=
iv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg);
> +}
> +
> +static u16 c_can_pci_read_reg_aligned_to_32bit(struct c_can_priv *priv=
,
> +						void *reg)
> +{
> +	return readw(reg + (long)reg - (long)priv->regs);
> +}
> +
> +static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv *pr=
iv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg + (long)reg - (long)priv->regs);
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
> +	priv->regs =3D addr;
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
> +	switch (c_can_pci_data->reg_align) {
> +	case C_CAN_REG_ALIGN_32:
> +		priv->read_reg =3D c_can_pci_read_reg_aligned_to_32bit;
> +		priv->write_reg =3D c_can_pci_write_reg_aligned_to_32bit;
> +		break;
> +	case C_CAN_REG_ALIGN_16:
> +	default:
> +		priv->read_reg =3D c_can_pci_read_reg_aligned_to_16bit;
> +		priv->write_reg =3D c_can_pci_write_reg_aligned_to_16bit;
> +		break;
> +	}
> +
> +	ret =3D register_c_can_dev(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err=3D%d)\n",
> +			KBUILD_MODNAME, ret);
> +		goto out_free_clock;
> +	}
> +
> +	dev_info(&pdev->dev, "%s device registered (regs=3D%p, irq=3D%d)\n",
> +		 KBUILD_MODNAME, priv->regs, dev->irq);
> +
> +	return 0;
> +
> +out_free_clock:
> +	if (!priv->priv)
           ^^^

looks fishy

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
> +	if(pdev->vendor =3D=3D PCI_VENDOR_ID_STMICRO &&
> +	   pdev->device =3D=3D PCI_DEVICE_ID_STMICRO_CAN)
> +		goto out;
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
> +	pci_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);
> +	if (!priv->priv)
dito
> +		clk_put(priv->priv);
> +	pci_iounmap(pdev, priv->regs);
> +	pci_disable_msi(pdev);
> +	pci_clear_master(pdev);
> +	pci_release_regions(pdev);
> +	/*
> +	 * do not call pci_disable_device on sta2x11 because it
> +	 * break all other Bus masters on this EP
> +	 */
> +	if(pdev->vendor =3D=3D PCI_VENDOR_ID_STMICRO &&
> +	   pdev->device =3D=3D PCI_DEVICE_ID_STMICRO_CAN)
> +		return;
> +	pci_disable_device(pdev);
> +}
> +
> +static struct c_can_pci_data c_can_sta2x11=3D {
> +	.reg_align =3D C_CAN_REG_ALIGN_32,
> +	.freq =3D 52000000, /* 52 Mhz */
> +};
> +
> +#define C_CAN_ID(_vend, _dev, _driverdata) {		\
> +	PCI_DEVICE(_vend, _dev),			\
> +	.driver_data =3D (unsigned long)&_driverdata,	\
> +}
> +DEFINE_PCI_DEVICE_TABLE(c_can_pci_tbl) =3D {
^^^^

static?

> +	C_CAN_ID(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN,
> +		 c_can_sta2x11),
> +	{},
> +};
> +static struct pci_driver sta2x11_pci_driver =3D {
> +	.name =3D KBUILD_MODNAME,
> +	.id_table =3D c_can_pci_tbl,
> +	.probe =3D c_can_pci_probe,
> +	.remove =3D __devexit_p(c_can_pci_remove),
> +};
> +
> +module_pci_driver(sta2x11_pci_driver);
> +
> +MODULE_AUTHOR("Federico Vaga <federico.vaga@gmail.com>");
> +MODULE_LICENSE("GPL V2");

IIRC, the correct case is "GPL v2"

> +MODULE_DESCRIPTION("PCI CAN bus driver for Bosch C_CAN controller");
> +MODULE_DEVICE_TABLE(pci, c_can_pci_tbl);


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC82CAD5BE406E983A1A3103B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/MwIIACgkQjTAFq1RaXHPNywCfTzDlL1HA8kYHdY1/5vEXRN1h
cecAmwQcJlYfUwkT6ohOA462Q/6kF3Ra
=lr4L
-----END PGP SIGNATURE-----

--------------enigC82CAD5BE406E983A1A3103B--
