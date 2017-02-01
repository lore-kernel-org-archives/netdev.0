From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 1 Feb 2017 10:51:21 +0000
Message-ID: <20170201105121.GA8191@n2100.armlinux.org.uk>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <20170201102208.GM27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        Mao Wenan <maowenan@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:44348 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751336AbdBAKva (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 05:51:30 -0500
Content-Disposition: inline
In-Reply-To: <20170201102208.GM27312@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 01, 2017 at 10:22:08AM +0000, Russell King - ARM Linux wrote:
> On Tue, Jan 31, 2017 at 06:46:43PM -0800, Florian Fainelli wrote:
> > From: Mao Wenan <maowenan@huawei.com>
> > 
> > There is currently no reference count being held on the PHY driver,
> > which makes it possible to remove the PHY driver module while the PHY
> > state machine is running and polling the PHY. This could cause crashes
> > similar to this one to show up:
> 
> Does this really solve the problem?  What if you use sysfs to unbind the
> driver but without removing the module?

I think that's a problem, and the patch is just solving a symptom of
it.

If a phy driver is unbound from a device, phy_remove() will be called.
This will set the state to PHY_DOWN (under the mutex) before calling
the driver's remove function (if any), and finally setting phydev->drv
to NULL.

If phy_state_machine() is called after that point, then:

void phy_state_machine(struct work_struct *work)
{
...
        if (phydev->drv->link_change_notify)
                phydev->drv->link_change_notify(phydev);

which happens unconditionally, causes a NULL pointer dereference, which
is probably the same NULL pointer dereference given in Mao Wenan's patch
description.

It looks to me as if that's the only case where this can happen, so maybe
the above needs to be:

        if (phydev->drv && phydev->drv->link_change_notify)
                phydev->drv->link_change_notify(phydev);

Also, I'd suggest making sure that the workqueue is flushed in
phy_remove() after setting phydev->drv to NULL to ensure that the
workqueue isn't running while the phy driver is being unbound, which
should also make module removal safe(r).  I haven't fully analysed
that though.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
