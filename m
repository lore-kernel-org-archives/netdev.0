From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 14/17] fakehard: mlme_ops->get_phy implementation
Date: Fri,  6 Nov 2009 15:39:38 +0300
Message-ID: <1257511181-19403-15-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758850AbZKFMlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:41:01 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:07 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |   38 ++++++++++++++++++++++++++++++++------
 1 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 70a9f9c..f877f13 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -32,9 +32,29 @@
 #include <net/nl802154.h>
 #include <net/wpan-phy.h>
 
-static struct wpan_phy *net_to_phy(struct net_device *dev)
+struct fakehard_priv {
+	struct wpan_phy *phy;
+};
+
+static struct wpan_phy *fake_to_phy(const struct net_device *dev)
+{
+	struct fakehard_priv *priv = netdev_priv(dev);
+	return priv->phy;
+}
+
+/**
+ * fake_get_phy - Return a phy corresponding to this device.
+ * @dev: The network device for which to return the wan-phy object
+ *
+ * This function returns a wpan-phy object corresponding to the passed
+ * network device. Reference counter for wpan-phy object is incremented,
+ * so when the wpan-phy isn't necessary, you should drop the reference
+ * via @wpan_phy_put() call.
+ */
+static struct wpan_phy *fake_get_phy(const struct net_device *dev)
 {
-	return container_of(dev->dev.parent, struct wpan_phy, dev);
+	struct wpan_phy *phy = fake_to_phy(dev);
+	return to_phy(get_device(&phy->dev));
 }
 
 /**
@@ -121,7 +141,7 @@ static u8 fake_get_bsn(const struct net_device *dev)
 static int fake_assoc_req(struct net_device *dev,
 		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
 {
-	struct wpan_phy *phy = net_to_phy(dev);
+	struct wpan_phy *phy = fake_to_phy(dev);
 
 	mutex_lock(&phy->pib_lock);
 	phy->current_channel = channel;
@@ -196,7 +216,7 @@ static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
 				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
 				u8 coord_realign)
 {
-	struct wpan_phy *phy = net_to_phy(dev);
+	struct wpan_phy *phy = fake_to_phy(dev);
 
 	mutex_lock(&phy->pib_lock);
 	phy->current_channel = channel;
@@ -239,6 +259,8 @@ static struct ieee802154_mlme_ops fake_mlme = {
 	.start_req = fake_start_req,
 	.scan_req = fake_scan_req,
 
+	.get_phy = fake_get_phy,
+
 	.get_pan_id = fake_get_pan_id,
 	.get_short_addr = fake_get_short_addr,
 	.get_dsn = fake_get_dsn,
@@ -313,7 +335,7 @@ static const struct net_device_ops fake_ops = {
 
 static void ieee802154_fake_destruct(struct net_device *dev)
 {
-	struct wpan_phy *phy = net_to_phy(dev);
+	struct wpan_phy *phy = fake_to_phy(dev);
 
 	wpan_phy_unregister(phy);
 	free_netdev(dev);
@@ -338,13 +360,14 @@ static void ieee802154_fake_setup(struct net_device *dev)
 static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
+	struct fakehard_priv *priv;
 	struct wpan_phy *phy = wpan_phy_alloc(0);
 	int err;
 
 	if (!phy)
 		return -ENOMEM;
 
-	dev = alloc_netdev(0, "hardwpan%d", ieee802154_fake_setup);
+	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d", ieee802154_fake_setup);
 	if (!dev) {
 		wpan_phy_free(phy);
 		return -ENOMEM;
@@ -370,6 +393,9 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 	dev->netdev_ops = &fake_ops;
 	dev->ml_priv = &fake_mlme;
 
+	priv = netdev_priv(dev);
+	priv->phy = phy;
+
 	/*
 	 * If the name is a format string the caller wants us to do a
 	 * name allocation.
-- 
1.6.5

