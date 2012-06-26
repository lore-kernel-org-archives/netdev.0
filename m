From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next 3/7] mac802154: short address setter
Date: Tue, 26 Jun 2012 13:24:50 +0400
Message-ID: <1340702694-24706-4-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39535 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab2FZJ3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:29:06 -0400
Received: by wibhr14 with SMTP id hr14so2023391wib.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:29:04 -0700 (PDT)
In-Reply-To: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A method to assign the IEEE802.15.4 short address was added to the
MIB implementation.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |    1 +
 net/mac802154/mib.c       |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 5cb7dc2..9951072 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -108,6 +108,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
 /* MIB callbacks */
+void mac802154_dev_set_short_addr(struct net_device *dev, u16 val);
 void mac802154_dev_set_ieee_addr(struct net_device *dev);
 u16 mac802154_dev_get_pan_id(const struct net_device *dev);
 void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 8e772ed..d74503b 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -78,6 +78,23 @@ static void set_hw_addr_filt(struct net_device *dev, unsigned long changed)
 	return;
 }
 
+void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	priv->short_addr = val;
+	spin_unlock_bh(&priv->mib_lock);
+
+	if ((priv->hw->ops->set_hw_addr_filt) &&
+	    (priv->hw->hw.hw_filt.short_addr != priv->short_addr)) {
+		priv->hw->hw.hw_filt.short_addr = priv->short_addr;
+		set_hw_addr_filt(dev, IEEE802515_AFILT_SADDR_CHANGED);
+	}
+}
+
 void mac802154_dev_set_ieee_addr(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-- 
1.7.2.3
