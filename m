From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 4/4] cfg80211: assign device type in netdev notifier callback
Date: Fri,  2 Oct 2009 17:15:28 +0200
Message-ID: <6c6ca62dee146042d3d5dd168baf70d93e21dc56.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
 <ff8a6da2784c27455e9666469ec95d84a1e00fd4.1254495724.git.marcel@holtmann.org>
 <45ca9f6130993f8f935f98a99b83ebc7ae7c116d.1254495724.git.marcel@holtmann.org>
 <21e0ecd67498ddd64add62973a497b8eeb658254.1254495724.git.marcel@holtmann.org>
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33432 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbZJBPP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 11:15:58 -0400
In-Reply-To: <21e0ecd67498ddd64add62973a497b8eeb658254.1254495724.git.marcel@holtmann.org>
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having to modify every non-mac80211 for device type assignment,
do this inside the netdev notifier callback of cfg80211. So all drivers
that integrate with cfg80211 will export a proper device type.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/mac80211/iface.c |    5 -----
 net/wireless/core.c  |    7 +++++++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index b8295cb..f6005ad 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -754,10 +754,6 @@ int ieee80211_if_change_type(struct ieee80211_sub_if_data *sdata,
 	return 0;
 }
 
-static struct device_type wiphy_type = {
-	.name	= "wlan",
-};
-
 int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 		     struct net_device **new_dev, enum nl80211_iftype type,
 		     struct vif_params *params)
@@ -789,7 +785,6 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(ndev, wiphy_dev(local->hw.wiphy));
-	SET_NETDEV_DEVTYPE(ndev, &wiphy_type);
 
 	/* don't use IEEE80211_DEV_TO_SUB_IF because it checks too much */
 	sdata = netdev_priv(ndev);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 45b2be3..e6f02e9 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -625,6 +625,10 @@ static void wdev_cleanup_work(struct work_struct *work)
 	dev_put(wdev->netdev);
 }
 
+static struct device_type wiphy_type = {
+	.name	= "wlan",
+};
+
 static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 					 unsigned long state,
 					 void *ndev)
@@ -641,6 +645,9 @@ static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 	WARN_ON(wdev->iftype == NL80211_IFTYPE_UNSPECIFIED);
 
 	switch (state) {
+	case NETDEV_POST_INIT:
+		SET_NETDEV_DEVTYPE(dev, &wiphy_type);
+		break;
 	case NETDEV_REGISTER:
 		/*
 		 * NB: cannot take rdev->mtx here because this may be
-- 
1.6.2.5

