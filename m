From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net] phy: Don't increment MDIO bus refcount unless it's a
 different owner
Date: Thu, 8 Dec 2016 18:01:27 +0100
Message-ID: <20161208170127.GJ31573@localhost>
References: <20161207045443.26246-1-f.fainelli@gmail.com>
 <20161208162740.GI31573@localhost>
 <81ffa62a-b385-94ca-2396-f2137a320e8b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, netdev@vger.kernel.org,
        rmk+kernel@arm.linux.org.uk, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35783 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLHRBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:01:23 -0500
Received: by mail-wj0-f195.google.com with SMTP id he10so41178314wjc.2
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:01:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <81ffa62a-b385-94ca-2396-f2137a320e8b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 08:47:54AM -0800, Florian Fainelli wrote:
> On 12/08/2016 08:27 AM, Johan Hovold wrote:
> > On Tue, Dec 06, 2016 at 08:54:43PM -0800, Florian Fainelli wrote:
> >> Commit 3e3aaf649416 ("phy: fix mdiobus module safety") fixed the way we
> >> dealt with MDIO bus module reference count, but sort of introduced a
> >> regression in that, if an Ethernet driver registers its own MDIO bus
> >> driver, as is common, we will end up with the Ethernet driver's
> >> module->refnct set to 1, thus preventing this driver from any removal.
> >>
> >> Fix this by comparing the network device's device driver owner against
> >> the MDIO bus driver owner, and only if they are different, increment the
> >> MDIO bus module refcount.
> >>
> >> Fixes: 3e3aaf649416 ("phy: fix mdiobus module safety")
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >> ---
> >> Russell,
> >>
> >> I verified this against the ethoc driver primarily (on a TS7300 board)
> >> and bcmgenet.
> >>
> >> Thanks!
> >>
> >>  drivers/net/phy/phy_device.c | 16 +++++++++++++---
> >>  1 file changed, 13 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> >> index 1a4bf8acad78..c4ceb082e970 100644
> >> --- a/drivers/net/phy/phy_device.c
> >> +++ b/drivers/net/phy/phy_device.c
> >> @@ -857,11 +857,17 @@ EXPORT_SYMBOL(phy_attached_print);
> >>  int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> >>  		      u32 flags, phy_interface_t interface)
> >>  {
> >> +	struct module *ndev_owner = dev->dev.parent->driver->owner;
> > 
> > Is this really safe? A driver does not need to set a parent device, and
> > in that case you get a NULL-deref here (I tried using cpsw).
> 
> Humm, cpsw does call SET_NETDEV_DEV() which should take care of that, is
> the call made too late? Do you have an example oops?

Sorry if I was being unclear, cpsw does set a parent device, but there
are network driver that do not. Perhaps such drivers will never hit this
code path, but I can't say for sure and everything appear to work for
cpsw if you comment out that SET_NETDEV_DEV (well, at least before this
patch).

> I don't mind safeguarding this with a check against dev->dev.parent, but
> I would like to fix the drivers where relevant too, since
> SET_NETDEV_DEV() should really be called, otherwise a number of things
> just don't work

I grepped for for register_netdev and think I saw a number of drivers
which do not call SET_NETDEV_DEV.

Again, perhaps they will never hit this path, but thought I should ask.

Johan
