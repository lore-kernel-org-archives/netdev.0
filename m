From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 3/6] fixed_phy: add fixed_phy_unregister()
Date: Thu, 26 Mar 2015 19:01:00 +0300
Message-ID: <55142D3C.4040902@list.ru>
References: <55142C31.5050504@list.ru> <55142CB1.1080107@list.ru> <55142D01.3090601@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.181.189]:45819 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbbCZQW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:22:58 -0400
Received: from smtp1.mail.ru (smtp1.mail.ru [94.100.179.111])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 6AF9B148D8F25
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 19:01:11 +0300 (MSK)
In-Reply-To: <55142D01.3090601@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-=-=-=-=-=-=-=-=-=# Don't remove this line #=-=-=-=-=-=-=-=-=-
A counterpart of fixed_phy_register().
Can be used on failure path.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/phy/fixed_phy.c  |   11 +++++++++++
 drivers/net/phy/phy_device.c |    7 +++++++
 include/linux/phy.h          |    1 +
 include/linux/phy_fixed.h    |    4 ++++
 4 files changed, 23 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 8078998..c2e82a0 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -275,6 +275,17 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 }
 EXPORT_SYMBOL_GPL(fixed_phy_register);
 
+void fixed_phy_unregister(struct phy_device *phy)
+{
+    struct device_node *np = phy->dev.of_node;
+
+    fixed_phy_del(phy->addr);
+    phy_device_unregister(phy);
+    phy_device_free(phy);
+    of_node_put(np);
+}
+EXPORT_SYMBOL_GPL(fixed_phy_unregister);
+
 static int __init fixed_mdio_bus_init(void)
 {
     struct fixed_mdio_bus *fmb = &platform_fmb;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51f..8923c0d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -375,6 +375,13 @@ int phy_device_register(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_device_register);
 
+void phy_device_unregister(struct phy_device *phydev)
+{
+    phydev->bus->phy_map[phydev->addr] = NULL;
+    device_del(&phydev->dev);
+}
+EXPORT_SYMBOL(phy_device_unregister);
+
 /**
  * phy_find_first - finds the first PHY device on the bus
  * @bus: the target MII bus
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6858098..448dda3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -714,6 +714,7 @@ struct phy_device *phy_device_create(struct mii_bus
*bus, int addr, int phy_id,
                      struct phy_c45_device_ids *c45_ids);
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool
is_c45);
 int phy_device_register(struct phy_device *phy);
+void phy_device_unregister(struct phy_device *phydev);
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
 int phy_resume(struct phy_device *phydev);
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index ac82e6d..bb7d17c 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -17,6 +17,7 @@ extern int fixed_phy_add(unsigned int irq, int phy_id,
 extern struct phy_device *fixed_phy_register(unsigned int irq,
                          struct fixed_phy_status *status,
                          struct device_node *np);
+extern void fixed_phy_unregister(struct phy_device *phy);
 extern void fixed_phy_del(int phy_addr);
 extern int fixed_phy_set_link_update(struct phy_device *phydev,
             int (*link_update)(struct phy_device *,
@@ -33,6 +34,9 @@ static inline struct phy_device
*fixed_phy_register(unsigned int irq,
 {
     return ERR_PTR(-ENODEV);
 }
+static inline void fixed_phy_unregister(struct phy_device *phy)
+{
+}
 static inline int fixed_phy_del(int phy_addr)
 {
     return -ENODEV;
-- 
1.7.9.5
