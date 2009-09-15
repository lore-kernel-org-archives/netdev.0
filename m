From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 6/7] nl802154: split away MAC commands implementation
Date: Wed, 16 Sep 2009 02:13:04 +0400
Message-ID: <1253052785-26190-7-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-5-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-6-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:42420 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758102AbZIOWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:14:05 -0400
Received: by mail-ew0-f206.google.com with SMTP id 2so922680ewy.17
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:14:08 -0700 (PDT)
In-Reply-To: <1253052785-26190-6-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all mac-related stuff to separate file so that ieee802154/netlink.c
contains only generic code.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/Makefile                |    2 +-
 net/ieee802154/ieee802154.h            |   48 +++
 net/ieee802154/netlink.c               |  605 +-------------------------------
 net/ieee802154/{netlink.c => nl-mac.c} |  117 ++-----
 4 files changed, 81 insertions(+), 691 deletions(-)
 create mode 100644 net/ieee802154/ieee802154.h
 copy net/ieee802154/{netlink.c => nl-mac.c} (86%)

diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 42b1f0d..69af9f6 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_IEEE802154) +=	ieee802154.o af_802154.o
-ieee802154-y		:= netlink.o nl_policy.o wpan-class.o
+ieee802154-y		:= netlink.o nl-mac.o nl_policy.o wpan-class.o
 af_802154-y		:= af_ieee802154.o raw.o dgram.o
 
 ccflags-y += -Wall -DDEBUG
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
new file mode 100644
index 0000000..0790eb0
--- /dev/null
+++ b/net/ieee802154/ieee802154.h
@@ -0,0 +1,48 @@
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
+ */
+#ifndef IEEE_802154_LOCAL_H
+#define IEEE_802154_LOCAL_H
+
+int __init ieee802154_nl_init(void);
+void __exit ieee802154_nl_exit(void);
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
+#define IEEE802154_DUMP(_cmd, _func, _dump)		\
+	{						\
+		.cmd	= _cmd,				\
+		.policy	= ieee802154_policy,		\
+		.doit	= _func,			\
+		.dumpit	= _dump,			\
+	}
+
+struct sk_buff *ieee802154_nl_create(int flags, u8 req);
+int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group);
+
+extern struct genl_family nl802154_family;
+int nl802154_mac_register(void);
+int nl802154_phy_register(void);
+
+#endif
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 0fadd6b..5b738ec 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -23,21 +23,15 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/if_arp.h>
-#include <linux/netdevice.h>
-#include <net/netlink.h>
 #include <net/genetlink.h>
-#include <net/sock.h>
 #include <linux/nl802154.h>
-#include <net/af_ieee802154.h>
-#include <net/nl802154.h>
-#include <net/ieee802154.h>
-#include <net/ieee802154_netdev.h>
+
+#include "ieee802154.h"
 
 static unsigned int ieee802154_seq_num;
 static DEFINE_SPINLOCK(ieee802154_seq_lock);
 
-static struct genl_family ieee802154_coordinator_family = {
+struct genl_family nl802154_family = {
 	.id		= GENL_ID_GENERATE,
 	.hdrsize	= 0,
 	.name		= IEEE802154_NL_NAME,
@@ -45,16 +39,8 @@ static struct genl_family ieee802154_coordinator_family = {
 	.maxattr	= IEEE802154_ATTR_MAX,
 };
 
-static struct genl_multicast_group ieee802154_coord_mcgrp = {
-	.name		= IEEE802154_MCAST_COORD_NAME,
-};
-
-static struct genl_multicast_group ieee802154_beacon_mcgrp = {
-	.name		= IEEE802154_MCAST_BEACON_NAME,
-};
-
 /* Requests to userspace */
-static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
+struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 {
 	void *hdr;
 	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
@@ -65,7 +51,7 @@ static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 
 	spin_lock_irqsave(&ieee802154_seq_lock, f);
 	hdr = genlmsg_put(msg, 0, ieee802154_seq_num++,
-			&ieee802154_coordinator_family, flags, req);
+			&nl802154_family, flags, req);
 	spin_unlock_irqrestore(&ieee802154_seq_lock, f);
 	if (!hdr) {
 		nlmsg_free(msg);
@@ -75,7 +61,7 @@ static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 	return msg;
 }
 
-static int ieee802154_nl_finish(struct sk_buff *msg)
+int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 {
 	/* XXX: nlh is right at the start of msg */
 	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
@@ -83,602 +69,33 @@ static int ieee802154_nl_finish(struct sk_buff *msg)
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
 
-	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id,
-			GFP_ATOMIC);
+	return genlmsg_multicast(msg, 0, group, GFP_ATOMIC);
 out:
 	nlmsg_free(msg);
 	return -ENOBUFS;
 }
 
-int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 cap)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	if (addr->addr_type != IEEE802154_ADDR_LONG) {
-		pr_err("%s: received non-long source address!\n", __func__);
-		return -EINVAL;
-	}
-
-	msg = ieee802154_nl_create(0, IEEE802154_ASSOCIATE_INDIC);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-			addr->hwaddr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_CAPABILITY, cap);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_assoc_indic);
-
-int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
-		u8 status)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_ASSOCIATE_CONF);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_assoc_confirm);
-
-int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_DISASSOCIATE_INDIC);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	if (addr->addr_type == IEEE802154_ADDR_LONG)
-		NLA_PUT(msg, IEEE802154_ATTR_SRC_HW_ADDR, IEEE802154_ADDR_LEN,
-				addr->hwaddr);
-	else
-		NLA_PUT_U16(msg, IEEE802154_ATTR_SRC_SHORT_ADDR,
-				addr->short_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_REASON, reason);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_disassoc_indic);
-
-int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_DISASSOCIATE_CONF);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_disassoc_confirm);
-
-int ieee802154_nl_beacon_indic(struct net_device *dev,
-		u16 panid, u16 coord_addr)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_BEACON_NOTIFY_INDIC);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_beacon_indic);
-
-int ieee802154_nl_scan_confirm(struct net_device *dev,
-		u8 status, u8 scan_type, u32 unscanned, u8 page,
-		u8 *edl/* , struct list_head *pan_desc_list */)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_SCAN_CONF);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_SCAN_TYPE, scan_type);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_CHANNELS, unscanned);
-	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, page);
-
-	if (edl)
-		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_scan_confirm);
-
-int ieee802154_nl_start_confirm(struct net_device *dev, u8 status)
-{
-	struct sk_buff *msg;
-
-	pr_debug("%s\n", __func__);
-
-	msg = ieee802154_nl_create(0, IEEE802154_START_CONF);
-	if (!msg)
-		return -ENOBUFS;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-			dev->dev_addr);
-
-	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
-
-	return ieee802154_nl_finish(msg);
-
-nla_put_failure:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-EXPORT_SYMBOL(ieee802154_nl_start_confirm);
-
-static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
-	u32 seq, int flags, struct net_device *dev)
-{
-	void *hdr;
-
-	pr_debug("%s\n", __func__);
-
-	hdr = genlmsg_put(msg, 0, seq, &ieee802154_coordinator_family, flags,
-		IEEE802154_LIST_IFACE);
-	if (!hdr)
-		goto out;
-
-	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
-
-	NLA_PUT(msg, IEEE802154_ATTR_HW_ADDR, IEEE802154_ADDR_LEN,
-		dev->dev_addr);
-	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR,
-		ieee802154_mlme_ops(dev)->get_short_addr(dev));
-	NLA_PUT_U16(msg, IEEE802154_ATTR_PAN_ID,
-		ieee802154_mlme_ops(dev)->get_pan_id(dev));
-	return genlmsg_end(msg, hdr);
-
-nla_put_failure:
-	genlmsg_cancel(msg, hdr);
-out:
-	return -EMSGSIZE;
-}
-
-/* Requests from userspace */
-static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
-{
-	struct net_device *dev;
-
-	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
-		char name[IFNAMSIZ + 1];
-		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME],
-				sizeof(name));
-		dev = dev_get_by_name(&init_net, name);
-	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX])
-		dev = dev_get_by_index(&init_net,
-			nla_get_u32(info->attrs[IEEE802154_ATTR_DEV_INDEX]));
-	else
-		return NULL;
-
-	if (!dev)
-		return NULL;
-
-	if (dev->type != ARPHRD_IEEE802154) {
-		dev_put(dev);
-		return NULL;
-	}
-
-	return dev;
-}
-
-static int ieee802154_associate_req(struct sk_buff *skb,
-		struct genl_info *info)
-{
-	struct net_device *dev;
-	struct ieee802154_addr addr;
-	u8 page;
-	int ret = -EINVAL;
-
-	if (!info->attrs[IEEE802154_ATTR_CHANNEL] ||
-	    !info->attrs[IEEE802154_ATTR_COORD_PAN_ID] ||
-	    (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] &&
-		!info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]) ||
-	    !info->attrs[IEEE802154_ATTR_CAPABILITY])
-		return -EINVAL;
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	if (info->attrs[IEEE802154_ATTR_COORD_HW_ADDR]) {
-		addr.addr_type = IEEE802154_ADDR_LONG;
-		nla_memcpy(addr.hwaddr,
-				info->attrs[IEEE802154_ATTR_COORD_HW_ADDR],
-				IEEE802154_ADDR_LEN);
-	} else {
-		addr.addr_type = IEEE802154_ADDR_SHORT;
-		addr.short_addr = nla_get_u16(
-				info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
-	}
-	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
-
-	if (info->attrs[IEEE802154_ATTR_PAGE])
-		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
-	else
-		page = 0;
-
-	ret = ieee802154_mlme_ops(dev)->assoc_req(dev, &addr,
-			nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]),
-			page,
-			nla_get_u8(info->attrs[IEEE802154_ATTR_CAPABILITY]));
-
-	dev_put(dev);
-	return ret;
-}
-
-static int ieee802154_associate_resp(struct sk_buff *skb,
-		struct genl_info *info)
-{
-	struct net_device *dev;
-	struct ieee802154_addr addr;
-	int ret = -EINVAL;
-
-	if (!info->attrs[IEEE802154_ATTR_STATUS] ||
-	    !info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] ||
-	    !info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR])
-		return -EINVAL;
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	addr.addr_type = IEEE802154_ADDR_LONG;
-	nla_memcpy(addr.hwaddr, info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
-			IEEE802154_ADDR_LEN);
-	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
-
-
-	ret = ieee802154_mlme_ops(dev)->assoc_resp(dev, &addr,
-		nla_get_u16(info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]),
-		nla_get_u8(info->attrs[IEEE802154_ATTR_STATUS]));
-
-	dev_put(dev);
-	return ret;
-}
-
-static int ieee802154_disassociate_req(struct sk_buff *skb,
-		struct genl_info *info)
-{
-	struct net_device *dev;
-	struct ieee802154_addr addr;
-	int ret = -EINVAL;
-
-	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] &&
-		!info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]) ||
-	    !info->attrs[IEEE802154_ATTR_REASON])
-		return -EINVAL;
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	if (info->attrs[IEEE802154_ATTR_DEST_HW_ADDR]) {
-		addr.addr_type = IEEE802154_ADDR_LONG;
-		nla_memcpy(addr.hwaddr,
-				info->attrs[IEEE802154_ATTR_DEST_HW_ADDR],
-				IEEE802154_ADDR_LEN);
-	} else {
-		addr.addr_type = IEEE802154_ADDR_SHORT;
-		addr.short_addr = nla_get_u16(
-				info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]);
-	}
-	addr.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
-
-	ret = ieee802154_mlme_ops(dev)->disassoc_req(dev, &addr,
-			nla_get_u8(info->attrs[IEEE802154_ATTR_REASON]));
-
-	dev_put(dev);
-	return ret;
-}
-
-/*
- * PANid, channel, beacon_order = 15, superframe_order = 15,
- * PAN_coordinator, battery_life_extension = 0,
- * coord_realignment = 0, security_enable = 0
-*/
-static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
-{
-	struct net_device *dev;
-	struct ieee802154_addr addr;
-
-	u8 channel, bcn_ord, sf_ord;
-	u8 page;
-	int pan_coord, blx, coord_realign;
-	int ret;
-
-	if (!info->attrs[IEEE802154_ATTR_COORD_PAN_ID] ||
-	    !info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR] ||
-	    !info->attrs[IEEE802154_ATTR_CHANNEL] ||
-	    !info->attrs[IEEE802154_ATTR_BCN_ORD] ||
-	    !info->attrs[IEEE802154_ATTR_SF_ORD] ||
-	    !info->attrs[IEEE802154_ATTR_PAN_COORD] ||
-	    !info->attrs[IEEE802154_ATTR_BAT_EXT] ||
-	    !info->attrs[IEEE802154_ATTR_COORD_REALIGN]
-	 )
-		return -EINVAL;
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	addr.addr_type = IEEE802154_ADDR_SHORT;
-	addr.short_addr = nla_get_u16(
-			info->attrs[IEEE802154_ATTR_COORD_SHORT_ADDR]);
-	addr.pan_id = nla_get_u16(info->attrs[IEEE802154_ATTR_COORD_PAN_ID]);
-
-	channel = nla_get_u8(info->attrs[IEEE802154_ATTR_CHANNEL]);
-	bcn_ord = nla_get_u8(info->attrs[IEEE802154_ATTR_BCN_ORD]);
-	sf_ord = nla_get_u8(info->attrs[IEEE802154_ATTR_SF_ORD]);
-	pan_coord = nla_get_u8(info->attrs[IEEE802154_ATTR_PAN_COORD]);
-	blx = nla_get_u8(info->attrs[IEEE802154_ATTR_BAT_EXT]);
-	coord_realign = nla_get_u8(info->attrs[IEEE802154_ATTR_COORD_REALIGN]);
-
-	if (info->attrs[IEEE802154_ATTR_PAGE])
-		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
-	else
-		page = 0;
-
-
-	if (addr.short_addr == IEEE802154_ADDR_BROADCAST) {
-		ieee802154_nl_start_confirm(dev, IEEE802154_NO_SHORT_ADDRESS);
-		dev_put(dev);
-		return -EINVAL;
-	}
-
-	ret = ieee802154_mlme_ops(dev)->start_req(dev, &addr, channel, page,
-		bcn_ord, sf_ord, pan_coord, blx, coord_realign);
-
-	dev_put(dev);
-	return ret;
-}
-
-static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
-{
-	struct net_device *dev;
-	int ret;
-	u8 type;
-	u32 channels;
-	u8 duration;
-	u8 page;
-
-	if (!info->attrs[IEEE802154_ATTR_SCAN_TYPE] ||
-	    !info->attrs[IEEE802154_ATTR_CHANNELS] ||
-	    !info->attrs[IEEE802154_ATTR_DURATION])
-		return -EINVAL;
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	type = nla_get_u8(info->attrs[IEEE802154_ATTR_SCAN_TYPE]);
-	channels = nla_get_u32(info->attrs[IEEE802154_ATTR_CHANNELS]);
-	duration = nla_get_u8(info->attrs[IEEE802154_ATTR_DURATION]);
-
-	if (info->attrs[IEEE802154_ATTR_PAGE])
-		page = nla_get_u8(info->attrs[IEEE802154_ATTR_PAGE]);
-	else
-		page = 0;
-
-
-	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels, page,
-			duration);
-
-	dev_put(dev);
-	return ret;
-}
-
-static int ieee802154_list_iface(struct sk_buff *skb,
-	struct genl_info *info)
-{
-	/* Request for interface name, index, type, IEEE address,
-	   PAN Id, short address */
-	struct sk_buff *msg;
-	struct net_device *dev = NULL;
-	int rc = -ENOBUFS;
-
-	pr_debug("%s\n", __func__);
-
-	dev = ieee802154_nl_get_dev(info);
-	if (!dev)
-		return -ENODEV;
-
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!msg)
-		goto out_dev;
-
-	rc = ieee802154_nl_fill_iface(msg, info->snd_pid, info->snd_seq,
-			0, dev);
-	if (rc < 0)
-		goto out_free;
-
-	dev_put(dev);
-
-	return genlmsg_unicast(&init_net, msg, info->snd_pid);
-out_free:
-	nlmsg_free(msg);
-out_dev:
-	dev_put(dev);
-	return rc;
-
-}
-
-static int ieee802154_dump_iface(struct sk_buff *skb,
-	struct netlink_callback *cb)
-{
-	struct net *net = sock_net(skb->sk);
-	struct net_device *dev;
-	int idx;
-	int s_idx = cb->args[0];
-
-	pr_debug("%s\n", __func__);
-
-	idx = 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx || (dev->type != ARPHRD_IEEE802154))
-			goto cont;
-
-		if (ieee802154_nl_fill_iface(skb, NETLINK_CB(cb->skb).pid,
-			cb->nlh->nlmsg_seq, NLM_F_MULTI, dev) < 0)
-			break;
-cont:
-		idx++;
-	}
-	cb->args[0] = idx;
-
-	return skb->len;
-}
-
-#define IEEE802154_OP(_cmd, _func)			\
-	{						\
-		.cmd	= _cmd,				\
-		.policy	= ieee802154_policy,		\
-		.doit	= _func,			\
-		.dumpit	= NULL,				\
-		.flags	= GENL_ADMIN_PERM,		\
-	}
-
-#define IEEE802154_DUMP(_cmd, _func, _dump)		\
-	{						\
-		.cmd	= _cmd,				\
-		.policy	= ieee802154_policy,		\
-		.doit	= _func,			\
-		.dumpit	= _dump,			\
-	}
-
-static struct genl_ops ieee802154_coordinator_ops[] = {
-	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
-	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
-	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_req),
-	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
-	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
-	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
-							ieee802154_dump_iface),
-};
-
 int __init ieee802154_nl_init(void)
 {
 	int rc;
-	int i;
 
-	rc = genl_register_family(&ieee802154_coordinator_family);
+	rc = genl_register_family(&nl802154_family);
 	if (rc)
 		goto fail;
 
-	rc = genl_register_mc_group(&ieee802154_coordinator_family,
-			&ieee802154_coord_mcgrp);
+	rc = nl802154_mac_register();
 	if (rc)
 		goto fail;
 
-	rc = genl_register_mc_group(&ieee802154_coordinator_family,
-			&ieee802154_beacon_mcgrp);
-	if (rc)
-		goto fail;
-
-
-	for (i = 0; i < ARRAY_SIZE(ieee802154_coordinator_ops); i++) {
-		rc = genl_register_ops(&ieee802154_coordinator_family,
-				&ieee802154_coordinator_ops[i]);
-		if (rc)
-			goto fail;
-	}
-
 	return 0;
 
 fail:
-	genl_unregister_family(&ieee802154_coordinator_family);
+	genl_unregister_family(&nl802154_family);
 	return rc;
 }
 
 void __exit ieee802154_nl_exit(void)
 {
-	genl_unregister_family(&ieee802154_coordinator_family);
+	genl_unregister_family(&nl802154_family);
 }
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/nl-mac.c
similarity index 86%
copy from net/ieee802154/netlink.c
copy to net/ieee802154/nl-mac.c
index 0fadd6b..eda506a 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/nl-mac.c
@@ -34,16 +34,7 @@
 #include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
-static unsigned int ieee802154_seq_num;
-static DEFINE_SPINLOCK(ieee802154_seq_lock);
-
-static struct genl_family ieee802154_coordinator_family = {
-	.id		= GENL_ID_GENERATE,
-	.hdrsize	= 0,
-	.name		= IEEE802154_NL_NAME,
-	.version	= 1,
-	.maxattr	= IEEE802154_ATTR_MAX,
-};
+#include "ieee802154.h"
 
 static struct genl_multicast_group ieee802154_coord_mcgrp = {
 	.name		= IEEE802154_MCAST_COORD_NAME,
@@ -53,43 +44,6 @@ static struct genl_multicast_group ieee802154_beacon_mcgrp = {
 	.name		= IEEE802154_MCAST_BEACON_NAME,
 };
 
-/* Requests to userspace */
-static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
-{
-	void *hdr;
-	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
-	unsigned long f;
-
-	if (!msg)
-		return NULL;
-
-	spin_lock_irqsave(&ieee802154_seq_lock, f);
-	hdr = genlmsg_put(msg, 0, ieee802154_seq_num++,
-			&ieee802154_coordinator_family, flags, req);
-	spin_unlock_irqrestore(&ieee802154_seq_lock, f);
-	if (!hdr) {
-		nlmsg_free(msg);
-		return NULL;
-	}
-
-	return msg;
-}
-
-static int ieee802154_nl_finish(struct sk_buff *msg)
-{
-	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(NLMSG_DATA(msg->data));
-
-	if (genlmsg_end(msg, hdr) < 0)
-		goto out;
-
-	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id,
-			GFP_ATOMIC);
-out:
-	nlmsg_free(msg);
-	return -ENOBUFS;
-}
-
 int ieee802154_nl_assoc_indic(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 cap)
 {
@@ -116,7 +70,7 @@ int ieee802154_nl_assoc_indic(struct net_device *dev,
 
 	NLA_PUT_U8(msg, IEEE802154_ATTR_CAPABILITY, cap);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -143,7 +97,7 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr,
 	NLA_PUT_U16(msg, IEEE802154_ATTR_SHORT_ADDR, short_addr);
 	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -176,7 +130,7 @@ int ieee802154_nl_disassoc_indic(struct net_device *dev,
 
 	NLA_PUT_U8(msg, IEEE802154_ATTR_REASON, reason);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -201,7 +155,7 @@ int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status)
 
 	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -227,7 +181,7 @@ int ieee802154_nl_beacon_indic(struct net_device *dev,
 	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_SHORT_ADDR, coord_addr);
 	NLA_PUT_U16(msg, IEEE802154_ATTR_COORD_PAN_ID, panid);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -260,7 +214,7 @@ int ieee802154_nl_scan_confirm(struct net_device *dev,
 	if (edl)
 		NLA_PUT(msg, IEEE802154_ATTR_ED_LIST, 27, edl);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -285,7 +239,7 @@ int ieee802154_nl_start_confirm(struct net_device *dev, u8 status)
 
 	NLA_PUT_U8(msg, IEEE802154_ATTR_STATUS, status);
 
-	return ieee802154_nl_finish(msg);
+	return ieee802154_nl_mcast(msg, ieee802154_coord_mcgrp.id);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -300,7 +254,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 
 	pr_debug("%s\n", __func__);
 
-	hdr = genlmsg_put(msg, 0, seq, &ieee802154_coordinator_family, flags,
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, flags,
 		IEEE802154_LIST_IFACE);
 	if (!hdr)
 		goto out;
@@ -581,7 +535,7 @@ static int ieee802154_list_iface(struct sk_buff *skb,
 
 	dev_put(dev);
 
-	return genlmsg_unicast(&init_net, msg, info->snd_pid);
+	return genlmsg_unicast(msg, info->snd_pid);
 out_free:
 	nlmsg_free(msg);
 out_dev:
@@ -616,23 +570,6 @@ cont:
 	return skb->len;
 }
 
-#define IEEE802154_OP(_cmd, _func)			\
-	{						\
-		.cmd	= _cmd,				\
-		.policy	= ieee802154_policy,		\
-		.doit	= _func,			\
-		.dumpit	= NULL,				\
-		.flags	= GENL_ADMIN_PERM,		\
-	}
-
-#define IEEE802154_DUMP(_cmd, _func, _dump)		\
-	{						\
-		.cmd	= _cmd,				\
-		.policy	= ieee802154_policy,		\
-		.doit	= _func,			\
-		.dumpit	= _dump,			\
-	}
-
 static struct genl_ops ieee802154_coordinator_ops[] = {
 	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
 	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
@@ -643,42 +580,30 @@ static struct genl_ops ieee802154_coordinator_ops[] = {
 							ieee802154_dump_iface),
 };
 
-int __init ieee802154_nl_init(void)
+/*
+ * No need to unregister as family unregistration will do it.
+ */
+int nl802154_mac_register(void)
 {
-	int rc;
 	int i;
+	int rc;
 
-	rc = genl_register_family(&ieee802154_coordinator_family);
-	if (rc)
-		goto fail;
-
-	rc = genl_register_mc_group(&ieee802154_coordinator_family,
+	rc = genl_register_mc_group(&nl802154_family,
 			&ieee802154_coord_mcgrp);
 	if (rc)
-		goto fail;
+		return rc;
 
-	rc = genl_register_mc_group(&ieee802154_coordinator_family,
+	rc = genl_register_mc_group(&nl802154_family,
 			&ieee802154_beacon_mcgrp);
 	if (rc)
-		goto fail;
-
+		return rc;
 
 	for (i = 0; i < ARRAY_SIZE(ieee802154_coordinator_ops); i++) {
-		rc = genl_register_ops(&ieee802154_coordinator_family,
+		rc = genl_register_ops(&nl802154_family,
 				&ieee802154_coordinator_ops[i]);
 		if (rc)
-			goto fail;
+			return rc;
 	}
 
 	return 0;
-
-fail:
-	genl_unregister_family(&ieee802154_coordinator_family);
-	return rc;
 }
-
-void __exit ieee802154_nl_exit(void)
-{
-	genl_unregister_family(&ieee802154_coordinator_family);
-}
-
-- 
1.6.3.3

