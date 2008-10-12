From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/au1000_eth.c MDIO namespace fixes
Date: Sun, 12 Oct 2008 15:49:39 +0300
Message-ID: <20081012124939.GI31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>,
	"David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:48229 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbYJLMug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 08:50:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2e888103295f47b8fcbf7e9bb8c5da97dd2ecd76
(phylib: add mdiobus_{read,write}) causes the
following compile error:

<--  snip  -->

...
  CC      drivers/net/au1000_eth.o
drivers/net/au1000_eth.c:252: error: conflicting types for 'mdiobus_read'
include/linux/phy.h:130: error: previous declaration of 'mdiobus_read' was here
drivers/net/au1000_eth.c:263: error: conflicting types for 'mdiobus_write'
include/linux/phy.h:131: error: previous declaration of 'mdiobus_write' was here
...
make[3]: *** [drivers/net/au1000_eth.o] Error 1

<--  snip  -->

This patch prefixes the driver functions with au1000_ 


Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/au1000_eth.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7b92201..019b13c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -94,8 +94,8 @@ static irqreturn_t au1000_interrupt(int, void *);
 static void au1000_tx_timeout(struct net_device *);
 static void set_rx_mode(struct net_device *);
 static int au1000_ioctl(struct net_device *, struct ifreq *, int);
-static int mdio_read(struct net_device *, int, int);
-static void mdio_write(struct net_device *, int, int, u16);
+static int au1000_mdio_read(struct net_device *, int, int);
+static void au1000_mdio_write(struct net_device *, int, int, u16);
 static void au1000_adjust_link(struct net_device *);
 static void enable_mac(struct net_device *, int);
 
@@ -191,7 +191,7 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
 /*
  * MII operations
  */
-static int mdio_read(struct net_device *dev, int phy_addr, int reg)
+static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
@@ -225,7 +225,8 @@ static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 	return (int)*mii_data_reg;
 }
 
-static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
+static void au1000_mdio_write(struct net_device *dev, int phy_addr,
+			      int reg, u16 value)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
@@ -249,7 +250,7 @@ static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
 	*mii_control_reg = mii_control;
 }
 
-static int mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
 	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
 	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus) */
@@ -257,21 +258,21 @@ static int mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 
 	enable_mac(dev, 0); /* make sure the MAC associated with this
 			     * mii_bus is enabled */
-	return mdio_read(dev, phy_addr, regnum);
+	return au1000_mdio_read(dev, phy_addr, regnum);
 }
 
-static int mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-			 u16 value)
+static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
+				u16 value)
 {
 	struct net_device *const dev = bus->priv;
 
 	enable_mac(dev, 0); /* make sure the MAC associated with this
 			     * mii_bus is enabled */
-	mdio_write(dev, phy_addr, regnum, value);
+	au1000_mdio_write(dev, phy_addr, regnum, value);
 	return 0;
 }
 
-static int mdiobus_reset(struct mii_bus *bus)
+static int au1000_mdiobus_reset(struct mii_bus *bus)
 {
 	struct net_device *const dev = bus->priv;
 
@@ -703,9 +704,9 @@ static struct net_device * au1000_probe(int port_num)
 		goto err_out;
 
 	aup->mii_bus->priv = dev;
-	aup->mii_bus->read = mdiobus_read;
-	aup->mii_bus->write = mdiobus_write;
-	aup->mii_bus->reset = mdiobus_reset;
+	aup->mii_bus->read = au1000_mdiobus_read;
+	aup->mii_bus->write = au1000_mdiobus_write;
+	aup->mii_bus->reset = au1000_mdiobus_reset;
 	aup->mii_bus->name = "au1000_eth_mii";
 	snprintf(aup->mii_bus->id, MII_BUS_ID_SIZE, "%x", aup->mac_id);
 	aup->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);

