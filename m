From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH net-next] can/sja1000: add driver for EMS PCMCIA card
Date: Fri, 23 Sep 2011 19:32:46 +0200
Message-ID: <20110923173246.GC22719@pengutronix.de>
References: <4E7CBB04.8070807@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FsscpQKzF/jJk6ya"
Cc: David Miller <davem@davemloft.net>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Markus Plessing <plessing@ems-wuensche.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-pcmcia@lists.infradead.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40658 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab1IWRct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 13:32:49 -0400
Content-Disposition: inline
In-Reply-To: <4E7CBB04.8070807@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FsscpQKzF/jJk6ya
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

CCing pcmcia-devel...

On Fri, Sep 23, 2011 at 06:59:48PM +0200, Oliver Hartkopp wrote:
> This patch adds the driver for the SJA1000 based PCMCIA card 'CPC-Card' f=
rom
> EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> ---
>=20
> diff -u -r -N a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000=
/Kconfig
> --- a/drivers/net/can/sja1000/Kconfig	2011-09-23 18:02:35.711750820 +0200
> +++ b/drivers/net/can/sja1000/Kconfig	2011-09-23 18:02:28.695751113 +0200
> @@ -29,6 +29,13 @@
>  	  OpenFirmware bindings, e.g. if you have a PowerPC based system
>  	  you may want to enable this option.
> =20
> +config CAN_EMS_PCMCIA
> +	tristate "EMS CPC-CARD Card"
> +	depends on PCMCIA
> +	---help---
> +	  This driver is for the one or two channel CPC-CARD cards from
> +	  EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
> +
>  config CAN_EMS_PCI
>  	tristate "EMS CPC-PCI, CPC-PCIe and CPC-104P Card"
>  	depends on PCI
> diff -u -r -N a/drivers/net/can/sja1000/Makefile b/drivers/net/can/sja100=
0/Makefile
> --- a/drivers/net/can/sja1000/Makefile	2011-09-23 18:02:38.595750534 +0200
> +++ b/drivers/net/can/sja1000/Makefile	2011-09-23 18:02:28.695751113 +0200
> @@ -6,6 +6,7 @@
>  obj-$(CONFIG_CAN_SJA1000_ISA) +=3D sja1000_isa.o
>  obj-$(CONFIG_CAN_SJA1000_PLATFORM) +=3D sja1000_platform.o
>  obj-$(CONFIG_CAN_SJA1000_OF_PLATFORM) +=3D sja1000_of_platform.o
> +obj-$(CONFIG_CAN_EMS_PCMCIA) +=3D ems_pcmcia.o
>  obj-$(CONFIG_CAN_EMS_PCI) +=3D ems_pci.o
>  obj-$(CONFIG_CAN_KVASER_PCI) +=3D kvaser_pci.o
>  obj-$(CONFIG_CAN_PEAK_PCI) +=3D peak_pci.o
> diff -u -r -N a/drivers/net/can/sja1000/ems_pcmcia.c b/drivers/net/can/sj=
a1000/ems_pcmcia.c
> --- a/drivers/net/can/sja1000/ems_pcmcia.c	1970-01-01 01:00:00.000000000 =
+0100
> +++ b/drivers/net/can/sja1000/ems_pcmcia.c	2011-09-23 18:13:59.227726972 =
+0200
> @@ -0,0 +1,331 @@
> +/*
> + * Copyright (C) 2008 Sebastian Haas (initial chardev implementation)
> + * Copyright (C) 2010 Markus Plessing <plessing@ems-wuensche.com>
> + * Rework for mainline by Oliver Hartkopp <socketcan@hartkopp.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the version 2 of the GNU General Public License
> + * as published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +#include <pcmcia/cistpl.h>
> +#include <pcmcia/ds.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include "sja1000.h"
> +
> +#define DRV_NAME "ems_pcmcia"
> +
> +MODULE_AUTHOR("Markus Plessing <plessing@ems-wuensche.com>");
> +MODULE_DESCRIPTION("Socket-CAN driver for EMS CPC-CARD cards");
> +MODULE_SUPPORTED_DEVICE("EMS CPC-CARD CAN card");
> +MODULE_LICENSE("GPL v2");
> +
> +#define EMS_PCMCIA_MAX_CHAN 2
> +
> +struct ems_pcmcia_card {
> +	int channels;
> +	struct pcmcia_device *pcmcia_dev;
> +	struct net_device *net_dev[EMS_PCMCIA_MAX_CHAN];
> +	void __iomem *base_addr;
> +};
> +
> +#define EMS_PCMCIA_CAN_CLOCK (16000000 / 2)
> +
> +/*
> + * The board configuration is probably following:
> + * RX1 is connected to ground.
> + * TX1 is not connected.
> + * CLKO is not connected.
> + * Setting the OCR register to 0xDA is a good idea.
> + * This means  normal output mode , push-pull and the correct polarity.
> + */
> +#define EMS_PCMCIA_OCR (OCR_TX0_PUSHPULL | OCR_TX1_PUSHPULL)
> +
> +/*
> + * In the CDR register, you should set CBP to 1.
> + * You will probably also want to set the clock divider value to 7
> + * (meaning direct oscillator output) because the second SJA1000 chip
> + * is driven by the first one CLKOUT output.
> + */
> +#define EMS_PCMCIA_CDR (CDR_CBP | CDR_CLKOUT_MASK)
> +#define EMS_PCMCIA_MEM_SIZE 4096 /* Size of the remapped io-memory */
> +#define EMS_PCMCIA_CAN_BASE_OFFSET 0x100 /* Offset where controllers sta=
rts */
> +#define EMS_PCMCIA_CAN_CTRL_SIZE 0x80 /* Memory size for each controller=
 */
> +
> +#define EMS_CMD_RESET 0x00 /* Perform a reset of the card */
> +#define EMS_CMD_MAP   0x03 /* Map CAN controllers into card' memory */
> +#define EMS_CMD_UMAP  0x02 /* Unmap CAN controllers from card' memory */
> +
> +static struct pcmcia_device_id ems_pcmcia_tbl[] =3D {
> +	PCMCIA_DEVICE_PROD_ID123("EMS_T_W", "CPC-Card", "V2.0", 0xeab1ea23,
> +				 0xa338573f, 0xe4575800),
> +	PCMCIA_DEVICE_NULL,
> +};
> +
> +MODULE_DEVICE_TABLE(pcmcia, ems_pcmcia_tbl);
> +
> +static u8 ems_pcmcia_read_reg(const struct sja1000_priv *priv, int port)
> +{
> +	return readb(priv->reg_base + port);
> +}
> +
> +static void ems_pcmcia_write_reg(const struct sja1000_priv *priv, int po=
rt,
> +				 u8 val)
> +{
> +	writeb(val, priv->reg_base + port);
> +}
> +
> +static irqreturn_t ems_pcmcia_interrupt(int irq, void *dev_id)
> +{
> +	struct ems_pcmcia_card *card =3D dev_id;
> +	struct net_device *dev;
> +	irqreturn_t retval =3D IRQ_NONE;
> +	int i, again;
> +
> +	/* Card not present */
> +	if (readw(card->base_addr) !=3D 0xAA55)
> +		return IRQ_HANDLED;
> +
> +	do {
> +		again =3D 0;
> +
> +		/* Check interrupt for each channel */
> +		for (i =3D 0; i < card->channels; i++) {
> +			dev =3D card->net_dev[i];
> +			if (!dev)
> +				continue;
> +
> +			if (sja1000_interrupt(irq, dev) =3D=3D IRQ_HANDLED)
> +				again =3D 1;
> +		}
> +		/* At least one channel handled the interrupt */
> +		if (again)
> +			retval =3D IRQ_HANDLED;
> +
> +	} while (again);
> +
> +	return retval;
> +}
> +
> +/*
> + * Check if a CAN controller is present at the specified location
> + * by trying to set 'em into the PeliCAN mode
> + */
> +static inline int ems_pcmcia_check_chan(struct sja1000_priv *priv)
> +{
> +	/* Make sure SJA1000 is in reset mode */
> +	ems_pcmcia_write_reg(priv, REG_MOD, 1);
> +	ems_pcmcia_write_reg(priv, REG_CDR, CDR_PELICAN);
> +
> +	/* read reset-values */
> +	if (ems_pcmcia_read_reg(priv, REG_CDR) =3D=3D CDR_PELICAN)
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static void ems_pcmcia_del_card(struct pcmcia_device *pdev)
> +{
> +	struct ems_pcmcia_card *card =3D pdev->priv;
> +	struct net_device *dev;
> +	int i;
> +
> +	free_irq(pdev->irq, card);
> +
> +	for (i =3D 0; i < card->channels; i++) {
> +		dev =3D card->net_dev[i];
> +		if (!dev)
> +			continue;
> +
> +		printk(KERN_INFO "%s: removing %s on channel #%d\n",
> +		       DRV_NAME, dev->name, i);
> +		unregister_sja1000dev(dev);
> +		free_sja1000dev(dev);
> +	}
> +
> +	writeb(EMS_CMD_UMAP, card->base_addr);
> +	iounmap(card->base_addr);
> +	kfree(card);
> +
> +	pdev->priv =3D NULL;
> +}
> +
> +/*
> + * Probe PCI device for EMS CAN signature and register each available
> + * CAN channel to SJA1000 Socket-CAN subsystem.
> + */
> +static int __devinit ems_pcmcia_add_card(struct pcmcia_device *pdev,
> +					 unsigned long base)
> +{
> +	struct sja1000_priv *priv;
> +	struct net_device *dev;
> +	struct ems_pcmcia_card *card;
> +	int err, i;
> +
> +	/* Allocating card structures to hold addresses, ... */
> +	card =3D kzalloc(sizeof(struct ems_pcmcia_card), GFP_KERNEL);
> +	if (!card)
> +		return -ENOMEM;
> +
> +	pdev->priv =3D card;
> +	card->channels =3D 0;
> +
> +	card->base_addr =3D ioremap(base, EMS_PCMCIA_MEM_SIZE);
> +	if (!card->base_addr) {
> +		err =3D -ENOMEM;
> +		goto failure_cleanup;
> +	}
> +
> +	/* Check for unique EMS CAN signature */
> +	if (readw(card->base_addr) !=3D 0xAA55) {
> +		err =3D -ENODEV;
> +		goto failure_cleanup;
> +	}
> +
> +	/* Request board reset */
> +	writeb(EMS_CMD_RESET, card->base_addr);
> +
> +	/* Make sure CAN controllers are mapped into card's memory space */
> +	writeb(EMS_CMD_MAP, card->base_addr);
> +
> +	/* Detect available channels */
> +	for (i =3D 0; i < EMS_PCMCIA_MAX_CHAN; i++) {
> +		dev =3D alloc_sja1000dev(0);
> +		if (!dev) {
> +			err =3D -ENOMEM;
> +			goto failure_cleanup;
> +		}
> +
> +		card->net_dev[i] =3D dev;
> +		priv =3D netdev_priv(dev);
> +		priv->priv =3D card;
> +		SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +		priv->irq_flags =3D IRQF_SHARED;
> +		dev->irq =3D pdev->irq;
> +		priv->reg_base =3D card->base_addr + EMS_PCMCIA_CAN_BASE_OFFSET +
> +			(i * EMS_PCMCIA_CAN_CTRL_SIZE);
> +
> +		/* Check if channel is present */
> +		if (ems_pcmcia_check_chan(priv)) {
> +			priv->read_reg  =3D ems_pcmcia_read_reg;
> +			priv->write_reg =3D ems_pcmcia_write_reg;
> +			priv->can.clock.freq =3D EMS_PCMCIA_CAN_CLOCK;
> +			priv->ocr =3D EMS_PCMCIA_OCR;
> +			priv->cdr =3D EMS_PCMCIA_CDR;
> +			priv->flags |=3D SJA1000_CUSTOM_IRQ_HANDLER;
> +
> +			/* Register SJA1000 device */
> +			err =3D register_sja1000dev(dev);
> +			if (err) {
> +				free_sja1000dev(dev);
> +				goto failure_cleanup;
> +			}
> +
> +			card->channels++;
> +
> +			printk(KERN_INFO "%s: registered %s on channel "
> +			       "#%d at 0x%p, irq %d\n", DRV_NAME, dev->name,
> +			       i, priv->reg_base, dev->irq);
> +		} else
> +			free_sja1000dev(dev);
> +	}
> +
> +	err =3D request_irq(dev->irq, &ems_pcmcia_interrupt, IRQF_SHARED,
> +			  DRV_NAME, card);
> +	if (!err)
> +		return 0;
> +
> +failure_cleanup:
> +	ems_pcmcia_del_card(pdev);
> +	return err;
> +}
> +
> +/*
> + * Setup PCMCIA socket and probe for EMS CPC-CARD
> + */
> +static int __devinit ems_pcmcia_probe(struct pcmcia_device *dev)
> +{
> +	int csval;
> +
> +	/* General socket configuration */
> +	dev->config_flags |=3D CONF_ENABLE_IRQ;
> +	dev->config_index =3D 1;
> +	dev->config_regs =3D PRESENT_OPTION;
> +
> +	/* The io structure describes IO port mapping */
> +	dev->resource[0]->end =3D 16;
> +	dev->resource[0]->flags |=3D IO_DATA_PATH_WIDTH_8;
> +	dev->resource[1]->end =3D 16;
> +	dev->resource[1]->flags |=3D IO_DATA_PATH_WIDTH_16;
> +	dev->io_lines =3D 5;
> +
> +	/* Allocate a memory window */
> +	dev->resource[2]->flags =3D
> +		(WIN_DATA_WIDTH_8 | WIN_MEMORY_TYPE_CM | WIN_ENABLE);
> +	dev->resource[2]->start =3D dev->resource[2]->end =3D 0;
> +
> +	csval =3D pcmcia_request_window(dev, dev->resource[2], 0);
> +	if (csval) {
> +		dev_err(&dev->dev, "pcmcia_request_window failed (err=3D%d)\n",
> +			csval);
> +		return 0;
> +	}
> +
> +	csval =3D pcmcia_map_mem_page(dev, dev->resource[2], dev->config_base);
> +	if (csval) {
> +		dev_err(&dev->dev, "pcmcia_map_mem_page failed (err=3D%d)\n",
> +			csval);
> +		return 0;
> +	}
> +
> +	csval =3D pcmcia_enable_device(dev);
> +	if (csval) {
> +		dev_err(&dev->dev, "pcmcia_enable_device failed (err=3D%d)\n",
> +			csval);
> +		return 0;
> +	}
> +
> +	ems_pcmcia_add_card(dev, dev->resource[2]->start);
> +	return 0;
> +}
> +
> +/*
> + * Release claimed resources
> + */
> +static void ems_pcmcia_remove(struct pcmcia_device *dev)
> +{
> +	ems_pcmcia_del_card(dev);
> +	pcmcia_disable_device(dev);
> +}
> +
> +static struct pcmcia_driver ems_pcmcia_driver =3D {
> +	.name =3D DRV_NAME,
> +	.probe =3D ems_pcmcia_probe,
> +	.remove =3D ems_pcmcia_remove,
> +	.id_table =3D ems_pcmcia_tbl,
> +};
> +
> +static int __init ems_pcmcia_init(void)
> +{
> +	return pcmcia_register_driver(&ems_pcmcia_driver);
> +}
> +module_init(ems_pcmcia_init);
> +
> +static void __exit ems_pcmcia_exit(void)
> +{
> +	pcmcia_unregister_driver(&ems_pcmcia_driver);
> +}
> +module_exit(ems_pcmcia_exit);
>=20
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core@lists.berlios.de
> https://lists.berlios.de/mailman/listinfo/socketcan-core

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--FsscpQKzF/jJk6ya
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk58wr4ACgkQD27XaX1/VRtAuACeIrKJ4zm4lIICYAdcq/BOdDsJ
SHYAoKKPPJFKu/TJF4fXhkfrac/7Ka03
=CSm5
-----END PGP SIGNATURE-----

--FsscpQKzF/jJk6ya--
