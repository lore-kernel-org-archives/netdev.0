From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next 2/7] mac802154: set and get PAN id
Date: Tue, 26 Jun 2012 13:24:49 +0400
Message-ID: <1340702694-24706-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:43136 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab2FZJ3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:29:04 -0400
Received: by wibhq12 with SMTP id hq12so3484468wib.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:29:03 -0700 (PDT)
In-Reply-To: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two methods intended to get and set the Private Area Network identifier
were added to the MIB implementation.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |    2 ++
 net/mac802154/mib.c       |   31 +++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index c0efcf1..5cb7dc2 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -109,5 +109,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 
 /* MIB callbacks */
 void mac802154_dev_set_ieee_addr(struct net_device *dev);
+u16 mac802154_dev_get_pan_id(const struct net_device *dev);
+void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
 
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index ab59821..8e772ed 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -91,3 +91,34 @@ void mac802154_dev_set_ieee_addr(struct net_device *dev)
 		set_hw_addr_filt(dev, IEEE802515_AFILT_IEEEADDR_CHANGED);
 	}
 }
+
+u16 mac802154_dev_get_pan_id(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->pan_id;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
+void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->pan_id = val;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if ((priv->hw->ops->set_hw_addr_filt) &&
+	    (priv->hw->hw.hw_filt.pan_id != priv->pan_id)) {
+		priv->hw->hw.hw_filt.pan_id = priv->pan_id;
+		set_hw_addr_filt(dev, IEEE802515_AFILT_PANID_CHANGED);
+	}
+}
-- 
1.7.2.3
