From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 05/10] ieee802154: add support for listen-before-talk in wpan_phy
Date: Fri, 14 Feb 2014 23:49:27 +0100
Message-ID: <1392418172-5305-6-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:43999 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbaBNW6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:58:31 -0500
In-Reply-To: <1392418172-5305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Listen-before-talk is an alternative to CSMA in uncoordinated networks
and prescribed by european regulations if one wants to have a device
with radio duty cycles above 10% (or less in some bands). Add a phy
property to enable/disable LBT in the phy, including support in the
at86rf230 driver for RF212 chips.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 11 +++++++-
 include/linux/nl802154.h           |  1 +
 include/net/mac802154.h            |  6 ++++
 include/net/wpan-phy.h             |  3 ++
 net/ieee802154/nl-phy.c            | 58 ++++++++++++++++++++++++++++++--------
 net/ieee802154/nl_policy.c         |  1 +
 net/mac802154/ieee802154_dev.c     | 11 ++++++++
 7 files changed, 78 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index bc80ca93..75bc9cf 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -152,7 +152,7 @@ static inline int is_rf212(struct at86rf230_local *local)
 #define	SR_RESERVED_17_5	0x17, 0x08, 3
 #define	SR_AACK_UPLD_RES_FT	0x17, 0x10, 4
 #define	SR_AACK_FLTR_RES_FT	0x17, 0x20, 5
-#define	SR_RESERVED_17_2	0x17, 0x40, 6
+#define	SR_CSMA_LBT_MODE	0x17, 0x40, 6
 #define	SR_RESERVED_17_1	0x17, 0x80, 7
 #define	RG_FTN_CTRL	(0x18)
 #define	SR_RESERVED_18_2	0x18, 0x7f, 0
@@ -787,6 +787,14 @@ at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
 	return 0;
 }
 
+static int
+at86rf212_set_lbt(struct ieee802154_dev *dev, bool on)
+{
+	struct at86rf230_local *lp = dev->priv;
+
+	return at86rf230_write_subreg(lp, SR_CSMA_LBT_MODE, on);
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -806,6 +814,7 @@ static struct ieee802154_ops at86rf212_ops = {
 	.stop = at86rf230_stop,
 	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
 	.set_txpower = at86rf212_set_txpower,
+	.set_lbt = at86rf212_set_lbt,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 625d19e..326baee 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -71,6 +71,7 @@ enum {
 	IEEE802154_ATTR_DEV_TYPE,
 
 	IEEE802154_ATTR_TXPOWER,
+	IEEE802154_ATTR_LBT_ENABLED,
 
 	__IEEE802154_ATTR_MAX,
 };
diff --git a/include/net/mac802154.h b/include/net/mac802154.h
index 8bd2785..521edcb 100644
--- a/include/net/mac802154.h
+++ b/include/net/mac802154.h
@@ -117,6 +117,11 @@ struct ieee802154_dev {
  * set_txpower:
  *	  Set radio transmit power in dB. Called with pib_lock held.
  *	  Returns either zero, or negative errno.
+ *
+ * set_lbt
+ *	  Enables or disables listen before talk on the device. Called with
+ *	  pib_lock held.
+ *	  Returns either zero, or negative errno.
  */
 struct ieee802154_ops {
 	struct module	*owner;
@@ -134,6 +139,7 @@ struct ieee802154_ops {
 	int		(*ieee_addr)(struct ieee802154_dev *dev,
 				     u8 addr[IEEE802154_ADDR_LEN]);
 	int		(*set_txpower)(struct ieee802154_dev *dev, int db);
+	int		(*set_lbt)(struct ieee802154_dev *dev, bool on);
 };
 
 /* Basic interface to register ieee802154 device */
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 47fc0c1..804e6c4 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -47,6 +47,8 @@ struct wpan_phy {
 	s8 transmit_power;
 	u8 cca_mode;
 
+	bool lbt;
+
 	struct device dev;
 	int idx;
 
@@ -55,6 +57,7 @@ struct wpan_phy {
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	int (*set_txpower)(struct wpan_phy *phy, int db);
+	int (*set_lbt)(struct wpan_phy *phy, bool on);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index d3ee62f..f248122 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -56,7 +56,8 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	if (nla_put_string(msg, IEEE802154_ATTR_PHY_NAME, wpan_phy_name(phy)) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_PAGE, phy->current_page) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_CHANNEL, phy->current_channel) ||
-	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power))
+	    nla_put_s8(msg, IEEE802154_ATTR_TXPOWER, phy->transmit_power) ||
+	    nla_put_u8(msg, IEEE802154_ATTR_LBT_ENABLED, phy->lbt))
 		goto nla_put_failure;
 	for (i = 0; i < 32; i++) {
 		if (phy->channels_supported[i])
@@ -356,40 +357,71 @@ out_dev:
 	return rc;
 }
 
+static int phy_set_txpower(struct wpan_phy *phy, struct genl_info *info)
+{
+	int txpower = nla_get_s8(info->attrs[IEEE802154_ATTR_TXPOWER]);
+	int rc;
+
+	rc = phy->set_txpower(phy, txpower);
+	if (rc < 0)
+		return rc;
+
+	phy->transmit_power = txpower;
+
+	return 0;
+}
+
+static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
+{
+	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
+	int rc;
+
+	rc = phy->set_lbt(phy, on);
+	if (rc < 0)
+		return rc;
+
+	phy->lbt = on;
+
+	return 0;
+}
+
 int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 {
 	struct wpan_phy *phy;
 	const char *name;
-	int txpower;
-	int rc = -EINVAL;
+	int rc = -ENOTSUPP;
 
 	pr_debug("%s\n", __func__);
 
-	if (!info->attrs[IEEE802154_ATTR_PHY_NAME])
+	if (!info->attrs[IEEE802154_ATTR_PHY_NAME] &&
+		!info->attrs[IEEE802154_ATTR_LBT_ENABLED])
 		return -EINVAL;
 
 	name = nla_data(info->attrs[IEEE802154_ATTR_PHY_NAME]);
 	if (name[nla_len(info->attrs[IEEE802154_ATTR_PHY_NAME]) - 1] != '\0')
 		return -EINVAL; /* phy name should be null-terminated */
 
-	txpower = nla_get_s8(info->attrs[IEEE802154_ATTR_TXPOWER]);
-
 	phy = wpan_phy_find(name);
 	if (!phy)
 		return -ENODEV;
 
-	if (!phy->set_txpower)
+	if ((!phy->set_txpower && info->attrs[IEEE802154_ATTR_TXPOWER]) ||
+		(!phy->set_lbt && info->attrs[IEEE802154_ATTR_LBT_ENABLED]))
 		goto out;
 
 	mutex_lock(&phy->pib_lock);
 
-	rc = phy->set_txpower(phy, txpower);
-	if (rc < 0) {
-		mutex_unlock(&phy->pib_lock);
-		goto out;
+	if (info->attrs[IEEE802154_ATTR_TXPOWER]) {
+		rc = phy_set_txpower(phy, info);
+		if (rc < 0)
+			goto error;
 	}
 
-	phy->transmit_power = txpower;
+	if (info->attrs[IEEE802154_ATTR_LBT_ENABLED]) {
+		rc = phy_set_lbt(phy, info);
+		if (rc < 0)
+			goto error;
+	}
 
 	mutex_unlock(&phy->pib_lock);
 
@@ -397,6 +429,8 @@ int ieee802154_set_phyparams(struct sk_buff *skb, struct genl_info *info)
 
 	return 0;
 
+error:
+	mutex_unlock(&phy->pib_lock);
 out:
 	wpan_phy_put(phy);
 	return rc;
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 90b1d0d..a09f642 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -54,5 +54,6 @@ const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_CHANNEL_PAGE_LIST] = { .len = 32 * 4, },
 
 	[IEEE802154_ATTR_TXPOWER] = { .type = NLA_S8, },
+	[IEEE802154_ATTR_LBT_ENABLED] = { .type = NLA_U8, },
 };
 
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 9eb49e0..56338c8 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -175,6 +175,16 @@ static int mac802154_set_txpower(struct wpan_phy *phy, int db)
 	return priv->ops->set_txpower(&priv->hw, db);
 }
 
+static int mac802154_set_lbt(struct wpan_phy *phy, bool on)
+{
+	struct mac802154_priv *priv = wpan_phy_priv(phy);
+
+	if (!priv->ops->set_lbt)
+		return -ENOTSUPP;
+
+	return priv->ops->set_lbt(&priv->hw, on);
+}
+
 struct ieee802154_dev *
 ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 {
@@ -253,6 +263,7 @@ int ieee802154_register_device(struct ieee802154_dev *dev)
 	priv->phy->add_iface = mac802154_add_iface;
 	priv->phy->del_iface = mac802154_del_iface;
 	priv->phy->set_txpower = mac802154_set_txpower;
+	priv->phy->set_lbt = mac802154_set_lbt;
 
 	rc = wpan_phy_register(priv->phy);
 	if (rc < 0)
-- 
1.8.5.4
