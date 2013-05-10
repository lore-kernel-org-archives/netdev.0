From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH] emac: Fix EMAC soft reset on 460EX/GT
Date: Thu, 9 May 2013 19:42:01 -0700
Message-ID: <CAGXr9JHwvgUmc6Z3T46fYW=hRiVgEKGTQc3cRbJdfJ435F8wsA@mail.gmail.com>
References: <20130510022504.C4CAB10064B@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f52.google.com ([209.85.128.52]:51217 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab3EJCmD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 22:42:03 -0400
Received: by mail-qe0-f52.google.com with SMTP id nd7so2202266qeb.25
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 19:42:01 -0700 (PDT)
In-Reply-To: <20130510022504.C4CAB10064B@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Non-ASCII character slipped into "Advanced User's Manual". I'll fix tha=
t ASAP.

On Thu, May 9, 2013 at 7:25 PM, Petri Gynther <pgynther@google.com> wro=
te:
> Fix EMAC soft reset on 460EX/GT to select the right PHY clock source
> before and after the soft reset.
>
> EMAC with PHY should use the clock from PHY during soft reset.
> EMAC without PHY should use the internal clock during soft reset.
>
> PPC460EX/GT Embedded Processor Advanced User=92s Manual
> section 28.10.1 Mode Register 0 (EMACx_MR0) states:
> Note: The PHY must provide a TX Clk in order to perform a soft reset
> of the EMAC. If none is present, select the internal clock
> (SDR0_ETH_CFG[EMACx_PHY_CLK] =3D 1).
> After a soft reset, select the external clock.
>
> Without the fix, 460EX/GT-based boards with RGMII PHYs attached to
> EMACs experience EMAC interrupt storm and system watchdog reset when
> issuing "ifconfig eth0 down" + "ifconfig eth0 up" a few times.
> The system enters endless loop of serving emac_irq() with EMACx_ISR
> register stuck at value 0x10000000 (Rx parity error).
>
> With the fix, the above issue is no longer observed.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/ethernet/ibm/emac/core.c | 36 ++++++++++++++++++++++++++=
++--------
>  1 file changed, 28 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ether=
net/ibm/emac/core.c
> index 4989481..205d29c 100644
> --- a/drivers/net/ethernet/ibm/emac/core.c
> +++ b/drivers/net/ethernet/ibm/emac/core.c
> @@ -359,10 +359,26 @@ static int emac_reset(struct emac_instance *dev=
)
>         }
>
>  #ifdef CONFIG_PPC_DCR_NATIVE
> -       /* Enable internal clock source */
> -       if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX))
> -               dcri_clrset(SDR0, SDR0_ETH_CFG,
> -                           0, SDR0_ETH_CFG_ECS << dev->cell_index);
> +       /*
> +        * PPC460EX/GT Embedded Processor Advanced User=92s Manual
> +        * section 28.10.1 Mode Register 0 (EMACx_MR0) states:
> +        * Note: The PHY must provide a TX Clk in order to perform a =
soft reset
> +        * of the EMAC. If none is present, select the internal clock
> +        * (SDR0_ETH_CFG[EMACx_PHY_CLK] =3D 1).
> +        * After a soft reset, select the external clock.
> +        */
> +       if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX)) {
> +               if (dev->phy_address =3D=3D 0xffffffff &&
> +                   dev->phy_map =3D=3D 0xffffffff) {
> +                       /* No PHY: select internal loop clock before =
reset */
> +                       dcri_clrset(SDR0, SDR0_ETH_CFG,
> +                                   0, SDR0_ETH_CFG_ECS << dev->cell_=
index);
> +               } else {
> +                       /* PHY present: select external clock before =
reset */
> +                       dcri_clrset(SDR0, SDR0_ETH_CFG,
> +                                   SDR0_ETH_CFG_ECS << dev->cell_ind=
ex, 0);
> +               }
> +       }
>  #endif
>
>         out_be32(&p->mr0, EMAC_MR0_SRST);
> @@ -370,10 +386,14 @@ static int emac_reset(struct emac_instance *dev=
)
>                 --n;
>
>  #ifdef CONFIG_PPC_DCR_NATIVE
> -        /* Enable external clock source */
> -       if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX))
> -               dcri_clrset(SDR0, SDR0_ETH_CFG,
> -                           SDR0_ETH_CFG_ECS << dev->cell_index, 0);
> +       if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX)) {
> +               if (dev->phy_address =3D=3D 0xffffffff &&
> +                   dev->phy_map =3D=3D 0xffffffff) {
> +                       /* No PHY: restore external clock source afte=
r reset */
> +                       dcri_clrset(SDR0, SDR0_ETH_CFG,
> +                                   SDR0_ETH_CFG_ECS << dev->cell_ind=
ex, 0);
> +               }
> +       }
>  #endif
>
>         if (n) {
> --
> 1.8.2.1
>
