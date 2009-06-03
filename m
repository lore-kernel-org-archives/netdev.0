From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Thu, 4 Jun 2009 03:12:48 +0400
Message-ID: <20090603231248.GA32561@doriath.ww600.siemens.net>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com> <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com> <1244021964.10665.5.camel@johannes.local> <20090603.030911.162861804.davem@davemloft.net> <20090603105256.GB20508@doriath.ww600.siemens.net> <1244027110.1693.9.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	sfr@canb.auug.org.au, slapin@ossfans.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:48572 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbZFCXVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 19:21:17 -0400
Content-Disposition: inline
In-Reply-To: <1244027110.1693.9.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This doesn't address all the comments all comments by Johannes (as I
didn't understood the two last one), but I'd like to post this heavily
updated version.

>From 1aae1d7a60b104d271082c7612d1b9b9314c5949 Mon Sep 17 00:00:00 2001
From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 4 Jun 2009 03:09:42 +0400
Subject: [PATCH 4/6] net: add NL802154 interface for configuration of 802.15.4 devices

Add a netlink interface for configuration of IEEE 802.15.4 device. Also this
interface specifies events notification sent by devices towards higher layers.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Signed-off-by: Sergey Lapin <slapin@ossfans.org>
---
 include/net/ieee802154/nl802154.h |  137 +++++++++++
 net/ieee802154/Makefile           |    3 +-
 net/ieee802154/netlink.c          |  489 +++++++++++++++++++++++++++++++++++++
 net/ieee802154/nl_policy.c        |   65 +++++
 4 files changed, 693 insertions(+), 1 deletions(-)
 create mode 100644 include/net/ieee802154/nl802154.h
 create mode 100644 net/ieee802154/netlink.c
 create mode 100644 net/ieee802154/nl_policy.c

diff --git a/include/net/ieee802154/nl802154.h b/include/net/ieee802154/nl802154.h
new file mode 100644
index 0000000..0b03979
--- /dev/null
+++ b/include/net/ieee802154/nl802154.h
@@ -0,0 +1,137 @@
+/*
+ * nl802154.h
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
+ */
+
+#ifndef IEEE802154_NL_H
+#define IEEE802154_NL_H
+
+#ifdef __KERNEL__
+#include <net/netlink.h>
+#endif
+
+#define IEEE802154_NL_NAME "802.15.4 MAC"
+#define IEEE802154_MCAST_COORD_NAME "coordinator"
+#define IEEE802154_MCAST_BEACON_NAME "beacon"
+
+enum {
+	__IEEE802154_ATTR_INVALID,
+
+	IEEE802154_ATTR_DEV_NAME,
+	IEEE802154_ATTR_DEV_INDEX,
+
+	IEEE802154_ATTR_STATUS,
+
+	IEEE802154_ATTR_SHORT_ADDR,
+	IEEE802154_ATTR_HW_ADDR,
+	IEEE802154_ATTR_PAN_ID,
+
+	IEEE802154_ATTR_CHANNEL,
+
+	IEEE802154_ATTR_COORD_SHORT_ADDR,
+	IEEE802154_ATTR_COORD_HW_ADDR,
+	IEEE802154_ATTR_COORD_PAN_ID,
+
+	IEEE802154_ATTR_SRC_SHORT_ADDR,
+	IEEE802154_ATTR_SRC_HW_ADDR,
+	IEEE802154_ATTR_SRC_PAN_ID,
+
+	IEEE802154_ATTR_DEST_SHORT_ADDR,
+	IEEE802154_ATTR_DEST_HW_ADDR,
+	IEEE802154_ATTR_DEST_PAN_ID,
+
+	IEEE802154_ATTR_CAPABILITY,
+	IEEE802154_ATTR_REASON,
+	IEEE802154_ATTR_SCAN_TYPE,
+	IEEE802154_ATTR_CHANNELS,
+	IEEE802154_ATTR_DURATION,
+	IEEE802154_ATTR_ED_LIST,
+	IEEE802154_ATTR_BCN_ORD,
+	IEEE802154_ATTR_SF_ORD,
+	IEEE802154_ATTR_PAN_COORD,
+	IEEE802154_ATTR_BAT_EXT,
+	IEEE802154_ATTR_COORD_REALIGN,
+	IEEE802154_ATTR_SEC,
+
+	__IEEE802154_ATTR_MAX,
+};
+
+#define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
+
+extern struct nla_policy ieee802154_policy[];
+
+/* commands */
+/* REQ should be responded with CONF
+ * and INDIC with RESP
+ */
+enum {
+	__IEEE802154_COMMAND_INVALID,
+
+	IEEE802154_ASSOCIATE_REQ,
+	IEEE802154_ASSOCIATE_CONF,
+	IEEE802154_DISASSOCIATE_REQ,
+	IEEE802154_DISASSOCIATE_CONF,
+	IEEE802154_GET_REQ,
+	IEEE802154_GET_CONF,
+	IEEE802154_RESET_REQ,
+	IEEE802154_RESET_CONF,
+	IEEE802154_SCAN_REQ,
+	IEEE802154_SCAN_CONF,
+	IEEE802154_SET_REQ,
+	IEEE802154_SET_CONF,
+	IEEE802154_START_REQ,
+	IEEE802154_START_CONF,
+	IEEE802154_SYNC_REQ,
+	IEEE802154_POLL_REQ,
+	IEEE802154_POLL_CONF,
+
+	IEEE802154_ASSOCIATE_INDIC,
+	IEEE802154_ASSOCIATE_RESP,
+	IEEE802154_DISASSOCIATE_INDIC,
+	IEEE802154_BEACON_NOTIFY_INDIC,
+	IEEE802154_ORPHAN_INDIC,
+	IEEE802154_ORPHAN_RESP,
+	IEEE802154_COMM_STATUS_INDIC,
+	IEEE802154_SYNC_LOSS_INDIC,
+
+	IEEE802154_GTS_REQ, /* Not supported yet */
+	IEEE802154_GTS_INDIC, /* Not supported yet */
+	IEEE802154_GTS_CONF, /* Not supported yet */
+	IEEE802154_RX_ENABLE_REQ, /* Not supported yet */
+	IEEE802154_RX_ENABLE_CONF, /* Not supported yet */
+
+	__IEEE802154_CMD_MAX,
+};
+
+#define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
+
+
+#ifdef __KERNEL__
+struct net_device;
+struct ieee802154_addr;
+
+int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee802154_addr *addr, u8 cap);
+int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr, u8 status);
+int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee802154_addr *addr, u8 reason);
+int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status);
+int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8 scan_type, u32 unscanned,
+		u8 *edl/*, struct list_head *pan_desc_list */);
+int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u16 coord_addr); /* TODO */
+#endif
+
+#endif
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index cb88054..0b11995 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,4 +1,5 @@
-obj-$(CONFIG_IEEE802154) +=	af_802154.o
+obj-$(CONFIG_IEEE802154) +=	nl802154.o af_802154.o
+nl802154-objs		:= netlink.o nl_policy.o
 af_802154-objs		:= af_ieee802154.o raw.o dgram.o
 
 EXTRA_CFLAGS += -Wall -DDEBUG
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
new file mode 100644
index 0000000..6163db6
--- /dev/null
+++ b/net/ieee802154/netlink.c
@@ -0,0 +1,489 @@
+/*
+ * Netlink inteface for IEEE 802.15.4 stack
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
+#include <linux/if_arp.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <linux/netdevice.h>
+#include <net/ieee802154/af_ieee802154.h>
+#define IEEE802154_NL_WANT_POLICY
+#include <net/ieee802154/nl802154.h>
+#include <net/ieee802154/netdevice.h>
+
+static unsigned int ieee802154_seq_num;
+
+static struct genl_family ieee802154_coordinator_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= IEEE802154_NL_NAME,
+	.version	= 1,
+	.maxattr	= IEEE802154_ATTR_MAX,
+};
+
+static struct genl_multicast_group ieee802154_coord_mcgrp = {
+	.name		= IEEE802154_MCAST_COORD_NAME,
+};
+
+static struct genl_multicast_group ieee802154_beacon_mcgrp = {
+	.name		= IEEE802154_MCAST_BEACON_NAME,
+};
+
+/* Requests to userspace */
+static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
+{
+	void *hdr;
+	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+
+	if (!msg)
+		return NULL;
+
+	hdr = genlmsg_put(msg, 0, ieee802154_seq_num++, &ieee802154_coordinator_family, flags, req);
+	if (!hdr) {
+		nlmsg_free(msg);
+		return NULL;
+	}
+
+	return msg;
+}
+
+static int ieee802154_nl_finish(struct sk_buff *msg)
+{
+	void *hdr = genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh is right at the start of msg */
+
+	if (!genlmsg_end(msg, hdr))
+		goto out;
+
+	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMIC);
+out:
+	nlmsg_free(msg);
+	return -ENOBUFS;
+}
+
+static int ieee802154_nl_put_failure(struct sk_buff *msg)
+{
+	void *hdr = genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh is right at the start of msg */
+	genlmsg_cancel(msg, hdr);
+	nlmsg_free(msg);
+	return -ENOBUFS;
+}
+
+int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee802154_addr *addr, u8 cap)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	if (addr->addr_type != IEEE802154_ADDR_LONG) {
+		pr_err("%s: received non-long source address!\n", __func__);
+		return -EINVAL;
+	}
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_ASSOCIATE_INDIC);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+
+	NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN, addr->hwaddr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_CAPABILITY, cap);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_assoc_indic);
+
+int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr, u8 status)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_ASSOCIATE_CONF);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+
+	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_assoc_confirm);
+
+int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee802154_addr *addr, u8 reason)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_DISASSOCIATE_INDIC);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+
+	if (addr->addr_type == IEEE802154_ADDR_LONG)
+		NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN, addr->hwaddr);
+	else
+		NLA_PUT_U16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR, addr->short_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_REASON, reason);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_disassoc_indic);
+
+int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_DISASSOCIATE_CONF);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_disassoc_confirm);
+
+int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u16 coord_addr) /* TODO */
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_BEACON_NOTIFY_INDIC);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr);
+	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_beacon_indic);
+
+int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8 scan_type, u32 unscanned,
+		u8 *edl/* , struct list_head *pan_desc_list */)
+{
+	struct sk_buff *msg;
+
+	pr_debug("%s\n", __func__);
+
+	msg = ieee802154_nl_create(/* flags*/ 0, IEEE802154_SCAN_CONF);
+	if (!msg)
+		return -ENOBUFS;
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
+	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN, dev->dev_addr);
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type);
+	NLA_PUT_U32(msg, IEEE802154_ATTR_CHANNELS, unscanned);
+
+	if (edl)
+		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
+
+	return ieee802154_nl_finish(msg);
+
+nla_put_failure:
+	return ieee802154_nl_put_failure(msg);
+}
+EXPORT_SYMBOL(ieee802154_nl_scan_confirm);
+
+/* Requests from userspace */
+static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
+{
+	struct net_device *dev;
+
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		char name[IFNAMSIZ + 1];
+		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME], sizeof(name));
+		dev = dev_get_by_name(&init_net, name);
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX])
+		dev = dev_get_by_index(&init_net, nla_get_u32(info->attrs[IEEE802154_ATTR_DEV_INDEX]));
+	else
+		return NULL;
+
+	if (dev->type != ARPHRD_IEEE802154) {
+		dev_put(dev);
+		return NULL;
+	}
+
+	return dev;
+}
+
+static int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr;
+	int ret = -EINVAL;
+
+	if (!info->attrs[IEEE802154_ATTR_CHANNEL]
+	 || !info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
+	 || (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] && !info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR])
+	 || !info->attrs[IEEE802154_ATTR_CAPABILITY])
+		return -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]) {
+		addr.addr_type = IEEE802154_ADDR_LONG;
+		nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_COORD_HW_ADDR], IEEE802154_ADDR_LEN);
+	} else {
+		addr.addr_type = IEEE802154_ADDR_SHORT;
+		addr.short_addr = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
+	}
+	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
+
+	ret = IEEE802154_MLME_OPS(dev)->assoc_req(dev, &addr,
+			nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]),
+			nla_get_u8(info->attrs[IEEE802154_ATTR_CAPABILITY]));
+
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr;
+	int ret = -EINVAL;
+
+	if (!info->attrs[IEEE802154_ATTR_STATUS]
+	 || !info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]
+	 || !info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])
+		return -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	addr.addr_type = IEEE802154_ADDR_LONG;
+	nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR], IEEE802154_ADDR_LEN);
+	addr.pan_id = IEEE802154_MLME_OPS(dev)->get_pan_id(dev);
+
+
+	ret = IEEE802154_MLME_OPS(dev)->assoc_resp(dev, &addr,
+			nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]),
+			nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]));
+
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr;
+	int ret = -EINVAL;
+
+	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] && !info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])
+	 || !info->attrs[IEEE802154_ATTR_REASON])
+		return -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]) {
+		addr.addr_type = IEEE802154_ADDR_LONG;
+		nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR], IEEE802154_ADDR_LEN);
+	} else {
+		addr.addr_type = IEEE802154_ADDR_SHORT;
+		addr.short_addr = nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]);
+	}
+	addr.pan_id = IEEE802154_MLME_OPS(dev)->get_pan_id(dev);
+
+	ret = IEEE802154_MLME_OPS(dev)->disassoc_req(dev, &addr,
+			nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]));
+
+	dev_put(dev);
+	return ret;
+}
+
+/*
+ * PANid, channel, beacon_order = 15, superframe_order = 15,
+ * PAN_coordinator, battery_life_extension = 0,
+ * coord_realignment = 0, security_enable = 0
+*/
+static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct ieee802154_addr addr;
+
+	u8 channel, bcn_ord, sf_ord;
+	int pan_coord, blx, coord_realign;
+	int ret;
+
+	if (!info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
+	 || !info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]
+	 || !info->attrs[IEEE802154_ATTR_CHANNEL]
+	 || !info->attrs[IEEE802154_ATTR_BCN_ORD]
+	 || !info->attrs[IEEE802154_ATTR_SF_ORD]
+	 || !info->attrs[IEEE802154_ATTR_PAN_COORD]
+	 || !info->attrs[IEEE802154_ATTR_BAT_EXT]
+	 || !info->attrs[IEEE802154_ATTR_COORD_REALIGN]
+	 )
+		return -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	addr.addr_type = IEEE802154_ADDR_SHORT;
+	addr.short_addr = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
+	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
+
+	channel = nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]);
+	bcn_ord = nla_get_u8(info->attrs[IEEE802154_ATTR_BCN_ORD]);
+	sf_ord = nla_get_u8(info->attrs[IEEE802154_ATTR_SF_ORD]);
+	pan_coord = nla_get_u8(info->attrs[IEEE802154_ATTR_PAN_COORD]);
+	blx = nla_get_u8(info->attrs[IEEE802154_ATTR_BAT_EXT]);
+	coord_realign = nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_REALIGN]);
+
+	ret = IEEE802154_MLME_OPS(dev)->start_req(dev, &addr, channel, bcn_ord, sf_ord,
+		pan_coord, blx, coord_realign);
+
+	dev_put(dev);
+	return ret;
+}
+
+static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	int ret;
+	u8 type;
+	u32 channels;
+	u8 duration;
+
+	if (!info->attrs[IEEE802154_ATTR_SCAN_TYPE]
+	 || !info->attrs[IEEE802154_ATTR_CHANNELS]
+	 || !info->attrs[IEEE802154_ATTR_DURATION])
+		return -EINVAL;
+
+	dev = ieee802154_nl_get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	type = nla_get_u8(info->attrs[IEEE802154_ATTR_SCAN_TYPE]);
+	channels = nla_get_u32(info->attrs[IEEE802154_ATTR_CHANNELS]);
+	duration = nla_get_u8(info->attrs[IEEE802154_ATTR_DURATION]);
+
+	ret = IEEE802154_MLME_OPS(dev)->scan_req(dev, type, channels, duration);
+
+	dev_put(dev);
+	return ret;
+}
+
+#define IEEE802154_OP(_cmd, _func)			\
+	{						\
+		.cmd	= _cmd,				\
+		.policy	= ieee802154_policy,		\
+		.doit	= _func,			\
+		.dumpit	= NULL,				\
+		.flags	= GENL_ADMIN_PERM,		\
+	}
+
+static struct genl_ops ieee802154_coordinator_ops[] = {
+	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
+	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
+	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_req),
+	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
+	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
+};
+
+static int __init ieee802154_nl_init(void)
+{
+	int rc;
+	int i;
+
+	rc = genl_register_family(&ieee802154_coordinator_family);
+	if (rc)
+		goto fail;
+
+	rc = genl_register_mc_group(&ieee802154_coordinator_family, &ieee802154_coord_mcgrp);
+	if (rc)
+		goto fail;
+
+	rc = genl_register_mc_group(&ieee802154_coordinator_family, &ieee802154_beacon_mcgrp);
+	if (rc)
+		goto fail;
+
+
+	for (i = 0; i < ARRAY_SIZE(ieee802154_coordinator_ops); i++) {
+		rc = genl_register_ops(&ieee802154_coordinator_family, &ieee802154_coordinator_ops[i]);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+
+fail:
+	genl_unregister_family(&ieee802154_coordinator_family);
+	return rc;
+}
+module_init(ieee802154_nl_init);
+
+static void __exit ieee802154_nl_exit(void)
+{
+	genl_unregister_family(&ieee802154_coordinator_family);
+}
+module_exit(ieee802154_nl_exit);
+
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
new file mode 100644
index 0000000..099e965
--- /dev/null
+++ b/net/ieee802154/nl_policy.c
@@ -0,0 +1,65 @@
+/*
+ * nl802154.h
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
+ */
+
+/* This source file is shared between kernel and userspace sources, thus
+ * a bit of __KERNEL__ checks
+ */
+#ifdef __KERNEL__
+#include <linux/kernel.h>
+#include <net/netlink.h>
+#include <net/ieee802154/nl802154.h>
+#else
+#include <netlink/netlink.h>
+#include <netlink/attr.h>
+#include <nl802154.h>
+#endif
+
+#define NLA_HW_ADDR NLA_U64
+
+struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
+	[IEEE802154_ATTR_DEV_NAME] = { .type = NLA_STRING, },
+	[IEEE802154_ATTR_DEV_INDEX] = { .type = NLA_U32, },
+
+	[IEEE802154_ATTR_STATUS] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_SHORT_ADDR] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_HW_ADDR] = { .type = NLA_HW_ADDR, },
+	[IEEE802154_ATTR_PAN_ID] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_CHANNEL] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_COORD_SHORT_ADDR] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_COORD_HW_ADDR] = { .type = NLA_HW_ADDR, },
+	[IEEE802154_ATTR_COORD_PAN_ID] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_SRC_SHORT_ADDR] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_SRC_HW_ADDR] = { .type = NLA_HW_ADDR, },
+	[IEEE802154_ATTR_SRC_PAN_ID] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_DEST_SHORT_ADDR] = { .type = NLA_U16, },
+	[IEEE802154_ATTR_DEST_HW_ADDR] = { .type = NLA_HW_ADDR, },
+	[IEEE802154_ATTR_DEST_PAN_ID] = { .type = NLA_U16, },
+
+	[IEEE802154_ATTR_CAPABILITY] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_REASON] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_SCAN_TYPE] = { .type = NLA_U8, },
+	[IEEE802154_ATTR_CHANNELS] = { .type = NLA_U32, },
+	[IEEE802154_ATTR_DURATION] = { .type = NLA_U8, },
+#ifdef __KERNEL__
+	[IEEE802154_ATTR_ED_LIST] = { .len = 27 },
+#else
+	[IEEE802154_ATTR_ED_LIST] = { .minlen = 27, .maxlen = 27 },
+#endif
+};
-- 
1.6.3.1

-- 
With best wishes
Dmitry

