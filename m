From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/14] mac802154: basic mib support
Date: Mon, 19 Dec 2011 19:33:48 +0300
Message-ID: <1324312434-13151-8-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111219163117.GA13123-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Basic support for IEEE 802.15.4 management information base.
Currently setting of HW address is implemented only.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac802154/Makefile    |    2 +-
 net/mac802154/mac802154.h |    3 +
 net/mac802154/mib.c       |   96 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 1 deletions(-)
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
index fc0aa75..d0e3d8d 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -90,4 +90,7 @@ extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 							u8 page, u8 chan);
 
+/* MIB callbacks */
+void mac802154_dev_set_ieee_addr(struct net_device *dev);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
new file mode 100644
index 0000000..1a3c913
--- /dev/null
+++ b/net/mac802154/mib.c
@@ -0,0 +1,96 @@
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
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
+ * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
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
+		&hw->hw.hw_filt, nw->changed);
+	if (res)
+		pr_debug("%s: failed changed mask %lx\n",
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
+void mac802154_dev_set_ieee_addr(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	if (priv->hw->ops->set_hw_addr_filt &&
+		memcmp(priv->hw->hw.hw_filt.ieee_addr,
+			dev->dev_addr, IEEE802154_ADDR_LEN)) {
+		memcpy(priv->hw->hw.hw_filt.ieee_addr,
+			dev->dev_addr, IEEE802154_ADDR_LEN);
+		set_hw_addr_filt(dev, IEEE802515_IEEEADDR_CHANGED);
+	}
+}
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
