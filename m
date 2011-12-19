From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 12/14] mac802154: monitor device support
Date: Mon, 19 Dec 2011 19:33:52 +0300
Message-ID: <1324312434-13151-12-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Alexander Smirnov \(none\)" <alexander@Lenovo.>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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

From: Alexander Smirnov <alexander@Lenovo.(none)>

Support for monitor device intended to capture all the network
activity. This interface could be used by networks sniffers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/if_arp.h         |    1 +
 include/linux/nl802154.h       |    1 +
 include/net/wpan-phy.h         |    2 +
 net/mac802154/Makefile         |    2 +-
 net/mac802154/ieee802154_dev.c |    5 ++-
 net/mac802154/mac802154.h      |    3 +
 net/mac802154/monitor.c        |  115 ++++++++++++++++++++++++++++++++++++++++
 net/mac802154/rx.c             |    1 +
 8 files changed, 128 insertions(+), 2 deletions(-)
 create mode 100644 net/mac802154/monitor.c

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 6d722f4..f0e69c6 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -87,6 +87,7 @@
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
 #define ARPHRD_IEEE802154	  804
+#define ARPHRD_IEEE802154_MONITOR 805	/* IEEE 802.15.4 network monitor */
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 8fa29ff..6152fc9 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -126,6 +126,7 @@ enum {
 #define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
 
 enum {
+	IEEE802154_DEV_MONITOR = 1, /* for compatibility with WireShark */
 	__IEEE802154_DEV_MAX,
 };
 
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 0c2c931..368da0b 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -24,6 +24,8 @@
 #include <linux/netdevice.h>
 #include <linux/mutex.h>
 
+#define WPAN_NUM_PAGES 32
+
 struct wpan_phy {
 	struct mutex pib_lock;
 
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index 6b348b0..ec1bd3f 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o monitor.o
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 649409c..03330d3 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -126,8 +126,11 @@ static struct net_device *mac802154_add_iface(struct wpan_phy *phy,
 	struct net_device *dev;
 	int err = -ENOMEM;
 
-	/* No devices is currently supported */
 	switch (type) {
+	case IEEE802154_DEV_MONITOR:
+		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
+					name, mac802154_monitor_setup);
+		break;
 	default:
 		dev = NULL;
 		err = -EINVAL;
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index f6f6f0a..2a301d0 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -90,6 +90,9 @@ extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 int mac802154_slave_open(struct net_device *dev);
 int mac802154_slave_close(struct net_device *dev);
 
+void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb);
+void mac802154_monitor_setup(struct net_device *dev);
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 							u8 page, u8 chan);
 
diff --git a/net/mac802154/monitor.c b/net/mac802154/monitor.c
new file mode 100644
index 0000000..ccc5e81
--- /dev/null
+++ b/net/mac802154/monitor.c
@@ -0,0 +1,115 @@
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
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <linux/crc-ccitt.h>
+#include <linux/nl802154.h>
+#include <net/ieee802154.h>
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+static netdev_tx_t mac802154_monitor_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv;
+	u8 chan, page;
+
+	priv = netdev_priv(dev);
+
+	/* FIXME: locking */
+	chan = priv->hw->phy->current_channel;
+	page = priv->hw->phy->current_page;
+
+	if (chan == (u8)-1) /* not init */
+		return NETDEV_TX_OK;
+
+	BUG_ON(page >= WPAN_NUM_PAGES);
+	BUG_ON(chan >= 27);
+
+	skb->skb_iif = dev->ifindex;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	return mac802154_tx(priv->hw, skb, page, chan);
+}
+
+
+void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb)
+{
+	struct sk_buff *skb2;
+	struct mac802154_sub_if_data *sdata;
+	u16 crc = crc_ccitt(0, skb->data, skb->len);
+	u8 *data;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
+		if (sdata->type != IEEE802154_DEV_MONITOR)
+			continue;
+
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		skb2->dev = sdata->dev;
+		skb2->pkt_type = PACKET_HOST;
+		data = skb_put(skb2, 2);
+		data[0] = crc & 0xff;
+		data[1] = crc >> 8;
+
+		if (in_interrupt())
+			netif_rx(skb2);
+		else
+			netif_rx_ni(skb2);
+	}
+	rcu_read_unlock();
+}
+
+static const struct net_device_ops mac802154_monitor_ops = {
+	.ndo_open		= mac802154_slave_open,
+	.ndo_stop		= mac802154_slave_close,
+	.ndo_start_xmit		= mac802154_monitor_xmit,
+};
+
+void mac802154_monitor_setup(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv;
+
+	dev->addr_len		= 0;
+	dev->hard_header_len	= 0;
+	dev->needed_tailroom	= 2; /* FCS */
+	dev->mtu		= IEEE802154_MTU;
+	dev->tx_queue_len	= 10;
+	dev->type		= ARPHRD_IEEE802154_MONITOR;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+
+	dev->destructor		= free_netdev;
+	dev->netdev_ops		= &mac802154_monitor_ops;
+	dev->ml_priv		= &mac802154_mlme_reduced;
+
+	priv = netdev_priv(dev);
+	priv->type = IEEE802154_DEV_MONITOR;
+
+	priv->chan = -1; /* not initialized */
+	priv->page = 0; /* for compat */
+}
+
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index d469bef..335efbf 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -60,6 +60,7 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 		skb_trim(skb, skb->len - 2); /* CRC */
 	}
 
+        mac802154_monitors_rx(priv, skb);
 out:
 	dev_kfree_skb(skb);
 	return;
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
