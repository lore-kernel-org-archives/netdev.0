From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 03/14] mac802154: RX data path
Date: Mon, 19 Dec 2011 19:33:43 +0300
Message-ID: <1324312434-13151-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54585 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800Ab1LSPev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:34:51 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so5551520eek.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 07:34:51 -0800 (PST)
In-Reply-To: <20111219163117.GA13123@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main RX data path implementation between physical and mac layers.
Both contexts are supported: interrupt (data processed via worker)
and non-interrupt (data processed directly).

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/ieee802154_netdev.h |    2 +
 include/net/mac802154.h         |    4 ++
 net/mac802154/Makefile          |    2 +-
 net/mac802154/rx.c              |  106 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 113 insertions(+), 1 deletions(-)
 create mode 100644 net/mac802154/rx.c

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 5743055..12a7ee4 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -26,6 +26,8 @@
 #ifndef IEEE802154_NETDEVICE_H
 #define IEEE802154_NETDEVICE_H
 
+#include <net/af_ieee802154.h>
+
 /*
  * A control block of skb passed between the ARPHRD_IEEE802154 device
  * and other stack parts.
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 2733dab..4e9f042 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -142,4 +142,8 @@ struct ieee802154_ops {
 int ieee802154_register_device(struct ieee802154_dev *dev);
 void ieee802154_unregister_device(struct ieee802154_dev *dev);
 
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi);
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb,
+		u8 lqi);
+
 #endif /* NET_MAC802154_H */
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index cda9393..e00fe47 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o
+mac802154-objs		:= ieee802154_dev.o rx.o
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
new file mode 100644
index 0000000..d469bef
--- /dev/null
+++ b/net/mac802154/rx.c
@@ -0,0 +1,106 @@
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
+ * Pavel Smolenskiy <pavel.smolenskiy@gmail.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+#include <linux/crc-ccitt.h>
+
+#include <net/mac802154.h>
+#include <net/ieee802154_netdev.h>
+
+#include "mac802154.h"
+
+static void
+mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(hw);
+
+	BUG_ON(!skb);
+
+	mac_cb(skb)->lqi = lqi;
+	skb->protocol = htons(ETH_P_IEEE802154);
+	skb_reset_mac_header(skb);
+
+	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
+
+	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
+		u16 crc;
+
+		if (skb->len < 2) {
+			pr_debug("(%s): got invalid frame\n", __func__);
+			goto out;
+		}
+		crc = crc_ccitt(0, skb->data, skb->len);
+		if (crc) {
+			pr_debug("(%s): CRC mismatch\n", __func__);
+			goto out;
+		}
+		skb_trim(skb, skb->len - 2); /* CRC */
+	}
+
+out:
+	dev_kfree_skb(skb);
+	return;
+}
+
+struct rx_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_dev *dev;
+	u8 lqi;
+};
+
+static void mac802154_rx_worker(struct work_struct *work)
+{
+	struct rx_work *rw = container_of(work, struct rx_work, work);
+	struct sk_buff *skb = rw->skb;
+
+	mac802154_subif_rx(rw->dev, skb, rw->lqi);
+	kfree(rw);
+}
+
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev,
+		struct sk_buff *skb, u8 lqi)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	struct rx_work *work = kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
+
+	if (!work)
+		return;
+
+	INIT_WORK(&work->work, mac802154_rx_worker);
+	work->skb = skb;
+	work->dev = dev;
+	work->lqi = lqi;
+
+	queue_work(priv->dev_workqueue, &work->work);
+}
+EXPORT_SYMBOL(ieee802154_rx_irqsafe);
+
+void mac802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	mac802154_subif_rx(dev, skb, lqi);
+}
+EXPORT_SYMBOL(mac802154_rx);
-- 
1.7.2.3
