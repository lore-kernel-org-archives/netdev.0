From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 2/3] net: ibm_newemac: convert it to use of_get_phy_mode
Date: Tue, 5 Jul 2011 11:38:46 -0600
Message-ID: <CACxGe6vxTMHksJyHA+msJj9oKJ582-6akWv8Qt6V+HSubgy3Vg@mail.gmail.com>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org> <1309878839-25743-3-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, patches@linaro.org,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:53529 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab1GERjH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 13:39:07 -0400
Received: by ywe9 with SMTP id 9so2357471ywe.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 10:39:06 -0700 (PDT)
In-Reply-To: <1309878839-25743-3-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 9:13 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> The patch extends 'enum phy_interface_t' and of_get_phy_mode a little
> bit with PHY_INTERFACE_MODE_NA and PHY_INTERFACE_MODE_SMII added,
> and then converts ibm_newemac net driver to use of_get_phy_mode
> getting phy mode from device tree.
>
> It also resolves the namespace conflict on phy_read/write between
> common mdiobus interface and ibm_newemac private one.
>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Grant Likely <grant.likely@secretlab.ca>

I'm okay with this, but I'm don't know if it is a good idea to add the
new PHY_INTERFACE_MODE defines (but I cannot think of a reason why
not).  I'll let someone else comment on that.

Acked-by: Grant Likely <grant.likely@secretlab.ca>


> ---
> =A0drivers/net/ibm_newemac/core.c | =A0 33 ++++----------------------=
-------
> =A0drivers/net/ibm_newemac/emac.h | =A0 19 ++++++++++---------
> =A0drivers/net/ibm_newemac/phy.c =A0| =A0 =A07 +++++--
> =A0drivers/of/of_net.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++
> =A0include/linux/phy.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +++-
> =A05 files changed, 24 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac=
/core.c
> index 725399e..70cb7d8 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -39,6 +39,7 @@
> =A0#include <linux/bitops.h>
> =A0#include <linux/workqueue.h>
> =A0#include <linux/of.h>
> +#include <linux/of_net.h>
> =A0#include <linux/slab.h>
>
> =A0#include <asm/processor.h>
> @@ -2506,18 +2507,6 @@ static int __devinit emac_init_config(struct e=
mac_instance *dev)
> =A0{
> =A0 =A0 =A0 =A0struct device_node *np =3D dev->ofdev->dev.of_node;
> =A0 =A0 =A0 =A0const void *p;
> - =A0 =A0 =A0 unsigned int plen;
> - =A0 =A0 =A0 const char *pm, *phy_modes[] =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_NA] =3D "",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_MII] =3D "mii",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_RMII] =3D "rmii",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_SMII] =3D "smii",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_RGMII] =3D "rgmii",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_TBI] =3D "tbi",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_GMII] =3D "gmii",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_RTBI] =3D "rtbi",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PHY_MODE_SGMII] =3D "sgmii",
> - =A0 =A0 =A0 };
>
> =A0 =A0 =A0 =A0/* Read config from device-tree */
> =A0 =A0 =A0 =A0if (emac_read_uint_prop(np, "mal-device", &dev->mal_ph=
, 1))
> @@ -2566,23 +2555,9 @@ static int __devinit emac_init_config(struct e=
mac_instance *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->mal_burst_size =3D 256;
>
> =A0 =A0 =A0 =A0/* PHY mode needs some decoding */
> - =A0 =A0 =A0 dev->phy_mode =3D PHY_MODE_NA;
> - =A0 =A0 =A0 pm =3D of_get_property(np, "phy-mode", &plen);
> - =A0 =A0 =A0 if (pm !=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int i;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(phy_modes)=
; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcasecmp(pm, phy=
_modes[i])) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->ph=
y_mode =3D i;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* Backward compat with non-final DT */
> - =A0 =A0 =A0 if (dev->phy_mode =3D=3D PHY_MODE_NA && pm !=3D NULL &&=
 plen =3D=3D 4) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 nmode =3D *(const u32 *)pm;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nmode > PHY_MODE_NA && nmode <=3D P=
HY_MODE_SGMII)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->phy_mode =3D nmode=
;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 dev->phy_mode =3D of_get_phy_mode(np);
> + =A0 =A0 =A0 if (dev->phy_mode < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->phy_mode =3D PHY_MODE_NA;
>
> =A0 =A0 =A0 =A0/* Check EMAC version */
> =A0 =A0 =A0 =A0if (of_device_is_compatible(np, "ibm,emac4sync")) {
> diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ibm_newemac=
/emac.h
> index 8a61b597..1568278 100644
> --- a/drivers/net/ibm_newemac/emac.h
> +++ b/drivers/net/ibm_newemac/emac.h
> @@ -26,6 +26,7 @@
> =A0#define __IBM_NEWEMAC_H
>
> =A0#include <linux/types.h>
> +#include <linux/phy.h>
>
> =A0/* EMAC registers =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Write=
 Access rules */
> =A0struct emac_regs {
> @@ -106,15 +107,15 @@ struct emac_regs {
> =A0/*
> =A0* PHY mode settings (EMAC <-> ZMII/RGMII bridge <-> PHY)
> =A0*/
> -#define PHY_MODE_NA =A0 =A00
> -#define PHY_MODE_MII =A0 1
> -#define PHY_MODE_RMII =A02
> -#define PHY_MODE_SMII =A03
> -#define PHY_MODE_RGMII 4
> -#define PHY_MODE_TBI =A0 5
> -#define PHY_MODE_GMII =A06
> -#define PHY_MODE_RTBI =A07
> -#define PHY_MODE_SGMII 8
> +#define PHY_MODE_NA =A0 =A0PHY_INTERFACE_MODE_NA
> +#define PHY_MODE_MII =A0 PHY_INTERFACE_MODE_MII
> +#define PHY_MODE_RMII =A0PHY_INTERFACE_MODE_RMII
> +#define PHY_MODE_SMII =A0PHY_INTERFACE_MODE_SMII
> +#define PHY_MODE_RGMII PHY_INTERFACE_MODE_RGMII
> +#define PHY_MODE_TBI =A0 PHY_INTERFACE_MODE_TBI
> +#define PHY_MODE_GMII =A0PHY_INTERFACE_MODE_GMII
> +#define PHY_MODE_RTBI =A0PHY_INTERFACE_MODE_RTBI
> +#define PHY_MODE_SGMII PHY_INTERFACE_MODE_SGMII
>
> =A0/* EMACx_MR0 */
> =A0#define EMAC_MR0_RXI =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x8000000=
0
> diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/=
phy.c
> index ac9d964..ab4e596 100644
> --- a/drivers/net/ibm_newemac/phy.c
> +++ b/drivers/net/ibm_newemac/phy.c
> @@ -28,12 +28,15 @@
> =A0#include "emac.h"
> =A0#include "phy.h"
>
> -static inline int phy_read(struct mii_phy *phy, int reg)
> +#define phy_read _phy_read
> +#define phy_write _phy_write
> +
> +static inline int _phy_read(struct mii_phy *phy, int reg)
> =A0{
> =A0 =A0 =A0 =A0return phy->mdio_read(phy->dev, phy->address, reg);
> =A0}
>
> -static inline void phy_write(struct mii_phy *phy, int reg, int val)
> +static inline void _phy_write(struct mii_phy *phy, int reg, int val)
> =A0{
> =A0 =A0 =A0 =A0phy->mdio_write(phy->dev, phy->address, reg, val);
> =A0}
> diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
> index cc117db..bb18471 100644
> --- a/drivers/of/of_net.c
> +++ b/drivers/of/of_net.c
> @@ -16,6 +16,7 @@
> =A0* device driver can get phy interface from device tree.
> =A0*/
> =A0static const char *phy_modes[] =3D {
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_NA] =A0 =A0 =A0 =A0 =3D "",
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_MII] =A0 =A0 =A0 =A0=3D "mii",
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_GMII] =A0 =A0 =A0 =3D "gmii",
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_SGMII] =A0 =A0 =A0=3D "sgmii",
> @@ -26,6 +27,7 @@ static const char *phy_modes[] =3D {
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_RGMII_RXID] =3D "rgmii-rxid",
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_RGMII_TXID] =3D "rgmii-txid",
> =A0 =A0 =A0 =A0[PHY_INTERFACE_MODE_RTBI] =A0 =A0 =A0 =3D "rtbi",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_SMII] =A0 =A0 =A0 =3D "smii",
> =A0};
>
> =A0/**
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 7da5fa8..1622081 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -53,6 +53,7 @@
>
> =A0/* Interface Mode definitions */
> =A0typedef enum {
> + =A0 =A0 =A0 PHY_INTERFACE_MODE_NA,
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_MII,
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_GMII,
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_SGMII,
> @@ -62,7 +63,8 @@ typedef enum {
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_RGMII_ID,
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_RGMII_RXID,
> =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_RGMII_TXID,
> - =A0 =A0 =A0 PHY_INTERFACE_MODE_RTBI
> + =A0 =A0 =A0 PHY_INTERFACE_MODE_RTBI,
> + =A0 =A0 =A0 PHY_INTERFACE_MODE_SMII,
> =A0} phy_interface_t;
>
>
> --
> 1.7.4.1
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
