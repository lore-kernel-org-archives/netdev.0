From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next] phy: add phy fixup unregister functions
Date: Fri, 2 Dec 2016 23:04:13 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40975526@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:31963 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932165AbcLBXEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:04:15 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add functions to unregister phy fixup for modules.

phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask)
 Unregister phy fixup matches bus_id, phy_uid and phy_uid_mask
 from phy_fixup_list.
 Return 0 when find matched one and remove from the list.
 Return -ENODEV when fail to find it on the list.

phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask)
 Unregister phy fixup from phy_fixup_list.
 Use it for fixup registered by phy_register_fixup_for_uid()
 Return 0 when find matched one and remove from the list.
 Return -ENODEV when fail to find it on the list.

phy_unregister_fixup_for_id(const char *bus_id)
 Unregister phy fixup from phy_fixup_list.
 Use it for fixup registered by phy_register_fixup_for_id()
 Return 0 when find matched one and remove from the list.
 Return -ENODEV when fail to find it on the list.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 Documentation/networking/phy.txt |  9 ++++++++
 drivers/net/phy/phy_device.c     | 47 ++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h              |  4 ++++
 3 files changed, 60 insertions(+)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index e017d93..16f90d8 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -407,6 +407,15 @@ Board Fixups
  The stubs set one of the two matching criteria, and set the other one to
  match anything.
 
+ When phy_register_fixup() or *_for_uid()/*_for_id() is called at module,
+ unregister fixup and free allocate memory are required.
+
+ Call one of following function before unloading module.
+
+ int phy_unregister_fixup(const char *phy_id, u32 phy_uid, u32 phy_uid_mask);
+ int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask);
+ int phy_register_fixup_for_id(const char *phy_id);
+
 Standards
 
  IEEE Standard 802.3: CSMA/CD Access Method and Physical Layer Specifications, Section Two:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index aeaf1bc..32fa7c7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -235,6 +235,53 @@ int phy_register_fixup_for_id(const char *bus_id,
 }
 EXPORT_SYMBOL(phy_register_fixup_for_id);
 
+/**
+ * phy_unregister_fixup - remove a phy_fixup from the list
+ * @bus_id: A string matches fixup->bus_id (or PHY_ANY_ID) in phy_fixup_list
+ * @phy_uid: A phy id matches fixup->phy_id (or PHY_ANY_UID) in phy_fixup_list
+ * @phy_uid_mask: Applied to phy_uid and fixup->phy_uid before comparison
+ */
+int phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask)
+{
+	struct list_head *pos, *n;
+	struct phy_fixup *fixup;
+	int ret;
+
+	ret = -ENODEV;
+
+	mutex_lock(&phy_fixup_lock);
+	list_for_each_safe(pos, n, &phy_fixup_list) {
+		fixup = list_entry(pos, struct phy_fixup, list);
+
+		if ((!strcmp(fixup->bus_id, bus_id)) &&
+		    ((fixup->phy_uid & phy_uid_mask) ==
+		     (phy_uid & phy_uid_mask))) {
+			list_del(&fixup->list);
+			kfree(fixup);
+			ret = 0;
+			break;
+		}
+	}
+	mutex_unlock(&phy_fixup_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(phy_unregister_fixup);
+
+/* Unregisters a fixup of any PHY with the UID in phy_uid */
+int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask)
+{
+	return phy_unregister_fixup(PHY_ANY_ID, phy_uid, phy_uid_mask);
+}
+EXPORT_SYMBOL(phy_unregister_fixup_for_uid);
+
+/* Unregisters a fixup of the PHY with id string bus_id */
+int phy_unregister_fixup_for_id(const char *bus_id)
+{
+	return phy_unregister_fixup(bus_id, PHY_ANY_UID, 0xffffffff);
+}
+EXPORT_SYMBOL(phy_unregister_fixup_for_id);
+
 /* Returns 1 if fixup matches phydev in bus_id and phy_uid.
  * Fixups can be set to match any in one or more fields.
  */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index b53177f..745661d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -859,6 +859,10 @@ int phy_register_fixup_for_id(const char *bus_id,
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 			       int (*run)(struct phy_device *));
 
+int phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask);
+int phy_unregister_fixup_for_id(const char *bus_id);
+int phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask);
+
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
 int phy_get_eee_err(struct phy_device *phydev);
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data);
-- 
2.7.4
