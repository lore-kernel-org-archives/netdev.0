From: <s-paulraj@ti.com>
Subject: [PATCH 2/4] phylib: add context argument to adjust link callback
Date: Fri, 6 Jul 2012 16:09:42 -0400
Message-ID: <1341605382-20563-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Paulraj <s-paulraj@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:54976 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab2GFUJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 16:09:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Paulraj <s-paulraj@ti.com>

This patch introduces a context argument for the adjust link callback.  This
context information is set at phy_connect() (and its variants), and is passed
back into the adjust_link callbacks on link state change events.

Such context information is necessary when a network device has multiple
underlying ports.  Specifically, this comes into play when the netdev is
really one of the ports going into an on-chip switch of some sort.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>
---
 drivers/net/phy/phy.c        |    6 +++---
 drivers/net/phy/phy_device.c |   23 +++++++++++++++--------
 include/linux/phy.h          |   20 ++++++++++++--------
 3 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36ca912..491a608 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -433,7 +433,7 @@ static void phy_change(struct work_struct *work);
  *   function.
  */
 void phy_start_machine(struct phy_device *phydev,
-		void (*handler)(struct net_device *))
+		       void (*handler)(struct net_device *, void *context))
 {
 	phydev->adjust_state = handler;
 
@@ -763,7 +763,7 @@ EXPORT_SYMBOL(phy_start);
 
 static inline void phy_adjust_link(struct phy_device *phydev)
 {
-	phydev->adjust_link(phydev->attached_dev);
+	phydev->adjust_link(phydev->attached_dev, phydev->context);
 }
 
 /**
@@ -781,7 +781,7 @@ void phy_state_machine(struct work_struct *work)
 	mutex_lock(&phydev->lock);
 
 	if (phydev->adjust_state)
-		phydev->adjust_state(phydev->attached_dev);
+		phydev->adjust_state(phydev->attached_dev, phydev->context);
 
 	switch(phydev->state) {
 		case PHY_DOWN:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index de86a55..a4e5313 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -310,6 +310,7 @@ EXPORT_SYMBOL(phy_find_first);
  * phy_prepare_link - prepares the PHY layer to monitor link status
  * @phydev: target phy_device struct
  * @handler: callback function for link status change notifications
+ * @context: context information for callback handler
  *
  * Description: Tells the PHY infrastructure to handle the
  *   gory details on monitoring link status (whether through
@@ -319,9 +320,11 @@ EXPORT_SYMBOL(phy_find_first);
  *   this function.
  */
 static void phy_prepare_link(struct phy_device *phydev,
-		void (*handler)(struct net_device *))
+		void (*handler)(struct net_device *, void *context),
+		void *context)
 {
 	phydev->adjust_link = handler;
+	phydev->context = context;
 }
 
 /**
@@ -331,10 +334,11 @@ static void phy_prepare_link(struct phy_device *phydev,
  * @handler: callback function for state change notifications
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
+ * @context: context information for callback handler
  */
 int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
-		       void (*handler)(struct net_device *), u32 flags,
-		       phy_interface_t interface)
+		       void (*handler)(struct net_device *, void *context),
+		       u32 flags, phy_interface_t interface, void *context)
 {
 	int rc;
 
@@ -342,7 +346,7 @@ int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
 	if (rc)
 		return rc;
 
-	phy_prepare_link(phydev, handler);
+	phy_prepare_link(phydev, handler, context);
 	phy_start_machine(phydev, NULL);
 	if (phydev->irq > 0)
 		phy_start_interrupts(phydev);
@@ -358,6 +362,7 @@ EXPORT_SYMBOL(phy_connect_direct);
  * @handler: callback function for state change notifications
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
+ * @context: context information for callback handler
  *
  * Description: Convenience function for connecting ethernet
  *   devices to PHY devices.  The default behavior is for
@@ -367,9 +372,10 @@ EXPORT_SYMBOL(phy_connect_direct);
  *   choose to call only the subset of functions which provide
  *   the desired functionality.
  */
-struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
-		void (*handler)(struct net_device *), u32 flags,
-		phy_interface_t interface)
+struct phy_device *
+phy_connect(struct net_device *dev, const char *bus_id,
+	    void (*handler)(struct net_device *, void *context),
+	    u32 flags, phy_interface_t interface, void *context)
 {
 	struct phy_device *phydev;
 	struct device *d;
@@ -384,7 +390,8 @@ struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
 	}
 	phydev = to_phy_device(d);
 
-	rc = phy_connect_direct(dev, phydev, handler, flags, interface);
+	rc = phy_connect_direct(dev, phydev, handler, flags, interface,
+				context);
 	if (rc)
 		return ERR_PTR(rc);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index c291cae..596b8fe 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -263,6 +263,7 @@ enum phy_state {
  * changes in the link state.
  * adjust_state: Callback for the enet driver to respond to
  * changes in the state machine.
+ * context: Context information for adjust_link and adjust_state callbacks
  *
  * speed, duplex, pause, supported, advertising, and
  * autoneg are used like in mii_if_info
@@ -337,9 +338,11 @@ struct phy_device {
 
 	struct net_device *attached_dev;
 
-	void (*adjust_link)(struct net_device *dev);
+	void (*adjust_link)(struct net_device *dev, void *context);
 
-	void (*adjust_state)(struct net_device *dev);
+	void (*adjust_state)(struct net_device *dev, void *context);
+
+	void *context;
 };
 #define to_phy_device(d) container_of(d, struct phy_device, dev)
 
@@ -487,11 +490,12 @@ struct phy_device * phy_attach(struct net_device *dev,
 		const char *bus_id, u32 flags, phy_interface_t interface);
 struct phy_device *phy_find_first(struct mii_bus *bus);
 int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
-		void (*handler)(struct net_device *), u32 flags,
-		phy_interface_t interface);
-struct phy_device * phy_connect(struct net_device *dev, const char *bus_id,
-		void (*handler)(struct net_device *), u32 flags,
-		phy_interface_t interface);
+		       void (*handler)(struct net_device *, void *context),
+		       u32 flags, phy_interface_t interface, void *context);
+struct phy_device *
+phy_connect(struct net_device *dev, const char *bus_id,
+	    void (*handler)(struct net_device *, void *context),
+	    u32 flags, phy_interface_t interface, void *context);
 void phy_disconnect(struct phy_device *phydev);
 void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
@@ -514,7 +518,7 @@ void phy_driver_unregister(struct phy_driver *drv);
 int phy_driver_register(struct phy_driver *new_driver);
 void phy_state_machine(struct work_struct *work);
 void phy_start_machine(struct phy_device *phydev,
-		void (*handler)(struct net_device *));
+		       void (*handler)(struct net_device *, void *context));
 void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
-- 
1.7.9.5
