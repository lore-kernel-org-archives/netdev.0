From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net 1/3] 6lowpan: fix segmentation fault caused by mlme request
Date: Thu, 26 Apr 2012 13:24:56 +0400
Message-ID: <1335432298-17161-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37864 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab2DZJbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:31:08 -0400
Received: by wejx9 with SMTP id x9so619427wej.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:31:07 -0700 (PDT)
In-Reply-To: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add nescesary mlme callbacks to satisfy "iz list" request from user space.
Due to 6lowpan device doesn't have its own phy, mlme implemented as a pipe
to a real phy to which 6lowpan is attached.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 58c8895..7ce508f 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1044,6 +1044,24 @@ static void lowpan_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
+{
+	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+	return ieee802154_mlme_ops(real_dev)->get_phy(real_dev);
+}
+
+static u16 lowpan_get_pan_id(const struct net_device *dev)
+{
+	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+	return ieee802154_mlme_ops(real_dev)->get_pan_id(real_dev);
+}
+
+static u16 lowpan_get_short_addr(const struct net_device *dev)
+{
+	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+	return ieee802154_mlme_ops(real_dev)->get_short_addr(real_dev);
+}
+
 static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
@@ -1053,6 +1071,12 @@ static const struct net_device_ops lowpan_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
+static struct ieee802154_mlme_ops lowpan_mlme = {
+	.get_pan_id = lowpan_get_pan_id,
+	.get_phy = lowpan_get_phy,
+	.get_short_addr = lowpan_get_short_addr,
+};
+
 static void lowpan_setup(struct net_device *dev)
 {
 	pr_debug("(%s)\n", __func__);
@@ -1070,6 +1094,7 @@ static void lowpan_setup(struct net_device *dev)
 
 	dev->netdev_ops		= &lowpan_netdev_ops;
 	dev->header_ops		= &lowpan_header_ops;
+	dev->ml_priv		= &lowpan_mlme;
 	dev->destructor		= lowpan_dev_free;
 }
 
-- 
1.7.2.3
