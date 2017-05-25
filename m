From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 1/5] net: dsa: mv88e6xxx: Move phy functions into phy.[ch]
Date: Fri, 26 May 2017 01:03:20 +0200
Message-ID: <1495753404-29943-2-git-send-email-andrew@lunn.ch>
References: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45077 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165913AbdEYXEG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:04:06 -0400
In-Reply-To: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upcoming SERDES support will need to make use of PHY functions. Move
them out into a file of there own. No code changes.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/Makefile    |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 233 +-------------------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   2 +-
 drivers/net/dsa/mv88e6xxx/phy.c       | 246 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/phy.h       |  37 +++++
 5 files changed, 287 insertions(+), 232 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/phy.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/phy.h

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 6edd869c8d6f..e4372eaf3bc5 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -4,4 +4,5 @@ mv88e6xxx-objs += global1.o
 mv88e6xxx-objs += global1_atu.o
 mv88e6xxx-objs += global1_vtu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
+mv88e6xxx-objs += phy.o
 mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 41de250dbcc3..724f3b09e077 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -36,6 +36,7 @@
 #include "mv88e6xxx.h"
 #include "global1.h"
 #include "global2.h"
+#include "phy.h"
 #include "port.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
@@ -221,21 +222,7 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
-static int mv88e6165_phy_read(struct mv88e6xxx_chip *chip,
-			      struct mii_bus *bus,
-			      int addr, int reg, u16 *val)
-{
-	return mv88e6xxx_read(chip, addr, reg, val);
-}
-
-static int mv88e6165_phy_write(struct mv88e6xxx_chip *chip,
-			       struct mii_bus *bus,
-			       int addr, int reg, u16 val)
-{
-	return mv88e6xxx_write(chip, addr, reg, val);
-}
-
-static struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
+struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
 {
 	struct mv88e6xxx_mdio_bus *mdio_bus;
 
@@ -247,94 +234,6 @@ static struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip)
 	return mdio_bus->bus;
 }
 
-static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
-			      int reg, u16 *val)
-{
-	int addr = phy; /* PHY devices addresses start at 0x0 */
-	struct mii_bus *bus;
-
-	bus = mv88e6xxx_default_mdio_bus(chip);
-	if (!bus)
-		return -EOPNOTSUPP;
-
-	if (!chip->info->ops->phy_read)
-		return -EOPNOTSUPP;
-
-	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
-}
-
-static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
-			       int reg, u16 val)
-{
-	int addr = phy; /* PHY devices addresses start at 0x0 */
-	struct mii_bus *bus;
-
-	bus = mv88e6xxx_default_mdio_bus(chip);
-	if (!bus)
-		return -EOPNOTSUPP;
-
-	if (!chip->info->ops->phy_write)
-		return -EOPNOTSUPP;
-
-	return chip->info->ops->phy_write(chip, bus, addr, reg, val);
-}
-
-static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
-{
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
-		return -EOPNOTSUPP;
-
-	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
-}
-
-static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
-{
-	int err;
-
-	/* Restore PHY page Copper 0x0 for access via the registered MDIO bus */
-	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
-	if (unlikely(err)) {
-		dev_err(chip->dev, "failed to restore PHY %d page Copper (%d)\n",
-			phy, err);
-	}
-}
-
-static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
-				   u8 page, int reg, u16 *val)
-{
-	int err;
-
-	/* There is no paging for registers 22 */
-	if (reg == PHY_PAGE)
-		return -EINVAL;
-
-	err = mv88e6xxx_phy_page_get(chip, phy, page);
-	if (!err) {
-		err = mv88e6xxx_phy_read(chip, phy, reg, val);
-		mv88e6xxx_phy_page_put(chip, phy);
-	}
-
-	return err;
-}
-
-static int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
-				    u8 page, int reg, u16 val)
-{
-	int err;
-
-	/* There is no paging for registers 22 */
-	if (reg == PHY_PAGE)
-		return -EINVAL;
-
-	err = mv88e6xxx_phy_page_get(chip, phy, page);
-	if (!err) {
-		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
-		mv88e6xxx_phy_page_put(chip, phy);
-	}
-
-	return err;
-}
-
 static int mv88e6xxx_serdes_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
 {
 	return mv88e6xxx_phy_page_read(chip, ADDR_SERDES, SERDES_PAGE_FIBER,
@@ -560,122 +459,6 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg, u16 update)
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
-{
-	if (!chip->info->ops->ppu_disable)
-		return 0;
-
-	return chip->info->ops->ppu_disable(chip);
-}
-
-static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
-{
-	if (!chip->info->ops->ppu_enable)
-		return 0;
-
-	return chip->info->ops->ppu_enable(chip);
-}
-
-static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
-{
-	struct mv88e6xxx_chip *chip;
-
-	chip = container_of(ugly, struct mv88e6xxx_chip, ppu_work);
-
-	mutex_lock(&chip->reg_lock);
-
-	if (mutex_trylock(&chip->ppu_mutex)) {
-		if (mv88e6xxx_ppu_enable(chip) == 0)
-			chip->ppu_disabled = 0;
-		mutex_unlock(&chip->ppu_mutex);
-	}
-
-	mutex_unlock(&chip->reg_lock);
-}
-
-static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
-{
-	struct mv88e6xxx_chip *chip = (void *)_ps;
-
-	schedule_work(&chip->ppu_work);
-}
-
-static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
-{
-	int ret;
-
-	mutex_lock(&chip->ppu_mutex);
-
-	/* If the PHY polling unit is enabled, disable it so that
-	 * we can access the PHY registers.  If it was already
-	 * disabled, cancel the timer that is going to re-enable
-	 * it.
-	 */
-	if (!chip->ppu_disabled) {
-		ret = mv88e6xxx_ppu_disable(chip);
-		if (ret < 0) {
-			mutex_unlock(&chip->ppu_mutex);
-			return ret;
-		}
-		chip->ppu_disabled = 1;
-	} else {
-		del_timer(&chip->ppu_timer);
-		ret = 0;
-	}
-
-	return ret;
-}
-
-static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_chip *chip)
-{
-	/* Schedule a timer to re-enable the PHY polling unit. */
-	mod_timer(&chip->ppu_timer, jiffies + msecs_to_jiffies(10));
-	mutex_unlock(&chip->ppu_mutex);
-}
-
-static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
-{
-	mutex_init(&chip->ppu_mutex);
-	INIT_WORK(&chip->ppu_work, mv88e6xxx_ppu_reenable_work);
-	setup_timer(&chip->ppu_timer, mv88e6xxx_ppu_reenable_timer,
-		    (unsigned long)chip);
-}
-
-static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
-{
-	del_timer_sync(&chip->ppu_timer);
-}
-
-static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip,
-				  struct mii_bus *bus,
-				  int addr, int reg, u16 *val)
-{
-	int err;
-
-	err = mv88e6xxx_ppu_access_get(chip);
-	if (!err) {
-		err = mv88e6xxx_read(chip, addr, reg, val);
-		mv88e6xxx_ppu_access_put(chip);
-	}
-
-	return err;
-}
-
-static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip,
-				   struct mii_bus *bus,
-				   int addr, int reg, u16 val)
-{
-	int err;
-
-	err = mv88e6xxx_ppu_access_get(chip);
-	if (!err) {
-		err = mv88e6xxx_write(chip, addr, reg, val);
-		mv88e6xxx_ppu_access_put(chip);
-	}
-
-	return err;
-}
-
 static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
 				    int link, int speed, int duplex,
 				    phy_interface_t mode)
@@ -3914,18 +3697,6 @@ static struct mv88e6xxx_chip *mv88e6xxx_alloc_chip(struct device *dev)
 	return chip;
 }
 
-static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
-{
-	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
-		mv88e6xxx_ppu_state_init(chip);
-}
-
-static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
-{
-	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
-		mv88e6xxx_ppu_state_destroy(chip);
-}
-
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 77236cd72df2..45b387c780a8 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -942,5 +942,5 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 		     u16 update);
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask);
-
+struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip);
 #endif
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
new file mode 100644
index 000000000000..0e6c72b93c8f
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -0,0 +1,246 @@
+/*
+ * Marvell 88e6xxx Ethernet switch PHY and PPU support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2017 Andrew Lunn <andrew@lunn.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/mdio.h>
+#include <linux/module.h>
+#include <net/dsa.h>
+
+#include "mv88e6xxx.h"
+#include "phy.h"
+
+int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+		       int addr, int reg, u16 *val)
+{
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
+int mv88e6165_phy_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			int addr, int reg, u16 val)
+{
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
+
+int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy, int reg, u16 *val)
+{
+	int addr = phy; /* PHY devices addresses start at 0x0 */
+	struct mii_bus *bus;
+
+	bus = mv88e6xxx_default_mdio_bus(chip);
+	if (!bus)
+		return -EOPNOTSUPP;
+
+	if (!chip->info->ops->phy_read)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->phy_read(chip, bus, addr, reg, val);
+}
+
+int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy, int reg, u16 val)
+{
+	int addr = phy; /* PHY devices addresses start at 0x0 */
+	struct mii_bus *bus;
+
+	bus = mv88e6xxx_default_mdio_bus(chip);
+	if (!bus)
+		return -EOPNOTSUPP;
+
+	if (!chip->info->ops->phy_write)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->phy_write(chip, bus, addr, reg, val);
+}
+
+static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
+{
+	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
+		return -EOPNOTSUPP;
+
+	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+}
+
+static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
+{
+	int err;
+
+	/* Restore PHY page Copper 0x0 for access via the registered
+	 * MDIO bus
+	 */
+	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
+	if (unlikely(err)) {
+		dev_err(chip->dev,
+			"failed to restore PHY %d page Copper (%d)\n",
+			phy, err);
+	}
+}
+
+int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
+			    u8 page, int reg, u16 *val)
+{
+	int err;
+
+	/* There is no paging for registers 22 */
+	if (reg == PHY_PAGE)
+		return -EINVAL;
+
+	err = mv88e6xxx_phy_page_get(chip, phy, page);
+	if (!err) {
+		err = mv88e6xxx_phy_read(chip, phy, reg, val);
+		mv88e6xxx_phy_page_put(chip, phy);
+	}
+
+	return err;
+}
+
+int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
+			     u8 page, int reg, u16 val)
+{
+	int err;
+
+	/* There is no paging for registers 22 */
+	if (reg == PHY_PAGE)
+		return -EINVAL;
+
+	err = mv88e6xxx_phy_page_get(chip, phy, page);
+	if (!err) {
+		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+		mv88e6xxx_phy_page_put(chip, phy);
+	}
+
+	return err;
+}
+
+static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
+{
+	if (!chip->info->ops->ppu_disable)
+		return 0;
+
+	return chip->info->ops->ppu_disable(chip);
+}
+
+int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
+{
+	if (!chip->info->ops->ppu_enable)
+		return 0;
+
+	return chip->info->ops->ppu_enable(chip);
+}
+
+static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
+{
+	struct mv88e6xxx_chip *chip;
+
+	chip = container_of(ugly, struct mv88e6xxx_chip, ppu_work);
+
+	mutex_lock(&chip->reg_lock);
+
+	if (mutex_trylock(&chip->ppu_mutex)) {
+		if (mv88e6xxx_ppu_enable(chip) == 0)
+			chip->ppu_disabled = 0;
+		mutex_unlock(&chip->ppu_mutex);
+	}
+
+	mutex_unlock(&chip->reg_lock);
+}
+
+static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
+{
+	struct mv88e6xxx_chip *chip = (void *)_ps;
+
+	schedule_work(&chip->ppu_work);
+}
+
+static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_chip *chip)
+{
+	int ret;
+
+	mutex_lock(&chip->ppu_mutex);
+
+	/* If the PHY polling unit is enabled, disable it so that
+	 * we can access the PHY registers.  If it was already
+	 * disabled, cancel the timer that is going to re-enable
+	 * it.
+	 */
+	if (!chip->ppu_disabled) {
+		ret = mv88e6xxx_ppu_disable(chip);
+		if (ret < 0) {
+			mutex_unlock(&chip->ppu_mutex);
+			return ret;
+		}
+		chip->ppu_disabled = 1;
+	} else {
+		del_timer(&chip->ppu_timer);
+		ret = 0;
+	}
+
+	return ret;
+}
+
+static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_chip *chip)
+{
+	/* Schedule a timer to re-enable the PHY polling unit. */
+	mod_timer(&chip->ppu_timer, jiffies + msecs_to_jiffies(10));
+	mutex_unlock(&chip->ppu_mutex);
+}
+
+static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
+{
+	mutex_init(&chip->ppu_mutex);
+	INIT_WORK(&chip->ppu_work, mv88e6xxx_ppu_reenable_work);
+	setup_timer(&chip->ppu_timer, mv88e6xxx_ppu_reenable_timer,
+		    (unsigned long)chip);
+}
+
+static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
+{
+	del_timer_sync(&chip->ppu_timer);
+}
+
+int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			   int addr, int reg, u16 *val)
+{
+	int err;
+
+	err = mv88e6xxx_ppu_access_get(chip);
+	if (!err) {
+		err = mv88e6xxx_read(chip, addr, reg, val);
+		mv88e6xxx_ppu_access_put(chip);
+	}
+
+	return err;
+}
+
+int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			    int addr, int reg, u16 val)
+{
+	int err;
+
+	err = mv88e6xxx_ppu_access_get(chip);
+	if (!err) {
+		err = mv88e6xxx_write(chip, addr, reg, val);
+		mv88e6xxx_ppu_access_put(chip);
+	}
+
+	return err;
+}
+
+void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
+		mv88e6xxx_ppu_state_init(chip);
+}
+
+void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
+		mv88e6xxx_ppu_state_destroy(chip);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
new file mode 100644
index 000000000000..0961d781b726
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -0,0 +1,37 @@
+/*
+ * Marvell 88E6xxx PHY access
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2017 Andrew Lunn <andrew@lunn.ch>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _MV88E6XXX_PHY_H
+#define _MV88E6XXX_PHY_H
+
+int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+		       int addr, int reg, u16 *val);
+int mv88e6165_phy_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			int addr, int reg, u16 val);
+int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
+		       int reg, u16 *val);
+int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
+			int reg, u16 val);
+int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
+			    u8 page, int reg, u16 *val);
+int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
+			     u8 page, int reg, u16 val);
+int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			   int addr, int reg, u16 *val);
+int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
+			    int addr, int reg, u16 val);
+int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip);
+void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip);
+void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip);
+
+#endif /*_MV88E6XXX_PHY_H */
-- 
2.11.0
