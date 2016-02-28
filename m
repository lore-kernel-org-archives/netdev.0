From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 32/32] phy: fixed: Fix removal of phys.
Date: Sun, 28 Feb 2016 17:41:40 +0100
Message-ID: <1456677700-23027-33-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44939 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759488AbcB1QmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:24 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fixed phys delete function simply removed the fixed phy from the
internal linked list and freed the memory. It however did not
unregister the associated phy device. This meant it was still possible
to find the phy device on the mdio bus.

Make fixed_phy_del() an internal function and add a
fixed_phy_unregister() to unregisters the phy device and then uses
fixed_phy_del() to free resources.

Modify DSA to use this new API function. It then becomes possible to
unload and load driver modules with setups that use fixed phys.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/fixed_phy.c | 10 ++++++++--
 include/linux/phy_fixed.h   |  5 ++---
 net/dsa/dsa.c               |  4 +---
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index ab9c473d75ea..a6caf99a3904 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -285,7 +285,7 @@ err_regs:
 }
 EXPORT_SYMBOL_GPL(fixed_phy_add);
 
-void fixed_phy_del(int phy_addr)
+static void fixed_phy_del(int phy_addr)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp, *tmp;
@@ -300,7 +300,6 @@ void fixed_phy_del(int phy_addr)
 		}
 	}
 }
-EXPORT_SYMBOL_GPL(fixed_phy_del);
 
 static int phy_fixed_addr;
 static DEFINE_SPINLOCK(phy_fixed_addr_lock);
@@ -371,6 +370,13 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 }
 EXPORT_SYMBOL_GPL(fixed_phy_register);
 
+void fixed_phy_unregister(struct phy_device *phy)
+{
+	phy_device_remove(phy);
+
+	fixed_phy_del(phy->mdio.addr);
+}
+
 static int __init fixed_mdio_bus_init(void)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 2400d2ea4f34..1d41ec44e39d 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -19,7 +19,7 @@ extern struct phy_device *fixed_phy_register(unsigned int irq,
 					     struct fixed_phy_status *status,
 					     int link_gpio,
 					     struct device_node *np);
-extern void fixed_phy_del(int phy_addr);
+extern void fixed_phy_unregister(struct phy_device *phydev);
 extern int fixed_phy_set_link_update(struct phy_device *phydev,
 			int (*link_update)(struct net_device *,
 					   struct fixed_phy_status *));
@@ -40,9 +40,8 @@ static inline struct phy_device *fixed_phy_register(unsigned int irq,
 {
 	return ERR_PTR(-ENODEV);
 }
-static inline int fixed_phy_del(int phy_addr)
+static inline void fixed_phy_unregister(struct phy_device *phydev)
 {
-	return -ENODEV;
 }
 static inline int fixed_phy_set_link_update(struct phy_device *phydev,
 			int (*link_update)(struct net_device *,
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index e969a43f7a21..445097927131 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -404,11 +404,9 @@ static void dsa_switch_finish_one(struct dsa_switch *ds)
 		if (of_phy_is_fixed_link(port_dn)) {
 			phydev = of_phy_find_device(port_dn);
 			if (phydev) {
-				int addr = phydev->mdio.addr;
-
 				phy_device_free(phydev);
 				of_node_put(port_dn);
-				fixed_phy_del(addr);
+				fixed_phy_unregister(phydev);
 			}
 		}
 	}
-- 
2.7.0
