From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net PATCH 1/1] net: phy: fix phy link up when limiting speed via
 device tree
Date: Thu, 25 Jun 2015 10:31:53 -0700
Message-ID: <CAGVrzcZcs5n7A+VF3uextDgONS_UNLYDianw=NwH62Bx-6ZEyw@mail.gmail.com>
References: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35157 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbbFYRcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 13:32:33 -0400
Received: by obbop1 with SMTP id op1so51556984obb.2
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 10:32:33 -0700 (PDT)
In-Reply-To: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-06-25 9:51 GMT-07:00 Mugunthan V N <mugunthanvnm@ti.com>:
> When limiting phy link speed using "max-speed" to 100mbps or less on a
> giga bit phy, phy never completes auto negotiation and phy state
> machine is held in PHY_AN. Fixing this issue by comparing the giga
> bit advertise though phydev->supported doesn't have it but phy has
> BMSR_ESTATEN set. So that auto negotiation is restarted as old and
> new advertise are different and link comes up fine.

This looks valid, however, I am curious why this part of the code:

        oldadv = adv;
        adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
                 ADVERTISE_PAUSE_ASYM);
        adv |= ethtool_adv_to_mii_adv_t(advertise);

        if (adv != oldadv) {
                err = phy_write(phydev, MII_ADVERTISE, adv);

                if (err < 0)
                        return err;
                changed = 1;
        }

Is not flagging this as a change already?

>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/phy/phy_device.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index bdfe51f..d551df6 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -796,10 +796,11 @@ static int genphy_config_advert(struct phy_device *phydev)
>         if (phydev->supported & (SUPPORTED_1000baseT_Half |
>                                  SUPPORTED_1000baseT_Full)) {
>                 adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
> -               if (adv != oldadv)
> -                       changed = 1;
>         }
>
> +       if (adv != oldadv)
> +               changed = 1;
> +
>         err = phy_write(phydev, MII_CTRL1000, adv);
>         if (err < 0)
>                 return err;
> --
> 2.4.4.409.g5b1d901
>



-- 
Florian
