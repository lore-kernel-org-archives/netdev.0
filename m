From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH] net: Add support for the OpenCores 10/100 Mbps
	Ethernet MAC.
Date: Wed, 25 Mar 2009 15:43:10 +0100
Message-ID: <20090325144310.GA11710@avionic-design.de>
References: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de> <200903241132.12836.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:56264 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbZCYOnN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 10:43:13 -0400
Content-Disposition: inline
In-Reply-To: <200903241132.12836.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Florian Fainelli wrote:
> Hi Thierry,
>=20
> Le Tuesday 24 March 2009 11:18:43 Thierry Reding, vous avez =C3=A9cri=
t=C2=A0:
> > This patch adds a platform device driver that supports the OpenCore=
s 10/100
> > Mbps Ethernet MAC.
> >
> > The driver expects three resources: one IORESOURCE_MEM resource def=
ines the
> > memory region for the core's memory-mapped registers while a second
> > IORESOURCE_MEM resource defines the network packet buffer space. Th=
e third
> > resource, of type IORESOURCE_IRQ, associates an interrupt with the =
driver.
>=20
> I am glad someone updated and submitted this driver, excellent work !=
=2E Few=20
> comments below.
>=20
> > + * Copyright (C) 2007-2008 Avionic Design Development GmbH
> > + * Copyright (C) 2008-2009 Avionic Design GmbH
>=20
> I think there are some other authors like Simon Srot and Tensilica, u=
nless you=20
> did wrote this completely from scratch and did not look at the uClinc=
u=20
> open_eth driver at all ?

I did look at the uClinux driver at some point, but decided to rewrite =
it-
from scratch. But to be honest it's been quite some time since I starte=
d work
on this and I'm not a 100% certain that one part or another may not be
borrowed from it.

Would it be enough to mention that it is loosely based on the uClinux d=
river?

> > +/* function prototypes */
> > +static int ethoc_set_mac_address(struct net_device *dev, void *add=
r);
> > +static int ethoc_get_mac_address(struct net_device *dev, void *add=
r);
> > +static int ethoc_rx(struct net_device *dev, int budget);
> > +static void ethoc_tx(struct net_device *dev);
> > +static irqreturn_t ethoc_interrupt(int irq, void *dev_id);
>=20
> Why do you need these declarations ? Are not your functions properly =
ordered=20
> already ?

I'll reply to the first patch with an updated version shortly.

> > +/**
> > + * ethoc_probe() - initialize OpenCores ethernet MAC
> > + * pdev:	platform device
> > + */
> > +static int ethoc_probe(struct platform_device *pdev)
> > +{
> > +	struct net_device *netdev =3D NULL;
> > +	struct resource *res =3D NULL;
> > +	struct resource *mmio =3D NULL;
> > +	struct resource *mem =3D NULL;
> > +	struct ethoc *priv =3D NULL;
> > +	unsigned int phy;
> > +	int ret =3D 0;
> > +
> > +	/* allocate networking device */
> > +	netdev =3D alloc_etherdev(sizeof(struct ethoc));
> > +	if (!netdev) {
> > +		dev_err(&pdev->dev, "cannot allocate network device\n");
> > +		ret =3D -ENOMEM;
> > +		goto out;
> > +	}
> > +
> > +	SET_NETDEV_DEV(netdev, &pdev->dev);
> > +	platform_set_drvdata(pdev, netdev);
> > +
> > +	/* obtain I/O memory space */
> > +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	if (!res) {
> > +		dev_err(&pdev->dev, "cannot obtain I/O memory space\n");
> > +		ret =3D -ENXIO;
> > +		goto free;
> > +	}
> > +
> > +	mmio =3D devm_request_mem_region(&pdev->dev, res->start,
> > +			res->end - res->start + 1, res->name);
> > +	if (!res) {
> > +		dev_err(&pdev->dev, "cannot request I/O memory space\n");
> > +		ret =3D -ENXIO;
> > +		goto free;
> > +	}
> > +
> > +	netdev->base_addr =3D mmio->start;
> > +
> > +	/* obtain buffer memory space */
> > +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> > +	if (!res) {
> > +		dev_err(&pdev->dev, "cannot obtain memory space\n");
> > +		ret =3D -ENXIO;
> > +		goto free;
> > +	}
>=20
> That's what uClinux driver calls SRAM right ?

Right.

> > +	/* setup the net_device structure */
> > +	netdev->open =3D ethoc_open;
> > +	netdev->stop =3D ethoc_stop;
> > +	netdev->do_ioctl =3D ethoc_ioctl;
> > +	netdev->set_config =3D ethoc_config;
> > +	netdev->set_mac_address =3D ethoc_set_mac_address;
> > +	netdev->set_multicast_list =3D ethoc_set_multicast_list;
> > +	netdev->change_mtu =3D ethoc_change_mtu;
> > +	netdev->tx_timeout =3D ethoc_tx_timeout;
> > +	netdev->get_stats =3D ethoc_stats;
> > +	netdev->hard_start_xmit =3D ethoc_start_xmit;
> > +	netdev->watchdog_timeo =3D ETHOC_TIMEOUT;
> > +	netdev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGH=
DMA;
>=20
> Please use netdev_ops.

Done.

> > +#ifndef LINUX_NET_ETHOC_H
> > +#define LINUX_NET_ETHOC_H 1
> > +
> > +struct ethoc_platform_data {
> > +	u8 hwaddr[IFHWADDRLEN];
> > +	s8 phy_id;
>=20
> What about allowing platform configuration of the RX/TX buffers size =
and=20
> number of them ?

I think this is a good idea, but I'm not quite sure about how this shou=
ld be
implemented. The total number of buffers is dependent on the total buff=
er size
as defined by the second IORESOURCE_MEM resource. That really only leav=
es the
option for allowing the individual buffer size to be defined by the pla=
tform
configuration. Furthermore the network controller can only handle fixed=
-sized
buffers (at least for reception), so perhaps defining some kind of RX/T=
X
buffer number ratio would be useful. Or perhaps defining a minimum or m=
aximum
number of TX buffers and leaving the rest up for RX for instance.

Any suggestions?

Cheers,
Thierry

