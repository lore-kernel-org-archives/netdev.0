From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] phylib: introduce mdiobus_alloc_size()
Date: Fri, 6 Jan 2012 13:08:33 -0600
Message-ID: <1325876913-20363-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <afleming@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:34065
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758055Ab2AFTIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 14:08:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function mdiobus_alloc_size() as an alternative to mdiobus_alloc().
Most callers of mdiobus_alloc() also allocate a private data structure, and
then manually point bus->priv to this object.  mdiobus_alloc_size()
combines the two operations into one, which simplifies memory management.

The original mdiobus_alloc() now just calls mdiobus_alloc_size(0).

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/phy/mdio_bus.c |   24 +++++++++++++++++++-----
 include/linux/phy.h        |    7 ++++++-
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6c58da2..88cc5db 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -37,22 +37,36 @@
 #include <asm/uaccess.h>
 
 /**
- * mdiobus_alloc - allocate a mii_bus structure
+ * mdiobus_alloc_size - allocate a mii_bus structure
  *
  * Description: called by a bus driver to allocate an mii_bus
  * structure to fill in.
+ *
+ * 'size' is an an extra amount of memory to allocate for private storage.
+ * If non-zero, then bus->priv is points to that memory.
  */
-struct mii_bus *mdiobus_alloc(void)
+struct mii_bus *mdiobus_alloc_size(size_t size)
 {
 	struct mii_bus *bus;
+	size_t aligned_size = ALIGN(sizeof(*bus), NETDEV_ALIGN);
+	size_t alloc_size;
+
+	/* If we alloc extra space, it should be aligned */
+	if (size)
+		alloc_size = aligned_size + size;
+	else
+		alloc_size = sizeof(*bus);
 
-	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
-	if (bus != NULL)
+	bus = kzalloc(alloc_size, GFP_KERNEL);
+	if (bus) {
 		bus->state = MDIOBUS_ALLOCATED;
+		if (size)
+			bus->priv = (void *)bus + aligned_size;
+	}
 
 	return bus;
 }
-EXPORT_SYMBOL(mdiobus_alloc);
+EXPORT_SYMBOL(mdiobus_alloc_size);
 
 /**
  * mdiobus_release - mii_bus device release callback
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 79f337c..c599f7ec 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -129,7 +129,12 @@ struct mii_bus {
 };
 #define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 
-struct mii_bus *mdiobus_alloc(void);
+struct mii_bus *mdiobus_alloc_size(size_t);
+static inline struct mii_bus *mdiobus_alloc(void)
+{
+	return mdiobus_alloc_size(0);
+}
+
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
-- 
1.7.3.4
