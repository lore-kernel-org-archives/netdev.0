From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.
Date: Tue, 24 Mar 2009 11:32:11 +0100
Message-ID: <200903241132.12836.florian@openwrt.org>
References: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:50608 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975AbZCXKcU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 06:32:20 -0400
In-Reply-To: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thierry,

Le Tuesday 24 March 2009 11:18:43 Thierry Reding, vous avez =C3=A9crit=C2=
=A0:
> This patch adds a platform device driver that supports the OpenCores =
10/100
> Mbps Ethernet MAC.
>
> The driver expects three resources: one IORESOURCE_MEM resource defin=
es the
> memory region for the core's memory-mapped registers while a second
> IORESOURCE_MEM resource defines the network packet buffer space. The =
third
> resource, of type IORESOURCE_IRQ, associates an interrupt with the dr=
iver.

I am glad someone updated and submitted this driver, excellent work !. =
=46ew=20
comments below.

> + * Copyright (C) 2007-2008 Avionic Design Development GmbH
> + * Copyright (C) 2008-2009 Avionic Design GmbH

I think there are some other authors like Simon Srot and Tensilica, unl=
ess you=20
did wrote this completely from scratch and did not look at the uClincu=20
open_eth driver at all ?

[snip]

> +/* function prototypes */
> +static int ethoc_set_mac_address(struct net_device *dev, void *addr)=
;
> +static int ethoc_get_mac_address(struct net_device *dev, void *addr)=
;
> +static int ethoc_rx(struct net_device *dev, int budget);
> +static void ethoc_tx(struct net_device *dev);
> +static irqreturn_t ethoc_interrupt(int irq, void *dev_id);

Why do you need these declarations ? Are not your functions properly or=
dered=20
already ?

> +/**
> + * ethoc_probe() - initialize OpenCores ethernet MAC
> + * pdev:	platform device
> + */
> +static int ethoc_probe(struct platform_device *pdev)
> +{
> +	struct net_device *netdev =3D NULL;
> +	struct resource *res =3D NULL;
> +	struct resource *mmio =3D NULL;
> +	struct resource *mem =3D NULL;
> +	struct ethoc *priv =3D NULL;
> +	unsigned int phy;
> +	int ret =3D 0;
> +
> +	/* allocate networking device */
> +	netdev =3D alloc_etherdev(sizeof(struct ethoc));
> +	if (!netdev) {
> +		dev_err(&pdev->dev, "cannot allocate network device\n");
> +		ret =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +	platform_set_drvdata(pdev, netdev);
> +
> +	/* obtain I/O memory space */
> +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		dev_err(&pdev->dev, "cannot obtain I/O memory space\n");
> +		ret =3D -ENXIO;
> +		goto free;
> +	}
> +
> +	mmio =3D devm_request_mem_region(&pdev->dev, res->start,
> +			res->end - res->start + 1, res->name);
> +	if (!res) {
> +		dev_err(&pdev->dev, "cannot request I/O memory space\n");
> +		ret =3D -ENXIO;
> +		goto free;
> +	}
> +
> +	netdev->base_addr =3D mmio->start;
> +
> +	/* obtain buffer memory space */
> +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	if (!res) {
> +		dev_err(&pdev->dev, "cannot obtain memory space\n");
> +		ret =3D -ENXIO;
> +		goto free;
> +	}

That's what uClinux driver calls SRAM right ?

[snip]

> +	/* setup the net_device structure */
> +	netdev->open =3D ethoc_open;
> +	netdev->stop =3D ethoc_stop;
> +	netdev->do_ioctl =3D ethoc_ioctl;
> +	netdev->set_config =3D ethoc_config;
> +	netdev->set_mac_address =3D ethoc_set_mac_address;
> +	netdev->set_multicast_list =3D ethoc_set_multicast_list;
> +	netdev->change_mtu =3D ethoc_change_mtu;
> +	netdev->tx_timeout =3D ethoc_tx_timeout;
> +	netdev->get_stats =3D ethoc_stats;
> +	netdev->hard_start_xmit =3D ethoc_start_xmit;
> +	netdev->watchdog_timeo =3D ETHOC_TIMEOUT;
> +	netdev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDM=
A;

Please use netdev_ops.

[snip]

> +#ifndef LINUX_NET_ETHOC_H
> +#define LINUX_NET_ETHOC_H 1
> +
> +struct ethoc_platform_data {
> +	u8 hwaddr[IFHWADDRLEN];
> +	s8 phy_id;

What about allowing platform configuration of the RX/TX buffers size an=
d=20
number of them ?

Otherwise

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
