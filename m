From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 10/17] ieee802154: add LIST_PHY command support
Date: Fri,  6 Nov 2009 15:39:34 +0300
Message-ID: <1257511181-19403-11-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758132AbZKFMky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:54 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:59 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add nl802154 command to get information about PHY's present in
the system.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/linux/nl802154.h   |    4 +
 net/ieee802154/Makefile    |    2 +-
 net/ieee802154/netlink.c   |    4 +
 net/ieee802154/nl-phy.c    |  188 ++++++++++++++++++++++++++++++++++++++++++++
 net/ieee802154/nl_policy.c |    2 +
 5 files changed, 199 insertions(+), 1 deletions(-)
 create mode 100644 net/ieee802154/nl-phy.c

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index b7d9435..275fd94 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -65,6 +65,9 @@ enum {
 	IEEE802154_ATTR_SEC,
 
 	IEEE802154_ATTR_PAGE,
+	IEEE802154_ATTR_CHANNEL_PAGE_LIST,
+
+	IEEE802154_ATTR_PHY_NAME,
 
 	__IEEE802154_ATTR_MAX,
 };
@@ -114,6 +117,7 @@ enum {
 	IEEE802154_RX_ENABLE_CONF, /* Not supported yet */
 
 	IEEE802154_LIST_IFACE,
+	IEEE802154_LIST_PHY,
 
 	__IEEE802154_CMD_MAX,
 };
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index 69af9f6..ce2d335 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_IEEE802154) +=	ieee802154.o af_802154.o
-ieee802154-y		:= netlink.o nl-mac.o nl_policy.o wpan-class.o
+ieee802154-y		:= netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y		:= af_ieee802154.o raw.o dgram.o
 
 ccflags-y += -Wall -DDEBUG
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 5b738ec..8a22173 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -87,6 +87,10 @@ int __init ieee802154_nl_init(void)
 	if (rc)
 		goto fail;
 
+	rc = nl802154_phy_register();
+	if (rc)
+		goto fail;
+
 	return 0;
 
 fail:
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
new file mode 100644
index 0000000..b7af722
--- /dev/null
+++ b/net/ieee802154/nl-phy.c
@@ -0,0 +1,188 @@
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
+ * Sergey Lapin <slapin@ossfans.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Maxim Osipov <maxim.osipov@siemens.com>
+ */
+
+#include <linux/kernel.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/wpan-phy.h>
+#include <linux/nl802154.h>
+
+#include "ieee802154.h"
+
+static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 pid,
+	u32 seq, int flags, struct wpan_phy *phy)
+{
+	void *hdr;
+	int i, pages = 0;
+	uint32_t *buf = kzalloc(32 * sizeof(uint32_t), GFP_KERNEL);
+
+	pr_debug("%s\n", __func__);
+
+	if (!buf)
+		goto out;
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, flags,
+		IEEE802154_LIST_PHY);
+	if (!hdr)
+		goto out;
+
+	mutex_lock(&phy->pib_lock);
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, phy->current_page);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel);
+	for (i = 0; i < 32; i++) {
+		if (phy->channels_supported[i])
+			buf[pages++] = phy->channels_supported[i] | (i << 27);
+	}
+	if (pages)
+		NLA_PUT(msg, IEEE802154_ATTR_CHANNEL_PAGE_LIST,
+				pages * sizeof(uint32_t), buf);
+
+	mutex_unlock(&phy->pib_lock);
+	return genlmsg_end(msg, hdr);
+
+nla_put_failure:
+	mutex_unlock(&phy->pib_lock);
+	genlmsg_cancel(msg, hdr);
+out:
+	kfree(buf);
+	return -EMSGSIZE;
+}
+
+static int ieee802154_list_phy(struct sk_buff *skb,
+	struct genl_info *info)
+{
+	/* Request for interface name, index, type, IEEE address,
+	   PAN Id, short address */
+	struct sk_buff *msg;
+	struct wpan_phy *phy;
+	const char *name;
+	int rc = -ENOBUFS;
+
+	pr_debug("%s\n", __func__);
+
+	if (!info->attrs[IEEE802154_ATTR_PHY_NAME])
+		return -EINVAL;
+
+	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
+	if (name[nla_len(info->attrs[IEEE802154_ATTR_PHY_NAME]) - 1] != '\0')
+		return -EINVAL; /* phy name should be null-terminated */
+
+
+	phy = wpan_phy_find(name);
+	if (!phy)
+		return -ENODEV;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg)
+		goto out_dev;
+
+	rc = ieee802154_nl_fill_phy(msg, info->snd_pid, info->snd_seq,
+			0, phy);
+	if (rc < 0)
+		goto out_free;
+
+	wpan_phy_put(phy);
+
+	return genlmsg_reply(msg, info);
+out_free:
+	nlmsg_free(msg);
+out_dev:
+	wpan_phy_put(phy);
+	return rc;
+
+}
+
+struct dump_phy_data {
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	int idx, s_idx;
+};
+
+static int ieee802154_dump_phy_iter(struct wpan_phy *phy, void *_data)
+{
+	int rc;
+	struct dump_phy_data *data = _data;
+
+	pr_debug("%s\n", __func__);
+
+	if (data->idx++ < data->s_idx)
+		return 0;
+
+	rc = ieee802154_nl_fill_phy(data->skb,
+			NETLINK_CB(data->cb->skb).pid,
+			data->cb->nlh->nlmsg_seq,
+			NLM_F_MULTI,
+			phy);
+
+	if (rc < 0) {
+		data->idx--;
+		return rc;
+	}
+
+	return 0;
+}
+
+static int ieee802154_dump_phy(struct sk_buff *skb,
+	struct netlink_callback *cb)
+{
+	struct dump_phy_data data = {
+		.cb = cb,
+		.skb = skb,
+		.s_idx = cb->args[0],
+		.idx = 0,
+	};
+
+	pr_debug("%s\n", __func__);
+
+	wpan_phy_for_each(ieee802154_dump_phy_iter, &data);
+
+	cb->args[0] = data.idx;
+
+	return skb->len;
+}
+
+static struct genl_ops ieee802154_phy_ops[] = {
+	IEEE802154_DUMP(IEEE802154_LIST_PHY, ieee802154_list_phy,
+							ieee802154_dump_phy),
+};
+
+/*
+ * No need to unregister as family unregistration will do it.
+ */
+int nl802154_phy_register(void)
+{
+	int i;
+	int rc;
+
+	for (i = 0; i < ARRAY_SIZE(ieee802154_phy_ops); i++) {
+		rc = genl_register_ops(&nl802154_family,
+				&ieee802154_phy_ops[i]);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 2363ebe..6adda4d 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -27,6 +27,7 @@
 const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_DEV_NAME] = { .type = NLA_STRING, },
 	[IEEE802154_ATTR_DEV_INDEX] = { .type = NLA_U32, },
+	[IEEE802154_ATTR_PHY_NAME] = { .type = NLA_STRING, },
 
 	[IEEE802154_ATTR_STATUS] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_SHORT_ADDR] = { .type = NLA_U16, },
@@ -50,5 +51,6 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_CHANNELS] = { .type = NLA_U32, },
 	[IEEE802154_ATTR_DURATION] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_ED_LIST] = { .len = 27 },
+	[IEEE802154_ATTR_CHANNEL_PAGE_LIST] = { .len = 32 * 4, },
 };
 
-- 
1.6.5

