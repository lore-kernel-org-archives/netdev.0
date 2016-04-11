From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: mdio: Fix lockdep falls positive splat
Date: Mon, 11 Apr 2016 21:40:05 +0200
Message-ID: <1460403605-31882-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53400 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427AbcDKTkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 15:40:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDIO devices can be stacked upon each other. The current code supports
two levels, which until recently has been enough for a DSA mdio bus on
top of another bus. Now we have hardware which has an MDIO mux in the
middle.

Define an MDIO MUTEX class with three levels.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio-mux.c | 10 ++--------
 drivers/net/phy/mdio_bus.c |  4 ++--
 include/linux/mdio.h       | 11 +++++++++++
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 308ade0eb1b6..5c81d6faf304 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -45,13 +45,7 @@ static int mdio_mux_read(struct mii_bus *bus, int phy_id, int regnum)
 	struct mdio_mux_parent_bus *pb = cb->parent;
 	int r;
 
-	/* In theory multiple mdio_mux could be stacked, thus creating
-	 * more than a single level of nesting.  But in practice,
-	 * SINGLE_DEPTH_NESTING will cover the vast majority of use
-	 * cases.  We use it, instead of trying to handle the general
-	 * case.
-	 */
-	mutex_lock_nested(&pb->mii_bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	mutex_lock_nested(&pb->mii_bus->mdio_lock, MDIO_MUTEX_MUX);
 	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
 	if (r)
 		goto out;
@@ -76,7 +70,7 @@ static int mdio_mux_write(struct mii_bus *bus, int phy_id,
 
 	int r;
 
-	mutex_lock_nested(&pb->mii_bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	mutex_lock_nested(&pb->mii_bus->mdio_lock, MDIO_MUTEX_MUX);
 	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
 	if (r)
 		goto out;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 0cba64f1ecf4..751202a285a6 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -457,7 +457,7 @@ int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum)
 
 	BUG_ON(in_interrupt());
 
-	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	mutex_lock_nested(&bus->mdio_lock, MDIO_MUTEX_NESTED);
 	retval = bus->read(bus, addr, regnum);
 	mutex_unlock(&bus->mdio_lock);
 
@@ -509,7 +509,7 @@ int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val)
 
 	BUG_ON(in_interrupt());
 
-	mutex_lock_nested(&bus->mdio_lock, SINGLE_DEPTH_NESTING);
+	mutex_lock_nested(&bus->mdio_lock, MDIO_MUTEX_NESTED);
 	err = bus->write(bus, addr, regnum, val);
 	mutex_unlock(&bus->mdio_lock);
 
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 5bfd99d1a40a..bf9d1d750693 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -13,6 +13,17 @@
 
 struct mii_bus;
 
+/* Multiple levels of nesting are possible. However typically this is
+ * limited to nested DSA like layer, a MUX layer, and the normal
+ * user. Instead of trying to handle the general case, just define
+ * these cases.
+ */
+enum mdio_mutex_lock_class {
+	MDIO_MUTEX_NORMAL,
+	MDIO_MUTEX_MUX,
+	MDIO_MUTEX_NESTED,
+};
+
 struct mdio_device {
 	struct device dev;
 
-- 
2.7.0
