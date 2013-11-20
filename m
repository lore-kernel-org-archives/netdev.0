From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v1 4/7] net: phy: suspend unused PHYs on mdio_bus in late_initcall
Date: Wed, 20 Nov 2013 12:58:52 -0800
Message-ID: <CAGVrzcYBexBWrh2Nz8tu0KRLQ4YPjtJux9N-TC07-Hxf3On1FQ@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1384978913-8052-5-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-5-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/20 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> Since phy_attach ensures PHYs are resumed, we can now suspend all
> PHYs that have no attached netdev after initcalls.

I do like the idea, but I think you might want to make sure that the
MDIO bus suspend policy was set to "auto" (which is the default afair)
not to expose unexpected behavior.

>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/mdio_bus.c |   27 +++++++++++++++++++++++++++
>  1 files changed, 27 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 5617876..10eba58 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -320,6 +320,33 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
>                 (phydev->phy_id & phydrv->phy_id_mask));
>  }
>
> +static int mdio_bus_suspend_unused(struct device *busdev, void *data)
> +{
> +       struct mii_bus *bus = to_mii_bus(busdev);
> +       struct phy_device *phydev;
> +       struct phy_driver *phydrv;
> +       int i;
> +
> +       for (i = 0; i < PHY_MAX_ADDR; i++) {
> +               if (!bus->phy_map[i])
> +                       continue;
> +
> +               phydev = to_phy_device(&bus->phy_map[i]->dev);
> +               phydrv = to_phy_driver(phydev->dev.driver);
> +               if (!phydev->attached_dev && phydrv && phydrv->suspend)
> +                       phy_suspend(phydev);
> +       }
> +
> +       return 0;

You might want to reuse mdio_bus_phy_may_suspend() here to have a
central place checking for phydev->attached_dev and phydrv->suspend
just in case we need to add more callbacks in the future or implicit
PHY state machine hooks. That might also take care of my concern
expressed above.

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
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
