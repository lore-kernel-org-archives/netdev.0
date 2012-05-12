From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 04/13] mac802154: TX data path
Date: Sat, 12 May 2012 17:59:16 +0400
Message-ID: <1336831165-23944-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50719 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab2ELOAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:15 -0400
Received: by mail-we0-f174.google.com with SMTP id u7so920892wey.19
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:15 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main TX data path implementation between upper and physical layers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |    5 ++
 net/mac802154/tx.c        |  113 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 119 insertions(+), 1 deletions(-)
 create mode 100644 net/mac802154/tx.c

diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index e00fe47..490beef 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 7a118e9..7606ba9 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -59,4 +59,9 @@ struct mac802154_priv {
 
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
 
+#define MAC802154_MAX_XMIT_ATTEMPTS	3
+
+netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
+			 u8 page, u8 chan);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
new file mode 100644
index 0000000..e62f915
--- /dev/null
+++ b/net/mac802154/tx.c
@@ -0,0 +1,113 @@
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
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
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
+	u8 xmit_attempts;
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
+						  xw->page,
+						  xw->chan);
+		if (res) {
+			pr_debug("set_channel failed\n");
+			goto out;
+		}
+	}
+
+	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
+
+out:
+	mutex_unlock(&xw->priv->phy->pib_lock);
+
+	if (res) {
+		if (xw->xmit_attempts++ < MAC802154_MAX_XMIT_ATTEMPTS) {
+			queue_work(xw->priv->dev_workqueue, &xw->work);
+			return;
+		} else
+			pr_debug("transmission failed for %d times",
+				  MAC802154_MAX_XMIT_ATTEMPTS);
+	}
+
+	dev_kfree_skb(xw->skb);
+
+	kfree(xw);
+}
+
+netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
+			 u8 page, u8 chan)
+{
+	struct xmit_work *work;
+
+	if (!(priv->phy->channels_supported[page] & (1 << chan)))
+		WARN_ON(1);
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
+	work->xmit_attempts = 0;
+
+	queue_work(priv->dev_workqueue, &work->work);
+
+	return NETDEV_TX_OK;
+}
-- 
1.7.2.3
