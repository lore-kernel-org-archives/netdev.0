From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 12/12] ptp: Added a clock driver for the National
	Semiconductor PHYTER.
Date: Tue, 15 Jun 2010 12:49:13 -0600
Message-ID: <AANLkTilqd-wxqMWDxssC-XMDJqZ8iIiSrvp2t8xARAQV@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<37f5015b186bdd51f8451ade042f90c8b39a5cc8.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42452 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758234Ab0FOSyk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:54:40 -0400
Received: by gwj15 with SMTP id 15so3472223gwj.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 11:54:39 -0700 (PDT)
In-Reply-To: <37f5015b186bdd51f8451ade042f90c8b39a5cc8.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 10:10 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch adds support for the PTP clock found on the DP83640. Only =
the
> basic clock operations have been implemented.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
> =A0drivers/net/phy/Kconfig =A0 | =A0 11 +++
> =A0drivers/net/phy/dp83640.c | =A0158 +++++++++++++++++++++++++++++++=
+++++++++++++-
> =A02 files changed, 168 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 430cab1..507c68a 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -79,9 +79,20 @@ config NATIONAL_PHY
>
> =A0config DP83640_PHY
> =A0 =A0 =A0 =A0tristate "Driver for the National Semiconductor DP8364=
0 PHYTER"
> + =A0 =A0 =A0 depends on PTP_1588_CLOCK
> + =A0 =A0 =A0 depends on NETWORK_PHY_TIMESTAMPING

Won't this break things for existing DP83640 users?

> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Supports the DP83640 PHYTER with IEEE 1588 feature=
s.
>
> + =A0 =A0 =A0 =A0 This driver adds support for using the DP83640 as a=
 PTP
> + =A0 =A0 =A0 =A0 clock. This clock is only useful if your PTP progra=
ms are
> + =A0 =A0 =A0 =A0 getting hardware time stamps on the PTP Ethernet pa=
ckets
> + =A0 =A0 =A0 =A0 using the SO_TIMESTAMPING API.
> +
> + =A0 =A0 =A0 =A0 In order for this to work, your MAC driver must als=
o
> + =A0 =A0 =A0 =A0 implement the the skb_tx_timetamp() and skb_rx_time=
tamp()
> + =A0 =A0 =A0 =A0 functions.
> +
> =A0config STE10XP
> =A0 =A0 =A0 =A0depends on PHYLIB
> =A0 =A0 =A0 =A0tristate "Driver for STMicroelectronics STe10Xp PHYs"
> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> index a3217ea..21eadc3 100644
> --- a/drivers/net/phy/dp83640.c
> +++ b/drivers/net/phy/dp83640.c
> @@ -26,6 +26,7 @@
> =A0#include <linux/netdevice.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/ptp_classify.h>
> +#include <linux/ptp_clock_kernel.h>
>
> =A0#include "dp83640_reg.h"
>
> @@ -45,10 +46,13 @@ struct rxts {
> =A0};
>
> =A0struct dp83640_private {
> + =A0 =A0 =A0 struct phy_device *phydev;
> =A0 =A0 =A0 =A0int hwts_tx_en;
> =A0 =A0 =A0 =A0int hwts_rx_en;
> =A0 =A0 =A0 =A0int layer;
> =A0 =A0 =A0 =A0int version;
> + =A0 =A0 =A0 /* protects PTP_TDR register from concurrent access */
> + =A0 =A0 =A0 spinlock_t ptp_tdr_lock;
> =A0 =A0 =A0 =A0/* protects extended registers from concurrent access =
*/
> =A0 =A0 =A0 =A0spinlock_t extreg_lock;
> =A0 =A0 =A0 =A0int page;
> @@ -60,6 +64,9 @@ struct dp83640_private {
>
> =A0/* globals */
>
> +static struct ptp_clock *dp83640_clock;
> +DEFINE_SPINLOCK(clock_lock); /* protects the one and only dp83640_cl=
ock */

Why only one?  Is it not possible to have 2 of these PHYs in a system?

> +
> =A0static struct sock_filter ptp_filter[] =3D {
> =A0 =A0 =A0 =A0PTP_FILTER
> =A0};
> @@ -99,6 +106,129 @@ static void ext_write(struct phy_device *phydev,=
 int page, u32 regnum, u16 val)
> =A0 =A0 =A0 =A0spin_unlock(&dp83640->extreg_lock);
> =A0}
>
> +static int tdr_write(struct dp83640_private *dp83640,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct timespec *ts, u16 cmd=
)
> +{
> + =A0 =A0 =A0 struct phy_device *phydev =3D dp83640->phydev;
> +
> + =A0 =A0 =A0 spin_lock(&dp83640->ptp_tdr_lock);
> +
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_TDR, ts->tv_nsec & 0xffff)=
;/* ns[15:0] */
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_TDR, ts->tv_nsec >> 16); =A0=
 /* ns[31:16] */
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_TDR, ts->tv_sec & 0xffff);=
 /* sec[15:0] */
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_TDR, ts->tv_sec >> 16); =A0=
 =A0/* sec[31:16] */
> +
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_CTL, cmd);
> +
> + =A0 =A0 =A0 spin_unlock(&dp83640->ptp_tdr_lock);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* ptp clock methods */
> +
> +static int ptp_dp83640_adjfreq(void *priv, s32 ppb)
> +{
> + =A0 =A0 =A0 struct dp83640_private *dp83640 =3D priv;
> + =A0 =A0 =A0 struct phy_device *phydev =3D dp83640->phydev;
> + =A0 =A0 =A0 u64 rate;
> + =A0 =A0 =A0 int neg_adj =3D 0;
> + =A0 =A0 =A0 u16 hi, lo;
> +
> + =A0 =A0 =A0 if (!ppb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (ppb < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 neg_adj =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ppb =3D -ppb;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rate =3D ppb;
> + =A0 =A0 =A0 rate <<=3D 26;
> + =A0 =A0 =A0 rate =3D div_u64(rate, 1953125);
> +
> + =A0 =A0 =A0 hi =3D (rate >> 16) & PTP_RATE_HI_MASK;
> + =A0 =A0 =A0 if (neg_adj)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hi |=3D PTP_RATE_DIR;
> +
> + =A0 =A0 =A0 lo =3D rate & 0xffff;
> +
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_RATEH, hi);
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_RATEL, lo);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_dp83640_adjtime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 return tdr_write(priv, ts, PTP_STEP_CLK);
> +}
> +
> +static int ptp_dp83640_gettime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 struct dp83640_private *dp83640 =3D priv;
> + =A0 =A0 =A0 struct phy_device *phydev =3D dp83640->phydev;
> + =A0 =A0 =A0 unsigned int val[4];
> +
> + =A0 =A0 =A0 spin_lock(&dp83640->ptp_tdr_lock);
> +
> + =A0 =A0 =A0 ext_write(phydev, PAGE4, PTP_CTL, PTP_RD_CLK);
> +
> + =A0 =A0 =A0 val[0] =3D ext_read(phydev, PAGE4, PTP_TDR); /* ns[15:0=
] */
> + =A0 =A0 =A0 val[1] =3D ext_read(phydev, PAGE4, PTP_TDR); /* ns[31:1=
6] */
> + =A0 =A0 =A0 val[2] =3D ext_read(phydev, PAGE4, PTP_TDR); /* sec[15:=
0] */
> + =A0 =A0 =A0 val[3] =3D ext_read(phydev, PAGE4, PTP_TDR); /* sec[31:=
16] */
> +
> + =A0 =A0 =A0 spin_unlock(&dp83640->ptp_tdr_lock);
> +
> + =A0 =A0 =A0 ts->tv_nsec =3D val[0] | (val[1] << 16);
> + =A0 =A0 =A0 ts->tv_sec =A0=3D val[2] | (val[3] << 16);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int ptp_dp83640_settime(void *priv, struct timespec *ts)
> +{
> + =A0 =A0 =A0 return tdr_write(priv, ts, PTP_LOAD_CLK);
> +}
> +
> +static int ptp_dp83640_gettimer(void *priv, int index, struct itimer=
spec *ts)
> +{
> + =A0 =A0 =A0 /* We do not (yet) offer any ancillary features. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static int ptp_dp83640_settimer(void *p, int i, int abs, struct itim=
erspec *ts)
> +{
> + =A0 =A0 =A0 /* We do not (yet) offer any ancillary features. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static int ptp_dp83640_enable(void *priv, struct ptp_clock_request *=
rq, int on)
> +{
> + =A0 =A0 =A0 /* We do not (yet) offer any ancillary features. */
> + =A0 =A0 =A0 return -EOPNOTSUPP;
> +}
> +
> +static struct ptp_clock_info ptp_dp83640_caps =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "dp83640 timer",
> + =A0 =A0 =A0 .max_adj =A0 =A0 =A0 =A0=3D 1953124,
> + =A0 =A0 =A0 .n_alarm =A0 =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .n_ext_ts =A0 =A0 =A0 =3D 0,
> + =A0 =A0 =A0 .n_per_out =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .pps =A0 =A0 =A0 =A0 =A0 =A0=3D 0,
> + =A0 =A0 =A0 .priv =A0 =A0 =A0 =A0 =A0 =3D NULL,

ditto here, can leave the 0s and nulls out.

> + =A0 =A0 =A0 .adjfreq =A0 =A0 =A0 =A0=3D ptp_dp83640_adjfreq,
> + =A0 =A0 =A0 .adjtime =A0 =A0 =A0 =A0=3D ptp_dp83640_adjtime,
> + =A0 =A0 =A0 .gettime =A0 =A0 =A0 =A0=3D ptp_dp83640_gettime,
> + =A0 =A0 =A0 .settime =A0 =A0 =A0 =A0=3D ptp_dp83640_settime,
> + =A0 =A0 =A0 .gettimer =A0 =A0 =A0 =3D ptp_dp83640_gettimer,
> + =A0 =A0 =A0 .settimer =A0 =A0 =A0 =3D ptp_dp83640_settimer,
> + =A0 =A0 =A0 .enable =A0 =A0 =A0 =A0 =3D ptp_dp83640_enable,
> +};
> +
> +/* time stamping methods */
> +
> =A0static int expired(struct rxts *rxts)
> =A0{
> =A0 =A0 =A0 =A0return time_after(jiffies, rxts->tmo);
> @@ -144,6 +274,7 @@ static int match(struct sk_buff *skb, unsigned in=
t type, struct rxts *rxts)
> =A0static int dp83640_probe(struct phy_device *phydev)
> =A0{
> =A0 =A0 =A0 =A0struct dp83640_private *dp83640;
> + =A0 =A0 =A0 unsigned long flags;
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0if (sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter)))=
 {
> @@ -155,8 +286,9 @@ static int dp83640_probe(struct phy_device *phyde=
v)
> =A0 =A0 =A0 =A0if (!dp83640)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> + =A0 =A0 =A0 dp83640->phydev =3D phydev;
> + =A0 =A0 =A0 spin_lock_init(&dp83640->ptp_tdr_lock);
> =A0 =A0 =A0 =A0spin_lock_init(&dp83640->extreg_lock);
> -
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&dp83640->rxts);
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&dp83640->pool);
>
> @@ -165,12 +297,36 @@ static int dp83640_probe(struct phy_device *phy=
dev)
>
> =A0 =A0 =A0 =A0phydev->priv =3D dp83640;
>
> + =A0 =A0 =A0 spin_lock_irqsave(&clock_lock, flags);
> +
> + =A0 =A0 =A0 if (!dp83640_clock) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_dp83640_caps.priv =3D dp83640;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dp83640_clock =3D ptp_clock_register(&p=
tp_dp83640_caps);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(dp83640_clock)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(=
&clock_lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(dp83640);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(dp83640_=
clock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clock_lock, flags);
> +
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> =A0static void dp83640_remove(struct phy_device *phydev)
> =A0{
> =A0 =A0 =A0 =A0struct dp83640_private *dp83640 =3D phydev->priv;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&clock_lock, flags);
> +
> + =A0 =A0 =A0 if (ptp_dp83640_caps.priv =3D=3D dp83640) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_clock_unregister(dp83640_clock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dp83640_clock =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp_dp83640_caps.priv =3D NULL;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clock_lock, flags);
> +
> =A0 =A0 =A0 =A0kfree(dp83640);
> =A0}
>
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
