From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 1/2] mac802154: allow only one
	WPAN to be up at any given time
Date: Mon, 31 Mar 2014 15:17:52 +0200
Message-ID: <1396271873-10300-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1396271873-10300-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

All 802.15.4 PHY devices with drivers in tree can support only one WPAN
at any given time, yet the stack allows arbitrarily many WPAN devices to
be created and up at the same time. This cannot work with what the
hardware provides, and in the current implementation, provides an easy
DoS vector to any process on the system that may call socket() and
sendmsg().

Thus, allow only one WPAN per PHY to be up at once, just like mac80211
does for managed devices.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/mac802154/ieee802154_dev.c |   25 +++++++++++++++++++++++++
 net/mac802154/mac802154.h      |    1 +
 2 files changed, 26 insertions(+)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 10cdb09..e7aa764 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -36,9 +36,28 @@
 int mac802154_slave_open(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct mac802154_sub_if_data *subif;
 	struct mac802154_priv *ipriv = priv->hw;
 	int res = 0;
 
+	ASSERT_RTNL();
+
+	if (priv->type == IEEE802154_DEV_WPAN) {
+		mutex_lock(&priv->hw->slaves_mtx);
+		list_for_each_entry(subif, &priv->hw->slaves, list) {
+			if (subif != priv && subif->type == priv->type &&
+			    subif->running) {
+				mutex_unlock(&priv->hw->slaves_mtx);
+				return -EBUSY;
+			}
+		}
+		mutex_unlock(&priv->hw->slaves_mtx);
+	}
+
+	mutex_lock(&priv->hw->slaves_mtx);
+	priv->running = true;
+	mutex_unlock(&priv->hw->slaves_mtx);
+
 	if (ipriv->open_count++ == 0) {
 		res = ipriv->ops->start(&ipriv->hw);
 		WARN_ON(res);
@@ -69,8 +88,14 @@ int mac802154_slave_close(struct net_device *dev)
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	struct mac802154_priv *ipriv = priv->hw;
 
+	ASSERT_RTNL();
+
 	netif_stop_queue(dev);
 
+	mutex_lock(&priv->hw->slaves_mtx);
+	priv->running = false;
+	mutex_unlock(&priv->hw->slaves_mtx);
+
 	if (!--ipriv->open_count)
 		ipriv->ops->stop(&ipriv->hw);
 
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 4619486..f40522e 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -71,6 +71,7 @@ struct mac802154_sub_if_data {
 	struct net_device *dev;
 
 	int type;
+	bool running;
 
 	spinlock_t mib_lock;
 
-- 
1.7.9.5


------------------------------------------------------------------------------
