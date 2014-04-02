From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init) for
 Marvel 88E1116R PHYs
Date: Tue, 1 Apr 2014 17:57:48 -0700
Message-ID: <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60693 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaDBA63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 20:58:29 -0400
In-Reply-To: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-01 16:55 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)
> changed the initialization of the mv643xx_eth driver to use phy_init_hw()
> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
> was broken such, that it used mdelay() instead of really waiting for a
> reset to finish.

So the only big difference before
7cd1463664c2a15721ff4ccfb61d4d970815cb3d ("net: mv643xx_eth: use
phy_init_hw to reset PHY") is that we waited potentially forever for
the BMCR_RESET bit to get cleared, while now, we only wait for up to
500 milliseconds.

Could you verify the following two things before your patch gets merged:

- how long does it take for your PHY to clear the BMCR_RESET bit, is
it more than the allowed time out in
drivers/net/phy/phy_device.c::phy_poll_reset
- is your PHY powered down (check BMCR_PWRDOWN), if that is the case,
we might be hitting some corner case where toggling BMCR_RESET will
power it on, but at the expense of waiting longer

Thanks

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
>
>         return 0;
>  }
> --
> 1.8.3.1
>



-- 
Florian
