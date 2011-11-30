From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 06/12] [MAC802154] mac802154: MIB support
Date: Wed, 30 Nov 2011 17:25:05 +0300
Message-ID: <1322663105-3952-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58782 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936Ab1K3NZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:25:24 -0500
Received: by eaak14 with SMTP id k14so663554eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 05:25:22 -0800 (PST)
In-Reply-To: <20111130141827.GA3739@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for IEEE 802.15.4 management information base,
routine like setting of HW address, PAN id, channel etc...

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/linux/if.h        |    3 +
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |   22 ++++
 net/mac802154/mib.c       |  247 +++++++++++++++++++++++++++++++++++++++++++++
 net/mac802154/mib.h       |   35 +++++++
 5 files changed, 308 insertions(+), 1 deletions(-)
 create mode 100644 net/mac802154/mib.c
 create mode 100644 net/mac802154/mib.h

diff --git a/include/linux/if.h b/include/linux/if.h
index 06b6ef6..deaf14c 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -76,6 +76,9 @@
 #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
 #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
 					 * datapath port */
+
+#define IFF_IEEE802154_COORD	0x400	/* IEEE802.15.4 PAN coordinator */
+
 #define IFF_TX_SKB_SHARING	0x10000	/* The interface supports sharing
 					 * skbs on transmit */
 #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 490beef..875feb2 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o tx.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o mib.o
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 99c16ac..752ae6a 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -53,4 +53,26 @@ struct mac802154_priv {
 
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
 
+struct mac802154_sub_if_data {
+	struct list_head list; /* the ieee802154_priv->slaves list */
+
+	struct mac802154_priv *hw;
+	struct net_device *dev;
+
+	int type;
+
+	spinlock_t mib_lock;
+
+	u16 pan_id;
+	u16 short_addr;
+
+	u8 chan;
+	u8 page;
+
+	/* MAC BSN field */
+	u8 bsn;
+	/* MAC DSN field */
+	u8 dsn;
+};
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
new file mode 100644
index 0000000..8574bf6
--- /dev/null
+++ b/net/mac802154/mib.c
@@ -0,0 +1,247 @@
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
+#include "mib.h"
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
+static void hw_addr_notify(struct work_struct *work)
+{
+	struct hw_addr_filt_notify_work *nw =
+		container_of(work, struct hw_addr_filt_notify_work, work);
+	struct mac802154_priv *hw = mac802154_slave_get_priv(nw->dev);
+	int res;
+
+	res = hw->ops->set_hw_addr_filt(&hw->hw, &hw->hw.hw_filt, nw->changed);
+	if (res)
+		pr_debug("(%s): failed changed mask %lx\n",
+			__func__, nw->changed);
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
+static void phy_chan_notify(struct work_struct *work)
+{
+	struct phy_chan_notify_work *nw =
+		container_of(work, struct phy_chan_notify_work, work);
+	struct mac802154_priv *hw = mac802154_slave_get_priv(nw->dev);
+	struct mac802154_sub_if_data *priv = netdev_priv(nw->dev);
+	int res;
+
+	res = hw->ops->set_channel(&hw->hw, priv->page, priv->chan);
+	if (res)
+		pr_debug("(%s): set_channel failed\n", __func__);
+
+	kfree(nw);
+
+	return;
+}
+
+u16 mac802154_dev_get_pan_id(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->pan_id;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
+u16 mac802154_dev_get_short_addr(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->short_addr;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
+void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->pan_id = val;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if (priv->hw->ops->set_hw_addr_filt &&
+		(priv->hw->hw.hw_filt.pan_id != priv->pan_id)) {
+		priv->hw->hw.hw_filt.pan_id = priv->pan_id;
+		set_hw_addr_filt(dev, IEEE802515_PANID_CHANGED);
+	}
+}
+
+void mac802154_dev_set_pan_coord(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int pan_coord = !!(dev->priv_flags & IFF_IEEE802154_COORD);
+
+	if (priv->hw->ops->set_hw_addr_filt &&
+		(priv->hw->hw.hw_filt.pan_coord != pan_coord)) {
+		priv->hw->hw.hw_filt.pan_coord = pan_coord;
+		set_hw_addr_filt(dev, IEEE802515_PANC_CHANGED);
+	}
+}
+
+void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->short_addr = val;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if (priv->hw->ops->set_hw_addr_filt &&
+		(priv->hw->hw.hw_filt.short_addr != priv->short_addr)) {
+		priv->hw->hw.hw_filt.short_addr = priv->short_addr;
+		set_hw_addr_filt(dev, IEEE802515_SADDR_CHANGED);
+	}
+}
+
+void mac802154_dev_set_ieee_addr(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	if (priv->hw->ops->set_hw_addr_filt &&
+		memcmp(priv->hw->hw.hw_filt.ieee_addr,
+			dev->dev_addr, IEEE802154_ALEN)) {
+		memcpy(priv->hw->hw.hw_filt.ieee_addr,
+			dev->dev_addr, IEEE802154_ALEN);
+		set_hw_addr_filt(dev, IEEE802515_IEEEADDR_CHANGED);
+	}
+}
+
+void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct phy_chan_notify_work *work;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->page = page;
+	priv->chan = chan;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if (priv->hw->phy->current_channel != priv->chan ||
+	    priv->hw->phy->current_page != priv->page) {
+		work = kzalloc(sizeof(*work), GFP_ATOMIC);
+		if (!work)
+			return;
+
+		INIT_WORK(&work->work, phy_chan_notify);
+		work->dev = dev;
+		queue_work(priv->hw->dev_workqueue, &work->work);
+	}
+}
+
+u8 mac802154_dev_get_dsn(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->dsn++;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
+u8 mac802154_dev_get_bsn(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->bsn++;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
+struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->hw;
+}
+
+struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return to_phy(get_device(&priv->hw->phy->dev));
+}
diff --git a/net/mac802154/mib.h b/net/mac802154/mib.h
new file mode 100644
index 0000000..a243339
--- /dev/null
+++ b/net/mac802154/mib.h
@@ -0,0 +1,35 @@
+/*
+ * Copyright 2008 Siemens AG
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
+#ifndef MIB802154_H
+#define MIB802154_H
+
+/* MIB API */
+u8 mac802154_dev_get_dsn(const struct net_device *dev);
+u8 mac802154_dev_get_bsn(const struct net_device *dev);
+u16 mac802154_dev_get_pan_id(const struct net_device *dev);
+u16 mac802154_dev_get_short_addr(const struct net_device *dev);
+void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
+void mac802154_dev_set_pan_coord(struct net_device *dev);
+void mac802154_dev_set_short_addr(struct net_device *dev, u16 val);
+void mac802154_dev_set_ieee_addr(struct net_device *dev);
+void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan);
+struct wpan_phy *mac802154_get_phy(const struct net_device *dev);
+struct mac802154_priv *mac802154_slave_get_priv(struct net_device *dev);
+
+#endif
-- 
1.7.2.3
