From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 10/14 v2] ieee802154: interface type to be added
Date: Mon, 26 Dec 2011 20:11:34 +0300
Message-ID: <1324919494-15181-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39503 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab1LZQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:12:32 -0500
Received: by eekc4 with SMTP id c4so11134286eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:12:31 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stack supports several types of slaves interfaces. Another
parameter to 'add_iface_ function is added.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/linux/nl802154.h |    6 ++++++
 include/net/wpan-phy.h   |    2 +-
 net/ieee802154/nl-phy.c  |    9 ++++++++-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index d2b5ae2..e339c96 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -68,6 +68,7 @@ enum {
 	IEEE802154_ATTR_CHANNEL_PAGE_LIST,
 
 	IEEE802154_ATTR_PHY_NAME,
+	IEEE802154_ATTR_DEV_TYPE,
 
 	__IEEE802154_ATTR_MAX,
 };
@@ -124,4 +125,9 @@ enum {
 
 #define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
 
+enum {
+	__IEEE802154_DEV_INVALID = -1,
+	__IEEE802154_DEV_MAX,
+};
+
 #endif
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index d86fffd..1437c90 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -42,7 +42,7 @@ struct wpan_phy {
 	int idx;
 
 	struct net_device *(*add_iface)(struct wpan_phy *phy,
-			const char *name);
+					const char *name, int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index c64a38d..2e0ae10 100644
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
