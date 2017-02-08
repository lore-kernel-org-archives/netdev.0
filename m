From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 12:47:47 -0200
Message-ID: <CAOMZO5CjRbvPJjNDGkOFjz+AZ1ydN9+SRBsypCPyNocPoFOdRA@mail.gmail.com>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
 <20170208142857.GD10855@lunn.ch> <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
 <20170208144029.GE10855@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34766 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753700AbdBHOsf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 09:48:35 -0500
Received: by mail-oi0-f45.google.com with SMTP id s203so83028407oie.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 06:47:48 -0800 (PST)
In-Reply-To: <20170208144029.GE10855@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 12:40 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> And i guess you don't have a specific PHY driver for you PHYs. You are
> using the generic PHY driver?

Yes, I am:
Generic PHY 63fec000.ethernet-1:00: attached PHY driver [Generic PHY]
(mii_bus:phy_addr=63fec000.ethernet-1:00, irq=-1)

>
> Could you try modifying phy_attach_direct() such that the
> try_module_get() is after:
>
>        /* Assume that if there is no driver, that it doesn't
>          * exist, and we should use the genphy driver.
>          */
>         if (!d->driver) {
>         <snip>
>         }

Yes, this is what I am using right now:

--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -920,11 +920,6 @@ int phy_attach_direct(struct net_device *dev,
struct phy_device *phydev,
                return -EIO;
        }

-       if (!try_module_get(d->driver->owner)) {
-               dev_err(&dev->dev, "failed to get the device driver module\n");
-               return -EIO;
-       }
-
        get_device(d);

        /* Assume that if there is no driver, that it doesn't
@@ -946,6 +941,11 @@ int phy_attach_direct(struct net_device *dev,
struct phy_device *phydev,
                        goto error;
        }

+       if (!try_module_get(d->driver->owner)) {
+               dev_err(&dev->dev, "failed to get the device driver module\n");
+               return -EIO;
+       }
+
        if (phydev->attached_dev) {
                dev_err(&dev->dev, "PHY already attached\n");
                err = -EBUSY;

Would you like me to submit this one?

Thanks
