From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 4/7] ieee802154: add wpan-phy iteration functions
Date: Wed, 16 Sep 2009 02:13:02 +0400
Message-ID: <1253052785-26190-5-git-send-email-dbaryshkov@gmail.com>
References: <1253052785-26190-1-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-2-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-3-git-send-email-dbaryshkov@gmail.com>
 <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:4448 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbZIOWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:14:02 -0400
Received: by ey-out-2122.google.com with SMTP id 25so882299eya.19
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 15:14:03 -0700 (PDT)
In-Reply-To: <1253052785-26190-4-git-send-email-dbaryshkov@gmail.com>
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
1.6.3.3

