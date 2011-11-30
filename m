From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/12] [MAC802154] mac802154: bind
	network iface to phy
Date: Wed, 30 Nov 2011 17:27:09 +0300
Message-ID: <1322663229-4095-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111130141827.GA3739-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Transciever slaves manipulation. Each slave represents network interface
in user space and is described by net_device structure. One transciever
may support several slaves and be connected to several networks at the
same time.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac802154/ieee802154_dev.c |  147 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index e90d336..8fe1a9b 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -18,12 +18,143 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/nl802154.h>
 #include <net/route.h>
 
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
 #include "mac802154.h"
+#include "mib.h"
+
+int mac802154_slave_open(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res = 0;
+
+	if (priv->hw->open_count++ == 0) {
+		res = priv->hw->ops->start(&priv->hw->hw);
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
+	dev->priv_flags &= ~IFF_IEEE802154_COORD;
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
+		struct net_device *dev)
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
+		const char *name, int type)
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
+
+	err = mac802154_netdev_register(phy, dev);
+
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
@@ -61,6 +192,8 @@ void ieee802154_free_device(struct ieee802154_dev *hw)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(hw);
 
+	BUG_ON(!list_empty(&priv->slaves));
+
 	wpan_phy_free(priv->phy);
 
 	mutex_destroy(&priv->slaves_mtx);
@@ -80,6 +213,9 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 
 	wpan_phy_set_dev(priv->phy, priv->hw.parent);
 
+	priv->phy->add_iface = mac802154_add_iface;
+	priv->phy->del_iface = mac802154_del_iface;
+
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
 		goto out_wq;
@@ -99,9 +235,12 @@ out:
 }
 EXPORT_SYMBOL(ieee802154_register_device);
 
+
+
 void ieee802154_unregister_device(struct ieee802154_dev *dev)
 {
 	struct mac802154_priv *priv = mac802154_to_priv(dev);
+	struct mac802154_sub_if_data *sdata, *next;
 
 	flush_workqueue(priv->dev_workqueue);
 	destroy_workqueue(priv->dev_workqueue);
@@ -112,6 +251,14 @@ void ieee802154_unregister_device(struct ieee802154_dev *dev)
 	priv->running = 0;
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
-- 
1.7.2.3


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
