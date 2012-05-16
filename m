From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v5 08/13] mac802154: basic mib support
Date: Wed, 16 May 2012 10:50:26 +0400
Message-ID: <1337151031-5178-9-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51812 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759389Ab2EPGvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 02:51:45 -0400
Received: by mail-we0-f174.google.com with SMTP id u7so224285wey.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 23:51:45 -0700 (PDT)
In-Reply-To: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basic support for IEEE 802.15.4 management information base.
Current implementation contains a command to set HW address only.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |    3 +
 net/mac802154/mib.c       |   93 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 97 insertions(+), 1 deletions(-)
 create mode 100644 net/mac802154/mib.c

diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 4d9dd0f..6b348b0 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 7ec2821..7d9a0d4 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -95,4 +95,7 @@ extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
+/* MIB callbacks */
+void mac802154_dev_set_ieee_addr(struct net_device *dev);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
new file mode 100644
index 0000000..ab59821
--- /dev/null
+++ b/net/mac802154/mib.c
@@ -0,0 +1,93 @@
+/*
+ * Copyright 2007-2012 Siemens AG
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
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Sergey Lapin <slapin@ossfans.org>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
+ */
+
+#include <linux/if_arp.h>
+
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+struct hw_addr_filt_notify_work {
+	struct work_struct work;
+	struct net_device *dev;
+	unsigned long changed;
+};
+
+struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->hw;
+}
+
+static void hw_addr_notify(struct work_struct *work)
+{
+	struct hw_addr_filt_notify_work *nw = container_of(work,
+			struct hw_addr_filt_notify_work, work);
+	struct mac802154_priv *hw = mac802154_slave_get_priv(nw->dev);
+	int res;
+
+	res = hw->ops->set_hw_addr_filt(&hw->hw,
+					&hw->hw.hw_filt,
+					nw->changed);
+	if (res)
+		pr_debug("failed changed mask %lx\n", nw->changed);
+
+	kfree(nw);
+
+	return;
+}
+
+static void set_hw_addr_filt(struct net_device *dev, unsigned long changed)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct hw_addr_filt_notify_work *work;
+
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work)
+		return;
+
+	INIT_WORK(&work->work, hw_addr_notify);
+	work->dev = dev;
+	work->changed = changed;
+	queue_work(priv->hw->dev_workqueue, &work->work);
+
+	return;
+}
+
+void mac802154_dev_set_ieee_addr(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct mac802154_priv *mac = priv->hw;
+
+	if (mac->ops->set_hw_addr_filt &&
+	    memcmp(mac->hw.hw_filt.ieee_addr,
+		   dev->dev_addr, IEEE802154_ADDR_LEN)) {
+		memcpy(mac->hw.hw_filt.ieee_addr,
+		       dev->dev_addr, IEEE802154_ADDR_LEN);
+		set_hw_addr_filt(dev, IEEE802515_AFILT_IEEEADDR_CHANGED);
+	}
+}
-- 
1.7.2.3
