From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [RFC PATCHv2 2/4] net: phy: extend fixed driver with fixed_phy_register()
Date: Fri,  6 Sep 2013 17:18:19 +0200
Message-ID: <1378480701-12908-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:41904 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753304Ab3IFPSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 11:18:25 -0400
In-Reply-To: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing fixed_phy_add() function has several drawbacks that
prevents it from being used as is for OF-based declaration of fixed
PHYs:

 * The address of the PHY on the fake bus needs to be passed, while a
   dynamic allocation is desired.

 * Since the phy_device instantiation is post-poned until the next
   mdiobus scan, there is no way to associate the fixed PHY with its
   OF node, which later prevents of_phy_connect() from finding this
   fixed PHY from a given OF node.

To solve this, this commit introduces fixed_phy_register(), which will
allocate an available PHY address, add the PHY using fixed_phy_add()
and instantiate the phy_device structure associated with the provided
OF node.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/phy/fixed.c   | 43 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy_fixed.h | 11 +++++++++++
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 0f02403..3f9412b 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -21,6 +21,7 @@
 #include <linux/phy_fixed.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/of.h>
 
 #define MII_REGS_NUM 29
 
@@ -203,6 +204,48 @@ err_regs:
 }
 EXPORT_SYMBOL_GPL(fixed_phy_add);
 
+static int phy_fixed_addr;
+static DEFINE_SPINLOCK(phy_fixed_addr_lock);
+
+int fixed_phy_register(unsigned int irq,
+		       struct fixed_phy_status *status,
+		       struct device_node *np)
+{
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct phy_device *phy;
+	int phy_addr;
+	int ret;
+
+	/* Get the next available PHY address, up to PHY_MAX_ADDR */
+	spin_lock(&phy_fixed_addr_lock);
+	if (phy_fixed_addr == PHY_MAX_ADDR) {
+		spin_unlock(&phy_fixed_addr_lock);
+		return -ENOSPC;
+	}
+	phy_addr = phy_fixed_addr++;
+	spin_unlock(&phy_fixed_addr_lock);
+
+	ret = fixed_phy_add(PHY_POLL, phy_addr, status);
+	if (ret < 0)
+		return ret;
+
+	phy = get_phy_device(fmb->mii_bus, phy_addr, false);
+	if (!phy || IS_ERR(phy))
+		return -EINVAL;
+
+	of_node_get(np);
+	phy->dev.of_node = np;
+
+	ret = phy_device_register(phy);
+	if (ret) {
+		phy_device_free(phy);
+		of_node_put(np);
+		return ret;
+	}
+
+	return 0;
+}
+
 static int __init fixed_mdio_bus_init(void)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 509d8f5..902e8a1 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -9,15 +9,26 @@ struct fixed_phy_status {
 	int asym_pause;
 };
 
+struct device_node;
+
 #ifdef CONFIG_FIXED_PHY
 extern int fixed_phy_add(unsigned int irq, int phy_id,
 			 struct fixed_phy_status *status);
+extern int fixed_phy_register(unsigned int irq,
+			      struct fixed_phy_status *status,
+			      struct device_node *np);
 #else
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
 				struct fixed_phy_status *status)
 {
 	return -ENODEV;
 }
+extern int fixed_phy_register(unsigned int irq,
+			      struct fixed_phy_status *status,
+			      struct device_node *np)
+{
+	return -ENODEV;
+}
 #endif /* CONFIG_FIXED_PHY */
 
 /*
-- 
1.8.1.2
