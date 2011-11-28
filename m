From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Mon, 28 Nov 2011 13:09:23 +0100
Message-ID: <4ED379F3.1070206@pengutronix.de>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAC91A1F18A725703AC41175F"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1322214204-1121-3-git-send-email-wg@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAC91A1F18A725703AC41175F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/25/2011 10:43 AM, Wolfgang Grandegger wrote:
> This patch adds support for legacy Bosch CC770 and Intel AN82527 CAN
> controllers on the ISA or PC-104 bus. The I/O port or memory address
> and the IRQ number must be specified via module parameters:
>=20
>   insmod cc770_isa.ko port=3D0x310,0x380 irq=3D7,11
>=20
> for ISA devices using I/O ports or:
>=20
>   insmod cc770_isa.ko mem=3D0xd1000,0xd1000 irq=3D7,11
>=20
> for memory mapped ISA devices.
>=20
> Indirect access via address and data port is supported as well:
>=20
>   insmod cc770_isa.ko port=3D0x310,0x380 indirect=3D1 irq=3D7,11
>=20
> Furthermore, the following mode parameter can be defined:
>=20
>   clk: External oscillator clock frequency (default=3D16000000 [16 MHz]=
)
>   cir: CPU interface register (default=3D0x40 [DSC])
>   ocr, Bus configuration register (default=3D0x40 [CBY])
>   cor, Clockout register (default=3D0x00)
>=20
> Note: for clk, cir, bcr and cor, the first argument re-defines the
> default for all other devices, e.g.:
>=20
>   insmod cc770_isa.ko mem=3D0xd1000,0xd1000 irq=3D7,11 clk=3D24000000
>=20
> is equivalent to
>=20
>   insmod cc770_isa.ko mem=3D0xd1000,0xd1000 irq=3D7,11 clk=3D24000000,2=
4000000
>=20
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Some nitpicking inside.

Marc
> ---
>  drivers/net/can/cc770/Kconfig     |   11 ++
>  drivers/net/can/cc770/Makefile    |    1 +
>  drivers/net/can/cc770/cc770_isa.c |  336 +++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 348 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/cc770/cc770_isa.c
>=20
> diff --git a/drivers/net/can/cc770/Kconfig b/drivers/net/can/cc770/Kcon=
fig
> index 225131b..28e4d48 100644
> --- a/drivers/net/can/cc770/Kconfig
> +++ b/drivers/net/can/cc770/Kconfig
> @@ -1,3 +1,14 @@
>  menuconfig CAN_CC770
>  	tristate "Bosch CC770 and Intel AN82527 devices"
>  	depends on CAN_DEV && HAS_IOMEM
> +
> +if CAN_CC770
> +
> +config CAN_CC770_ISA
> +	tristate "ISA Bus based legacy CC770 driver"
> +	---help---
> +	  This driver adds legacy support for CC770 and AN82527 chips
> +	  connected to the ISA bus using I/O port, memory mapped or
> +	  indirect access.
> +
> +endif
> diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Mak=
efile
> index 34e8180..872ecff 100644
> --- a/drivers/net/can/cc770/Makefile
> +++ b/drivers/net/can/cc770/Makefile
> @@ -3,5 +3,6 @@
>  #
> =20
>  obj-$(CONFIG_CAN_CC770) +=3D cc770.o
> +obj-$(CONFIG_CAN_CC770_ISA) +=3D cc770_isa.o
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/=
cc770_isa.c
> new file mode 100644
> index 0000000..3aaecd5
> --- /dev/null
> +++ b/drivers/net/can/cc770/cc770_isa.c
> @@ -0,0 +1,336 @@
> +/*
> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
> + *
> + * This program is free software; you can redistribute it and/or modif=
y
> + * it under the terms of the version 2 of the GNU General Public Licen=
se
> + * as published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7  USA

Please remove the address.

> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/platform_device.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/delay.h>
> +#include <linux/irq.h>
> +#include <linux/io.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +
> +#include "cc770.h"
> +
> +#define DRV_NAME "cc770_isa"
> +
> +#define MAXDEV 8
> +
> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
> +MODULE_DESCRIPTION("Socket-CAN driver for CC770 on the ISA bus");
> +MODULE_LICENSE("GPL v2");
> +
> +#define CLK_DEFAULT	16000000	/* 16 MHz */
> +#define COR_DEFAULT	0x00
> +#define BCR_DEFAULT	BUSCFG_CBY
> +
> +static unsigned long port[MAXDEV];
> +static unsigned long mem[MAXDEV];
> +static int __devinitdata irq[MAXDEV];
> +static int __devinitdata clk[MAXDEV];
> +static u8 __devinitdata cir[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D 0xff=
};
> +static u8 __devinitdata cor[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D 0xff=
};
> +static u8 __devinitdata bcr[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D 0xff=
};
> +static int __devinitdata indirect[MAXDEV] =3D {[0 ... (MAXDEV - 1)] =3D=
 -1};
> +
> +module_param_array(port, ulong, NULL, S_IRUGO);
> +MODULE_PARM_DESC(port, "I/O port number");
> +
> +module_param_array(mem, ulong, NULL, S_IRUGO);
> +MODULE_PARM_DESC(mem, "I/O memory address");
> +
> +module_param_array(indirect, int, NULL, S_IRUGO);
> +MODULE_PARM_DESC(indirect, "Indirect access via address and data port"=
);
> +
> +module_param_array(irq, int, NULL, S_IRUGO);
> +MODULE_PARM_DESC(irq, "IRQ number");
> +
> +module_param_array(clk, int, NULL, S_IRUGO);
> +MODULE_PARM_DESC(clk, "External oscillator clock frequency "
> +		 "(default=3D16000000 [16 MHz])");
> +
> +module_param_array(cir, byte, NULL, S_IRUGO);
> +MODULE_PARM_DESC(cir, "CPU interface register (default=3D0x40 [DSC])")=
;
> +
> +module_param_array(cor, byte, NULL, S_IRUGO);
> +MODULE_PARM_DESC(cor, "Clockout register (default=3D0x00)");
> +
> +module_param_array(bcr, byte, NULL, S_IRUGO);
> +MODULE_PARM_DESC(bcr, "Bus configuration register (default=3D0x40 [CBY=
])");
> +
> +#define CC770_IOSIZE          0x20
> +#define CC770_IOSIZE_INDIRECT 0x02
> +
> +static struct platform_device *cc770_isa_devs[MAXDEV];
> +
> +static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int re=
g)
> +{
> +	return readb(priv->reg_base + reg);
> +}
> +
> +static void cc770_isa_mem_write_reg(const struct cc770_priv *priv,
> +				      int reg, u8 val)
> +{
> +	writeb(val, priv->reg_base + reg);
> +}
> +
> +static u8 cc770_isa_port_read_reg(const struct cc770_priv *priv, int r=
eg)
> +{
> +	return inb((unsigned long)priv->reg_base + reg);
> +}
> +
> +static void cc770_isa_port_write_reg(const struct cc770_priv *priv,
> +				       int reg, u8 val)
> +{
> +	outb(val, (unsigned long)priv->reg_base + reg);
> +}
> +
> +static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *pr=
iv,
> +					     int reg)
> +{
> +	unsigned long base =3D (unsigned long)priv->reg_base;
> +
> +	outb(reg, base);
> +	return inb(base + 1);
> +}
> +
> +static void cc770_isa_port_write_reg_indirect(const struct cc770_priv =
*priv,
> +						int reg, u8 val)
> +{
> +	unsigned long base =3D (unsigned long)priv->reg_base;
> +
> +	outb(reg, base);
> +	outb(val, base + 1);
> +}
> +
> +static int __devinit cc770_isa_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct cc770_priv *priv;
> +	void __iomem *base =3D NULL;
> +	int iosize =3D CC770_IOSIZE;
> +	int idx =3D pdev->id;
> +	int err;
> +	u32 clktmp;
> +
> +	dev_dbg(&pdev->dev, "probing idx=3D%d: port=3D%#lx, mem=3D%#lx, irq=3D=
%d\n",
> +		idx, port[idx], mem[idx], irq[idx]);
> +	if (mem[idx]) {
> +		if (!request_mem_region(mem[idx], iosize, DRV_NAME)) {
> +			err =3D -EBUSY;
> +			goto exit;
> +		}
> +		base =3D ioremap_nocache(mem[idx], iosize);
> +		if (!base) {
> +			err =3D -ENOMEM;
> +			goto exit_release;
> +		}
> +	} else {
> +		if (indirect[idx] > 0 ||
> +		    (indirect[idx] =3D=3D -1 && indirect[0] > 0))
> +			iosize =3D CC770_IOSIZE_INDIRECT;
> +		if (!request_region(port[idx], iosize, DRV_NAME)) {
> +			err =3D -EBUSY;
> +			goto exit;
> +		}
> +	}
> +
> +	dev =3D alloc_cc770dev(0);MAXDEV
> +	if (!dev) {
> +		err =3D -ENOMEM;
> +		goto exit_unmap;
> +	}
> +	priv =3D netdev_priv(dev);
> +
> +	dev->irq =3D irq[idx];
> +	priv->irq_flags =3D IRQF_SHARED;
> +	if (mem[idx]) {
> +		priv->reg_base =3D base;
> +		dev->base_addr =3D mem[idx];
> +		priv->read_reg =3D cc770_isa_mem_read_reg;
> +		priv->write_reg =3D cc770_isa_mem_write_reg;
> +	} else {
> +		priv->reg_base =3D (void __iomem *)port[idx];
> +		dev->base_addr =3D port[idx];
> +
> +		if (iosize =3D=3D CC770_IOSIZE_INDIRECT) {
> +			priv->read_reg =3D cc770_isa_port_read_reg_indirect;
> +			priv->write_reg =3D cc770_isa_port_write_reg_indirect;
> +		} else {
> +			priv->read_reg =3D cc770_isa_port_read_reg;
> +			priv->write_reg =3D cc770_isa_port_write_reg;
> +		}
> +	}
> +
> +	if (clk[idx])
> +		clktmp =3D clk[idx];
> +	else if (clk[0])
> +		clktmp =3D clk[0];
> +	else
> +		clktmp =3D CLK_DEFAULT;
> +	priv->can.clock.freq =3D clktmp;
> +
> +	if (cir[idx] !=3D 0xff) {
> +		priv->cpu_interface =3D cir[idx] & 0xff;
> +	} else if (cir[0] !=3D 0xff) {
> +		priv->cpu_interface =3D cir[0] & 0xff;
> +	} else {
> +		/* The system clock may not exceed 10 MHz */
> +		if (clktmp > 10000000) {
> +			priv->cpu_interface |=3D CPUIF_DSC;
> +			clktmp /=3D 2;
> +		}
> +		/* The memory clock may not exceed 8 MHz */
> +		if (clktmp > 8000000)
> +			priv->cpu_interface |=3D CPUIF_DMC;
> +	}
> +
> +	if (priv->cpu_interface & CPUIF_DSC)
> +		priv->can.clock.freq /=3D 2;
> +
> +	if (bcr[idx] !=3D 0xff)
> +		priv->bus_config =3D bcr[idx] & 0xff;
> +	else if (bcr[0] !=3D 0xff)
> +		priv->bus_config =3D bcr[0] & 0xff;
bus_config is u8
> +	else
> +		priv->bus_config =3D BCR_DEFAULT;
> +
> +	if (cor[idx] !=3D 0xff)
> +		priv->clkout =3D cor[idx];
> +	else if (cor[0] !=3D 0xff)
> +		priv->clkout =3D cor[0] & 0xff;
> +	else
> +		priv->clkout =3D COR_DEFAULT;
> +
> +	dev_set_drvdata(&pdev->dev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	err =3D register_cc770dev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "registering %s failed (err=3D%d)\n",
> +			DRV_NAME, err);
> +		goto exit_unmap;
> +	}
> +
> +	dev_info(&pdev->dev, "%s device registered (reg_base=3D0x%p, irq=3D%d=
)\n",
> +		 DRV_NAME, priv->reg_base, dev->irq);
> +	return 0;
> +
> + exit_unmap:
> +	if (mem[idx])
> +		iounmap(base);
> + exit_release:
> +	if (mem[idx])
> +		release_mem_region(mem[idx], iosize);
> +	else
> +		release_region(port[idx], iosize);
> + exit:
> +	return err;
> +}
> +
> +static int __devexit cc770_isa_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev =3D dev_get_drvdata(&pdev->dev);
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	int idx =3D pdev->id;
> +
> +	unregister_cc770dev(dev);
> +	dev_set_drvdata(&pdev->dev, NULL);
> +
> +	if (mem[idx]) {
> +		iounmap(priv->reg_base);
> +		release_mem_region(mem[idx], CC770_IOSIZE);
> +	} else {
> +		if (priv->read_reg =3D=3D cc770_isa_port_read_reg_indirect)
> +			release_region(port[idx], CC770_IOSIZE_INDIRECT);
> +		else
> +			release_region(port[idx], CC770_IOSIZE);
> +	}
> +	free_cc770dev(dev);
> +
> +	return 0;
> +}
> +
> +static struct platform_driver cc770_isa_driver =3D {
> +	.probe =3D cc770_isa_probe,
> +	.remove =3D __devexit_p(cc770_isa_remove),
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +	},
> +};
> +
> +static int __init cc770_isa_init(void)
> +{
> +	int idx, err;
> +
> +	for (idx =3D 0; idx < MAXDEV; idx++) {
ARRAY_SIZE?
> +		if ((port[idx] || mem[idx]) && irq[idx]) {
> +			cc770_isa_devs[idx] =3D
> +				platform_device_alloc(DRV_NAME, idx);
> +			if (!cc770_isa_devs[idx]) {
> +				err =3D -ENOMEM;
> +				goto exit_free_devices;
> +			}
> +			err =3D platform_device_add(cc770_isa_devs[idx]);
> +			if (err) {
> +				platform_device_put(cc770_isa_devs[idx]);
> +				goto exit_free_devices;
> +			}
> +			pr_debug("%s: platform device %d: port=3D%#lx, mem=3D%#lx, "
> +				 "irq=3D%d\n",
> +				 DRV_NAME, idx, port[idx], mem[idx], irq[idx]);
> +		} else if (idx =3D=3D 0 || port[idx] || mem[idx]) {
> +				pr_err("%s: insufficient parameters supplied\n",
> +				       DRV_NAME);
> +				err =3D -EINVAL;
> +				goto exit_free_devices;
> +		}
> +	}
> +
> +	err =3D platform_driver_register(&cc770_isa_driver);
> +	if (err)
> +		goto exit_free_devices;
> +
> +	pr_info("Legacy %s driver for max. %d devices registered\n",
> +		DRV_NAME, MAXDEV);
> +
> +	return 0;
> +
> +exit_free_devices:
> +	while (--idx >=3D 0) {
> +		if (cc770_isa_devs[idx])
> +			platform_device_unregister(cc770_isa_devs[idx]);
> +	}
> +
> +	return err;
> +}
> +module_init(cc770_isa_init);
> +
> +static void __exit cc770_isa_exit(void)
> +{
> +	int idx;
> +
> +	platform_driver_unregister(&cc770_isa_driver);
> +	for (idx =3D 0; idx < MAXDEV; idx++) {
ARRAY_SIZE
> +		if (cc770_isa_devs[idx])
> +			platform_device_unregister(cc770_isa_devs[idx]);
> +	}
> +}
> +module_exit(cc770_isa_exit);


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAC91A1F18A725703AC41175F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7TefMACgkQjTAFq1RaXHP5OwCdHmh+fXtIsozC3COXs9UveBOh
8y4AoJMvDpOL0/gZhnw5lTBlgLnPpjaD
=psVx
-----END PGP SIGNATURE-----

--------------enigAC91A1F18A725703AC41175F--
