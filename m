From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 1/1] ethernet driver: dm9000: davicom: Upgrade the
 driver to suit for all DM9000 series chips
Date: Mon, 25 Mar 2013 14:08:35 -0600
Message-ID: <20130325140835.115bf6ab@lwn.net>
References: <1364198682-1589-1-git-send-email-josright123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Matthew Leach <matthew@mattleach.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joseph CHANG <joseph_chang@davicom.com.tw>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joseph CHANG <josright123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tex.lwn.net ([70.33.254.29]:41389 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758299Ab3CYUgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 16:36:45 -0400
In-Reply-To: <1364198682-1589-1-git-send-email-josright123@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Mar 2013 16:04:42 +0800
Joseph CHANG <josright123@gmail.com> wrote:

> From: Joseph CHANG <joseph_chang@davicom.com.tw>
>=20
> Some necessary modification for DM9000 series chips to be better in o=
peration!

Interesting, this had been sent to me privately at about the same time.
=46or the record, here's what I sent back:

=46rom: Jonathan Corbet <corbet@lwn.net>
To: Allen Huang (=E9=BB=83=E5=81=89=E6=A0=BC) <allen_huang@davicom.com.=
tw>
Subject: Re: Davicom Linux driver
Date: Mon, 25 Mar 2013 09:55:48 -0600
Organization: LWN.net

On Mon, 25 Mar 2013 18:31:35 +0800
Allen Huang (=E9=BB=83=E5=81=89=E6=A0=BC) <allen_huang@davicom.com.tw> =
wrote:

> Please see our Linux Patch in the attachment and we would appreciate =
any
> comments that you have on our driver and/or whether it is ready to go=
 into
> the kernel. Thanks.  =20

I'll take a quick look at it.  But the only true way to know whether it=
's
ready, of course, is to post it to the public lists.

> Some necessary modification for DM9000 series chips to be better in o=
peration! =20

The patch will be better received if you say what "better in operation"
actually means.  Are you supporting new hardware, adding new features,
fixing bugs?  Hopefully not more than one of those in a single patch.

> Had tested to all of DM9000 series chips, include DM9000E, DM9000A, D=
M9000B,
> and DM9000C in X86 and ARM embedded Linux system these years.
>=20
> Signed-off-by: Joseph CHANG <joseph_chang@davicom.com.tw>
> ---
>  drivers/net/ethernet/davicom/dm9000.c |   28 +++++++++++++++++++++++=
-----
>  drivers/net/ethernet/davicom/dm9000.h |    4 +++-
>  2 files changed, 26 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethe=
rnet/davicom/dm9000.c
> index 8cdf025..54bdc92 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
> @@ -47,7 +47,8 @@
>  #define DM9000_PHY		0x40	/* PHY address 0x01 */
> =20
>  #define CARDNAME	"dm9000"
> -#define DRV_VERSION	"1.31"
> +/* [KERN-ADD-1](upgrade) */ =20

I would lose the [KERN-ADD*] comments, those will certainly draw some
grumbling when the patch is posted publicly.  They don't add any value;=
 the
repository will show which changes were made when.

> +#define DRV_VERSION	"1.39"
> =20
>  /*
>   * Transmit timeout, default 5 seconds.
> @@ -671,10 +672,16 @@ dm9000_poll_work(struct work_struct *w)
>  			if (netif_msg_link(db))
>  				dm9000_show_carrier(db, new_carrier, nsr);
> =20
> -			if (!new_carrier)
> +			/* [KERN-ADD-2] */
> +			if (!new_carrier) {
>  				netif_carrier_off(ndev);
> -			else
> +				netdev_info(ndev, "[%s Ethernet Driver, V%s]: Link-Down!!\n",
> +					CARDNAME, DRV_VERSION);
> +			} else {
>  				netif_carrier_on(ndev);
> +				netdev_info(ndev, "[%s Ethernet Driver, V%s]: Link-Up!!\n",
> +					CARDNAME, DRV_VERSION);
> +			} =20

So "better in operation" means more log messages?  This, too, will like=
ly
draw complaints.  That could be a lot of log messages!  The additional
information is also probably unnecessary, netdev_info() should print th=
e
relevant device information.

>  		}
>  	} else
>  		mii_check_media(&db->mii, netif_msg_link(db), 0);
> @@ -794,6 +801,9 @@ dm9000_init_dm9000(struct net_device *dev)
>  			(dev->features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
> =20
>  	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
> +    /* [KERN-ADD-3] */
> +	dm9000_phy_write(dev, 0, 0, 0x8000); /* reset PHY */
> +	mdelay(2); =20

Magic constants aren't good, you can't define a symbol for that?

dm900_poll_work() is a workqueue function, right?  So it can sleep.  So=
 you
should almost certainly use msleep() rather than mdelay().

>  	ncr =3D (db->flags & DM9000_PLATF_EXT_PHY) ? NCR_EXT_PHY : 0;
> =20
> @@ -830,6 +840,8 @@ dm9000_init_dm9000(struct net_device *dev)
>  	db->tx_pkt_cnt =3D 0;
>  	db->queue_pkt_len =3D 0;
>  	dev->trans_start =3D jiffies;
> +    /* [KERN-ADD-4]	*/
> +	dm9000_phy_write(dev, 0, 27, 0xE100); =20

Again, can we avoid the magic constants?

>  }
> =20
>  /* Our watchdog timed out. Called by the networking layer */
> @@ -1181,7 +1193,8 @@ dm9000_open(struct net_device *dev)
> =20
>  	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
>  	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
> -	mdelay(1); /* delay needs by DM9000B */
> +	/* [KERN-ADD-5](Enable PHY) */
> +	mdelay(2); /* delay needs by DM9000B */ =20

You say "Enable PHY" but I see no change that does that?
Again, msleep() would be better here - an open function can certainly
sleep!=20

>  	/* Initialize DM9000 board */
>  	dm9000_reset(db);
> @@ -1311,6 +1324,8 @@ dm9000_shutdown(struct net_device *dev)
> =20
>  	/* RESET device */
>  	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
> +    /* [KERN-ADD-6](NOTICE)(by)("if (!db->wake_state) ..") */
> +    /* iow(db, DM9000_GPR, 0x01); */
>  	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */ =20

What is the purpose of this change?

>  	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
>  	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
> @@ -1465,6 +1480,8 @@ dm9000_probe(struct platform_device *pdev)
>  	/* fill in parameters for net-dev structure */
>  	ndev->base_addr =3D (unsigned long)db->io_addr;
>  	ndev->irq	=3D db->irq_res->start;
> +    /* [KERN-ADD-7] */
> +	netdev_info(ndev, "[dm9] %s ndev->irq=3D%x\n", __func__, ndev->irq)=
; =20

That should be unnecessary; that information is available in
/proc/interrupts, and probably via ethtool too.

>  	/* ensure at least we have a default set of IO routines */
>  	dm9000_set_io(db, iosize);
> @@ -1502,7 +1519,8 @@ dm9000_probe(struct platform_device *pdev)
>  	db->flags |=3D DM9000_PLATF_SIMPLE_PHY;
>  #endif
> =20
> -	dm9000_reset(db);
> +    /* [KERN-ADD-8](SPECIAL WHEN INIT_OF_PROBE)[takeover"dm9000_rese=
t(db)"] */
> +	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST); /* 0x03 */ =20

What is accomplished by this change?  Should it maybe be a parameter to
dm9000_reset()?

>  	/* try multiple times, DM9000 sometimes gets the read wrong */
>  	for (i =3D 0; i < 8; i++) {
> diff --git a/drivers/net/ethernet/davicom/dm9000.h b/drivers/net/ethe=
rnet/davicom/dm9000.h
> index 55688bd..d644506 100644
> --- a/drivers/net/ethernet/davicom/dm9000.h
> +++ b/drivers/net/ethernet/davicom/dm9000.h
> @@ -69,7 +69,9 @@
>  #define NCR_WAKEEN          (1<<6)
>  #define NCR_FCOL            (1<<4)
>  #define NCR_FDX             (1<<3)
> -#define NCR_LBK             (3<<1)
> +
> +#define NCR_RESERVED        (3<<1)
> +#define NCR_MAC_LBK         (1<<1) /* [kern-add-0] */
>  #define NCR_RST	            (1<<0)
> =20
>  #define NSR_SPEED           (1<<7)
> --=20
> 1.7.1
>  =20
Hope that helps,

jon
