From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 08/11] mac802154: add llsec
	configuration functions
Date: Fri, 16 May 2014 17:46:42 +0200
Message-ID: <1400255205-9031-9-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154_netdev.h |   36 ++++++++
 net/mac802154/mac802154.h       |   33 +++++++
 net/mac802154/mac_cmd.c         |   18 ++++
 net/mac802154/mib.c             |  187 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 274 insertions(+)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 000c855..eb9f850 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -358,6 +358,40 @@ enum {
 	IEEE802154_LLSEC_PARAM_COORD_SHORTADDR = 1 << 8,
 };
 
+struct ieee802154_llsec_ops {
+	int (*get_params)(struct net_device *dev,
+			  struct ieee802154_llsec_params *params);
+	int (*set_params)(struct net_device *dev,
+			  const struct ieee802154_llsec_params *params,
+			  int changed);
+
+	int (*add_key)(struct net_device *dev,
+		       const struct ieee802154_llsec_key_id *id,
+		       const struct ieee802154_llsec_key *key);
+	int (*del_key)(struct net_device *dev,
+		       const struct ieee802154_llsec_key_id *id);
+
+	int (*add_dev)(struct net_device *dev,
+		       const struct ieee802154_llsec_device *llsec_dev);
+	int (*del_dev)(struct net_device *dev, __le64 dev_addr);
+
+	int (*add_devkey)(struct net_device *dev,
+			  __le64 device_addr,
+			  const struct ieee802154_llsec_device_key *key);
+	int (*del_devkey)(struct net_device *dev,
+			  __le64 device_addr,
+			  const struct ieee802154_llsec_device_key *key);
+
+	int (*add_seclevel)(struct net_device *dev,
+			    const struct ieee802154_llsec_seclevel *sl);
+	int (*del_seclevel)(struct net_device *dev,
+			    const struct ieee802154_llsec_seclevel *sl);
+
+	void (*lock_table)(struct net_device *dev);
+	void (*get_table)(struct net_device *dev,
+			  struct ieee802154_llsec_table **t);
+	void (*unlock_table)(struct net_device *dev);
+};
 /*
  * This should be located at net_device->ml_priv
  *
@@ -388,6 +422,8 @@ struct ieee802154_mlme_ops {
 	void (*get_mac_params)(struct net_device *dev,
 			       struct ieee802154_mac_params *params);
 
+	struct ieee802154_llsec_ops *llsec;
+
 	/* The fields below are required. */
 
 	struct wpan_phy *(*get_phy)(const struct net_device *dev);
diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index a8d7cbc..762a6f8 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -136,4 +136,37 @@ int mac802154_set_mac_params(struct net_device *dev,
 void mac802154_get_mac_params(struct net_device *dev,
 			      struct ieee802154_mac_params *params);
 
+int mac802154_get_params(struct net_device *dev,
+			 struct ieee802154_llsec_params *params);
+int mac802154_set_params(struct net_device *dev,
+			 const struct ieee802154_llsec_params *params,
+			 int changed);
+
+int mac802154_add_key(struct net_device *dev,
+		      const struct ieee802154_llsec_key_id *id,
+		      const struct ieee802154_llsec_key *key);
+int mac802154_del_key(struct net_device *dev,
+		      const struct ieee802154_llsec_key_id *id);
+
+int mac802154_add_dev(struct net_device *dev,
+		      const struct ieee802154_llsec_device *llsec_dev);
+int mac802154_del_dev(struct net_device *dev, __le64 dev_addr);
+
+int mac802154_add_devkey(struct net_device *dev,
+			 __le64 device_addr,
+			 const struct ieee802154_llsec_device_key *key);
+int mac802154_del_devkey(struct net_device *dev,
+			 __le64 device_addr,
+			 const struct ieee802154_llsec_device_key *key);
+
+int mac802154_add_seclevel(struct net_device *dev,
+			   const struct ieee802154_llsec_seclevel *sl);
+int mac802154_del_seclevel(struct net_device *dev,
+			   const struct ieee802154_llsec_seclevel *sl);
+
+void mac802154_lock_table(struct net_device *dev);
+void mac802154_get_table(struct net_device *dev,
+			 struct ieee802154_llsec_table **t);
+void mac802154_unlock_table(struct net_device *dev);
+
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index d40c092..afb4e2c 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -64,6 +64,22 @@ static struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
 	return to_phy(get_device(&priv->hw->phy->dev));
 }
 
+static struct ieee802154_llsec_ops mac802154_llsec_ops = {
+	.get_params = mac802154_get_params,
+	.set_params = mac802154_set_params,
+	.add_key = mac802154_add_key,
+	.del_key = mac802154_del_key,
+	.add_dev = mac802154_add_dev,
+	.del_dev = mac802154_del_dev,
+	.add_devkey = mac802154_add_devkey,
+	.del_devkey = mac802154_del_devkey,
+	.add_seclevel = mac802154_add_seclevel,
+	.del_seclevel = mac802154_del_seclevel,
+	.lock_table = mac802154_lock_table,
+	.get_table = mac802154_get_table,
+	.unlock_table = mac802154_unlock_table,
+};
+
 struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced = {
 	.get_phy = mac802154_get_phy,
 };
@@ -75,6 +91,8 @@ struct ieee802154_mlme_ops mac802154_mlme_wpan = {
 	.get_short_addr = mac802154_dev_get_short_addr,
 	.get_dsn = mac802154_dev_get_dsn,
 
+	.llsec = &mac802154_llsec_ops,
+
 	.set_mac_params = mac802154_set_mac_params,
 	.get_mac_params = mac802154_get_mac_params,
 };
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 153bd1d..18a2faa 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -214,3 +214,190 @@ void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
 	} else
 		mutex_unlock(&priv->hw->phy->pib_lock);
 }
+
+
+int mac802154_get_params(struct net_device *dev,
+			 struct ieee802154_llsec_params *params)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_get_params(&priv->sec, params);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+int mac802154_set_params(struct net_device *dev,
+			 const struct ieee802154_llsec_params *params,
+			 int changed)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_set_params(&priv->sec, params, changed);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+
+int mac802154_add_key(struct net_device *dev,
+		      const struct ieee802154_llsec_key_id *id,
+		      const struct ieee802154_llsec_key *key)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_key_add(&priv->sec, id, key);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+int mac802154_del_key(struct net_device *dev,
+		      const struct ieee802154_llsec_key_id *id)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_key_del(&priv->sec, id);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+
+int mac802154_add_dev(struct net_device *dev,
+		      const struct ieee802154_llsec_device *llsec_dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_dev_add(&priv->sec, llsec_dev);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+int mac802154_del_dev(struct net_device *dev, __le64 dev_addr)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_dev_del(&priv->sec, dev_addr);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+
+int mac802154_add_devkey(struct net_device *dev,
+			 __le64 device_addr,
+			 const struct ieee802154_llsec_device_key *key)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_devkey_add(&priv->sec, device_addr, key);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+int mac802154_del_devkey(struct net_device *dev,
+			 __le64 device_addr,
+			 const struct ieee802154_llsec_device_key *key)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_devkey_del(&priv->sec, device_addr, key);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+
+int mac802154_add_seclevel(struct net_device *dev,
+			   const struct ieee802154_llsec_seclevel *sl)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_seclevel_add(&priv->sec, sl);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+int mac802154_del_seclevel(struct net_device *dev,
+			   const struct ieee802154_llsec_seclevel *sl)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	int res;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+	res = mac802154_llsec_seclevel_del(&priv->sec, sl);
+	mutex_unlock(&priv->sec_mtx);
+
+	return res;
+}
+
+
+void mac802154_lock_table(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_lock(&priv->sec_mtx);
+}
+
+void mac802154_get_table(struct net_device *dev,
+			 struct ieee802154_llsec_table **t)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	*t = &priv->sec.table;
+}
+
+void mac802154_unlock_table(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	mutex_unlock(&priv->sec_mtx);
+}
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
