From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/17] d80211: symlinks to wiphy in sysfs
Date: Fri, 21 Apr 2006 22:11:33 +0200 (CEST)
Message-ID: <20060421201133.2AC98482C2@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10631 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932398AbWDUULF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:05 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds symlinks under /sys/net/*/wiphy pointing to
/sys/class/ieee80211/phyX.

This allows new interfaces to be added by writing a new name to e.g.
/sys/net/wlan0/wiphy/add_iface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_dev.c   |   16 +++++++++++++
 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_sysfs.c |   51 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 67 insertions(+), 1 deletions(-)

8ac63bdfba39115673abc492d7eb867c364b0fc4
diff --git a/net/d80211/ieee80211_dev.c b/net/d80211/ieee80211_dev.c
index 4302506..6278cfa 100644
--- a/net/d80211/ieee80211_dev.c
+++ b/net/d80211/ieee80211_dev.c
@@ -83,3 +83,19 @@ struct ieee80211_local *ieee80211_dev_fi
 	spin_unlock(&dev_list_lock);
 	return dev_item ? dev_item->local : NULL;
 }
+
+int ieee80211_dev_find_index(struct ieee80211_local *local)
+{
+	struct ieee80211_dev_list *dev_item;
+	int index = -1;
+
+	spin_lock(&dev_list_lock);
+	list_for_each_entry(dev_item, &dev_list, list) {
+		if (dev_item->local == local) {
+			index = dev_item->dev_index;
+			break;
+		}
+	}
+	spin_unlock(&dev_list_lock);
+	return index;
+}
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0c1eeac..c217104 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -587,6 +587,7 @@ int ieee80211_sta_disassociate(struct ne
 int ieee80211_dev_alloc_index(struct ieee80211_local *local);
 void ieee80211_dev_free_index(struct ieee80211_local *local);
 struct ieee80211_local *ieee80211_dev_find(int index);
+int ieee80211_dev_find_index(struct ieee80211_local *local);
 
 /* ieee80211_sysfs.c */
 int ieee80211_register_sysfs(struct ieee80211_local *local);
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 6e7d3ea..32fb380 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -10,6 +10,7 @@ #include <linux/kernel.h>
 #include <linux/device.h>
 #include <linux/if.h>
 #include <linux/interrupt.h>
+#include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
@@ -124,12 +125,60 @@ void ieee80211_unregister_sysfs(struct i
 	class_device_del(&local->class_dev);
 }
 
+static int ieee80211_add_netdevice(struct class_device *cd,
+				   struct class_interface *cintf)
+{
+	struct net_device *dev = container_of(cd, struct net_device, class_dev);
+	struct ieee80211_local *local = dev->priv;
+
+	if (ieee80211_dev_find_index(local) < 0)
+		return 0;
+	return sysfs_create_link(&cd->kobj, &local->class_dev.kobj, "wiphy");
+}
+
+static void ieee80211_remove_netdevice(struct class_device *cd,
+				       struct class_interface *cintf)
+{
+	struct net_device *dev = container_of(cd, struct net_device, class_dev);
+	struct ieee80211_local *local = dev->priv;
+
+	if (ieee80211_dev_find_index(local) >= 0)
+		sysfs_remove_link(&cd->kobj, "wiphy");
+}
+
+static struct class_interface ieee80211_wiphy_cintf = {
+	.add = ieee80211_add_netdevice,
+	.remove = ieee80211_remove_netdevice,
+};
+
+/* Adds class interface watching for new network devices and adding "wiphy"
+ * attribute (symlink) to them. */
+static int ieee80211_register_wiphy_cintf(void)
+{
+	ieee80211_wiphy_cintf.class = loopback_dev.class_dev.class;
+	return class_interface_register(&ieee80211_wiphy_cintf);
+}
+
+static void ieee80211_unregister_wiphy_cintf(void)
+{
+	class_interface_unregister(&ieee80211_wiphy_cintf);
+}
+
 int ieee80211_sysfs_init(void)
 {
-	return class_register(&ieee80211_class);
+	int result;
+
+	result = class_register(&ieee80211_class);
+	if (result)
+		return result;
+	result = ieee80211_register_wiphy_cintf();
+	if (result)
+		class_unregister(&ieee80211_class);
+	return result;
 }
 
 void ieee80211_sysfs_deinit(void)
 {
+	ieee80211_unregister_wiphy_cintf();
 	class_unregister(&ieee80211_class);
 }
-- 
1.3.0

