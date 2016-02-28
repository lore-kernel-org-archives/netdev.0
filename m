From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 21/32] net: mdio: Add mdiodev_{read|write} helpers
Date: Sun, 28 Feb 2016 17:41:29 +0100
Message-ID: <1456677700-23027-22-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44962 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758528AbcB1Qms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:48 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An mdio driver will want to perform reads/writes on its device.
Provide an abstraction over the mdiobus functions, which require more
knowledge of bus addresses.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio_device.c | 68 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h          |  5 ++++
 2 files changed, 73 insertions(+)

diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
index 9c88e6749b9a..5bf6a2b93773 100644
--- a/drivers/net/phy/mdio_device.c
+++ b/drivers/net/phy/mdio_device.c
@@ -23,6 +23,74 @@
 #include <linux/string.h>
 #include <linux/unistd.h>
 
+/**
+ * mdiodev_read_nested - Nested version of the mdiodev_read function
+ * @mdiodev: the mdio device to read
+ * @regnum: register number to read
+ *
+ * In case of nested MDIO bus access avoid lockdep false positives by
+ * using mutex_lock_nested().
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiodev_read_nested(struct mdio_device *mdiodev, u32 regnum)
+{
+	return mdiobus_read_nested(mdiodev->bus, mdiodev->addr, regnum);
+}
+EXPORT_SYMBOL(mdiodev_read_nested);
+
+/**
+ * mdiodev_read - Convenience function for reading a given MII mgmt register
+ * @mdiodev: the mdio device to read
+ * @regnum: register number to read
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiodev_read(struct mdio_device *mdiodev, u32 regnum)
+{
+	return mdiobus_read(mdiodev->bus, mdiodev->addr, regnum);
+}
+EXPORT_SYMBOL(mdiodev_read);
+
+/**
+ * mdiodev_write_nested - Nested version of the mdiodev_write function
+ * @mdiodev: the mdio device to read
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * In case of nested MDIO bus access avoid lockdep false positives by
+ * using mutex_lock_nested().
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiodev_write_nested(struct mdio_device *mdiodev, u32 regnum, u16 val)
+{
+	return mdiobus_write_nested(mdiodev->bus, mdiodev->addr, regnum, val);
+}
+EXPORT_SYMBOL(mdiodev_write_nested);
+
+/**
+ * mdiodev_write - Convenience function for writing a given MII mgmt register
+ * @mdiodev: the mdio device to read
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+int mdiodev_write(struct mdio_device *mdiodev, u32 regnum, u16 val)
+{
+	return mdiobus_write(mdiodev->bus, mdiodev->addr, regnum, val);
+}
+EXPORT_SYMBOL(mdiodev_write);
+
 void mdio_device_free(struct mdio_device *mdiodev)
 {
 	put_device(&mdiodev->dev);
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 5bfd99d1a40a..58e39fbaa3e8 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -227,6 +227,11 @@ int mdiobus_read_nested(struct mii_bus *bus, int addr, u32 regnum);
 int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
 int mdiobus_write_nested(struct mii_bus *bus, int addr, u32 regnum, u16 val);
 
+int mdiodev_read(struct mdio_device *mdiodev, u32 regnum);
+int mdiodev_read_nested(struct mdio_device *mdiodev, u32 regnum);
+int mdiodev_write(struct mdio_device *mdiodev, u32 regnum, u16 val);
+int mdiodev_write_nested(struct mdio_device *mdiodev, u32 regnum, u16 val);
+
 int mdiobus_register_device(struct mdio_device *mdiodev);
 int mdiobus_unregister_device(struct mdio_device *mdiodev);
 bool mdiobus_is_registered_device(struct mii_bus *bus, int addr);
-- 
2.7.0
