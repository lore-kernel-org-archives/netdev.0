From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 13/17] ieee802154: add an mlme_ops call to retrieve PHY object
Date: Fri,  6 Nov 2009 15:39:37 +0300
Message-ID: <1257511181-19403-14-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:64606 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758210AbZKFMk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:59 -0500
Received: by ey-out-2122.google.com with SMTP id 25so248343eya.19
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:05 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ops->get_phy should increment reference to wpan-phy. As we return
the external structure, we should do refcounting correctly.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/net/ieee802154_netdev.h |    6 ++++++
 include/net/wpan-phy.h          |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index d23fb5a..5743055 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -74,8 +74,12 @@ static inline int mac_cb_type(struct sk_buff *skb)
 #define IEEE802154_MAC_SCAN_PASSIVE	2
 #define IEEE802154_MAC_SCAN_ORPHAN	3
 
+struct wpan_phy;
 /*
  * This should be located at net_device->ml_priv
+ *
+ * get_phy should increment the reference counting on returned phy.
+ * Use wpan_wpy_put to put that reference.
  */
 struct ieee802154_mlme_ops {
 	int (*assoc_req)(struct net_device *dev,
@@ -94,6 +98,8 @@ struct ieee802154_mlme_ops {
 	int (*scan_req)(struct net_device *dev,
 			u8 type, u32 channels, u8 page, u8 duration);
 
+	struct wpan_phy *(*get_phy)(const struct net_device *dev);
+
 	/*
 	 * FIXME: these should become the part of PIB/MIB interface.
 	 * However we still don't have IB interface of any kind
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index f63537c..a65e985 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -44,6 +44,8 @@ struct wpan_phy {
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
 
+#define to_phy(_dev)	container_of(_dev, struct wpan_phy, dev)
+
 struct wpan_phy *wpan_phy_alloc(size_t priv_size);
 static inline void wpan_phy_set_dev(struct wpan_phy *phy, struct device *dev)
 {
-- 
1.6.5

