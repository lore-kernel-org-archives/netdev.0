From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 08/14 v2] mac802154: basic mib support
Date: Mon, 26 Dec 2011 20:09:48 +0300
Message-ID: <1324919388-15112-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54536 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab1LZQKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:10:48 -0500
Received: by eekc4 with SMTP id c4so11133571eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:10:47 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basic support for IEEE 802.15.4 management information base.
Currently setting of HW address is implemented only.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |    3 +
 net/mac802154/mib.c       |   97 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+), 1 deletions(-)
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
index 43a02d2..deb9afa 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -93,4 +93,7 @@ extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
+/* MIB callbacks */
+void mac802154_dev_set_ieee_addr(struct net_device *dev);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
new file mode 100644
index 0000000..7c93576
--- /dev/null
+++ b/net/mac802154/mib.c
@@ -0,0 +1,97 @@
+/*
+ * Copyright 2007, 2008, 2009 Siemens AG
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
+ */
+
+#include <linux/if_arp.h>
+
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+struct phy_chan_notify_work {
+	struct work_struct work;
+	struct net_device *dev;
+};
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
+		set_hw_addr_filt(dev, IEEE802515_IEEEADDR_CHANGED);
+	}
+}
-- 
1.7.2.3
