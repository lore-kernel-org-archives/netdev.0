From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/3] phylib: move to dynamic allocation of struct mii_bus
Date: Tue, 30 Sep 2008 04:56:21 +0200
Message-ID: <20080930025621.GB3251@xi.wantstofly.org>
References: <20080929021342.GD21560@xi.wantstofly.org> <3586F2DA-EF30-41CE-82F4-1AE514C3C7CD@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:51385 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbYI3C4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 22:56:25 -0400
Content-Disposition: inline
In-Reply-To: <3586F2DA-EF30-41CE-82F4-1AE514C3C7CD@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 04:31:24PM -0500, Andy Fleming wrote:

> > This patch introduces mdiobus_alloc() and mdiobus_free(), and
> > makes all mdio bus drivers use these functions to allocate their
> > struct mii_bus'es dynamically.
> >
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > ---
> > drivers/net/au1000_eth.c          |   43 +++++++++++++++---------
> > drivers/net/au1000_eth.h          |    2 +-
> > drivers/net/bfin_mac.c            |   31 ++++++++++-------
> > drivers/net/bfin_mac.h            |    2 +-
> > drivers/net/cpmac.c               |   51 +++++++++++++++++------------
> > drivers/net/fec_mpc52xx_phy.c     |    6 ++--
> > drivers/net/fs_enet/mii-bitbang.c |    7 ++--
> > drivers/net/fs_enet/mii-fec.c     |    6 ++--
> > drivers/net/gianfar_mii.c         |    7 ++--
> > drivers/net/macb.c                |   49 ++++++++++++++++-----------
> > drivers/net/macb.h                |    2 +-
> > drivers/net/mv643xx_eth.c         |   32 +++++++++++-------
> > drivers/net/phy/fixed.c           |   29 ++++++++++-----
> > drivers/net/phy/mdio-bitbang.c    |    6 +--
> > drivers/net/phy/mdio-ofgpio.c     |    9 ++---
> > drivers/net/phy/mdio_bus.c        |   24 +++++++++++++
> > drivers/net/sb1250-mac.c          |   36 ++++++++++++--------
> > drivers/net/sh_eth.c              |    2 +-
> > drivers/net/tc35815.c             |   45 +++++++++++++++----------
> > drivers/net/tg3.c                 |   66 ++++++++++++++++++ 
> > +------------------
> > drivers/net/tg3.h                 |    2 +-
> > drivers/net/ucc_geth_mii.c        |    7 ++--
> > include/linux/phy.h               |    2 +
> > 23 files changed, 279 insertions(+), 187 deletions(-)
> 
> Hrm.  I know this is to set up for your next patch, which does  
> something with mdiobus_alloc(), but this patch creates an abstraction  
> which actually increases the total amount of code.  I'm not quite sure  
> the following patch provides additional functionality that justifies  
> abstracting kzalloc.
> 
> What is the motivation for doing this?  Is it necessary to make the  
> bus dynamically allocated for the device layer to function properly?

Yes, that's the only reason for doing it.  Effectively, control of
the reference count of the mii bus is taken away from the code that
created the mii bus, which necessitates decoupling freeing of the
struct mii_bus from the freeing of whatever struct it's embedded in.

If you don't want to change the calling convention, we can always
create a 'struct mii_bus_internal' containing the struct device, with
pointer back to its parent struct mii_bus, and allocate and attach
such an object to struct mii_bus on mdiobus_register().  But that
adds extra pointer juggling and goes against what all the other struct
device users do.


> A few more comments below:
> 
> >+	if (aup->mii_bus != NULL) {
> >+		mdiobus_unregister(aup->mii_bus);
> >+		mdiobus_free(aup->mii_bus);
> 
> Should we consider merging free and unregister, since they seem like  
> they'd be called together every time.

Not _every_ time -- e.g. sb1250 registers the mii bus in ->open(),
and unregisters it in ->close(), and doesn't free it until ->remove().
(That's maybe not the way it's supposed to be done, though.)


> >@@ -231,12 +231,11 @@ static int fs_enet_mdio_remove(struct  
> >of_device *ofdev)
> >	struct bb_info *bitbang = bus->priv;
> >
> >	mdiobus_unregister(bus);
> >-	free_mdio_bitbang(bus);
> >	dev_set_drvdata(&ofdev->dev, NULL);
> >	kfree(bus->irq);
> >+	free_mdio_bitbang(bus);
> >	iounmap(bitbang->dir);
> >	kfree(bitbang);
> >-	kfree(bus);
> >
> >	return 0;
> >}
> 
> Hm.  Was the original kfree(bus) a bug?  It looks like  
> free_mdio_bitbang was doing that, anyway...
> 
> If not, why don't we need an mdiobus_free() here?

Yes, the original kfree(bus) is a bug, and the use of bus->irq
after freeing bus in free_mdio_bitbang() (the latter calls
mdiobus_free()).


> >--- a/drivers/net/phy/mdio-bitbang.c
> >+++ b/drivers/net/phy/mdio-bitbang.c
> >@@ -165,9 +165,7 @@ struct mii_bus *alloc_mdio_bitbang(struct  
> >mdiobb_ctrl *ctrl)
> >{
> >	struct mii_bus *bus;
> >
> >-	bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
> >-	if (!bus)
> >-		return NULL;
> >+	bus = mdiobus_alloc();
> 
> 
> I think you removed the error checking, here.

Thanks, fixed.


> >@@ -168,11 +168,10 @@ static int mdio_ofgpio_remove(struct of_device  
> >*ofdev)
> >	struct mdio_gpio_info *bitbang = bus->priv;
> >
> >	mdiobus_unregister(bus);
> >+	kfree(bus->irq);
> >	free_mdio_bitbang(bus);
> >	dev_set_drvdata(&ofdev->dev, NULL);
> >-	kfree(bus->irq);
> >	kfree(bitbang);
> >-	kfree(bus);
> 
> Same question here as the previous free_mdio_bitbang() invocation.

Yes, the original use of kfree(bus) was a bug (double free), as was
the use of bus->irq after freeing bus in free_mdio_bitbang().

Thanks!
