From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 02/14 v2] mac802154: allocation of
	ieee802154 device
Date: Mon, 26 Dec 2011 20:04:07 +0300
Message-ID: <1324919047-14851-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Interface for device drivers to allocate and register ieee802154
compatible devices.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/mac802154.h        |    6 ++
 net/Kconfig                    |    1 +
 net/Makefile                   |    1 +
 net/mac802154/Kconfig          |   16 +++++
 net/mac802154/Makefile         |    2 +
 net/mac802154/ieee802154_dev.c |  125 ++++++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h      |   64 ++++++++++++++++++++
 7 files changed, 215 insertions(+), 0 deletions(-)
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/ieee802154_dev.c
 create mode 100644 net/mac802154/mac802154.h

diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 85d371c..6cf950c 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -144,4 +144,10 @@ struct ieee802154_ops {
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
index 0000000..9af54cd
--- /dev/null
+++ b/net/mac802154/ieee802154_dev.c
@@ -0,0 +1,125 @@
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
+	priv_size = ALIGN(sizeof(*priv), NETDEV_ALIGN) + priv_data_len;
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
index 0000000..12582a7
--- /dev/null
+++ b/net/mac802154/mac802154.h
@@ -0,0 +1,64 @@
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
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+#ifndef MAC802154_H
+#define MAC802154_H
+
+struct mac802154_priv {
+	struct ieee802154_dev	hw;
+	struct ieee802154_ops	*ops;
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
+	 * These flags are also modified under slaves_mtx and RTNL,
+	 * so you can read them using any of protection methods.
+	 */
+	/*
+	 * SoftMAC device is registered and running. One can add
+	 * subinterfaces.
+	 */
+	unsigned running:1;
+};
+
+enum {
+	MAC802154_DEVICE_STOPPED,
+	MAC802154_DEVICE_RUN,
+};
+
+#define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
+
+#endif /* MAC802154_H */
-- 
1.7.2.3


------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
