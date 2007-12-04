From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH][RESEND] PHY: Add the phy_device_release device method.
Date: Tue, 4 Dec 2007 16:17:33 +0300
Message-ID: <20071204131733.GA27457@localhost.localdomain>
References: <20071119.214215.207388094.davem@davemloft.net> <4751D9F3.5090502@garzik.org> <20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de> <20071203214440.78709615.akpm@linux-foundation.org> <20071204073847.GA881@avionic-tr-basi.adnet.avionic-design.de>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:4133 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750993AbXLDNNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 08:13:31 -0500
Content-Disposition: inline
In-Reply-To: <20071204073847.GA881@avionic-tr-basi.adnet.avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 08:38:47AM +0100, Thierry Reding wrote:
> * Andrew Morton wrote:
> > On Mon, 3 Dec 2007 09:35:11 +0100 Thierry Reding <thierry.reding@avionic-design.de> wrote:
> > 
[...]
> > I've been sitting on
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc3/2.6.24-rc3-mm2/broken-out/phy-implement-release-function.patch
> > for a few weeks.  For some reason I have it in my "nacked netdev patches"
> > section but I think that was a mistake and it has not (yet ;)) been nacked.

Heh, it has been otherwise Acked-by: Andy Fleming, informal(?) phylib
maintainer.

> > Anyway, Anton's patch looks somewhat different from yours.  Please compare
> > notes.
> 
> FWIW, I like Anton's patch better, especially since it plugs a possible
> memory leak. I'm not sure it's useful or necessary to export the
> phy_device_free symbol, though.

Makes sense, I think. Here is the newer patch, the only difference is
removed EXPORT_SYMBOL(). Because of trivial change, I dared to keep
Andy's Acked-by intact.

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] phy: implement release function

Lately I've got this nice badness on mdio bus removal:

Device 'e0103120:06' does not have a release() function, it is broken and must be fixed.
------------[ cut here ]------------
Badness at drivers/base/core.c:107
NIP: c015c1a8 LR: c015c1a8 CTR: c0157488
REGS: c34bdcf0 TRAP: 0700   Not tainted  (2.6.23-rc5-g9ebadfbb-dirty)
MSR: 00029032 <EE,ME,IR,DR>  CR: 24088422  XER: 00000000
...
[c34bdda0] [c015c1a8] device_release+0x78/0x80 (unreliable)
[c34bddb0] [c01354cc] kobject_cleanup+0x80/0xbc
[c34bddd0] [c01365f0] kref_put+0x54/0x6c
[c34bdde0] [c013543c] kobject_put+0x24/0x34
[c34bddf0] [c015c384] put_device+0x1c/0x2c
[c34bde00] [c0180e84] mdiobus_unregister+0x2c/0x58
...

Though actually there is nothing broken, it just device
subsystem core expects another "pattern" of resource managment.

This patch implement phy device's release function, thus
we're getting rid of this badness.

Also small hidden bug fixed, hope none other introduced. ;-)

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/mdio_bus.c   |    9 +++++----
 drivers/net/phy/phy_device.c |   12 ++++++++++++
 include/linux/phy.h          |    1 +
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc2f0e6..c30196d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -91,9 +91,12 @@ int mdiobus_register(struct mii_bus *bus)
 
 			err = device_register(&phydev->dev);
 
-			if (err)
+			if (err) {
 				printk(KERN_ERR "phy %d failed to register\n",
 						i);
+				phy_device_free(phydev);
+				phydev = NULL;
+			}
 		}
 
 		bus->phy_map[i] = phydev;
@@ -110,10 +113,8 @@ void mdiobus_unregister(struct mii_bus *bus)
 	int i;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (bus->phy_map[i]) {
+		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
-			kfree(bus->phy_map[i]);
-		}
 	}
 }
 EXPORT_SYMBOL(mdiobus_unregister);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f6e4848..5b9e175 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -44,6 +44,16 @@ static struct phy_driver genphy_driver;
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
+void phy_device_free(struct phy_device *phydev)
+{
+	kfree(phydev);
+}
+
+static void phy_device_release(struct device *dev)
+{
+	phy_device_free(to_phy_device(dev));
+}
+
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 {
 	struct phy_device *dev;
@@ -54,6 +64,8 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	if (NULL == dev)
 		return (struct phy_device*) PTR_ERR((void*)-ENOMEM);
 
+	dev->dev.release = phy_device_release;
+
 	dev->speed = 0;
 	dev->duplex = -1;
 	dev->pause = dev->asym_pause = 0;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e10763d..554836e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -403,6 +403,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
+void phy_device_free(struct phy_device *phydev);
 
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
-- 
1.5.2.2

