From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFCv2 5/6] net: phy: suspend unused PHYs on mdio_bus in late_initcall
Date: Thu, 5 Dec 2013 16:02:53 -0800
Message-ID: <CAGVrzcaY2WAhSRNHwR4+rm5h71Ayq3kHb-a269wRqQL+c_WSLQ@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1386171888-28190-6-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46023 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911Ab3LFADd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:03:33 -0500
In-Reply-To: <1386171888-28190-6-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/4 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> Since phy_attach ensures PHYs are resumed, we can now suspend all
> PHYs that have no attached netdev after initcalls.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Changelog:
> RFCv1->RFCv2:
> - only check for phydev->attached_dev and let phy_suspend decide on
>   performing suspend or not (Suggested by Florian)
>
> @Florian: You suggested to 'make sure that the MDIO bus suspend policy
> was set to "auto"'. I wasn't able to find any clue how to check that,
> so I ignored that for now.

I was looking at the sysfs knob which controls the auto suspend
policy, but I am not sure myself how to query that from the kernel, so
let's just forget about it.

>
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/mdio_bus.c |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 5617876..f533d17 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -320,6 +320,31 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
>                 (phydev->phy_id & phydrv->phy_id_mask));
>  }
>
> +static int mdio_bus_suspend_unused(struct device *busdev, void *data)
> +{
> +       struct mii_bus *bus = to_mii_bus(busdev);
> +       struct phy_device *phydev;
> +       int i;
> +
> +       for (i = 0; i < PHY_MAX_ADDR; i++) {
> +               if (!bus->phy_map[i])
> +                       continue;
> +
> +               phydev = to_phy_device(&bus->phy_map[i]->dev);
> +               if (!phydev->attached_dev)
> +                       phy_suspend(phydev);
> +       }
> +
> +       return 0;
> +}
> +
> +static int mdio_bus_class_suspend_unused(void)
> +{
> +       return class_for_each_device(&mdio_bus_class, NULL, NULL,
> +                                    mdio_bus_suspend_unused);
> +}
> +late_initcall_sync(mdio_bus_class_suspend_unused);
> +
>  #ifdef CONFIG_PM
>
>  static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
> --
> 1.7.2.5
>



-- 
Florian
