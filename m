From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 05/12] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Tue, 15 Jun 2010 18:08:46 +0200
Message-ID: <1b8219e7d7993d0e8204b94e959477e3007534ce.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab0FOQHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:07:55 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:07:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support hardware time stamping from a PHY, it is necessary to
read from the PHY while running in_interrupt(). This patch allows a mii
bus to operate in an atomic context. An mii_bus driver may declare itself
capable for this mode. Drivers which do not do this will remain with the
default that bus operations may sleep.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/mdio_bus.c |   35 ++++++++++++++++++++++++++++-------
 include/linux/phy.h        |   13 +++++++++++--
 2 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6a6b819..441be7d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -36,6 +36,22 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
+static inline void mdiobus_lock(struct mii_bus *bus)
+{
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_lock(&bus->mdio_lock.m);
+	else
+		spin_lock(&bus->mdio_lock.s);
+}
+
+static inline void mdiobus_unlock(struct mii_bus *bus)
+{
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_unlock(&bus->mdio_lock.m);
+	else
+		spin_unlock(&bus->mdio_lock.s);
+}
+
 /**
  * mdiobus_alloc - allocate a mii_bus structure
  *
@@ -107,7 +123,10 @@ int mdiobus_register(struct mii_bus *bus)
 		return -EINVAL;
 	}
 
-	mutex_init(&bus->mdio_lock);
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_init(&bus->mdio_lock.m);
+	else
+		spin_lock_init(&bus->mdio_lock.s);
 
 	if (bus->reset)
 		bus->reset(bus);
@@ -212,11 +231,12 @@ int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
 {
 	int retval;
 
-	BUG_ON(in_interrupt());
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		BUG_ON(in_interrupt());
 
-	mutex_lock(&bus->mdio_lock);
+	mdiobus_lock(bus);
 	retval = bus->read(bus, addr, regnum);
-	mutex_unlock(&bus->mdio_lock);
+	mdiobus_unlock(bus);
 
 	return retval;
 }
@@ -237,11 +257,12 @@ int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
 {
 	int err;
 
-	BUG_ON(in_interrupt());
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		BUG_ON(in_interrupt());
 
-	mutex_lock(&bus->mdio_lock);
+	mdiobus_lock(bus);
 	err = bus->write(bus, addr, regnum, val);
-	mutex_unlock(&bus->mdio_lock);
+	mdiobus_unlock(bus);
 
 	return err;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7a8caac..352b030 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -98,11 +98,20 @@ struct mii_bus {
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
 
+	/* Indicates whether bus may be used from an atomic context. */
+	enum {
+		MDIOBUS_SLEEPS_RW,
+		MDIOBUS_ATOMIC_RW
+	} locktype;
+
 	/*
-	 * A lock to ensure that only one thing can read/write
+	 * A lock or mutex to ensure that only one thing can read/write
 	 * the MDIO bus at a time
 	 */
-	struct mutex mdio_lock;
+	union {
+		struct mutex m;
+		spinlock_t s;
+	} mdio_lock;
 
 	struct device *parent;
 	enum {
-- 
1.6.3.3

