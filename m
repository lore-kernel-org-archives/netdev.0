From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2 v3] fs_enet/mii-fec.c: fix MII speed calculation
Date: Wed, 15 Jul 2009 11:17:33 -0600
Message-ID: <fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.com>
References: <1247578966-9847-1-git-send-email-wd@denx.de>
	<1247671133-12148-1-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1247671133-12148-1-git-send-email-wd@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2009 at 9:18 AM, Wolfgang Denk<wd@denx.de> wrote:
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
> ---
> Please ignore patch v2, it's crap.
> Hope this is a bit better.
>
> =A0arch/powerpc/include/asm/mpc5xxx.h =A0 | =A0 10 +++++++++
> =A0arch/powerpc/sysdev/mpc5xxx_clocks.c | =A0 37 ++++++++++++++++++++++++=
++++++++++

Drop the common code bit.  The 5200 and 5121 are different devices and
it is a tiny bit of code.  I don't think there is any benefit to
having it as a common function.  Just roll the get_mii_speed function
in the mii-fec driver itself.

Also, this patch can be quite a bit simpler if you use the .data
pointer in the drivers match table to specify the function used to
return the bus clock speed.  Something like this:

static struct of_device_id fs_enet_mdio_fec_match[] =3D {
	{
		.compatible =3D "fsl,pq1-fec-mdio",
	},
#if defined(CONFIG_PPC_MPC512x)
	{
		.compatible =3D "fsl,mpc5121-fec-mdio",
		.data =3D mpc5xxx_get_bus_frequency,
	},
#endif
	{},
};

and

int *get_bus_freq(of_node *) =3D data;
if (get_bus_freq)
        bus_freq =3D get_bus_freq(np);
else
        bus_freq =3D ppc_proc_freq / 2;

... then do the regular calculation here and add in the additional
robustification you did in this patch.

Heck, you could even eliminate the if/else above if the normal case
you have a get_bus_speed function for the original ppc_proc_freq case,
but I'm not sure if it is worth it.


> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0 =A0| =A0 13 +++++++++--
> =A03 files changed, 57 insertions(+), 3 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/mpc5xxx.h b/arch/powerpc/include/as=
m/mpc5xxx.h
> index 5ce9c5f..86ab29f 100644
> --- a/arch/powerpc/include/asm/mpc5xxx.h
> +++ b/arch/powerpc/include/asm/mpc5xxx.h
> @@ -15,8 +15,18 @@
>
> =A0#ifndef __ASM_POWERPC_MPC5xxx_H__
> =A0#define __ASM_POWERPC_MPC5xxx_H__
> +#include <linux/of_platform.h>
>
> =A0extern unsigned long mpc5xxx_get_bus_frequency(struct device_node *nod=
e);
>
> +#if defined(CONFIG_PPC_MPC512x) || defined(CONFIG_PPC_MPC52xx)
> +extern int mpc5xxx_get_mii_speed(struct of_device *ofdev);
> +#else
> +static inline int mpc5xxx_get_mii_speed(struct of_device *ofdev)
> +{
> + =A0 =A0 =A0 return -1;
> +}
> +#endif
> +
> =A0#endif /* __ASM_POWERPC_MPC5xxx_H__ */
>
> diff --git a/arch/powerpc/sysdev/mpc5xxx_clocks.c b/arch/powerpc/sysdev/m=
pc5xxx_clocks.c
> index 34e12f9..e26d12b 100644
> --- a/arch/powerpc/sysdev/mpc5xxx_clocks.c
> +++ b/arch/powerpc/sysdev/mpc5xxx_clocks.c
> @@ -31,3 +31,40 @@ mpc5xxx_get_bus_frequency(struct device_node *node)
> =A0 =A0 =A0 =A0return p_bus_freq ? *p_bus_freq : 0;
> =A0}
> =A0EXPORT_SYMBOL(mpc5xxx_get_bus_frequency);
> +
> +/**
> + * =A0 =A0 mpc5xxx_get_mii_speed - Get the MII_SPEED value
> + * =A0 =A0 @node: =A0device node
> + *
> + * =A0 =A0 Returns the MII_SPEED value for MPC512x and MPC52xx systems.
> + * =A0 =A0 The value gets computed such that the resulting MDC frequency
> + * =A0 =A0 is 2.5 MHz or lower.
> + */
> +
> +int
> +mpc5xxx_get_mii_speed(struct of_device *ofdev)
> +{
> + =A0 =A0 =A0 unsigned int clock, speed;
> +
> + =A0 =A0 =A0 clock =3D mpc5xxx_get_bus_frequency(ofdev->node);
> +
> + =A0 =A0 =A0 if (!clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ofdev->dev, "could not determine I=
PS/IPB clock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* scale for a MII clock <=3D 2.5 MHz */
> + =A0 =A0 =A0 speed =3D (clock + 2499999) / 2500000;
> +
> + =A0 =A0 =A0 /* only 6 bits available for MII speed */
> + =A0 =A0 =A0 if (speed > 0x3F) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 speed =3D 0x3F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ofdev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MII clock (%d MHz) exceeds=
 max (2.5 MHz)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock / speed);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Field is in bits 25:30 of MII_SPEED register */
> + =A0 =A0 =A0 return speed << 1;
> +}
> +EXPORT_SYMBOL(mpc5xxx_get_mii_speed);
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
> index 75a0999..a28d39f 100644
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
> @@ -103,7 +104,6 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
> =A0static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 const struct of_device_id *match)
> =A0{
> - =A0 =A0 =A0 struct device_node *np =3D NULL;
> =A0 =A0 =A0 =A0struct resource res;
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct fec_info *fec;
> @@ -133,13 +133,20 @@ static int __devinit fs_enet_mdio_probe(struct of_d=
evice *ofdev,
> =A0 =A0 =A0 =A0if (!fec->fecp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_fec;
>
> - =A0 =A0 =A0 fec->mii_speed =3D ((ppc_proc_freq + 4999999) / 5000000) <<=
 1;
> + =A0 =A0 =A0 if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec-m=
dio")) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D mpc5xxx_get_mii_speed(ofdev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap_regs;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fec->mii_speed =3D i;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fec->mii_speed =3D ((ppc_proc_freq + 499999=
9) / 5000000) << 1;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
> =A0 =A0 =A0 =A0setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0FEC_ECNTRL_ETHER_EN);
> =A0 =A0 =A0 =A0out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
> - =A0 =A0 =A0 out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
> + =A0 =A0 =A0 clrsetbits_be32(&fec->fecp->fec_mii_speed, 0x7E, fec->mii_s=
peed);
>
> =A0 =A0 =A0 =A0new_bus->phy_mask =3D ~0;
> =A0 =A0 =A0 =A0new_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_K=
ERNEL);
> --
> 1.6.0.6
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
