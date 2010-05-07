From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 1/2] netdev/fec: fix performance impact from mdio poll
	operation
Date: Fri, 7 May 2010 11:06:38 -0500
Message-ID: <i2l2acbd3e41005070906me50416bapd8154a567406b886@mail.gmail.com>
References: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>
	 <1273199239-11057-2-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1273199239-11057-2-git-send-email-bryan.wu@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 6, 2010, Bryan Wu <bryan.wu@canonical.com> wrote:
> BugLink: http://bugs.launchpad.net/bugs/546649
> BugLink: http://bugs.launchpad.net/bugs/457878
>
> After introducing phylib supporting, users experienced performace dro=
p. That is
> because of the mdio polling operation of phylib. Use msleep to replac=
e the busy
> waiting cpu_relax() and remove the warning message.

I'm a little confused by this patch.  In order to improve performance,
you made the mdio functions fail silently?  Why are you getting
timeouts at all?  The Phy lib is not going to respond well if an mdio
write times out without returning an error.  And returning an error
means the whole state machine has to reset, as a failed write is not
something we currently handle gracefully.

Is it possible to use an interrupt to get the phy state change?  This
would allow the phy lib to stop its incessant polling.  It doesn't
solve the question of why it's timing out, though.

>
> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
> Acked-by: Andy Whitcroft <apw@canonical.com>
> ---
> =A0drivers/net/fec.c | =A0 45 +++++++++++++++++++++------------------=
------
> =A01 files changed, 21 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 2b1651a..9c58f6b 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -203,7 +203,7 @@ static void fec_stop(struct net_device *dev);
> =A0#define FEC_MMFR_TA =A0 =A0 =A0 =A0 =A0 =A0(2 << 16)
> =A0#define FEC_MMFR_DATA(v) =A0 =A0 =A0 (v & 0xffff)
>
> -#define FEC_MII_TIMEOUT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010000
> +#define FEC_MII_TIMEOUT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010
>
> =A0/* Transmitter timeout */
> =A0#define TX_TIMEOUT (2 * HZ)
> @@ -611,13 +611,29 @@ spin_unlock:
> =A0/*
>  =A0* NOTE: a MII transaction is during around 25 us, so polling it..=
=2E
>  =A0*/
> -static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int r=
egnum)
> +static int fec_enet_mdio_poll(struct fec_enet_private *fep)
> =A0{
> - =A0 =A0 =A0 struct fec_enet_private *fep =3D bus->priv;
>  =A0 =A0 =A0 =A0int timeout =3D FEC_MII_TIMEOUT;
>
>  =A0 =A0 =A0 =A0fep->mii_timeout =3D 0;
>
> + =A0 =A0 =A0 /* wait for end of transfer */
> + =A0 =A0 =A0 while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 msleep(1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout-- < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->mii_timeout =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int r=
egnum)
> +{
> + =A0 =A0 =A0 struct fec_enet_private *fep =3D bus->priv;
> +
> +
>  =A0 =A0 =A0 =A0/* clear MII end of transfer bit*/
>  =A0 =A0 =A0 =A0writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
>
> @@ -626,15 +642,7 @@ static int fec_enet_mdio_read(struct mii_bus *bu=
s, int mii_id, int regnum)
>  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(reg=
num) |
>  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FEC_MMFR_TA, fep->hwp + FEC_MII_DATA)=
;
>
> - =A0 =A0 =A0 /* wait for end of transfer */
> - =A0 =A0 =A0 while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout-- < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->mii_timeout =3D 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "FEC: M=
DIO read timeout\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 fec_enet_mdio_poll(fep);
>
>  =A0 =A0 =A0 =A0/* return value */
>  =A0 =A0 =A0 =A0return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
> @@ -644,9 +652,6 @@ static int fec_enet_mdio_write(struct mii_bus *bu=
s, int mii_id, int regnum,
>  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 value)
> =A0{
>  =A0 =A0 =A0 =A0struct fec_enet_private *fep =3D bus->priv;
> - =A0 =A0 =A0 int timeout =3D FEC_MII_TIMEOUT;
> -
> - =A0 =A0 =A0 fep->mii_timeout =3D 0;
>
>  =A0 =A0 =A0 =A0/* clear MII end of transfer bit*/
>  =A0 =A0 =A0 =A0writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
> @@ -657,15 +662,7 @@ static int fec_enet_mdio_write(struct mii_bus *b=
us, int mii_id, int regnum,
>  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0FEC_MMFR_TA | FEC_MMFR_DATA(value),
>  =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->hwp + FEC_MII_DATA);
>
> - =A0 =A0 =A0 /* wait for end of transfer */
> - =A0 =A0 =A0 while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout-- < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fep->mii_timeout =3D 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "FEC: M=
DIO write timeout\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 fec_enet_mdio_poll(fep);
>
>  =A0 =A0 =A0 =A0return 0;
> =A0}
> --
> 1.7.0.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
