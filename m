From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 07/17] phy: Unify PHY reset, initialization, and fixup handling
Date: Thu, 20 Oct 2011 17:00:14 -0400
Message-ID: <1319144425-15547-8-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Decotigny <decot@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mike Frysinger <vapier@gentoo.org>, linux-doc@vger.kernel.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whenever the BMCR_RESET bit is set (in the MII_BMCR register), the
IEEE standards say we MUST poll until it is cleared, which may take up
to 0.5s.  Failing to do so may result in MDIO bus errors or ignored
register writes.  Furthermore, some chips require a little extra time
*after* the bit is cleared before they will work correctly.

This modifies the phy_init_hw() helper function to perform the necessary
full-reset followed by scans of board-specific and driver-specific fixups,
then ensures that phy_init_hw() is called everywhere necessary.

Since some of the fixups must be the first thing run after reset, all
ethernet drivers should call phy_init_hw() to set things up instead of
setting BMCR_RESET by hand.

NOTE: I'm pretty sure the locking is wrong here, it's on my TODO list.

Not-yet-Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 Documentation/networking/phy.txt |    5 +-
 drivers/net/phy/phy.c            |   20 ++++--
 drivers/net/phy/phy_device.c     |  132 +++++++++++++++++++++++++++-----------
 include/linux/phy.h              |    1 -
 4 files changed, 111 insertions(+), 47 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 62f890e..0db8c81 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -251,15 +251,16 @@ Writing a PHY driver
 
  Each driver consists of a number of function pointers:
 
+   probe: Allocate phy->priv, optionally refuse to bind.
+     PHY may not have been reset or had fixups run yet.
    config_init: configures PHY into a sane state after a reset.
      For instance, a Davicom PHY requires descrambling disabled.
-   probe: Does any setup needed by the driver
    suspend/resume: power management
    config_aneg: Changes the speed/duplex/negotiation settings
    read_status: Reads the current speed/duplex/negotiation settings
    ack_interrupt: Clear a pending interrupt
    config_intr: Enable or disable interrupts
-   remove: Does any driver take-down
+   remove: Free phy->priv and clean up driver state
 
  All of these functions are optional.  It is strongly preferred to use the
  generic phy driver's versions of these two functions if at all possible:
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index cc7f353..c378f91 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -354,14 +354,20 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		}
 
 		mdiobus_write(phydev->bus, mii_data->phy_id,
-			      mii_data->reg_num, val);
+				mii_data->reg_num, val);
+
+		/*
+		 * If they wanted to reset the PHY, then this needs to also
+		 * wait for the reset to complete. or later MDIO cycles may
+		 * fail with errors.
+		 *
+		 * NOTE: This interface is for debug only, and therefore it
+		 * will NOT rerun board or driver initialization.
+		 */
+		if ((mii_data->reg_num == MII_BMCR) && (val & BMCR_RESET)
+				&& (mii_data->phy_id == phydev->addr))
+			phy_poll_reset(phydev);
 
-		if (mii_data->reg_num == MII_BMCR &&
-		    val & BMCR_RESET &&
-		    phydev->drv->config_init) {
-			phy_scan_fixups(phydev);
-			phydev->drv->config_init(phydev);
-		}
 		break;
 
 	case SIOCSHWTSTAMP:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8990e87..fc0f315 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -125,30 +125,6 @@ static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup *fixup)
 	return 1;
 }
 
-/* Runs any matching fixups for this phydev */
-int phy_scan_fixups(struct phy_device *phydev)
-{
-	struct phy_fixup *fixup;
-
-	mutex_lock(&phy_fixup_lock);
-	list_for_each_entry(fixup, &phy_fixup_list, list) {
-		if (phy_needs_fixup(phydev, fixup)) {
-			int err;
-
-			err = fixup->run(phydev);
-
-			if (err < 0) {
-				mutex_unlock(&phy_fixup_lock);
-				return err;
-			}
-		}
-	}
-	mutex_unlock(&phy_fixup_lock);
-
-	return 0;
-}
-EXPORT_SYMBOL(phy_scan_fixups);
-
 static struct phy_device* phy_device_create(struct mii_bus *bus,
 					    int addr, int phy_id)
 {
@@ -274,12 +250,18 @@ int phy_device_register(struct phy_device *phydev)
 		return -EINVAL;
 	phydev->bus->phy_map[phydev->addr] = phydev;
 
-	/* Run all of the fixups for this PHY */
-	phy_scan_fixups(phydev);
+	/* Reset and reinitialize the PHY */
+	err = phy_init_hw(phydev);
+	if (err) {
+		dev_err(phydev->dev.parent, "phy %d failed to init: %d\n",
+				phydev->addr, err);
+		goto out;
+	}
 
 	err = device_register(&phydev->dev);
 	if (err) {
-		pr_err("phy %d failed to register\n", phydev->addr);
+		dev_err(phydev->dev.parent, "phy %d failed to register: %d\n",
+				phydev->addr, err);
 		goto out;
 	}
 
@@ -380,7 +362,7 @@ struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 	 * PHY with the requested name */
 	d = bus_find_device_by_name(&mdio_bus_type, NULL, bus_id);
 	if (!d) {
-		pr_err("PHY %s not found\n", bus_id);
+		dev_err(&dev->dev, "PHY %s not found\n", bus_id);
 		return ERR_PTR(-ENODEV);
 	}
 	phydev = to_phy_device(d);
@@ -410,19 +392,93 @@ void phy_disconnect(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_disconnect);
 
-int phy_init_hw(struct phy_device *phydev)
+/**
+ * phy_poll_reset - Safely wait until a PHY reset has properly completed
+ * @phydev: The PHY device to poll
+ *
+ * Description: According to IEEE 802.3, Section 2, Subsection 22.2.4.1.1, as
+ *   published in 2008, a PHY reset may take up to 0.5 seconds.  The MII BMCR
+ *   register must be polled until the BMCR_RESET bit clears.
+ *
+ *   Furthermore, any attempts to write to PHY registers may have no effect
+ *   or even generate MDIO bus errors until this is complete.
+ *
+ *   Some PHYs (such as the Marvell 88E1111) don't entirely conform to the
+ *   standard and do not fully reset after the BMCR_RESET bit is set, and may
+ *   even *REQUIRE* a soft-reset to properly restart autonegotiation.  In an
+ *   effort to support such broken PHYs, this function is separate from the
+ *   standard phy_init_hw() which will zero all the other bits in the BMCR
+ *   and reapply all driver-specific and board-specific fixups.
+ */
+int phy_poll_reset(struct phy_device *phydev)
 {
+	/* Poll until the reset bit clears (50ms per retry == 0.6 sec) */
+	unsigned int retries = 12;
 	int ret;
+	do {
+		msleep(50);
+		ret = phy_read(phydev, MII_BMCR);
+		if (ret < 0)
+			return ret;
+	} while (ret & BMCR_RESET && --retries);
+	if (ret & BMCR_RESET)
+		return -ETIMEDOUT;
+
+	/*
+	 * Some chips (smsc911x) may still need up to another 1ms after the
+	 * BMCR_RESET bit is cleared before they are usable.
+	 */
+	msleep(1);
+	return 0;
+}
 
-	if (!phydev->drv || !phydev->drv->config_init)
-		return 0;
+/**
+ * phy_init_hw - Fully reinitialize a PHY and apply board and driver fixups
+ * @phydev: the PHY device to reset
+ *
+ * Description: Reset the specified PHY using the BMCR_RESET bit, clearing
+ *   all of the other bits in the BMCR.  On standards-compliant PHYs this
+ *   should also restore all other registers to power-on defaults.
+ *
+ *   In addition, this will automatically run any board-specific and
+ *   driver-specific fixups.
+ */
+int phy_init_hw(struct phy_device *phydev)
+{
+	struct phy_fixup *fixup;
 
-	ret = phy_scan_fixups(phydev);
+	/* Always perform a reset first */
+	int ret = phy_write(phydev, MII_BMCR, BMCR_RESET);
 	if (ret < 0)
 		return ret;
 
-	return phydev->drv->config_init(phydev);
+	/* Now wait for the reset to complete */
+	ret = phy_poll_reset(phydev);
+	if (ret < 0)
+		return ret;
+
+	/* Scan board-specific PHY fixups */
+	mutex_lock(&phy_fixup_lock);
+	list_for_each_entry(fixup, &phy_fixup_list, list) {
+		if (!phy_needs_fixup(phydev, fixup))
+			continue;
+
+		ret = fixup->run(phydev);
+		if (ret < 0)
+			break;
+	}
+	mutex_unlock(&phy_fixup_lock);
+	if (ret < 0)
+		return ret;
+
+	/* Now driver-specific initialization */
+	ret = 0;
+	if (phydev->drv && phydev->drv->config_init)
+		ret = phydev->drv->config_init(phydev);
+
+	return ret;
 }
+EXPORT_SYMBOL(phy_init_hw);
 
 /**
  * phy_attach_direct - attach a network device to a given PHY device pointer
@@ -471,9 +527,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->state = PHY_READY;
 
-	/* Do initial configuration here, now that
-	 * we have certain key parameters
-	 * (dev_flags and interface) */
+	/*
+	 * The PHY was already reset and initialize when it was first probed,
+	 * but we just set the dev_flags and interface fields, so the driver
+	 * may need to re-initialize things again to take those into account.
+	 */
 	err = phy_init_hw(phydev);
 	if (err)
 		phy_detach(phydev);
@@ -503,7 +561,7 @@ struct phy_device *phy_attach(struct net_device *dev,
 	 * PHY with the requested name */
 	d = bus_find_device_by_name(bus, NULL, bus_id);
 	if (!d) {
-		pr_err("PHY %s not found\n", bus_id);
+		dev_err(&dev->dev, "PHY %s not found\n", bus_id);
 		return ERR_PTR(-ENODEV);
 	}
 	phydev = to_phy_device(d);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c6bbb38..f07fc1c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -526,7 +526,6 @@ int phy_register_fixup_for_id(const char *bus_id,
 		int (*run)(struct phy_device *));
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
-int phy_scan_fixups(struct phy_device *phydev);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
-- 
1.7.2.5
