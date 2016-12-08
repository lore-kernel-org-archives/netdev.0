From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net] phy: Don't increment MDIO bus refcount unless it's a
 different owner
Date: Thu, 8 Dec 2016 17:27:40 +0100
Message-ID: <20161208162740.GI31573@localhost>
References: <20161207045443.26246-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johan@kernel.org,
        rmk+kernel@arm.linux.org.uk, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35706 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932490AbcLHQ1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:27:37 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so4573247wme.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 08:27:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161207045443.26246-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 08:54:43PM -0800, Florian Fainelli wrote:
> Commit 3e3aaf649416 ("phy: fix mdiobus module safety") fixed the way we
> dealt with MDIO bus module reference count, but sort of introduced a
> regression in that, if an Ethernet driver registers its own MDIO bus
> driver, as is common, we will end up with the Ethernet driver's
> module->refnct set to 1, thus preventing this driver from any removal.
> 
> Fix this by comparing the network device's device driver owner against
> the MDIO bus driver owner, and only if they are different, increment the
> MDIO bus module refcount.
> 
> Fixes: 3e3aaf649416 ("phy: fix mdiobus module safety")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Russell,
> 
> I verified this against the ethoc driver primarily (on a TS7300 board)
> and bcmgenet.
> 
> Thanks!
> 
>  drivers/net/phy/phy_device.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1a4bf8acad78..c4ceb082e970 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -857,11 +857,17 @@ EXPORT_SYMBOL(phy_attached_print);
>  int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		      u32 flags, phy_interface_t interface)
>  {
> +	struct module *ndev_owner = dev->dev.parent->driver->owner;

Is this really safe? A driver does not need to set a parent device, and
in that case you get a NULL-deref here (I tried using cpsw).

>  	struct mii_bus *bus = phydev->mdio.bus;
>  	struct device *d = &phydev->mdio.dev;
>  	int err;
>  
> -	if (!try_module_get(bus->owner)) {
> +	/* For Ethernet device drivers that register their own MDIO bus, we
> +	 * will have bus->owner match ndev_mod, so we do not want to increment

You also wanted s/ndev_mod/ndev_owner/ here.

> +	 * our own module->refcnt here, otherwise we would not be able to
> +	 * unload later on.
> +	 */
> +	if (ndev_owner != bus->owner && !try_module_get(bus->owner)) {
>  		dev_err(&dev->dev, "failed to get the bus module\n");
>  		return -EIO;

Johan
