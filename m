From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 06/10] mac802154: add a software MAC 802.15.4 implementation
Date: Mon,  1 Jun 2009 18:54:47 +0400
Message-ID: <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
 <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:19950 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758163AbZFAOza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 10:55:30 -0400
In-Reply-To: <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of available devices are just dump radios implementing IEEE 802.15.4
PHY layer. This commit adds a common library that acts like an intermediate
layer between our socket family and drivers for those dumb devices.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Signed-off-by: Sergey Lapin <slapin@ossfans.org>
---
 include/net/ieee802154/mac802154.h |   79 ++++
 net/Kconfig                        |    1 +
 net/Makefile                       |    1 +
 net/mac802154/Kconfig              |   13 +
 net/mac802154/Makefile             |    5 +
 net/mac802154/beacon.c             |  242 +++++++++++
 net/mac802154/beacon.h             |   48 ++
 net/mac802154/beacon_hash.c        |  103 +++++
 net/mac802154/beacon_hash.h        |   40 ++
 net/mac802154/dev.c                |  843 ++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h          |   64 +++
 net/mac802154/mac_cmd.c            |  325 ++++++++++++++
 net/mac802154/main.c               |   96 ++++
 net/mac802154/mdev.c               |  283 ++++++++++++
 net/mac802154/mib.h                |   32 ++
 net/mac802154/pib.c                |   87 ++++
 net/mac802154/pib.h                |   35 ++
 net/mac802154/scan.c               |  215 +++++++++
 18 files changed, 2512 insertions(+), 0 deletions(-)
 create mode 100644 include/net/ieee802154/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/beacon.c
 create mode 100644 net/mac802154/beacon.h
 create mode 100644 net/mac802154/beacon_hash.c
 create mode 100644 net/mac802154/beacon_hash.h
 create mode 100644 net/mac802154/dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/main.c
 create mode 100644 net/mac802154/mdev.c
 create mode 100644 net/mac802154/mib.h
 create mode 100644 net/mac802154/pib.c
 create mode 100644 net/mac802154/pib.h
 create mode 100644 net/mac802154/scan.c

diff --git a/include/net/ieee802154/mac802154.h b/include/net/ieee802154/mac802154.h
new file mode 100644
index 0000000..68e48d0
--- /dev/null
+++ b/include/net/ieee802154/mac802154.h
@@ -0,0 +1,79 @@
+/*
+ * IEEE802.15.4-2003 specification
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
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
+ */
+#ifndef IEEE802154_MAC802154_H
+#define IEEE802154_MAC802154_H
+
+/* FIXME: this can be merged with const.h ? */
+typedef enum {
+	PHY_BUSY = 0, /* cca */
+	PHY_BUSY_RX, /* state */
+	PHY_BUSY_TX, /* state */
+	PHY_FORCE_TRX_OFF,
+	PHY_IDLE, /* cca */
+	PHY_INVALID_PARAMETER, /* pib get/set */
+	PHY_RX_ON, /* state */
+	PHY_SUCCESS, /* ed */
+	PHY_TRX_OFF, /* cca, ed, state */
+	PHY_TX_ON, /* cca, ed, state */
+	PHY_UNSUPPORTED_ATTRIBUTE, /* pib get/set */
+	PHY_READ_ONLY, /* pib get/set */
+
+	PHY_INVAL = -1, /* all */
+	PHY_ERROR = -2, /* all */
+} phy_status_t;
+
+struct ieee802154_dev {
+	const char *name;
+	int	extra_tx_headroom; /* headroom to reserve for tx skb */
+	void	*priv;		/* driver-specific data */
+	u32	channel_mask;
+	u8	current_channel;
+	u32 flags; /* Flags for device to set */
+	struct device *parent;
+	struct net_device *netdev; /* mwpanX device */
+};
+
+/* Checksum is in hardware and is omitted from packet */
+#define IEEE802154_FLAGS_OMIT_CKSUM	(1 << 0)
+
+struct sk_buff;
+
+struct ieee802154_ops {
+	struct module	*owner;
+	phy_status_t (*tx)(struct ieee802154_dev *dev, struct sk_buff *skb);
+	phy_status_t (*cca)(struct ieee802154_dev *dev);
+	phy_status_t (*ed)(struct ieee802154_dev *dev, u8 *level);
+	phy_status_t (*set_trx_state)(struct ieee802154_dev *dev, phy_status_t state);
+	phy_status_t (*set_channel)(struct ieee802154_dev *dev, int channel);
+	/* FIXME: PIB get/set ??? */
+};
+
+struct ieee802154_dev *ieee802154_alloc_device(void);
+int ieee802154_register_device(struct ieee802154_dev *dev, struct ieee802154_ops *ops);
+void ieee802154_unregister_device(struct ieee802154_dev *dev);
+void ieee802154_free_device(struct ieee802154_dev *dev);
+
+int __deprecated ieee802154_add_slave(struct ieee802154_dev *hw, const u8 *addr);
+
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi);
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi);
+#endif
+
diff --git a/net/Kconfig b/net/Kconfig
index 7051b97..b42d325 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -180,6 +180,7 @@ source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
+source "net/mac802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 
diff --git a/net/Makefile b/net/Makefile
index ba324ae..81115f6 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -61,6 +61,7 @@ ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
 obj-y				+= ieee802154/
+obj-y				+= mac802154/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff --git a/net/mac802154/Kconfig b/net/mac802154/Kconfig
new file mode 100644
index 0000000..4f0333a
--- /dev/null
+++ b/net/mac802154/Kconfig
@@ -0,0 +1,13 @@
+config MAC802154
+	tristate "Generic IEEE 802.15.4 Soft Networking Stack (mac802154)"
+	depends on IEEE802154 && EXPERIMENTAL
+	select CRC_ITU_T
+	---help---
+	  This option enables the hardware independent IEEE 802.15.4
+	  networking stack for SoftMAC devices (the ones implementing
+	  only PHY level of IEEE 802.15.4 standard).
+
+	  If you plan to use HardMAC IEEE 802.15.4 devices, you can
+          say N here. Alternatievly you can say M to compile it as
+	  module.
+
diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
new file mode 100644
index 0000000..253ae18
--- /dev/null
+++ b/net/mac802154/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_MAC802154) +=	mac802154.o
+mac802154-objs		:= main.o mdev.o pib.o dev.o mac_cmd.o scan.o \
+			beacon.o beacon_hash.o
+
+EXTRA_CFLAGS += -Wall -DDEBUG
diff --git a/net/mac802154/beacon.c b/net/mac802154/beacon.c
new file mode 100644
index 0000000..cb7cec3
--- /dev/null
+++ b/net/mac802154/beacon.c
@@ -0,0 +1,242 @@
+/*
+ * MAC beacon interface
+ *
+ * Copyright 2007, 2008 Siemens AG
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
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/if_arp.h>
+#include <linux/list.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/nl802154.h>
+#include <net/ieee802154/mac802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdevice.h>
+
+#include "mac802154.h"
+#include "beacon.h"
+
+/* Beacon frame format per specification is the followinf:
+ * Standard MAC frame header:
+ * FC (2) SEQ (1)
+ * Addressing (4-20)
+ * Beacon fields:
+ * <Superframe specification> (2)
+ * <GTS> (?)
+ * <Pending address> (?)
+ * <Beacon payload> (?)
+ * FCS (2)
+ *
+ * Superframe specification:
+ * bit   Value
+ * 15    Association permit
+ * 14    PAN coordinator
+ * 13    Reserved
+ * 12    Battery life extension
+ * 8-11  Final CAP slot
+ * 4-7   Superframe order
+ * 0-3   Beacon order
+ *
+ * GTS:
+ * <GTS specification> (1)
+ * <GTS directions> (0-1)
+ * <GTS list> (?)
+ *
+ * Pending address:
+ * <Pending address specification> (1)
+ * <Pending address list (?)
+ *
+ * GTS specification:
+ * bit   Value
+ * 7     GTS permit
+ * 3-6   Reserved
+ * 0-2   GTS descriptor count
+ *
+ * Pending address specification:
+ * bit   Value
+ * 7     Reserved
+ * 4-6   Number of extended addresses pendinf
+ * 3     Reserved
+ * 0-2   Number of short addresses pending
+ * */
+
+#define IEEE802154_BEACON_SF_BO_BEACONLESS	(15 << 0)
+#define IEEE802154_BEACON_SF_SO(x)		((x & 0xf) << 4)
+#define IEEE802154_BEACON_SF_SO_INACTIVE		IEEE802154_BEACON_SF_SO(15)
+#define IEEE802154_BEACON_SF_PANCOORD		(1 << 14)
+#define IEEE802154_BEACON_SF_CANASSOC		(1 << 15)
+#define IEEE802154_BEACON_GTS_COUNT(x)		(x << 0)
+#define IEEE802154_BEACON_GTS_PERMIT		(1 << 7)
+#define IEEE802154_BEACON_PA_SHORT(x)		((x & 7) << 0)
+#define IEEE802154_BEACON_PA_LONG(x)		((x & 7) << 4)
+
+/* Flags parameter */
+#define IEEE802154_BEACON_FLAG_PANCOORD		(1 << 0)
+#define IEEE802154_BEACON_FLAG_CANASSOC		(1 << 1)
+#define IEEE802154_BEACON_FLAG_GTSPERMIT		(1 << 2)
+
+struct ieee802154_address_list {
+	struct list_head list;
+	struct ieee802154_addr addr;
+};
+/*
+ * @dev device
+ * @addr destination address
+ * @saddr source address
+ * @buf beacon payload
+ * @len beacon payload size
+ * @pan_coord - if we're PAN coordinator while sending this frame
+ * @gts_permit - wheather we allow GTS requests
+ * @al address list to be provided in beacon
+ *
+ * TODO:
+ * For a beacon frame, the sequence number field shall specify a BSN.
+ * Each coordinator shall store its current
+ * BSN value in the MAC PIB attribute macBSN and initialize it to a random value.
+ * The algorithm for choosing a random number is out of the scope
+ * of this standard. The coordinator shall copy the value of the macBSN
+ * attribute into the sequence number field of a beacon frame,
+ * each time one is generated, and shall then increment macBSN by one.
+ *
+*/
+
+
+int ieee802154_send_beacon(struct net_device *dev, struct ieee802154_addr *saddr,
+		u16 pan_id, const u8 *buf, int len,
+		int flags, struct list_head *al)
+{
+	struct sk_buff *skb;
+	int err;
+	u16 sf;
+	u8 gts;
+	u8 pa_spec;
+	int addr16_cnt;
+	int addr64_cnt;
+	struct ieee802154_addr addr;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	skb = alloc_skb(LL_ALLOCATED_SPACE(dev) + len, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	MAC_CB(skb)->flags = IEEE802154_FC_TYPE_BEACON;
+	MAC_CB(skb)->seq = IEEE802154_MLME_OPS(dev)->get_bsn(dev);
+
+	addr.addr_type = IEEE802154_ADDR_NONE;
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &addr, saddr, len);
+	if (err < 0) {
+		kfree_skb(skb);
+		return err;
+	}
+	skb_reset_mac_header(skb);
+
+	/* Superframe */
+	sf = IEEE802154_BEACON_SF_BO_BEACONLESS;
+	sf |= IEEE802154_BEACON_SF_SO_INACTIVE;
+	if (flags & IEEE802154_BEACON_FLAG_PANCOORD)
+		sf |= IEEE802154_BEACON_SF_PANCOORD;
+
+	if (flags & IEEE802154_BEACON_FLAG_CANASSOC)
+		sf |= IEEE802154_BEACON_SF_CANASSOC;
+	memcpy(skb_put(skb,  sizeof(sf)), &sf, sizeof(sf));
+
+	/* TODO GTS */
+	gts = 0;
+
+	if (flags & IEEE802154_BEACON_FLAG_GTSPERMIT)
+		gts |= IEEE802154_BEACON_GTS_PERMIT;
+	memcpy(skb_put(skb, sizeof(gts)), &gts, sizeof(gts));
+
+	/* FIXME pending address */
+	addr16_cnt = 0;
+	addr64_cnt = 0;
+
+	pa_spec = IEEE802154_BEACON_PA_LONG(addr64_cnt) | IEEE802154_BEACON_PA_SHORT(addr16_cnt);
+	memcpy(skb_put(skb, sizeof(pa_spec)), &pa_spec, sizeof(pa_spec));
+
+	memcpy(skb_put(skb, len), buf, len);
+
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	return dev_queue_xmit(skb);
+}
+
+/* at entry to this function we need skb->data to point to start
+ * of beacon field and MAC frame already parsed into MAC_CB */
+
+int parse_beacon_frame(struct sk_buff *skb, u8 *buf,
+		int *flags, struct list_head *al)
+{
+	int offt = 0;
+	u8 gts_spec;
+	u8 pa_spec;
+	struct ieee802154_pandsc *pd;
+	u16 sf = skb->data[0] + (skb->data[1] << 8);
+
+	pd = kzalloc(sizeof(struct ieee802154_pandsc), GFP_KERNEL);
+
+	/* Filling-up pre-parsed values */
+	pd->lqi = MAC_CB(skb)->lqi;
+	pd->sf = sf;
+	/* FIXME: make sure we do it right */
+	memcpy(&pd->addr, &MAC_CB(skb)->da, sizeof(struct ieee802154_addr));
+
+	/* Supplying our nitifiers with data */
+	ieee802154_slave_event(skb->dev, IEEE802154_NOTIFIER_BEACON, pd);
+	ieee802154_nl_beacon_indic(skb->dev, pd->addr.pan_id, pd->addr.short_addr);
+	/* FIXME: We don't cache PAN descriptors yet */
+	kfree(pd);
+
+	offt += 2;
+	gts_spec = skb->data[offt++];
+	/* FIXME !!! */
+	if ((gts_spec & 7) != 0) {
+		pr_debug("We still don't parse GTS part properly");
+		return -ENOTSUPP;
+	}
+	pa_spec = skb->data[offt++];
+	/* FIXME !!! */
+	if (pa_spec != 0) {
+		pr_debug("We still don't parse PA part properly");
+		return -ENOTSUPP;
+	}
+
+	*flags = 0;
+
+	if (sf & IEEE802154_BEACON_SF_PANCOORD)
+		*flags |= IEEE802154_BEACON_FLAG_PANCOORD;
+
+	if (sf & IEEE802154_BEACON_SF_CANASSOC)
+		*flags |= IEEE802154_BEACON_FLAG_CANASSOC;
+	BUG_ON(skb->len - offt < 0);
+	/* FIXME */
+	if (buf && (skb->len - offt > 0))
+		memcpy(buf, skb->data + offt, skb->len - offt);
+	return 0;
+}
+
diff --git a/net/mac802154/beacon.h b/net/mac802154/beacon.h
new file mode 100644
index 0000000..0fedc93
--- /dev/null
+++ b/net/mac802154/beacon.h
@@ -0,0 +1,48 @@
+/*
+ * beacon.h
+ *
+ * Copyright (C) 2007, 2008, 2009 Siemens AG
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
+ */
+
+#ifndef IEEE802154_BEACON_H
+#define IEEE802154_BEACON_H
+
+/* Per spec; optimizations are needed */
+struct ieee802154_pandsc {
+	struct list_head	list;
+	struct ieee802154_addr	addr; /* Contains panid */
+	int			channel;
+	u16			sf;
+	bool			gts_permit;
+	u8			lqi;
+/* FIXME: Aging of stored PAN descriptors is not decided yet,
+ * because no PAN descriptor storage is implemented yet */
+	u32			timestamp;
+};
+
+int parse_beacon_frame(struct sk_buff *skb, u8 * buf,
+		int *flags, struct list_head *al);
+
+int ieee802154_send_beacon(struct net_device *dev, struct ieee802154_addr *saddr,
+		u16 pan_id, const u8 *buf, int len,
+		int flags, struct list_head *al);
+
+#endif /* IEEE802154_BEACON_H */
+
diff --git a/net/mac802154/beacon_hash.c b/net/mac802154/beacon_hash.c
new file mode 100644
index 0000000..90ea801
--- /dev/null
+++ b/net/mac802154/beacon_hash.c
@@ -0,0 +1,103 @@
+/*
+ * MAC beacon hash storage
+ *
+ * Copyright 2007, 2008 Siemens AG
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
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+
+#include "beacon_hash.h"
+
+static struct hlist_head beacon_hash[IEEE802154_BEACON_HTABLE_SIZE];
+static DEFINE_RWLOCK(beacon_hash_lock);
+
+static int beacon_hashfn(struct ieee802154_addr *coord_addr, u16 pan_addr)
+{
+	return pan_addr % IEEE802154_BEACON_HTABLE_SIZE;
+}
+
+static void __beacon_add_node(struct ieee802154_addr *coord_addr, u16 pan_addr)
+{
+	struct beacon_node *node = kzalloc(sizeof(struct beacon_node), GFP_KERNEL);
+	struct hlist_head *list = &beacon_hash[beacon_hashfn(coord_addr, pan_addr)];
+	memcpy(&node->coord_addr, coord_addr, sizeof(struct ieee802154_addr));
+	node->pan_addr = pan_addr;
+	INIT_HLIST_NODE(&node->list);
+	hlist_add_head(&node->list, list);
+}
+
+struct beacon_node *ieee802154_beacon_find_pan(struct ieee802154_addr *coord_addr,
+						u16 pan_addr)
+{
+	struct hlist_head *list;
+	struct hlist_node *tmp;
+	list = &beacon_hash[beacon_hashfn(coord_addr, pan_addr)];
+	if (hlist_empty(list))
+		return NULL;
+	hlist_for_each(tmp, list) {
+		struct beacon_node *entry = hlist_entry(tmp, struct beacon_node, list);
+		if (entry->pan_addr == pan_addr)
+			return entry;
+	}
+	return NULL;
+}
+
+void ieee802154_beacon_hash_add(struct ieee802154_addr *coord_addr)
+{
+	if (!ieee802154_beacon_find_pan(coord_addr, coord_addr->pan_id)) {
+		write_lock(&beacon_hash_lock);
+		__beacon_add_node(coord_addr, coord_addr->pan_id);
+		write_unlock(&beacon_hash_lock);
+	}
+}
+
+void ieee802154_beacon_hash_del(struct ieee802154_addr *coord_addr)
+{
+	struct beacon_node *entry = ieee802154_beacon_find_pan(coord_addr,
+								coord_addr->pan_id);
+	if (!entry)
+		return;
+	write_lock(&beacon_hash_lock);
+	hlist_del(&entry->list);
+	write_unlock(&beacon_hash_lock);
+	kfree(entry);
+}
+
+void ieee802154_beacon_hash_dump(void)
+{
+	int i;
+	struct hlist_node *tmp;
+	pr_debug("beacon hash dump begin\n");
+	read_lock(&beacon_hash_lock);
+	for (i = 0; i < IEEE802154_BEACON_HTABLE_SIZE; i++) {
+		struct beacon_node *entry;
+		hlist_for_each(tmp, &beacon_hash[i]) {
+			entry = hlist_entry(tmp, struct beacon_node, list);
+			pr_debug("PAN: %d\n", entry->pan_addr);
+		}
+	}
+	read_unlock(&beacon_hash_lock);
+	pr_debug("beacon hash dump end\n");
+}
+
diff --git a/net/mac802154/beacon_hash.h b/net/mac802154/beacon_hash.h
new file mode 100644
index 0000000..db8457c
--- /dev/null
+++ b/net/mac802154/beacon_hash.h
@@ -0,0 +1,40 @@
+/*
+ * MAC beacon hash storage
+ *
+ * Copyright 2007, 2008 Siemens AG
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
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#ifndef IEEE802154_BEACON_HASH_H
+#define IEEE802154_BEACON_HASH_H
+
+#define IEEE802154_BEACON_HTABLE_SIZE 256
+
+struct beacon_node {
+	struct hlist_node list;
+	struct ieee802154_addr coord_addr;
+	u16 pan_addr;
+};
+struct beacon_node *ieee802154_beacon_find_pan(struct ieee802154_addr *coord_addr,
+			u16 pan_addr);
+void ieee802154_beacon_hash_add(struct ieee802154_addr *coord_addr);
+void ieee802154_beacon_hash_del(struct ieee802154_addr *coord_addr);
+void ieee802154_beacon_hash_dump(void);
+#endif
+
diff --git a/net/mac802154/dev.c b/net/mac802154/dev.c
new file mode 100644
index 0000000..4e3f70f
--- /dev/null
+++ b/net/mac802154/dev.c
@@ -0,0 +1,843 @@
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
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
+ */
+
+#include <linux/net.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/termios.h>	/* For TIOCOUTQ/INQ */
+#include <linux/notifier.h>
+#include <linux/random.h>
+#include <linux/crc-itu-t.h>
+#include <net/datalink.h>
+#include <net/psnap.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/route.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac802154.h>
+#include <net/ieee802154/netdevice.h>
+#include <net/ieee802154/mac_def.h>
+
+#include "mac802154.h"
+#include "beacon.h"
+#include "beacon_hash.h"
+#include "mib.h"
+
+struct ieee802154_netdev_priv {
+	struct list_head list;
+	struct ieee802154_priv *hw;
+	struct net_device *dev;
+
+	__le16 pan_id;
+	__le16 short_addr;
+
+	u8 chan;
+
+	/* MAC BSN field */
+	u8 bsn;
+	/* MAC BSN field */
+	u8 dsn;
+
+	/* This one is used to provide notifications */
+	struct blocking_notifier_head events;
+};
+
+static int ieee802154_net_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	priv = netdev_priv(dev);
+
+	if (!(priv->hw->hw.flags & IEEE802154_FLAGS_OMIT_CKSUM)) {
+		u16 crc = bitrev16(crc_itu_t_bitreversed(0, skb->data, skb->len));
+		u8 *data = skb_put(skb, 2);
+		data[0] = crc & 0xff;
+		data[1] = crc >> 8;
+	}
+
+	PHY_CB(skb)->chan = priv->chan;
+
+	skb->iif = dev->ifindex;
+	skb->dev = priv->hw->hw.netdev;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	dev->trans_start = jiffies;
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+static int ieee802154_slave_open(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	priv = netdev_priv(dev);
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_slave_close(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv;
+	dev->priv_flags &= ~IFF_IEEE802154_COORD;
+	netif_stop_queue(dev);
+	priv = netdev_priv(dev);
+	netif_stop_queue(dev);
+	return 0;
+}
+
+
+static int ieee802154_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+	struct sockaddr_ieee802154 *sa = (struct sockaddr_ieee802154 *)&ifr->ifr_addr;
+	switch (cmd) {
+	case SIOCGIFADDR:
+		if (priv->pan_id == IEEE802154_PANID_BROADCAST || priv->short_addr == IEEE802154_ADDR_BROADCAST)
+			return -EADDRNOTAVAIL;
+
+		sa->family = AF_IEEE802154;
+		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
+		sa->addr.pan_id = priv->pan_id;
+		sa->addr.short_addr = priv->short_addr;
+		return 0;
+	case SIOCSIFADDR:
+		dev_warn(&dev->dev, "Using DEBUGing ioctl SIOCSIFADDR isn't recommened!\n");
+		if (sa->family != AF_IEEE802154 || sa->addr.addr_type != IEEE802154_ADDR_SHORT ||
+			sa->addr.pan_id == IEEE802154_PANID_BROADCAST || sa->addr.short_addr == IEEE802154_ADDR_BROADCAST || sa->addr.short_addr == IEEE802154_ADDR_UNDEF)
+			return -EINVAL;
+
+		priv->pan_id = sa->addr.pan_id;
+		priv->short_addr = sa->addr.short_addr;
+		return 0;
+	}
+	return -ENOIOCTLCMD;
+}
+
+static int ieee802154_slave_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (netif_running(dev))
+		return -EBUSY;
+	/* FIXME: validate addr */
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+static int ieee802154_header_create(struct sk_buff *skb, struct net_device *dev,
+			   unsigned short type, const void *_daddr,
+			   const void *_saddr, unsigned len)
+{
+	u8 head[24] = {};
+	int pos = 0;
+
+	u16 fc;
+	const struct ieee802154_addr *saddr = _saddr;
+	const struct ieee802154_addr *daddr = _daddr;
+	struct ieee802154_addr dev_addr;
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	fc = MAC_CB_TYPE(skb);
+	if (MAC_CB_IS_ACKREQ(skb))
+		fc |= IEEE802154_FC_ACK_REQ;
+
+	pos = 2;
+
+	head[pos++] = MAC_CB(skb)->seq; /* DSN/BSN */
+
+	if (!daddr)
+		return -EINVAL;
+
+	if (!saddr) {
+		if (priv->short_addr == IEEE802154_ADDR_BROADCAST || priv->short_addr == IEEE802154_ADDR_UNDEF || priv->pan_id == IEEE802154_PANID_BROADCAST) {
+			dev_addr.addr_type = IEEE802154_ADDR_LONG;
+			memcpy(dev_addr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+		} else {
+			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
+			dev_addr.short_addr = priv->short_addr;
+		}
+
+		dev_addr.pan_id = priv->pan_id;
+		saddr = &dev_addr;
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
+			memcpy(head + pos, daddr->hwaddr, IEEE802154_ADDR_LEN);
+			pos += IEEE802154_ADDR_LEN;
+		}
+	}
+
+	if (saddr->addr_type != IEEE802154_ADDR_NONE) {
+		fc |= (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
+
+		if ((saddr->pan_id == daddr->pan_id) && (saddr->pan_id != IEEE802154_PANID_BROADCAST))
+			fc |= IEEE802154_FC_INTRA_PAN; /* PANID compression/ intra PAN */
+		else {
+			head[pos++] = saddr->pan_id & 0xff;
+			head[pos++] = saddr->pan_id >> 8;
+		}
+
+		if (saddr->addr_type == IEEE802154_ADDR_SHORT) {
+			head[pos++] = saddr->short_addr & 0xff;
+			head[pos++] = saddr->short_addr >> 8;
+		} else {
+			memcpy(head + pos, saddr->hwaddr, IEEE802154_ADDR_LEN);
+			pos += IEEE802154_ADDR_LEN;
+		}
+	}
+
+	head[0] = fc;
+	head[1] = fc >> 8;
+
+	memcpy(skb_push(skb, pos), head, pos);
+
+	return pos;
+}
+
+static int ieee802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
+{
+	const u8 *hdr = skb_mac_header(skb), *tail = skb_tail_pointer(skb);
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
+
+	case IEEE802154_ADDR_LONG:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+		hdr += IEEE802154_ADDR_LEN;
+		break;
+
+	case IEEE802154_ADDR_SHORT:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (fc & IEEE802154_FC_INTRA_PAN) {
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+		hdr += 2;
+		break;
+
+	default:
+		goto malformed;
+
+	}
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_NONE:
+		break;
+
+	case IEEE802154_ADDR_LONG:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + IEEE802154_ADDR_LEN > tail)
+			goto malformed;
+		memcpy(addr->hwaddr, hdr, IEEE802154_ADDR_LEN);
+		hdr += IEEE802154_ADDR_LEN;
+		break;
+
+	case IEEE802154_ADDR_SHORT:
+		if (hdr + 2 > tail)
+			goto malformed;
+		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
+			addr->pan_id = hdr[0] | (hdr[1] << 8);
+			hdr += 2;
+		}
+
+		if (hdr + 2 > tail)
+			goto malformed;
+		addr->short_addr = hdr[0] | (hdr[1] << 8);
+		hdr += 2;
+		break;
+
+	default:
+		goto malformed;
+
+	}
+
+	return sizeof(struct ieee802154_addr);
+
+malformed:
+	pr_debug("malformed packet\n");
+	return 0;
+}
+
+static struct header_ops ieee802154_header_ops = {
+	.create		= ieee802154_header_create,
+	.parse		= ieee802154_header_parse,
+};
+
+static void ieee802154_netdev_setup(struct net_device *dev)
+{
+	dev->addr_len		= IEEE802154_ADDR_LEN;
+	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
+	dev->features		= NETIF_F_NO_CSUM;
+	dev->hard_header_len	= 2 + 1 + 20 + 14;
+	dev->header_ops		= &ieee802154_header_ops;
+	dev->needed_tailroom	= 2; /* FCS */
+	dev->mtu		= 127;
+	dev->tx_queue_len	= 10;
+	dev->type		= ARPHRD_IEEE802154;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+}
+
+static const struct net_device_ops ieee802154_slave_ops = {
+	.ndo_open		= ieee802154_slave_open,
+	.ndo_stop		= ieee802154_slave_close,
+	.ndo_start_xmit		= ieee802154_net_xmit,
+	.ndo_do_ioctl		= ieee802154_slave_ioctl,
+	.ndo_set_mac_address	= ieee802154_slave_mac_addr,
+};
+
+int ieee802154_add_slave(struct ieee802154_dev *hw, const u8 *addr)
+{
+	struct net_device *dev;
+	struct ieee802154_netdev_priv *priv;
+	struct ieee802154_priv *ipriv = ieee802154_to_priv(hw);
+	int err;
+
+	ASSERT_RTNL();
+
+	dev = alloc_netdev(sizeof(struct ieee802154_netdev_priv),
+			"wpan%d", ieee802154_netdev_setup);
+	if (!dev) {
+		printk(KERN_ERR "Failure to initialize IEEE802154 device\n");
+		return -ENOMEM;
+	}
+	priv = netdev_priv(dev);
+	priv->dev = dev;
+	priv->hw = ipriv;
+
+	get_random_bytes(&priv->bsn, 1);
+	get_random_bytes(&priv->dsn, 1);
+
+	BLOCKING_INIT_NOTIFIER_HEAD(&priv->events);
+	memcpy(dev->dev_addr, addr, dev->addr_len);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+	dev->priv_flags = IFF_SLAVE_INACTIVE;
+	dev->netdev_ops = &ieee802154_slave_ops;
+	dev->ml_priv = &mac802154_mlme;
+
+	priv->pan_id = IEEE802154_PANID_BROADCAST;
+	priv->short_addr = IEEE802154_ADDR_BROADCAST;
+
+	dev_hold(ipriv->hw.netdev);
+
+	dev->needed_headroom = ipriv->hw.extra_tx_headroom;
+
+	spin_lock(&ipriv->slaves_lock);
+	list_add_tail(&priv->list, &ipriv->slaves);
+	spin_unlock(&ipriv->slaves_lock);
+	/*
+	 * If the name is a format string the caller wants us to do a
+	 * name allocation.
+	 */
+	if (strchr(dev->name, '%')) {
+		err = dev_alloc_name(dev, dev->name);
+		if (err < 0)
+			goto out;
+	}
+
+	SET_NETDEV_DEV(dev, &ipriv->hw.netdev->dev);
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out;
+
+	return dev->ifindex;
+out:
+	return err;
+}
+EXPORT_SYMBOL(ieee802154_add_slave);
+
+static void __ieee802154_del_slave(struct ieee802154_netdev_priv *ndp)
+{
+	struct net_device *dev = ndp->dev;
+	dev_put(ndp->hw->hw.netdev);
+	unregister_netdev(ndp->dev);
+
+	spin_lock(&ndp->hw->slaves_lock);
+	list_del(&ndp->list);
+	spin_unlock(&ndp->hw->slaves_lock);
+
+	free_netdev(dev);
+}
+
+void ieee802154_drop_slaves(struct ieee802154_dev *hw)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
+	struct ieee802154_netdev_priv *ndp, *next;
+
+	spin_lock(&priv->slaves_lock);
+	list_for_each_entry_safe(ndp, next, &priv->slaves, list) {
+		spin_unlock(&priv->slaves_lock);
+		__ieee802154_del_slave(ndp);
+		spin_lock(&priv->slaves_lock);
+	}
+	spin_unlock(&priv->slaves_lock);
+}
+
+static int ieee802154_send_ack(struct sk_buff *skb)
+{
+	u16 fc = IEEE802154_FC_TYPE_ACK;
+	u8 *data;
+	struct sk_buff *ackskb;
+
+	BUG_ON(!skb || !skb->dev);
+	BUG_ON(!MAC_CB_IS_ACKREQ(skb));
+
+	ackskb = alloc_skb(LL_ALLOCATED_SPACE(skb->dev) + 3, GFP_ATOMIC);
+
+	skb_reserve(ackskb, LL_RESERVED_SPACE(skb->dev));
+
+	skb_reset_network_header(ackskb);
+
+	data = skb_push(ackskb, 3);
+	data[0] = fc & 0xff;
+	data[1] = (fc >> 8) & 0xff;
+	data[2] = MAC_CB(skb)->seq;
+
+	skb_reset_mac_header(ackskb);
+
+	ackskb->dev = skb->dev;
+	pr_debug("ACK frame to %s device\n", skb->dev->name);
+	ackskb->protocol = htons(ETH_P_IEEE802154);
+	/* FIXME */
+
+	return dev_queue_xmit(ackskb);
+}
+
+static int ieee802154_process_beacon(struct net_device *dev, struct sk_buff *skb)
+{
+	int flags;
+	int ret;
+	ret = parse_beacon_frame(skb, NULL, &flags, NULL);
+
+	/* Here we have cb->sa = coordinator address, and PAN address */
+
+	if (ret < 0) {
+		ret = NET_RX_DROP;
+		goto fail;
+	}
+	dev_dbg(&dev->dev, "got beacon from pan %d\n", MAC_CB(skb)->sa.pan_id);
+	ieee802154_beacon_hash_add(&MAC_CB(skb)->sa);
+	ieee802154_beacon_hash_dump();
+	ret = NET_RX_SUCCESS;
+fail:
+	kfree_skb(skb);
+	return ret;
+}
+
+static int ieee802154_process_ack(struct net_device *dev, struct sk_buff *skb)
+{
+	pr_debug("got ACK for SEQ=%d\n", MAC_CB(skb)->seq);
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+}
+
+static int ieee802154_process_data(struct net_device *dev, struct sk_buff *skb)
+{
+	return netif_rx(skb);
+}
+
+static int ieee802154_subif_frame(struct ieee802154_netdev_priv *ndp, struct sk_buff *skb)
+{
+	pr_debug("%s Getting packet via slave interface %s\n",
+				__func__, ndp->dev->name);
+
+	switch (MAC_CB(skb)->da.addr_type) {
+	case IEEE802154_ADDR_NONE:
+		if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
+			/* FIXME: check if we are PAN coordinator :) */
+			skb->pkt_type = PACKET_OTHERHOST;
+		else
+			/* ACK comes with both addresses empty */
+			skb->pkt_type = PACKET_HOST;
+		break;
+	case IEEE802154_ADDR_LONG:
+		if (MAC_CB(skb)->da.pan_id != ndp->pan_id && MAC_CB(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+			skb->pkt_type = PACKET_OTHERHOST;
+		else if (!memcmp(MAC_CB(skb)->da.hwaddr, ndp->dev->dev_addr, IEEE802154_ADDR_LEN))
+			skb->pkt_type = PACKET_HOST;
+		else if (!memcmp(MAC_CB(skb)->da.hwaddr, ndp->dev->broadcast, IEEE802154_ADDR_LEN))
+			/* FIXME: is this correct? */
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (MAC_CB(skb)->da.pan_id != ndp->pan_id && MAC_CB(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+			skb->pkt_type = PACKET_OTHERHOST;
+		else if (MAC_CB(skb)->da.short_addr == ndp->short_addr)
+			skb->pkt_type = PACKET_HOST;
+		else if (MAC_CB(skb)->da.short_addr == IEEE802154_ADDR_BROADCAST)
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_OTHERHOST;
+		break;
+	}
+
+	skb->dev = ndp->dev;
+
+	if (MAC_CB_IS_ACKREQ(skb))
+		ieee802154_send_ack(skb);
+
+	switch (MAC_CB_TYPE(skb)) {
+	case IEEE802154_FC_TYPE_BEACON:
+		return ieee802154_process_beacon(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_ACK:
+		return ieee802154_process_ack(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_MAC_CMD:
+		return ieee802154_process_cmd(ndp->dev, skb);
+	case IEEE802154_FC_TYPE_DATA:
+		return ieee802154_process_data(ndp->dev, skb);
+	default:
+		pr_warning("ieee802154: Bad frame received (type = %d)\n", MAC_CB_TYPE(skb));
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+}
+
+static u8 fetch_skb_u8(struct sk_buff *skb)
+{
+	u8 ret;
+
+	BUG_ON(skb->len < 1);
+
+	ret = skb->data[0];
+	skb_pull(skb, 1);
+
+	return ret;
+}
+
+static u16 fetch_skb_u16(struct sk_buff *skb)
+{
+	u16 ret;
+
+	BUG_ON(skb->len < 2);
+
+	ret = skb->data[0] + (skb->data[1] * 256);
+	skb_pull(skb, 2);
+	return ret;
+}
+
+static void fetch_skb_u64(struct sk_buff *skb, void *data)
+{
+	BUG_ON(skb->len < IEEE802154_ADDR_LEN);
+
+	memcpy(data, skb->data, IEEE802154_ADDR_LEN);
+	skb_pull(skb, IEEE802154_ADDR_LEN);
+}
+
+#define IEEE802154_FETCH_U8(skb, var)		\
+	do {					\
+		if (skb->len < 1)		\
+			goto exit_error;	\
+		var = fetch_skb_u8(skb);	\
+	} while (0)
+
+#define IEEE802154_FETCH_U16(skb, var)		\
+	do {					\
+		if (skb->len < 2)		\
+			goto exit_error;	\
+		var = fetch_skb_u16(skb);	\
+	} while (0)
+
+#define IEEE802154_FETCH_U64(skb, var)			\
+	do {						\
+		if (skb->len < IEEE802154_ADDR_LEN)	\
+			goto exit_error;		\
+		fetch_skb_u64(skb, &var);		\
+	} while (0)
+
+static int parse_frame_start(struct sk_buff *skb)
+{
+	u8 *head = skb->data;
+	u16 fc;
+
+	if (skb->len < 3) {
+		pr_debug("frame size %d bytes is too short\n", skb->len);
+		return -EINVAL;
+	}
+
+	IEEE802154_FETCH_U16(skb, fc);
+	IEEE802154_FETCH_U8(skb, MAC_CB(skb)->seq);
+
+	pr_debug("%s: %04x dsn%02x\n", __func__, fc, head[2]);
+
+	MAC_CB(skb)->flags = IEEE802154_FC_TYPE(fc);
+
+	if (fc & IEEE802154_FC_ACK_REQ) {
+		pr_debug("%s(): ACKNOWLEDGE required\n", __func__);
+		MAC_CB(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+	}
+
+	if (fc & IEEE802154_FC_SECEN)
+		MAC_CB(skb)->flags |= MAC_CB_FLAG_SECEN;
+
+	if (fc & IEEE802154_FC_INTRA_PAN)
+		MAC_CB(skb)->flags |= MAC_CB_FLAG_INTRAPAN;
+
+	/* TODO */
+	if (MAC_CB_IS_SECEN(skb)) {
+		pr_info("security support is not implemented\n");
+		return -EINVAL;
+	}
+
+	MAC_CB(skb)->sa.addr_type = IEEE802154_FC_SAMODE(fc);
+	if (MAC_CB(skb)->sa.addr_type == IEEE802154_ADDR_NONE)
+		pr_debug("%s(): src addr_type is NONE\n", __func__);
+
+	MAC_CB(skb)->da.addr_type = IEEE802154_FC_DAMODE(fc);
+	if (MAC_CB(skb)->da.addr_type == IEEE802154_ADDR_NONE)
+		pr_debug("%s(): dst addr_type is NONE\n", __func__);
+
+	if (IEEE802154_FC_TYPE(fc) == IEEE802154_FC_TYPE_ACK) {
+		/* ACK can only have NONE-type addresses */
+		if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_NONE ||
+		    MAC_CB(skb)->da.addr_type != IEEE802154_ADDR_NONE)
+			return -EINVAL;
+	}
+
+	if (MAC_CB(skb)->da.addr_type != IEEE802154_ADDR_NONE) {
+		IEEE802154_FETCH_U16(skb, MAC_CB(skb)->da.pan_id);
+
+		if (MAC_CB_IS_INTRAPAN(skb)) { /* ! panid compress */
+			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n", __func__);
+			MAC_CB(skb)->sa.pan_id = MAC_CB(skb)->da.pan_id;
+			pr_debug("%s(): src PAN address %04x\n",
+					__func__, MAC_CB(skb)->sa.pan_id);
+		}
+
+		pr_debug("%s(): dst PAN address %04x\n",
+				__func__, MAC_CB(skb)->da.pan_id);
+
+		if (MAC_CB(skb)->da.addr_type == IEEE802154_ADDR_SHORT) {
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->da.short_addr);
+			pr_debug("%s(): dst SHORT address %04x\n",
+					__func__, MAC_CB(skb)->da.short_addr);
+
+		} else {
+			IEEE802154_FETCH_U64(skb, MAC_CB(skb)->da.hwaddr);
+			pr_debug("%s(): dst hardware addr\n", __func__);
+		}
+	}
+
+	if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_NONE) {
+		pr_debug("%s(): got src non-NONE address\n", __func__);
+		if (!(MAC_CB_IS_INTRAPAN(skb))) { /* ! panid compress */
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->sa.pan_id);
+			pr_debug("%s(): src IEEE802154_FC_INTRA_PAN\n", __func__);
+		}
+
+		if (MAC_CB(skb)->sa.addr_type == IEEE802154_ADDR_SHORT) {
+			IEEE802154_FETCH_U16(skb, MAC_CB(skb)->sa.short_addr);
+			pr_debug("%s(): src IEEE802154_ADDR_SHORT\n", __func__);
+		} else {
+			IEEE802154_FETCH_U64(skb, MAC_CB(skb)->sa.hwaddr);
+			pr_debug("%s(): src hardware addr\n", __func__);
+		}
+	}
+
+	return 0;
+
+exit_error:
+	return -EINVAL;
+}
+
+void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
+	struct ieee802154_netdev_priv *ndp, *prev = NULL;
+	int ret;
+
+	BUILD_BUG_ON(sizeof(struct ieee802154_mac_cb) > sizeof(skb->cb));
+	pr_debug("%s()\n", __func__);
+
+	ret = parse_frame_start(skb); /* 3 bytes pulled after this */
+	if (ret) {
+		pr_debug("%s(): Got invalid frame\n", __func__);
+		goto out;
+	}
+
+	if (!(priv->hw.flags & IEEE802154_FLAGS_OMIT_CKSUM)) {
+		if (skb->len < 2) {
+			pr_debug("%s(): Got invalid frame\n", __func__);
+			goto out;
+		}
+		/* FIXME: check CRC if necessary */
+		skb_trim(skb, skb->len - 2); /* CRC */
+	}
+
+	pr_debug("%s() frame %d\n", __func__, MAC_CB_TYPE(skb));
+
+	spin_lock(&priv->slaves_lock);
+	list_for_each_entry(ndp, &priv->slaves, list)
+	{
+		if (prev) {
+			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+			if (skb2)
+				ieee802154_subif_frame(prev, skb2);
+		}
+
+		prev = ndp;
+	}
+
+	if (prev)
+		ieee802154_subif_frame(prev, skb);
+	else
+		kfree_skb(skb);
+	spin_unlock(&priv->slaves_lock);
+
+	return;
+
+out:
+	kfree_skb(skb);
+	return;
+}
+
+u16 ieee802154_dev_get_pan_id(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->pan_id;
+}
+
+u16 ieee802154_dev_get_short_addr(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->short_addr;
+}
+
+void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	priv->pan_id = val;
+}
+void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	priv->short_addr = val;
+}
+void ieee802154_dev_set_channel(struct net_device *dev, u8 val)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	priv->chan = val;
+}
+
+u8 ieee802154_dev_get_dsn(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->dsn++;
+}
+
+u8 ieee802154_dev_get_bsn(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->bsn++;
+}
+
+int ieee802154_slave_register_notifier(struct net_device *dev, struct notifier_block *nb)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+	return blocking_notifier_chain_register(&priv->events, nb);
+}
+int ieee802154_slave_unregister_notifier(struct net_device *dev, struct notifier_block *nb)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+	return blocking_notifier_chain_unregister(&priv->events, nb);
+}
+int ieee802154_slave_event(struct net_device *dev, int event, void *data)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+	return blocking_notifier_call_chain(&priv->events, event, data);
+}
+
+struct ieee802154_priv *ieee802154_slave_get_priv(struct net_device *dev)
+{
+	struct ieee802154_netdev_priv *priv = netdev_priv(dev);
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->hw;
+}
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
new file mode 100644
index 0000000..2f346cd
--- /dev/null
+++ b/net/mac802154/mac802154.h
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) 2007, 2008 Siemens AG
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
+ */
+#ifndef MAC802154_H
+#define MAC802154_H
+
+struct ieee802154_priv {
+	struct ieee802154_dev	hw;
+	struct ieee802154_ops	*ops;
+	struct list_head	slaves;
+	spinlock_t		slaves_lock;
+	/* This one is used for scanning and other
+	 * jobs not to be interfered with serial driver */
+	struct workqueue_struct	*dev_workqueue;
+};
+
+#define ieee802154_to_priv(_hw)	container_of(_hw, struct ieee802154_priv, hw)
+
+void ieee802154_drop_slaves(struct ieee802154_dev *hw);
+
+void ieee802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb);
+
+struct ieee802154_phy_cb {
+	u8 lqi;
+	u8 chan;
+};
+
+#define PHY_CB(skb)	((struct ieee802154_phy_cb *)(skb)->cb)
+
+extern struct ieee802154_mlme_ops mac802154_mlme;
+
+int ieee802154_mlme_scan_req(struct net_device *dev, u8 type, u32 channels, u8 duration);
+
+int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb);
+int ieee802154_send_beacon_req(struct net_device *dev);
+
+struct ieee802154_priv *ieee802154_slave_get_priv(struct net_device *dev);
+
+/* FIXME: this interface should be rethought ! */
+struct notifier_block;
+int ieee802154_slave_register_notifier(struct net_device *dev, struct notifier_block *nb);
+int ieee802154_slave_unregister_notifier(struct net_device *dev, struct notifier_block *nb);
+int ieee802154_slave_event(struct net_device *dev, int event, void *data);
+#define IEEE802154_NOTIFIER_BEACON		0x0
+
+#endif
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
new file mode 100644
index 0000000..0be38fb
--- /dev/null
+++ b/net/mac802154/mac_cmd.c
@@ -0,0 +1,325 @@
+/*
+ * MAC commands interface
+ *
+ * Copyright 2007, 2008 Siemens AG
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
+ * Sergey Lapin <sergey.lapin@siemens.com>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdevice.h>
+#include <net/ieee802154/nl802154.h>
+
+#include "mac802154.h"
+#include "beacon.h"
+#include "mib.h"
+
+static int ieee802154_cmd_beacon_req(struct sk_buff *skb)
+{
+	struct ieee802154_addr saddr; /* jeez */
+	int flags = 0;
+	if (skb->len != 1)
+		return -EINVAL;
+
+	if (skb->pkt_type != PACKET_HOST)
+		return 0;
+
+	/* Checking if we're really PAN coordinator
+	 * before sending beacons */
+	if (!(skb->dev->priv_flags & IFF_IEEE802154_COORD))
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_NONE ||
+	    MAC_CB(skb)->da.addr_type != IEEE802154_ADDR_SHORT ||
+	    MAC_CB(skb)->da.pan_id != IEEE802154_PANID_BROADCAST ||
+	    MAC_CB(skb)->da.short_addr != IEEE802154_ADDR_BROADCAST)
+		return -EINVAL;
+
+
+	/* 7 bytes of MHR and 1 byte of command frame identifier
+	 * We have no information in this command to proceed with.
+	 * we need to submit beacon as answer to this. */
+
+	return ieee802154_send_beacon(skb->dev, &saddr, IEEE802154_MLME_OPS(skb->dev)->get_pan_id(skb->dev),
+			NULL, 0, flags, NULL);
+}
+
+static int ieee802154_cmd_assoc_req(struct sk_buff *skb)
+{
+	u8 cap;
+
+	if (skb->len != 2)
+		return -EINVAL;
+
+	if (skb->pkt_type != PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_LONG ||
+	    MAC_CB(skb)->sa.pan_id != IEEE802154_PANID_BROADCAST)
+		return -EINVAL;
+
+	/* FIXME: check that we allow incoming ASSOC requests by consulting MIB */
+
+	cap = skb->data[1];
+
+	return ieee802154_nl_assoc_indic(skb->dev, &MAC_CB(skb)->sa, cap);
+}
+
+static int ieee802154_cmd_assoc_resp(struct sk_buff *skb)
+{
+	u8 status;
+	u16 short_addr;
+
+	if (skb->len != 4)
+		return -EINVAL;
+
+	if (skb->pkt_type != PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_LONG ||
+	    MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_LONG ||
+	    !(MAC_CB(skb)->flags & MAC_CB_FLAG_INTRAPAN))
+		return -EINVAL;
+
+	/* FIXME: check that we requested association ? */
+
+	status = skb->data[3];
+	short_addr = skb->data[1] | (skb->data[2] << 8);
+	pr_info("Received ASSOC-RESP status %x, addr %hx\n", status, short_addr);
+	if (status) {
+		ieee802154_dev_set_short_addr(skb->dev, IEEE802154_ADDR_BROADCAST);
+		ieee802154_dev_set_pan_id(skb->dev, IEEE802154_PANID_BROADCAST);
+	} else
+		ieee802154_dev_set_short_addr(skb->dev, short_addr);
+
+	return ieee802154_nl_assoc_confirm(skb->dev, short_addr, status);
+}
+
+static int ieee802154_cmd_disassoc_notify(struct sk_buff *skb)
+{
+	u8 reason;
+
+	if (skb->len != 2)
+		return -EINVAL;
+
+	if (skb->pkt_type != PACKET_HOST)
+		return 0;
+
+	if (MAC_CB(skb)->sa.addr_type != IEEE802154_ADDR_LONG ||
+	    (MAC_CB(skb)->da.addr_type != IEEE802154_ADDR_LONG &&
+	     MAC_CB(skb)->da.addr_type != IEEE802154_ADDR_SHORT) ||
+	    MAC_CB(skb)->sa.pan_id != MAC_CB(skb)->da.pan_id)
+		return -EINVAL;
+
+	reason = skb->data[1];
+
+	/* FIXME: checks if this was our coordinator and the disassoc us */
+	/* FIXME: if we device, one should receive ->da and not ->sa */
+	/* FIXME: the status should also help */
+
+	return ieee802154_nl_disassoc_indic(skb->dev, &MAC_CB(skb)->sa, reason);
+}
+
+int ieee802154_process_cmd(struct net_device *dev, struct sk_buff *skb)
+{
+	u8 cmd;
+
+	if (skb->len < 1) {
+		pr_warning("Uncomplete command frame!\n");
+		goto drop;
+	}
+
+	cmd = *(skb->data);
+	pr_debug("Command %02x on device %s\n", cmd, dev->name);
+
+	switch (cmd) {
+	case IEEE802154_CMD_ASSOCIATION_REQ:
+		ieee802154_cmd_assoc_req(skb);
+		break;
+	case IEEE802154_CMD_ASSOCIATION_RESP:
+		ieee802154_cmd_assoc_resp(skb);
+		break;
+	case IEEE802154_CMD_DISASSOCIATION_NOTIFY:
+		ieee802154_cmd_disassoc_notify(skb);
+		break;
+	case IEEE802154_CMD_BEACON_REQ:
+		ieee802154_cmd_beacon_req(skb);
+		break;
+	default:
+		pr_debug("Frame type is not supported yet\n");
+		goto drop;
+	}
+
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static int ieee802154_send_cmd(struct net_device *dev,
+		struct ieee802154_addr *addr, struct ieee802154_addr *saddr,
+		const u8 *buf, int len)
+{
+	struct sk_buff *skb;
+	int err;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	skb = alloc_skb(LL_ALLOCATED_SPACE(dev) + len, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	MAC_CB(skb)->flags = IEEE802154_FC_TYPE_MAC_CMD | MAC_CB_FLAG_ACKREQ;
+	MAC_CB(skb)->seq = IEEE802154_MLME_OPS(dev)->get_dsn(dev);
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, addr, saddr, len);
+	if (err < 0) {
+		kfree_skb(skb);
+		return err;
+	}
+
+	skb_reset_mac_header(skb);
+	memcpy(skb_put(skb, len), buf, len);
+
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	return dev_queue_xmit(skb);
+}
+
+int ieee802154_send_beacon_req(struct net_device *dev)
+{
+	struct ieee802154_addr addr;
+	struct ieee802154_addr saddr;
+	u8 cmd = IEEE802154_CMD_BEACON_REQ;
+	addr.addr_type = IEEE802154_ADDR_SHORT;
+	addr.short_addr = IEEE802154_ADDR_BROADCAST;
+	addr.pan_id = IEEE802154_PANID_BROADCAST;
+	saddr.addr_type = IEEE802154_ADDR_NONE;
+	return ieee802154_send_cmd(dev, &addr, &saddr, &cmd, 1);
+}
+
+
+static int ieee802154_mlme_assoc_req(struct net_device *dev, struct ieee802154_addr *addr, u8 channel, u8 cap)
+{
+	struct ieee802154_addr saddr;
+	u8 buf[2];
+	int pos = 0;
+
+	saddr.addr_type = IEEE802154_ADDR_LONG;
+	saddr.pan_id = IEEE802154_PANID_BROADCAST;
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+
+	/* FIXME: set PIB/MIB info */
+	ieee802154_dev_set_pan_id(dev, addr->pan_id);
+	ieee802154_dev_set_channel(dev, channel);
+
+	buf[pos++] = IEEE802154_CMD_ASSOCIATION_REQ;
+	buf[pos++] = cap;
+
+	return ieee802154_send_cmd(dev, addr, &saddr, buf, pos);
+}
+
+static int ieee802154_mlme_assoc_resp(struct net_device *dev, struct ieee802154_addr *addr, u16 short_addr, u8 status)
+{
+	struct ieee802154_addr saddr;
+	u8 buf[4];
+	int pos = 0;
+
+	saddr.addr_type = IEEE802154_ADDR_LONG;
+	saddr.pan_id = addr->pan_id;
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+	buf[pos++] = IEEE802154_CMD_ASSOCIATION_RESP;
+	buf[pos++] = short_addr;
+	buf[pos++] = short_addr >> 8;
+	buf[pos++] = status;
+
+	return ieee802154_send_cmd(dev, addr, &saddr, buf, pos);
+}
+
+static int ieee802154_mlme_disassoc_req(struct net_device *dev, struct ieee802154_addr *addr, u8 reason)
+{
+	struct ieee802154_addr saddr;
+	u8 buf[2];
+	int pos = 0;
+	int ret;
+
+	saddr.addr_type = IEEE802154_ADDR_LONG;
+	saddr.pan_id = addr->pan_id;
+	memcpy(saddr.hwaddr, dev->dev_addr, IEEE802154_ADDR_LEN);
+
+	buf[pos++] = IEEE802154_CMD_DISASSOCIATION_NOTIFY;
+	buf[pos++] = reason;
+
+	ret = ieee802154_send_cmd(dev, addr, &saddr, buf, pos);
+
+	/* FIXME: this should be after the ack receved */
+	ieee802154_dev_set_pan_id(dev, 0xffff);
+	ieee802154_dev_set_short_addr(dev, 0xffff);
+	ieee802154_nl_disassoc_confirm(dev, 0x00);
+
+	return ret;
+}
+
+static int ieee802154_mlme_start_req(struct net_device *dev, struct ieee802154_addr *addr,
+				u8 channel,
+				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+				u8 coord_realign)
+{
+	BUG_ON(addr->addr_type != IEEE802154_ADDR_SHORT);
+
+	ieee802154_dev_set_pan_id(dev, addr->pan_id);
+	ieee802154_dev_set_short_addr(dev, addr->short_addr);
+	ieee802154_dev_set_channel(dev, channel);
+
+	/* FIXME: add validation for unused parameters to be sane for SoftMAC */
+
+	if (pan_coord)
+		dev->priv_flags |= IFF_IEEE802154_COORD;
+	else
+		dev->priv_flags &= ~IFF_IEEE802154_COORD;
+
+	return 0;
+}
+
+struct ieee802154_mlme_ops mac802154_mlme = {
+	.assoc_req = ieee802154_mlme_assoc_req,
+	.assoc_resp = ieee802154_mlme_assoc_resp,
+	.disassoc_req = ieee802154_mlme_disassoc_req,
+	.start_req = ieee802154_mlme_start_req,
+	.scan_req = ieee802154_mlme_scan_req,
+
+	.get_pan_id = ieee802154_dev_get_pan_id,
+	.get_short_addr = ieee802154_dev_get_short_addr,
+	.get_dsn = ieee802154_dev_get_dsn,
+	.get_bsn = ieee802154_dev_get_bsn,
+};
+
diff --git a/net/mac802154/main.c b/net/mac802154/main.c
new file mode 100644
index 0000000..1dbace4
--- /dev/null
+++ b/net/mac802154/main.c
@@ -0,0 +1,96 @@
+/*
+ * Copyright (C) 2007, 2008, 2009 Siemens AG
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
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/workqueue.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee802154/mac802154.h>
+
+#include "mac802154.h"
+
+static void __ieee802154_rx_prepare(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
+
+	BUG_ON(!skb);
+
+	PHY_CB(skb)->lqi = lqi;
+
+	skb->dev = priv->hw.netdev;
+
+	skb->iif = skb->dev->ifindex;
+
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	skb_reset_mac_header(skb);
+}
+
+void ieee802154_rx(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	struct sk_buff *skb2;
+
+	__ieee802154_rx_prepare(dev, skb, lqi);
+
+	skb2 = skb_clone(skb, GFP_KERNEL);
+	netif_rx(skb2);
+
+	ieee802154_subif_rx(dev, skb);
+}
+EXPORT_SYMBOL(ieee802154_rx);
+
+struct rx_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_dev *dev;
+};
+
+static void ieee802154_rx_worker(struct work_struct *work)
+{
+	struct rx_work *rw = container_of(work, struct rx_work, work);
+	struct sk_buff *skb = rw->skb;
+
+	struct sk_buff *skb2 = skb_clone(skb, GFP_KERNEL);
+	netif_rx(skb2);
+
+	ieee802154_subif_rx(rw->dev, skb);
+	kfree(rw);
+}
+
+void ieee802154_rx_irqsafe(struct ieee802154_dev *dev, struct sk_buff *skb, u8 lqi)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
+	struct rx_work *work = kzalloc(sizeof(struct rx_work), GFP_ATOMIC);
+
+	if (!work)
+		return;
+
+	__ieee802154_rx_prepare(dev, skb, lqi);
+
+	INIT_WORK(&work->work, ieee802154_rx_worker);
+	work->skb = skb;
+	work->dev = dev;
+
+	queue_work(priv->dev_workqueue, &work->work);
+}
+EXPORT_SYMBOL(ieee802154_rx_irqsafe);
diff --git a/net/mac802154/mdev.c b/net/mac802154/mdev.c
new file mode 100644
index 0000000..3bebe22
--- /dev/null
+++ b/net/mac802154/mdev.c
@@ -0,0 +1,283 @@
+/*
+ * Copyright (C) 2007, 2008 Siemens AG
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
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac802154.h>
+
+#include "mac802154.h"
+
+struct xmit_work {
+	struct sk_buff *skb;
+	struct work_struct work;
+	struct ieee802154_priv *priv;
+};
+
+static void ieee802154_xmit_worker(struct work_struct *work)
+{
+	struct xmit_work *xw = container_of(work, struct xmit_work, work);
+	phy_status_t res;
+
+	if (xw->priv->hw.current_channel != PHY_CB(xw->skb)->chan) {
+		res = xw->priv->ops->set_channel(&xw->priv->hw, PHY_CB(xw->skb)->chan);
+		if (res != PHY_SUCCESS) {
+			pr_debug("set_channel failed\n");
+			goto out;
+		}
+	}
+
+	res = xw->priv->ops->cca(&xw->priv->hw);
+	if (res != PHY_IDLE) {
+		pr_debug("CCA failed\n");
+		goto out;
+	}
+
+	res = xw->priv->ops->set_trx_state(&xw->priv->hw, PHY_TX_ON);
+	if (res != PHY_SUCCESS && res != PHY_TX_ON) {
+		pr_debug("set_trx_state returned %d\n", res);
+		goto out;
+	}
+
+	res = xw->priv->ops->tx(&xw->priv->hw, xw->skb);
+
+out:
+	/* FIXME: result processing and/or requeue!!! */
+	dev_kfree_skb(xw->skb);
+
+	xw->priv->ops->set_trx_state(&xw->priv->hw, PHY_RX_ON);
+	kfree(xw);
+}
+
+static int ieee802154_master_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ieee802154_priv *priv = netdev_priv(dev);
+	struct xmit_work *work;
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
+	INIT_WORK(&work->work, ieee802154_xmit_worker);
+	work->skb = skb;
+	work->priv = priv;
+
+	queue_work(priv->dev_workqueue, &work->work);
+
+	return NETDEV_TX_OK;
+}
+
+static int ieee802154_master_open(struct net_device *dev)
+{
+	struct ieee802154_priv *priv;
+	phy_status_t status;
+	priv = netdev_priv(dev);
+	if (!priv) {
+		pr_debug("%s:%s: unable to get master private data\n",
+				__FILE__, __func__);
+		return -ENODEV;
+	}
+	status = priv->ops->set_trx_state(&priv->hw, PHY_RX_ON);
+	if (status != PHY_SUCCESS) {
+		pr_debug("set_trx_state returned %d\n", status);
+		return -EBUSY;
+	}
+
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_master_close(struct net_device *dev)
+{
+	struct ieee802154_priv *priv;
+	netif_stop_queue(dev);
+	priv = netdev_priv(dev);
+
+	priv->ops->set_trx_state(&priv->hw, PHY_FORCE_TRX_OFF);
+	return 0;
+}
+static int ieee802154_master_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct ieee802154_priv *priv = netdev_priv(dev);
+	switch (cmd) {
+	case IEEE802154_SIOC_ADD_SLAVE:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		return ieee802154_add_slave(&priv->hw, (u8 *) &ifr->ifr_hwaddr.sa_data);
+	}
+	return -ENOIOCTLCMD;
+}
+
+static void ieee802154_netdev_setup_master(struct net_device *dev)
+{
+	dev->addr_len		= 0;
+	memset(dev->broadcast, 0xff, dev->addr_len);
+	dev->features		= NETIF_F_NO_CSUM;
+	dev->hard_header_len	= 0;
+	dev->mtu		= 127;
+	dev->tx_queue_len	= 0;
+	dev->type		= ARPHRD_IEEE802154_PHY;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+}
+static ssize_t ieee802154_netdev_show(const struct device *dev,
+			   struct device_attribute *attr, char *buf,
+			   ssize_t (*format)(const struct net_device *, char *))
+{
+	struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	if (netdev->reg_state <= NETREG_REGISTERED)
+		ret = (*format)(netdev, buf);
+
+	return ret;
+}
+#define MASTER_SHOW(field, format_string)				\
+static ssize_t format_##field(const struct net_device *dev, char *buf)	\
+{									\
+	struct ieee802154_priv *priv = netdev_priv(dev);		\
+	return sprintf(buf, format_string, priv->hw.field);		\
+}									\
+static ssize_t show_##field(struct device *dev,				\
+			    struct device_attribute *attr, char *buf)	\
+{									\
+	return ieee802154_netdev_show(dev, attr, buf, format_##field);	\
+}									\
+static DEVICE_ATTR(field, S_IRUGO, show_##field, NULL)
+
+static const char fmt_long_hex[] = "%#lx\n";
+static const char fmt_hex[] = "%#x\n";
+static const char fmt_dec[] = "%d\n";
+
+MASTER_SHOW(current_channel, fmt_dec);
+MASTER_SHOW(channel_mask, fmt_hex);
+
+static struct attribute *pmib_attrs[] = {
+	&dev_attr_current_channel.attr,
+	&dev_attr_channel_mask.attr,
+	NULL
+};
+
+static struct attribute_group pmib_group = {
+	.name  = "pib",
+	.attrs  = pmib_attrs,
+};
+
+static const struct net_device_ops ieee802154_master_ops = {
+	.ndo_open		= ieee802154_master_open,
+	.ndo_stop		= ieee802154_master_close,
+	.ndo_start_xmit		= ieee802154_master_hard_start_xmit,
+	.ndo_do_ioctl		= ieee802154_master_ioctl,
+};
+
+static int ieee802154_register_netdev_master(struct ieee802154_priv *priv)
+{
+	struct net_device *dev = priv->hw.netdev;
+
+	dev->netdev_ops = &ieee802154_master_ops;
+	dev->needed_headroom = priv->hw.extra_tx_headroom;
+	SET_NETDEV_DEV(dev, priv->hw.parent);
+
+	dev->sysfs_groups[1] = &pmib_group;
+
+	register_netdev(dev);
+
+	return 0;
+}
+
+struct ieee802154_dev *ieee802154_alloc_device(void)
+{
+	struct net_device *dev;
+	struct ieee802154_priv *priv;
+
+	dev = alloc_netdev(sizeof(struct ieee802154_priv),
+			"mwpan%d", ieee802154_netdev_setup_master);
+	if (!dev) {
+		printk(KERN_ERR "Failure to initialize master IEEE802154 device\n");
+		return NULL;
+	}
+	priv = netdev_priv(dev);
+	priv->hw.netdev = dev;
+
+	INIT_LIST_HEAD(&priv->slaves);
+	spin_lock_init(&priv->slaves_lock);
+	return &priv->hw;
+}
+EXPORT_SYMBOL(ieee802154_alloc_device);
+
+void ieee802154_free_device(struct ieee802154_dev *hw)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
+
+	BUG_ON(!list_empty(&priv->slaves));
+	BUG_ON(!priv->hw.netdev);
+
+	free_netdev(priv->hw.netdev);
+}
+EXPORT_SYMBOL(ieee802154_free_device);
+
+int ieee802154_register_device(struct ieee802154_dev *dev, struct ieee802154_ops *ops)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
+	int rc;
+
+	if (!try_module_get(ops->owner))
+		return -EFAULT;
+
+	BUG_ON(!dev || !dev->name);
+	BUG_ON(!ops || !ops->tx || !ops->cca || !ops->ed || !ops->set_trx_state);
+
+	priv->ops = ops;
+	rc = ieee802154_register_netdev_master(priv);
+	if (rc < 0)
+		goto out;
+	priv->dev_workqueue = create_singlethread_workqueue(priv->hw.netdev->name);
+	if (!priv->dev_workqueue)
+		goto out_wq;
+
+	return 0;
+
+out_wq:
+	unregister_netdev(priv->hw.netdev);
+out:
+	return rc;
+}
+EXPORT_SYMBOL(ieee802154_register_device);
+
+void ieee802154_unregister_device(struct ieee802154_dev *dev)
+{
+	struct ieee802154_priv *priv = ieee802154_to_priv(dev);
+
+	ieee802154_drop_slaves(dev);
+	unregister_netdev(priv->hw.netdev);
+	flush_workqueue(priv->dev_workqueue);
+	destroy_workqueue(priv->dev_workqueue);
+	module_put(priv->ops->owner);
+}
+EXPORT_SYMBOL(ieee802154_unregister_device);
+
+MODULE_DESCRIPTION("IEEE 802.15.4 implementation");
+MODULE_LICENSE("GPL v2");
+
diff --git a/net/mac802154/mib.h b/net/mac802154/mib.h
new file mode 100644
index 0000000..57bf03f
--- /dev/null
+++ b/net/mac802154/mib.h
@@ -0,0 +1,32 @@
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
+/* FIXME: should be dropped in favour of generic MIB API */
+u8 ieee802154_dev_get_dsn(struct net_device *dev);
+u8 ieee802154_dev_get_bsn(struct net_device *dev);
+u16 ieee802154_dev_get_pan_id(struct net_device *dev);
+u16 ieee802154_dev_get_short_addr(struct net_device *dev);
+void ieee802154_dev_set_pan_id(struct net_device *dev, u16 val);
+void ieee802154_dev_set_short_addr(struct net_device *dev, u16 val);
+void ieee802154_dev_set_channel(struct net_device *dev, u8 chan);
+
+
+#endif
diff --git a/net/mac802154/pib.c b/net/mac802154/pib.c
new file mode 100644
index 0000000..29fc75e
--- /dev/null
+++ b/net/mac802154/pib.c
@@ -0,0 +1,87 @@
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
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <net/ieee802154/mac802154.h>
+
+#include "mac802154.h"
+#include "pib.h"
+
+int ieee802154_pib_set(struct ieee802154_dev *hw, struct ieee802154_pib *pib)
+{
+	int ret;
+	struct ieee802154_priv *priv = ieee802154_to_priv(hw);
+	BUG_ON(!hw);
+	BUG_ON(!pib);
+	switch (pib->type) {
+	case IEEE802154_PIB_CURCHAN:
+#warning this should go via usual workqueue!!!
+		/* Our internal mask is inverted
+		 * 0 = channel is available
+		 * 1 = channel is unavailable
+		 * this saves initialization */
+		if (hw->channel_mask & (1 << (pib->val - 1)))
+			return -EINVAL;
+		ret = priv->ops->set_channel(hw, pib->val);
+		if (ret == PHY_ERROR)
+			return -EINVAL; /* FIXME */
+		hw->current_channel =  pib->val;
+		break;
+	case IEEE802154_PIB_CHANSUPP:
+		hw->channel_mask = ~(pib->val);
+		break;
+	case IEEE802154_PIB_TRPWR:
+		/* TODO */
+		break;
+	case IEEE802154_PIB_CCAMODE:
+		/* TODO */
+		break;
+	default:
+		pr_debug("Unknown PIB type value\n");
+		return -ENOTSUPP;
+	}
+	return 0;
+}
+
+int ieee802154_pib_get(struct ieee802154_dev *hw, struct ieee802154_pib *pib)
+{
+	BUG_ON(!hw);
+	BUG_ON(!pib);
+	switch (pib->type) {
+	case IEEE802154_PIB_CURCHAN:
+		pib->val = hw->current_channel;
+		break;
+	case IEEE802154_PIB_CHANSUPP:
+		pib->val = ~(hw->channel_mask);
+		break;
+	case IEEE802154_PIB_TRPWR:
+		pib->val = 0;
+		break;
+	case IEEE802154_PIB_CCAMODE:
+		pib->val = 0;
+		break;
+	default:
+		pr_debug("Unknown PIB type value\n");
+		return -ENOTSUPP;
+	}
+	return 0;
+}
+
diff --git a/net/mac802154/pib.h b/net/mac802154/pib.h
new file mode 100644
index 0000000..6593fa1
--- /dev/null
+++ b/net/mac802154/pib.h
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
+#ifndef PIB802154_H
+#define PIB802154_H
+
+struct ieee802154_pib {
+	int type;
+	u32 val;
+};
+
+#define IEEE802154_PIB_CURCHAN	0 /* Current channel, u8 6.1.2 */
+#define IEEE802154_PIB_CHANSUPP	1 /* Channel mask, u32 6.1.2 */
+#define IEEE802154_PIB_TRPWR	2 /* Transmit power, u8 6.4.2  */
+#define IEEE802154_PIB_CCAMODE	3 /* CCA mode, u8 6.7.9 */
+
+int ieee802154_pib_set(struct ieee802154_dev *hw, struct ieee802154_pib *pib);
+int ieee802154_pib_get(struct ieee802154_dev *hw, struct ieee802154_pib *pib);
+
+#endif
diff --git a/net/mac802154/scan.c b/net/mac802154/scan.c
new file mode 100644
index 0000000..89e0c9f
--- /dev/null
+++ b/net/mac802154/scan.c
@@ -0,0 +1,215 @@
+/*
+ * scan.c
+ *
+ * Description: MAC scan helper functions.
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
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
+ */
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac802154.h>
+#include <net/ieee802154/nl802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdevice.h>
+
+#include "mac802154.h"
+#include "beacon.h"
+
+/*
+ * ED scan is periodic issuing of ed device function
+ * on evry permitted channel, so it is virtually PHY-only scan */
+
+struct scan_work {
+	struct work_struct work;
+
+	int (*scan_ch)(struct scan_work *work, int channel, u8 duration);
+	struct net_device *dev;
+
+	u8 edl[27];
+
+	u8 type;
+	u32 channels;
+	u8 duration;
+};
+
+static int scan_ed(struct scan_work *work, int channel, u8 duration)
+{
+	int ret;
+	struct ieee802154_priv *hw = ieee802154_slave_get_priv(work->dev);
+	pr_debug("ed scan channel %d duration %d\n", channel, duration);
+	ret = hw->ops->ed(&hw->hw, &work->edl[channel]);
+	pr_debug("ed scan channel %d value %d\n", channel, work->edl[channel]);
+	return ret;
+}
+
+struct scan_data {
+	struct notifier_block nb;
+	struct list_head scan_head;
+};
+
+static int beacon_notifier(struct notifier_block *p,
+		unsigned long event, void *data)
+{
+	struct ieee802154_pandsc *pd = data;
+	struct scan_data *sd = container_of(p, struct scan_data, nb);
+	switch (event) {
+	case IEEE802154_NOTIFIER_BEACON:
+		/* TODO: add item to list here */
+		pr_debug("got a beacon frame addr_type %d pan_id %d\n",
+				pd->addr.addr_type, pd->addr.pan_id);
+		break;
+	}
+	return 0;
+}
+
+
+static int scan_passive(struct scan_work *work, int channel, u8 duration)
+{
+	unsigned long j;
+	struct scan_data *data = kzalloc(sizeof(struct scan_data), GFP_KERNEL);
+	pr_debug("passive scan channel %d duration %d\n", channel, duration);
+	data->nb.notifier_call = beacon_notifier;
+	ieee802154_slave_register_notifier(work->dev, &data->nb);
+	/* Hope 2 msecs will be enough for scan */
+	j = msecs_to_jiffies(2);
+	while (j > 0)
+		j = schedule_timeout(j);
+
+	ieee802154_slave_unregister_notifier(work->dev, &data->nb);
+	kfree(data);
+	return PHY_SUCCESS;
+}
+
+/* Active scan is periodic submission of beacon request
+ * and waiting for beacons which is useful for collecting LWPAN information */
+static int scan_active(struct scan_work *work, int channel, u8 duration)
+{
+	int ret;
+	pr_debug("active scan channel %d duration %d\n", channel, duration);
+	ret = ieee802154_send_beacon_req(work->dev);
+	if (ret < 0)
+		return PHY_ERROR;
+	return scan_passive(work, channel, duration);
+}
+
+static int scan_orphan(struct scan_work *work, int channel, u8 duration)
+{
+	pr_debug("orphan scan channel %d duration %d\n", channel, duration);
+	return 0;
+}
+
+static void scanner(struct work_struct *work)
+{
+	struct scan_work *sw = container_of(work, struct scan_work, work);
+	struct ieee802154_priv *hw = ieee802154_slave_get_priv(sw->dev);
+	int i;
+	phy_status_t ret;
+
+	for (i = 0; i < 27; i++) {
+		if (!(sw->channels & (1 << i)))
+			continue;
+
+		ret = hw->ops->set_channel(&hw->hw,  i);
+		if (ret != PHY_SUCCESS)
+			goto exit_error;
+
+		ret = sw->scan_ch(sw, i, sw->duration);
+		if (ret != PHY_SUCCESS)
+			goto exit_error;
+
+		sw->channels &= ~(1 << i);
+	}
+
+	ieee802154_nl_scan_confirm(sw->dev, IEEE802154_SUCCESS, sw->type, sw->channels,
+			sw->edl/*, NULL */);
+
+	kfree(sw);
+
+	return;
+
+exit_error:
+	ieee802154_nl_scan_confirm(sw->dev, IEEE802154_INVALID_PARAMETER, sw->type, sw->channels,
+			NULL/*, NULL */);
+	kfree(sw);
+	return;
+}
+
+/*
+ * Alloc ed_detect list for ED scan.
+ *
+ * @param mac current mac pointer
+ * @param type type of the scan to be performed
+ * @param channels 32-bit mask of requested to scan channels
+ * @param duration scan duration, see ieee802.15.4-2003.pdf, page 145.
+ * @return 0 if request is ok, errno otherwise.
+ */
+int ieee802154_mlme_scan_req(struct net_device *dev, u8 type, u32 channels, u8 duration)
+{
+	struct ieee802154_priv *hw = ieee802154_slave_get_priv(dev);
+	struct scan_work *work;
+
+	pr_debug("%s()\n", __func__);
+
+	if (duration > 14)
+		goto inval;
+	if (channels & hw->hw.channel_mask)
+		goto inval;
+
+	work = kzalloc(sizeof(struct scan_work), GFP_KERNEL);
+	if (!work)
+		goto inval;
+
+	work->dev = dev;
+	work->channels = channels;
+	work->duration = duration;
+	work->type = type;
+
+	switch (type) {
+	case IEEE802154_MAC_SCAN_ED:
+		work->scan_ch = scan_ed;
+		break;
+	case IEEE802154_MAC_SCAN_ACTIVE:
+		work->scan_ch = scan_active;
+		break;
+	case IEEE802154_MAC_SCAN_PASSIVE:
+		work->scan_ch = scan_passive;
+		break;
+	case IEEE802154_MAC_SCAN_ORPHAN:
+		work->scan_ch = scan_orphan;
+		break;
+	default:
+		pr_debug("%s(): invalid type %d\n", __func__, type);
+		goto inval;
+	}
+
+	INIT_WORK(&work->work, scanner);
+	queue_work(hw->dev_workqueue, &work->work);
+
+	return 0;
+
+inval:
+	ieee802154_nl_scan_confirm(dev, IEEE802154_INVALID_PARAMETER, type, channels,
+			NULL/*, NULL */);
+	return -EINVAL;
+}
+
-- 
1.6.2.4

