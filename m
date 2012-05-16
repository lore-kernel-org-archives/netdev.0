From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v5 03/13] mac802154: RX data path
Date: Wed, 16 May 2012 10:50:21 +0400
Message-ID: <1337151031-5178-4-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51812 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759140Ab2EPGvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 02:51:37 -0400
Received: by mail-we0-f174.google.com with SMTP id u7so224285wey.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 23:51:36 -0700 (PDT)
In-Reply-To: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main RX data path implementation between physical and mac layers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/ieee802154_netdev.h |    2 +
 include/net/mac802154.h         |    3 +
 net/mac802154/Makefile          |    2 +-
 net/mac802154/rx.c              |  113 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 119 insertions(+), 1 deletions(-)
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
index 3973075..c9f8ab5 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -130,4 +130,7 @@ void ieee802154_free_device(struct ieee802154_dev *dev);
 int ieee802154_register_device(struct ieee802154_dev *dev);
 void ieee802154_unregister_device(struct ieee802154_dev *dev);
 
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb,
+			   u8 lqi);
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
index 0000000..d15738f
--- /dev/null
+++ b/net/mac802154/rx.c
@@ -0,0 +1,113 @@
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
+/* The IEEE 802.15.4 standard defines 4 MAC packet types:
+ * - beacon frame
+ * - MAC command frame
+ * - acknowledgement frame
+ * - data frame
+ *
+ * and only the data frame should be pushed to the upper layers, other types
+ * are just internal MAC layer management information. So only data packets
+ * are going to be sent to the networking queue, all other will be processed
+ * right here by using the device workqueue.
+ */
+struct rx_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_dev *dev;
+	u8 lqi;
+};
+
+static void
+mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(hw);
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
+			pr_debug("got invalid frame\n");
+			goto out;
+		}
+		crc = crc_ccitt(0, skb->data, skb->len);
+		if (crc) {
+			pr_debug("CRC mismatch\n");
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
+static void mac802154_rx_worker(struct work_struct *work)
+{
+	struct rx_work *rw = container_of(work, struct rx_work, work);
+	struct sk_buff *skb = rw->skb;
+
+	mac802154_subif_rx(rw->dev, skb, rw->lqi);
+	kfree(rw);
+}
+
+void
+ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	struct rx_work *work;
+
+	if (!skb)
+		return;
+
+	work = kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
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
-- 
1.7.2.3
