From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 7/7] ieee802154: add LIST_PHY command support
Date: Wed, 16 Sep 2009 02:13:05 +0400
Message-ID: <1253052785-26190-8-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-5-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-6-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-7-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:4448 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758726AbZIOWOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:14:06 -0400
Received: by ey-out-2122.google.com with SMTP id 25so882299eya.19
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:14:09 -0700 (PDT)
In-Reply-To: <1253052785-26190-7-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add nl802154 command to get information about PHY's present in
the system.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/linux/nl802154.h |    1 +
 net/ieee802154/Makefile  |    2 +-
 net/ieee802154/netlink.c |    4 +
 net/ieee802154/nl-phy.c  |  175 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 181 insertions(+), 1 deletions(-)
 create mode 100644 net/ieee802154/nl-phy.c

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index b7d9435..8707678 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -114,6 +114,7 @@ enum {
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
index 0000000..e9edecc
--- /dev/null
+++ b/net/ieee802154/nl-phy.c
@@ -0,0 +1,175 @@
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
+
+	pr_debug("%s\n", __func__);
+
+	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, flags,
+		IEEE802154_LIST_PHY);
+	if (!hdr)
+		goto out;
+
+	mutex_lock(&phy->pib_lock);
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, wpan_phy_name(phy));
+
+	NLA_PUT_U8(msg, IEEE802154_ATTR_PAGE, phy->current_page);
+	NLA_PUT_U8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel);
+
+	mutex_unlock(&phy->pib_lock);
+	return genlmsg_end(msg, hdr);
+
+nla_put_failure:
+	mutex_unlock(&phy->pib_lock);
+	genlmsg_cancel(msg, hdr);
+out:
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
+	if (!info->attrs[IEEE802154_ATTR_DEV_NAME])
+		return -EINVAL;
+
+	name = nla_data(info->attrs[IEEE802154_ATTR_DEV_NAME]);
+	if (name[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1] != '\0')
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
+	return genlmsg_unicast(msg, info->snd_pid);
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
-- 
1.6.3.3

