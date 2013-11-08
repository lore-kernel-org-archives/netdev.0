From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: add Renesas R-Car CAN driver
Date: Fri, 08 Nov 2013 10:17:44 +0100
Message-ID: <527CAC38.6040800@pengutronix.de>
References: <201311020240.13354.sergei.shtylyov@cogentembedded.com> <5276ADF6.9050309@pengutronix.de> <527C28DE.7070402@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="R5I5adSUoMHecnfQm97EuTB7OU45m6NTT"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <527C28DE.7070402@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--R5I5adSUoMHecnfQm97EuTB7OU45m6NTT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/08/2013 12:57 AM, Sergei Shtylyov wrote:
>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- /dev/null
>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>> @@ -0,0 +1,893 @@
>>> +/*
>>> + * Renesas R-Car CAN device driver
>>> + *
>>> + * Copyright (C) 2013 Cogent Embedded, Inc. <source@cogentembedded.c=
om>
>>> + * Copyright (C) 2013 Renesas Solutions Corp.
>>> + *
>>> + * This program is free software; you can redistribute  it and/or
>>> modify it
>>> + * under  the terms of  the GNU General  Public License as published=

>>> by the
>>> + * Free Software Foundation;  either version 2 of the  License, or
>>> (at your
>>> + * option) any later version.
>>> + */
>>> +
>>> +#include <linux/module.h>
>>> +#include <linux/kernel.h>
>>> +#include <linux/types.h>
>>> +#include <linux/interrupt.h>
>>> +#include <linux/errno.h>
>>> +#include <linux/netdevice.h>
>>> +#include <linux/platform_device.h>
>>> +#include <linux/can/led.h>
>>> +#include <linux/can/dev.h>
>>> +#include <linux/clk.h>
>>> +#include <linux/can/platform/rcar_can.h>
>>> +
>>> +#define DRV_NAME    "rcar_can"
>>> +
>>> +/* Mailbox configuration:
>>> + * mailbox 0 - not used
>>> + * mailbox 1-31 - Rx
>>> + * mailbox 32-63 - Tx
>>> + * no FIFO mailboxes
>>> + */
>>> +#define N_MBX        64
>>> +#define FIRST_TX_MB    32
>>> +#define N_TX_MB        (N_MBX - FIRST_TX_MB)
>>> +#define RX_MBX_MASK    0xFFFFFFFE
>=20
>> Please use a common prefix for all defines.
>=20
>    OK, done now. Could you however explain why the file-local #define's=

> should be prefixed? It's not quite obvious to me...

It's about readability and maintainability. If you don't know the
driver, but all driver local defines and functions have a common prefix,
it's much easier to read if you are not the author of the driver IMHO.

>=20
> [...]
>>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>>> +                       struct net_device *ndev)
>>> +{
>>> +    struct rcar_can_priv *priv =3D netdev_priv(ndev);
>>> +    struct can_frame *cf =3D (struct can_frame *)skb->data;
>>> +    u32 data, mier1, mbxno, i;
>>> +    unsigned long flags;
>>> +    u8 mctl =3D 0;
>>> +
>>> +    if (can_dropped_invalid_skb(ndev, skb))
>>> +        return NETDEV_TX_OK;
>>> +
>>> +    spin_lock_irqsave(&priv->mier_lock, flags);
>>> +    mier1 =3D readl(&priv->regs->mier1);
>>> +    if (mier1) {
>>> +        i =3D __builtin_clz(mier1);
>>> +        mbxno =3D i ? N_MBX - i : FIRST_TX_MB;
>>> +    } else {
>>> +        mbxno =3D FIRST_TX_MB;
>>> +    }
>=20
>> Can you explain how the hardware arbitration works, and you do you
>> guarantee the CAN frames are send by the hardware in the same order yo=
u
>> put them into the hardware.
>=20
>    Tx mailbox with the smallest mailbox number has the highest priority=
=2E
> The other possible Tx mailbox selection rule (not used by the driver
> now) is ID priority transmit mode (as defined in the ISO 11898-1 specs)=
=2E
> The algorithm used guarantees the mailboxes are filled sequentially.

I see. You are using mier1 to track the used mailboxes....correct?

> +	if (unlikely(mier1 =3D=3D 0xffffffff))
> +		netif_stop_queue(ndev);

Then you have a race condition in your tx-complete handler
rcar_can_tx_done(), as you call netif_wake_queue() unconditionally. If
mier1 =3D=3D 0xffffffff you must wait until _all_ mailboxes are transmitt=
ed
until you are allowed to reenable the mailboxes. Have a look at the
at91_can driver, it's using a similar scheme. The lowest mailbox is
transmitted first, but there are three additional bits that indicate the
priority.

> I've used 'canfdtest' as suggested by Wolfgang Grandegger to verify, se=
e
> the log below:
>=20
> root@am335x-evm:~# ./canfdtest -v -g can0
> interface =3D can0, family =3D 29, type =3D 3, proto =3D 1
> .......................................................................=
=2E.......C
>=20
> Test messages sent and received: 483203
> Exiting...
> root@am335x-evm:~#
>=20
> [...]
>>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>>> +{
>>> +    struct rcar_can_priv *priv =3D container_of(napi,
>>> +                          struct rcar_can_priv, napi);
>>> +    int num_pkts =3D 0;
>>> +
>>> +    /* Find mailbox */
>>> +    while (num_pkts < quota) {
>>> +        u8 mctl, mbx;
>>> +
>>> +        mbx =3D readb(&priv->regs->mssr);
>=20
>> How does the RX work? Is it a hardware FIFO?
>=20
>    In short, the MSSR register provides the smallest Rx mailbox number
> that is looked up in the Rx search mode. We read MSSR until no search
> results can be obtained, so it is some sort of FIFO.

This looks racy....

>    And there is separate FIFO operation mode: some mailboxes can be
> configured as FIFO and serviced by special registers but this operation=

> mode is not supported by the driver.

if you hardware supports a real FIFO then I strongly suggest to make use
of it.

> [...]
>>> +static int rcar_can_probe(struct platform_device *pdev)
>>> +{
>>> +    struct rcar_can_platform_data *pdata;
>>> +    struct rcar_can_priv *priv;
>>> +    struct net_device *ndev;
>>> +    struct resource *mem;
>>> +    void __iomem *addr;
>>> +    int err =3D -ENODEV;
>>> +    int irq;
>>> +
>>> +    pdata =3D dev_get_platdata(&pdev->dev);
>>> +    if (!pdata) {
>>> +        dev_err(&pdev->dev, "No platform data provided!\n");
>>> +        goto fail;
>>> +    }
>>> +
>>> +    irq =3D platform_get_irq(pdev, 0);
>>> +    if (!irq) {
>>> +        dev_err(&pdev->dev, "No IRQ resource\n");
>>> +        goto fail;
>>> +    }
>>> +
>>> +    mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>> +    addr =3D devm_ioremap_resource(&pdev->dev, mem);
>>> +    if (IS_ERR(addr)) {
>>> +        err =3D PTR_ERR(addr);
>>> +        goto fail;
>>> +    }
>>> +
>>> +    ndev =3D alloc_candev(sizeof(struct rcar_can_priv), N_MBX -
>>> FIRST_TX_MB);
>>> +    if (!ndev) {
>>> +        dev_err(&pdev->dev, "alloc_candev failed\n");
>>> +        err =3D -ENOMEM;
>>> +        goto fail;
>>> +    }
>>> +
>>> +    priv =3D netdev_priv(ndev);
>>> +
>>> +    priv->clk =3D devm_clk_get(&pdev->dev, NULL);
>>> +    if (IS_ERR(priv->clk)) {
>>> +        err =3D PTR_ERR(priv->clk);
>>> +        dev_err(&pdev->dev, "cannot get clock: %d\n", err);
>>> +        goto fail_clk;
>>> +    }
>>> +
>>> +    ndev->netdev_ops =3D &rcar_can_netdev_ops;
>>> +    ndev->irq =3D irq;
>>> +    ndev->flags |=3D IFF_ECHO;
>>> +    priv->ndev =3D ndev;
>>> +    priv->regs =3D addr;
>>> +    priv->clock_select =3D pdata->clock_select;
>>> +    priv->can.clock.freq =3D clk_get_rate(priv->clk);
>>> +    priv->can.bittiming_const =3D &rcar_can_bittiming_const;
>>> +    priv->can.do_set_bittiming =3D rcar_can_set_bittiming;
>=20
>> Please call this function directly during the open() function.
>=20
>    OK, done, and the method installation was removed. However, I'm not
> sure why you requested this as many drivers are still using the method.=


The callback was there from the beginning, but then we figured out that
we don't need it in the driver, but no one has cleaned up the drivers
yet. So don't use it in new drivers. I know it's not documented anywhere =
:(

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--R5I5adSUoMHecnfQm97EuTB7OU45m6NTT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJ8rDgACgkQjTAFq1RaXHN2VgCggazCnpSzAW/8oE6PfPdFDNgC
N/sAn1CuaeubetDV8JV/pTIiKaUSkp2+
=sUOs
-----END PGP SIGNATURE-----

--R5I5adSUoMHecnfQm97EuTB7OU45m6NTT--
