From: John Woods <johnrw@gmail.com>
Subject: Re: IXP42x rev. A0 support for network devices
Date: Sun, 26 Apr 2009 19:06:45 -0400
Message-ID: <f7910e810904261606g6f946f87wb45e3c356cf7999d@mail.gmail.com>
References: <m3y6tnaxh8.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benoit LIETAER <blietaer@free.fr>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753860AbZDZXGz@vger.kernel.org>
In-Reply-To: <m3y6tnaxh8.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 26, 2009 at 5:58 PM, Krzysztof Halasa <khc@pm.waw.pl> wrote=
:
> Hi,
>
> well, I finally found that old prototype board with IXP425 rev A0 and
> I was even able to implant some modern RedBoot to it, so I gave it
> a try.
>
> It seems that a list of rev. A0 bugs (or "bugs") isn't that long afte=
r
> all (those affecting Ethernet at least). Basically the QMgr IRQ statu=
s
> is unreliable, and the undocumented "feature" register is write-only.
>
> This patch is a bit of handcraft but it applies to 2.6.29 and
> probably to older kernels.
> Benoit, John, please let me know if it works or not. Thanks.
> --
> Krzysztof Halasa
>
> --- a/arch/arm/mach-ixp4xx/include/mach/cpu.h
> +++ b/arch/arm/mach-ixp4xx/include/mach/cpu.h
> @@ -26,6 +26,8 @@
> =A0#define IXP46X_PROCESSOR_ID_VALUE =A0 =A0 =A00x69054200
> =A0#define IXP46X_PROCESSOR_ID_MASK =A0 =A0 =A0 0xfffffff0
>
> +#define cpu_is_ixp42x_rev_a0() ((read_cpuid_id() & (IXP4XX_PROCESSOR=
_ID_MASK | 0xF)) =3D=3D \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IXP42X_=
PROCESSOR_ID_VALUE)
> =A0#define cpu_is_ixp42x() =A0 =A0 =A0 =A0((read_cpuid_id() & IXP4XX_=
PROCESSOR_ID_MASK) =3D=3D \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IXP42X_PROCESSOR_ID_V=
ALUE)
> =A0#define cpu_is_ixp43x() =A0 =A0 =A0 =A0((read_cpuid_id() & IXP43X_=
PROCESSOR_ID_MASK) =3D=3D \
> @@ -35,6 +35,9 @@
> =A0{
> =A0 =A0 =A0 =A0unsigned int val =3D ~*IXP4XX_EXP_CFG2;
> =A0 =A0 =A0 =A0val &=3D ~IXP4XX_FEATURE_RESERVED;
> + =A0 =A0 =A0 if (cpu_is_ixp42x_rev_a0())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ~IXP4XX_FEATURE_IXP46X_ONLY & ~(=
IXP4XX_FEATURE_RCOMP |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IXP4XX_FEATURE_AES);
> =A0 =A0 =A0 =A0if (!cpu_is_ixp46x())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val &=3D ~IXP4XX_FEATURE_IXP46X_ONLY;
>
> --- a/arch/arm/mach-ixp4xx/ixp4xx_npe.c
> +++ b/arch/arm/mach-ixp4xx/ixp4xx_npe.c
> @@ -386,15 +386,6 @@ static int npe_reset(struct npe *npe)
> =A0 =A0 =A0 =A0/* reset the NPE */
> =A0 =A0 =A0 =A0ixp4xx_write_feature_bits(val &
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0~(=
IXP4XX_FEATURE_RESET_NPEA << npe->id));
> - =A0 =A0 =A0 for (i =3D 0; i < MAX_RETRIES; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(ixp4xx_read_feature_bits() &
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (IXP4XX_FEATURE_RESET_NPEA =
<< npe->id)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; =A0/* reset comp=
leted */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (i =3D=3D MAX_RETRIES)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> -
> =A0 =A0 =A0 =A0/* deassert reset */
> =A0 =A0 =A0 =A0ixp4xx_write_feature_bits(val |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(I=
XP4XX_FEATURE_RESET_NPEA << npe->id));
> --- a/arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
> +++ b/arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
> @@ -41,6 +41,31 @@ void qmgr_set_irq(unsigned int queue, int src,
> =A0}
>
>
> +static irqreturn_t qmgr_irq1_a0(int irq, void *pdev)
> +{
> + =A0 =A0 =A0 int i, ret =3D 0;
> +
> + =A0 =A0 =A0 /* ACK - it may also clear newly requested irqs so don'=
t rely on it */
> + =A0 =A0 =A0 __raw_writel(__raw_readl(&qmgr_regs->irqstat[0]),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&qmgr_regs->irqstat[0]);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < HALF_QUEUES; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 src, stat;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(qmgr_regs->irqen[0] & BIT(i)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 src =3D qmgr_regs->irqsrc[i >> 3];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat =3D qmgr_regs->stat1[i >> 3];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (src & 4) /* the IRQ condition is in=
verted */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat =3D ~stat;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stat & BIT(src & 3)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 irq_handlers[i](irq_pde=
vs[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D IRQ_HANDLED;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return ret;
> +}
> +
> +
> =A0static irqreturn_t qmgr_irq1(int irq, void *pdev)
> =A0{
> =A0 =A0 =A0 =A0int i;
> @@ -250,8 +275,8 @@ static int qmgr_init(void)
> =A0 =A0 =A0 =A0for (i =3D 0; i < QUEUES; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__raw_writel(0, &qmgr_regs->sram[i]);
>
> - =A0 =A0 =A0 err =3D request_irq(IRQ_IXP4XX_QM1, qmgr_irq1, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "IXP4xx Queue Manag=
er", NULL);
> + =A0 =A0 =A0 err =3D request_irq(IRQ_IXP4XX_QM1, cpu_is_ixp42x_rev_a=
0() ? qmgr_irq1_a0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 : qmgr_irq1, 0, "IX=
P4xx Queue Manager", NULL);
> =A0 =A0 =A0 =A0if (err) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "qmgr: failed to reque=
st IRQ%i\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IRQ_IXP4XX_QM1);
>

Hi Krzysztof,

I should be able to test it, in a day.
Thank You!

John Woods
