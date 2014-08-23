From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/7] net: phy: export phy_{read,write}_mmd_indirect
Date: Fri, 22 Aug 2014 18:55:43 -0700
Message-ID: <1408758945-18908-6-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:45629 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbaHWB4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:19 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so17570544pad.13
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:19 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHY drivers might need to access Clause 45 registers in Clause 22
compatibility mode to e.g: properly advertise EEE support when disabled
by default.

Export these two helper functions: phy_read_mmd_indirect() and
phy_write_mmd_indirect() for drivers to use them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c |  6 ++++--
 include/linux/phy.h   | 27 +++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c94e2a27446a..e7a5893f32ff 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -955,7 +955,7 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
  * 3) Write reg 13 // MMD Data Command for MMD DEVAD
  * 3) Read  reg 14 // Read MMD data
  */
-static int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
+int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
 				 int devad, int addr)
 {
 	struct phy_driver *phydrv = phydev->drv;
@@ -971,6 +971,7 @@ static int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
 	}
 	return value;
 }
+EXPORT_SYMBOL(phy_read_mmd_indirect);
 
 /**
  * phy_write_mmd_indirect - writes data to the MMD registers
@@ -988,7 +989,7 @@ static int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
  * 3) Write reg 13 // MMD Data Command for MMD DEVAD
  * 3) Write reg 14 // Write MMD data
  */
-static void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
+void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
 				   int devad, int addr, u32 data)
 {
 	struct phy_driver *phydrv = phydev->drv;
@@ -1002,6 +1003,7 @@ static void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
 		phydrv->write_mmd_indirect(phydev, prtad, devad, addr, data);
 	}
 }
+EXPORT_SYMBOL(phy_write_mmd_indirect);
 
 /**
  * phy_init_eee - init and check the EEE feature
diff --git a/include/linux/phy.h b/include/linux/phy.h
index ed39956b5613..d090cfcaa167 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -598,6 +598,19 @@ static inline int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
 }
 
 /**
+ * phy_read_mmd_indirect - reads data from the MMD registers
+ * @phydev: The PHY device bus
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ * @addr: PHY address on the MII bus
+ *
+ * Description: it reads data from the MMD registers (clause 22 to access to
+ * clause 45) of the specified phy address.
+ */
+int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
+			  int devad, int addr);
+
+/**
  * phy_read - Convenience function for reading a given PHY register
  * @phydev: the phy_device struct
  * @regnum: register number to read
@@ -668,6 +681,20 @@ static inline int phy_write_mmd(struct phy_device *phydev, int devad,
 	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
 }
 
+/**
+ * phy_write_mmd_indirect - writes data to the MMD registers
+ * @phydev: The PHY device
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ * @addr: PHY address on the MII bus
+ * @data: data to write in the MMD register
+ *
+ * Description: Write data from the MMD registers of the specified
+ * phy address.
+ */
+void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
+			    int devad, int addr, u32 data);
+
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
 				     struct phy_c45_device_ids *c45_ids);
-- 
1.9.1
