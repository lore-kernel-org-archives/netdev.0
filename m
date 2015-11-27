From: Michael Heimpold <michael.heimpold@i2se.com>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Fri, 27 Nov 2015 16:16:49 +0100
Message-ID: <565873E1.1030505@i2se.com>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Lothar_Wa=c3=9fmann?= <LW@KARO-electronics.de>,
	Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stefan Agner <stefan@agner.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am 27.11.2015 um 14:39 schrieb Lothar Wa=C3=9Fmann:
> When ENET_OUT is being used as reference clock for an external PHY,
> the clock must not be disabled while the PHY is active. Otherwise the
> PHY may lose its internal state and require a reset to become
> functional again.
>
> A symptom for this bug is a network interface that constantly toggles
> between UP and DOWN state:
> fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control =
rx/tx
> fec 800f0000.ethernet eth0: Link is Down
> fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control =
rx/tx
> fec 800f0000.ethernet eth0: Link is Down
> [...]

I would add a sentence about the solution, e.g. moving ENET_OUT handlin=
g to driver probe etc.

> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> ---
>   drivers/net/ethernet/freescale/fec_main.c | 34 +++++++++++++-------=
-----------
>   1 file changed, 14 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index d2328fc..d9df4c5 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1857,11 +1857,6 @@ static int fec_enet_clk_enable(struct net_devi=
ce *ndev, bool enable)
>   		ret =3D clk_prepare_enable(fep->clk_ahb);
>   		if (ret)
>   			return ret;
> -		if (fep->clk_enet_out) {
> -			ret =3D clk_prepare_enable(fep->clk_enet_out);
> -			if (ret)
> -				goto failed_clk_enet_out;
> -		}
>   		if (fep->clk_ptp) {
>   			mutex_lock(&fep->ptp_clk_mutex);
>   			ret =3D clk_prepare_enable(fep->clk_ptp);
> @@ -1873,35 +1868,26 @@ static int fec_enet_clk_enable(struct net_dev=
ice *ndev, bool enable)
>   			}
>   			mutex_unlock(&fep->ptp_clk_mutex);
>   		}
> -		if (fep->clk_ref) {
> -			ret =3D clk_prepare_enable(fep->clk_ref);
> -			if (ret)
> -				goto failed_clk_ref;
> -		}
> +		ret =3D clk_prepare_enable(fep->clk_ref);
> +		if (ret)
> +			goto failed_clk_ref;

This change seems unrelated to the problem. At least, I can leave this =
part out
and the toggle still disappear after apply the remaining parts.
However, I've only my Duckbill (iMX28) around to test with.

>   	} else {
>   		clk_disable_unprepare(fep->clk_ahb);
> -		if (fep->clk_enet_out)
> -			clk_disable_unprepare(fep->clk_enet_out);
>   		if (fep->clk_ptp) {
>   			mutex_lock(&fep->ptp_clk_mutex);
>   			clk_disable_unprepare(fep->clk_ptp);
>   			fep->ptp_clk_on =3D false;
>   			mutex_unlock(&fep->ptp_clk_mutex);
>   		}
> -		if (fep->clk_ref)
> -			clk_disable_unprepare(fep->clk_ref);
> +		clk_disable_unprepare(fep->clk_ref);

Same as above, might be unrelated.

>   	}
>  =20
>   	return 0;
>  =20
>   failed_clk_ref:
> -	if (fep->clk_ref)
> -		clk_disable_unprepare(fep->clk_ref);
> +	clk_disable_unprepare(fep->clk_ref);
dito

>   failed_clk_ptp:
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> -failed_clk_enet_out:
> -		clk_disable_unprepare(fep->clk_ahb);
> +	clk_disable_unprepare(fep->clk_ahb);
>  =20
>   	return ret;
>   }
> @@ -3425,6 +3411,10 @@ fec_probe(struct platform_device *pdev)
>   	if (ret)
>   		goto failed_clk;
>  =20
> +	ret =3D clk_prepare_enable(fep->clk_enet_out);
> +	if (ret)
> +		goto failed_clk_enet_out;
> +
As enet_out is optional, shouldn't this block be guarded by
if (fep->clk_enet_out)... ?

>   	ret =3D clk_prepare_enable(fep->clk_ipg);
>   	if (ret)
>   		goto failed_clk_ipg;
> @@ -3509,6 +3499,8 @@ failed_init:
>   	if (fep->reg_phy)
>   		regulator_disable(fep->reg_phy);
>   failed_regulator:
> +	clk_disable_unprepare(fep->clk_enet_out);
here too?
> +failed_clk_enet_out:
>   	clk_disable_unprepare(fep->clk_ipg);
>   failed_clk_ipg:
>   	fec_enet_clk_enable(ndev, false);
> @@ -3531,6 +3523,8 @@ fec_drv_remove(struct platform_device *pdev)
>   	fec_ptp_stop(pdev);
>   	unregister_netdev(ndev);
>   	fec_enet_mii_remove(fep);
> +	fec_enet_clk_enable(ndev, false);
> +	clk_disable_unprepare(fep->clk_enet_out);

and here too?

>   	if (fep->reg_phy)
>   		regulator_disable(fep->reg_phy);
>   	of_node_put(fep->phy_node);

Mit freundlichen Gr=C3=BC=C3=9Fen / Kind regards
Michael Heimpold
--=20
Software Engineer

I2SE GmbH                           Tel: +49 (0) 341 355667-00
=46riedrich-Ebert-Str. 61             Fax: +49 (0) 341 355667-02
04109 Leipzig
Germany
Web: http://www.i2se.com/           Mail: info@i2se.com
VAT No.: DE 811528334
Amtsgericht Leipzig HRB 23784
Gesch=C3=A4ftsf=C3=BChrer/CEO: Carsten Ziermann

*** Diese E-Mail ist allein f=C3=BCr den bezeichneten Adressaten bestim=
mt. Sie kann rechtlich vertrauliche Informationen enthalten. Wenn Sie d=
iese E-Mail irrt=C3=BCmlich erhalten haben, informieren Sie bitte unver=
z=C3=BCglich den Absender per E-Mail und l=C3=B6schen Sie diese E-Mail =
von Ihrem Computer, ohne Kopien anzufertigen.
Vielen Dank. ***

*** This email is for the exclusive use of the addressee. It may contai=
n legally privileged information. If you have received this message in =
error, please notify the sender by email immediately and delete the mes=
sage from your computer without making any copies.
Thank you. ***
