From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Correctly handle MII ioctl which changes autonegotiation.
Date: Mon, 10 Nov 2014 20:17:06 -0800
Message-ID: <CAGVrzcZbRSH-t8wRAX9Zf2rXyyMfTuNWMbp2TeMrR=t3JbvGMw@mail.gmail.com>
References: <54610F8B.2000600@houston-radar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Brian Hill <brian@houston-radar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:38501 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaKKERr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 23:17:47 -0500
Received: by mail-ie0-f179.google.com with SMTP id rl12so10830212iec.10
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 20:17:47 -0800 (PST)
In-Reply-To: <54610F8B.2000600@houston-radar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian,

2014-11-10 11:18 GMT-08:00 Brian Hill <brian@houston-radar.com>:
>
>  When advertised capabilities are changed with mii-tool,
>  such as:
>  mii-tool -A 10baseT
>  the existing handler has two errors.
>
>  - An actual PHY register value is provided by mii-tool, and this
>    must be mapped to internal state with mii_adv_to_ethtool_adv_t().
>  - The PHY state machine needs to be told that autonegotiation has
>    again been performed.  If not, the MAC will not be notified of
>    the new link speed and duplex, resulting in a possible config
>    mismatch.

Looks very good to me, just one minor thing I did not notice
initially. Once you fix that, feel free to resubmit with:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> Signed-off-by: Brian Hill <Brian@houston-radar.com>
> ---
>  drivers/net/phy/phy.c |   36 ++++++++++++++++++++++++------------
>  1 file changed, 24 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c94e2a2..ee9f0c9 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -352,6 +352,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct
> ifreq *ifr, int cmd)
>  {
>      struct mii_ioctl_data *mii_data = if_mii(ifr);
>      u16 val = mii_data->val_in;
> +    int change_autoneg = 0;

This should be a "bool autoneg = false;" here

>
>      switch (cmd) {
>      case SIOCGMIIPHY:
> @@ -367,22 +368,29 @@ int phy_mii_ioctl(struct phy_device *phydev, struct
> ifreq *ifr, int cmd)
>          if (mii_data->phy_id == phydev->addr) {
>              switch (mii_data->reg_num) {
>              case MII_BMCR:
> -                if ((val & (BMCR_RESET | BMCR_ANENABLE)) == 0)
> +                if ((val & (BMCR_RESET | BMCR_ANENABLE)) == 0) {
> +                    if (phydev->autoneg == AUTONEG_ENABLE)
> +                        change_autoneg = 1;
>                      phydev->autoneg = AUTONEG_DISABLE;
> -                else
> +                    if (val & BMCR_FULLDPLX)
> +                        phydev->duplex = DUPLEX_FULL;
> +                    else
> +                        phydev->duplex = DUPLEX_HALF;
> +                    if (val & BMCR_SPEED1000)
> +                        phydev->speed = SPEED_1000;
> +                    else if (val & BMCR_SPEED100)
> +                        phydev->speed = SPEED_100;
> +                    else phydev->speed = SPEED_10;
> +                }
> +                else {
> +                    if (phydev->autoneg == AUTONEG_DISABLE)
> +                        change_autoneg = 1;
>                      phydev->autoneg = AUTONEG_ENABLE;
> -                if (!phydev->autoneg && (val & BMCR_FULLDPLX))
> -                    phydev->duplex = DUPLEX_FULL;
> -                else
> -                    phydev->duplex = DUPLEX_HALF;
> -                if (!phydev->autoneg && (val & BMCR_SPEED1000))
> -                    phydev->speed = SPEED_1000;
> -                else if (!phydev->autoneg &&
> -                     (val & BMCR_SPEED100))
> -                    phydev->speed = SPEED_100;
> +                }
>                  break;
>              case MII_ADVERTISE:
> -                phydev->advertising = val;
> +                phydev->advertising = mii_adv_to_ethtool_adv_t(val);
> +                change_autoneg = 1;
>                  break;
>              default:
>                  /* do nothing */
> @@ -396,6 +404,10 @@ int phy_mii_ioctl(struct phy_device *phydev, struct
> ifreq *ifr, int cmd)
>          if (mii_data->reg_num == MII_BMCR &&
>              val & BMCR_RESET)
>              return phy_init_hw(phydev);
> +
> +        if (change_autoneg)
> +            return phy_start_aneg(phydev);
> +
>          return 0;
>
>      case SIOCSHWTSTAMP:
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
