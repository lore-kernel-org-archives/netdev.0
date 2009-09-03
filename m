From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 1/2] fec: fix recursive locking of mii_lock
Date: Thu, 03 Sep 2009 11:16:16 +1000
Message-ID: <4A9F18E0.3060307@snapgear.com>
References: <20090831132200.GA21836@pengutronix.de> <1251882856-23549-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rt-users@vger.kernel.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Patrick McHardy <kaber@trash.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Matt Waddel <Matt.Waddel@freescale.com>,
	netdev@vger.kernel.org,
	Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:50528 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753987AbZICBQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 21:16:49 -0400
In-Reply-To: <1251882856-23549-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

Uwe Kleine-K=C3=B6nig wrote:
> mii_discover_phy is only called by fec_enet_mii (via mip->mii_func). =
 So
> &fep->mii_lock is already held and mii_discover_phy must not call
> mii_queue which locks &fep->mii_lock, too.
>=20
> This was noticed by lockdep:
>=20
> 	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> 	[ INFO: possible recursive locking detected ]
> 	2.6.31-rc8-00038-g37d0892 #109
> 	---------------------------------------------
> 	swapper/1 is trying to acquire lock:
> 	 (&fep->mii_lock){-.....}, at: [<c01569f8>] mii_queue+0x2c/0xcc
>=20
> 	but task is already holding lock:
> 	 (&fep->mii_lock){-.....}, at: [<c0156328>] fec_enet_interrupt+0x78/=
0x460
>=20
> 	other info that might help us debug this:
> 	2 locks held by swapper/1:
> 	 #0:  (rtnl_mutex){+.+.+.}, at: [<c0183534>] rtnl_lock+0x18/0x20
> 	 #1:  (&fep->mii_lock){-.....}, at: [<c0156328>] fec_enet_interrupt+=
0x78/0x460
>=20
> 	stack backtrace:
> 	Backtrace:
> 	[<c00226fc>] (dump_backtrace+0x0/0x108) from [<c01eac14>] (dump_stac=
k+0x18/0x1c)
> 	 r6:c781d118 r5:c03e41d8 r4:00000001
> 	[<c01eabfc>] (dump_stack+0x0/0x1c) from [<c005bae4>] (__lock_acquire=
+0x1a20/0x1a88)
> 	[<c005a0c4>] (__lock_acquire+0x0/0x1a88) from [<c005bbac>] (lock_acq=
uire+0x60/0x74)
> 	[<c005bb4c>] (lock_acquire+0x0/0x74) from [<c01edda8>] (_spin_lock_i=
rqsave+0x54/0x68)
> 	 r7:60000093 r6:c01569f8 r5:c785e468 r4:00000000
> 	[<c01edd54>] (_spin_lock_irqsave+0x0/0x68) from [<c01569f8>] (mii_qu=
eue+0x2c/0xcc)
> 	 r7:c785e468 r6:c0156b24 r5:600a0000 r4:c785e000
> 	[<c01569cc>] (mii_queue+0x0/0xcc) from [<c0156b78>] (mii_discover_ph=
y+0x54/0xa8)
> 	 r8:00000002 r7:00000032 r6:c785e000 r5:c785e360 r4:c785e000
> 	[<c0156b24>] (mii_discover_phy+0x0/0xa8) from [<c0156354>] (fec_enet=
_interrupt+0xa4/0x460)
> 	 r5:c785e360 r4:c077a170
> 	[<c01562b0>] (fec_enet_interrupt+0x0/0x460) from [<c0066674>] (handl=
e_IRQ_event+0x48/0x120)
> 	[<c006662c>] (handle_IRQ_event+0x0/0x120) from [<c0068438>] (handle_=
level_irq+0x94/0x11c)
> 	...
>=20
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> Cc: Greg Ungerer <gerg@uclinux.org>

Looks good too.

Acked-by: Greg Ungerer <gerg@uclinux.org>


> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Sascha Hauer <s.hauer@pengutronix.de>
> Cc: Matt Waddel <Matt.Waddel@freescale.com>
> Cc: netdev@vger.kernel.org
> Cc: Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
> ---
>  drivers/net/fec.c |   22 +++++++++++++++++-----
>  1 files changed, 17 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index c9fd82d..ef82606 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -637,16 +637,15 @@ unlock:
>  }
> =20
>  static int
> -mii_queue(struct net_device *dev, int regval, void (*func)(uint, str=
uct net_device *))
> +mii_queue_unlocked(struct net_device *dev, int regval,
> +		void (*func)(uint, struct net_device *))
>  {
>  	struct fec_enet_private *fep;
> -	unsigned long	flags;
>  	mii_list_t	*mip;
>  	int		retval;
> =20
>  	/* Add PHY address to register command */
>  	fep =3D netdev_priv(dev);
> -	spin_lock_irqsave(&fep->mii_lock, flags);
> =20
>  	regval |=3D fep->phy_addr << 23;
>  	retval =3D 0;
> @@ -667,6 +666,19 @@ mii_queue(struct net_device *dev, int regval, vo=
id (*func)(uint, struct net_devi
>  		retval =3D 1;
>  	}
> =20
> +	return retval;
> +}
> +
> +static int
> +mii_queue(struct net_device *dev, int regval,
> +		void (*func)(uint, struct net_device *))
> +{
> +	struct fec_enet_private *fep;
> +	unsigned long   flags;
> +	int             retval;
> +	fep =3D netdev_priv(dev);
> +	spin_lock_irqsave(&fep->mii_lock, flags);
> +	retval =3D mii_queue_unlocked(dev, regval, func);
>  	spin_unlock_irqrestore(&fep->mii_lock, flags);
>  	return retval;
>  }
> @@ -1373,11 +1385,11 @@ mii_discover_phy(uint mii_reg, struct net_dev=
ice *dev)
> =20
>  			/* Got first part of ID, now get remainder */
>  			fep->phy_id =3D phytype << 16;
> -			mii_queue(dev, mk_mii_read(MII_REG_PHYIR2),
> +			mii_queue_unlocked(dev, mk_mii_read(MII_REG_PHYIR2),
>  							mii_discover_phy3);
>  		} else {
>  			fep->phy_addr++;
> -			mii_queue(dev, mk_mii_read(MII_REG_PHYIR1),
> +			mii_queue_unlocked(dev, mk_mii_read(MII_REG_PHYIR1),
>  							mii_discover_phy);
>  		}
>  	} else {

--=20
-----------------------------------------------------------------------=
-
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.co=
m
SnapGear Group, McAfee                      PHONE:       +61 7 3435 288=
8
825 Stanley St,                             FAX:         +61 7 3891 363=
0
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.co=
m
