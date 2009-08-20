From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/5] ieee802154: add a sysfs
	representation of WPAN master devices
Date: Thu, 20 Aug 2009 20:13:04 +0400
Message-ID: <1250784787-30590-3-git-send-email-dbaryshkov@gmail.com>
References: <1250784787-30590-1-git-send-email-dbaryshkov@gmail.com>
	<1250784787-30590-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1250784787-30590-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a sysfs/in-kernel representation of LR-WPAN master devices.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/wpan-phy.h      |   63 +++++++++++++++++
 net/ieee802154/Makefile     |    2 +-
 net/ieee802154/wpan-class.c |  159 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 223 insertions(+), 1 deletions(-)
 create mode 100644 include/net/wpan-phy.h
 create mode 100644 net/ieee802154/wpan-class.c

diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
new file mode 100644
index 0000000..547b1e2
--- /dev/null
+++ b/include/net/wpan-phy.h
@@ -0,0 +1,63 @@
+/*
+ * Copyright (C) 2007, 2008, 2009 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef WPAN_PHY_H
+#define WPAN_PHY_H
+
+#include <linux/netdevice.h>
+#include <linux/mutex.h>
+
+struct wpan_phy {
+	struct mutex pib_lock;
+
+	/*
+	 * This is a PIB acording to 802.15.4-2006.
+	 * We do not provide timing-related variables, as they
+	 * aren't used outside of driver
+	 */
+	u8 current_channel;
+	u8 current_page;
+	u32 channels_supported;
+	u8 transmit_power;
+	u8 cca_mode;
+
+	struct device dev;
+	int idx;
+
+	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
+};
+
+struct wpan_phy *wpan_phy_alloc(size_t priv_size);
+int wpan_phy_register(struct device *parent, struct wpan_phy *phy);
+void wpan_phy_unregister(struct wpan_phy *phy);
+void wpan_phy_free(struct wpan_phy *phy);
+
+static inline void *wpan_phy_priv(struct wpan_phy *phy)
+{
+	BUG_ON(!phy);
+	return &phy->priv;
+}
+
+struct wpan_phy *wpan_phy_find(const char *str);
+static inline const char *wpan_phy_name(struct wpan_phy *phy)
+{
+	return dev_name(&phy->dev);
+}
+#endif
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index f99338a..4068a9f 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,4 +1,4 @@
-obj-$(CONFIG_IEEE802154) +=	nl802154.o af_802154.o
+obj-$(CONFIG_IEEE802154) +=	nl802154.o af_802154.o wpan-class.o
 nl802154-y		:= netlink.o nl_policy.o
 af_802154-y		:= af_ieee802154.o raw.o dgram.o
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
new file mode 100644
index 0000000..f306604
--- /dev/null
+++ b/net/ieee802154/wpan-class.c
@@ -0,0 +1,159 @@
+/*
+ * Copyright (C) 2007, 2008, 2009 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/device.h>
+
+#include <net/wpan-phy.h>
+
+#define MASTER_SHOW_COMPLEX(name, format_string, args...)		\
+static ssize_t name ## _show(struct device *dev,			\
+			    struct device_attribute *attr, char *buf)	\
+{									\
+	struct wpan_phy *phy = container_of(dev, struct wpan_phy, dev);	\
+	int ret;							\
+									\
+	mutex_lock(&phy->pib_lock);					\
+	ret = sprintf(buf, format_string "\n", args);			\
+	mutex_unlock(&phy->pib_lock);					\
+	return ret;							\
+}
+
+#define MASTER_SHOW(field, format_string)				\
+	MASTER_SHOW_COMPLEX(field, format_string, phy->field)
+
+MASTER_SHOW(current_channel, "%d");
+MASTER_SHOW(current_page, "%d");
+MASTER_SHOW(channels_supported, "%#x");
+MASTER_SHOW_COMPLEX(transmit_power, "%d +- %d dB",
+	((signed char) (phy->transmit_power << 2)) >> 2,
+	(phy->transmit_power >> 6) ? (phy->transmit_power >> 6) * 3 : 1 );
+MASTER_SHOW(cca_mode, "%d");
+
+static struct device_attribute pmib_attrs[] = {
+	__ATTR_RO(current_channel),
+	__ATTR_RO(current_page),
+	__ATTR_RO(channels_supported),
+	__ATTR_RO(transmit_power),
+	__ATTR_RO(cca_mode),
+	{},
+};
+
+static void wpan_phy_release(struct device *d)
+{
+	struct wpan_phy *phy = container_of(d, struct wpan_phy, dev);
+	kfree(phy);
+}
+
+static struct class wpan_phy_class = {
+	.name = "ieee802154",
+	.dev_release = wpan_phy_release,
+	.dev_attrs = pmib_attrs,
+};
+
+static DEFINE_MUTEX(wpan_phy_mutex);
+static int wpan_phy_idx;
+
+static int wpan_phy_match(struct device *dev, void *data)
+{
+	return !strcmp(dev_name(dev), (const char *)data);
+}
+
+struct wpan_phy *wpan_phy_find(const char *str)
+{
+	struct device *dev;
+
+	if (WARN_ON(!str))
+		return NULL;
+
+	dev = class_find_device(&wpan_phy_class, NULL,
+			(void *)str, wpan_phy_match);
+	if (!dev)
+		return NULL;
+
+	return container_of(dev, struct wpan_phy, dev);
+}
+EXPORT_SYMBOL(wpan_phy_find);
+
+static int wpan_phy_idx_valid(int idx)
+{
+	return idx >= 0;
+}
+
+struct wpan_phy *wpan_phy_alloc(size_t priv_size)
+{
+	struct wpan_phy *phy = kzalloc(sizeof(*phy) + priv_size,
+			GFP_KERNEL);
+
+	mutex_lock(&wpan_phy_mutex);
+	phy->idx = wpan_phy_idx++;
+	if (unlikely(!wpan_phy_idx_valid(phy->idx))) {
+		wpan_phy_idx--;
+		mutex_unlock(&wpan_phy_mutex);
+		kfree(phy);
+		return NULL;
+	}
+	mutex_unlock(&wpan_phy_mutex);
+
+	mutex_init(&phy->pib_lock);
+
+	device_initialize(&phy->dev);
+	dev_set_name(&phy->dev, "wpan-phy%d", phy->idx);
+
+	phy->dev.class = &wpan_phy_class;
+
+	return phy;
+}
+EXPORT_SYMBOL(wpan_phy_alloc);
+
+int wpan_phy_register(struct device *parent, struct wpan_phy *phy)
+{
+	phy->dev.parent = parent;
+
+	return device_add(&phy->dev);
+}
+EXPORT_SYMBOL(wpan_phy_register);
+
+void wpan_phy_unregister(struct wpan_phy *phy)
+{
+	device_del(&phy->dev);
+}
+EXPORT_SYMBOL(wpan_phy_unregister);
+
+void wpan_phy_free(struct wpan_phy *phy)
+{
+	put_device(&phy->dev);
+}
+EXPORT_SYMBOL(wpan_phy_free);
+
+static int __init wpan_phy_class_init(void)
+{
+	return class_register(&wpan_phy_class);
+}
+subsys_initcall(wpan_phy_class_init);
+
+static void __exit wpan_phy_class_exit(void)
+{
+	class_unregister(&wpan_phy_class);
+}
+module_exit(wpan_phy_class_exit);
+
+MODULE_DESCRIPTION("IEEE 802.15.4 device class");
+MODULE_LICENSE("GPL v2");
+
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
