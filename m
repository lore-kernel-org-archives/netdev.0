From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 06/17] wpan-phy: follow usual patter of devices registration
Date: Fri,  6 Nov 2009 15:39:30 +0300
Message-ID: <1257511181-19403-7-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758039AbZKFMkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:46 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:51 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow the usual pattern of devices registration by adding new function
(wpan_phy_set_dev) that sets child->parent relationship and removing
parent argument from wpan_phy_register call.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |    3 ++-
 include/net/wpan-phy.h        |    6 +++++-
 net/ieee802154/wpan-class.c   |    4 +---
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index f6f2afe..4ea93cc 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -372,11 +372,12 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 			goto out;
 	}
 
+	wpan_phy_set_dev(phy, &pdev->dev);
 	SET_NETDEV_DEV(dev, &phy->dev);
 
 	platform_set_drvdata(pdev, dev);
 
-	err = wpan_phy_register(&pdev->dev, phy);
+	err = wpan_phy_register(phy);
 	if (err)
 		goto out;
 
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 7b7fc58..f63537c 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -45,7 +45,11 @@ struct wpan_phy {
 };
 
 struct wpan_phy *wpan_phy_alloc(size_t priv_size);
-int wpan_phy_register(struct device *parent, struct wpan_phy *phy);
+static inline void wpan_phy_set_dev(struct wpan_phy *phy, struct device *dev)
+{
+	phy->dev.parent = dev;
+}
+int wpan_phy_register(struct wpan_phy *phy);
 void wpan_phy_unregister(struct wpan_phy *phy);
 void wpan_phy_free(struct wpan_phy *phy);
 /* Same semantics as for class_for_each_device */
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 0c51f85..cd42e88 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -168,10 +168,8 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 }
 EXPORT_SYMBOL(wpan_phy_alloc);
 
-int wpan_phy_register(struct device *parent, struct wpan_phy *phy)
+int wpan_phy_register(struct wpan_phy *phy)
 {
-	phy->dev.parent = parent;
-
 	return device_add(&phy->dev);
 }
 EXPORT_SYMBOL(wpan_phy_register);
-- 
1.6.5

