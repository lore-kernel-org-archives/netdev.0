From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 1/7] mac802154: add wpan device-class support
Date: Mon, 25 Jun 2012 17:33:11 +0400
Message-ID: <1340631197-27691-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340631197-27691-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58362 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab2FYNgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:36:39 -0400
Received: by wgbdr13 with SMTP id dr13so4119921wgb.1
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 06:36:37 -0700 (PDT)
In-Reply-To: <1340631197-27691-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every real 802.15.4 transceiver, which works with software MAC layer,
can be classified as a wpan device in this stack. So the wpan device
implementation provides missing link in datapath between the device
drivers and the Linux network queue.

According to the IEEE 802.15.4 standard each packet can be one of the
following types:
 - beacon
 - MAC layer command
 - ACK
 - data

This patch adds support for the data packet-type only, but this is
enough to perform data transmission and receiving over radio.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/linux/nl802154.h       |   14 +-
 include/net/mac802154.h        |    8 +
 net/mac802154/Makefile         |    2 +-
 net/mac802154/ieee802154_dev.c |    4 +
 net/mac802154/mac802154.h      |    4 +
 net/mac802154/mac_cmd.c        |    4 +
 net/mac802154/rx.c             |    1 +
 net/mac802154/wpan.c           |  560 ++++++++++++++++++++++++++++++++++++++++
 8 files changed, 584 insertions(+), 13 deletions(-)
 create mode 100644 net/mac802154/wpan.c

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 5a3db3a..fd4f2d1 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -130,18 +130,8 @@ enum {
 enum {
 	__IEEE802154_DEV_INVALID = -1,
 
-	 /* TODO:
-	 * Nowadays three device types supported by this stack at linux-zigbee
-	 * project: WPAN = 0, MONITOR = 1 and SMAC = 2.
-	 *
-	 * Since this stack implementation exists many years, it's definitely
-	 * bad idea to change the assigned values due to they are already used
-	 * by third-party userspace software like: iz-tools, wireshark...
-	 *
-	 * Currently only monitor device is added and initialized by '1' for
-	 * compatibility.
-	 */
-	IEEE802154_DEV_MONITOR = 1,
+	IEEE802154_DEV_WPAN,
+	IEEE802154_DEV_MONITOR,
 
 	__IEEE802154_DEV_MAX,
 };
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index c9f8ab5..d0d11df 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -21,6 +21,14 @@
 
 #include <net/af_ieee802154.h>
 
+/* General MAC frame format:
+ *  2 bytes: Frame Control
+ *  1 byte:  Sequence Number
+ * 20 bytes: Addressing fields
+ * 14 bytes: Auxiliary Security Header
+ */
+#define MAC802154_FRAME_HARD_HEADER_LEN		(2 + 1 + 20 + 14)
+
 /* The following flags are used to indicate changed address settings from
  * the stack to the hardware.
  */
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
index ec1bd3f..57cf5d1 100644
--- a/net/mac802154/Makefile
+++ b/net/mac802154/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_MAC802154)	+= mac802154.o
-mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o monitor.o
+mac802154-objs		:= ieee802154_dev.o rx.o tx.o mac_cmd.o mib.o monitor.o wpan.o
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index e3edfb0..e748aed 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -140,6 +140,10 @@ mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
 		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
 				   name, mac802154_monitor_setup);
 		break;
+	case IEEE802154_DEV_WPAN:
+		dev = alloc_netdev(sizeof(struct mac802154_sub_if_data),
+				   name, mac802154_wpan_setup);
+		break;
 	default:
 		dev = NULL;
 		err = -EINVAL;
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 789d9c9..c0efcf1 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -93,6 +93,7 @@ struct mac802154_sub_if_data {
 #define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
+extern struct ieee802154_mlme_ops mac802154_mlme_wpan;
 
 int mac802154_slave_open(struct net_device *dev);
 int mac802154_slave_close(struct net_device *dev);
@@ -100,6 +101,9 @@ int mac802154_slave_close(struct net_device *dev);
 void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb);
 void mac802154_monitor_setup(struct net_device *dev);
 
+void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb);
+void mac802154_wpan_setup(struct net_device *dev);
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 7a5d0e0..db83419 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -43,3 +43,7 @@ struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
 struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced = {
 	.get_phy = mac802154_get_phy,
 };
+
+struct ieee802154_mlme_ops mac802154_mlme_wpan = {
+	.get_phy = mac802154_get_phy,
+};
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index 4a7d76d..38548ec 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -77,6 +77,7 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 	}
 
 	mac802154_monitors_rx(priv, skb);
+	mac802154_wpans_rx(priv, skb);
 out:
 	dev_kfree_skb(skb);
 	return;
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
new file mode 100644
index 0000000..caab599
--- /dev/null
+++ b/net/mac802154/wpan.c
@@ -0,0 +1,560 @@
+/*
+ * Copyright 2007-2012 Siemens AG
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
+#include <linux/module.h>
+#include <linux/if_arp.h>
+
+#include <net/rtnetlink.h>
+#include <linux/nl802154.h>
+#include <net/af_ieee802154.h>
+#include <net/mac802154.h>
+#include <net/ieee802154_netdev.h>
+#include <net/ieee802154.h>
+#include <net/wpan-phy.h>
+
+#include "mac802154.h"
+
+static inline int mac802154_fetch_skb_u8(struct sk_buff *skb, u8 *val)
+{
+	if (unlikely(!pskb_may_pull(skb, 1)))
+		return -EINVAL;
+
+	*val = skb->data[0];
+	 skb_pull(skb, 1);
+
+	return 0;
+}
+
+static inline int mac802154_fetch_skb_u16(struct sk_buff *skb, u16 *val)
+{
+	if (unlikely(!pskb_may_pull(skb, 2)))
+		return -EINVAL;
+
+	*val = skb->data[0] | (skb->data[1] << 8);
+	skb_pull(skb, 2);
+
+	return 0;
+}
+
+static inline void mac802154_haddr_copy_swap(u8 *dest, const u8 *src)
+{
+	int i;
+	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
+		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];
+}
+
+static int
+mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct sockaddr_ieee802154 *sa =
+		(struct sockaddr_ieee802154 *)&ifr->ifr_addr;
+	int err = -ENOIOCTLCMD;
+
+	spin_lock_bh(&priv->mib_lock);
+
+	switch (cmd) {
+	case SIOCGIFADDR:
+		if (priv->pan_id == IEEE802154_PANID_BROADCAST ||
+		    priv->short_addr == IEEE802154_ADDR_BROADCAST) {
+			err = -EADDRNOTAVAIL;
+			break;
+		}
+
+		sa->family = AF_IEEE802154;
+		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
+		sa->addr.pan_id = priv->pan_id;
+		sa->addr.short_addr = priv->short_addr;
+
+		err = 0;
+		break;
+	case SIOCSIFADDR:
+		dev_warn(&dev->dev,
+			 "Using DEBUGing ioctl SIOCSIFADDR isn't recommened!\n");
+		if (sa->family != AF_IEEE802154 ||
+		    sa->addr.addr_type != IEEE802154_ADDR_SHORT ||
+		    sa->addr.pan_id == IEEE802154_PANID_BROADCAST ||
+		    sa->addr.short_addr == IEEE802154_ADDR_BROADCAST ||
+		    sa->addr.short_addr == IEEE802154_ADDR_UNDEF) {
+			err = -EINVAL;
+			break;
+		}
+
+		priv->pan_id = sa->addr.pan_id;
+		priv->short_addr = sa->addr.short_addr;
+
+		err = 0;
+		break;
+	}
+
+	spin_unlock_bh(&priv->mib_lock);
+	return err;
+}
+
+static int mac802154_wpan_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	/* FIXME: validate addr */
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	mac802154_dev_set_ieee_addr(dev);
+	return 0;
+}
+
+static int mac802154_header_create(struct sk_buff *skb,
+				   struct net_device *dev,
+				   unsigned short type,
+				   const void *_daddr,
+				   const void *_saddr,
+				   unsigned len)
+{
+	const struct ieee802154_addr *saddr = _saddr;
+	const struct ieee802154_addr *daddr = _daddr;
+	struct ieee802154_addr dev_addr;
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int pos = 2;
+	u8 *head;
+	u16 fc;
+
+	if (!daddr)
+		return -EINVAL;
+
+	head = kzalloc(MAC802154_FRAME_HARD_HEADER_LEN, GFP_KERNEL);
+	if (head == NULL)
+		return -ENOMEM;
+
+	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
+	fc = mac_cb_type(skb);
+
+	if (!saddr) {
+		spin_lock_bh(&priv->mib_lock);
+
+		if (priv->short_addr == IEEE802154_ADDR_BROADCAST ||
+		    priv->short_addr == IEEE802154_ADDR_UNDEF ||
+		    priv->pan_id == IEEE802154_PANID_BROADCAST) {
+			dev_addr.addr_type = IEEE802154_ADDR_LONG;
+			memcpy(dev_addr.hwaddr, dev->dev_addr,
+			       IEEE802154_ADDR_LEN);
+		} else {
+			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
+			dev_addr.short_addr = priv->short_addr;
+		}
+
+		dev_addr.pan_id = priv->pan_id;
+		saddr = &dev_addr;
+
+		spin_unlock_bh(&priv->mib_lock);
+	}
+
+	if (daddr->addr_type != IEEE802154_ADDR_NONE) {
+		fc |= (daddr->addr_type << IEEE802154_FC_DAMODE_SHIFT);
+
+		head[pos++] = daddr->pan_id & 0xff;
+		head[pos++] = daddr->pan_id >> 8;
+
+		if (daddr->addr_type == IEEE802154_ADDR_SHORT) {
+			head[pos++] = daddr->short_addr & 0xff;
+			head[pos++] = daddr->short_addr >> 8;
+		} else {
+			mac802154_haddr_copy_swap(head + pos, daddr->hwaddr);
+			pos += IEEE802154_ADDR_LEN;
+		}
+	}
+
+	if (saddr->addr_type != IEEE802154_ADDR_NONE) {
+		fc |= (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
+
+		if ((saddr->pan_id == daddr->pan_id) &&
+		    (saddr->pan_id != IEEE802154_PANID_BROADCAST))
+			/* PANID compression/ intra PAN */
+			fc |= IEEE802154_FC_INTRA_PAN;
+		else {
+			head[pos++] = saddr->pan_id & 0xff;
+			head[pos++] = saddr->pan_id >> 8;
+		}
+
+		if (saddr->addr_type == IEEE802154_ADDR_SHORT) {
+			head[pos++] = saddr->short_addr & 0xff;
+			head[pos++] = saddr->short_addr >> 8;
+		} else {
+			mac802154_haddr_copy_swap(head + pos, saddr->hwaddr);
+			pos += IEEE802154_ADDR_LEN;
+		}
+	}
+
+	head[0] = fc;
+	head[1] = fc >> 8;
+
+	memcpy(skb_push(skb, pos), head, pos);
+	kfree(head);
+
+	return pos;
+}
+
+static int
+mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
+{
+	const u8 *hdr = skb_mac_header(skb);
+	const u8 *tail = skb_tail_pointer(skb);
+	struct ieee802154_addr *addr = (struct ieee802154_addr *)haddr;
+	u16 fc;
+	int da_type;
+
+	if (hdr + 3 > tail)
+		goto malformed;
+
+	fc = hdr[0] | (hdr[1] << 8);
+
+	hdr += 3;
+
+	da_type = IEEE802154_FC_DAMODE(fc);
+	addr->addr_type = IEEE802154_FC_SAMODE(fc);
+
+	switch (da_type) {
+	case IEEE802154_ADDR_NONE:
+		if (fc & IEEE802154_FC_INTRA_PAN)
+			goto malformed;
+		break;
+	case IEEE802154_ADDR_LONG:
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			if (hdr + 2 > tail)
+				goto malformed;
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+
+		hdr += IEEE802154_ADDR_LEN;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			if (hdr + 2 > tail)
+				goto malformed;
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+
+		hdr += 2;
+		break;
+	default:
+		goto malformed;
+
+	}
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_NONE:
+		break;
+	case IEEE802154_ADDR_LONG:
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			if (hdr + 2 > tail)
+				goto malformed;
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+
+		mac802154_haddr_copy_swap(addr->hwaddr, hdr);
+		hdr += IEEE802154_ADDR_LEN;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			if (hdr + 2 > tail)
+				goto malformed;
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+
+		addr->short_addr = hdr[0] | (hdr[1] << 8);
+		hdr += 2;
+		break;
+	default:
+		goto malformed;
+	}
+
+	return sizeof(struct ieee802154_addr);
+
+malformed:
+	pr_debug("malformed packet\n");
+	return 0;
+}
+
+static netdev_tx_t
+mac802154_wpan_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv;
+	u8 chan, page;
+
+	priv = netdev_priv(dev);
+
+	spin_lock_bh(&priv->mib_lock);
+	chan = priv->chan;
+	page = priv->page;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if (chan == MAC802154_CHAN_NONE ||
+	    page >= WPAN_NUM_PAGES ||
+	    chan >= WPAN_NUM_CHANNELS)
+		return NETDEV_TX_OK;
+
+	skb->skb_iif = dev->ifindex;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	return mac802154_tx(priv->hw, skb, page, chan);
+}
+
+static struct header_ops mac802154_header_ops = {
+	.create		= mac802154_header_create,
+	.parse		= mac802154_header_parse,
+};
+
+static const struct net_device_ops mac802154_wpan_ops = {
+	.ndo_open		= mac802154_slave_open,
+	.ndo_stop		= mac802154_slave_close,
+	.ndo_start_xmit		= mac802154_wpan_xmit,
+	.ndo_do_ioctl		= mac802154_wpan_ioctl,
+	.ndo_set_mac_address	= mac802154_wpan_mac_addr,
+};
+
+void mac802154_wpan_setup(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv;
+
+	dev->addr_len		= IEEE802154_ADDR_LEN;
+	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
+
+	dev->hard_header_len	= MAC802154_FRAME_HARD_HEADER_LEN;
+	dev->header_ops		= &mac802154_header_ops;
+	dev->needed_tailroom	= 2; /* FCS */
+	dev->mtu		= IEEE802154_MTU;
+	dev->tx_queue_len	= 10;
+	dev->type		= ARPHRD_IEEE802154;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+
+	dev->destructor		= free_netdev;
+	dev->netdev_ops		= &mac802154_wpan_ops;
+	dev->ml_priv		= &mac802154_mlme_wpan;
+
+	priv = netdev_priv(dev);
+	priv->type = IEEE802154_DEV_WPAN;
+
+	priv->chan = MAC802154_CHAN_NONE;
+	priv->page = 0;
+
+	spin_lock_init(&priv->mib_lock);
+
+	get_random_bytes(&priv->bsn, 1);
+	get_random_bytes(&priv->dsn, 1);
+
+	priv->pan_id = IEEE802154_PANID_BROADCAST;
+	priv->short_addr = IEEE802154_ADDR_BROADCAST;
+}
+
+static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
+{
+	return netif_rx(skb);
+}
+
+static int
+mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
+{
+	pr_debug("getting packet via slave interface %s\n", sdata->dev->name);
+
+	spin_lock_bh(&sdata->mib_lock);
+
+	switch (mac_cb(skb)->da.addr_type) {
+	case IEEE802154_ADDR_NONE:
+		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
+			/* FIXME: check if we are PAN coordinator */
+			skb->pkt_type = PACKET_OTHERHOST;
+		else
+			/* ACK comes with both addresses empty */
+			skb->pkt_type = PACKET_HOST;
+		break;
+	case IEEE802154_ADDR_LONG:
+		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
+		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+			skb->pkt_type = PACKET_OTHERHOST;
+		else if (!memcmp(mac_cb(skb)->da.hwaddr, sdata->dev->dev_addr,
+				 IEEE802154_ADDR_LEN))
+			skb->pkt_type = PACKET_HOST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
+		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+			skb->pkt_type = PACKET_OTHERHOST;
+		else if (mac_cb(skb)->da.short_addr == sdata->short_addr)
+			skb->pkt_type = PACKET_HOST;
+		else if (mac_cb(skb)->da.short_addr ==
+					IEEE802154_ADDR_BROADCAST)
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+		break;
+	default:
+		break;
+	}
+
+	spin_unlock_bh(&sdata->mib_lock);
+
+	skb->dev = sdata->dev;
+
+	sdata->dev->stats.rx_packets++;
+	sdata->dev->stats.rx_bytes += skb->len;
+
+	switch (mac_cb_type(skb)) {
+	case IEEE802154_FC_TYPE_DATA:
+		return mac802154_process_data(sdata->dev, skb);
+	default:
+		pr_warning("ieee802154: bad frame received (type = %d)\n",
+			   mac_cb_type(skb));
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+}
+
+static int mac802154_parse_frame_start(struct sk_buff *skb)
+{
+	u8 *head = skb->data;
+	u16 fc;
+
+	if (mac802154_fetch_skb_u16(skb, &fc) ||
+	    mac802154_fetch_skb_u8(skb, &(mac_cb(skb)->seq)))
+		goto err;
+
+	pr_debug("fc: %04x dsn: %02x\n", fc, head[2]);
+
+	mac_cb(skb)->flags = IEEE802154_FC_TYPE(fc);
+	mac_cb(skb)->sa.addr_type = IEEE802154_FC_SAMODE(fc);
+	mac_cb(skb)->da.addr_type = IEEE802154_FC_DAMODE(fc);
+
+	if (fc & IEEE802154_FC_INTRA_PAN)
+		mac_cb(skb)->flags |= MAC_CB_FLAG_INTRAPAN;
+
+	if (mac_cb(skb)->da.addr_type != IEEE802154_ADDR_NONE) {
+		if (mac802154_fetch_skb_u16(skb, &(mac_cb(skb)->da.pan_id)))
+			goto err;
+
+		/* source PAN id compression */
+		if (mac_cb_is_intrapan(skb))
+			mac_cb(skb)->sa.pan_id = mac_cb(skb)->da.pan_id;
+
+		pr_debug("dest PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
+
+		if (mac_cb(skb)->da.addr_type == IEEE802154_ADDR_SHORT) {
+			u16 *da = &(mac_cb(skb)->da.short_addr);
+
+			if (mac802154_fetch_skb_u16(skb, da))
+				goto err;
+
+			pr_debug("destination address is short: %04x\n",
+				 mac_cb(skb)->da.short_addr);
+		} else {
+			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
+				goto err;
+
+			mac802154_haddr_copy_swap(mac_cb(skb)->da.hwaddr,
+						  skb->data);
+			skb_pull(skb, IEEE802154_ADDR_LEN);
+
+			pr_debug("destination address is hardware\n");
+		}
+	}
+
+	if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE) {
+		/* non PAN-compression, fetch source address id */
+		if (!(mac_cb_is_intrapan(skb))) {
+			u16 *sa_pan = &(mac_cb(skb)->sa.pan_id);
+
+			if (mac802154_fetch_skb_u16(skb, sa_pan))
+				goto err;
+		}
+
+		pr_debug("source PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
+
+		if (mac_cb(skb)->sa.addr_type == IEEE802154_ADDR_SHORT) {
+			u16 *sa = &(mac_cb(skb)->sa.short_addr);
+
+			if (mac802154_fetch_skb_u16(skb, sa))
+				goto err;
+
+			pr_debug("source address is short: %04x\n",
+				 mac_cb(skb)->sa.short_addr);
+		} else {
+			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
+				goto err;
+
+			mac802154_haddr_copy_swap(mac_cb(skb)->sa.hwaddr,
+						  skb->data);
+			skb_pull(skb, IEEE802154_ADDR_LEN);
+
+			pr_debug("source address is hardware\n");
+		}
+	}
+
+	return 0;
+err:
+	return -EINVAL;
+}
+
+void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
+{
+	int ret;
+	struct sk_buff *sskb;
+	struct mac802154_sub_if_data *sdata;
+
+	ret = mac802154_parse_frame_start(skb);
+	if (ret) {
+		pr_debug("got invalid frame\n");
+		return;
+	}
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &priv->slaves, list)
+	{
+		if (sdata->type != IEEE802154_DEV_WPAN)
+			continue;
+
+		sskb = skb_clone(skb, GFP_ATOMIC);
+		if (sskb)
+			mac802154_subif_frame(sdata, sskb);
+	}
+	rcu_read_unlock();
+}
-- 
1.7.2.3
