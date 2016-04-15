From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Fri, 15 Apr 2016 15:23:39 -0700
Message-ID: <571169EB.4090300@gmail.com>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com> <20160415205613.GE25196@piout.net>
 <20160415220508.GC26665@lunn.ch> <20160415221711.GG25196@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35587 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbcDOWZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 18:25:46 -0400
In-Reply-To: <20160415221711.GG25196@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/04/16 15:17, Alexandre Belloni wrote:
> On 16/04/2016 at 00:05:08 +0200, Andrew Lunn wrote :
>>> Trace without my patch:
>>> libphy: MACB_mii_bus: probed
>>> macb f8020000.ethernet eth0: Cadence GEM rev 0x00020120 at 0xf8020000 irq 27 (fc:c2:3d:0c:6e:05)
>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: attached PHY driver [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=f8020000.etherne:01, irq=171)
>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
>>> [...]
>>> Micrel KSZ8081 or KSZ8091 f8020000.etherne:01: PHY state change READY -> READY
>>
>> Are there some state changes before this? How is it getting to state
>> READY? It would expect it to start in DOWN, from when the phy device
>> was created in phy_device_create().
>>
> 
> No other changes. I forgot to mention that this is when booting with a
> cable plugged in. Unplugging and replugging the cable makes the link
> detection work fine even without the patch.

OK, so the last hunk of the change in d5c3d84657db ("net: phy: Avoid
polling PHY with PHY_IGNORE_INTERRUPTS"):

-       queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
-                          PHY_STATE_TIME * HZ);
+       /* Only re-schedule a PHY state machine change if we are polling the
+        * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
+        * between states from phy_mac_interrupt()
+        */
+       if (phydev->irq == PHY_POLL)
+               queue_delayed_work(system_power_efficient_wq,
&phydev->state_queue,
+                                  PHY_STATE_TIME * HZ);


is presumably what broke for you, right?

Could you also give this patch a spin and see if it works better with
it? The macb driver does something racy with how the MDIO and PHY are
probe wrt. registering the netdev, that needs fixing too.

diff --git a/drivers/net/ethernet/cadence/macb.c
b/drivers/net/ethernet/cadence/macb.c
index eec3200ade4a..98b99149ce0b 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -3005,28 +3005,36 @@ static int macb_probe(struct platform_device *pdev)
        if (err)
                goto err_out_free_netdev;

+       err = macb_mii_init(bp);
+       if (err)
+               goto err_out_free_netdev;
+
+       phydev = bp->phy_dev;
+       phy_attached_info(phydev);
+
+       netif_carrier_off(dev);
+
        err = register_netdev(dev);
        if (err) {
                dev_err(&pdev->dev, "Cannot register net device,
aborting.\n");
                goto err_out_unregister_netdev;
        }

-       err = macb_mii_init(bp);
-       if (err)
-               goto err_out_unregister_netdev;
-
-       netif_carrier_off(dev);
-
        netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
                    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
                    dev->base_addr, dev->irq, dev->dev_addr);

-       phydev = bp->phy_dev;
-       phy_attached_info(phydev);
-
        return 0;

 err_out_unregister_netdev:
+       phy_disconnect(bp->phy_dev);
+       mdiobus_unregister(bp->mii_bus);
+       mdiobus_free(bp->mii_bus);
+
+       /* Shutdown the PHY if there is a GPIO reset */
+       if (bp->reset_gpio)
+               gpiod_set_value(bp->reset_gpio, 0);
+
        unregister_netdev(dev);

 err_out_free_netdev:



-- 
Florian
