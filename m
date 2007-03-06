From: akpm@linux-foundation.org
Subject: [patch 04/19] phy layer: add kernel-doc + DocBook
Date: Tue, 06 Mar 2007 02:41:48 -0800
Message-ID: <200703061041.l26Afnc4019743@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34699 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934066AbXCFKmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:36 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Convert function documentation in drivers/net/phy/ to kernel-doc
and add it to DocBook.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/DocBook/kernel-api.tmpl |    6 
 drivers/net/phy/mdio_bus.c            |   19 +-
 drivers/net/phy/phy.c                 |  192 +++++++++++++++++-------
 drivers/net/phy/phy_device.c          |  114 +++++++++-----
 4 files changed, 234 insertions(+), 97 deletions(-)

diff -puN Documentation/DocBook/kernel-api.tmpl~phy-layer-add-kernel-doc-docbook Documentation/DocBook/kernel-api.tmpl
--- a/Documentation/DocBook/kernel-api.tmpl~phy-layer-add-kernel-doc-docbook
+++ a/Documentation/DocBook/kernel-api.tmpl
@@ -236,6 +236,12 @@ X!Ilib/string.c
 !Enet/core/dev.c
 !Enet/ethernet/eth.c
 !Iinclude/linux/etherdevice.h
+!Edrivers/net/phy/phy.c
+!Idrivers/net/phy/phy.c
+!Edrivers/net/phy/phy_device.c
+!Idrivers/net/phy/phy_device.c
+!Edrivers/net/phy/mdio_bus.c
+!Idrivers/net/phy/mdio_bus.c
 <!-- FIXME: Removed for now since no structured comments in source
 X!Enet/core/wireless.c
 -->
diff -puN drivers/net/phy/mdio_bus.c~phy-layer-add-kernel-doc-docbook drivers/net/phy/mdio_bus.c
--- a/drivers/net/phy/mdio_bus.c~phy-layer-add-kernel-doc-docbook
+++ a/drivers/net/phy/mdio_bus.c
@@ -35,10 +35,14 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-/* mdiobus_register 
+/**
+ * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
+ * @bus: target mii_bus
  *
- * description: Called by a bus driver to bring up all the PHYs
- *   on a given bus, and attach them to the bus
+ * Description: Called by a bus driver to bring up all the PHYs
+ *   on a given bus, and attach them to the bus.
+ *
+ * Returns 0 on success or < 0 on error.
  */
 int mdiobus_register(struct mii_bus *bus)
 {
@@ -114,10 +118,13 @@ void mdiobus_unregister(struct mii_bus *
 }
 EXPORT_SYMBOL(mdiobus_unregister);
 
-/* mdio_bus_match
+/**
+ * mdio_bus_match - determine if given PHY driver supports the given PHY device
+ * @dev: target PHY device
+ * @drv: given PHY driver
  *
- * description: Given a PHY device, and a PHY driver, return 1 if
- *   the driver supports the device.  Otherwise, return 0
+ * Description: Given a PHY device, and a PHY driver, return 1 if
+ *   the driver supports the device.  Otherwise, return 0.
  */
 static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 {
diff -puN drivers/net/phy/phy.c~phy-layer-add-kernel-doc-docbook drivers/net/phy/phy.c
--- a/drivers/net/phy/phy.c~phy-layer-add-kernel-doc-docbook
+++ a/drivers/net/phy/phy.c
@@ -39,7 +39,9 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-/* Convenience function to print out the current phy status
+/**
+ * phy_print_status - Convenience function to print out the current phy status
+ * @phydev: the phy_device struct
  */
 void phy_print_status(struct phy_device *phydev)
 {
@@ -55,10 +57,15 @@ void phy_print_status(struct phy_device 
 EXPORT_SYMBOL(phy_print_status);
 
 
-/* Convenience functions for reading/writing a given PHY
- * register. They MUST NOT be called from interrupt context,
+/**
+ * phy_read - Convenience function for reading a given PHY register
+ * @phydev: the phy_device struct
+ * @regnum: register number to read
+ *
+ * NOTE: MUST NOT be called from interrupt context,
  * because the bus read/write functions may wait for an interrupt
- * to conclude the operation. */
+ * to conclude the operation.
+ */
 int phy_read(struct phy_device *phydev, u16 regnum)
 {
 	int retval;
@@ -72,6 +79,16 @@ int phy_read(struct phy_device *phydev, 
 }
 EXPORT_SYMBOL(phy_read);
 
+/**
+ * phy_write - Convenience function for writing a given PHY register
+ * @phydev: the phy_device struct
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
 {
 	int err;
@@ -85,7 +102,15 @@ int phy_write(struct phy_device *phydev,
 }
 EXPORT_SYMBOL(phy_write);
 
-
+/**
+ * phy_clear_interrupt - Ack the phy device's interrupt
+ * @phydev: the phy_device struct
+ *
+ * If the @phydev driver has an ack_interrupt function, call it to
+ * ack and clear the phy device's interrupt.
+ *
+ * Returns 0 on success on < 0 on error.
+ */
 int phy_clear_interrupt(struct phy_device *phydev)
 {
 	int err = 0;
@@ -96,7 +121,13 @@ int phy_clear_interrupt(struct phy_devic
 	return err;
 }
 
-
+/**
+ * phy_config_interrupt - configure the PHY device for the requested interrupts
+ * @phydev: the phy_device struct
+ * @interrupts: interrupt flags to configure for this @phydev
+ *
+ * Returns 0 on success on < 0 on error.
+ */
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
 {
 	int err = 0;
@@ -109,9 +140,11 @@ int phy_config_interrupt(struct phy_devi
 }
 
 
-/* phy_aneg_done
+/**
+ * phy_aneg_done - return auto-negotiation status
+ * @phydev: target phy_device struct
  *
- * description: Reads the status register and returns 0 either if
+ * Description: Reads the status register and returns 0 either if
  *   auto-negotiation is incomplete, or if there was an error.
  *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
  */
@@ -173,9 +206,12 @@ static const struct phy_setting settings
 
 #define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))
 
-/* phy_find_setting
+/**
+ * phy_find_setting - find a PHY settings array entry that matches speed & duplex
+ * @speed: speed to match
+ * @duplex: duplex to match
  *
- * description: Searches the settings array for the setting which
+ * Description: Searches the settings array for the setting which
  *   matches the desired speed and duplex, and returns the index
  *   of that setting.  Returns the index of the last setting if
  *   none of the others match.
@@ -192,11 +228,12 @@ static inline int phy_find_setting(int s
 	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
 }
 
-/* phy_find_valid
- * idx: The first index in settings[] to search
- * features: A mask of the valid settings
+/**
+ * phy_find_valid - find a PHY setting that matches the requested features mask
+ * @idx: The first index in settings[] to search
+ * @features: A mask of the valid settings
  *
- * description: Returns the index of the first valid setting less
+ * Description: Returns the index of the first valid setting less
  *   than or equal to the one pointed to by idx, as determined by
  *   the mask in features.  Returns the index of the last setting
  *   if nothing else matches.
@@ -209,11 +246,13 @@ static inline int phy_find_valid(int idx
 	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
 }
 
-/* phy_sanitize_settings
+/**
+ * phy_sanitize_settings - make sure the PHY is set to supported speed and duplex
+ * @phydev: the target phy_device struct
  *
- * description: Make sure the PHY is set to supported speeds and
+ * Description: Make sure the PHY is set to supported speeds and
  *   duplexes.  Drop down by one in this order:  1000/FULL,
- *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF
+ *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF.
  */
 void phy_sanitize_settings(struct phy_device *phydev)
 {
@@ -232,16 +271,17 @@ void phy_sanitize_settings(struct phy_de
 }
 EXPORT_SYMBOL(phy_sanitize_settings);
 
-/* phy_ethtool_sset:
- * A generic ethtool sset function.  Handles all the details
+/**
+ * phy_ethtool_sset - generic ethtool sset function, handles all the details
+ * @phydev: target phy_device struct
+ * @cmd: ethtool_cmd
  *
  * A few notes about parameter checking:
  * - We don't set port or transceiver, so we don't care what they
  *   were set to.
  * - phy_start_aneg() will make sure forced settings are sane, and
  *   choose the next best ones from the ones selected, so we don't
- *   care if ethtool tries to give us bad values
- *
+ *   care if ethtool tries to give us bad values.
  */
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
@@ -304,9 +344,15 @@ int phy_ethtool_gset(struct phy_device *
 }
 EXPORT_SYMBOL(phy_ethtool_gset);
 
-/* Note that this function is currently incompatible with the
+/**
+ * phy_mii_ioctl - generic PHY MII ioctl interface
+ * @phydev: the phy_device struct
+ * @mii_data: MII ioctl data
+ * @cmd: ioctl cmd to execute
+ *
+ * Note that this function is currently incompatible with the
  * PHYCONTROL layer.  It changes registers without regard to
- * current state.  Use at own risk
+ * current state.  Use at own risk.
  */
 int phy_mii_ioctl(struct phy_device *phydev,
 		struct mii_ioctl_data *mii_data, int cmd)
@@ -358,13 +404,14 @@ int phy_mii_ioctl(struct phy_device *phy
 	return 0;
 }
 
-/* phy_start_aneg
- *
- * description: Sanitizes the settings (if we're not
- *   autonegotiating them), and then calls the driver's
- *   config_aneg function.  If the PHYCONTROL Layer is operating,
- *   we change the state to reflect the beginning of
- *   Auto-negotiation or forcing.
+/**
+ * phy_start_aneg - start auto-negotiation for this PHY device
+ * @phydev: the phy_device struct
+ *
+ * Description: Sanitizes the settings (if we're not autonegotiating
+ *   them), and then calls the driver's config_aneg function.
+ *   If the PHYCONTROL Layer is operating, we change the state to
+ *   reflect the beginning of Auto-negotiation or forcing.
  */
 int phy_start_aneg(struct phy_device *phydev)
 {
@@ -400,15 +447,19 @@ EXPORT_SYMBOL(phy_start_aneg);
 static void phy_change(struct work_struct *work);
 static void phy_timer(unsigned long data);
 
-/* phy_start_machine:
+/**
+ * phy_start_machine - start PHY state machine tracking
+ * @phydev: the phy_device struct
+ * @handler: callback function for state change notifications
  *
- * description: The PHY infrastructure can run a state machine
+ * Description: The PHY infrastructure can run a state machine
  *   which tracks whether the PHY is starting up, negotiating,
  *   etc.  This function starts the timer which tracks the state
- *   of the PHY.  If you want to be notified when the state
- *   changes, pass in the callback, otherwise, pass NULL.  If you
+ *   of the PHY.  If you want to be notified when the state changes,
+ *   pass in the callback @handler, otherwise, pass NULL.  If you
  *   want to maintain your own state machine, do not call this
- *   function. */
+ *   function.
+ */
 void phy_start_machine(struct phy_device *phydev,
 		void (*handler)(struct net_device *))
 {
@@ -420,9 +471,11 @@ void phy_start_machine(struct phy_device
 	mod_timer(&phydev->phy_timer, jiffies + HZ);
 }
 
-/* phy_stop_machine
+/**
+ * phy_stop_machine - stop the PHY state machine tracking
+ * @phydev: target phy_device struct
  *
- * description: Stops the state machine timer, sets the state to UP
+ * Description: Stops the state machine timer, sets the state to UP
  *   (unless it wasn't up yet). This function must be called BEFORE
  *   phy_detach.
  */
@@ -438,12 +491,14 @@ void phy_stop_machine(struct phy_device 
 	phydev->adjust_state = NULL;
 }
 
-/* phy_force_reduction
- *
- * description: Reduces the speed/duplex settings by
- *   one notch.  The order is so:
- *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF,
- *   10/FULL, 10/HALF.  The function bottoms out at 10/HALF.
+/**
+ * phy_force_reduction - reduce PHY speed/duplex settings by one step
+ * @phydev: target phy_device struct
+ *
+ * Description: Reduces the speed/duplex settings by one notch,
+ *   in this order--
+ *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF.
+ *   The function bottoms out at 10/HALF.
  */
 static void phy_force_reduction(struct phy_device *phydev)
 {
@@ -464,7 +519,9 @@ static void phy_force_reduction(struct p
 }
 
 
-/* phy_error:
+/**
+ * phy_error - enter HALTED state for this PHY device
+ * @phydev: target phy_device struct
  *
  * Moves the PHY to the HALTED state in response to a read
  * or write error, and tells the controller the link is down.
@@ -478,9 +535,12 @@ void phy_error(struct phy_device *phydev
 	spin_unlock(&phydev->lock);
 }
 
-/* phy_interrupt
+/**
+ * phy_interrupt - PHY interrupt handler
+ * @irq: interrupt line
+ * @phy_dat: phy_device pointer
  *
- * description: When a PHY interrupt occurs, the handler disables
+ * Description: When a PHY interrupt occurs, the handler disables
  * interrupts, and schedules a work task to clear the interrupt.
  */
 static irqreturn_t phy_interrupt(int irq, void *phy_dat)
@@ -501,7 +561,10 @@ static irqreturn_t phy_interrupt(int irq
 	return IRQ_HANDLED;
 }
 
-/* Enable the interrupts from the PHY side */
+/**
+ * phy_enable_interrupts - Enable the interrupts from the PHY side
+ * @phydev: target phy_device struct
+ */
 int phy_enable_interrupts(struct phy_device *phydev)
 {
 	int err;
@@ -517,7 +580,10 @@ int phy_enable_interrupts(struct phy_dev
 }
 EXPORT_SYMBOL(phy_enable_interrupts);
 
-/* Disable the PHY interrupts from the PHY side */
+/**
+ * phy_disable_interrupts - Disable the PHY interrupts from the PHY side
+ * @phydev: target phy_device struct
+ */
 int phy_disable_interrupts(struct phy_device *phydev)
 {
 	int err;
@@ -543,13 +609,15 @@ phy_err:
 }
 EXPORT_SYMBOL(phy_disable_interrupts);
 
-/* phy_start_interrupts
+/**
+ * phy_start_interrupts - request and enable interrupts for a PHY device
+ * @phydev: target phy_device struct
  *
- * description: Request the interrupt for the given PHY.  If
- *   this fails, then we set irq to PHY_POLL.
+ * Description: Request the interrupt for the given PHY.
+ *   If this fails, then we set irq to PHY_POLL.
  *   Otherwise, we enable the interrupts in the PHY.
- *   Returns 0 on success.
  *   This should only be called with a valid IRQ number.
+ *   Returns 0 on success or < 0 on error.
  */
 int phy_start_interrupts(struct phy_device *phydev)
 {
@@ -574,6 +642,10 @@ int phy_start_interrupts(struct phy_devi
 }
 EXPORT_SYMBOL(phy_start_interrupts);
 
+/**
+ * phy_stop_interrupts - disable interrupts from a PHY device
+ * @phydev: target phy_device struct
+ */
 int phy_stop_interrupts(struct phy_device *phydev)
 {
 	int err;
@@ -596,7 +668,10 @@ int phy_stop_interrupts(struct phy_devic
 EXPORT_SYMBOL(phy_stop_interrupts);
 
 
-/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+/**
+ * phy_change - Scheduled by the phy_interrupt/timer to handle PHY changes
+ * @work: work_struct that describes the work to be done
+ */
 static void phy_change(struct work_struct *work)
 {
 	int err;
@@ -630,7 +705,10 @@ phy_err:
 	phy_error(phydev);
 }
 
-/* Bring down the PHY link, and stop checking the status. */
+/**
+ * phy_stop - Bring down the PHY link, and stop checking the status
+ * @phydev: target phy_device struct
+ */
 void phy_stop(struct phy_device *phydev)
 {
 	spin_lock(&phydev->lock);
@@ -659,9 +737,11 @@ out_unlock:
 }
 
 
-/* phy_start
+/**
+ * phy_start - start or restart a PHY device
+ * @phydev: target phy_device struct
  *
- * description: Indicates the attached device's readiness to
+ * Description: Indicates the attached device's readiness to
  *   handle PHY-related work.  Used during startup to start the
  *   PHY, and after a call to phy_stop() to resume operation.
  *   Also used to indicate the MDIO bus has cleared an error
diff -puN drivers/net/phy/phy_device.c~phy-layer-add-kernel-doc-docbook drivers/net/phy/phy_device.c
--- a/drivers/net/phy/phy_device.c~phy-layer-add-kernel-doc-docbook
+++ a/drivers/net/phy/phy_device.c
@@ -74,11 +74,13 @@ struct phy_device* phy_device_create(str
 }
 EXPORT_SYMBOL(phy_device_create);
 
-/* get_phy_device
+/**
+ * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * @bus: the target MII bus
+ * @addr: PHY address on the MII bus
  *
- * description: Reads the ID registers of the PHY at addr on the
- *   bus, then allocates and returns the phy_device to
- *   represent it.
+ * Description: Reads the ID registers of the PHY at @addr on the
+ *   @bus, then allocates and returns the phy_device to represent it.
  */
 struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 {
@@ -112,23 +114,33 @@ struct phy_device * get_phy_device(struc
 	return dev;
 }
 
-/* phy_prepare_link:
+/**
+ * phy_prepare_link - prepares the PHY layer to monitor link status
+ * @phydev: target phy_device struct
+ * @handler: callback function for link status change notifications
  *
- * description: Tells the PHY infrastructure to handle the
+ * Description: Tells the PHY infrastructure to handle the
  *   gory details on monitoring link status (whether through
  *   polling or an interrupt), and to call back to the
  *   connected device driver when the link status changes.
  *   If you want to monitor your own link state, don't call
- *   this function */
+ *   this function.
+ */
 void phy_prepare_link(struct phy_device *phydev,
 		void (*handler)(struct net_device *))
 {
 	phydev->adjust_link = handler;
 }
 
-/* phy_connect:
+/**
+ * phy_connect - connect an ethernet device to a PHY device
+ * @dev: the network device to connect
+ * @phy_id: the PHY device to connect
+ * @handler: callback function for state change notifications
+ * @flags: PHY device's dev_flags
+ * @interface: PHY device's interface
  *
- * description: Convenience function for connecting ethernet
+ * Description: Convenience function for connecting ethernet
  *   devices to PHY devices.  The default behavior is for
  *   the PHY infrastructure to handle everything, and only notify
  *   the connected driver when the link status changes.  If you
@@ -158,6 +170,10 @@ struct phy_device * phy_connect(struct n
 }
 EXPORT_SYMBOL(phy_connect);
 
+/**
+ * phy_disconnect - disable interrupts, stop state machine, and detach a PHY device
+ * @phydev: target phy_device struct
+ */
 void phy_disconnect(struct phy_device *phydev)
 {
 	if (phydev->irq > 0)
@@ -171,21 +187,25 @@ void phy_disconnect(struct phy_device *p
 }
 EXPORT_SYMBOL(phy_disconnect);
 
-/* phy_attach:
+static int phy_compare_id(struct device *dev, void *data)
+{
+	return strcmp((char *)data, dev->bus_id) ? 0 : 1;
+}
+
+/**
+ * phy_attach - attach a network device to a particular PHY device
+ * @dev: network device to attach
+ * @phy_id: PHY device to attach
+ * @flags: PHY device's dev_flags
+ * @interface: PHY device's interface
  *
- *   description: Called by drivers to attach to a particular PHY
+ * Description: Called by drivers to attach to a particular PHY
  *     device. The phy_device is found, and properly hooked up
  *     to the phy_driver.  If no driver is attached, then the
  *     genphy_driver is used.  The phy_device is given a ptr to
  *     the attaching device, and given a callback for link status
- *     change.  The phy_device is returned to the attaching
- *     driver.
+ *     change.  The phy_device is returned to the attaching driver.
  */
-static int phy_compare_id(struct device *dev, void *data)
-{
-	return strcmp((char *)data, dev->bus_id) ? 0 : 1;
-}
-
 struct phy_device *phy_attach(struct net_device *dev,
 		const char *phy_id, u32 flags, phy_interface_t interface)
 {
@@ -250,6 +270,10 @@ struct phy_device *phy_attach(struct net
 }
 EXPORT_SYMBOL(phy_attach);
 
+/**
+ * phy_detach - detach a PHY device from its network device
+ * @phydev: target phy_device struct
+ */
 void phy_detach(struct phy_device *phydev)
 {
 	phydev->attached_dev = NULL;
@@ -269,11 +293,13 @@ EXPORT_SYMBOL(phy_detach);
 
 /* Generic PHY support and helper functions */
 
-/* genphy_config_advert
+/**
+ * genphy_config_advert - sanitize and advertise auto-negotation parameters
+ * @phydev: target phy_device struct
  *
- * description: Writes MII_ADVERTISE with the appropriate values,
+ * Description: Writes MII_ADVERTISE with the appropriate values,
  *   after sanitizing the values to make sure we only advertise
- *   what is supported
+ *   what is supported.
  */
 int genphy_config_advert(struct phy_device *phydev)
 {
@@ -335,11 +361,14 @@ int genphy_config_advert(struct phy_devi
 }
 EXPORT_SYMBOL(genphy_config_advert);
 
-/* genphy_setup_forced
+/**
+ * genphy_setup_forced - configures/forces speed/duplex from @phydev
+ * @phydev: target phy_device struct
  *
- * description: Configures MII_BMCR to force speed/duplex
+ * Description: Configures MII_BMCR to force speed/duplex
  *   to the values in phydev. Assumes that the values are valid.
- *   Please see phy_sanitize_settings() */
+ *   Please see phy_sanitize_settings().
+ */
 int genphy_setup_forced(struct phy_device *phydev)
 {
 	int ctl = BMCR_RESET;
@@ -368,7 +397,10 @@ int genphy_setup_forced(struct phy_devic
 }
 
 
-/* Enable and Restart Autonegotiation */
+/**
+ * genphy_restart_aneg - Enable and Restart Autonegotiation
+ * @phydev: target phy_device struct
+ */
 int genphy_restart_aneg(struct phy_device *phydev)
 {
 	int ctl;
@@ -389,11 +421,13 @@ int genphy_restart_aneg(struct phy_devic
 }
 
 
-/* genphy_config_aneg
+/**
+ * genphy_config_aneg - restart auto-negotiation or write BMCR
+ * @phydev: target phy_device struct
  *
- * description: If auto-negotiation is enabled, we configure the
+ * Description: If auto-negotiation is enabled, we configure the
  *   advertising, and then restart auto-negotiation.  If it is not
- *   enabled, then we write the BMCR
+ *   enabled, then we write the BMCR.
  */
 int genphy_config_aneg(struct phy_device *phydev)
 {
@@ -413,11 +447,13 @@ int genphy_config_aneg(struct phy_device
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
-/* genphy_update_link
+/**
+ * genphy_update_link - update link status in @phydev
+ * @phydev: target phy_device struct
  *
- * description: Update the value in phydev->link to reflect the
+ * Description: Update the value in phydev->link to reflect the
  *   current link value.  In order to do this, we need to read
- *   the status register twice, keeping the second value
+ *   the status register twice, keeping the second value.
  */
 int genphy_update_link(struct phy_device *phydev)
 {
@@ -444,9 +480,11 @@ int genphy_update_link(struct phy_device
 }
 EXPORT_SYMBOL(genphy_update_link);
 
-/* genphy_read_status
+/**
+ * genphy_read_status - check the link status and update current link state
+ * @phydev: target phy_device struct
  *
- * description: Check the link, then figure out the current state
+ * Description: Check the link, then figure out the current state
  *   by comparing what we advertise with what the link partner
  *   advertises.  Start by checking the gigabit possibilities,
  *   then move on to 10/100.
@@ -586,9 +624,11 @@ static int genphy_config_init(struct phy
 }
 
 
-/* phy_probe
+/**
+ * phy_probe - probe and init a PHY device
+ * @dev: device to probe and init
  *
- * description: Take care of setting up the phy_device structure,
+ * Description: Take care of setting up the phy_device structure,
  *   set the state to READY (the driver's init function should
  *   set it to STARTING if needed).
  */
@@ -650,6 +690,10 @@ static int phy_remove(struct device *dev
 	return 0;
 }
 
+/**
+ * phy_driver_register - register a phy_driver with the PHY layer
+ * @new_driver: new phy_driver to register
+ */
 int phy_driver_register(struct phy_driver *new_driver)
 {
 	int retval;
_
