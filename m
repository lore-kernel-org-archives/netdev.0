From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 11/14] mac802154: slaves manipulation
	routine
Date: Mon, 19 Dec 2011 19:33:51 +0300
Message-ID: <1324312434-13151-11-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Alexander Smirnov \(none\)" <alexander@Lenovo.>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111219163117.GA13123-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Smirnov <alexander@Lenovo.(none)>

This patch adds interface for registration and removing slaves in the
system.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/mac802154.h        |    4 +
 net/mac802154/ieee802154_dev.c |  140 +++++++++++++++++++++++++++++++++++++++-
 net/mac802154/mac802154.h      |    3 +
 3 files changed, 146 insertions(+), 1 deletions(-)

diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 4e9f042..4854885 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -139,6 +139,10 @@ struct ieee802154_ops {
 					u8 addr[IEEE802154_ADDR_LEN]);
 };
 
+struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
+					struct ieee802154_ops *ops);
+void ieee802154_free_device(struct ieee802154_dev *dev);
+
 int ieee802154_register_device(struct ieee802154_dev *dev);
 void ieee802154_unregister_device(struct ieee802154_dev *dev);
 
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 2bd1034..649409c 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -18,13 +18,137 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/nl802154.h>
 #include <net/route.h>
-
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
 
+int mac802154_slave_open(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res = 0;
+
+	if (priv->hw->open_count++ == 0) {
+	res = priv->hw->ops->start(&priv->hw->hw);
+		WARN_ON(res);
+		if (res)
+			goto err;
+	}
+
+	if (priv->hw->ops->ieee_addr) {
+		res = priv->hw->ops->ieee_addr(&priv->hw->hw, dev->dev_addr);
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
+
+	netif_stop_queue(dev);
+
+	if ((--priv->hw->open_count) == 0)
+		priv->hw->ops->stop(&priv->hw->hw);
+
+	return 0;
+}
+
+static int mac802154_netdev_register(struct wpan_phy *phy,
+					struct net_device *dev)
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
+static void mac802154_del_iface(struct wpan_phy *phy,
+				struct net_device *dev)
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
+static struct net_device *mac802154_add_iface(struct wpan_phy *phy,
+					const char *name, int type)
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
 struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
 		struct ieee802154_ops *ops)
 {
@@ -61,6 +185,8 @@ void ieee802154_free_device(struct ieee802154_dev *hw)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(hw);
 
+	BUG_ON(!list_empty(&priv->slaves));
+
 	wpan_phy_free(priv->phy);
 
 	mutex_destroy(&priv->slaves_mtx);
@@ -80,6 +206,9 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 
 	wpan_phy_set_dev(priv->phy, priv->hw.parent);
 
+	priv->phy->add_iface = mac802154_add_iface;
+	priv->phy->del_iface = mac802154_del_iface;
+
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
 		goto out_wq;
@@ -104,6 +233,7 @@ EXPORT_SYMBOL(ieee802154_register_device);
 void ieee802154_unregister_device(struct ieee802154_dev *dev)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	struct mac802154_sub_if_data *sdata, *next;
 
 	flush_workqueue(priv->dev_workqueue);
 	destroy_workqueue(priv->dev_workqueue);
@@ -114,6 +244,14 @@ void ieee802154_unregister_device(struct ieee802154_dev *dev)
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
index d0e3d8d..f6f6f0a 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -87,6 +87,9 @@ struct mac802154_sub_if_data {
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 
+int mac802154_slave_open(struct net_device *dev);
+int mac802154_slave_close(struct net_device *dev);
+
 netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 							u8 page, u8 chan);
 
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
