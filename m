From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 03/14 v2] mac802154: RX data path
Date: Mon, 26 Dec 2011 20:04:52 +0300
Message-ID: <1324919092-14887-1-git-send-email-alex.bluesman.smirnov@gmail.com>
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

Main RX data path implementation between physical and mac layers.
Both contexts are supported: interrupt (data processed via worker)
and non-interrupt (data processed directly).

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154_netdev.h |    2 +
 include/net/mac802154.h         |    4 ++
 net/mac802154/Makefile          |    2 +-
 net/mac802154/rx.c              |  109 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 116 insertions(+), 1 deletions(-)
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
index 6cf950c..5eaba60 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -150,4 +150,8 @@ void ieee802154_free_device(struct ieee802154_dev *dev);
 int ieee802154_register_device(struct ieee802154_dev *dev);
 void ieee802154_unregister_device(struct ieee802154_dev *dev);
 
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi);
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
index 0000000..3446379
--- /dev/null
+++ b/net/mac802154/rx.c
@@ -0,0 +1,109 @@
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
+
+void mac802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	if (skb)
+		mac802154_subif_rx(dev, skb, lqi);
+}
+EXPORT_SYMBOL(mac802154_rx);
-- 
1.7.2.3


------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
