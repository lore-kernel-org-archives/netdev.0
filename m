From: Andy Fleming <afleming@freescale.com>
Subject: [RFC PATCH 1/4] PHY Abstraction Layer III (now with more splitiness)
Date: Mon, 25 Jul 2005 14:47:50 -0500 (CDT)
Message-ID: <Pine.LNX.4.61.0507251134470.15537@cde-tx32-ldt113.sps.mot.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linuxppc-embedded <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Netdev <netdev@vger.kernel.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch contains the PHY layer itself, no phy drivers

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -131,6 +131,8 @@ if NETDEVICES
 	source "drivers/net/arcnet/Kconfig"
 endif
 
+source "drivers/net/phy/Kconfig"
+
 #
 #	Ethernet
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_ADAPTEC_STARFIRE) += starfi
 #
 
 obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_PHYLIB) += phy/
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/Kconfig
@@ -0,0 +1,57 @@
+#
+# PHY Layer Configuration
+#
+
+menu "PHY device support"
+
+config PHYLIB
+	bool "PHY Device support and infrastructure"
+	depends on NET_ETHERNET
+	help
+	  Ethernet controllers are usually attached to PHY
+	  devices.  This option provides infrastructure for
+	  managing PHY devices.
+
+config PHYCONTROL
+	bool "Support for automatically handling PHY state changes"
+	depends on PHYLIB
+	help
+	  Adds code to perform all the work for keeping PHY link
+	  state (speed/duplex/etc) up-to-date.  Also handles
+	  interrupts.
+
+comment "MII PHY device drivers"
+	depends on PHYLIB
+
+config MARVELL_PHY
+	bool "Drivers for Marvell PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently has a driver for the 88E1011S
+	
+config DAVICOM_PHY
+	bool "Drivers for Davicom PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports dm9161e and dm9131
+
+config QSEMI_PHY
+	bool "Drivers for Quality Semiconductor PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the qs6612
+
+config LXT_PHY
+	bool "Drivers for the Intel LXT PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the lxt970, lxt971
+
+config CICADA_PHY
+	bool "Drivers for the Cicada PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the cis8204
+
+endmenu
+
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/Makefile
@@ -0,0 +1,9 @@
+# Makefile for Linux PHY drivers
+
+obj-$(CONFIG_PHYLIB) += phy.o phy_device.o mdio_bus.o
+
+obj-$(CONFIG_MARVELL_PHY) += marvell.o
+obj-$(CONFIG_DAVICOM_PHY) += davicom.o
+obj-$(CONFIG_CICADA_PHY) += cicada.o
+obj-$(CONFIG_LXT_PHY) += lxt.o
+obj-$(CONFIG_QSEMI_PHY) += qsemi.o

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/mdio_bus.c
@@ -0,0 +1,175 @@
+/*
+ * drivers/net/phy/mdio_bus.c
+ *
+ * MDIO Bus interface
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify 
it
+ * under  the terms of  the GNU General  Public License as published by 
the
+ * Free Software Foundation;  either version 2 of the  License, or (at 
your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* register_mdiobus
+ *
+ * description: Called by a bus driver to bring up all the PHYs
+ *   on a given bus, and attach them to the bus
+ */
+int mdiobus_register(struct mii_bus *bus)
+{
+	int i;
+	int err = 0;
+
+	spin_lock_init(&bus->mdio_lock);
+
+	if (NULL == bus || NULL == bus->name ||
+			NULL == bus->read ||
+			NULL == bus->write)
+		return -EINVAL;
+
+	if (bus->reset)
+		bus->reset(bus);
+
+	for (i=0; i < PHY_MAX_ADDR; i++) {
+		struct phy_device *phydev;
+
+		phydev = get_phy_device(bus, i);
+
+		/* There's a PHY at this address
+		 * We need to set:
+		 * 1) IRQ
+		 * 2) bus_id
+		 * 3) parent
+		 * 4) bus
+		 * 5) mii_bus
+		 * And, we need to register it */
+		if (phydev) {
+			phydev->irq = bus->irq[i];
+
+			phydev->dev.parent = bus->dev;
+
+			phydev->dev.bus = &mdio_bus_type;
+
+			phydev->bus = bus;
+
+			sprintf(phydev->dev.bus_id, "phy%d:%d", bus->id, 
i);
+
+			err = device_register(&phydev->dev);
+
+			if (err)
+				printk("phy %d did not register (%d)\n",
+						i, err);
+
+		/* If get_phy_device returned NULL, it may be
+		 * because an error occurred.  If so, we return
+		 * that error */
+		} else if (errno)
+			return errno;
+
+		bus->phy_map[i] = phydev;
+	}
+
+	pr_info("%s: probed\n", bus->name);
+
+	return err;
+}
+EXPORT_SYMBOL(mdiobus_register);
+
+void mdiobus_unregister(struct mii_bus *bus)
+{
+	int i;
+
+	for (i=0; i < PHY_MAX_ADDR; i++)
+		if (bus->phy_map[i]) {
+			device_unregister(&bus->phy_map[i]->dev);
+			kfree(bus->phy_map[i]);
+		}
+
+}
+EXPORT_SYMBOL(mdiobus_unregister);
+
+/* mdio_bus_match
+ *
+ * description: Given a PHY device, and a PHY driver, return 1 if
+ *   the driver supports the device.  Otherwise, return 0
+ */
+static int mdio_bus_match(struct device *dev, struct device_driver *drv)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct phy_driver *phydrv = to_phy_driver(drv);
+
+	return (phydrv->phy_id == (phydev->phy_id & phydrv->phy_id_mask));
+}
+
+/* Suspend and resume.  Copied from platform_suspend and
+ * platform_resume
+ */
+static int mdio_bus_suspend(struct device * dev, u32 state)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->suspend) {
+		ret = dev->driver->suspend(dev, state, SUSPEND_DISABLE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, 
SUSPEND_SAVE_STATE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, 
SUSPEND_POWER_DOWN);
+	}
+	return ret;
+}
+
+static int mdio_bus_resume(struct device * dev)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->resume) {
+		ret = dev->driver->resume(dev, RESUME_POWER_ON);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, 
RESUME_RESTORE_STATE);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, RESUME_ENABLE);
+	}
+	return ret;
+}
+
+struct bus_type mdio_bus_type = {
+	.name	= "mdio_bus",
+	.match	= mdio_bus_match,
+	.suspend= mdio_bus_suspend,
+	.resume	= mdio_bus_resume,
+};
+
+static int __init mdio_bus_init(void)
+{
+	return bus_register(&mdio_bus_type);
+}
+
+subsys_initcall(mdio_bus_init);
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/phy.c
@@ -0,0 +1,852 @@
+/*
+ * drivers/net/phy/phy.c
+ *
+ * Framework for configuring and reading PHY devices
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify 
it
+ * under  the terms of  the GNU General  Public License as published by 
the
+ * Free Software Foundation;  either version 2 of the  License, or (at 
your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+int phy_read(struct phy_device *phydev, u16 regnum);
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+void phy_change(void *data);
+void phy_timer(unsigned long data);
+
+/* Convenience function to print out the current phy status
+ */
+void phy_print_status(struct phy_device *phydev)
+{
+	pr_info("%s: Link is %s", phydev->dev.bus_id,
+			phydev->link ? "Up" : "Down");
+	if (phydev->link)
+		printk(" - %d/%s", phydev->speed,
+				DUPLEX_FULL == phydev->duplex ?
+				"Full" : "Half");
+
+	printk("\n");
+}
+EXPORT_SYMBOL(phy_print_status);
+
+
+/* Convenience functions for reading/writing a given PHY
+ * register. They MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation. */
+int phy_read(struct phy_device *phydev, u16 regnum)
+{
+	int retval;
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	retval = bus->read(bus, phydev->addr, regnum);
+	spin_unlock_bh(&bus->mdio_lock);
+
+	return retval;
+}
+EXPORT_SYMBOL(phy_read);
+
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	int err;
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	err = bus->write(bus, phydev->addr, regnum, val);
+	spin_unlock_bh(&bus->mdio_lock);
+
+	return err;
+}
+EXPORT_SYMBOL(phy_write);
+
+
+int phy_clear_interrupt(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (phydev->drv->ack_interrupt)
+		err = phydev->drv->ack_interrupt(phydev);
+
+	return err;
+}
+
+
+int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
+{
+	int err = 0;
+
+	phydev->interrupts = interrupts;
+	if (phydev->drv->config_intr)
+		err = phydev->drv->config_intr(phydev);
+
+	return err;
+}
+
+
+/* phy_aneg_done
+ *
+ * description: Reads the status register and returns 0 either if
+ *   auto-negotiation is incomplete, or if there was an error.
+ *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
+ */
+static inline int phy_aneg_done(struct phy_device *phydev)
+{
+	int retval;
+
+	retval = phy_read(phydev, MII_BMSR);
+
+	if (retval < 0)
+		return retval;
+
+	return retval & BMSR_ANEGCOMPLETE;
+}
+
+/* phy_start_aneg
+ *
+ * description: Calls the PHY driver's config_aneg, and then
+ *   sets the PHY state to PHY_AN if auto-negotiation is enabled,
+ *   and to PHY_FORCING if auto-negotiation is disabled. Unless
+ *   the PHY is currently HALTED.
+ */
+int phy_start_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	spin_lock(&phydev->lock);
+
+	if (AUTONEG_DISABLE == phydev->autoneg)
+		phy_sanitize_settings(phydev);
+
+	err = phydev->drv->config_aneg(phydev);
+
+	if (err < 0)
+		return err;
+
+	if (phydev->state != PHY_HALTED) {
+		if (AUTONEG_ENABLE == phydev->autoneg) {
+			phydev->state = PHY_AN;
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+		} else {
+			phydev->state = PHY_FORCING;
+			phydev->link_timeout = PHY_FORCE_TIMEOUT;
+		}
+	}
+
+	spin_unlock(&phydev->lock);
+
+	return err;
+}
+EXPORT_SYMBOL(phy_start_aneg);
+
+
+/* A structure for mapping a particular speed and duplex
+ * combination to a particular SUPPORTED and ADVERTISED value */
+struct phy_setting {
+	int speed;
+	int duplex;
+	u32 setting;
+};
+
+/* A mapping of all SUPPORTED settings to speed/duplex */
+static struct phy_setting settings[] = {
+	{ .speed = 10000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_1000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_1000baseT_Half,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_100baseT_Full,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_100baseT_Half,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10baseT_Full,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_10baseT_Half,
+	},
+};
+
+#define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))
+
+/* phy_find_setting
+ *
+ * description: Searches the settings array for the setting which
+ *   matches the desired speed and duplex, and returns the index
+ *   of that setting.  Returns the index of the last setting if
+ *   none of the others match.
+ */
+static inline int phy_find_setting(int speed, int duplex)
+{
+	int idx = 0;
+
+	while (idx < MAX_NUM_SETTINGS &&
+			(settings[idx].speed != speed ||
+			settings[idx].duplex != duplex))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_find_valid
+ * idx: The first index in settings[] to search
+ * features: A mask of the valid settings
+ *
+ * description: Returns the index of the first valid setting less
+ *   than or equal to the one pointed to by idx, as determined by
+ *   the mask in features.  Returns the index of the last setting
+ *   if nothing else matches.
+ */
+static inline int phy_find_valid(int idx, u32 features)
+{
+	while (idx < MAX_NUM_SETTINGS && !(settings[idx].setting & 
features))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_sanitize_settings
+ *
+ * description: Make sure the PHY is set to supported speeds and
+ *   duplexes.  Drop down by one in this order:  1000/FULL,
+ *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF
+ */
+void phy_sanitize_settings(struct phy_device *phydev)
+{
+	u32 features = phydev->supported;
+	int idx;
+
+	/* Sanitize settings based on PHY capabilities */
+	if ((features & SUPPORTED_Autoneg) == 0)
+		phydev->autoneg = 0;
+
+	idx = phy_find_valid(phy_find_setting(phydev->speed, 
phydev->duplex),
+			features);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+}
+EXPORT_SYMBOL(phy_sanitize_settings);
+
+/* phy_force_reduction
+ *
+ * description: Reduces the speed/duplex settings by
+ *   one notch.  The order is so:
+ *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF,
+ *   10/FULL, 10/HALF.  The function bottoms out at 10/HALF.
+ */
+static void phy_force_reduction(struct phy_device *phydev)
+{
+	int idx;
+
+	idx = phy_find_setting(phydev->speed, phydev->duplex);
+	
+	idx++;
+
+	idx = phy_find_valid(idx, phydev->supported);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+
+	pr_info("Trying %d/%s\n", phydev->speed,
+			DUPLEX_FULL == phydev->duplex ?
+			"FULL" : "HALF");
+}
+
+/* phy_ethtool_sset:
+ * A generic ethtool sset function.  Handles all the details
+ *
+ * A few notes about parameter checking:
+ * - We don't set port or transceiver, so we don't care what they
+ *   were set to.
+ * - phy_start_aneg() will make sure forced settings are sane, and
+ *   choose the next best ones from the ones selected, so we don't
+ *   care if ethtool tries to give us bad values
+ */
+int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
+{
+	if (cmd->phy_address != phydev->addr)
+		return -EINVAL;
+
+	/* We make sure that we don't pass unsupported
+	 * values in to the PHY */
+	cmd->advertising &= phydev->supported;
+
+	/* Verify the settings we care about. */
+	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != 
AUTONEG_DISABLE)
+		return -EINVAL;
+
+	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+		return -EINVAL;
+
+	if (cmd->autoneg == AUTONEG_DISABLE
+			&& ((cmd->speed != SPEED_1000
+					&& cmd->speed != SPEED_100
+					&& cmd->speed != SPEED_10)
+				|| (cmd->duplex != DUPLEX_HALF
+					&& cmd->duplex != DUPLEX_FULL)))
+		return -EINVAL;
+
+	phydev->autoneg = cmd->autoneg;
+
+	phydev->speed = cmd->speed;
+
+	phydev->advertising = cmd->advertising;
+
+	if (AUTONEG_ENABLE == cmd->autoneg)
+		phydev->advertising |= ADVERTISED_Autoneg;
+	else
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+
+	phydev->duplex = cmd->duplex;
+
+	/* Restart the PHY */
+	phy_start_aneg(phydev);
+
+	return 0;
+}
+
+int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = phydev->supported;
+
+	cmd->advertising = phydev->advertising;
+
+	cmd->speed = phydev->speed;
+	cmd->duplex = phydev->duplex;
+	cmd->port = PORT_MII;
+	cmd->phy_address = phydev->addr;
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->autoneg = phydev->autoneg;
+
+	return 0;
+}
+
+
+/* Note that this function is currently incompatible with the
+ * PHYCONTROL layer.  It changes registers without regard to
+ * current state.  Use at own risk
+ */
+int phy_mii_ioctl(struct phy_device *phydev,
+		struct mii_ioctl_data *mii_data, int cmd)
+{
+	u16 val = mii_data->val_in;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		mii_data->phy_id = phydev->addr;
+		break;
+	case SIOCGMIIREG:
+		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
+		break;
+
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (mii_data->phy_id == phydev->addr) {
+			switch(mii_data->reg_num) {
+			case MII_BMCR:
+				if (val & (BMCR_RESET|BMCR_ANENABLE))
+					phydev->autoneg = AUTONEG_DISABLE;
+				else
+					phydev->autoneg = AUTONEG_ENABLE;
+				if ((!phydev->autoneg) && (val & 
BMCR_FULLDPLX))
+					phydev->duplex = DUPLEX_FULL;
+				else
+					phydev->duplex = DUPLEX_HALF;
+				break;
+			case MII_ADVERTISE:
+				phydev->advertising = val;
+				break;
+			default:
+				/* do nothing */
+				break;
+			}
+		}
+
+		phy_write(phydev, mii_data->reg_num, val);
+		
+		if (mii_data->reg_num == MII_BMCR 
+				&& val & BMCR_RESET
+				&& phydev->drv->config_init)
+			phydev->drv->config_init(phydev);
+		break;
+	}
+
+	return 0;
+}
+
+/* phy_start_machine:
+ *
+ * description: The PHY infrastructure can run a state machine
+ *   which tracks whether the PHY is starting up, negotiating,
+ *   etc.  This function starts the timer which tracks the state
+ *   of the PHY.  If you want to be notified when the state
+ *   changes, pass in the callback, otherwise, pass NULL.  If you
+ *   want to maintain your own state machine, do not call this
+ *   function. */
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct net_device *))
+{
+	phydev->adjust_state = handler;
+
+	init_timer(&phydev->phy_timer);
+	phydev->phy_timer.function = &phy_timer;
+	phydev->phy_timer.data = (unsigned long) phydev;
+	mod_timer(&phydev->phy_timer, jiffies + HZ);
+}
+
+/* phy_stop_machine
+ *
+ * description: Stops the state machine timer, sets the state to
+ *   UP (unless it wasn't up yet), and then frees the interrupt,
+ *   if it is in use. This function must be called BEFORE
+ *   phy_detach.
+ */
+void phy_stop_machine(struct phy_device *phydev)
+{
+	del_timer_sync(&phydev->phy_timer);
+
+	spin_lock(&phydev->lock);
+	if (phydev->state > PHY_UP)
+		phydev->state = PHY_UP;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->irq != PHY_POLL)
+		phy_stop_interrupts(phydev);
+
+	phydev->adjust_state = NULL;
+}
+
+#ifdef CONFIG_PHYCONTROL
+/* phy_error:
+ *
+ * Moves the PHY to the HALTED state in response to a read
+ * or write error, and tells the controller the link is down.
+ * Must not be called from interrupt context, or while the
+ * phydev->lock is held.
+ */
+void phy_error(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+	phydev->state = PHY_HALTED;
+	spin_unlock(&phydev->lock);
+}
+
+/* phy_interrupt
+ *
+ * description: When a PHY interrupt occurs, the handler disables
+ * interrupts, and schedules a work task to clear the interrupt.
+ */
+static irqreturn_t phy_interrupt(int irq, void *phy_dat, struct pt_regs 
*regs)
+{
+	struct phy_device *phydev = phy_dat;
+
+	/* The MDIO bus is not allowed to be written in interrupt
+	 * context, so we need to disable the irq here.  A work
+	 * queue will write the PHY to disable and clear the
+	 * interrupt, and then reenable the irq line. */
+	disable_irq_nosync(irq);
+
+	schedule_work(&phydev->phy_queue);
+
+	return IRQ_HANDLED;
+}
+
+/* Enable the interrupts from the PHY side */
+int phy_enable_interrupts(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_clear_interrupt(phydev);
+
+	if (err < 0)
+		return err;
+
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	return err;
+}
+
+/* Disable the PHY interrupts from the PHY side */
+int phy_disable_interrupts(struct phy_device *phydev)
+{
+	int err;
+
+	/* Disable PHY interrupts */
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+
+	if (err)
+		goto phy_err;
+
+	/* Clear the interrupt */
+	err = phy_clear_interrupt(phydev);
+
+	if (err)
+		goto phy_err;
+
+	return 0;
+
+phy_err:
+	phy_error(phydev);
+
+	return err;
+}
+
+/* phy_start_interrupts
+ *
+ * description: Request the interrupt for the given PHY.  If
+ *   this fails, then we set irq to PHY_POLL.
+ *   Otherwise, we enable the interrupts in the PHY.
+ *   Returns 0 on success.
+ *   This should only be called with a valid IRQ number.
+ */
+int phy_start_interrupts(struct phy_device *phydev)
+{
+	int err = 0;
+
+	INIT_WORK(&phydev->phy_queue, phy_change, phydev);
+
+	if (request_irq(phydev->irq, phy_interrupt,
+				SA_SHIRQ,
+				"phy_interrupt",
+				phydev) < 0) {
+		printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
+				phydev->bus->name,
+				phydev->irq);
+		phydev->irq = PHY_POLL;
+		return 0;
+	}
+
+	err = phy_enable_interrupts(phydev);
+
+	return err;
+}
+EXPORT_SYMBOL(phy_start_interrupts);
+
+int phy_stop_interrupts(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_disable_interrupts(phydev);
+
+	if (err)
+		phy_error(phydev);
+
+	free_irq(phydev->irq, phydev);
+
+	return err;
+}
+EXPORT_SYMBOL(phy_stop_interrupts);
+
+
+/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+void phy_change(void *data)
+{
+	int err;
+	struct phy_device *phydev = data;
+
+	err = phy_disable_interrupts(phydev);
+
+	if (err)
+		goto phy_err;
+
+	spin_lock(&phydev->lock);
+	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == 
phydev->state))
+		phydev->state = PHY_CHANGELINK;
+	spin_unlock(&phydev->lock);
+
+	enable_irq(phydev->irq);
+
+	/* Reenable interrupts */
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	if (err)
+		goto irq_enable_err;
+
+	return;
+
+irq_enable_err:
+	disable_irq(phydev->irq);
+phy_err:
+	phy_error(phydev);
+}
+
+/* Bring down the PHY link, and stop checking the status. */
+void phy_stop(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	if (PHY_HALTED == phydev->state) {
+		spin_unlock(&phydev->lock);
+		return;
+	}
+
+	if (phydev->irq != PHY_POLL) {
+		/* Clear any pending interrupts */
+		phy_clear_interrupt(phydev);
+
+		/* Disable PHY Interrupts */
+		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+	}
+
+	phydev->state = PHY_HALTED;
+
+	spin_unlock(&phydev->lock);
+}
+
+
+/* phy_start
+ *
+ * description: Indicates the attached device's readiness to
+ *   handle PHY-related work.  Used during startup to start the
+ *   PHY, and after a call to phy_stop() to resume operation.
+ *   Also used to indicate the MDIO bus has cleared an error
+ *   condition.
+ */
+void phy_start(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	switch (phydev->state) {
+		case PHY_STARTING:
+			phydev->state = PHY_PENDING;
+			break;
+		case PHY_READY:
+			phydev->state = PHY_UP;
+			break;
+		case PHY_HALTED:
+			phydev->state = PHY_RESUMING;
+		default:
+			break;
+	}
+	spin_unlock(&phydev->lock);
+}
+EXPORT_SYMBOL(phy_stop);
+EXPORT_SYMBOL(phy_start);
+
+/* PHY timer which handles the state machine */
+void phy_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+	int needs_aneg = 0;
+	int err = 0;
+
+	spin_lock(&phydev->lock);
+
+	if (phydev->adjust_state)
+		phydev->adjust_state(phydev->attached_dev);
+
+	switch(phydev->state) {
+		case PHY_DOWN:
+		case PHY_STARTING:
+		case PHY_READY:
+		case PHY_PENDING:
+			break;
+		case PHY_UP:
+			needs_aneg = 1;
+
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+
+			break;
+		case PHY_AN:
+			/* Check if negotiation is done.  Break
+			 * if there's an error */
+			err = phy_aneg_done(phydev);
+			if (err < 0)
+				break;
+
+			/* If auto-negotiation is done, we change to
+			 * either RUNNING, or NOLINK */
+			if (err > 0) {
+				err = phy_read_status(phydev);
+
+				if (err)
+					break;
+
+				if (phydev->link) {
+					phydev->state = PHY_RUNNING;
+					
netif_carrier_on(phydev->attached_dev);
+				} else {
+					phydev->state = PHY_NOLINK;
+					
netif_carrier_off(phydev->attached_dev);
+				}
+
+				phydev->adjust_link(phydev->attached_dev);
+
+			} else if (0 == phydev->link_timeout--) {
+				/* The counter expired, so either we
+				 * switch to forced mode, or the
+				 * magic_aneg bit exists, and we try aneg
+				 * again */
+				if (!(phydev->drv->flags & 
PHY_HAS_MAGICANEG)) {
+					int idx;
+
+					/* We'll start from the
+					 * fastest speed, and work
+					 * our way down */
+					idx = phy_find_valid(0,
+							
phydev->supported);
+
+					phydev->speed = 
settings[idx].speed;
+					phydev->duplex = 
settings[idx].duplex;
+					
+					phydev->autoneg = AUTONEG_DISABLE;
+					phydev->state = PHY_FORCING;
+					phydev->link_timeout =
+						PHY_FORCE_TIMEOUT;
+
+					pr_info("Trying %d/%s\n",
+							phydev->speed,
+							DUPLEX_FULL ==
+							phydev->duplex ?
+							"FULL" : "HALF");
+				}
+
+				needs_aneg = 1;
+			}
+			break;
+		case PHY_NOLINK:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_FORCING:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+			} else {
+				if (0 == phydev->link_timeout--) {
+					phy_force_reduction(phydev);
+					needs_aneg = 1;
+				}
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+			break;
+		case PHY_RUNNING:
+			/* Only register a CHANGE if we are
+			 * polling */
+			if (PHY_POLL == phydev->irq)
+				phydev->state = PHY_CHANGELINK;
+			break;
+		case PHY_CHANGELINK:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+			} else {
+				phydev->state = PHY_NOLINK;
+				netif_carrier_off(phydev->attached_dev);
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+
+			if (PHY_POLL != phydev->irq)
+				err = phy_config_interrupt(phydev,
+						PHY_INTERRUPT_ENABLED);
+			break;
+		case PHY_HALTED:
+			if (phydev->link) {
+				phydev->link = 0;
+				netif_carrier_off(phydev->attached_dev);
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_RESUMING:
+
+			err = phy_clear_interrupt(phydev);
+
+			if (err)
+				break;
+
+			err = phy_config_interrupt(phydev,
+					PHY_INTERRUPT_ENABLED);
+
+			if (err)
+				break;
+
+			if (AUTONEG_ENABLE == phydev->autoneg) {
+				err = phy_aneg_done(phydev);
+				if (err < 0)
+					break;
+
+				/* err > 0 if AN is done.
+				 * Otherwise, it's 0, and we're
+				 * still waiting for AN */
+				if (err > 0) {
+					phydev->state = PHY_RUNNING;
+				} else {
+					phydev->state = PHY_AN;
+					phydev->link_timeout = 
PHY_AN_TIMEOUT;
+				}
+			} else
+				phydev->state = PHY_RUNNING;
+			break;
+	}
+
+	spin_unlock(&phydev->lock);
+
+	if (needs_aneg)
+		err = phy_start_aneg(phydev);
+
+	if (err < 0)
+		phy_error(phydev);
+
+	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
+}
+
+#endif /* CONFIG_PHYCONTROL */
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/phy_device.c
@@ -0,0 +1,700 @@
+/*
+ * drivers/net/phy/phy_device.c
+ *
+ * Framework for finding and configuring PHYs.
+ * Also contains generic PHY driver
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify 
it
+ * under  the terms of  the GNU General  Public License as published by 
the
+ * Free Software Foundation;  either version 2 of the  License, or (at 
your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* get_phy_device
+ *
+ * description: Reads the ID registers of the PHY at addr on the
+ *   bus, then allocates and returns the phy_device to
+ *   represent it.
+ */
+struct phy_device * get_phy_device(struct mii_bus *bus, uint addr)
+{
+	int phy_reg;
+	u32 phy_id;
+	struct phy_device *dev = NULL;
+
+	errno = 0;
+
+	/* Grab the bits from PHYIR1, and put them
+	 * in the upper half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID1);
+
+	if (phy_reg < 0) {
+		errno = phy_reg;
+		return NULL;
+	}
+
+	phy_id = (phy_reg & 0xffff) << 16;
+
+	/* Grab the bits from PHYIR2, and put them in the lower half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID2);
+
+	if (phy_reg < 0) {
+		errno = phy_reg;
+		return NULL;
+	}
+
+	phy_id |= (phy_reg & 0xffff);
+
+	/* If the phy_id is all Fs, there is no device there */
+	if (0xffffffff == phy_id)
+		return NULL;
+
+	/* Otherwise, we allocate the device, and initialize the
+	 * default values */
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+
+	if (NULL == dev) {
+		errno = -ENOMEM;
+		return NULL;
+	}
+
+	memset(dev, 0, sizeof(*dev));
+
+	dev->speed = 0;
+	dev->duplex = -1;
+	dev->pause = dev->asym_pause = 0;
+	dev->link = 1;
+
+	dev->autoneg = AUTONEG_ENABLE;
+
+	dev->addr = addr;
+	dev->phy_id = phy_id;
+	dev->bus = bus;
+
+	dev->state = PHY_DOWN;
+
+	spin_lock_init(&dev->lock);
+
+	return dev;
+}
+
+/* phy_prepare_link:
+ *
+ * description: Tells the PHY infrastructure to handle the
+ *   gory details on monitoring link status (whether through
+ *   polling or an interrupt), and to call back to the
+ *   connected device driver when the link status changes.
+ *   If you want to monitor your own link state, don't call
+ *   this function */
+void phy_prepare_link(struct phy_device *phydev,
+		void (*handler)(struct net_device *))
+{
+	phydev->adjust_link = handler;
+}
+
+#ifdef CONFIG_PHYCONTROL
+/* phy_connect:
+ *
+ * description: Convenience function for connecting ethernet
+ *   devices to PHY devices.  The default behavior is for
+ *   the PHY infrastructure to handle everything, and only notify
+ *   the connected driver when the link status changes.  If you
+ *   don't want, or can't use the provided functionality, you may
+ *   choose to call only the subset of functions which provide
+ *   the desired functionality.
+ */
+struct phy_device * phy_connect(struct net_device *dev, const char 
*phy_id,
+		void (*handler)(struct net_device *), u32 flags)
+{
+	struct phy_device *phydev;
+
+	phydev = phy_attach(dev, phy_id, flags);
+
+	if (NULL == phydev)
+		return phydev;
+
+	phy_prepare_link(phydev, handler);
+
+	phy_start_machine(phydev, NULL);
+
+	if (phydev->irq > 0)
+		phy_start_interrupts(phydev);
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_connect);
+
+void phy_disconnect(struct phy_device *phydev)
+{
+	if (phydev->irq > 0)
+		phy_stop_interrupts(phydev);
+
+	phy_stop_machine(phydev);
+	
+	phydev->adjust_link = NULL;
+
+	phy_detach(phydev);
+}
+EXPORT_SYMBOL(phy_disconnect);
+
+#endif /* CONFIG_PHYCONTROL */
+
+/* phy_attach:
+ *
+ *   description: Called by drivers to attach to a particular PHY
+ *     device. The phy_device is found, and properly hooked up
+ *     to the phy_driver.  If no driver is attached, then the
+ *     genphy_driver is used.  The phy_device is given a ptr to
+ *     the attaching device, and given a callback for link status
+ *     change.  The phy_device is returned to the attaching
+ *     driver.
+ */
+static int phy_compare_id(struct device *dev, void *data)
+{
+	const char *name = data;
+
+	if (strcmp(name, dev->bus_id) == 0)
+		return 1;
+	return 0;
+}
+
+struct phy_device *phy_attach(struct net_device *dev,
+		const char *phy_id, u32 flags)
+{
+	struct phy_device *phydev = NULL;
+	struct bus_type *bus = &mdio_bus_type;
+	struct device *d;
+
+	/* Search the list of PHY devices on the mdio bus for the
+	 * PHY with the requested name */
+	d = bus_find_device(bus, NULL, (void *)phy_id, phy_compare_id);
+
+	if (d) {
+		phydev = to_phy_device(d);
+	} else {
+		printk(KERN_ERR "%s not found\n", phy_id);
+		errno = -ENODEV;
+		return NULL;
+	}
+
+	/* Assume that if there is no driver, that it doesn't
+	 * exist, and we should use the genphy driver. */
+	if (NULL == phydev->dev.driver) {
+		int err;
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		phydev->dev.driver = &genphy_driver.driver;
+
+		err = phydev->dev.driver->probe(&phydev->dev);
+
+		if (err < 0) {
+			errno = err;
+			return NULL;
+		}
+
+		device_bind_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+
+	if (phydev->attached_dev) {
+		printk(KERN_ERR "%s: %s already attached\n",
+				dev->name, phy_id);
+		errno = -EBUSY;
+		return NULL;
+	}
+
+	phydev->attached_dev = dev;
+
+	phydev->dev_flags = flags;
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_attach);
+
+void phy_detach(struct phy_device *phydev)
+{
+	phydev->attached_dev = NULL;
+
+	/* If the device had no specific driver before (i.e. - it
+	 * was using the generic driver), we unbind the device
+	 * from the generic driver so that there's a chance a
+	 * real driver could be loaded */
+	if (phydev->dev.driver == &genphy_driver.driver) {
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		device_release_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+}
+EXPORT_SYMBOL(phy_detach);
+
+
+/* Generic PHY support and helper functions */
+
+/* genphy_config_advert
+ *
+ * description: Writes MII_ADVERTISE with the appropriate values,
+ *   after sanitizing the values to make sure we only advertise
+ *   what is supported
+ */
+int genphy_config_advert(struct phy_device *phydev)
+{
+	u32 advertise;
+	int adv;
+	int err;
+
+	/* Only allow advertising what
+	 * this PHY supports */
+	phydev->advertising &= phydev->supported;
+	advertise = phydev->advertising;
+
+	/* Setup standard advertisement */
+	adv = phy_read(phydev, MII_ADVERTISE);
+
+	if (adv < 0)
+		return adv;
+
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP 
| 
+		 ADVERTISE_PAUSE_ASYM);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
+
+	err = phy_write(phydev, MII_ADVERTISE, adv);
+
+	if (err < 0)
+		return err;
+
+	/* Configure gigabit if it's supported */
+	if (phydev->supported & (SUPPORTED_1000baseT_Half |
+				SUPPORTED_1000baseT_Full)) {
+		adv = phy_read(phydev, MII_CTRL1000);
+
+		if (adv < 0)
+			return adv;
+
+		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+		if (advertise & SUPPORTED_1000baseT_Half)
+			adv |= ADVERTISE_1000HALF;
+		if (advertise & SUPPORTED_1000baseT_Full)
+			adv |= ADVERTISE_1000FULL;
+		err = phy_write(phydev, MII_CTRL1000, adv);
+
+		if (err < 0)
+			return err;
+	}
+
+	return adv;
+}
+EXPORT_SYMBOL(genphy_config_advert);
+
+/* genphy_setup_forced
+ *
+ * description: Configures MII_BMCR to force speed/duplex
+ *   to the values in phydev. Assumes that the values are valid.
+ *   Please see phy_sanitize_settings() */
+int genphy_setup_forced(struct phy_device *phydev)
+{
+	int ctl = BMCR_RESET;
+
+	phydev->pause = phydev->asym_pause = 0;
+
+	if (SPEED_1000 == phydev->speed)
+		ctl |= BMCR_SPEED1000;
+	else if (SPEED_100 == phydev->speed)
+		ctl |= BMCR_SPEED100;
+
+	if (DUPLEX_FULL == phydev->duplex)
+		ctl |= BMCR_FULLDPLX;
+	
+	ctl = phy_write(phydev, MII_BMCR, ctl);
+
+	if (ctl < 0)
+		return ctl;
+
+	/* We just reset the device, so we'd better configure any
+	 * settings the PHY requires to operate */
+	if (phydev->drv->config_init)
+		ctl = phydev->drv->config_init(phydev);
+
+	return ctl;
+}
+
+
+/* Enable and Restart Autonegotiation */
+int genphy_restart_aneg(struct phy_device *phydev)
+{
+	int ctl;
+
+	ctl = phy_read(phydev, MII_BMCR);
+
+	if (ctl < 0)
+		return ctl;
+
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+
+	/* Don't isolate the PHY if we're negotiating */
+	ctl &= ~(BMCR_ISOLATE);
+
+	ctl = phy_write(phydev, MII_BMCR, ctl);
+
+	return ctl;
+}
+
+
+/* genphy_config_aneg
+ *
+ * description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR
+ */
+int genphy_config_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		err = genphy_config_advert(phydev);
+
+		if (err < 0)
+			return err;
+
+		err = genphy_restart_aneg(phydev);
+	} else
+		err = genphy_setup_forced(phydev);
+
+	return err;
+}
+EXPORT_SYMBOL(genphy_config_aneg);
+
+/* genphy_update_link
+ *
+ * description: Update the value in phydev->link to reflect the
+ *   current link value.  In order to do this, we need to read
+ *   the status register twice, keeping the second value
+ */
+int genphy_update_link(struct phy_device *phydev)
+{
+	int status;
+
+	/* Do a fake read */
+	status = phy_read(phydev, MII_BMSR);
+
+	if (status < 0)
+		return status;
+
+	/* Read link and autonegotiation status */
+	status = phy_read(phydev, MII_BMSR);
+
+	if (status < 0)
+		return status;
+
+	if ((status & BMSR_LSTATUS) == 0)
+		phydev->link = 0;
+	else
+		phydev->link = 1;
+
+	return 0;
+}
+
+/* genphy_read_status
+ *
+ * description: Check the link, then figure out the current state
+ *   by comparing what we advertise with what the link partner
+ *   advertises.  Start by checking the gigabit possibilities,
+ *   then move on to 10/100.
+ */
+int genphy_read_status(struct phy_device *phydev)
+{
+	int adv;
+	int err;
+	int lpa;
+	int lpagb = 0;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		if (phydev->supported & (SUPPORTED_1000baseT_Half
+					| SUPPORTED_1000baseT_Full)) {
+			lpagb = phy_read(phydev, MII_STAT1000);
+
+			if (lpagb < 0)
+				return lpagb;
+
+			adv = phy_read(phydev, MII_CTRL1000);
+
+			if (adv < 0)
+				return adv;
+
+			lpagb &= adv << 2;
+		}
+
+		lpa = phy_read(phydev, MII_LPA);
+
+		if (lpa < 0)
+			return lpa;
+
+		adv = phy_read(phydev, MII_ADVERTISE);
+
+		if (adv < 0)
+			return adv;
+
+		lpa &= adv;
+
+		phydev->speed = SPEED_10;
+		phydev->duplex = DUPLEX_HALF;
+		phydev->pause = phydev->asym_pause = 0;
+
+		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
+			phydev->speed = SPEED_1000;
+
+			if (lpagb & LPA_1000FULL)
+				phydev->duplex = DUPLEX_FULL;
+		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
+			phydev->speed = SPEED_100;
+			
+			if (lpa & LPA_100FULL)
+				phydev->duplex = DUPLEX_FULL;
+		} else
+			if (lpa & LPA_10FULL)
+				phydev->duplex = DUPLEX_FULL;
+
+		if (phydev->duplex == DUPLEX_FULL){
+			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+		}
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+		if (bmcr < 0)
+			return bmcr;
+
+		if (bmcr & BMCR_FULLDPLX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (bmcr & BMCR_SPEED1000)
+			phydev->speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		phydev->pause = phydev->asym_pause = 0;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(genphy_read_status);
+
+static int genphy_config_init(struct phy_device *phydev)
+{
+	u32 val;
+	u32 features;
+
+	/* For now, I'll claim that the generic driver supports
+	 * all possible port types */
+	features = (SUPPORTED_TP | SUPPORTED_MII
+			| SUPPORTED_AUI | SUPPORTED_FIBRE |
+			SUPPORTED_BNC);
+
+	/* Do we support autonegotiation? */
+	val = phy_read(phydev, MII_BMSR);
+
+	if (val < 0)
+		return val;
+
+	if (val & BMSR_ANEGCAPABLE)
+		features |= SUPPORTED_Autoneg;
+
+	if (val & BMSR_100FULL)
+		features |= SUPPORTED_100baseT_Full;
+	if (val & BMSR_100HALF)
+		features |= SUPPORTED_100baseT_Half;
+	if (val & BMSR_10FULL)
+		features |= SUPPORTED_10baseT_Full;
+	if (val & BMSR_10HALF)
+		features |= SUPPORTED_10baseT_Half;
+
+	if (val & BMSR_ESTATEN) {
+		val = phy_read(phydev, MII_ESTATUS);
+
+		if (val < 0)
+			return val;
+
+		if (val & ESTATUS_1000_TFULL)
+			features |= SUPPORTED_1000baseT_Full;
+		if (val & ESTATUS_1000_THALF)
+			features |= SUPPORTED_1000baseT_Half;
+	}
+
+	phydev->supported = features;
+	phydev->advertising = features;
+
+	return 0;
+}
+
+
+/* phy_probe
+ *
+ * description: Take care of setting up the phy_device structure,
+ *   set the state to READY (the driver's init function should
+ *   set it to STARTING if needed).
+ */
+static int phy_probe(struct device *dev)
+{
+	struct phy_device *phydev;
+	struct phy_driver *phydrv;
+	struct device_driver *drv;
+	int err = 0;
+
+	phydev = to_phy_device(dev);
+
+	/* Make sure the driver is held.
+	 * XXX -- Is this correct? */
+	drv = get_driver(phydev->dev.driver);
+	phydrv = to_phy_driver(drv);
+	phydev->drv = phydrv;
+
+	/* Disable the interrupt if the PHY doesn't support it */
+	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
+		phydev->irq = PHY_POLL;
+
+	spin_lock(&phydev->lock);
+
+	/* Start out supporting everything. Eventually,
+	 * a controller will attach, and may modify one
+	 * or both of these values */
+	phydev->supported = phydrv->features;
+	phydev->advertising = phydrv->features;
+
+	/* Set the state to READY by default */
+	phydev->state = PHY_READY;
+
+	if (phydev->drv->probe)
+		err = phydev->drv->probe(phydev);
+
+	spin_unlock(&phydev->lock);
+
+	if (err < 0)
+		return err;
+
+	if (phydev->drv->config_init)
+		err = phydev->drv->config_init(phydev);
+
+	return err;
+}
+
+static int phy_remove(struct device *dev)
+{
+	struct phy_device *phydev;
+
+	phydev = to_phy_device(dev);
+
+	spin_lock(&phydev->lock);
+	phydev->state = PHY_DOWN;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->drv->remove)
+		phydev->drv->remove(phydev);
+
+	put_driver(phydev->dev.driver);
+	phydev->drv = NULL;
+
+	return 0;
+}
+
+int phy_driver_register(struct phy_driver *new_driver)
+{
+	int retval;
+
+	memset(&new_driver->driver, 0, sizeof(new_driver->driver));
+	new_driver->driver.name = new_driver->name;
+	new_driver->driver.bus = &mdio_bus_type;
+	new_driver->driver.probe = phy_probe;
+	new_driver->driver.remove = phy_remove;
+
+	retval = driver_register(&new_driver->driver);
+
+	if (retval) {
+		printk(KERN_ERR "%s: Error %d in registering driver\n",
+				new_driver->name, retval);
+
+		return retval;
+	}
+
+	pr_info("%s: Registered new driver\n", new_driver->name);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_driver_register);
+
+void phy_driver_unregister(struct phy_driver *drv)
+{
+	driver_unregister(&drv->driver);
+}
+EXPORT_SYMBOL(phy_driver_unregister);
+
+static struct phy_driver genphy_driver = {
+	.phy_id		= 0xffffffff,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Generic PHY",
+	.config_init	= genphy_config_init,
+	.features	= 0,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver	=	{.owner	= THIS_MODULE, },
+};
+
+static int __init genphy_init(void)
+{
+	return phy_driver_register(&genphy_driver);
+
+}
+
+static void __exit genphy_exit(void)
+{
+	phy_driver_unregister(&genphy_driver);
+}
+
+module_init(genphy_init);
+module_exit(genphy_exit);
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -408,6 +408,8 @@ struct ethtool_ops {
 #define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
+#define SUPPORTED_Pause			(1 << 13)
+#define SUPPORTED_Asym_Pause		(1 << 14)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -423,6 +425,8 @@ struct ethtool_ops {
 #define ADVERTISED_FIBRE		(1 << 10)
 #define ADVERTISED_BNC			(1 << 11)
 #define ADVERTISED_10000baseT_Full	(1 << 12)
+#define ADVERTISED_Pause		(1 << 13)
+#define ADVERTISED_Asym_Pause		(1 << 14)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff --git a/include/linux/mii.h b/include/linux/mii.h
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -22,6 +22,7 @@
 #define MII_EXPANSION       0x06        /* Expansion register          */
 #define MII_CTRL1000        0x09        /* 1000BASE-T control          */
 #define MII_STAT1000        0x0a        /* 1000BASE-T status           */
+#define MII_ESTATUS	    0x0f	/* Extended Status */
 #define MII_DCOUNTER        0x12        /* Disconnect counter          */
 #define MII_FCSCOUNTER      0x13        /* False carrier counter       */
 #define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
@@ -54,7 +55,10 @@
 #define BMSR_ANEGCAPABLE        0x0008  /* Able to do auto-negotiation */
 #define BMSR_RFAULT             0x0010  /* Remote fault detected       */
 #define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
-#define BMSR_RESV               0x07c0  /* Unused...                   */
+#define BMSR_RESV               0x00c0  /* Unused...                   */
+#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
+#define BMSR_100FULL2		0x0200	/* Can do 100BASE-T2 HDX */
+#define BMSR_100HALF2		0x0400	/* Can do 100BASE-T2 FDX */
 #define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
 #define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
 #define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
@@ -113,6 +117,9 @@
 #define EXPANSION_NPCAPABLE     0x0008  /* Link partner supports npage */
 #define EXPANSION_MFAULTS       0x0010  /* Multiple faults detected    */
 #define EXPANSION_RESV          0xffe0  /* Unused...                   */
+
+#define ESTATUS_1000_TFULL	0x2000	/* Can do 1000BT Full */
+#define ESTATUS_1000_THALF	0x1000	/* Can do 1000BT Half */
 
 /* N-way test register. */
 #define NWAYTEST_RESV1          0x00ff  /* Unused...                   */
diff --git a/include/linux/phy.h b/include/linux/phy.h
new file mode 100644
--- /dev/null
+++ b/include/linux/phy.h
@@ -0,0 +1,378 @@
+/*
+ * include/linux/phy.h
+ *
+ * Framework and drivers for configuring and reading different PHYs
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify 
it
+ * under  the terms of  the GNU General  Public License as published by 
the
+ * Free Software Foundation;  either version 2 of the  License, or (at 
your
+ * option) any later version.
+ *
+ */
+
+#ifndef __PHY_H
+#define __PHY_H
+
+#include <linux/spinlock.h>
+#include <linux/device.h>
+
+#define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
+				 SUPPORTED_10baseT_Full | \
+				 SUPPORTED_100baseT_Half | \
+				 SUPPORTED_100baseT_Full | \
+				 SUPPORTED_Autoneg | \
+				 SUPPORTED_TP | \
+				 SUPPORTED_MII)
+
+#define PHY_GBIT_FEATURES	(PHY_BASIC_FEATURES | \
+				 SUPPORTED_1000baseT_Half | \
+				 SUPPORTED_1000baseT_Full)
+
+/* Set phydev->irq to PHY_POLL if interrupts are not supported,
+ * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
+ * the attached driver handles the interrupt
+ */
+#define PHY_POLL		-1
+#define PHY_IGNORE_INTERRUPT	-2
+
+#define PHY_HAS_INTERRUPT	0x00000001
+#define PHY_HAS_MAGICANEG	0x00000002
+
+#define MII_BUS_MAX 4
+
+
+#define PHY_INIT_TIMEOUT 100000
+#define PHY_STATE_TIME		1
+#define PHY_FORCE_TIMEOUT	10
+#define PHY_AN_TIMEOUT		10
+
+#define PHY_MAX_ADDR 32
+
+/* The Bus class for PHYs.  Devices which provide access to
+ * PHYs should register using this structure */
+struct mii_bus {
+	const char *name;
+	int id;
+	void *priv;
+	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
+	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 
val);
+	int (*reset)(struct mii_bus *bus);
+
+	/* A lock to ensure that only one thing can read/write
+	 * the MDIO bus at a time */
+	spinlock_t mdio_lock;
+
+	struct device *dev;
+
+	/* list of all PHYs on bus */
+	struct phy_device *phy_map[PHY_MAX_ADDR];
+
+	/* Pointer to an array of interrupts, each PHY's
+	 * interrupt at the index matching its address */
+	int *irq;
+};
+
+#define PHY_INTERRUPT_DISABLED 0x0
+#define PHY_INTERRUPT_ENABLED 0x80000000
+
+/* PHY state machine states:
+ *
+ * DOWN: PHY device and driver are not ready for anything.  probe
+ * should be called if and only if the PHY is in this state,
+ * given that the PHY device exists.
+ * - PHY driver probe function will, depending on the PHY, set
+ * the state to STARTING or READY
+ *
+ * STARTING:  PHY device is coming up, and the ethernet driver is
+ * not ready.  PHY drivers may set this in the probe function.
+ * If they do, they are responsible for making sure the state is
+ * eventually set to indicate whether the PHY is UP or READY,
+ * depending on the state when the PHY is done starting up.
+ * - PHY driver will set the state to READY
+ * - start will set the state to PENDING
+ *
+ * READY: PHY is ready to send and receive packets, but the
+ * controller is not.  By default, PHYs which do not implement
+ * probe will be set to this state by phy_probe().  If the PHY
+ * driver knows the PHY is ready, and the PHY state is STARTING,
+ * then it sets this STATE.
+ * - start will set the state to UP
+ *
+ * PENDING: PHY device is coming up, but the ethernet driver is
+ * ready.  phy_start will set this state if the PHY state is
+ * STARTING.
+ * - PHY driver will set the state to UP when the PHY is ready
+ *
+ * UP: The PHY and attached device are ready to do work.
+ * Interrupts should be started here.
+ * - timer moves to AN
+ *
+ * AN: The PHY is currently negotiating the link state.  Link is
+ * therefore down for now.  phy_timer will set this state when it
+ * detects the state is UP.  config_aneg will set this state
+ * whenever called with phydev->autoneg set to AUTONEG_ENABLE.
+ * - If autonegotiation finishes, but there's no link, it sets
+ *   the state to NOLINK.
+ * - If aneg finishes with link, it sets the state to RUNNING,
+ *   and calls adjust_link
+ * - If autonegotiation did not finish after an arbitrary amount
+ *   of time, autonegotiation should be tried again if the PHY
+ *   supports "magic" autonegotiation (back to AN)
+ * - If it didn't finish, and no magic_aneg, move to FORCING.
+ *
+ * NOLINK: PHY is up, but not currently plugged in.
+ * - If the timer notes that the link comes back, we move to RUNNING
+ * - config_aneg moves to AN
+ * - phy_stop moves to HALTED
+ *
+ * FORCING: PHY is being configured with forced settings
+ * - if link is up, move to RUNNING
+ * - If link is down, we drop to the next highest setting, and
+ *   retry (FORCING) after a timeout
+ * - phy_stop moves to HALTED
+ *
+ * RUNNING: PHY is currently up, running, and possibly sending
+ * and/or receiving packets
+ * - timer will set CHANGELINK if we're polling (this ensures the
+ *   link state is polled every other cycle of this state machine,
+ *   which makes it every other second)
+ * - irq will set CHANGELINK
+ * - config_aneg will set AN
+ * - phy_stop moves to HALTED
+ *
+ * CHANGELINK: PHY experienced a change in link state
+ * - timer moves to RUNNING if link
+ * - timer moves to NOLINK if the link is down
+ * - phy_stop moves to HALTED
+ *
+ * HALTED: PHY is up, but no polling or interrupts are done. Or
+ * PHY is in an error state.
+ *
+ * - phy_start moves to RESUMING
+ *
+ * RESUMING: PHY was halted, but now wants to run again.
+ * - If we are forcing, or aneg is done, timer moves to RUNNING
+ * - If aneg is not done, timer moves to AN
+ * - phy_stop moves to HALTED
+ */
+enum phy_state {
+	PHY_DOWN=0,
+	PHY_STARTING,
+	PHY_READY,
+	PHY_PENDING,
+	PHY_UP,
+	PHY_AN,
+	PHY_RUNNING,
+	PHY_NOLINK,
+	PHY_FORCING,
+	PHY_CHANGELINK,
+	PHY_HALTED,
+	PHY_RESUMING
+};
+
+/* phy_device: An instance of a PHY
+ *
+ * drv: Pointer to the driver for this PHY instance
+ * bus: Pointer to the bus this PHY is on
+ * dev: driver model device structure for this PHY
+ * phy_id: UID for this device found during discovery
+ * state: state of the PHY for management purposes
+ * dev_flags: Device-specific flags used by the PHY driver.
+ * addr: Bus address of PHY
+ * link_timeout: The number of timer firings to wait before the
+ * giving up on the current attempt at acquiring a link
+ * irq: IRQ number of the PHY's interrupt (-1 if none)
+ * phy_timer: The timer for handling the state machine
+ * phy_queue: A work_queue for the interrupt
+ * attached_dev: The attached enet driver's device instance ptr
+ * adjust_link: Callback for the enet controller to respond to
+ * changes in the link state.
+ * adjust_state: Callback for the enet driver to respond to
+ * changes in the state machine.
+ *
+ * speed, duplex, pause, supported, advertising, and
+ * autoneg are used like in mii_if_info
+ *
+ * interrupts currently only supports enabled or disabled,
+ * but could be changed in the future to support enabling
+ * and disabling specific interrupts
+ *
+ * Contains some infrastructure for polling and interrupt
+ * handling, as well as handling shifts in PHY hardware state
+ */
+struct phy_device {
+	/* Information about the PHY type */
+	/* And management functions */
+	struct phy_driver *drv;
+
+	struct mii_bus *bus;
+
+	struct device dev;
+
+	u32 phy_id;
+
+	enum phy_state state;
+
+	u32 dev_flags;
+
+	/* Bus address of the PHY (0-32) */
+	int addr;
+
+	/* forced speed & duplex (no autoneg)
+	 * partner speed & duplex & pause (autoneg)
+	 */
+	int speed;
+	int duplex;
+	int pause;
+	int asym_pause;
+
+	/* The most recently read link state */
+	int link;
+
+	/* Enabled Interrupts */
+	u32 interrupts;
+
+	/* Union of PHY and Attached devices' supported modes */
+	/* See mii.h for more info */
+	u32 supported;
+	u32 advertising;
+
+	int autoneg;
+
+	int link_timeout;
+
+	/* Interrupt number for this PHY
+	 * -1 means no interrupt */
+	int irq;
+
+	/* private data pointer */
+	/* For use by PHYs to maintain extra state */
+	void *priv;
+
+	/* Interrupt and Polling infrastructure */
+	struct work_struct phy_queue;
+	struct timer_list phy_timer;
+
+	spinlock_t lock;
+
+	struct net_device *attached_dev;
+
+	void (*adjust_link)(struct net_device *dev);
+
+	void (*adjust_state)(struct net_device *dev);
+};
+#define to_phy_device(d) container_of(d, struct phy_device, dev)
+
+/* struct phy_driver: Driver structure for a particular PHY type
+ *
+ * phy_id: The result of reading the UID registers of this PHY
+ *   type, and ANDing them with the phy_id_mask.  This driver
+ *   only works for PHYs with IDs which match this field
+ * name: The friendly name of this PHY type
+ * phy_id_mask: Defines the important bits of the phy_id
+ * features: A list of features (speed, duplex, etc) supported
+ *   by this PHY
+ * flags: A bitfield defining certain other features this PHY
+ *   supports (like interrupts)
+ *
+ * The drivers must implement config_aneg and read_status.  All
+ * other functions are optional. Note that none of these
+ * functions should be called from interrupt time.  The goal is
+ * for the bus read/write functions to be able to block when the
+ * bus transaction is happening, and be freed up by an interrupt
+ * (The MPC85xx has this ability, though it is not currently
+ * supported in the driver).
+ */
+struct phy_driver {
+	u32 phy_id;
+	char *name;
+	unsigned int phy_id_mask;
+	u32 features;
+	u32 flags;
+
+	/* Called to initialize the PHY,
+	 * including after a reset */
+	int (*config_init)(struct phy_device *phydev);
+
+	/* Called during discovery.  Used to set
+	 * up device-specific structures, if any */
+	int (*probe)(struct phy_device *phydev);
+
+	/* PHY Power Management */
+	int (*suspend)(struct phy_device *phydev);
+	int (*resume)(struct phy_device *phydev);
+
+	/* Configures the advertisement and resets
+	 * autonegotiation if phydev->autoneg is on,
+	 * forces the speed to the current settings in phydev
+	 * if phydev->autoneg is off */
+	int (*config_aneg)(struct phy_device *phydev);
+
+	/* Determines the negotiated speed and duplex */
+	int (*read_status)(struct phy_device *phydev);
+
+	/* Clears any pending interrupts */
+	int (*ack_interrupt)(struct phy_device *phydev);
+
+	/* Enables or disables interrupts */
+	int (*config_intr)(struct phy_device *phydev);
+
+	/* Clears up any memory if needed */
+	void (*remove)(struct phy_device *phydev);
+
+	struct device_driver driver;
+};
+#define to_phy_driver(d) container_of(d, struct phy_driver, driver)
+
+int phy_read(struct phy_device *phydev, u16 regnum);
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+struct phy_device* get_phy_device(struct mii_bus *bus, uint addr);
+int phy_clear_interrupt(struct phy_device *phydev);
+int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+struct phy_device * phy_attach(struct net_device *dev,
+		const char *phy_id, u32 flags);
+struct phy_device * phy_connect(struct net_device *dev, const char 
*phy_id,
+		void (*handler)(struct net_device *), u32 flags);
+void phy_disconnect(struct phy_device *phydev);
+void phy_detach(struct phy_device *phydev);
+void phy_start(struct phy_device *phydev);
+void phy_stop(struct phy_device *phydev);
+int phy_start_aneg(struct phy_device *phydev);
+
+int mdiobus_register(struct mii_bus *bus);
+void mdiobus_unregister(struct mii_bus *bus);
+void phy_sanitize_settings(struct phy_device *phydev);
+int phy_stop_interrupts(struct phy_device *phydev);
+
+static inline int phy_read_status(struct phy_device *phydev) {
+	return phydev->drv->read_status(phydev);
+}
+
+int genphy_config_advert(struct phy_device *phydev);
+int genphy_setup_forced(struct phy_device *phydev);
+int genphy_restart_aneg(struct phy_device *phydev);
+int genphy_config_aneg(struct phy_device *phydev);
+int genphy_update_link(struct phy_device *phydev);
+int genphy_read_status(struct phy_device *phydev);
+void phy_driver_unregister(struct phy_driver *drv);
+int phy_driver_register(struct phy_driver *new_driver);
+void phy_prepare_link(struct phy_device *phydev,
+		void (*adjust_link)(struct net_device *));
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct net_device *));
+void phy_stop_machine(struct phy_device *phydev);
+int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+int phy_mii_ioctl(struct phy_device *phydev,
+		struct mii_ioctl_data *mii_data, int cmd);
+int phy_start_interrupts(struct phy_device *phydev);
+void phy_print_status(struct phy_device *phydev);
+
+extern struct bus_type mdio_bus_type;
+extern struct phy_driver genphy_driver;
+#endif /* __PHY_H */
