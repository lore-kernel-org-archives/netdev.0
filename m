From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 04/12] [MAC802154] mac802154: TX data path
Date: Wed, 30 Nov 2011 17:23:49 +0300
Message-ID: <1322663029-3880-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51328 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1K3NYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:24:11 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so661607eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 05:24:10 -0800 (PST)
In-Reply-To: <20111130141827.GA3739@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main TX data path implementation between upper and physical layers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/Makefile         |    2 +-
 net/mac802154/ieee802154_dev.c |    3 +-
 net/mac802154/tx.c             |  102 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 2 deletions(-)
 create mode 100644 net/mac802154/tx.c

diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index e00fe47..490beef 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 42f95b2..e90d336 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -31,7 +31,8 @@ struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
 	struct wpan_phy *phy;
 	struct mac802154_priv *priv;
 
-	if (!ops || !ops->xmit || !ops->ed || !ops->start || !ops->stop) {
+	if (!ops || !ops->xmit || !ops->ed || !ops->start || !ops->stop ||
+	    !ops->set_channel) {
 		printk(KERN_ERR
 			"Undefined IEEE802.15.4 device operations\n");
 		return NULL;
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
new file mode 100644
index 0000000..3325cde
--- /dev/null
+++ b/net/mac802154/tx.c
@@ -0,0 +1,102 @@
+/*
+ * Copyright 2007-2011 Siemens AG
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
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/crc-ccitt.h>
+
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+struct xmit_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct mac802154_priv *priv;
+	u8 page;
+	u8 chan;
+};
+
+static void mac802154_xmit_worker(struct work_struct *work)
+{
+	struct xmit_work *xw = container_of(work, struct xmit_work, work);
+	int res;
+
+	mutex_lock(&xw->priv->phy->pib_lock);
+	if (xw->priv->phy->current_channel != xw->chan ||
+	    xw->priv->phy->current_page != xw->page) {
+		res = xw->priv->ops->set_channel(&xw->priv->hw,
+				xw->page,
+				xw->chan);
+		if (res) {
+			pr_debug("(%s): set_channel failed\n", __func__);
+			goto out;
+		}
+	}
+
+	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
+
+out:
+	mutex_unlock(&xw->priv->phy->pib_lock);
+
+	/* FIXME: result processing and/or requeue!!! */
+	dev_kfree_skb(xw->skb);
+
+	kfree(xw);
+}
+
+netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
+		u8 page, u8 chan)
+{
+	struct xmit_work *work;
+
+	if (WARN_ON(!(priv->phy->channels_supported[page] &
+					(1 << chan))))
+		return NETDEV_TX_OK;
+
+	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
+		u16 crc = crc_ccitt(0, skb->data, skb->len);
+		u8 *data = skb_put(skb, 2);
+		data[0] = crc & 0xff;
+		data[1] = crc >> 8;
+	}
+
+	if (skb_cow_head(skb, priv->hw.extra_tx_headroom)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	work = kzalloc(sizeof(struct xmit_work), GFP_ATOMIC);
+	if (!work)
+		return NETDEV_TX_BUSY;
+
+	INIT_WORK(&work->work, mac802154_xmit_worker);
+	work->skb = skb;
+	work->priv = priv;
+	work->page = page;
+	work->chan = chan;
+
+	queue_work(priv->dev_workqueue, &work->work);
+
+	return NETDEV_TX_OK;
+}
-- 
1.7.2.3
