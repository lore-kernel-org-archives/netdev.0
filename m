From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 1/5] drivers/base: Add bus_register_notifier_alldev() variant
Date: Tue, 10 Mar 2009 09:22:02 -0600
Message-ID: <20090310152201.12455.74770.stgit@localhost.localdomain>
References: <20090310150751.12455.70598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:39859 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbZCJPWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 11:22:06 -0400
In-Reply-To: <20090310150751.12455.70598.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

bus_register_notifier_alldev() is a variation on bus_register_notifier()
which also triggers the notifier callback for devices already on the bus
and already bound to drivers.

This function is useful for the case where a driver needs to get a
reference to a struct device other than the one it is bound to and
it is not known if the device will be bound before or after this
function is called.  For example, an Ethernet device connected to
a PHY that is probed separately.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
CC: linux-kernel@vger.kernel.org
CC: linuxppc-dev@ozlabs.org
CC: Greg Kroah-Hartman <gregkh@suse.de>
---

 drivers/base/bus.c     |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/device.h |    2 ++
 2 files changed, 49 insertions(+), 0 deletions(-)


diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index 83f32b8..6edde85 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -962,6 +962,53 @@ int bus_register_notifier(struct bus_type *bus, struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(bus_register_notifier);
 
+/**
+ * bus_register_notifier_alldev_helper - internal support function
+ * Used by bus_register_notifier_alldev() to create ADD and BOUND events
+ * for devices.
+ */
+static int bus_register_notifier_alldev_helper(struct device *dev, void *data)
+{
+	struct notifier_block *nb = data;
+	nb->notifier_call(nb, BUS_NOTIFY_ADD_DEVICE, dev);
+	if (dev->driver)
+		nb->notifier_call(nb, BUS_NOTIFY_BOUND_DRIVER, dev);
+	return 0;
+}
+
+/**
+ * bus_register_notifier_alldev - Register for bus events; include existing devs
+ * @bus: pointer to bus_type
+ * @nb: pointer to notifier block to register with the bus
+ *
+ * Similar to bus_register_notifier() except it also generates events for
+ * devices already on the bus when the notifier is registered.  When this
+ * function is called the notifier is called once for each device with
+ * the BUS_NOTIFY_ADD_DEVICE event, and once for each device registered to
+ * a driver * with the BUS_NOTIFY_BOUND_DRIVER event.
+ *
+ * There is a small chance that the notifier could be called more than once
+ * for a device.  This would happen if a new device was registered on the bus
+ * or bound to a driver between the call to bus_register_notifier() and the
+ * call to bus_for_each_dev().  The only way I can see to protect against
+ * this would be to take the klist_devices spinlock while calling the
+ * notifier; but that would be a Very Bad Thing (tm).  Caller needs to be
+ * aware that a notifier called before this function returns might get
+ * called a second time on the same device.
+ */
+int bus_register_notifier_alldev(struct bus_type *b, struct notifier_block *nb)
+{
+	int ret;
+
+	ret = bus_register_notifier(b, nb);
+	if (ret == 0) {
+		bus_for_each_dev(b, NULL, nb,
+				 bus_register_notifier_alldev_helper);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(bus_register_notifier_alldev);
+
 int bus_unregister_notifier(struct bus_type *bus, struct notifier_block *nb)
 {
 	return blocking_notifier_chain_unregister(&bus->p->bus_notifier, nb);
diff --git a/include/linux/device.h b/include/linux/device.h
index 47f343c..95a7d2b 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -103,6 +103,8 @@ struct notifier_block;
 
 extern int bus_register_notifier(struct bus_type *bus,
 				 struct notifier_block *nb);
+extern int bus_register_notifier_alldev(struct bus_type *b,
+					struct notifier_block *nb);
 extern int bus_unregister_notifier(struct bus_type *bus,
 				   struct notifier_block *nb);
 

