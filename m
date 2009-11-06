From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 17/17] ieee802154: add support for creation/removal of logic interfaces
Date: Fri,  6 Nov 2009 15:39:41 +0300
Message-ID: <1257511181-19403-18-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759104AbZKFMlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:41:07 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:12 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for two more NL802154 commands: ADD_IFACE and DEL_IFACE,
thus allowing creation and removal of logic WPAN interfaces on the top
of wpan-phy.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/linux/nl802154.h |    2 +
 include/net/wpan-phy.h   |    4 +
 net/ieee802154/nl-phy.c  |  156 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 162 insertions(+), 0 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 275fd94..33d9f51 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -118,6 +118,8 @@ enum {
 
 	IEEE802154_LIST_IFACE,
 	IEEE802154_LIST_PHY,
+	IEEE802154_ADD_IFACE,
+	IEEE802154_DEL_IFACE,
 
 	__IEEE802154_CMD_MAX,
 };
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index a65e985..8592623 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -41,6 +41,10 @@ struct wpan_phy {
 	struct device dev;
 	int idx;
 
+	struct net_device *(*add_iface)(struct wpan_phy *phy,
+			const char *name);
+	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
+
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
 
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index b7af722..199a2d9 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -26,6 +26,9 @@
 #include <net/netlink.h>
 #include <net/genetlink.h>
 #include <net/wpan-phy.h>
+#include <net/af_ieee802154.h>
+#include <net/ieee802154_netdev.h>
+#include <net/rtnetlink.h> /* for rtnl_{un,}lock */
 #include <linux/nl802154.h>
 
 #include "ieee802154.h"
@@ -164,9 +167,162 @@ static int ieee802154_dump_phy(struct sk_buff *skb,
 	return skb->len;
 }
 
+static int ieee802154_add_iface(struct sk_buff *skb,
+		struct genl_info *info)
+{
+	struct sk_buff *msg;
+	struct wpan_phy *phy;
+	const char *name;
+	const char *devname;
+	int rc = -ENOBUFS;
+	struct net_device *dev;
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
+	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
+		devname = nla_data(info->attrs[IEEE802154_ATTR_DEV_NAME]);
+		if (devname[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1]
+				!= '\0')
+			return -EINVAL; /* phy name should be null-terminated */
+	} else  {
+		devname = "wpan%d";
+	}
+
+	if (strlen(devname) >= IFNAMSIZ)
+		return -ENAMETOOLONG;
+
+	phy = wpan_phy_find(name);
+	if (!phy)
+		return -ENODEV;
+
+	msg = ieee802154_nl_new_reply(info, 0, IEEE802154_ADD_IFACE);
+	if (!msg)
+		goto out_dev;
+
+	if (!phy->add_iface) {
+		rc = -EINVAL;
+		goto nla_put_failure;
+	}
+
+	dev = phy->add_iface(phy, devname);
+	if (IS_ERR(dev)) {
+		rc = PTR_ERR(dev);
+		goto nla_put_failure;
+	}
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
+
+	dev_put(dev);
+
+	wpan_phy_put(phy);
+
+	return ieee802154_nl_reply(msg, info);
+
+nla_put_failure:
+	nlmsg_free(msg);
+out_dev:
+	wpan_phy_put(phy);
+	return rc;
+}
+
+static int ieee802154_del_iface(struct sk_buff *skb,
+		struct genl_info *info)
+{
+	struct sk_buff *msg;
+	struct wpan_phy *phy;
+	const char *name;
+	int rc;
+	struct net_device *dev;
+
+	pr_debug("%s\n", __func__);
+
+	if (!info->attrs[IEEE802154_ATTR_DEV_NAME])
+		return -EINVAL;
+
+	name = nla_data(info->attrs[IEEE802154_ATTR_DEV_NAME]);
+	if (name[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1] != '\0')
+		return -EINVAL; /* name should be null-terminated */
+
+	dev = dev_get_by_name(genl_info_net(info), name);
+	if (!dev)
+		return -ENODEV;
+
+	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
+	BUG_ON(!phy);
+
+	rc = -EINVAL;
+	/* phy name is optional, but should be checked if it's given */
+	if (info->attrs[IEEE802154_ATTR_PHY_NAME]) {
+		struct wpan_phy *phy2;
+
+		const char *pname =
+			nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
+		if (pname[nla_len(info->attrs[IEEE802154_ATTR_PHY_NAME]) - 1]
+				!= '\0')
+			/* name should be null-terminated */
+			goto out_dev;
+
+		phy2 = wpan_phy_find(pname);
+		if (!phy2)
+			goto out_dev;
+
+		if (phy != phy2) {
+			wpan_phy_put(phy2);
+			goto out_dev;
+		}
+	}
+
+	rc = -ENOBUFS;
+
+	msg = ieee802154_nl_new_reply(info, 0, IEEE802154_DEL_IFACE);
+	if (!msg)
+		goto out_dev;
+
+	if (!phy->del_iface) {
+		rc = -EINVAL;
+		goto nla_put_failure;
+	}
+
+	rtnl_lock();
+	phy->del_iface(phy, dev);
+
+	/* We don't have device anymore */
+	dev_put(dev);
+	dev = NULL;
+
+	rtnl_unlock();
+
+
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy));
+	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, name);
+
+	wpan_phy_put(phy);
+
+	return ieee802154_nl_reply(msg, info);
+
+nla_put_failure:
+	nlmsg_free(msg);
+out_dev:
+	wpan_phy_put(phy);
+	if (dev)
+		dev_put(dev);
+
+	return rc;
+}
+
 static struct genl_ops ieee802154_phy_ops[] = {
 	IEEE802154_DUMP(IEEE802154_LIST_PHY, ieee802154_list_phy,
 							ieee802154_dump_phy),
+	IEEE802154_OP(IEEE802154_ADD_IFACE, ieee802154_add_iface),
+	IEEE802154_OP(IEEE802154_DEL_IFACE, ieee802154_del_iface),
 };
 
 /*
-- 
1.6.5

