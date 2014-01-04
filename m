From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 5/6] phylib: remove unused adjust_state callback
Date: Sat, 4 Jan 2014 04:21:56 +0300
Message-ID: <201401040421.56307.sergei.shtylyov@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:62388 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbaADAVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:21:54 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so8570983lab.9
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:21:52 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-83-104.pppoe.mtu-net.ru. [91.76.83.104])
        by mx.google.com with ESMTPSA id n13sm37459905lbl.17.2014.01.03.16.21.51
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:21:52 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove adjust_state() callback from 'struct phy_device' since it seems to have
never been really used from the inception: phy_start_machine() has been always
called with 2nd argument equal to NULL.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/mdio_bus.c   |    4 ++--
 drivers/net/phy/phy.c        |   17 +++--------------
 drivers/net/phy/phy_device.c |    2 +-
 include/linux/phy.h          |    7 +------
 4 files changed, 7 insertions(+), 23 deletions(-)

Index: net-next/drivers/net/phy/mdio_bus.c
===================================================================
--- net-next.orig/drivers/net/phy/mdio_bus.c
+++ net-next/drivers/net/phy/mdio_bus.c
@@ -379,7 +379,7 @@ static int mdio_bus_resume(struct device
 
 no_resume:
 	if (phydev->attached_dev && phydev->adjust_link)
-		phy_start_machine(phydev, NULL);
+		phy_start_machine(phydev);
 
 	return 0;
 }
@@ -401,7 +401,7 @@ static int mdio_bus_restore(struct devic
 	phydev->link = 0;
 	phydev->state = PHY_UP;
 
-	phy_start_machine(phydev, NULL);
+	phy_start_machine(phydev);
 
 	return 0;
 }
Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -406,21 +406,15 @@ EXPORT_SYMBOL(phy_start_aneg);
 /**
  * phy_start_machine - start PHY state machine tracking
  * @phydev: the phy_device struct
- * @handler: callback function for state change notifications
  *
  * Description: The PHY infrastructure can run a state machine
  *   which tracks whether the PHY is starting up, negotiating,
  *   etc.  This function starts the timer which tracks the state
- *   of the PHY.  If you want to be notified when the state changes,
- *   pass in the callback @handler, otherwise, pass NULL.  If you
- *   want to maintain your own state machine, do not call this
- *   function.
+ *   of the PHY.  If you want to maintain your own state machine,
+ *   do not call this function.
  */
-void phy_start_machine(struct phy_device *phydev,
-		       void (*handler)(struct net_device *))
+void phy_start_machine(struct phy_device *phydev)
 {
-	phydev->adjust_state = handler;
-
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
 }
 
@@ -440,8 +434,6 @@ void phy_stop_machine(struct phy_device 
 	if (phydev->state > PHY_UP)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
-
-	phydev->adjust_state = NULL;
 }
 
 /**
@@ -708,9 +700,6 @@ void phy_state_machine(struct work_struc
 
 	mutex_lock(&phydev->lock);
 
-	if (phydev->adjust_state)
-		phydev->adjust_state(phydev->attached_dev);
-
 	switch (phydev->state) {
 	case PHY_DOWN:
 	case PHY_STARTING:
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -424,7 +424,7 @@ int phy_connect_direct(struct net_device
 		return rc;
 
 	phy_prepare_link(phydev, handler);
-	phy_start_machine(phydev, NULL);
+	phy_start_machine(phydev);
 	if (phydev->irq > 0)
 		phy_start_interrupts(phydev);
 
Index: net-next/include/linux/phy.h
===================================================================
--- net-next.orig/include/linux/phy.h
+++ net-next/include/linux/phy.h
@@ -284,8 +284,6 @@ struct phy_c45_device_ids {
  * attached_dev: The attached enet driver's device instance ptr
  * adjust_link: Callback for the enet controller to respond to
  * changes in the link state.
- * adjust_state: Callback for the enet driver to respond to
- * changes in the state machine.
  *
  * speed, duplex, pause, supported, advertising, lp_advertising,
  * and autoneg are used like in mii_if_info
@@ -366,8 +364,6 @@ struct phy_device {
 	struct net_device *attached_dev;
 
 	void (*adjust_link)(struct net_device *dev);
-
-	void (*adjust_state)(struct net_device *dev);
 };
 #define to_phy_device(d) container_of(d, struct phy_device, dev)
 
@@ -585,8 +581,7 @@ int phy_drivers_register(struct phy_driv
 void phy_state_machine(struct work_struct *work);
 void phy_change(struct work_struct *work);
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
-void phy_start_machine(struct phy_device *phydev,
-		void (*handler)(struct net_device *));
+void phy_start_machine(struct phy_device *phydev);
 void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
