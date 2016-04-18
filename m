From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Tue, 19 Apr 2016 00:14:33 +0200
Message-ID: <20160418221433.GX25196@piout.net>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com>
 <20160415205613.GE25196@piout.net>
 <20160415220508.GC26665@lunn.ch>
 <20160415221711.GG25196@piout.net>
 <571169EB.4090300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S . Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <571169EB.4090300@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/04/2016 at 15:23:39 -0700, Florian Fainelli wrote :
> On 15/04/16 15:17, Alexandre Belloni wrote:
> > On 16/04/2016 at 00:05:08 +0200, Andrew Lunn wrote :
> >>> Trace without my patch:
> >>> libphy: MACB_mii_bus: probed
> >>> macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
> >>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
> >>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
> >>> [...]
> >>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
> >>
> >> Are there some state changes before this? How is it getting to state
> >> READY? It would expect it to start in DOWN, from when the phy device
> >> was created in phy_device_create().
> >>
> > 
> > No other changes. I forgot to mention that this is when booting with a
> > cable plugged in. Unplugging and replugging the cable makes the link
> > detection work fine even without the patch.
> 
> OK, so the last hunk of the change in d5c3d84657db ("net: phy: Avoid
> polling PHY with PHY_IGNORE_INTERRUPTS"):
> 
> -       queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
> -                          PHY_STATE_TIME * HZ);
> +       /* Only re-schedule a PHY state machine change if we are polling the
> +        * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
> +        * between states from phy_mac_interrupt()
> +        */
> +       if (phydev->irq == PHY_POLL)
> +               queue_delayed_work(system_power_efficient_wq,
> &phydev->state_queue,
> +                                  PHY_STATE_TIME * HZ);
> 
> 
> is presumably what broke for you, right?
> 
> Could you also give this patch a spin and see if it works better with
> it? The macb driver does something racy with how the MDIO and PHY are
> probe wrt. registering the netdev, that needs fixing too.
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c
> b/drivers/net/ethernet/cadence/macb.c
> index eec3200ade4a..98b99149ce0b 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -3005,28 +3005,36 @@ static int macb_probe(struct platform_device *pdev)
>         if (err)
>                 goto err_out_free_netdev;
> 
> +       err = macb_mii_init(bp);
> +       if (err)
> +               goto err_out_free_netdev;
> +
> +       phydev = bp->phy_dev;
> +       phy_attached_info(phydev);
> +
> +       netif_carrier_off(dev);
> +
>         err = register_netdev(dev);
>         if (err) {
>                 dev_err(&pdev->dev, "Cannot register net device,
> aborting.\n");
>                 goto err_out_unregister_netdev;
>         }
> 
> -       err = macb_mii_init(bp);
> -       if (err)
> -               goto err_out_unregister_netdev;
> -
> -       netif_carrier_off(dev);
> -
>         netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
>                     macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
>                     dev->base_addr, dev->irq, dev->dev_addr);
> 
> -       phydev = bp->phy_dev;
> -       phy_attached_info(phydev);
> -
>         return 0;
> 
>  err_out_unregister_netdev:
> +       phy_disconnect(bp->phy_dev);
> +       mdiobus_unregister(bp->mii_bus);
> +       mdiobus_free(bp->mii_bus);
> +
> +       /* Shutdown the PHY if there is a GPIO reset */
> +       if (bp->reset_gpio)
> +               gpiod_set_value(bp->reset_gpio, 0);
> +
>         unregister_netdev(dev);
> 
>  err_out_free_netdev:
> 

Well, this fails with:

[    2.780000] ------------[ cut here ]------------
[    2.780000] WARNING: CPU: 0 PID: 1 at lib/kobject.c:597 kobject_get+0x6c/0xa0
[    2.790000] kobject: '(null)' (df532280): is not initialized, yet kobject_get() is being called.
[    2.800000] Modules linked in:
[    2.800000] CPU: 0 PID: 1 Comm: swapper Not tainted 4.6.0-rc1+ #46
[    2.810000] Hardware name: Atmel SAMA5
[    2.810000] [<c010cc44>] (unwind_backtrace) from [<c010a76c>] (show_stack+0x10/0x14)
[    2.820000] [<c010a76c>] (show_stack) from [<c0115a70>] (__warn+0xe4/0xfc)
[    2.830000] [<c0115a70>] (__warn) from [<c0115ac0>] (warn_slowpath_fmt+0x38/0x48)
[    2.840000] [<c0115ac0>] (warn_slowpath_fmt) from [<c02d5524>] (kobject_get+0x6c/0xa0)
[    2.840000] [<c02d5524>] (kobject_get) from [<c0343b24>] (device_add+0xac/0x56c)
[    2.850000] [<c0343b24>] (device_add) from [<c03aa900>] (__mdiobus_register+0x8c/0x198)
[    2.860000] [<c03aa900>] (__mdiobus_register) from [<c045ed0c>] (of_mdiobus_register+0x20/0x184)
[    2.870000] [<c045ed0c>] (of_mdiobus_register) from [<c03b18f0>] (macb_probe+0x488/0x898)
[    2.880000] [<c03b18f0>] (macb_probe) from [<c0347ff0>] (platform_drv_probe+0x4c/0xb0)
[    2.880000] [<c0347ff0>] (platform_drv_probe) from [<c0346838>] (driver_probe_device+0x214/0x2c0)
[    2.890000] [<c0346838>] (driver_probe_device) from [<c034699c>] (__driver_attach+0xb8/0xbc)
[    2.900000] [<c034699c>] (__driver_attach) from [<c0344b8c>] (bus_for_each_dev+0x68/0x9c)
[    2.910000] [<c0344b8c>] (bus_for_each_dev) from [<c0345cd0>] (bus_add_driver+0x1a0/0x218)
[    2.920000] [<c0345cd0>] (bus_add_driver) from [<c0347084>] (driver_register+0x78/0xf8)
[    2.930000] [<c0347084>] (driver_register) from [<c010166c>] (do_one_initcall+0x90/0x1dc)
[    2.930000] [<c010166c>] (do_one_initcall) from [<c0800d78>] (kernel_init_freeable+0x134/0x1d4)
[    2.940000] [<c0800d78>] (kernel_init_freeable) from [<c05e7bd0>] (kernel_init+0x8/0x110)
[    2.950000] [<c05e7bd0>] (kernel_init) from [<c0107598>] (ret_from_fork+0x14/0x3c)
[    2.960000] ---[ end trace 81bf87ef8c18d052 ]---


I'm not completely clear why but I think one of the parent is not initialized
until register_netdev() is called.


-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
