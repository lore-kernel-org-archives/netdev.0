From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 02/17] wpan-phy: add wpan-phy iteration functions
Date: Fri,  6 Nov 2009 15:39:26 +0300
Message-ID: <1257511181-19403-3-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:64606 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757650AbZKFMkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:39 -0500
Received: by ey-out-2122.google.com with SMTP id 25so248343eya.19
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:43 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add API to iterate over the wpan-phy instances.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/net/wpan-phy.h      |    2 ++
 net/ieee802154/wpan-class.c |   25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 5e803a0..3367dd9 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -48,6 +48,8 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size);
 int wpan_phy_register(struct device *parent, struct wpan_phy *phy);
 void wpan_phy_unregister(struct wpan_phy *phy);
 void wpan_phy_free(struct wpan_phy *phy);
+/* Same semantics as for class_for_each_device */
+int wpan_phy_for_each(int (*fn)(struct wpan_phy *phy, void *data), void *data);
 
 static inline void *wpan_phy_priv(struct wpan_phy *phy)
 {
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index f306604..0cec138 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -91,6 +91,31 @@ struct wpan_phy *wpan_phy_find(const char *str)
 }
 EXPORT_SYMBOL(wpan_phy_find);
 
+struct wpan_phy_iter_data {
+	int (*fn)(struct wpan_phy *phy, void *data);
+	void *data;
+};
+
+static int wpan_phy_iter(struct device *dev, void *_data)
+{
+	struct wpan_phy_iter_data *wpid = _data;
+	struct wpan_phy *phy = container_of(dev, struct wpan_phy, dev);
+	return wpid->fn(phy, wpid->data);
+}
+
+int wpan_phy_for_each(int (*fn)(struct wpan_phy *phy, void *data),
+		void *data)
+{
+	struct wpan_phy_iter_data wpid = {
+		.fn = fn,
+		.data = data,
+	};
+
+	return class_for_each_device(&wpan_phy_class, NULL,
+			&wpid, wpan_phy_iter);
+}
+EXPORT_SYMBOL(wpan_phy_for_each);
+
 static int wpan_phy_idx_valid(int idx)
 {
 	return idx >= 0;
-- 
1.6.5

