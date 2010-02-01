From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 3/4] ucc_geth: update the tbi-phy setting
Date: Mon, 1 Feb 2010 15:00:21 -0700
Message-ID: <fa686aa41002011400i7160f360offc5b788e82122ea@mail.gmail.com>
References: <1263456799-3306-1-git-send-email-yu.liu@freescale.com>
	<1263456799-3306-2-git-send-email-yu.liu@freescale.com> <1263456799-3306-3-git-send-email-yu.liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: galak@kernel.crashing.org, davem@davemloft.net,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Liu Yu <yu.liu@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f189.google.com ([209.85.210.189]:52857 "EHLO
	mail-yx0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab0BAWAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 17:00:42 -0500
Received: by yxe27 with SMTP id 27so665861yxe.4
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2010 14:00:41 -0800 (PST)
In-Reply-To: <1263456799-3306-3-git-send-email-yu.liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 14, 2010 at 1:13 AM, Liu Yu <yu.liu@freescale.com> wrote:
> Old method only set tbi-phy for eth0.
>
> Signed-off-by: Liu Yu <yu.liu@freescale.com>
> ---
> =A0drivers/net/ucc_geth.c | =A0 23 +++++++++++++++--------
> =A01 files changed, 15 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 750d86d..0e72013 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -37,6 +37,7 @@
> =A0#include <asm/qe.h>
> =A0#include <asm/ucc.h>
> =A0#include <asm/ucc_fast.h>
> +#include <asm/machdep.h>
>
> =A0#include "ucc_geth.h"
> =A0#include "fsl_pq_mdio.h"
> @@ -1334,7 +1335,7 @@ static int adjust_enet_interface(struct ucc_get=
h_private *ugeth)
> =A0 =A0 =A0 =A0struct ucc_geth __iomem *ug_regs;
> =A0 =A0 =A0 =A0struct ucc_fast __iomem *uf_regs;
> =A0 =A0 =A0 =A0int ret_val;
> - =A0 =A0 =A0 u32 upsmr, maccfg2, tbiBaseAddress;
> + =A0 =A0 =A0 u32 upsmr, maccfg2;
> =A0 =A0 =A0 =A0u16 value;
>
> =A0 =A0 =A0 =A0ugeth_vdbg("%s: IN", __func__);
> @@ -1389,14 +1390,20 @@ static int adjust_enet_interface(struct ucc_g=
eth_private *ugeth)
> =A0 =A0 =A0 =A0/* Note that this depends on proper setting in utbipar=
 register. */
> =A0 =A0 =A0 =A0if ((ugeth->phy_interface =3D=3D PHY_INTERFACE_MODE_TB=
I) ||
> =A0 =A0 =A0 =A0 =A0 =A0(ugeth->phy_interface =3D=3D PHY_INTERFACE_MOD=
E_RTBI)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tbiBaseAddress =3D in_be32(&ug_regs->ut=
bipar);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tbiBaseAddress &=3D UTBIPAR_PHY_ADDRESS=
_MASK;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tbiBaseAddress >>=3D UTBIPAR_PHY_ADDRES=
S_SHIFT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 value =3D ugeth->phydev->bus->read(uget=
h->phydev->bus,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u8) tb=
iBaseAddress, ENET_TBI_MII_CR);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ucc_geth_info *ug_info =3D ugeth=
->ug_info;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct phy_device *tbiphy;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ug_info->tbi_node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ugeth_warn("TBI mode re=
quires that the device "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "tree s=
pecify a tbi-handle\n");

Shouldn't the driver avoid calling of_phy_find_device() if this error
path is taken?

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tbiphy =3D of_phy_find_device(ug_info->=
tbi_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tbiphy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ugeth_warn("Could not g=
et TBI device\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 value =3D phy_read(tbiphy, ENET_TBI_MII=
_CR);

Ditto here; the code unconditionally tries to read the tbiphy, even if
it isn't there.

Looks wrong.

g.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0value &=3D ~0x1000; =A0 =A0 =A0 /* Tur=
n off autonegotiation */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ugeth->phydev->bus->write(ugeth->phydev=
->bus,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u8) tb=
iBaseAddress, ENET_TBI_MII_CR, value);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_write(tbiphy, ENET_TBI_MII_CR, valu=
e);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0init_check_frame_length_mode(ug_info->lengthCheckRx, &=
ug_regs->maccfg2);
> --
> 1.6.4
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
