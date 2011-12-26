From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 11/14 v2] mac802154: slaves manipulation routine
Date: Mon, 26 Dec 2011 20:11:54 +0300
Message-ID: <1324919514-15215-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39503 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab1LZQMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:12:53 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so11134286eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:12:52 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds interface for registration and removing slaves in the
system.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/ieee802154_dev.c |  141 ++++++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h      |    3 +
 2 files changed, 144 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 9af54cd..27a6495 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -18,6 +18,7 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/nl802154.h>
 #include <net/route.h>
 
 #include <net/mac802154.h>
@@ -25,6 +26,132 @@
 
 #include "mac802154.h"
 
+int mac802154_slave_open(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct mac802154_priv *ipriv = priv->hw;
+	int res = 0;
+
+	if (ipriv->open_count++ == 0) {
+		res = ipriv->ops->start(&ipriv->hw);
+		WARN_ON(res);
+		if (res)
+			goto err;
+	}
+
+	if (ipriv->ops->ieee_addr) {
+		res = ipriv->ops->ieee_addr(&ipriv->hw, dev->dev_addr);
+		WARN_ON(res);
+		if (res)
+			goto err;
+		mac802154_dev_set_ieee_addr(dev);
+	}
+
+	netif_start_queue(dev);
+	return 0;
+err:
+	priv->hw->open_count--;
+
+	return res;
+}
+
+int mac802154_slave_close(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct mac802154_priv *ipriv = priv->hw;
+
+	netif_stop_queue(dev);
+
+	if (!--ipriv->open_count)
+		ipriv->ops->stop(&ipriv->hw);
+
+	return 0;
+}
+
+static int
+mac802154_netdev_register(struct wpan_phy *phy, struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv;
+	struct mac802154_priv *ipriv;
+	int err;
+
+	ipriv = wpan_phy_priv(phy);
+
+	priv = netdev_priv(dev);
+	priv->dev = dev;
+	priv->hw = ipriv;
+
+	dev->needed_headroom = ipriv->hw.extra_tx_headroom;
+
+	SET_NETDEV_DEV(dev, &ipriv->phy->dev);
+
+	mutex_lock(&ipriv->slaves_mtx);
+	if (!ipriv->running) {
+		mutex_unlock(&ipriv->slaves_mtx);
+		return -ENODEV;
+	}
+	mutex_unlock(&ipriv->slaves_mtx);
+
+	err = register_netdev(dev);
+	if (err < 0)
+		return err;
+
+	rtnl_lock();
+	mutex_lock(&ipriv->slaves_mtx);
+	list_add_tail_rcu(&priv->list, &ipriv->slaves);
+	mutex_unlock(&ipriv->slaves_mtx);
+	rtnl_unlock();
+
+	return 0;
+}
+
+static void
+mac802154_del_iface(struct wpan_phy *phy, struct net_device *dev)
+{
+	struct mac802154_sub_if_data *sdata;
+	ASSERT_RTNL();
+
+	sdata = netdev_priv(dev);
+
+	BUG_ON(sdata->hw->phy != phy);
+
+	mutex_lock(&sdata->hw->slaves_mtx);
+	list_del_rcu(&sdata->list);
+	mutex_unlock(&sdata->hw->slaves_mtx);
+
+	synchronize_rcu();
+	unregister_netdevice(sdata->dev);
+}
+
+static struct net_device *
+mac802154_add_iface(struct wpan_phy *phy, const char *name, int type)
+{
+	struct net_device *dev;
+	int err = -ENOMEM;
+
+	/* No devices is currently supported */
+	switch (type) {
+	default:
+		dev = NULL;
+		err = -EINVAL;
+		break;
+	}
+	if (!dev)
+		goto err;
+
+	err = mac802154_netdev_register(phy, dev);
+	if (err)
+		goto err_free;
+
+	dev_hold(dev); /* we return a device w/ incremented refcount */
+	return dev;
+
+err_free:
+	free_netdev(dev);
+err:
+	return ERR_PTR(err);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -63,6 +190,8 @@ void ieee802154_free_device(struct ieee802154_dev *hw)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(hw);
 
+	BUG_ON(!list_empty(&priv->slaves));
+
 	wpan_phy_free(priv->phy);
 
 	mutex_destroy(&priv->slaves_mtx);
@@ -81,6 +210,9 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 
 	wpan_phy_set_dev(priv->phy, priv->hw.parent);
 
+	priv->phy->add_iface = mac802154_add_iface;
+	priv->phy->del_iface = mac802154_del_iface;
+
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
 		goto out_wq;
@@ -105,6 +237,7 @@ EXPORT_SYMBOL(ieee802154_register_device);
 void ieee802154_unregister_device(struct ieee802154_dev *dev)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	struct mac802154_sub_if_data *sdata, *next;
 
 	flush_workqueue(priv->dev_workqueue);
 	destroy_workqueue(priv->dev_workqueue);
@@ -115,6 +248,14 @@ void ieee802154_unregister_device(struct ieee802154_dev *dev)
 	priv->running = MAC802154_DEVICE_STOPPED;
 	mutex_unlock(&priv->slaves_mtx);
 
+	list_for_each_entry_safe(sdata, next, &priv->slaves, list) {
+		mutex_lock(&sdata->hw->slaves_mtx);
+		list_del(&sdata->list);
+		mutex_unlock(&sdata->hw->slaves_mtx);
+
+		unregister_netdevice(sdata->dev);
+	}
+
 	rtnl_unlock();
 
 	wpan_phy_unregister(priv->phy);
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index deb9afa..7d8736a 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -90,6 +90,9 @@ struct mac802154_sub_if_data {
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 
+int mac802154_slave_open(struct net_device *dev);
+int mac802154_slave_close(struct net_device *dev);
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan);
 
-- 
1.7.2.3
