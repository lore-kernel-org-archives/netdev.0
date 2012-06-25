From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 4/7] mac802154: page and channel setter
Date: Mon, 25 Jun 2012 17:33:14 +0400
Message-ID: <1340631197-27691-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340631197-27691-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:64390 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab2FYNgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:36:43 -0400
Received: by wibhq12 with SMTP id hq12so2712643wib.1
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 06:36:42 -0700 (PDT)
In-Reply-To: <1340631197-27691-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new method to set page and channel values for a transceiver
was added to the MIB.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |    1 +
 net/mac802154/mib.c       |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 9951072..6967864 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -112,5 +112,6 @@ void mac802154_dev_set_short_addr(struct net_device *dev, u16 val);
 void mac802154_dev_set_ieee_addr(struct net_device *dev);
 u16 mac802154_dev_get_pan_id(const struct net_device *dev);
 void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
+void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan);
 
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index d74503b..4bba4e1 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -28,6 +28,11 @@
 
 #include "mac802154.h"
 
+struct phy_chan_notify_work {
+	struct work_struct work;
+	struct net_device *dev;
+};
+
 struct hw_addr_filt_notify_work {
 	struct work_struct work;
 	struct net_device *dev;
@@ -139,3 +144,43 @@ void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
 		set_hw_addr_filt(dev, IEEE802515_AFILT_PANID_CHANGED);
 	}
 }
+
+static void phy_chan_notify(struct work_struct *work)
+{
+	struct phy_chan_notify_work *nw = container_of(work,
+					  struct phy_chan_notify_work, work);
+	struct mac802154_priv *hw = mac802154_slave_get_priv(nw->dev);
+	struct mac802154_sub_if_data *priv = netdev_priv(nw->dev);
+	int res;
+
+	res = hw->ops->set_channel(&hw->hw, priv->page, priv->chan);
+	if (res)
+		pr_debug("set_channel failed\n");
+
+	kfree(nw);
+}
+
+void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct phy_chan_notify_work *work;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->page = page;
+	priv->chan = chan;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if (priv->hw->phy->current_channel != priv->chan ||
+	    priv->hw->phy->current_page != priv->page) {
+		work = kzalloc(sizeof(*work), GFP_ATOMIC);
+		if (!work)
+			return;
+
+		INIT_WORK(&work->work, phy_chan_notify);
+		work->dev = dev;
+		queue_work(priv->hw->dev_workqueue, &work->work);
+	}
+}
+
-- 
1.7.2.3
