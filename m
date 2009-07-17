From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2 v5] fs_enet/mii-fec.c: fix MII speed calculation
Date: Fri, 17 Jul 2009 08:41:08 -0600
Message-ID: <fa686aa40907170741n121d3e4cqdfddaf4d23d4d1fc@mail.gmail.com>
References: <1247780546-4426-1-git-send-email-wd@denx.de> <1247833628-15952-1-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:59150 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbZGQOla convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 10:41:30 -0400
Received: by rv-out-0506.google.com with SMTP id k40so314311rvb.5
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 07:41:28 -0700 (PDT)
In-Reply-To: <1247833628-15952-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 6:27 AM, Wolfgang Denk<wd@denx.de> wrote:
> The MII speed calculation was based on the CPU clock (ppc_proc_freq),
> but for MPC512x we must use the bus clock instead.
>
> This patch makes it use the correct clock and makes sure we don't
> clobber reserved bits in the MII_SPEED register.
>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

David, this isn't a critical bug fix or a regression, so I think it
should be merged for -next.

g.

> ---
> v5: - fix divider so we really use 2.5 MHz (instead of 1.25)
> =A0 =A0- use maximum divider in case MPC512x IPS clock is unknown
>
> =A0drivers/net/fs_enet/mii-fec.c | =A0 37 +++++++++++++++++++++++++++=
++++++----
> =A01 files changed, 33 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-=
fec.c
> index 75a0999..5176986 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -36,6 +36,7 @@
> =A0#include <asm/pgtable.h>
> =A0#include <asm/irq.h>
> =A0#include <asm/uaccess.h>
> +#include <asm/mpc5xxx.h>
>
> =A0#include "fs_enet.h"
> =A0#include "fec.h"
> @@ -103,11 +104,11 @@ static int fs_enet_fec_mii_reset(struct mii_bus=
 *bus)
> =A0static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 const struct of_device_id *match)
> =A0{
> - =A0 =A0 =A0 struct device_node *np =3D NULL;
> =A0 =A0 =A0 =A0struct resource res;
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct fec_info *fec;
> - =A0 =A0 =A0 int ret =3D -ENOMEM, i;
> + =A0 =A0 =A0 int (*get_bus_freq)(struct device_node *) =3D match->da=
ta;
> + =A0 =A0 =A0 int ret =3D -ENOMEM, clock, speed;
>
> =A0 =A0 =A0 =A0new_bus =3D mdiobus_alloc();
> =A0 =A0 =A0 =A0if (!new_bus)
> @@ -133,13 +134,35 @@ static int __devinit fs_enet_mdio_probe(struct =
of_device *ofdev,
> =A0 =A0 =A0 =A0if (!fec->fecp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_fec;
>
> - =A0 =A0 =A0 fec->mii_speed =3D ((ppc_proc_freq + 4999999) / 5000000=
) << 1;
> + =A0 =A0 =A0 if (get_bus_freq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D get_bus_freq(ofdev->node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Use maximum divider =
if clock is unknown */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(&ofdev->dev, "=
could not determine IPS clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D 0x3F * 500000=
0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock =3D ppc_proc_freq;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Scale for a MII clock <=3D 2.5 MHz
> + =A0 =A0 =A0 =A0* Note that only 6 bits (25:30) are available for MI=
I speed.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 speed =3D (clock + 4999999) / 5000000;
> + =A0 =A0 =A0 if (speed > 0x3F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 speed =3D 0x3F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ofdev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MII clock (%d Hz) exce=
eds max (2.5 MHz)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock / speed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 fec->mii_speed =3D speed << 1;
>
> =A0 =A0 =A0 =A0setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE=
);
> =A0 =A0 =A0 =A0setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0FEC_ECNTRL_ETHER_EN);
> =A0 =A0 =A0 =A0out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
> - =A0 =A0 =A0 out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
> + =A0 =A0 =A0 clrsetbits_be32(&fec->fecp->fec_mii_speed, 0x7E, fec->m=
ii_speed);
>
> =A0 =A0 =A0 =A0new_bus->phy_mask =3D ~0;
> =A0 =A0 =A0 =A0new_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, G=
=46P_KERNEL);
> @@ -188,6 +211,12 @@ static struct of_device_id fs_enet_mdio_fec_matc=
h[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.compatible =3D "fsl,pq1-fec-mdio",
> =A0 =A0 =A0 =A0},
> +#if defined(CONFIG_PPC_MPC512x)
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .compatible =3D "fsl,mpc5121-fec-mdio",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =3D mpc5xxx_get_bus_frequency,
> + =A0 =A0 =A0 },
> +#endif
> =A0 =A0 =A0 =A0{},
> =A0};
>
> --
> 1.6.0.6
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
