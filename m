From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] phy: unmask link partner capabilities
Date: Mon, 24 Feb 2014 10:54:01 -0800
Message-ID: <CAGVrzcZ_abzXoE7X+3mMLaSKjGSJzy4DcqFUd-Dbb_n83M=AEw@mail.gmail.com>
References: <1393257178-25052-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Shaohui Xie <shaohui.xie@freescale.com>, shruti@freescale.com,
	Ben Hutchings <ben@decadent.org.uk>
To: cristian.bercaru@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:46095 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbaBXSym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 13:54:42 -0500
Received: by mail-pd0-f177.google.com with SMTP id g10so1034072pdj.36
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 10:54:42 -0800 (PST)
In-Reply-To: <1393257178-25052-1-git-send-email-cristian.bercaru@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christian,

2014-02-24 7:52 GMT-08:00  <cristian.bercaru@freescale.com>:
> From: Cristian Bercaru <cristian.bercaru@freescale.com>
>
> Masking the link partner's capabilities with local capabilities can be
> misleading in autonegotiation scenarios such as PAUSE frame
> autonegotiation.
> This patch calculates the join between the local capabilities and the
> link parner capabilities, when it calculates the speed and duplex
> settings, but does not mask any of the link partner capabilities
> when it calculates PAUSE frame settings.
>
> Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
> ---
> v2 caches (lpa & adv) and (lpa & adv << 2) in intermediate variables.

Looks much better:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>
>  drivers/net/phy/phy_device.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index a70b604..4b021a3 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -933,6 +933,8 @@ int genphy_read_status(struct phy_device *phydev)
>         int err;
>         int lpa;
>         int lpagb = 0;
> +       int common_adv;
> +       int common_adv_gb;
>
>         /* Update the link, but return if there was an error */
>         err = genphy_update_link(phydev);
> @@ -954,7 +956,7 @@ int genphy_read_status(struct phy_device *phydev)
>
>                         phydev->lp_advertising =
>                                 mii_stat1000_to_ethtool_lpa_t(lpagb);
> -                       lpagb &= adv << 2;
> +                       common_adv_gb = lpagb & adv << 2;
>                 }
>
>                 lpa = phy_read(phydev, MII_LPA);
> @@ -967,25 +969,25 @@ int genphy_read_status(struct phy_device *phydev)
>                 if (adv < 0)
>                         return adv;
>
> -               lpa &= adv;
> +               common_adv = lpa & adv;
>
>                 phydev->speed = SPEED_10;
>                 phydev->duplex = DUPLEX_HALF;
>                 phydev->pause = 0;
>                 phydev->asym_pause = 0;
>
> -               if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
> +               if (common_adv_gb & (LPA_1000FULL | LPA_1000HALF)) {
>                         phydev->speed = SPEED_1000;
>
> -                       if (lpagb & LPA_1000FULL)
> +                       if (common_adv_gb & LPA_1000FULL)
>                                 phydev->duplex = DUPLEX_FULL;
> -               } else if (lpa & (LPA_100FULL | LPA_100HALF)) {
> +               } else if (common_adv & (LPA_100FULL | LPA_100HALF)) {
>                         phydev->speed = SPEED_100;
>
> -                       if (lpa & LPA_100FULL)
> +                       if (common_adv & LPA_100FULL)
>                                 phydev->duplex = DUPLEX_FULL;
>                 } else
> -                       if (lpa & LPA_10FULL)
> +                       if (common_adv & LPA_10FULL)
>                                 phydev->duplex = DUPLEX_FULL;
>
>                 if (phydev->duplex == DUPLEX_FULL) {
> --
> 1.7.11.7
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
