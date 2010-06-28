From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
 atomic context.
Date: Mon, 28 Jun 2010 17:35:07 +0200
Message-ID: <ad79e07520acb5ecd6029747e74da6e468f3b249.1277737223.git.richard.cochran@omicron.at>
References: <cover.1277737222.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17909 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755247Ab0F1PfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 11:35:07 -0400
Received: by fg-out-1718.google.com with SMTP id 19so359213fgg.1
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 08:35:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1277737222.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support hardware time stamping from a PHY, it is necessary to
read from the PHY while running in_interrupt(). This patch allows a mii
bus to operate in an atomic context. An mii_bus driver may declare itself
capable for this mode. Drivers which do not do this will remain with the
default that bus operations may sleep.

Before commit 35b5f6b1a82b5c586e0b24c711dc6ba944e88ef1 mii bus
operations were protected with spin locks. That commit replaced the
locks with mutexs in order to accommodate i2c buses that need to
sleep. Thus, this patch restores the original behavior as a run time
option.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/fsl_pq_mdio.c  |    4 +-
 drivers/net/phy/mdio_bus.c |   45 +++++++++++++++++++++++++++++++++++++------
 include/linux/phy.h        |   15 ++++++++++++-
 3 files changed, 53 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index b4c41d7..0b34f50 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -145,7 +145,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 	int timeout = PHY_INIT_TIMEOUT;
 
-	mutex_lock(&bus->mdio_lock);
+	mdiobus_lock(bus);
 
 	/* Reset the management interface */
 	out_be32(&regs->miimcfg, MIIMCFG_RESET);
@@ -157,7 +157,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
 		cpu_relax();
 
-	mutex_unlock(&bus->mdio_lock);
+	mdiobus_unlock(bus);
 
 	if (timeout < 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6a6b819..ad6bed8 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -37,6 +37,32 @@
 #include <asm/uaccess.h>
 
 /**
+ * mdiobus_lock - locks a given bus for read or write operations.
+ * @bus: target mii_bus
+ */
+void mdiobus_lock(struct mii_bus *bus)
+{
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_lock(&bus->lock.m);
+	else
+		spin_lock(&bus->lock.s);
+}
+EXPORT_SYMBOL(mdiobus_lock);
+
+/**
+ * mdiobus_unlock - unlocks a given bus for read or write operations.
+ * @bus: target mii_bus
+ */
+void mdiobus_unlock(struct mii_bus *bus)
+{
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_unlock(&bus->lock.m);
+	else
+		spin_unlock(&bus->lock.s);
+}
+EXPORT_SYMBOL(mdiobus_unlock);
+
+/**
  * mdiobus_alloc - allocate a mii_bus structure
  *
  * Description: called by a bus driver to allocate an mii_bus
@@ -107,7 +133,10 @@ int mdiobus_register(struct mii_bus *bus)
 		return -EINVAL;
 	}
 
-	mutex_init(&bus->mdio_lock);
+	if (MDIOBUS_SLEEPS_RW == bus->locktype)
+		mutex_init(&bus->lock.m);
+	else
+		spin_lock_init(&bus->lock.s);
 
 	if (bus->reset)
 		bus->reset(bus);
@@ -212,11 +241,12 @@ int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
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
@@ -237,11 +267,12 @@ int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
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
index 7a8caac..93ea55f 100644
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
+	} lock;
 
 	struct device *parent;
 	enum {
@@ -127,6 +136,8 @@ struct mii_bus {
 };
 #define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 
+void mdiobus_lock(struct mii_bus *bus);
+void mdiobus_unlock(struct mii_bus *bus);
 struct mii_bus *mdiobus_alloc(void);
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
-- 
1.7.0.4

