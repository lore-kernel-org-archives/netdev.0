From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: Re: [PATCHv2] tun: fix carrier on/off status
Date: Mon, 28 Jan 2013 20:38:38 +0100
Message-ID: <5106D3BE.3030401@gmx.de>
References: <5103B01D.5070303@gmx.de> <3592886.xagLc7Uij9@jason-thinkpad-t430s> <20130128101111.GB5337@redhat.com> <20130128103801.GA6648@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63228 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166Ab3A1TsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 14:48:23 -0500
Received: from mailout-de.gmx.net ([10.1.76.10]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0LpAT4-1UcFiU0W8a-00eqxE for
 <netdev@vger.kernel.org>; Mon, 28 Jan 2013 20:48:22 +0100
In-Reply-To: <20130128103801.GA6648@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Toralf F=C3=B6rster <toralf.foerster@gmx.de>

On 01/28/2013 11:38 AM, Michael S. Tsirkin wrote:
> Commit c8d68e6be1c3b242f1c598595830890b65cea64a removed carrier off c=
all
> from tun_detach since it's now called on queue disable and not only o=
n
> tun close.  This confuses userspace which used this flag to detect a
> free tun. To fix, put this back but under if (clean).
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>=20
> ---
>=20
> Changes from v1:
> 	Don't set carrier off unless all queues are closed.
>=20
> Note: didn't test in MQ mode - Jason, care checking this does the
> right thing there?
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index af372d0..06b2723 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -434,10 +434,13 @@ static void __tun_detach(struct tun_file *tfile=
, bool clean)
>  	}
> =20
>  	if (clean) {
> -		if (tun && tun->numqueues =3D=3D 0 && tun->numdisabled =3D=3D 0 &&
> -		    !(tun->flags & TUN_PERSIST))
> -			if (tun->dev->reg_state =3D=3D NETREG_REGISTERED)
> +		if (tun && tun->numqueues =3D=3D 0 && tun->numdisabled =3D=3D 0) {
> +			netif_carrier_off(tun->dev);
> +
> +			if (!(tun->flags & TUN_PERSIST) &&
> +			    tun->dev->reg_state =3D=3D NETREG_REGISTERED)
>  				unregister_netdevice(tun->dev);
> +		}
> =20
>  		BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
>  				 &tfile->socket.flags));
> @@ -1644,10 +1647,10 @@ static int tun_set_iff(struct net *net, struc=
t file *file, struct ifreq *ifr)
>  		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
>  		    device_create_file(&tun->dev->dev, &dev_attr_group))
>  			pr_err("Failed to create tun sysfs files\n");
> -
> -		netif_carrier_on(tun->dev);
>  	}
> =20
> +	netif_carrier_on(tun->dev);
> +
>  	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
> =20
>  	if (ifr->ifr_flags & IFF_NO_PI)
>=20


--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
