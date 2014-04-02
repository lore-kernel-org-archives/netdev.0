From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init) for
 Marvel 88E1116R PHYs
Date: Tue, 1 Apr 2014 17:00:30 -0700
Message-ID: <CAGVrzcZGYTK9goPnrxNLxvFJJBk9zUpedH+wZOeWPx-WKxOmbQ@mail.gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:63460 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699AbaDBABN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 20:01:13 -0400
In-Reply-To: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-01 16:55 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)

Please specify the commit message in parenthesis.

> changed the initialization of the mv643xx_eth driver to use phy_init_hw()
> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
> was broken such, that it used mdelay() instead of really waiting for a
> reset to finish.
>
> The effect was that the ethernet on my Kirkwood 88F6281 based device didn't
> come up anymore (no carrier).
>
> Fix this by waiting for a reset to finish before proceeding further.
>
> Signed-off-by: Alexander Holler <holler@ahsoftware.de>
>
> Cc: Michal Simek <michal.simek@xilinx.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: <stable@vger.kernel.org>
> ---
>  drivers/net/phy/marvell.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index bd37e45..5b84808 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -396,7 +396,9 @@ static int m88e1116r_config_init(struct phy_device *phydev)
>         if (err < 0)
>                 return err;
>
> -       mdelay(500);
> +       do
> +               temp = phy_read(phydev, MII_BMCR);
> +       while (temp & BMCR_RESET);

Please use genphy_soft_reset() which ensures that the bit is cleared,
and will also wait for an appropriate amount of time before returning.
I had a bunch of local patches waiting for net-next which clean up the
Marvell PHY driver to use genphy_soft_reset() consistently instead of
open-coding BMCR_RESET without waiting for the bit to get cleared.

>
>         err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
>         if (err < 0)
> @@ -429,7 +431,9 @@ static int m88e1116r_config_init(struct phy_device *phydev)
>         if (err < 0)
>                 return err;
>
> -       mdelay(500);
> +       do
> +               temp = phy_read(phydev, MII_BMCR);
> +       while (temp & BMCR_RESET);

Ditto.

>
>         return 0;
>  }
> --
> 1.8.3.1
>



-- 
Florian
