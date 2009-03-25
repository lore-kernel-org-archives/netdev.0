From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.
Date: Wed, 25 Mar 2009 22:00:22 +0100
Message-ID: <200903252200.24365.florian@openwrt.org>
References: <1237889923-32257-1-git-send-email-thierry.reding@avionic-design.de> <200903241132.12836.florian@openwrt.org> <20090325144310.GA11710@avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:62404 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757138AbZCZJIq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 05:08:46 -0400
In-Reply-To: <20090325144310.GA11710@avionic-design.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thierry,

Le Wednesday 25 March 2009 15:43:10 Thierry Reding, vous avez =C3=A9cri=
t=C2=A0:
> I did look at the uClinux driver at some point, but decided to rewrit=
e it-
> from scratch. But to be honest it's been quite some time since I star=
ted
> work on this and I'm not a 100% certain that one part or another may =
not be
> borrowed from it.

Sure my concern was more about the original authors somehow claiming co=
pyright=20
on this sooner or later. That's fine with me.

>
> Would it be enough to mention that it is loosely based on the uClinux
> driver?
>
> > > +/* function prototypes */
> > > +static int ethoc_set_mac_address(struct net_device *dev, void *a=
ddr);
> > > +static int ethoc_get_mac_address(struct net_device *dev, void *a=
ddr);
> > > +static int ethoc_rx(struct net_device *dev, int budget);
> > > +static void ethoc_tx(struct net_device *dev);
> > > +static irqreturn_t ethoc_interrupt(int irq, void *dev_id);
> >
> > Why do you need these declarations ? Are not your functions properl=
y
> > ordered already ?
>
> I'll reply to the first patch with an updated version shortly.
>
> > > +/**
> > > + * ethoc_probe() - initialize OpenCores ethernet MAC
> > > + * pdev:	platform device
> > > + */
> > > +static int ethoc_probe(struct platform_device *pdev)
> > > +{
> > > +	struct net_device *netdev =3D NULL;
> > > +	struct resource *res =3D NULL;
> > > +	struct resource *mmio =3D NULL;
> > > +	struct resource *mem =3D NULL;
> > > +	struct ethoc *priv =3D NULL;
> > > +	unsigned int phy;
> > > +	int ret =3D 0;
> > > +
> > > +	/* allocate networking device */
> > > +	netdev =3D alloc_etherdev(sizeof(struct ethoc));
> > > +	if (!netdev) {
> > > +		dev_err(&pdev->dev, "cannot allocate network device\n");
> > > +		ret =3D -ENOMEM;
> > > +		goto out;
> > > +	}
> > > +
> > > +	SET_NETDEV_DEV(netdev, &pdev->dev);
> > > +	platform_set_drvdata(pdev, netdev);
> > > +
> > > +	/* obtain I/O memory space */
> > > +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > > +	if (!res) {
> > > +		dev_err(&pdev->dev, "cannot obtain I/O memory space\n");
> > > +		ret =3D -ENXIO;
> > > +		goto free;
> > > +	}
> > > +
> > > +	mmio =3D devm_request_mem_region(&pdev->dev, res->start,
> > > +			res->end - res->start + 1, res->name);
> > > +	if (!res) {
> > > +		dev_err(&pdev->dev, "cannot request I/O memory space\n");
> > > +		ret =3D -ENXIO;
> > > +		goto free;
> > > +	}
> > > +
> > > +	netdev->base_addr =3D mmio->start;
> > > +
> > > +	/* obtain buffer memory space */
> > > +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> > > +	if (!res) {
> > > +		dev_err(&pdev->dev, "cannot obtain memory space\n");
> > > +		ret =3D -ENXIO;
> > > +		goto free;
> > > +	}
> >
> > That's what uClinux driver calls SRAM right ?
>
> Right.
>
> > > +	/* setup the net_device structure */
> > > +	netdev->open =3D ethoc_open;
> > > +	netdev->stop =3D ethoc_stop;
> > > +	netdev->do_ioctl =3D ethoc_ioctl;
> > > +	netdev->set_config =3D ethoc_config;
> > > +	netdev->set_mac_address =3D ethoc_set_mac_address;
> > > +	netdev->set_multicast_list =3D ethoc_set_multicast_list;
> > > +	netdev->change_mtu =3D ethoc_change_mtu;
> > > +	netdev->tx_timeout =3D ethoc_tx_timeout;
> > > +	netdev->get_stats =3D ethoc_stats;
> > > +	netdev->hard_start_xmit =3D ethoc_start_xmit;
> > > +	netdev->watchdog_timeo =3D ETHOC_TIMEOUT;
> > > +	netdev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HI=
GHDMA;
> >
> > Please use netdev_ops.
>
> Done.
>
> > > +#ifndef LINUX_NET_ETHOC_H
> > > +#define LINUX_NET_ETHOC_H 1
> > > +
> > > +struct ethoc_platform_data {
> > > +	u8 hwaddr[IFHWADDRLEN];
> > > +	s8 phy_id;
> >
> > What about allowing platform configuration of the RX/TX buffers siz=
e and
> > number of them ?
>
> I think this is a good idea, but I'm not quite sure about how this sh=
ould
> be implemented. The total number of buffers is dependent on the total
> buffer size as defined by the second IORESOURCE_MEM resource. That re=
ally
> only leaves the option for allowing the individual buffer size to be
> defined by the platform configuration. Furthermore the network contro=
ller
> can only handle fixed-sized buffers (at least for reception), so perh=
aps
> defining some kind of RX/TX buffer number ratio would be useful. Or p=
erhaps
> defining a minimum or maximum number of TX buffers and leaving the re=
st up
> for RX for instance.

I like the idea of defining ratios but for now let's just stick to what=
 you=20
proposed and we can later agree on getting more parameters being passed=
 to=20
the driver using platform_data I am not sure yet how I will tune these=20
parameters on my design.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
