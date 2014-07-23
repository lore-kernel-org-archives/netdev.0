From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] net: phy: Ensure the MDIO bus module is held
Date: Wed, 23 Jul 2014 14:46:46 -0700
Message-ID: <CAGVrzcah6rRHhfxAXpRWg9f1YGNtry27TxUuLstuewnzF97s4A@mail.gmail.com>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406144852-7379-3-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:38079 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933484AbaGWVr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:47:27 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so2530047oag.40
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 14:47:26 -0700 (PDT)
In-Reply-To: <1406144852-7379-3-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-23 12:47 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>:
> This commit adds proper module_{get,put} to prevent the MDIO bus module
> from being unloaded while the phydev is connected. By doing so, we fix
> a kernel panic produced when a MDIO driver is removed, but the phydev
> that relies on it is attached and running.
>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Ezequiel!

> ---
>  drivers/net/phy/phy_device.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 4f4568e..1a5815c 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -575,6 +575,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>                       u32 flags, phy_interface_t interface)
>  {
>         struct device *d = &phydev->dev;
> +       struct module *bus_module;
>         int err;
>
>         /* Assume that if there is no driver, that it doesn't
> @@ -599,6 +600,14 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>                 return -EBUSY;
>         }
>
> +       /* Increment the bus module reference count */
> +       bus_module = phydev->bus->dev.driver ?
> +                    phydev->bus->dev.driver->owner : NULL;
> +       if (!try_module_get(bus_module)) {
> +               dev_err(&dev->dev, "failed to get the bus module\n");
> +               return -EIO;
> +       }
> +
>         phydev->attached_dev = dev;
>         dev->phydev = phydev;
>
> @@ -664,6 +673,10 @@ EXPORT_SYMBOL(phy_attach);
>  void phy_detach(struct phy_device *phydev)
>  {
>         int i;
> +
> +       if (phydev->bus->dev.driver)
> +               module_put(phydev->bus->dev.driver->owner);
> +
>         phydev->attached_dev->phydev = NULL;
>         phydev->attached_dev = NULL;
>         phy_suspend(phydev);
> --
> 2.0.1
>



-- 
Florian
