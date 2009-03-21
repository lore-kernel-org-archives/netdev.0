From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 04/13] phylib: add *_direct() variants of phy_connect and
	phy_attach functions
Date: Sat, 21 Mar 2009 16:28:33 -0600
Message-ID: <20090321222833.20493.21831.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:31077 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567AbZCUW2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:28:40 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:28:39 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

Add phy_connect_direct() and phy_attach_direct() functions so that
drivers can use a pointer to the phy_device instead of trying to determine
the phy's bus_id string.

This patch is useful for OF device tree descriptions of phy devices where
the driver doesn't need or know what the bus_id value in order to get a
phy_device pointer.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/phy/phy_device.c |  118 ++++++++++++++++++++++++++++++------------
 include/linux/phy.h          |    5 ++
 2 files changed, 90 insertions(+), 33 deletions(-)


diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9352ca8..3c8c1de 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -292,6 +292,33 @@ void phy_prepare_link(struct phy_device *phydev,
 }
 
 /**
+ * phy_connect_direct - connect an ethernet device to a specific phy_device
+ * @dev: the network device to connect
+ * @phydev: the pointer to the phy device
+ * @handler: callback function for state change notifications
+ * @flags: PHY device's dev_flags
+ * @interface: PHY device's interface
+ */
+int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
+		       void (*handler)(struct net_device *), u32 flags,
+		       phy_interface_t interface)
+{
+	int rc;
+
+	rc = phy_attach_direct(dev, phydev, flags, interface);
+	if (rc)
+		return rc;
+
+	phy_prepare_link(phydev, handler);
+	phy_start_machine(phydev, NULL);
+	if (phydev->irq > 0)
+		phy_start_interrupts(phydev);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_connect_direct);
+
+/**
  * phy_connect - connect an ethernet device to a PHY device
  * @dev: the network device to connect
  * @bus_id: the id string of the PHY device to connect
@@ -312,18 +339,21 @@ struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 		phy_interface_t interface)
 {
 	struct phy_device *phydev;
+	struct device *d;
+	int rc;
 
-	phydev = phy_attach(dev, bus_id, flags, interface);
-
-	if (IS_ERR(phydev))
-		return phydev;
-
-	phy_prepare_link(phydev, handler);
-
-	phy_start_machine(phydev, NULL);
+	/* Search the list of PHY devices on the mdio bus for the
+	 * PHY with the requested name */
+	d = bus_find_device_by_name(&mdio_bus_type, NULL, bus_id);
+	if (!d) {
+		pr_err("PHY %s not found\n", bus_id);
+		return ERR_PTR(-ENODEV);
+	}
+	phydev = to_phy_device(d);
 
-	if (phydev->irq > 0)
-		phy_start_interrupts(phydev);
+	rc = phy_attach_direct(dev, phydev, flags, interface);
+	if (rc)
+		return ERR_PTR(rc);
 
 	return phydev;
 }
@@ -347,9 +377,9 @@ void phy_disconnect(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_disconnect);
 
 /**
- * phy_attach - attach a network device to a particular PHY device
+ * phy_attach_direct - attach a network device to a given PHY device pointer
  * @dev: network device to attach
- * @bus_id: PHY device to attach
+ * @phydev: Pointer to phy_device to attach
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
  *
@@ -360,22 +390,10 @@ EXPORT_SYMBOL(phy_disconnect);
  *     the attaching device, and given a callback for link status
  *     change.  The phy_device is returned to the attaching driver.
  */
-struct phy_device *phy_attach(struct net_device *dev,
-		const char *bus_id, u32 flags, phy_interface_t interface)
+int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
+		      u32 flags, phy_interface_t interface)
 {
-	struct bus_type *bus = &mdio_bus_type;
-	struct phy_device *phydev;
-	struct device *d;
-
-	/* Search the list of PHY devices on the mdio bus for the
-	 * PHY with the requested name */
-	d = bus_find_device_by_name(bus, NULL, bus_id);
-	if (d) {
-		phydev = to_phy_device(d);
-	} else {
-		printk(KERN_ERR "%s not found\n", bus_id);
-		return ERR_PTR(-ENODEV);
-	}
+	struct device *d = &phydev->dev;
 
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver. */
@@ -388,13 +406,12 @@ struct phy_device *phy_attach(struct net_device *dev,
 			err = device_bind_driver(d);
 
 		if (err)
-			return ERR_PTR(err);
+			return err;
 	}
 
 	if (phydev->attached_dev) {
-		printk(KERN_ERR "%s: %s already attached\n",
-				dev->name, bus_id);
-		return ERR_PTR(-EBUSY);
+		dev_err(&dev->dev, "PHY already attached\n");
+		return -EBUSY;
 	}
 
 	phydev->attached_dev = dev;
@@ -412,13 +429,48 @@ struct phy_device *phy_attach(struct net_device *dev,
 		err = phy_scan_fixups(phydev);
 
 		if (err < 0)
-			return ERR_PTR(err);
+			return err;
 
 		err = phydev->drv->config_init(phydev);
 
 		if (err < 0)
-			return ERR_PTR(err);
+			return err;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_attach_direct);
+
+/**
+ * phy_attach - attach a network device to a particular PHY device
+ * @dev: network device to attach
+ * @bus_id: Bus ID of PHY device to attach
+ * @flags: PHY device's dev_flags
+ * @interface: PHY device's interface
+ *
+ * Description: Same as phy_attach_direct() except that a PHY bus_id
+ *     string is passed instead of a pointer to a struct phy_device.
+ */
+struct phy_device *phy_attach(struct net_device *dev,
+		const char *bus_id, u32 flags, phy_interface_t interface)
+{
+	struct bus_type *bus = &mdio_bus_type;
+	struct phy_device *phydev;
+	struct device *d;
+	int rc;
+
+	/* Search the list of PHY devices on the mdio bus for the
+	 * PHY with the requested name */
+	d = bus_find_device_by_name(bus, NULL, bus_id);
+	if (!d) {
+		pr_err("PHY %s not found\n", bus_id);
+		return ERR_PTR(-ENODEV);
 	}
+	phydev = to_phy_device(d);
+
+	rc = phy_attach_direct(dev, phydev, flags, interface);
+	if (rc)
+		return ERR_PTR(rc);
 
 	return phydev;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index a47d64f..97405f2 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -442,8 +442,13 @@ struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_device_register(struct phy_device *phy);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
+		u32 flags, phy_interface_t interface);
 struct phy_device * phy_attach(struct net_device *dev,
 		const char *bus_id, u32 flags, phy_interface_t interface);
+int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
+		void (*handler)(struct net_device *), u32 flags,
+		phy_interface_t interface);
 struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface);

