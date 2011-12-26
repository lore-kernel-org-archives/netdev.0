From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 12/14 v2] mac802154: monitor device support
Date: Mon, 26 Dec 2011 20:12:29 +0300
Message-ID: <1324919549-15250-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53209 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab1LZQN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:13:26 -0500
Received: by eekc4 with SMTP id c4so11134712eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:13:25 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for monitor device intended to capture all the network
activity. This interface could be used by networks sniffers.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/linux/if_arp.h         |    1 +
 include/linux/nl802154.h       |   11 ++++
 include/net/wpan-phy.h         |    3 +
 net/mac802154/Makefile         |    2 +-
 net/mac802154/ieee802154_dev.c |    5 ++-
 net/mac802154/mac802154.h      |    5 ++
 net/mac802154/monitor.c        |  115 ++++++++++++++++++++++++++++++++++++++++
 net/mac802154/rx.c             |    1 +
 8 files changed, 141 insertions(+), 2 deletions(-)
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
index e339c96..fbd0fdf 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -127,6 +127,17 @@ enum {
 
 enum {
 	__IEEE802154_DEV_INVALID = -1,
+
+	/*
+	 * Three device types are currently available in linux-zigbee
+	 * project: WPAN = 0, MONITOR = 1 and SMAC = 2.
+	 * All these values are already in use by other software (iz tools,
+	 * WireShark) so we should keep compatibility with it by assigning
+	 * proper values. Currently only monitor device is added.
+	 */
+
+	IEEE802154_DEV_MONITOR = 1,
+
 	__IEEE802154_DEV_MAX,
 };
 
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 1437c90..d0fb1ed 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -24,6 +24,9 @@
 #include <linux/netdevice.h>
 #include <linux/mutex.h>
 
+#define WPAN_NUM_PAGES		32
+#define WPAN_NUM_CHANNELS	27
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
index 27a6495..cc85410 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -129,8 +129,11 @@ mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
 	struct net_device *dev;
 	int err = -ENOMEM;
 
-	/* No devices is currently supported */
 	switch (type) {
+	case IEEE802154_DEV_MONITOR:
+		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
+				   name, mac802154_monitor_setup);
+		break;
 	default:
 		dev = NULL;
 		err = -EINVAL;
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 7d8736a..f0a0c08 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -88,11 +88,16 @@ struct mac802154_sub_if_data {
 
 #define MAC802154_MAX_XMIT_ATTEMPTS	3
 
+#define MAC802154_CHAN_NONE		(~(u8)0)
+
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 
 int mac802154_slave_open(struct net_device *dev);
 int mac802154_slave_close(struct net_device *dev);
 
+void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb);
+void mac802154_monitor_setup(struct net_device *dev);
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
diff --git a/net/mac802154/monitor.c b/net/mac802154/monitor.c
new file mode 100644
index 0000000..d76e8d0
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
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Sergey Lapin <slapin@ossfans.org>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
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
+static netdev_tx_t mac802154_monitor_xmit(struct sk_buff *skb,
+					  struct net_device *dev)
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
+	if (chan == MAC802154_CHAN_NONE) /* not initialized */
+		return NETDEV_TX_OK;
+
+	BUG_ON(page >= WPAN_NUM_PAGES);
+	BUG_ON(chan >= WPAN_NUM_CHANNELS);
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
+	priv->chan = MAC802154_CHAN_NONE; /* not initialized */
+	priv->page = 0; /* for compat */
+}
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index 3446379..3a6836c 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -58,6 +58,7 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 		skb_trim(skb, skb->len - 2); /* CRC */
 	}
 
+	mac802154_monitors_rx(priv, skb);
 out:
 	dev_kfree_skb(skb);
 	return;
-- 
1.7.2.3
