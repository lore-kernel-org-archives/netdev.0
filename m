From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 09/13] ieee802154: interface type to be added
Date: Sat, 12 May 2012 17:59:21 +0400
Message-ID: <1336831165-23944-10-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56521 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab2ELOAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:23 -0400
Received: by wibhn6 with SMTP id hn6so1098482wib.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:22 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stack implementation supports several types of slaves
interfaces. Another parameter to 'add_iface_ function is added
to clarify the interface type is going to be registered.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/linux/nl802154.h |    6 ++++++
 include/net/wpan-phy.h   |    2 +-
 net/ieee802154/nl-phy.c  |    9 ++++++++-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 33d9f51..2015ad2 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -68,6 +68,7 @@ enum {
 	IEEE802154_ATTR_CHANNEL_PAGE_LIST,
 
 	IEEE802154_ATTR_PHY_NAME,
+	IEEE802154_ATTR_DEV_TYPE,
 
 	__IEEE802154_ATTR_MAX,
 };
@@ -126,4 +127,9 @@ enum {
 
 #define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
 
+enum {
+	__IEEE802154_DEV_INVALID = -1,
+	__IEEE802154_DEV_MAX,
+};
+
 #endif
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index ff27f1b..efd6749 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -43,7 +43,7 @@ struct wpan_phy {
 	int idx;
 
 	struct net_device *(*add_iface)(struct wpan_phy *phy,
-			const char *name);
+					const char *name, int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 3bdc430..eed2916 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -179,6 +179,7 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 	const char *devname;
 	int rc = -ENOBUFS;
 	struct net_device *dev;
+	int type = __IEEE802154_DEV_INVALID;
 
 	pr_debug("%s\n", __func__);
 
@@ -221,7 +222,13 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 		goto nla_put_failure;
 	}
 
-	dev = phy->add_iface(phy, devname);
+	if (info->attrs[IEEE802154_ATTR_DEV_TYPE]) {
+		type = nla_get_u8(info->attrs[IEEE802154_ATTR_DEV_TYPE]);
+		if (type >= __IEEE802154_DEV_MAX)
+			return -EINVAL;
+	}
+
+	dev = phy->add_iface(phy, devname, type);
 	if (IS_ERR(dev)) {
 		rc = PTR_ERR(dev);
 		goto nla_put_failure;
-- 
1.7.2.3
