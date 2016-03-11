From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/5] phy: fixed: Fix removal of phys.
Date: Sat, 12 Mar 2016 00:01:40 +0100
Message-ID: <1457737300-23660-6-git-send-email-andrew@lunn.ch>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55182 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbcCKXBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:01:50 -0500
In-Reply-To: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fixed phys delete function simply removed the fixed phy from the
internal linked list and freed the memory. It however did not
unregister the associated phy device. This meant it was still possible
to find the phy device on the mdio bus.

Make fixed_phy_del() an internal function and add a
fixed_phy_unregister() to unregisters the phy device and then uses
fixed_phy_del() to free resources.

Modify DSA to use this new API function, so we don't leak phys.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/fixed_phy.c | 11 +++++++++--
 include/linux/phy_fixed.h   |  5 ++---
 net/dsa/dsa.c               |  4 +---
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index ab9c473d75ea..fc07a8866020 100644
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
@@ -371,6 +370,14 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 }
 EXPORT_SYMBOL_GPL(fixed_phy_register);
 
+void fixed_phy_unregister(struct phy_device *phy)
+{
+	phy_device_remove(phy);
+
+	fixed_phy_del(phy->mdio.addr);
+}
+EXPORT_SYMBOL_GPL(fixed_phy_unregister);
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
index f100f340d93f..c28c47463b7e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -447,11 +447,9 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
