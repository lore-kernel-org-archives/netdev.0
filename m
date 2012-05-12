From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 02/13] mac802154: allocation of ieee802154 device
Date: Sat, 12 May 2012 17:59:14 +0400
Message-ID: <1336831165-23944-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47024 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab2ELOAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:13 -0400
Received: by mail-wi0-f172.google.com with SMTP id hj8so359000wib.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:12 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interface for device drivers to allocate and register ieee802154
compatible device.

This code is based on net/mac80211/main.c file

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/mac802154.h        |    6 ++
 net/Kconfig                    |    1 +
 net/Makefile                   |    1 +
 net/mac802154/Kconfig          |   16 +++++
 net/mac802154/Makefile         |    2 +
 net/mac802154/ieee802154_dev.c |  146 ++++++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h      |   62 +++++++++++++++++
 7 files changed, 234 insertions(+), 0 deletions(-)
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h

diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index a846511..ef27d07 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -128,4 +128,10 @@ struct ieee802154_ops {
 				     u8 addr[IEEE802154_ADDR_LEN]);
 };
 
+struct ieee802154_dev *
+ieee802154_alloc_device(size_t priv_data_lex, struct ieee802154_ops *ops);
+void ieee802154_free_device(struct ieee802154_dev *dev);
+int ieee802154_register_device(struct ieee802154_dev *dev);
+void ieee802154_unregister_device(struct ieee802154_dev *dev);
+
 #endif /* NET_MAC802154_H */
diff --git a/net/Kconfig b/net/Kconfig
index e07272d..4c06c7c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -211,6 +211,7 @@ source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
+source "net/mac802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index ad432fa..2a97cde 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -60,6 +60,7 @@ ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
 obj-$(CONFIG_IEEE802154)	+= ieee802154/
+obj-$(CONFIG_MAC802154)		+= mac802154/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff --git a/net/mac802154/Kconfig b/net/mac802154/Kconfig
new file mode 100644
index 0000000..a967dda
--- /dev/null
+++ b/net/mac802154/Kconfig
@@ -0,0 +1,16 @@
+config MAC802154
+	tristate "Generic IEEE 802.15.4 Soft Networking Stack (mac802154)"
+	depends on IEEE802154 && EXPERIMENTAL
+	select CRC_CCITT
+	---help---
+	  This option enables the hardware independent IEEE 802.15.4
+	  networking stack for SoftMAC devices (the ones implementing
+	  only PHY level of IEEE 802.15.4 standard).
+
+	  Note: this implementation is neither certified, nor feature
+	  complete! Compatibility with other implementations hasn't
+	  been tested yet!
+
+	  If you plan to use HardMAC IEEE 802.15.4 devices, you can
+	  say N here. Alternatievly you can say M to compile it as
+	  module.
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
new file mode 100644
index 0000000..cda9393
--- /dev/null
+++ b/net/mac802154/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_MAC802154)	+= mac802154.o
+mac802154-objs		:= ieee802154_dev.o
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
new file mode 100644
index 0000000..288a2b0
--- /dev/null
+++ b/net/mac802154/ieee802154_dev.c
@@ -0,0 +1,146 @@
+/*
+ * Copyright (C) 2007-2011 Siemens AG
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
+#include <linux/netdevice.h>
+#include <net/route.h>
+
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+struct ieee802154_dev *
+ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
+{
+	struct wpan_phy *phy;
+	struct mac802154_priv *priv;
+	size_t priv_size;
+
+	if (!ops || !ops->xmit || !ops->ed || !ops->start ||
+	    !ops->stop || !ops->set_channel) {
+		printk(KERN_ERR
+			"undefined IEEE802.15.4 device operations\n");
+		return NULL;
+	}
+
+	/*
+	 * Ensure 32-byte alignment of our private data and hw private data.
+	 * We use the wpan_phy priv data for both our mac802154_priv and for
+	 * the driver's private data
+	 *
+	 * in memory it'll be like this:
+	 *
+	 * +-----------------------+
+	 * | struct wpan_phy       |
+	 * +-----------------------+
+	 * | struct mac802154_priv |
+	 * +-----------------------+
+	 * | driver's private data |
+	 * +-----------------------+
+	 *
+	 * Due to ieee802154 layer isn't aware of driver and MAC structures,
+	 * so lets allign them here.
+	 */
+
+	priv_size = ALIGN(sizeof(*priv), NETDEV_ALIGN) + priv_data_len;
+
+	phy = wpan_phy_alloc(priv_size);
+	if (!phy) {
+		printk(KERN_ERR
+			"failure to allocate master IEEE802.15.4 device\n");
+		return NULL;
+	}
+
+	priv = wpan_phy_priv(phy);
+	priv->hw.phy = priv->phy = phy;
+	priv->hw.priv = (char *)priv + ALIGN(sizeof(*priv), NETDEV_ALIGN);
+	priv->ops = ops;
+
+	INIT_LIST_HEAD(&priv->slaves);
+	mutex_init(&priv->slaves_mtx);
+
+	return &priv->hw;
+}
+EXPORT_SYMBOL(ieee802154_alloc_device);
+
+void ieee802154_free_device(struct ieee802154_dev *hw)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(hw);
+
+	wpan_phy_free(priv->phy);
+
+	mutex_destroy(&priv->slaves_mtx);
+}
+EXPORT_SYMBOL(ieee802154_free_device);
+
+int ieee802154_register_device(struct ieee802154_dev *dev)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	int rc = -ENOMEM;
+
+	priv->dev_workqueue =
+		create_singlethread_workqueue(wpan_phy_name(priv->phy));
+	if (!priv->dev_workqueue)
+		goto out;
+
+	wpan_phy_set_dev(priv->phy, priv->hw.parent);
+
+	rc = wpan_phy_register(priv->phy);
+	if (rc < 0)
+		goto out_wq;
+
+	rtnl_lock();
+
+	mutex_lock(&priv->slaves_mtx);
+	priv->running = MAC802154_DEVICE_RUN;
+	mutex_unlock(&priv->slaves_mtx);
+
+	rtnl_unlock();
+
+	return 0;
+
+out_wq:
+	destroy_workqueue(priv->dev_workqueue);
+out:
+	return rc;
+}
+EXPORT_SYMBOL(ieee802154_register_device);
+
+void ieee802154_unregister_device(struct ieee802154_dev *dev)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(dev);
+
+	flush_workqueue(priv->dev_workqueue);
+	destroy_workqueue(priv->dev_workqueue);
+
+	rtnl_lock();
+
+	mutex_lock(&priv->slaves_mtx);
+	priv->running = MAC802154_DEVICE_STOPPED;
+	mutex_unlock(&priv->slaves_mtx);
+
+	rtnl_unlock();
+
+	wpan_phy_unregister(priv->phy);
+}
+EXPORT_SYMBOL(ieee802154_unregister_device);
+
+MODULE_DESCRIPTION("IEEE 802.15.4 implementation");
+MODULE_LICENSE("GPL v2");
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
new file mode 100644
index 0000000..7a118e9
--- /dev/null
+++ b/net/mac802154/mac802154.h
@@ -0,0 +1,62 @@
+/*
+ * Copyright (C) 2007-2012 Siemens AG
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
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
+ */
+#ifndef MAC802154_H
+#define MAC802154_H
+
+struct mac802154_priv {
+	struct ieee802154_dev hw;
+	struct ieee802154_ops *ops;
+
+	struct wpan_phy *phy;
+
+	int open_count;
+	/* As in mac80211 slaves list is modified:
+	 * 1) under the RTNL
+	 * 2) protected by slaves_mtx;
+	 * 3) in an RCU manner
+	 *
+	 * So atomic readers can use any of this protection methods
+	 */
+	struct list_head	slaves;
+	struct mutex		slaves_mtx;
+	/* This one is used for scanning and other
+	 * jobs not to be interfered with serial driver */
+	struct workqueue_struct	*dev_workqueue;
+
+	/*
+	 * The following flag is also modified under slaves_mtx and RTNL,
+	 * so you can read them using any of protection methods.
+	 */
+	/*
+	 * SoftMAC device is registered and running. One can add
+	 * subinterfaces.
+	 */
+	bool running;
+};
+
+#define	MAC802154_DEVICE_STOPPED	0x00
+#define MAC802154_DEVICE_RUN		0x01
+
+#define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
+
+#endif /* MAC802154_H */
-- 
1.7.2.3
